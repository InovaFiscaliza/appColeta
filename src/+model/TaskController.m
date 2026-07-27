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
    % quais o app principal se inscreve (ver "wireTaskController").
    %
    % O acesso a recursos que não são de interface (bibliotecas de
    % instrumento, configurações gerais, diálogo de progresso) é feito por
    % meio da referência ao app owner ("App"), seguindo o mesmo padrão já
    % adotado em "class.tcpServerLib(app)".
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
        Tasks        = model.Task.empty
        UDPPortArray = {}
    end


    properties (SetAccess = private)
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
            % Substitui "RegularTask_MainLoop(app)".

            obj.IsRunning = true;
            isEditing     = true;

            stop(obj.App.timerObj_task)

            while obj.IsRunning
                if isEditing
                    obj.RevisitInfo = fcn.RevisitFactors(obj.Tasks);
                    notify(obj, 'RevisitInfoChanged')

                    if isempty(obj.RevisitInfo.GlobalRevisitTime)
                        obj.IsRunning = false;
                        break
                    end

                    nn = 0;
                    isEditing = false;
                end

                sweepTic = tic;
                for ii = 1:numel(obj.Tasks)
                    if obj.statusTaskCheck(ii, '')
                        isEditing = true;
                        break
                    end

                    if ~strcmp(obj.Tasks(ii).Status, 'Em andamento')
                        continue
                    end

                    regularTask = ~contains(obj.Tasks(ii).TaskSpec.Type, 'PRÉVIA');

                    hReceiver   = obj.Tasks(ii).Connections.receiver;
                    hStreaming  = obj.Tasks(ii).Connections.stream;
                    hGPS        = obj.Tasks(ii).Connections.gps;

                    configMode  = true;

                    nBands = numel(obj.Tasks(ii).Bands);
                    for jj = 0:nBands
                        if mod(nn, obj.RevisitInfo.Band(ii).RevisitFactors(jj+1)) || obj.RevisitInfo.Band(ii).RevisitFactors(jj+1) == -1
                            continue
                        end
                        newTimeStamp = datetime('now');

                        if jj == 0
                            % A atualização das coordenadas geográficas do
                            % ponto de monitoração não precisa ser feita para
                            % a tarefa "Drive-test (Level+Azimuth)" porque essa
                            % tarefa já possui, no seu datagrama, a informação
                            % das coordenadas.

                            if obj.Tasks(ii).TaskSpec.Receiver.Config.connectFlag ~= 3
                                obj.gpsData(ii, hReceiver, hGPS, newTimeStamp);
                            end

                        else
                            obj.Tasks(ii) = class.RFlookBinLib.CheckFile(obj.Tasks(ii), jj, obj.App.General.fileFolder.userPath);

                            try
                                % ANTENNA SWITCH (IF APPLICABLE)
                                obj.antennaSwitch(ii, jj)

                                % RECEIVER RECONFIGURATION (IF APPLICABLE)
                                if (nBands > 1) || (hReceiver.UserData.nTasks > 1)
                                    if configMode
                                        if ismember(obj.Tasks(ii).TaskSpec.Receiver.Config.connectFlag, [2, 3])
                                            class.EB500Lib.OperationMode(hReceiver, obj.Tasks(ii).TaskSpec.Receiver.Config.connectFlag)
                                        end
                                        configMode = false;
                                    end

                                    obj.configBand(ii, jj, hReceiver)
                                end

                                attFactor = -1;
                                if ~isempty(obj.Tasks(ii).ReceiverCommands.query)
                                % Bloco try/catch protege eventual erro, o que não causará dano à
                                % monitoração em si por se tratar de informação não essencial.
                                    try
                                        attFactor = str2double(fcn.WriteRead(hReceiver, obj.Tasks(ii).ReceiverCommands.query));
                                    catch
                                    end
                                end

                                % maskTrigger: Variável local que registra se foi evidenciado rompimento da máscara espectral.
                                maskTrigger = 0;

                                if isempty(obj.Tasks(ii).Bands(jj).Mask)
                                    % SINGLE TRACE
                                    newArray = obj.specData(ii, jj, hReceiver, hStreaming, newTimeStamp);
                                    obj.Tasks(ii).Bands(jj).nSweeps = obj.Tasks(ii).Bands(jj).nSweeps+1;

                                else
                                    % BURST OF TRACES
                                    nSweeps  = obj.Tasks(ii).Bands(jj).Mask.FindPeaks.nSweeps;
                                    newArray = zeros(nSweeps, obj.Tasks(ii).Bands(jj).DataPoints, 'single');
                                    for kk = 1:nSweeps
                                        newArray(kk,:) = obj.specData(ii, jj, hReceiver, hStreaming, newTimeStamp);
                                        obj.Tasks(ii).Bands(jj).nSweeps = obj.Tasks(ii).Bands(jj).nSweeps+1;
                                    end
                                    smoothedArray = mean(newArray, 1);

                                    % METADATA UPDATE
                                    obj.Tasks(ii).Bands(jj).Mask.Validations = obj.Tasks(ii).Bands(jj).Mask.Validations + 1;

                                    % MASK BROKEN ANALISYS
                                    validationArray = (smoothedArray - obj.Tasks(ii).Bands(jj).Mask.Array) > 0;
                                    if any(validationArray)
                                        obj.Tasks(ii).Bands(jj).Mask.BrokenArray = obj.Tasks(ii).Bands(jj).Mask.BrokenArray + validationArray;

                                        peaksTable = fcn.FindPeaks(obj.Tasks(ii), jj, smoothedArray, validationArray);
                                        if ~isempty(peaksTable)
                                            obj.Tasks(ii).Bands(jj).Mask.BrokenCount = obj.Tasks(ii).Bands(jj).Mask.BrokenCount + 1;
                                            obj.Tasks(ii).Bands(jj).Mask.Peaks       = peaksTable;
                                            obj.Tasks(ii).Bands(jj).Mask.TimeStamp   = newTimeStamp;

                                            if regularTask
                                                writematrix(jsonencode(rmfield(obj.Tasks(ii).Bands(jj).Mask, {'Table', 'Array', 'Validations', 'BrokenArray', 'FindPeaks'})), ...
                                                    replace(obj.Tasks(ii).Bands(jj).File.CurrentFile.FullPath, {'~', '.bin'}, {'', '.txt'}), 'QuoteStrings', 'none', 'WriteMode', 'append', 'Encoding', 'UTF-8')
                                            end

                                            maskTrigger = 1;
                                        end
                                    end

                                    newArray = newArray(end,:);
                                end

                                obj.Tasks(ii).RetryPolicy.receiver = struct('failureCount', 0, 'firstFailureAt', NaT, 'lastFailureAt', NaT);

                                % WATERFALL MATRIX
                                idx = obj.Tasks(ii).Bands(jj).Waterfall.idx + 1;
                                if idx > obj.Tasks(ii).Bands(jj).Waterfall.Depth; idx = 1;
                                end

                                obj.Tasks(ii).Bands(jj).Waterfall.idx = idx;
                                obj.Tasks(ii).Bands(jj).Waterfall.Matrix(idx,:) = newArray(:,:,1);

                                [~, ~, nDim] = size(newArray);
                                if nDim > 1
                                    obj.Tasks(ii).Bands(jj).Azimuth = newArray(:,:,2);
                                end

                                % ESTIMATED REVISIT TIME
                                if isempty(obj.Tasks(ii).Bands(jj).LastTimeStamp)
                                    obj.Tasks(ii).Bands(jj).RevisitTime = obj.RevisitInfo.GlobalRevisitTime * obj.RevisitInfo.Band(ii).RevisitFactors(jj+1);
                                else
                                    obj.Tasks(ii).Bands(jj).RevisitTime = ((obj.App.General.Integration.SampleTime-1)*obj.Tasks(ii).Bands(jj).RevisitTime + seconds(newTimeStamp-obj.Tasks(ii).Bands(jj).LastTimeStamp))/obj.App.General.Integration.SampleTime;
                                end
                                obj.Tasks(ii).Bands(jj).LastTimeStamp = newTimeStamp;

                                % FILE
                                if regularTask && (isempty(obj.Tasks(ii).Bands(jj).Mask) || ismember(obj.Tasks(ii).TaskSpec.Script.Band(jj).MaskTrigger.Status, [0, 3]) || ((obj.Tasks(ii).TaskSpec.Script.Band(jj).MaskTrigger.Status == 2) && maskTrigger))
                                    class.RFlookBinLib.EditFile(obj.Tasks(ii), jj, newArray, attFactor, newTimeStamp)
                                    obj.Tasks(ii).Bands(jj).File.WritedSamples = obj.Tasks(ii).Bands(jj).File.WritedSamples + 1;
                                end

                                % PLOT, WRITEDSAMPLES & MASKINFO (IF APPLICABLE)
                                notify(obj, 'BandDataAcquired', model.TaskEventData(ii, jj, maskTrigger))

                            catch ME
                                % O controle de erro do GPS se dá na função "gpsData".
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

                                obj.Tasks(ii).LogEntries(end+1) = struct('level', 'error (RECEIVER)', 'timestamp', char(newTimeStamp), 'message', ME.message);
                                obj.errorHandle('Receiver', ii, newTimeStamp)

                                notify(obj, 'ErrorRaised', model.TaskEventData(ii, [], 'Receiver'))

                                msgError = obj.App.receiverObj.ReconnectAttempt(obj.Tasks(ii).Connections.receiver.UserData.instrSelected, ...
                                                                            obj.Tasks(ii).TaskSpec.Receiver.Config.connectFlag, ...
                                                                            obj.Tasks(ii).TaskSpec.Receiver.Config.StartUp{1},  ...
                                                                            obj.Tasks(ii).Bands(jj).SpecificSCPI);
                                if ~isempty(msgError)
                                    obj.statusTaskCheck(ii, 'ErrorTrigger');
                                    break
                                end
                            end
                        end
                    end
                end

                nn = nn+1;
                pause(max(obj.RevisitInfo.GlobalRevisitTime-toc(sweepTic), .001))
            end

            start(obj.App.timerObj_task)

            obj.RevisitInfo = [];
            notify(obj, 'RevisitInfoChanged')
        end

        %-----------------------------------------------------------------%
        function Flag = statusTaskCheck(obj, idx, evtName)
            % Substitui "RegularTask_StatusTaskCheck(app, idx, evtName)".
            %
            % Função responsável por trocar o estado das tarefas, de "Na
            % fila" para "Em andamento", "Em andamento" para "Cancelada",
            % "Em andamento" para "Erro" e por aí vai...
            %
            % Lembrando que o estado de uma nova tarefa é "Na fila", exceto
            % quando ocorre algum erro no processo de criação (decorrente
            % de uma configuração de um parâmetro não aceito pelo receptor,
            % por exemplo). Nesse caso, o estado será "Erro".
            %
            % Caso não exista alguma tarefa em execução, o obj.IsRunning
            % será igual a "false", e o timer da app estará ativo, o que o
            % fará avaliar a cada minuto o estado de todas as tarefas, nesta
            % função, de forma que:
            % (a) Seja iniciada uma tarefa no estado "Na fila";
            % (b) Seja realizada uma nova tentativa de iniciar uma tarefa
            %     no estado "Erro" (o que ocorrerá a cada 15 minutos).

            Timestamp = datetime('now');

            Flag = false;
            initialStatus = obj.Tasks(idx).Status;

            switch obj.Tasks(idx).Status
                case 'Em andamento'
                    if obj.Tasks(idx).Timing.endedAt < Timestamp || ismember(evtName, {'DeleteButtonPushed', 'ErrorTrigger'})
                        Flag = true;

                        if obj.Tasks(idx).Timing.endedAt < Timestamp
                            obj.Tasks(idx).Status = 'Concluída';
                        else
                            switch evtName
                                case 'DeleteButtonPushed'
                                    obj.Tasks(idx).Status = 'Cancelada';
                                case 'ErrorTrigger'
                                    obj.Tasks(idx).Status = 'Erro';
                            end
                        end

                        obj.Tasks(idx).Connections.receiver.UserData.nTasks = obj.Tasks(idx).Connections.receiver.UserData.nTasks-1;
                        obj.Tasks(idx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(Timestamp), 'message', sprintf('Alterado o estado da tarefa: Em andamento → %s.', obj.Tasks(idx).Status));

                        for ii = 1:numel(obj.Tasks(idx).Bands)
                            obj.Tasks(idx) = class.RFlookBinLib.CloseFile(obj.Tasks(idx), ii);
                            obj.Tasks(idx).Bands(ii).Status = false;
                        end

                    else
                        if strcmp(obj.Tasks(idx).TaskSpec.Script.Observation.Type, 'Samples')
                            tempFlag = [];
                            for ii = 1:numel(obj.Tasks(idx).Bands)
                                if obj.Tasks(idx).Bands(ii).Status
                                    if obj.Tasks(idx).Bands(ii).nSweeps == obj.Tasks(idx).TaskSpec.Script.Band(ii).instrObservationSamples
                                        obj.Tasks(idx) = class.RFlookBinLib.CloseFile(obj.Tasks(idx), ii);
                                        obj.Tasks(idx).Bands(ii).Status = false;
                                        tempFlag(end+1) = true;

                                    else
                                        tempFlag(end+1) = false;
                                    end
                                end
                            end

                            if all(tempFlag)
                                Flag = true;

                                obj.Tasks(idx).Status = 'Concluída';
                                obj.Tasks(idx).Connections.receiver.UserData.nTasks = obj.Tasks(idx).Connections.receiver.UserData.nTasks-1;
                                obj.Tasks(idx).Timing.endedAt = Timestamp;
                                obj.Tasks(idx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(Timestamp), 'message', sprintf('Alterado o estado da tarefa: Em andamento → %s.', obj.Tasks(idx).Status));

                            elseif any(tempFlag)
                                Flag = true;
                            end
                        end
                    end

                case {'Na fila', 'Erro'}
                    if strcmp(obj.Tasks(idx).Status, 'Erro')
                        if isnat(obj.Tasks(idx).Timing.startupAt)
                            obj.Tasks(idx).Timing.startupAt = Timestamp;
                        end

                        StartUp = obj.Tasks(idx).Timing.startupAt;
                        if isequal([year(Timestamp), month(Timestamp), day(Timestamp), hour(Timestamp), minute(Timestamp)], ...
                                [year(StartUp), month(StartUp), day(StartUp), hour(StartUp), minute(StartUp)])
                            return
                        end
                    end

                    if obj.Tasks(idx).Timing.startedAt < Timestamp
                        switch obj.Tasks(idx).TaskSpec.Script.Observation.Type
                            case {'Duration', 'Time'}
                                if isnat(obj.Tasks(idx).Timing.endedAt) || (obj.Tasks(idx).Timing.endedAt > Timestamp)
                                    Flag = true;
                                end

                            case 'Samples'
                                Flag = true;
                        end
                    end

                    if Flag
                        try
                            if strcmp(obj.App.timerObj_task.Running, 'on')
                                stop(obj.App.timerObj_task)
                            end
                            obj.startUp(idx);

                            obj.Tasks(idx).Status = 'Em andamento';
                            obj.Tasks(idx).Connections.receiver.UserData.nTasks   = obj.Tasks(idx).Connections.receiver.UserData.nTasks+1;
                            obj.Tasks(idx).Connections.receiver.UserData.SyncMode = obj.Tasks(idx).TaskSpec.Receiver.Sync;
                            obj.Tasks(idx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(Timestamp), 'message', 'Iniciada a execução da tarefa.');

                        catch ME
                            if strcmp(obj.App.timerObj_task.Running, 'off') && ~obj.IsRunning
                                start(obj.App.timerObj_task)
                            end
                            obj.Tasks(idx).Status = 'Erro';
                            obj.Tasks(idx).LogEntries(end+1) = struct('level', 'error', 'timestamp', char(Timestamp), 'message', getReport(ME));

                            Flag = false;
                        end
                    end
            end

            if Flag
                notify(obj, 'StatusChanged', model.TaskEventData(idx))
            end

            if ~strcmp(initialStatus, obj.Tasks(idx).Status)
                notify(obj, 'TasksChanged')
            end
        end

        %-----------------------------------------------------------------%
        function restartStatus(obj, idx, nSweepsFlag)
            % Substitui "RegularTask_RestartStatus(app, idx, nSweepsFlag)".

            for ii = 1:numel(obj.Tasks(idx).Bands)
                obj.Tasks(idx).Bands(ii).SyncModeRef   = -1;
                obj.Tasks(idx).Bands(ii).LastTimeStamp = [];
                obj.Tasks(idx).Bands(ii).Status        = true;

                if nSweepsFlag
                    obj.Tasks(idx).Bands(ii).nSweeps   = 0;
                end
            end
        end

        %-----------------------------------------------------------------%
        function startUp(obj, idx)
            % Substitui "RegularTask_StartUp(app, idx)".

            TaskSpec = obj.Tasks(idx).TaskSpec;

            % RECEIVER
            msgError = obj.App.receiverObj.ReconnectAttempt(Instrument(obj.Tasks(idx)),                     ...
                                                        obj.Tasks(idx).TaskSpec.Receiver.Config.connectFlag, ...
                                                        obj.Tasks(idx).TaskSpec.Receiver.Config.StartUp{1},  ...
                                                        obj.Tasks(idx).Bands(1).SpecificSCPI);
            if ~isempty(msgError)
                error(msgError)
            end
            hReceiver = obj.Tasks(idx).Connections.receiver;

            % STREAMING
            if isempty(obj.Tasks(idx).Connections.stream)
                if ismember(TaskSpec.Receiver.Config.connectFlag, [2, 3])
                    obj.Tasks(idx) = obj.resolveStreamingHandle(obj.Tasks(idx));
                end
            else
                if contains(obj.Tasks(idx).ReceiverId, 'EB500')                 && ...
                        ~contains(TaskSpec.Type, 'Drive-test (Level+Azimuth)') &&...
                        isempty(obj.Tasks(idx).Bands(1).Datagrams)

                    hStreaming = obj.Tasks(idx).Connections.stream;
                    obj.Tasks(idx) = class.EB500Lib.DatagramRead_PSCAN_PreTask(obj.App.EB500Obj, obj.Tasks(idx), hReceiver, hStreaming);
                end
            end

            % GPS
            if isempty(obj.Tasks(idx).Connections.gps)
                if ~isempty(TaskSpec.GPS.Selection)
                    [obj.Tasks(idx), msgError] = obj.resolveGpsHandle(obj.Tasks(idx));
                    if ~isempty(msgError)
                        error(msgError)
                    end
                end
            end

            % ANTENNA TRACKING (EMSat)
            if strcmp(TaskSpec.Antenna.Switch.Name, 'EMSat')
                fcn.antennaTracking(obj.App, 'mainApp', TaskSpec.Antenna.MetaData, obj.App.progressDialog);
            end

            % MASK, FILE & WATERFALL MATRIX
            baseName = sprintf('appColeta_%s', datestr(now, 'yymmdd_THHMMSS'));
            for ii = 1:numel(obj.Tasks(idx).Bands)
                ID = TaskSpec.Script.Band(ii).ID;

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
                if strcmp(TaskSpec.Antenna.Switch.Name, 'EMSat')
                    antennaName = extractBefore(TaskSpec.Script.Band(ii).instrAntenna, ' ');
                    [antennaPos, errorMsg] = obj.App.EMSatObj.AntennaPositionGET(antennaName);
                    obj.Tasks(idx).Bands(ii).Antenna.Position = jsonencode(antennaPos);

                    if ~isempty(errorMsg)
                        obj.Tasks(idx).LogEntries(end+1) = struct('level', 'startup', 'timestamp', datestr(now), 'message', sprintf('ID: %.0f\n%s ACU - %s', ID, antennaName, errorMsg));
                    end
                end

                % MASK
                obj.Tasks(idx).Bands(ii).Mask = [];
                if contains(TaskSpec.Type, 'Rompimento de Máscara Espectral') && TaskSpec.Script.Band(ii).MaskTrigger.Status
                    maskInfo  = class.maskLib.FileRead(TaskSpec.MaskFile);
                    maskArray = class.maskLib.ArrayConstructor(maskInfo, TaskSpec.Script.Band(ii));

                    FindPeaks = TaskSpec.Script.Band(ii).MaskTrigger.FindPeaks;
                    if isempty(FindPeaks)
                        FindPeaks = class.Constants.FindPeaks;
                    end

                    obj.Tasks(idx).Bands(ii).Mask = struct('Table', maskInfo.Table, 'Array', maskArray, 'Validations', 0, ...
                                                            'BrokenArray', zeros(1, TaskSpec.Script.Band(ii).instrDataPoints), ...
                                                            'BrokenCount', 0, 'Peaks', '', 'TimeStamp', NaT, 'FindPeaks', FindPeaks);
                    obj.Tasks(idx).LogEntries(end+1)    = struct('level', 'mask', 'timestamp', datestr(now), 'message', sprintf('ID %.0f\n%s', ID, jsonencode(maskInfo.Table)));
                end

                % FILE
                obj.Tasks(idx).Bands(ii).File = struct('Fileversion', class.Constants.fileVersion,     ...
                                                        'Basename', sprintf('%s_ID%.0f', baseName, ID), ...
                                                        'Filecount', 0, 'WritedSamples', 0, 'CurrentFile', []);

                [obj.Tasks(idx).Bands(ii).File.Filecount, ...
                    obj.Tasks(idx).Bands(ii).File.CurrentFile] = class.RFlookBinLib.OpenFile(obj.Tasks(idx), ii, obj.App.General.fileFolder.userPath);

                logMsg = sprintf(['ID: %.0f\n'             ...
                                  'scpiSet_Config: "%s"\n' ...
                                  'scpiSet_Att: "%s"\n'    ...
                                  'rawMetaData: "%s"\n'    ...
                                  'Filename (base): %s'], ID,                                                  ...
                                                          obj.Tasks(idx).Bands(ii).SpecificSCPI.configSET, ...
                                                          obj.Tasks(idx).Bands(ii).SpecificSCPI.attSET,    ...
                                                          obj.Tasks(idx).Bands(ii).rawMetaData,            ...
                                                          obj.Tasks(idx).Bands(ii).File.Basename);
                obj.Tasks(idx).LogEntries(end+1) = struct('level', 'startup', 'timestamp', datestr(now), 'message', logMsg);


                % WATERFALL MATRIX
                DataPoints     = TaskSpec.Script.Band(ii).instrDataPoints;
                WaterfallDepth = obj.App.General.Plot.Waterfall.Depth;
                if strcmp(TaskSpec.Script.Observation.Type, 'Samples')
                    WaterfallDepth = min([WaterfallDepth, TaskSpec.Script.Band(ii).instrObservationSamples]);
                end

                obj.Tasks(idx).Bands(ii).Waterfall = struct('idx', 0, 'Depth', WaterfallDepth, 'Matrix', -1000 .* ones(WaterfallDepth, DataPoints, 'single'));
            end

            obj.restartStatus(idx, 0)
        end

        %-----------------------------------------------------------------%
        function task = resolveStreamingHandle(obj, task)
            % Substitui "startup_specObjRead_Streaming(app, SpecObj)". Usada
            % tanto no início de uma tarefa (startUp) quanto na reconexão de
            % tarefas persistidas (winAppColeta_exported > startup_specObjRead).

            receiverName = task.TaskSpec.Receiver.Selection.Name{1};
            taskType     = task.TaskSpec.Type;

            idx1 = obj.selectedReceiverIndex(receiverName, taskType);
            if ismember(obj.App.receiverObj.Config.connectFlag(idx1), [2, 3])
                [obj.UDPPortArray, idx2] = fcn.udpSockets(obj.UDPPortArray, obj.App.EB500Obj.udpPort);
                if ~isempty(idx2)
                    task.TaskSpec.Streaming.Handle = obj.UDPPortArray{idx2};
                    task.Connections.stream        = task.TaskSpec.Streaming.Handle;
                end
            end
        end

        %-----------------------------------------------------------------%
        function [task, msgError] = resolveGpsHandle(obj, task)
            % Substitui "startup_specObjRead_GPS(app, SpecObj)". Usada tanto
            % no início de uma tarefa (startUp) quanto na reconexão de
            % tarefas persistidas (winAppColeta_exported > startup_specObjRead).

            msgError = '';

            if ~isempty(task.TaskSpec.GPS.Selection)
                instrSelected = struct('Type',       task.TaskSpec.GPS.Selection.Type{1}, ...
                                       'Parameters', jsondecode(task.TaskSpec.GPS.Selection.Parameters{1}));

                [idx2, msgError] = obj.App.gpsObj.Connect(instrSelected);
                if isempty(msgError)
                    task.TaskSpec.GPS.Handle = obj.App.gpsObj.Table.Handle{idx2};
                    task.GPS                 = task.TaskSpec.GPS.Handle;
                end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function idx = selectedReceiverIndex(obj, receiverName, taskType)
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
        function gpsData(obj, ii, hReceiver, hGPS, newTimeStamp)
            % Substitui "RegularTask_gpsData(app, ii, hReceiver, hGPS, newTimeStamp)".
            %
            % O controle de erro do RECEPTOR se dá no método "runLoop".
            %
            % O controle de erro do GPS, por outro lado, se dá diretamente aqui,
            % nesta função, e é restrito ao caso em que o receptor é "External",
            % ou seja, não se trata de GPS embarcado no RECEPTOR (GPS conectado
            % à porta USB do computador que executa o app, por exemplo).
            %
            % Caso a tarefa seja do tipo "Drive-test", toda vez que for manifestada
            % uma desconexão, o app tentará reativar a conexao. Ou, em sendo uma tarefa
            % de outro tipo, o app tentará reativar a conexão toda vez que o contador de
            % erro atingir um múltiplo de "class.Constants.errorGPSCountTrigger".

            gpsResult = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '');

            try
                switch obj.Tasks(ii).TaskSpec.Script.GPS.Type
                    case 'Built-in'
                        gpsResult = fcn.gpsBuiltInReader(hReceiver);
                    case 'External'
                        gpsResult = fcn.gpsExternalReader(hGPS, 1);
                        obj.Tasks(ii).RetryPolicy.gps = struct('failureCount', 0, 'firstFailureAt', NaT, 'lastFailureAt', NaT);
                end

            catch ME
                obj.Tasks(ii).LogEntries(end+1) = struct('level', 'error (GPS)', 'timestamp', char(newTimeStamp), 'message', ME.message);

                if strcmp(obj.Tasks(ii).TaskSpec.Script.GPS.Type, 'External')
                    obj.errorHandle('GPS', ii, newTimeStamp)
                    notify(obj, 'ErrorRaised', model.TaskEventData(ii, [], 'GPS'))

                    if contains(obj.Tasks(ii).TaskSpec.Type, 'Drive-test') || ~mod(obj.Tasks(ii).RetryPolicy.gps.failureCount, class.Constants.errorGPSCountTrigger)
                        obj.App.gpsObj.ReconnectAttempt(hGPS.UserData.instrSelected);
                    end
                end
            end

            obj.gpsUpdate(ii, gpsResult, newTimeStamp)
        end

        %-----------------------------------------------------------------%
        function gpsUpdate(obj, ii, gpsResult, newTimeStamp)
            % Substitui "RegularTask_gpsUpdate(app, ii, gpsData, newTimeStamp)".

            if isempty(gpsResult.TimeStamp)
                gpsResult.TimeStamp = char(newTimeStamp);
            end
            obj.Tasks(ii).GPSLastFix = gpsResult;

            notify(obj, 'GpsUpdated', model.TaskEventData(ii, [], gpsResult))
        end

        %-----------------------------------------------------------------%
        function antennaSwitch(obj, ii, jj)
            % Substitui "RegularTask_AntennaSwitch(app, ii, jj)".

            switch obj.Tasks(ii).TaskSpec.Antenna.Switch.Name
                case 'EMSat'
                    msgError = obj.App.EMSatObj.MatrixSwitch(obj.Tasks(ii).Bands(jj).Antenna.SwitchPort,    ...
                                                         obj.Tasks(ii).TaskSpec.Antenna.Switch.OutputPort, ...
                                                         obj.Tasks(ii).Bands(jj).Antenna.LNBChannel,    ...
                                                         obj.Tasks(ii).Bands(jj).Antenna.LNBIndex);
                    if ~isempty(msgError)
                        error(msgError)
                    end

                case 'ERMx'
                    msgError = obj.App.ERMxObj.MatrixSwitch( obj.Tasks(ii).Bands(jj).Antenna.SwitchPort, ...
                                                         obj.Tasks(ii).TaskSpec.Antenna.Switch.OutputPort);
                    if ~isempty(msgError)
                        error(msgError)
                    end
            end
        end

        %-----------------------------------------------------------------%
        function configBand(obj, ii, jj, hReceiver)
            % Substitui "RegularTask_ConfigBand(app, ii, jj, hReceiver)".

            writeline(hReceiver, obj.Tasks(ii).Bands(jj).SpecificSCPI.configSET);
            pause(.001)

            if ~isempty(obj.Tasks(ii).Bands(jj).SpecificSCPI.attSET)
                writeline(hReceiver, obj.Tasks(ii).Bands(jj).SpecificSCPI.attSET);
            end
        end

        %-----------------------------------------------------------------%
        function newArray = specData(obj, ii, jj, hReceiver, hStreaming, newTimeStamp)
            % Substitui "RegularTask_specData(app, ii, jj, hReceiver, hStreaming, newTimeStamp)".

            Timeout = class.Constants.Timeout;
            Flag_success = false;

            switch obj.Tasks(ii).TaskSpec.Receiver.Config.connectFlag
                case 1
                    % Spectrum analyzers (R&S, KeySight, Tektronix, Anritsu)

                    recTic = tic;
                    t1 = toc(recTic);
                    while t1 < Timeout
                        try
                            writeline(hReceiver, obj.Tasks(ii).ReceiverCommands.data);
                            newArray = readbinblock(hReceiver, 'single');

                            if numel(newArray) == obj.Tasks(ii).Bands(jj).DataPoints
                                if strcmp(obj.Tasks(ii).TaskSpec.Receiver.Sync, 'Continuous Sweep')
                                    SyncModeRef = sum(newArray);

                                    if SyncModeRef ~= obj.Tasks(ii).Bands(jj).SyncModeRef
                                        obj.Tasks(ii).Bands(jj).SyncModeRef = SyncModeRef;
                                    else
                                        continue
                                    end
                                end

                                Flag_success = true;
                                break
                            end

                        catch
                        end
                        t1 = toc(recTic);
                    end

                case 2
                    % R&S EB500: Tarefas ordinárias

                    taskInfo = struct('Type',       obj.Tasks(ii).TaskSpec.Type,                      ...
                                      'FreqStart',  obj.Tasks(ii).TaskSpec.Script.Band(jj).FreqStart, ...
                                      'FreqStop',   obj.Tasks(ii).TaskSpec.Script.Band(jj).FreqStop,  ...
                                      'DataPoints', obj.Tasks(ii).Bands(jj).DataPoints,            ...
                                      'nDatagrams', obj.Tasks(ii).Bands(jj).Datagrams,             ...
                                      'udpPort',    obj.App.EB500Obj.udpPort);

                    [newArray, Flag_success] = class.EB500Lib.DatagramRead_PSCAN(taskInfo, hReceiver, hStreaming);

                case 3
                    % R&S EB500 - Tarefa "Drive-test (Level+Azimuth)"
                    % O newArray gerado aqui, e apenas aqui, possui informações
                    % de nível, azimute e nota de qualidade do azimute. A dimensão
                    % dele é 1 (Height) x DataPoints (Width) x 3 (Depth).

                    taskInfo = struct('Type',       obj.Tasks(ii).TaskSpec.Type,                                                                          ...
                                      'FreqCenter', (obj.Tasks(ii).TaskSpec.Script.Band(jj).FreqStart + obj.Tasks(ii).TaskSpec.Script.Band(jj).FreqStop)/2, ...
                                      'FreqSpan',   obj.Tasks(ii).TaskSpec.Script.Band(jj).FreqStop - obj.Tasks(ii).TaskSpec.Script.Band(jj).FreqStart,     ...
                                      'DataPoints', obj.Tasks(ii).Bands(jj).DataPoints,                                                                ...
                                      'udpPort',    obj.App.EB500Obj.udpPort);

                    [newArray, gpsResult, Flag_success] = class.EB500Lib.DatagramRead_FFM(taskInfo, hReceiver, hStreaming);

                    % No datagrama tem a informação de gps... então vamos aproveitar! :)
                    obj.gpsUpdate(ii, gpsResult, newTimeStamp)
            end
            flush(hReceiver)

            if Flag_success
                if obj.Tasks(ii).Bands(jj).FlipArray
                    newArray(:,:,1) = flip(newArray(:,:,1));
                end
            else
                error('Não foi lido corretamente o vetor de nível do receptor dentro do tempo limite (%.0f segundos).', Timeout)
            end
        end

        %-----------------------------------------------------------------%
        function errorHandle(obj, errorType, ii, newTimeStamp)
            % Substitui "RegularTask_errorHandle(app, errorType, ii, newTimeStamp)".

            switch errorType
                case 'Receiver'; family = 'receiver';
                case 'GPS';      family = 'gps';
            end

            if isnat(obj.Tasks(ii).RetryPolicy.(family).firstFailureAt)
                obj.Tasks(ii).RetryPolicy.(family).firstFailureAt = newTimeStamp;
            end
            obj.Tasks(ii).RetryPolicy.(family).lastFailureAt  = newTimeStamp;
            obj.Tasks(ii).RetryPolicy.(family).failureCount   = obj.Tasks(ii).RetryPolicy.(family).failureCount + 1;
        end
    end

end