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
        Bands = model.TaskBand.empty

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
                'Tag', obj.TaskSpec.Receiver.Config.tag, ...
                'Definition', obj.TaskSpec.Receiver.Config, ...
                'Parameters', jsondecode(obj.TaskSpec.Receiver.Selection.Parameters{1}) ...
            );
        end

        %-----------------------------------------------------------------%
        function errorMsg = reinitializeReceiver(obj, receiverHandle, EMSatObj, ERMxObj)
            obj.Connections.receiver     = receiverHandle;
            obj.TaskSpec.Receiver.Handle = receiverHandle;
            obj.ReceiverId               = receiverHandle.UserData.IDN;

            errorMsg = obj.initializeReceiver(1, EMSatObj, ERMxObj);
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function errorMsg = initializeReceiver(obj, idx, EMSatObj, ERMxObj)
            errorMsg = '';

            try
                receiverHandle = obj(idx).Connections.receiver;
                if ~isempty(receiverHandle) && isvalid(receiverHandle)
                    driver = model.ReceiverDriver(obj(idx).TaskSpec.Receiver.Config, receiverHandle);

                    initialize(driver, strcmp(obj(idx).TaskSpec.Receiver.Reset, 'On'), obj(idx).TaskSpec.Receiver.Sync)
                    specificAspects(driver)
                end

                obj(idx).Status = 'Na fila';
                obj(idx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(datetime('now')), 'message', 'Incluída na fila a tarefa.');

            catch ME
                errorMsg = ME.message;
                obj(idx).Status = 'Erro';
                obj(idx).LogEntries(end+1) = struct('level', 'error', 'timestamp', char(datetime('now')), 'message', errorMsg);
            end

            function specificAspects(driver)
                taskSpec  = obj(idx).TaskSpec;
                rawBands  = taskSpec.Script.Band;
                taskBands = model.TaskBand.empty;
            
                % Teste de configuração para cada uma das bandas - em resumo, configura-se 
                % os parâmetros (FreqStart, FreqStop, Resolution etc) e, posteriormente, 
                % confirma-se que os parâmetros foram devidamente configurados.
                setOperationMode(driver)

                for ii = 1:numel(rawBands)
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
            
                    % Programa a banda no receptor e confirma que os parâmetros foram aceitos.
                    params = bandParameters(driver, rawBands(ii), freqStart, freqStop);
                    [taskBands(ii).ScpiCommands, taskBands(ii).ReceiverState] = applyBandConfig(driver, params);

                    taskBands(ii).DataPoints   = params.dataPoints;
                    taskBands(ii).FlipArray    = flipArray;
                    taskBands(ii).Antenna      = util.AntennaTracking.parseAntennaTarget(taskSpec.Antenna.MetaData, antennaName);
            
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