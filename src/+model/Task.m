classdef Task < matlab.mixin.Copyable

    %---------------------------------------------------------------------%
    % ## model.Task ##
    %
    % Representa uma tarefa de monitoração (na fila, em andamento ou já
    % finalizada) gerenciada pelo appColeta. Essa classe substitui a antiga
    % "class.specClass", preservando a mesma estrutura de propriedades para
    % manter compatibilidade com as funções auxiliares que a consomem.
    % A lista de tarefas em execução é mantida em model.TaskController.Tasks.
    %---------------------------------------------------------------------%

    properties
        ReceiverId = ''

        TaskSpec = model.TaskSpec.empty
        Timing = struct('createdAt', '', 'startedAt', NaT, 'endedAt', NaT, 'startupAt', NaT)
        
        Connections = struct('receiver', [], 'stream',[], 'gps', [])

        GPSLastFix = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '')
        ReceiverCommands = struct('reset', {}, 'startup', {}, 'sync', {}, 'query', {}, 'data', {})
        Bands = class.bandClass.empty

        RetryPolicy = struct( ...
            'receiver', struct('failureCount', 0, 'firstFailureAt', NaT, 'lastFailureAt', NaT), ...
            'gps',      struct('failureCount', 0, 'firstFailureAt', NaT, 'lastFailureAt', NaT) ...
        )

        Status = '' % 'Na fila' | 'Em andamento' | 'Cancelamento solicitado' | 'Concluída' | 'Cancelada' | 'Erro'
        LogEntries = struct('level', {}, 'timestamp', {}, 'message',  {})
    end


    methods
        %-----------------------------------------------------------------%
        function [obj, errorMsg] = AddOrEditTask(obj, infoEdition, newTask, EMSatObj, ERMxObj)
            switch infoEdition.type
                case 'new'
                    idx = numel(obj)+1;
                    obj(idx).Timing.createdAt = datestr(now, 'dd/mm/yyyy HH:MM:SS');

                case 'edit'
                    idx = infoEdition.idx;
            end

            obj(idx).TaskSpec = newTask;

            receptorHandle = newTask.Receiver.Handle;
            if ~isempty(receptorHandle) && isvalid(receptorHandle)
                obj(idx).Connections.receiver = receptorHandle;
                obj(idx).ReceiverId = receptorHandle.UserData.IDN;
            end
            
            obj(idx).Connections.stream = newTask.Streaming.Handle;
            obj(idx).Connections.gps = newTask.GPS.Handle;

            obj(idx).Timing.startedAt = datetime(newTask.Script.Observation.BeginTime, 'InputFormat', 'dd/MM/yyyy HH:mm:ss');
            obj(idx).Timing.endedAt = datetime(newTask.Script.Observation.EndTime,   'InputFormat', 'dd/MM/yyyy HH:mm:ss');

            obj.initializeGPSLastFix(idx, newTask.Script.GPS);
            errorMsg = obj.initializeReceiver(idx, EMSatObj, ERMxObj);
        end

        %-----------------------------------------------------------------%
        function receiver = buildReceiverConfig(obj)
            receiver = struct( ...
                'Type', obj.TaskSpec.Receiver.Selection.Type{1}, ...
                'Tag', obj.TaskSpec.Receiver.Config.Tag{1}, ...
                'Parameters', jsondecode(obj.TaskSpec.Receiver.Selection.Parameters{1}) ...
            );
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function errorMsg = initializeReceiver(obj, idx, EMSatObj, ERMxObj)
            errorMsg = '';

            try
                generalAspects()
                specificAspects()
                
                obj(idx).Status = 'Na fila';
                obj(idx).LogEntries(end+1) = struct('level', 'warning', 'timestamp', obj(idx).Timing.createdAt, 'message', strjoin(warnMsg, '\n\n'));
                obj(idx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(datetime('now')), 'message', 'Incluída na fila a tarefa.');

            catch ME
                obj(idx).Status = 'Erro';
                obj(idx).LogEntries(end+1) = struct('level', 'error', 'timestamp', char(datetime('now')), 'message', ME.message);
            end

            function generalAspects()
                taskSpec = obj(idx).TaskSpec;
                receiverConfig = taskSpec.Receiver.Config;
                receiverHandle = obj(idx).Connections.receiver;
    
                obj(idx).ReceiverCommands(1).startup = receiverConfig.StartUp{1};
                obj(idx).ReceiverCommands.query = receiverConfig.scpiQuery_Attenuation{1};
                obj(idx).ReceiverCommands.data = receiverConfig.scpiTraceData{1};
            
                if strcmp(taskSpec.Receiver.Reset, 'On')
                    obj(idx).ReceiverCommands.reset = receiverConfig.scpiReset{1};
                end
    
                switch taskSpec.Receiver.Sync
                    case 'Single Sweep'
                        syncSET = 'INITiate:CONTinuous OFF';
                    otherwise % 'Continuous Sweep' | 'Streaming'
                        syncSET = 'INITiate:CONTinuous ON';
                end
                obj(idx).ReceiverCommands.sync = syncSET;
    
                if ~isempty(receiverHandle) && isvalid(receiverHandle)
                    if ~isempty(obj(idx).ReceiverCommands.reset)
                        writeline(receiverHandle, receiverConfig.scpiReset{1});
                        pause(receiverConfig.ResetPause)
                    end
    
                    writeline(receiverHandle, receiverConfig.StartUp{1});
                    writeline(receiverHandle, syncSET);
                end
            end

            function specificAspects()
                receiverHandle = obj(idx).Connections.receiver;
                if isempty(receiverHandle) || ~isvalid(receiverHandle)
                    return
                end
    
                taskSpec  = obj(idx).TaskSpec;
                rawBands  = taskSpec.Script.Band;
                taskBands = class.bandClass.empty;
    
                % Peculiaridades do receptor sob análise:
                instrInfo = obj(idx).TaskSpec.Receiver.Config;
                traceModeOptions = strsplit(instrInfo.Trace_Values{1},     ',');
                averageModeOptions = instrInfo.AverageMode_Values{1};
                detectorOptions = strsplit(instrInfo.Detector_Values{1},  ',');
                levelUnitOptions = strsplit(instrInfo.LevelUnit_Values{1}, ',');
                vbwOptions = strsplit(instrInfo.scpiVBW_Options{1},  ',');
            
                rawFields = {'TraceMode',        'AverageMode',     'AveragCount',     ... %  1 a  3
                             'Detector',         'LevelUnit',       'FreqStart',       ... %  4 a  6
                             'FreqStop',         'DataPoints',      'StepWidth',       ... %  7 a  9
                             'ResolutionMode',   'ResolutionValue', 'Selectivity',     ... % 10 a 12
                             'SensitivityMode',  'Preamp',          'AttenuationMode', ... % 13 a 15
                             'AttenuationValue', 'SampleTimeMode',  'SampleTimeValue', ... % 16 a 18
                             'minFreqRange',     'maxFreqRange',    'VideoBandwidth',  ... % 19 a 21
                             'FreqCenter',       'FreqSpan',        'DF_SquelchMode',  ... % 22 a 24
                             'DF_SquelchValue',  'DF_MeasTime'};                           % 25 a 26
                rawFields = rawFields(instrInfo.scpiQuery_IDs{1});
            
                % Teste de configuração para cada uma das bandas - em resumo, configura-se 
                % os parâmetros (FreqStart, FreqStop, Resolution etc) e, posteriormente, 
                % confirma-se que os parâmetros foram devidamente configurados.
                if ismember(obj(idx).TaskSpec.Receiver.Config.connectFlag, [2, 3])
                    class.EB500Lib.OperationMode(receiverHandle, obj(idx).TaskSpec.Receiver.Config.connectFlag)
                end
            
                for ii = 1:numel(rawBands)
                    resolutionMode  = 0;
                    sampleTimeMode  = 1;
                    sampleTimeValue = 0;
            
                    % TraceMode
                    switch rawBands(ii).TraceMode
                        case 'ClearWrite'; traceId = 1;
                        case 'Average';    traceId = 2;
                        case 'MaxHold';    traceId = 3;
                        case 'MinHold';    traceId = 4;
                    end
                    traceMode = traceModeOptions{traceId};
                    
                    AverageMode = [];
                    if ~isempty(averageModeOptions); AverageMode = averageModeOptions(traceId);
                    end
            
                    % Average count
                    AverageCount = rawBands(ii).IntegrationFactor;
                    
                    % Detector
                    switch rawBands(ii).instrDetector
                        case 'Sample';        detector = detectorOptions{1};
                        case 'Average/RMS';   detector = detectorOptions{2};
                        case 'Positive Peak'; detector = detectorOptions{3};
                        case 'Negative Peak'; detector = detectorOptions{4};
                    end
                    
                    % LevelUnit
                    switch rawBands(ii).instrLevelUnit
                        case 'dBm';            levelUnit = levelUnitOptions{1};
                        case {'dBµV', 'dBμV'}; levelUnit = levelUnitOptions{2};
                    end                
                    
                    % FreqStart/FreqStop
                    switch taskSpec.Antenna.Switch.Name
                        case 'EMSat'
                            antennaLNBName = rawBands(ii).instrAntenna;
                            antennaName    = extractBefore(rawBands(ii).instrAntenna, ' ');
                            antIndex       = find(strcmp(EMSatObj.LNB.Name, antennaLNBName), 1);
                
                            freqBand       = abs([rawBands(ii).FreqStart, rawBands(ii).FreqStop] - double(EMSatObj.LNB.Offset(antIndex)));
                            freqStart      = min(freqBand);
                            freqStop       = max(freqBand);
                            
                            flipArray      = EMSatObj.LNB.Inverted(antIndex);
                            switchPort     = EMSatObj.LNB.SwitchPort(antIndex);
                            LNBChannel     = EMSatObj.LNB.LNBChannel(antIndex);
                
                            idx1 = find(strcmp({EMSatObj.Antenna.Name}, extractBefore(rawBands(ii).instrAntenna, ' ')), 1);
                            idx2 = -1;
                            for kk = 1:numel(EMSatObj.Antenna(idx1).LNB)
                                if ismember(antennaLNBName, EMSatObj.Antenna(idx1).LNB(kk).Name)
                                    idx2 = kk;
                                    break
                                end
                            end
                            LNBIndex       = [idx1, idx2];
            
                        case 'ERMx'
                            freqStart      = rawBands(ii).FreqStart;
                            freqStop       = rawBands(ii).FreqStop;
            
                            antennaName    = rawBands(ii).instrAntenna;
                            antIndex       = find(strcmp({ERMxObj.Antenna.Name}, antennaName), 1);
                            switchPort     = ERMxObj.Antenna(antIndex).SwitchPort;
                            flipArray      = [];
            
                        otherwise
                            freqStart      = rawBands(ii).FreqStart;
                            freqStop       = rawBands(ii).FreqStop;
                            
                            antennaName    = taskSpec.Antenna.MetaData.Name;    
                            flipArray      = [];
                    end
            
                    % DataPoints, StepWidth, Resolution, Selectivity
                    dataPoints  = rawBands(ii).instrDataPoints;
                    stepWidth   = (rawBands(ii).FreqStop - rawBands(ii).FreqStart) ./ (rawBands(ii).instrDataPoints - 1);
                    resolution  = str2double(extractBefore(rawBands(ii).instrResolution, ' kHz')) .* 1e+3;
                    selectivity = rawBands(ii).instrSelectivity;
            
                    % VBW
                    vbwValue = '';
                    if ~isempty(vbwOptions{1})
                        switch rawBands(ii).instrVBW
                            case 'auto'
                                vbwValue = vbwOptions{1};
                            otherwise
                                vbwValue = replace(vbwOptions{2}, '%VBWValue%', rawBands(ii).instrVBW);
                        end
                    end
                    
                    % SensitivityMode, Preamp, AttenuationMode, AttenuationValue
                    if ~isempty(rawBands(ii).instrSensitivityMode)
                        sensitivityMode = rawBands(ii).instrSensitivityMode;
                    end
                    
                    switch rawBands(ii).instrPreamp
                        case 'On'
                            preamp = 1;
                        otherwise
                            preamp = 0;
                    end
                    
                    autoLevel = '';
                    switch rawBands(ii).instrAttMode
                        case 'Auto'
                            attenuationMode  = 1;
                            attenuationValue = 0;
            
                            if strcmp(obj(idx).TaskSpec.Receiver.Selection.Name, 'Tektronix SA2500')
                                autoLevel = ';:INPut:ALEVel';
                            end
            
                        otherwise
                            attenuationMode  = 0;
                            attenuationValue = str2double(extractBefore(rawBands(ii).instrAttFactor, ' dB'));
                    end
                    
                    % SCPI main string
                    replaceCell = {'%Trace%',              traceMode;                 ... 
                                   '%AverageMode%',        num2str(AverageMode);      ...
                                   '%AverageCount%',       num2str(AverageCount);      ...
                                   '%Detector%',           detector;                  ...
                                   '%LevelUnit%',          levelUnit;                 ...
                                   '%FreqStart%',          num2str(freqStart);        ...
                                   '%FreqStop%',           num2str(freqStop);         ...
                                   '%DataPoints%',         num2str(dataPoints);       ...
                                   '%StepWidth%',          num2str(stepWidth);        ...
                                   '%ResolutionMode%',     num2str(resolutionMode);   ...
                                   '%ResolutionValue%',    num2str(resolution);  ...
                                   '%VBWOption%',          vbwValue;             ...
                                   '%Selectivity%',        selectivity;               ...
                                   '%SensitivityMode%',    sensitivityMode;           ...
                                   '%Preamp%',             num2str(preamp);           ...
                                   '%AttenuationMode%',    num2str(attenuationMode);  ...
                                   '%AutoLevel%',          autoLevel;                 ...
                                   '%AttenuationValue%',   num2str(attenuationValue); ...
                                   '%SampleTimeMode%',     num2str(sampleTimeMode);   ...
                                   '%SampleTimeValue%',    num2str(sampleTimeValue);  ...
                                   '%FreqCenter%',         num2str((freqStart + freqStop)/2);    ...
                                   '%FreqSpan%',           num2str(freqStop - freqStart);        ...
                                   '%DF_SquelchMode%',     rawBands(ii).DF_SquelchMode;           ...
                                   '%DF_SquelchValue%',    num2str(rawBands(ii).DF_SquelchValue); ...
                                   '%DF_MeasTime%',        num2str(rawBands(ii).DF_MeasTime)};
                    
                    scpiSet_Config = replace(instrInfo.scpiGeneral{1}, replaceCell(:,1), replaceCell(:,2));
                    scpiSet_Att    = '';
                    
                    % Tenta programar valores...
                    writeline(receiverHandle, scpiSet_Config);
                    pause(instrInfo.BandPause)
                    
                    if ~attenuationMode && ~isempty(instrInfo.scpiAttenuation{1})
                        scpiSet_Att = replace(char(instrInfo.scpiAttenuation{1}), '%AttenuationValue%', num2str(attenuationValue));
                        writeline(receiverHandle, scpiSet_Att);
                    end
                    
                    % Confirma que foram programados corretamente os valores no sensor...
                    flush(receiverHandle)
                    writeline(receiverHandle, instrInfo.scpiQuery{1});
            
                    rawAnswer = '';
            
                    statusTic = tic;
                    t = toc(statusTic);
                    while t < class.Constants.Timeout
                        if receiverHandle.NumBytesAvailable
                            rawAnswer = readline(receiverHandle);
                            if ~isempty(rawAnswer)
                                rawAnswer = strtrim(rawAnswer);
                                break
                            end
                        end
                        t = toc(statusTic);
                    end
            
                    if isempty(rawAnswer)
                        error(msgConstructor(1, 'Empty string', scpiSet_Config, ''))
                    end
            
                    splitAnswer    = strsplit(rawAnswer, ';');
                    scpiSet_Answer = [];
            
                    for jj = 1:numel(rawFields)
                        scpiSet_Answer.(rawFields{jj}) = splitAnswer{jj};
                    end
                    scpiSet_Answer = jsonencode(scpiSet_Answer);
            
                    for jj = 1:numel(instrInfo.scpiQuery_IDs{1})
                        Trigger = rawFields{jj};
            
                        % Restringido a mensagem de erro às principais variáveis a configurar: 
                        % "FreqStart", "FreqStop", "ResolutionValue" (RBW), "TraceMode", 
                        % "Detector" etc.
                        switch instrInfo.scpiQuery_IDs{1}(jj)
                            case  1; if ~strcmp(splitAnswer{jj}, traceMode);            error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                            case  4; if ~strcmp(splitAnswer{jj}, detector);             error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                            case  5; if ~strcmp(splitAnswer{jj}, levelUnit);            error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                            case  6; if str2double(splitAnswer{jj}) ~= freqStart;       error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                            case  7; if str2double(splitAnswer{jj}) ~= freqStop;        error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                            case  8; if str2double(splitAnswer{jj}) ~= dataPoints;      error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                            case  9; if str2double(splitAnswer{jj}) ~= stepWidth;       error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                            case 11; if str2double(splitAnswer{jj}) ~= resolution; error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        end
                    end
            
                    taskBands(ii).SpecificSCPI = struct('configSET', scpiSet_Config, 'attSET', scpiSet_Att);
                    taskBands(ii).rawMetaData  = scpiSet_Answer;
                    taskBands(ii).DataPoints   = dataPoints;
                    taskBands(ii).FlipArray    = flipArray;
                    taskBands(ii).Antenna      = fcn.antennaParser(taskSpec.Antenna.MetaData, antennaName);
            
                    switch taskSpec.Antenna.Switch.Name
                        case 'EMSat'
                            taskBands(ii).Antenna.SwitchPort = switchPort;
                            taskBands(ii).Antenna.LNBChannel = LNBChannel;
                            taskBands(ii).Antenna.LNBIndex   = LNBIndex;
            
                        case 'ERMx'
                            taskBands(ii).Antenna.SwitchPort = switchPort;
                    end
                end
            
                obj(idx).Bands = taskBands;
            end

            function msg = msgConstructor(type, trigger, configMsg, responseMsg)
                switch type
                    case 1
                        msg = sprintf(['Triggered parameter: "%s\n"' ...
                                       'scpiSet_Config: %s'], trigger, configMsg);
                    case 2                                                              % 'error' | 'warning'
                        msg = sprintf(['Triggered parameter: "%s"\n' ...
                                       'scpiSet_Config: %s\n'        ...
                                       'scpiSet_Answer: %s'], trigger, configMsg, responseMsg);
                end
            end
        end

        %-----------------------------------------------------------------%
        function initializeGPSLastFix(obj, idx, gps)
            if strcmp(gps.Type, 'Manual')
                obj(idx).GPSLastFix.Status = -1;
                obj(idx).GPSLastFix.Latitude  = gps.Latitude;
                obj(idx).GPSLastFix.Longitude = gps.Longitude;
            end

            obj(idx).GPSLastFix.TimeStamp = obj(idx).Timing.createdAt;
        end
    end
end