classdef TcpServer < handle

    %---------------------------------------------------------------------%
    % ## model.TcpServer ##
    %
    % Servidor TCP que responde a requisições de clientes externos (Zabbix,
    % Jupyter, MATLAB) com informações da estação e da lista de tarefas.
    % Substitui a antiga "class.tcpServerLib".
    %---------------------------------------------------------------------%

    properties
        App
        Server

        % Armazenado em "Timer" um handle para um objeto timer, o qual tem
        % como objetivo avaliar o status do servidor, realizando tentativa 
        % de reconexão, caso aplicável.
        Timer
        
        StartTime
        Log = table( ...
            'Size', [0, 8],                                                                                    ...
            'VariableTypes', {'string', 'string', 'double', 'string', 'string', 'string', 'double', 'string'}, ...
            'VariableNames', {'Timestamp', 'ClientAddress', 'ClientPort', 'Message', 'ClientName', 'Request', 'NumBytesWritten', 'Status'} ...
        );
    end


    methods
        %-----------------------------------------------------------------%
        function obj = TcpServer(app)
            obj.App = app;
            obj.StartTime = datetime('now', 'Format', 'dd/MM/yyyy HH:mm:ss');
            
            createStatusTimer(obj)
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function createStatusTimer(obj)
            obj.Timer = timer("ExecutionMode", "fixedSpacing",                  ...
                              "BusyMode",      "queue",                         ...
                              "StartDelay",    0,                               ...
                              "Period",        class.Constants.tcpServerPeriod, ...
                              "TimerFcn",      @(~,~)ensureConnection(obj));
            start(obj.Timer)
        end

        %-----------------------------------------------------------------%
        function ensureConnection(obj)
            ip = obj.App.General.context.SERVER.ip;
            port = obj.App.General.context.SERVER.port;

            try
                if isa(obj.Server, 'tcpserver.internal.TCPServer')
                    % Obter o handle para o objeto de baixo nível da interface
                    % tcpserver - o "GenericTransport", o qual possui propriedade 
                    % indicando o status do socket ("Connected"), além de métodos 
                    % que possibilitam reconexão ("connect" e "disconnect").

                    hTransport = struct(struct(struct(obj.Server).Client).ClientImpl).Transport;    
                    if ~hTransport.Connected
                        hTransport.connect
                    end

                else
                    util.SocketPorts.releasePort(port)
    
                    if ~isempty(ip)
                        obj.Server = tcpserver(ip, port);
                    else
                        obj.Server = tcpserver(port);
                    end
                    
                    configureTerminator(obj.Server, "CR/LF")
                    configureCallback(obj.Server, "terminator", @(~,~)onMessageReceived(obj))
                end

            catch
            end
        end

        %-----------------------------------------------------------------%
        function onMessageReceived(obj)
            % O servidor se comunica com apenas um único cliente, negando tentativas 
            % de conexão de outros clientes enquanto estiver ativa a comunicação com 
            % o cliente (socket criado).
    
            % O cliente deve enviar uma mensagem textual encapsulada respeitando a 
            % sintaxe JSON e possuir as seguintes chaves: "Key", "ClientName" e "Request".
    
            % O trigger no servidor não é o número de bytes recebidos, mas a chegada 
            % do terminador "CR/LF", que o cliente deve embutir na sua requisição.
        
            % Caso o cliente seja criado no MATLAB, a comunicação pode se dar da 
            % seguinte forma:
            % - writeline(tcpClient, jsonencode(msg))
            % - write(tcpClient, sprintf('%s\r\n', jsonencode(msg)))

            while obj.Server.NumBytesAvailable
                rawMsg = readline(obj.Server);
                
                if ~isempty(rawMsg)
                    for ii = 1:numel(rawMsg)
                        try
                            decodedMsg = jsondecode(rawMsg{ii});
    
                            % Verifica se a mensagem apresenta apenas as chaves
                            % "Key", "ClientName" e "Request".
                            if ~all(ismember(fields(decodedMsg), {'Key', 'ClientName', 'Request'}))
                                error('tcpServerLib:WrongListOfFields', 'Wrong list of fields')
                            end
                            
                            % Verifica tipos de dados...
                            mustBeTextScalar(decodedMsg.Key)
                            mustBeTextScalar(decodedMsg.ClientName)
                            mustBeTextScalar(decodedMsg.Request)
    
                            % Verifica se o cliente passou o valor correto de "Key".
                            % (configurado no arquivo "GeneralSettings.json")
                            if ~strcmp(decodedMsg.Key, obj.App.General.context.SERVER.key)
                                error('tcpServerLib:IncorrectKey', 'Incorrect key')
                            end
    
                            % Verifica se o nome do cliente está na lista de possíveis 
                            % nomes que o servidor se comunica.
                            % (configurado no arquivo "GeneralSettings.json")
                            if ~isempty(obj.App.General.context.SERVER.clientList) && ~ismember(decodedMsg.ClientName, obj.App.General.context.SERVER.clientList)
                                error('tcpServerLib:UnauthorizedClient', 'Unauthorized client')
                            end
            
                            % Requisições...
                            switch decodedMsg.Request
                                case 'StationInfo'
                                    msg = answerStationInfo(obj);
                                case 'Diagnostic'
                                    msg = answerDiagnostic(obj);
                                case 'Summary'
                                    msg = answerSummary(obj);
                                case 'PositionList'
                                    msg = answerPositionList(obj);
                                case 'TaskList'
                                    msg = answerTaskList(obj);
                                otherwise
                                    error('tcpServerLib:UnexpectedRequest', 'Unexpected Request')
                            end
    
                            sendMessageToClient(obj, struct('Request', decodedMsg.Request, 'Answer', msg))
                            appendLog(obj, rawMsg, decodedMsg, 'success')
                            
                        catch ME
                            sendMessageToClient(obj, struct('Request', rawMsg{ii}, 'Answer', ME.identifier))
                            appendLog(obj, rawMsg, rawMsg{ii}, ME.message)
                        end
                    end
    
                else
                    sendMessageToClient(obj, struct('Request', rawMsg, 'Answer', 'Invalid request'))
                    appendLog(obj, rawMsg, '', 'tcpServerLib:EmptyRequest')
                end
            end
        end

        %-----------------------------------------------------------------%
        function sendMessageToClient(obj, structMsg)
            writeline(obj.Server, ['<JSON>' jsonencode(structMsg) '</JSON>'])
        end

        %-----------------------------------------------------------------%
        function appendLog(obj, rawMsg, decodedMsg, statusMsg)
            clientName = '-';
            if isfield(decodedMsg, 'ClientName')
                clientName = decodedMsg.ClientName;
            end

            request = '-';
            if isfield(decodedMsg, 'Request')
                request    = decodedMsg.Request;  
            end

            obj.Log(end+1,:) = { ...
                datestr(now), ...
                obj.Server.ClientAddress, ...
                obj.Server.ClientPort, ...
                rawMsg, ...
                clientName, ...
                request, ...
                obj.Server.NumBytesWritten, ...
                statusMsg ...
            };
        end

        %-----------------------------------------------------------------%
        function answer = answerStationInfo(obj)
            answer = struct('stationInfo', obj.App.General.context.CONFIG.station);
        end

        %-----------------------------------------------------------------%
        function answer = answerDiagnostic(obj)
            answer = struct( ...
                'stationInfo', obj.App.General.context.CONFIG.station, ...
                'diagnostics', struct( ...
                    'applicationInfo', struct( ...
                        'matlabRelease', matlabRelease.Release, ...
                        'appVersion', class.Constants.appVersion ...
                    ), ...
                    'environmentVariables', [], ...
                    'systemInformation', [], ...
                    'logicalDisks', [] ...
                ) ...
            );

            % A seguir os campos que irão formar essa mensagem de diagnóstico
            % do appColeta.
            envFields = [ ...
                "COMPUTERNAME", ...
                "MATLAB_ARCH", ...
                "MODEL", ...
                "PROCESSOR_ARCHITECTURE", ...
                "PROCESSOR_IDENTIFIER", ...
                "PROCESSOR_LEVEL", ...
                "SERIAL", ...
                "TYPE2" ...
            ];

            sysNames = [ ...
                ... % English values
                "Host Name" ...
                "OS Name" ...
                "OS Version" ...
                "Product ID" ...
                "Original Install Date" ...
                "System Boot Time" ...
                "System Manufacturer" ...
                "System Model" ...
                "System Type" ...
                "BIOS Version" ...
                "Total Physical Memory" ...
                "Available Physical Memory" ...
                "Virtual Memory: Max Size" ...
                "Virtual Memory: Available" ...
                "Virtual Memory: In Use" ...
                ... % Portuguese values
                "Nome do host" ...
                "Nome do sistema operacional" ...
                "Versão do sistema operacional" ...
                "Identificação do produto" ...
                "Data da instalação original" ...
                "Tempo de Inicialização do Sistema" ...
                "Fabricante do sistema" ...
                "Modelo do sistema" ...
                "Tipo de sistema" ...
                "Versão do BIOS" ...
                "Memória física total" ...
                "Memória física disponível" ...
                "Memória Virtual: Tamanho Máximo" ...
                "Memória Virtual: Disponível" ...
                "Memória Virtual: Em Uso" ...
            ];

            sysValues  = repmat(replace(sysNames(1:15), {' ', ':'}, {'', ''}), [1 2]);
            sysDict    = dictionary(sysNames, sysValues);
            
            % Environment variable
            envVariables = getenv();
            envKeys      = keys(envVariables, 'uniform');
            envValues    = values(envVariables, 'uniform');
            
            [~, idx1]  = ismember(envFields, envKeys);
            idx1(~idx1) = [];
            answer.diagnostics.environmentVariables = table(envKeys(idx1), envValues(idx1), 'VariableNames', {'name', 'value'});
            
            % System info (Prompt1)
            [status, cmdout] = system('systeminfo');
            if ~status
                try
                    cmdout = strtrim(splitlines(cmdout));
                    cmdout(cellfun(@(x) isempty(x), cmdout)) = [];
            
                    cmdout_Cell = cellfun(@(x) regexp(x, '(?<parameter>[A-Z]\D+)[:]\s+(?<value>.+)', 'names'), cmdout, 'UniformOutput', false);
                    systemInfo  = struct('name', {}, 'value', {});
                    
                    for ii = 1:numel(cmdout_Cell)
                        if ~isempty(cmdout_Cell{ii})
                            keyName = cmdout_Cell{ii}.parameter;
                            if isKey(sysDict, keyName)
                                systemInfo(end+1) = struct('name', sysDict(keyName), 'value', cmdout_Cell{ii}.value);
                            end
                        end
                    end
                    answer.diagnostics.systemInformation = systemInfo;
                catch
                end
            end            
            
            % Disc info (Prompt2)
            answer.diagnostics.logicalDisks = queryLogicalDisks(obj);
        end

        %-----------------------------------------------------------------%
        function logicalDisks = queryLogicalDisks(~)
            logicalDisks = [];
            discFields = "DeviceID,FileSystem,FreeSpace,Size";

            [status, cmdout] = system("wmic LOGICALDISK get " + discFields);
            if ~status
                try
                    cmdout = strtrim(splitlines(cmdout));
                    cmdout(cellfun(@(x) isempty(x), cmdout)) = [];

                    logicalDisks = cellfun(@(x) regexp(x, '(?<deviceId>[A-Z]:)\s+(?<fileSystem>\w+)\s+(?<freeSpace>\d+)\s+(?<totalSize>\d+)', 'names'), cmdout(2:end));
                    for ii = 1:numel(logicalDisks)
                        logicalDisks(ii).freeSpace = textFormatGUI.bytes2human(str2double(logicalDisks(ii).freeSpace));
                        logicalDisks(ii).totalSize = textFormatGUI.bytes2human(str2double(logicalDisks(ii).totalSize));
                    end
                catch
                    logicalDisks = [];
                end
            end
        end

        %-----------------------------------------------------------------%
        function answer = answerSummary(obj)
            station = obj.App.General.context.CONFIG.station;

            receiverHandles = obj.App.receiverObj.Table.Handle;
            receiverIdns = {};
            for handleIdx = 1:numel(receiverHandles)
                receiverHandle = receiverHandles{handleIdx};
                if ~isempty(receiverHandle) && isvalid(receiverHandle) && isstruct(receiverHandle.UserData) && isfield(receiverHandle.UserData, 'IDN')
                    receiverIdns{end+1} = char(receiverHandle.UserData.IDN);
                end
            end
            receiverIdns = unique(receiverIdns);

            logicalDisks = queryLogicalDisks(obj);

            taskStatus = {obj.App.TaskController.Tasks.Status};
            runningTaskCount = sum(strcmp(taskStatus, 'Em andamento'));

            answer = struct( ...
                'stationName', station.name, ...
                'latitude', station.latitude, ...
                'longitude', station.longitude, ...
                'receiverIdns', {receiverIdns}, ...
                'logicalDisks', logicalDisks, ...
                'taskSummary', struct( ...
                    'isRunning', runningTaskCount > 0, ...
                    'totalCount', numel(taskStatus), ...
                    'runningCount', runningTaskCount ...
                ) ...
            );
        end

        %-----------------------------------------------------------------%
        function answer = answerPositionList(obj)
            tasks = obj.App.TaskController.Tasks;
            receiverPositions = cell(1, numel(tasks));
            for ii = 1:numel(tasks)
                receiverPositions{ii} = struct( ...
                    'receiverId', tasks(ii).ReceiverId, ...
                    'gpsType', tasks(ii).TaskSpec.Script.GPS.Type, ...
                    'gpsStatus', tasks(ii).GPSLastFix.Status, ...
                    'latitude', round(tasks(ii).GPSLastFix.Latitude, 6), ...
                    'longitude', round(tasks(ii).GPSLastFix.Longitude, 6) ...
                );
            end

            answer = struct( ...
                'stationInfo', obj.App.General.context.CONFIG.station, ...
                'receiverPositions', {receiverPositions} ...
            );
        end

        %-----------------------------------------------------------------%
        function answer = answerTaskList(obj)
            tasks = obj.App.TaskController.Tasks;
            taskList = cell(1, numel(tasks));

            for ii = 1:numel(tasks)
                observation = struct( ...
                    'type', tasks(ii).TaskSpec.Script.Observation.Type, ...
                    'startTime', tasks(ii).Timing.startedAt, ...
                    'endTime', tasks(ii).Timing.endedAt ...
                );
                
                maskTable = [];
                bands = cell(1, numel(tasks(ii).Bands));
                for jj = 1:numel(tasks(ii).Bands)
                    mask = tasks(ii).Bands(jj).Mask;
                    spectralMaskMonitoring = [];
                    if ~isempty(mask)
                        maskTable = mask.Table;

                        exceedingPeaks = mask.ExceedingPeaks;
                        if isempty(exceedingPeaks)
                            exceedingPeaks = {};
                        end

                        evaluation = struct( ...
                            'validationCount', mask.ValidationCount, ...
                            'violationCount', mask.ViolationCount, ...
                            'lastViolationAt', mask.LastViolationAt ...
                        );
                        evaluation.exceedingPeaks = exceedingPeaks;

                        spectralMaskMonitoring = struct( ...
                            'configuration', mask.Configuration, ...
                            'evaluation', evaluation ...
                        );
                    end

                    outputFile = tasks(ii).Bands(jj).OutputFile;
                    if isempty(outputFile)
                        writtenTraceCount = 0;
                    else
                        writtenTraceCount = outputFile.WritedSamples;
                    end

                    band = struct( ...
                        'startFrequencyHz', tasks(ii).TaskSpec.Script.Band(jj).FreqStart, ...
                        'stopFrequencyHz', tasks(ii).TaskSpec.Script.Band(jj).FreqStop, ...
                        'observationSampleCount', tasks(ii).TaskSpec.Script.Band(jj).instrObservationSamples, ...
                        'acquiredSweepCount', tasks(ii).Bands(jj).NumSweeps, ...
                        'writtenTraceCount', writtenTraceCount, ...
                        'spectralMaskMonitoring', spectralMaskMonitoring ...
                    );

                    bands{jj} = band;
                end

                taskList{ii} = struct( ...
                    'receiverId', tasks(ii).ReceiverId, ...
                    'taskName', tasks(ii).TaskSpec.Script.Name, ...
                    'observation', observation, ...
                    'frequencyBands', {bands}, ...
                    'spectralMaskTable', maskTable, ...
                    'taskStatus', tasks(ii).Status ...
                );
            end

            answer = struct( ...
                'stationInfo', obj.App.General.context.CONFIG.station, ...
                'tasks', {taskList} ...
            );
        end
    end
end
