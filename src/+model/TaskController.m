classdef TaskController < handle

    %---------------------------------------------------------------------%
    % ## model.TaskController ##
    %
    % Esse objeto é responsável pelo controle da execução das tarefas do
    % appColeta (model.Task), buscando garantir que os tempos de revisita
    % sejam respeitados e que sejam gerenciados os erros da execução,
    % iniciando tentativas de reconexão de instrumento, caso necessário.
    %
    % Essa classe substitui a lógica que estava anteriormente implementada
    % em "winAppColeta_exported.m" (método "RegularTask_MainLoop" e as
    % funções "RegularTask_*" diretamente relacionadas a ele).
    %
    % Comunicação com a UI: ao invés de manipular diretamente componentes
    % gráficos, o controller dispara eventos (StatusChanged, TasksChanged,
    % BandDataAcquired, GpsUpdated, ErrorRaised, RevisitInfoChanged), aos
    % quais o app principal se inscreve.
    %
    % O acesso a recursos que não são de interface (bibliotecas de
    % instrumento, configurações gerais, diálogo de progresso) é feito por
    % meio da referência ao app ("App").
    %
    % API pública: apenas o construtor e "runLoop". Os métodos usados pelo
    % fluxo de restauração/edição manual de tarefas em
    % "winAppColeta_exported.m" (reconexão de tarefas persistidas e reação
    % a ações do usuário na tabela) permanecem restritos às classes amigas
    % "winAppColeta_exported" e "winAppColeta" por meio de
    % "Access = {?winAppColeta_exported, ?winAppColeta}".
    %
    % app.TaskController = model.TaskController(app);
    %---------------------------------------------------------------------%

    events
        StatusChanged                                                       % (TaskId) Tarefa mudou de estado (tabela precisa ser reconstruída).
        TasksChanged                                                        % Estado persistente da lista de tarefas precisa ser salvo.
        BandDataAcquired                                                    % (TaskId, BandId, Payload = maskTrigger) Novo traço adquirido.
        GpsUpdated                                                          % (TaskId, Payload = gpsData) Nova posição de GPS lida.
        ErrorRaised                                                         % (TaskId, Payload = 'Receiver' | 'GPS') Erro de aquisição.
        RevisitInfoChanged                                                  % Estimativa de tempo de revisita foi recalculada.
    end


    properties
        %-----------------------------------------------------------------%
        Tasks = model.Task.empty
        UDPPortArray = {}
    end


    properties
        %-----------------------------------------------------------------%
        RevisitInfo = []
        IsRunning (1,1) logical = false
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        App                                                                 % Handle to the owning winAppColeta_exported app.
    end


    methods
        %-----------------------------------------------------------------%
        function obj = TaskController(app)
            obj.App = app;
        end

        %-----------------------------------------------------------------%
        function runLoop(obj)
            % Antes de iniciar o loop de monitoração propriamente dito, é
            % dada a cada tarefa a chance de mudar de estado (ex.: "Na fila"
            % → "Em andamento", "Erro" → "Em andamento" numa nova tentativa).
            % Se nenhuma tarefa mudar de estado, não há o que monitorar e o
            % método retorna sem efeito.

            hasTaskToRun = false;
            for taskIdx = 1:numel(obj.Tasks)
                if updateTaskStatus(obj, taskIdx, 'routineCheck')
                    hasTaskToRun = true;
                    break
                end
            end

            if ~hasTaskToRun
                return
            end

            stop(obj.App.TaskSchedulerTimer)

            obj.IsRunning = true;
            isEditing = true;
            forceConfiguration = false;

            while obj.IsRunning
                numActiveTasks = sum(strcmp({obj.Tasks.Status}, 'Em andamento'));

                if isEditing
                    obj.RevisitInfo = fcn.RevisitFactors(obj.Tasks);
                    notify(obj, 'RevisitInfoChanged')

                    forceConfiguration = (numActiveTasks == 1);

                    if isempty(obj.RevisitInfo.GlobalRevisitTime)
                        obj.IsRunning = false;
                        break
                    end

                    sweepCount = 0;
                    isEditing  = false;
                end

                sweepStartTic = tic;
                for taskIdx = 1:numel(obj.Tasks)
                    if updateTaskStatus(obj, taskIdx, 'routineCheck')
                        isEditing = true;
                        break
                    end

                    switch obj.Tasks(taskIdx).Status
                        case 'Cancelamento solicitado'
                            isEditing = true;
                            obj.Tasks(taskIdx).Status = 'Cancelada';
                            notify(obj, 'StatusChanged', model.TaskEventData(taskIdx))
                            break

                        case {'Na fila', 'Concluída', 'Cancelada', 'Erro'}
                            continue
                    end

                    isRegularTask = ~contains(obj.Tasks(taskIdx).TaskSpec.Type, 'PRÉVIA');

                    receiverHandle   = obj.Tasks(taskIdx).Connections.receiver;
                    udpPortHandle  = obj.Tasks(taskIdx).Connections.stream;
                    gpsHandle        = obj.Tasks(taskIdx).Connections.gps;

                    configMode  = true;

                    numBands = numel(obj.Tasks(taskIdx).Bands);
                    for bandIdx = 0:numBands
                        revisitFactor = obj.RevisitInfo.Band(taskIdx).RevisitFactors(bandIdx+1);
                        if mod(sweepCount, revisitFactor) || revisitFactor == -1
                            continue
                        end
                        sampleTimestamp = datetime('now');

                        if bandIdx == 0
                            % A atualização das coordenadas geográficas do
                            % ponto de monitoração não precisa ser feita para
                            % a tarefa "Drive-test (Level+Azimuth)" porque essa
                            % tarefa já possui, no seu datagrama, a informação
                            % das coordenadas.

                            if obj.Tasks(taskIdx).TaskSpec.Receiver.Config.connectFlag ~= 3
                                acquireGpsData(obj, taskIdx, receiverHandle, gpsHandle, sampleTimestamp);
                            end

                        else
                            obj.Tasks(taskIdx) = class.RFlookBinLib.CheckFile(obj.Tasks(taskIdx), bandIdx, obj.App.General.fileFolder.userPath);

                            try
                                % ANTENNA SWITCH (IF APPLICABLE)
                                switchAntenna(obj, taskIdx, bandIdx)

                                % RECEIVER RECONFIGURATION (IF APPLICABLE)
                                if numActiveTasks > 1 || numBands > 1 || forceConfiguration
                                    if configMode
                                        if ismember(obj.Tasks(taskIdx).TaskSpec.Receiver.Config.connectFlag, [2, 3])
                                            class.EB500Lib.OperationMode(receiverHandle, obj.Tasks(taskIdx).TaskSpec.Receiver.Config.connectFlag)
                                        end
                                        configMode = false;
                                    end

                                    configureBand(obj, taskIdx, bandIdx, receiverHandle)
                                    forceConfiguration = false;
                                end

                                attenuationFactor = -1;
                                if ~isempty(obj.Tasks(taskIdx).ReceiverCommands.query)
                                % Bloco try/catch protege eventual erro, o que não causará dano à
                                % monitoração em si por se tratar de informação não essencial.
                                    try
                                        attenuationFactor = str2double(fcn.WriteRead(receiverHandle, obj.Tasks(taskIdx).ReceiverCommands.query));
                                    catch
                                    end
                                end

                                % maskTriggered: registra se foi evidenciado rompimento da máscara espectral.
                                maskTriggered = 0;

                                if isempty(obj.Tasks(taskIdx).Bands(bandIdx).Mask)
                                    % SINGLE TRACE
                                    traceData = acquireSpectrumTrace(obj, taskIdx, bandIdx, receiverHandle, udpPortHandle, sampleTimestamp);
                                    obj.Tasks(taskIdx).Bands(bandIdx).nSweeps = obj.Tasks(taskIdx).Bands(bandIdx).nSweeps+1;

                                else
                                    % BURST OF TRACES
                                    burstSweeps = obj.Tasks(taskIdx).Bands(bandIdx).Mask.FindPeaks.nSweeps;
                                    traceData   = zeros(burstSweeps, obj.Tasks(taskIdx).Bands(bandIdx).DataPoints, 'single');

                                    for sweepIdx = 1:burstSweeps
                                        traceData(sweepIdx,:) = acquireSpectrumTrace(obj, taskIdx, bandIdx, receiverHandle, udpPortHandle, sampleTimestamp);
                                        obj.Tasks(taskIdx).Bands(bandIdx).nSweeps = obj.Tasks(taskIdx).Bands(bandIdx).nSweeps+1;
                                    end

                                    averagedTrace = mean(traceData, 1);

                                    % METADATA UPDATE
                                    obj.Tasks(taskIdx).Bands(bandIdx).Mask.Validations = obj.Tasks(taskIdx).Bands(bandIdx).Mask.Validations + 1;

                                    % MASK BROKEN ANALISYS
                                    maskExceedance = (averagedTrace - obj.Tasks(taskIdx).Bands(bandIdx).Mask.Array) > 0;
                                    if any(maskExceedance)
                                        obj.Tasks(taskIdx).Bands(bandIdx).Mask.BrokenArray = obj.Tasks(taskIdx).Bands(bandIdx).Mask.BrokenArray + maskExceedance;

                                        peaksTable = fcn.FindPeaks(obj.Tasks(taskIdx), bandIdx, averagedTrace, maskExceedance);
                                        if ~isempty(peaksTable)
                                            obj.Tasks(taskIdx).Bands(bandIdx).Mask.BrokenCount = obj.Tasks(taskIdx).Bands(bandIdx).Mask.BrokenCount + 1;
                                            obj.Tasks(taskIdx).Bands(bandIdx).Mask.Peaks       = peaksTable;
                                            obj.Tasks(taskIdx).Bands(bandIdx).Mask.TimeStamp   = sampleTimestamp;

                                            if isRegularTask
                                                writematrix(jsonencode(rmfield(obj.Tasks(taskIdx).Bands(bandIdx).Mask, {'Table', 'Array', 'Validations', 'BrokenArray', 'FindPeaks'})), ...
                                                    replace(obj.Tasks(taskIdx).Bands(bandIdx).File.CurrentFile.FullPath, {'~', '.bin'}, {'', '.txt'}), 'QuoteStrings', 'none', 'WriteMode', 'append', 'Encoding', 'UTF-8')
                                            end

                                            maskTriggered = 1;
                                        end
                                    end

                                    traceData = traceData(end,:);
                                end

                                obj.Tasks(taskIdx).RetryPolicy.receiver = struct('failureCount', 0, 'firstFailureAt', NaT, 'lastFailureAt', NaT);

                                % WATERFALL MATRIX
                                waterfallIdx = mod(obj.Tasks(taskIdx).Bands(bandIdx).Waterfall.idx, obj.Tasks(taskIdx).Bands(bandIdx).Waterfall.Depth) + 1;

                                obj.Tasks(taskIdx).Bands(bandIdx).Waterfall.idx = waterfallIdx;
                                obj.Tasks(taskIdx).Bands(bandIdx).Waterfall.Matrix(waterfallIdx,:) = traceData(:,:,1);

                                [~, ~, numDims] = size(traceData);
                                if numDims > 1
                                    obj.Tasks(taskIdx).Bands(bandIdx).Azimuth = traceData(:,:,2);
                                end

                                % ESTIMATED REVISIT TIME
                                if isempty(obj.Tasks(taskIdx).Bands(bandIdx).LastTimeStamp)
                                    obj.Tasks(taskIdx).Bands(bandIdx).RevisitTime = obj.RevisitInfo.GlobalRevisitTime * revisitFactor;
                                else
                                    obj.Tasks(taskIdx).Bands(bandIdx).RevisitTime = ((obj.App.General.Integration.SampleTime-1)*obj.Tasks(taskIdx).Bands(bandIdx).RevisitTime + seconds(sampleTimestamp-obj.Tasks(taskIdx).Bands(bandIdx).LastTimeStamp))/obj.App.General.Integration.SampleTime;
                                end
                                obj.Tasks(taskIdx).Bands(bandIdx).LastTimeStamp = sampleTimestamp;

                                % FILE
                                if isRegularTask && (isempty(obj.Tasks(taskIdx).Bands(bandIdx).Mask) || ismember(obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).MaskTrigger.Status, [0, 3]) || ((obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).MaskTrigger.Status == 2) && maskTriggered))
                                    class.RFlookBinLib.EditFile(obj.Tasks(taskIdx), bandIdx, traceData, attenuationFactor, sampleTimestamp)
                                    obj.Tasks(taskIdx).Bands(bandIdx).File.WritedSamples = obj.Tasks(taskIdx).Bands(bandIdx).File.WritedSamples + 1;
                                end

                                % PLOT, WRITEDSAMPLES & MASKINFO (IF APPLICABLE)
                                notify(obj, 'BandDataAcquired', model.TaskEventData(taskIdx, bandIdx, maskTriggered))

                            catch ME
                                % O controle de erro do GPS se dá na função "acquireGpsData".
                                %
                                % O controle de erro do RECEPTOR se dá aqui, neste trecho do
                                % método "runLoop".
                                %
                                % O app tentará reativar a conexão toda vez que o contador de
                                % erro atingir um múltiplo de "class.Constants.errorCountTrigger".
                                % E, além disso, caso ultrapassado o tempo (em segundos) definido
                                % em "class.Constants.errorTimeTrigger", o app trocará o estado da
                                % tarefa de "Em andamento" → "Erro".

                                if ME.message == "If you specify a message identifier argument, you must specify the message text argument."
                                    pause(1)
                                end

                                obj.Tasks(taskIdx).LogEntries(end+1) = struct('level', 'error (RECEIVER)', 'timestamp', char(sampleTimestamp), 'message', ME.message);
                                recordFailure(obj, 'receiver', taskIdx, sampleTimestamp)

                                notify(obj, 'ErrorRaised', model.TaskEventData(taskIdx, [], 'Receiver'))

                                msgError = reconnectAttempt(obj.App.receiverObj, ...
                                    obj.Tasks(taskIdx).Connections.receiver.UserData.instrSelected, ...
                                    obj.Tasks(taskIdx).TaskSpec.Receiver.Config.connectFlag, ...
                                    obj.Tasks(taskIdx).TaskSpec.Receiver.Config.StartUp{1},  ...
                                    obj.Tasks(taskIdx).Bands(bandIdx).SpecificSCPI ...
                                );

                                if ~isempty(msgError)
                                    updateTaskStatus(obj, taskIdx, 'error');
                                    break
                                end
                            end
                        end
                    end
                end

                sweepCount = sweepCount+1;
                pause(max(obj.RevisitInfo.GlobalRevisitTime-toc(sweepStartTic), .001))
            end

            start(obj.App.TaskSchedulerTimer)

            obj.RevisitInfo = [];
            notify(obj, 'RevisitInfoChanged')
        end
    end


    methods (Access = {?winAppColeta, ?winAppColeta_exported})
        %-----------------------------------------------------------------%
        function hasChanged = updateTaskStatus(obj, taskIdx, evtName)
            arguments
                obj
                taskIdx
                evtName {mustBeMember(evtName, {'routineCheck', 'error', 'cancellationRequested'})}
            end

            % Função responsável por trocar o estado das tarefas, de "Na
            % fila" para "Em andamento", "Em andamento" para "Erro" etc.
            %
            % Lembrando que o estado de uma nova tarefa é "Na fila", exceto
            % quando ocorre algum erro no processo de criação (decorrente
            % de uma configuração de um parâmetro não aceito pelo receptor,
            % por exemplo). Nesse caso, o estado será "Erro".
            %
            % Caso não exista alguma tarefa em execução, o obj.IsRunning
            % será igual a "false", e o timer do app estará ativo, o que o
            % fará avaliar a cada minuto o estado de todas as tarefas, nesta
            % função, de forma que:
            % (a) Seja iniciada uma tarefa no estado "Na fila";
            % (b) Seja realizada uma nova tentativa de iniciar uma tarefa
            %     no estado "Erro" (o que ocorrerá a cada 15 minutos).

            timestamp = datetime('now');

            hasChanged    = false;
            initialStatus = obj.Tasks(taskIdx).Status;

            switch obj.Tasks(taskIdx).Status
                case 'Em andamento'
                    % Verifica se a tarefa deve ser finalizada, seja 
                    % por ter atingido o tempo de término ou por ter 
                    % recebido um evento de erro ou cancelamento.
                    if obj.Tasks(taskIdx).Timing.endedAt < timestamp || ismember(evtName, {'error', 'cancellationRequested'})
                        hasChanged = true;

                        if obj.Tasks(taskIdx).Timing.endedAt < timestamp
                            obj.Tasks(taskIdx).Status = 'Concluída';
                        else
                            switch evtName
                                case 'error'
                                    obj.Tasks(taskIdx).Status = 'Erro';
                                case 'cancellationRequested'
                                    obj.Tasks(taskIdx).Status = 'Cancelamento solicitado';
                            end
                        end

                        obj.Tasks(taskIdx).LogEntries(end+1) = struct( ...
                            'level', 'task', ...
                            'timestamp', char(timestamp), ...
                            'message', sprintf('Alterado o estado da tarefa: Em andamento → %s.', obj.Tasks(taskIdx).Status) ...
                        );

                        for bandIdx = 1:numel(obj.Tasks(taskIdx).Bands)
                            obj.Tasks(taskIdx) = class.RFlookBinLib.CloseFile(obj.Tasks(taskIdx), bandIdx);
                            obj.Tasks(taskIdx).Bands(bandIdx).Status = false;
                        end

                    else
                        if strcmp(obj.Tasks(taskIdx).TaskSpec.Script.Observation.Type, 'Samples')
                            bandCompletionFlags = [];
                            for bandIdx = 1:numel(obj.Tasks(taskIdx).Bands)
                                if obj.Tasks(taskIdx).Bands(bandIdx).Status
                                    if obj.Tasks(taskIdx).Bands(bandIdx).nSweeps == obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrObservationSamples
                                        obj.Tasks(taskIdx) = class.RFlookBinLib.CloseFile(obj.Tasks(taskIdx), bandIdx);
                                        obj.Tasks(taskIdx).Bands(bandIdx).Status = false;
                                        bandCompletionFlags(end+1) = true;

                                    else
                                        bandCompletionFlags(end+1) = false;
                                    end
                                end
                            end

                            if all(bandCompletionFlags)
                                hasChanged = true;

                                obj.Tasks(taskIdx).Status = 'Concluída';
                                obj.Tasks(taskIdx).Timing.endedAt = timestamp;
                                obj.Tasks(taskIdx).LogEntries(end+1) = struct( ...
                                    'level', 'task', ...
                                    'timestamp', char(timestamp), ...
                                    'message', sprintf('Alterado o estado da tarefa: Em andamento → %s.', obj.Tasks(taskIdx).Status) ...
                                );

                            elseif any(bandCompletionFlags)
                                hasChanged = true;
                            end
                        end
                    end

                case {'Na fila', 'Erro'}
                    if strcmp(obj.Tasks(taskIdx).Status, 'Erro')
                        if isnat(obj.Tasks(taskIdx).Timing.startupAt)
                            obj.Tasks(taskIdx).Timing.startupAt = timestamp;
                        end

                        startupTimestamp = obj.Tasks(taskIdx).Timing.startupAt;
                        if isequal(dateshift(timestamp, 'start', 'minute'), dateshift(startupTimestamp, 'start', 'minute'))
                            return
                        end
                    end

                    if obj.Tasks(taskIdx).Timing.startedAt < timestamp
                        switch obj.Tasks(taskIdx).TaskSpec.Script.Observation.Type
                            case {'Duration', 'Time'}
                                if isnat(obj.Tasks(taskIdx).Timing.endedAt) || (obj.Tasks(taskIdx).Timing.endedAt > timestamp)
                                    hasChanged = true;
                                end

                            case 'Samples'
                                hasChanged = true;
                        end
                    end

                    if hasChanged
                        try
                            if strcmp(obj.App.TaskSchedulerTimer.Running, 'on')
                                stop(obj.App.TaskSchedulerTimer)
                            end
                            startTask(obj, taskIdx);

                            obj.Tasks(taskIdx).Status = 'Em andamento';
                            obj.Tasks(taskIdx).Connections.receiver.UserData.SyncMode = obj.Tasks(taskIdx).TaskSpec.Receiver.Sync;
                            obj.Tasks(taskIdx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(timestamp), 'message', 'Iniciada a execução da tarefa.');

                        catch ME
                            if strcmp(obj.App.TaskSchedulerTimer.Running, 'off') && ~obj.IsRunning
                                start(obj.App.TaskSchedulerTimer)
                            end
                            obj.Tasks(taskIdx).Status = 'Erro';
                            obj.Tasks(taskIdx).LogEntries(end+1) = struct('level', 'error', 'timestamp', char(timestamp), 'message', getReport(ME));

                            hasChanged = false;
                        end
                    end
            end

            if hasChanged
                notify(obj, 'StatusChanged', model.TaskEventData(taskIdx))
            end

            if ~strcmp(initialStatus, obj.Tasks(taskIdx).Status)
                notify(obj, 'TasksChanged')
            end
        end

        %-----------------------------------------------------------------%
        function resetTaskBands(obj, idx, resetSweepCount)
            for bandIdx = 1:numel(obj.Tasks(idx).Bands)
                obj.Tasks(idx).Bands(bandIdx).SyncModeRef = '';
                obj.Tasks(idx).Bands(bandIdx).LastTimeStamp = [];
                obj.Tasks(idx).Bands(bandIdx).Status = true;

                if resetSweepCount
                    obj.Tasks(idx).Bands(bandIdx).nSweeps = 0;
                end
            end
        end

        %-----------------------------------------------------------------%
        function task = resolveStreamingHandle(obj, task)
            % Usada tanto no início de uma tarefa quanto na reconexão de
            % tarefas persistidas.

            receiverName = task.TaskSpec.Receiver.Selection.Name{1};
            taskType = task.TaskSpec.Type;

            receiverIdx = findReceiverIndex(obj, receiverName, taskType);
            if ismember(obj.App.receiverObj.Config.connectFlag(receiverIdx), [2, 3])
                [obj.UDPPortArray, udpPortIdx] = fcn.udpSockets(obj.UDPPortArray, obj.App.EB500Obj.udpPort);
                if ~isempty(udpPortIdx)
                    task.TaskSpec.Streaming.Handle = obj.UDPPortArray{udpPortIdx};
                    task.Connections.stream = task.TaskSpec.Streaming.Handle;
                end
            end
        end

        %-----------------------------------------------------------------%
        function [task, msgError] = resolveGpsHandle(obj, task)
            % Usada tanto no início de uma tarefa quanto na reconexão de
            % tarefas persistidas.

            msgError = '';

            if ~isempty(task.TaskSpec.GPS.Selection)
                instrSelected = struct( ...
                    'Type', task.TaskSpec.GPS.Selection.Type{1}, ...
                    'Parameters', jsondecode(task.TaskSpec.GPS.Selection.Parameters{1}) ...
                );

                [gpsIdx, msgError] = connect(obj.App.gpsObj, instrSelected);
                if isempty(msgError)
                    task.TaskSpec.GPS.Handle = obj.App.gpsObj.Table.Handle{gpsIdx};
                    task.GPS                 = task.TaskSpec.GPS.Handle;
                end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function startTask(obj, idx)
            taskSpec = obj.Tasks(idx).TaskSpec;

            % RECEIVER
            msgError = reconnectAttempt(obj.App.receiverObj, ...
                getReceiver(obj.Tasks(idx)), ...
                obj.Tasks(idx).TaskSpec.Receiver.Config.connectFlag, ...
                obj.Tasks(idx).TaskSpec.Receiver.Config.StartUp{1}, ...
                obj.Tasks(idx).Bands(1).SpecificSCPI ...
            );

            if ~isempty(msgError)
                error(msgError)
            end
            
            receiverHandle = obj.Tasks(idx).Connections.receiver;

            % STREAMING
            if isempty(obj.Tasks(idx).Connections.stream)
                if ismember(taskSpec.Receiver.Config.connectFlag, [2, 3])
                    obj.Tasks(idx) = resolveStreamingHandle(obj, obj.Tasks(idx));
                end
            else
                if contains(obj.Tasks(idx).ReceiverId, 'EB500')                 && ...
                        ~contains(taskSpec.Type, 'Drive-test (Level+Azimuth)') &&...
                        isempty(obj.Tasks(idx).Bands(1).Datagrams)

                    udpPortHandle = obj.Tasks(idx).Connections.stream;
                    obj.Tasks(idx) = class.EB500Lib.DatagramRead_PSCAN_PreTask(obj.App.EB500Obj, obj.Tasks(idx), receiverHandle, udpPortHandle);
                end
            end

            % GPS
            if isempty(obj.Tasks(idx).Connections.gps)
                if ~isempty(taskSpec.GPS.Selection)
                    [obj.Tasks(idx), msgError] = resolveGpsHandle(obj, obj.Tasks(idx));
                    if ~isempty(msgError)
                        error(msgError)
                    end
                end
            end

            % ANTENNA TRACKING (EMSat)
            if strcmp(taskSpec.Antenna.Switch.Name, 'EMSat')
                fcn.antennaTracking(obj.App, 'mainApp', taskSpec.Antenna.MetaData, obj.App.progressDialog);
            end

            % MASK, FILE & WATERFALL MATRIX
            baseName = sprintf('appColeta_%s', datestr(now, 'yymmdd_THHMMSS'));
            for bandIdx = 1:numel(obj.Tasks(idx).Bands)
                bandId = taskSpec.Script.Band(bandIdx).ID;

                % ANTENNA SWITCH & ACU
                % Esse trecho do código consiste na tentativa de obter a posição
                % da antena, inserindo-a no arquivo binário e apresentando no
                % painel de metadados.
                %
                % Erros retornáveis:
                % - Caso não tenha sido desabilitado o Polling/Bus da ACU
                % no Compass.
                % - Caso a ACU não esteja acessível ('MCL-3' e 'MCC-1' ainda
                % não possuem); e 'MKA-1' ainda não é controlável por falta
                % de conectividade de rede (o app não "enxerga" a ACU).
                %
                % Os erros não travam a execução do código pois a antena
                % pode ter sido apontada manualmente ou automaticamente - este
                % último poderia ter sido conduzido no momento de criação da
                % tarefa (e posteriormente reabilitado o controle da ACU pelo
                % Compass.
                if strcmp(taskSpec.Antenna.Switch.Name, 'EMSat')
                    antennaName = extractBefore(taskSpec.Script.Band(bandIdx).instrAntenna, ' ');
                    [antennaPos, errorMsg] = obj.App.EMSatObj.AntennaPositionGET(antennaName);
                    obj.Tasks(idx).Bands(bandIdx).Antenna.Position = jsonencode(antennaPos);

                    if ~isempty(errorMsg)
                        obj.Tasks(idx).LogEntries(end+1) = struct('level', 'startup', 'timestamp', datestr(now), 'message', sprintf('ID: %.0f\n%s ACU - %s', bandId, antennaName, errorMsg));
                    end
                end

                % MASK
                obj.Tasks(idx).Bands(bandIdx).Mask = [];
                if contains(taskSpec.Type, 'Rompimento de Máscara Espectral') && taskSpec.Script.Band(bandIdx).MaskTrigger.Status
                    maskInfo  = class.maskLib.FileRead(taskSpec.MaskFile);
                    maskArray = class.maskLib.ArrayConstructor(maskInfo, taskSpec.Script.Band(bandIdx));

                    findPeaksConfig = taskSpec.Script.Band(bandIdx).MaskTrigger.FindPeaks;
                    if isempty(findPeaksConfig)
                        findPeaksConfig = class.Constants.FindPeaks;
                    end

                    obj.Tasks(idx).Bands(bandIdx).Mask = struct('Table', maskInfo.Table, 'Array', maskArray, 'Validations', 0, ...
                                                            'BrokenArray', zeros(1, taskSpec.Script.Band(bandIdx).instrDataPoints), ...
                                                            'BrokenCount', 0, 'Peaks', '', 'TimeStamp', NaT, 'FindPeaks', findPeaksConfig);
                    obj.Tasks(idx).LogEntries(end+1)    = struct('level', 'mask', 'timestamp', datestr(now), 'message', sprintf('ID %.0f\n%s', bandId, jsonencode(maskInfo.Table)));
                end

                % FILE
                obj.Tasks(idx).Bands(bandIdx).File = struct( ...
                    'Fileversion', class.Constants.fileVersion,     ...
                    'Basename', sprintf('%s_ID%.0f', baseName, bandId), ...
                    'Filecount', 0, ...
                    'WritedSamples', 0, ...
                    'CurrentFile', [] ...
                );

                [obj.Tasks(idx).Bands(bandIdx).File.Filecount, ...
                 obj.Tasks(idx).Bands(bandIdx).File.CurrentFile] = class.RFlookBinLib.OpenFile(obj.Tasks(idx), bandIdx, obj.App.General.fileFolder.userPath);

                logMsg = sprintf('ID: %.0f\nscpiSet_Config: "%s"\nscpiSet_Att: "%s"\nrawMetaData: "%s"\nFilename (base): %s', ...
                    bandId, ...
                    obj.Tasks(idx).Bands(bandIdx).SpecificSCPI.configSET, ...
                    obj.Tasks(idx).Bands(bandIdx).SpecificSCPI.attSET, ...
                    obj.Tasks(idx).Bands(bandIdx).rawMetaData, ...
                    obj.Tasks(idx).Bands(bandIdx).File.Basename ...
                );
                obj.Tasks(idx).LogEntries(end+1) = struct('level', 'startup', 'timestamp', datestr(now), 'message', logMsg);

                % WATERFALL MATRIX
                dataPoints     = taskSpec.Script.Band(bandIdx).instrDataPoints;
                waterfallDepth = obj.App.General.Plot.Waterfall.Depth;
                if strcmp(taskSpec.Script.Observation.Type, 'Samples')
                    waterfallDepth = min([waterfallDepth, taskSpec.Script.Band(bandIdx).instrObservationSamples]);
                end

                obj.Tasks(idx).Bands(bandIdx).Waterfall = struct('idx', 0, 'Depth', waterfallDepth, 'Matrix', -1000 .* ones(waterfallDepth, dataPoints, 'single'));
            end

            resetTaskBands(obj, idx, 0)
        end

        %-----------------------------------------------------------------%
        function idx = findReceiverIndex(obj, receiverName, taskType)
            idx = find(strcmp(obj.App.receiverObj.Config.Name, receiverName));
            if numel(idx) > 1
                connectFlagList = obj.App.receiverObj.Config.connectFlag(idx);
                if contains(taskType, 'Drive-test (Level+Azimuth)')
                    idx = idx(connectFlagList == 3);
                else
                    idx = idx(connectFlagList ~= 3);
                end
                idx = idx(1);
            end
        end

        %-----------------------------------------------------------------%
        function acquireGpsData(obj, taskIdx, receiverHandle, gpsHandle, timestamp)
            % O controle de erro do RECEPTOR se dá no método "runLoop".
            %
            % O controle de erro do GPS, por outro lado, se dá diretamente aqui,
            % nesta função, e é restrito ao caso em que o receptor é "External",
            % ou seja, não se trata de GPS embarcado no RECEPTOR, mas GPS 
            % conectado à porta USB do computador, por exemplo.
            %
            % Caso a tarefa seja do tipo "Drive-test", toda vez que for manifestada
            % uma desconexão, o app tentará reativar a conexao. Ou, em sendo uma tarefa
            % de outro tipo, o app tentará reativar a conexão toda vez que o contador de
            % erro atingir um múltiplo de "class.Constants.errorGPSCountTrigger".

            gps = model.GPS.DEFAULT;

            try
                switch obj.Tasks(taskIdx).TaskSpec.Script.GPS.Type
                    case 'Built-in'
                        receiverId = obj.Tasks(taskIdx).ReceiverId;
                        gps = model.GPS.fetchGPSCoordinates('Built-in', receiverHandle, receiverId);

                    case 'External'
                        gps = model.GPS.fetchGPSCoordinates('External', gpsHandle);
                        obj.Tasks(taskIdx).RetryPolicy.gps = struct('failureCount', 0, 'firstFailureAt', NaT, 'lastFailureAt', NaT);
                end

            catch ME
                obj.Tasks(taskIdx).LogEntries(end+1) = struct('level', 'error (GPS)', 'timestamp', char(timestamp), 'message', ME.message);

                if strcmp(obj.Tasks(taskIdx).TaskSpec.Script.GPS.Type, 'External')
                    recordFailure(obj, 'gps', taskIdx, timestamp)
                    notify(obj, 'ErrorRaised', model.TaskEventData(taskIdx, [], 'GPS'))

                    if contains(obj.Tasks(taskIdx).TaskSpec.Type, 'Drive-test') || ~mod(obj.Tasks(taskIdx).RetryPolicy.gps.failureCount, class.Constants.errorGPSCountTrigger)
                        reconnectAttempt(obj.App.gpsObj, gpsHandle.UserData.instrSelected);
                    end
                end
            end

            applyGpsFix(obj, taskIdx, gps, timestamp)
        end

        %-----------------------------------------------------------------%
        function applyGpsFix(obj, taskIdx, gps, timestamp)
            if isempty(gps.TimeStamp)
                gps.TimeStamp = char(timestamp);
            end
            obj.Tasks(taskIdx).GPSLastFix = gps;

            notify(obj, 'GpsUpdated', model.TaskEventData(taskIdx, [], gps))
        end

        %-----------------------------------------------------------------%
        function switchAntenna(obj, taskIdx, bandIdx)
            switchName = obj.Tasks(taskIdx).TaskSpec.Antenna.Switch.Name;
            if ~ismember(switchName, {'EMSat', 'ERMx'})
                return
            end

            switch switchName
                case 'EMSat'
                    msgError = obj.App.EMSatObj.MatrixSwitch( ...
                        obj.Tasks(taskIdx).Bands(bandIdx).Antenna.SwitchPort, ...
                        obj.Tasks(taskIdx).TaskSpec.Antenna.Switch.OutputPort, ...
                        obj.Tasks(taskIdx).Bands(bandIdx).Antenna.LNBChannel, ...
                        obj.Tasks(taskIdx).Bands(bandIdx).Antenna.LNBIndex ...
                    );

                otherwise % 'ERMx'
                    msgError = obj.App.ERMxObj.MatrixSwitch( ...
                        obj.Tasks(taskIdx).Bands(bandIdx).Antenna.SwitchPort, ...
                        obj.Tasks(taskIdx).TaskSpec.Antenna.Switch.OutputPort ...
                    );
            end

            if ~isempty(msgError)
                error(msgError)
            end
        end

        %-----------------------------------------------------------------%
        function configureBand(obj, taskIdx, bandIdx, receiverHandle)
            writeline(receiverHandle, obj.Tasks(taskIdx).Bands(bandIdx).SpecificSCPI.configSET);
            pause(.001)

            if ~isempty(obj.Tasks(taskIdx).Bands(bandIdx).SpecificSCPI.attSET)
                writeline(receiverHandle, obj.Tasks(taskIdx).Bands(bandIdx).SpecificSCPI.attSET);
            end
        end

        %-----------------------------------------------------------------%
        function traceData = acquireSpectrumTrace(obj, taskIdx, bandIdx, receiverHandle, udpPortHandle, timestamp)
            timeout  = class.Constants.Timeout;
            acquired = false;

            switch obj.Tasks(taskIdx).TaskSpec.Receiver.Config.connectFlag
                case 1 % Analisadores de espectro (R&S, KeySight, Tektronix, Anritsu)
                    acquisitionTic = tic;
                    elapsed = 0;

                    while elapsed < timeout
                        elapsed = toc(acquisitionTic);

                        try
                            writeline(receiverHandle, obj.Tasks(taskIdx).ReceiverCommands.data);
                            traceData = readbinblock(receiverHandle, 'single');

                            if numel(traceData) == obj.Tasks(taskIdx).Bands(bandIdx).DataPoints
                                if strcmp(obj.Tasks(taskIdx).TaskSpec.Receiver.Sync, 'Continuous Sweep')
                                    % Normaliza o traço de dados para calcular o hash de sincronização
                                    syncHash = Hash.sha1(traceData - min(traceData));

                                    if ~strcmp(obj.Tasks(taskIdx).Bands(bandIdx).SyncModeRef, syncHash)
                                        obj.Tasks(taskIdx).Bands(bandIdx).SyncModeRef = syncHash;
                                    else
                                        continue
                                    end
                                end

                                acquired = true;
                                break
                            end

                        catch
                        end
                    end

                case 2 % R&S EB500: Tarefas ordinárias

                    taskInfo = struct( ...
                        'Type',       obj.Tasks(taskIdx).TaskSpec.Type, ...
                        'FreqStart',  obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStart, ...
                        'FreqStop',   obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStop, ...
                        'DataPoints', obj.Tasks(taskIdx).Bands(bandIdx).DataPoints, ...
                        'nDatagrams', obj.Tasks(taskIdx).Bands(bandIdx).Datagrams, ...
                        'udpPort',    obj.App.EB500Obj.udpPort ...
                    );

                    [traceData, acquired] = class.EB500Lib.DatagramRead_PSCAN(taskInfo, receiverHandle, udpPortHandle);

                case 3 % R&S EB500 - Tarefa "Drive-test (Level+Azimuth)"
                    taskInfo = struct( ...
                        'Type',       obj.Tasks(taskIdx).TaskSpec.Type, ...
                        'FreqCenter', (obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStart + obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStop)/2, ...
                        'FreqSpan',   obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStop - obj.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStart, ...
                        'DataPoints', obj.Tasks(taskIdx).Bands(bandIdx).DataPoints, ...
                        'udpPort',    obj.App.EB500Obj.udpPort ...
                    );

                    % O traceData gerado aqui, e apenas aqui, possui informações
                    % de nível, azimute e nota de qualidade do azimute. A dimensão
                    % dele é 1 (Height) x DataPoints (Width) x 3 (Depth).
                    [traceData, gps, acquired] = class.EB500Lib.DatagramRead_FFM(taskInfo, receiverHandle, udpPortHandle);

                    % No datagrama tem a informação de gps... então vamos aproveitar! :)
                    applyGpsFix(obj, taskIdx, gps, timestamp)
            end
            flush(receiverHandle)

            if acquired
                if obj.Tasks(taskIdx).Bands(bandIdx).FlipArray
                    traceData(:,:,1) = flip(traceData(:,:,1));
                end
            else
                error('Não foi lido corretamente o vetor de nível do receptor dentro do tempo limite (%.0f segundos).', timeout)
            end
        end

        %-----------------------------------------------------------------%
        function recordFailure(obj, errorType, taskIdx, timestamp)
            arguments
                obj
                errorType char {mustBeMember(errorType, {'receiver', 'gps'})}
                taskIdx (1, 1) double {mustBePositive}
                timestamp datetime
            end

            if isnat(obj.Tasks(taskIdx).RetryPolicy.(errorType).firstFailureAt)
                obj.Tasks(taskIdx).RetryPolicy.(errorType).firstFailureAt = timestamp;
            end

            obj.Tasks(taskIdx).RetryPolicy.(errorType).lastFailureAt = timestamp;
            obj.Tasks(taskIdx).RetryPolicy.(errorType).failureCount  = obj.Tasks(taskIdx).RetryPolicy.(errorType).failureCount + 1;
        end
    end

end