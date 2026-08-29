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

        TaskSpec = class.taskClass.empty
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
                generalAspects(idx);
                receiverConfig_SpecificBand(obj, idx, EMSatObj, ERMxObj);
                obj(idx).Status = 'Na fila';

                if ~isempty(warnMsg)
                    obj(idx).LogEntries(end+1) = struct('level', 'warning', 'timestamp', obj(idx).Timing.createdAt, 'message', strjoin(warnMsg, '\n\n'));
                end
                obj(idx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(datetime('now')), 'message', 'Incluída na fila a tarefa.');

            catch ME
                fprintf('%s\n', jsonencode(ME))
                errorMsg = ME.message;

                if isempty(obj(idx).Bands)
                    obj(idx) = [];
                else
                    obj(idx).Status = 'Erro';
                    obj(idx).LogEntries(end+1) = struct('level', 'error', 'timestamp', char(datetime('now')), 'message', errorMsg);
                end
            end

            function generalAspects()
                taskSpec = obj(idx).TaskSpec;
                receiverConfig = taskSpec.Receiver.Config;
                receiverHandle = obj(idx).Connections.receiver;
    
                obj(idx).ReceiverCommands.startup = receiverConfig.StartUp{1};
                obj(idx).ReceiverCommands.query = receiverConfig.scpiQuery_Attenuation{1;
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
        end

        %-----------------------------------------------------------------%
        function warnMsg = receiverConfig_SpecificBand(obj, idx, EMSatObj, ERMxObj)
            warnMsg = {};
            
            receiverHandle = obj(idx).Connections.receiver;
            if isempty(receiverHandle) || ~isvalid(receiverHandle)
                return
            end

            taskSpec  = obj(idx).TaskSpec;
            rawBands  = taskSpec.Script.Band;
            taskBands = class.bandClass.empty;
        

            % Peculiaridades do receptor sob análise:
            instrInfo = obj(idx).TaskSpec.Receiver.Config;
            TraceMode_Values   = strsplit(instrInfo.Trace_Values{1},     ',');
            AverageMode_Values = instrInfo.AverageMode_Values{1};
            Detector_Values    = strsplit(instrInfo.Detector_Values{1},  ',');
            LevelUnit_Values   = strsplit(instrInfo.LevelUnit_Values{1}, ',');
            scpiVBW_Options    = strsplit(instrInfo.scpiVBW_Options{1},  ',');
        
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
                ResolutionMode  = 0;
                SampleTimeMode  = 1;
                SampleTimeValue = 0;
        
                % TraceMode
                switch rawBands(ii).TraceMode
                    case 'ClearWrite'; TraceModeID = 1;
                    case 'Average';    TraceModeID = 2;
                    case 'MaxHold';    TraceModeID = 3;
                    case 'MinHold';    TraceModeID = 4;
                end
                TraceMode = TraceMode_Values{TraceModeID};
                
                AverageMode = [];
                if ~isempty(AverageMode_Values); AverageMode = AverageMode_Values(TraceModeID);
                end
        
                % Average count
                AverageCount = rawBands(ii).IntegrationFactor;
                
                % Detector
                switch rawBands(ii).instrDetector
                    case 'Sample';        Detector = Detector_Values{1};
                    case 'Average/RMS';   Detector = Detector_Values{2};
                    case 'Positive Peak'; Detector = Detector_Values{3};
                    case 'Negative Peak'; Detector = Detector_Values{4};
                end
                
                % LevelUnit
                switch rawBands(ii).instrLevelUnit
                    case 'dBm';            LevelUnit = LevelUnit_Values{1};
                    case {'dBµV', 'dBμV'}; LevelUnit = LevelUnit_Values{2};
                end                
                
                % FreqStart/FreqStop
                switch taskSpec.Antenna.Switch.Name
                    case 'EMSat'
                        antennaLNBName = rawBands(ii).instrAntenna;
                        antennaName    = extractBefore(rawBands(ii).instrAntenna, ' ');
                        antIndex       = find(strcmp(EMSatObj.LNB.Name, antennaLNBName), 1);
            
                        freqBand       = abs([rawBands(ii).FreqStart, rawBands(ii).FreqStop] - double(EMSatObj.LNB.Offset(antIndex)));
                        FreqStart      = min(freqBand);
                        FreqStop       = max(freqBand);
                        
                        FlipArray      = EMSatObj.LNB.Inverted(antIndex);
                        SwitchPort     = EMSatObj.LNB.SwitchPort(antIndex);
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
                        FreqStart      = rawBands(ii).FreqStart;
                        FreqStop       = rawBands(ii).FreqStop;
        
                        antennaName    = rawBands(ii).instrAntenna;
                        antIndex       = find(strcmp({ERMxObj.Antenna.Name}, antennaName), 1);
                        SwitchPort     = ERMxObj.Antenna(antIndex).SwitchPort;
                        FlipArray      = [];
        
                    otherwise
                        FreqStart      = rawBands(ii).FreqStart;
                        FreqStop       = rawBands(ii).FreqStop;
                        
                        antennaName    = taskSpec.Antenna.MetaData.Name;    
                        FlipArray      = [];
                end
        
                % DataPoints, StepWidth, Resolution, Selectivity
                DataPoints      = rawBands(ii).instrDataPoints;
                StepWidth       = (rawBands(ii).FreqStop - rawBands(ii).FreqStart) ./ (rawBands(ii).instrDataPoints - 1);
                ResolutionValue = str2double(extractBefore(rawBands(ii).instrResolution, ' kHz')) .* 1e+3;
                Selectivity     = rawBands(ii).instrSelectivity;
        
                % VBW
                scpiVBW_Value   = '';
                if ~isempty(scpiVBW_Options{1})
                    switch rawBands(ii).instrVBW
                        case 'auto'; scpiVBW_Value = scpiVBW_Options{1};
                        otherwise;   scpiVBW_Value = replace(scpiVBW_Options{2}, '%VBWValue%', rawBands(ii).instrVBW);
                    end
                end
                
                % SensitivityMode, Preamp, AttenuationMode, AttenuationValue
                if ~isempty(rawBands(ii).instrSensitivityMode)
                    SensitivityMode = rawBands(ii).instrSensitivityMode;
                end
                
                switch rawBands(ii).instrPreamp
                    case 'On'; Preamp = 1;
                    otherwise; Preamp = 0;
                end
                
                AutoLevel = '';
                switch rawBands(ii).instrAttMode
                    case 'Auto'
                        AttenuationMode  = 1;
                        AttenuationValue = 0;
        
                        if strcmp(obj(idx).TaskSpec.Receiver.Selection.Name, 'Tektronix SA2500')
                            AutoLevel = ';:INPut:ALEVel';
                        end
        
                    otherwise
                        AttenuationMode  = 0;
                        AttenuationValue = str2double(extractBefore(rawBands(ii).instrAttFactor, ' dB'));
                end
                
                % SCPI main string
                replaceCell = {'%Trace%',              TraceMode;                 ... 
                               '%AverageMode%',        num2str(AverageMode);      ...
                               '%AverageCount%',       num2str(AverageCount);      ...
                               '%Detector%',           Detector;                  ...
                               '%LevelUnit%',          LevelUnit;                 ...
                               '%FreqStart%',          num2str(FreqStart);        ...
                               '%FreqStop%',           num2str(FreqStop);         ...
                               '%DataPoints%',         num2str(DataPoints);       ...
                               '%StepWidth%',          num2str(StepWidth);        ...
                               '%ResolutionMode%',     num2str(ResolutionMode);   ...
                               '%ResolutionValue%',    num2str(ResolutionValue);  ...
                               '%VBWOption%',          scpiVBW_Value;             ...
                               '%Selectivity%',        Selectivity;               ...
                               '%SensitivityMode%',    SensitivityMode;           ...
                               '%Preamp%',             num2str(Preamp);           ...
                               '%AttenuationMode%',    num2str(AttenuationMode);  ...
                               '%AutoLevel%',          AutoLevel;                 ...
                               '%AttenuationValue%',   num2str(AttenuationValue); ...
                               '%SampleTimeMode%',     num2str(SampleTimeMode);   ...
                               '%SampleTimeValue%',    num2str(SampleTimeValue);  ...
                               '%FreqCenter%',         num2str((FreqStart + FreqStop)/2);    ...
                               '%FreqSpan%',           num2str(FreqStop - FreqStart);        ...
                               '%DF_SquelchMode%',     rawBands(ii).DF_SquelchMode;           ...
                               '%DF_SquelchValue%',    num2str(rawBands(ii).DF_SquelchValue); ...
                               '%DF_MeasTime%',        num2str(rawBands(ii).DF_MeasTime)};
                
                scpiSet_Config = replace(instrInfo.scpiGeneral{1}, replaceCell(:,1), replaceCell(:,2));
                scpiSet_Att    = '';
                
                % Tenta programar valores...
                writeline(receiverHandle, scpiSet_Config);
                pause(instrInfo.BandPause)
                
                if ~AttenuationMode && ~isempty(instrInfo.scpiAttenuation{1})
                    scpiSet_Att = replace(char(instrInfo.scpiAttenuation{1}), '%AttenuationValue%', num2str(AttenuationValue));
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
                        case  1; if ~strcmp(splitAnswer{jj}, TraceMode);            error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        case  4; if ~strcmp(splitAnswer{jj}, Detector);             error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        case  5; if ~strcmp(splitAnswer{jj}, LevelUnit);            error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        case  6; if str2double(splitAnswer{jj}) ~= FreqStart;       error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        case  7; if str2double(splitAnswer{jj}) ~= FreqStop;        error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        case  8; if str2double(splitAnswer{jj}) ~= DataPoints;      error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        case  9; if str2double(splitAnswer{jj}) ~= StepWidth;       error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                        case 11; if str2double(splitAnswer{jj}) ~= ResolutionValue; error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                    end
                end
        
                taskBands(ii).SpecificSCPI = struct('configSET', scpiSet_Config, 'attSET', scpiSet_Att);
                taskBands(ii).rawMetaData  = scpiSet_Answer;
                taskBands(ii).DataPoints   = DataPoints;
                taskBands(ii).FlipArray    = FlipArray;
                taskBands(ii).Antenna      = fcn.antennaParser(taskSpec.Antenna.MetaData, antennaName);
        
                switch taskSpec.Antenna.Switch.Name
                    case 'EMSat'
                        taskBands(ii).Antenna.SwitchPort = SwitchPort;
                        taskBands(ii).Antenna.LNBChannel = LNBChannel;
                        taskBands(ii).Antenna.LNBIndex   = LNBIndex;
        
                    case 'ERMx'
                        taskBands(ii).Antenna.SwitchPort = SwitchPort;
                end
            end
        
            obj(idx).Bands = taskBands;
        end
        
        
        %-------------------------------------------------------------------------%
        function msg = msgConstructor(Type, Trigger, scpiSet_Config, scpiSet_Answer)
            switch Type
                case 1
                    msg = sprintf(['Triggered parameter: "%s\n"' ...
                                   'scpiSet_Config: %s'], Trigger, scpiSet_Config);
                case 2                                                              % 'error' | 'warning'
                    msg = sprintf(['Triggered parameter: "%s"\n' ...
                                   'scpiSet_Config: %s\n'        ...
                                   'scpiSet_Answer: %s'], Trigger, scpiSet_Config, scpiSet_Answer);
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