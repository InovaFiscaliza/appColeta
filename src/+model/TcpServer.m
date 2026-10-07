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
        Log  = table('Size', [0, 8],                                                                                    ...
                     'VariableTypes', {'string', 'string', 'double', 'string', 'string', 'string', 'double', 'string'}, ...
                     'VariableNames', {'Timestamp', 'ClientAddress', 'ClientPort', 'Message', 'ClientName', 'Request', 'NumBytesWritten', 'Status'});
    end


    methods
        %-----------------------------------------------------------------%
        function obj = TcpServer(app)
            obj.App       = app;
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
            IP   = obj.App.General.context.SERVER.ip;
            Port = obj.App.General.context.SERVER.port;

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
                    util.SocketPorts.releasePort(Port)
    
                    if ~isempty(IP); obj.Server = tcpserver(IP, Port);
                    else;            obj.Server = tcpserver(Port);
                    end
                    
                    configureTerminator(obj.Server, "CR/LF")
                    configureCallback(obj.Server, "terminator", @(~,~)onMessageReceived(obj))
                end

            catch
            end
        end

        %-----------------------------------------------------------------%
        function onMessageReceived(obj)
            app = obj.App;

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
                            if ~strcmp(decodedMsg.Key, app.General.context.SERVER.key)
                                error('tcpServerLib:IncorrectKey', 'Incorrect key')
                            end
    
                            % Verifica se o nome do cliente está na lista de possíveis 
                            % nomes que o servidor se comunica.
                            % (configurado no arquivo "GeneralSettings.json")
                            if ~isempty(app.General.context.SERVER.clientList) && ~ismember(decodedMsg.ClientName, app.General.context.SERVER.clientList)
                                error('tcpServerLib:UnauthorizedClient', 'Unauthorized client')
                            end
            
                            % Requisições...
                            switch decodedMsg.Request
                                case 'StationInfo';  msg = answerStationInfo(obj);
                                case 'Diagnostic';   msg = answerDiagnostic(obj);
                                case 'PositionList'; msg = answerPositionList(obj);
                                case 'TaskList';     msg = answerTaskList(obj);
                                otherwise;           error('tcpServerLib:UnexpectedRequest', 'Unexpected Request')
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
            if isfield(decodedMsg, 'ClientName'); ClientName = decodedMsg.ClientName;
            else;                                 ClientName = '-';
            end

            if isfield(decodedMsg, 'Request');    Request    = decodedMsg.Request;
            else;                                 Request    = '-';
            end

            obj.Log(end+1,:) = {datestr(now),               ...
                                obj.Server.ClientAddress,   ...
                                obj.Server.ClientPort,      ...
                                rawMsg,                     ...
                                ClientName,                 ...
                                Request,                    ...
                                obj.Server.NumBytesWritten, ...
                                statusMsg};
        end

        %-----------------------------------------------------------------%
        function answer = answerStationInfo(obj)
            answer = struct('stationInfo', obj.App.General.context.CONFIG.station);
        end

        %-----------------------------------------------------------------%
        function answer = answerDiagnostic(obj)
            answer = struct('stationInfo',  obj.App.General.context.CONFIG.station, ...
                            'Diagnostic',   struct('appColeta', struct('Release', matlabRelease.Release, ...
                                                                       'Version', class.Constants.appVersion), ...
                                                   'EnvVariables', [], ...
                                                   'SystemInfo',   [], ...
                                                   'LogicalDisk',  []));

            % A seguir os campos que irão formar essa mensagem de diagnóstico
            % do appColeta.
            envFields = ["COMPUTERNAME", ...
                         "MATLAB_ARCH", ...
                         "MODEL", ...
                         "PROCESSOR_ARCHITECTURE", ...
                         "PROCESSOR_IDENTIFIER", ...
                         "PROCESSOR_LEVEL", ...
                         "SERIAL", ...
                         "TYPE2"];
            sysNames   = ["Host Name"                 ...                   % English values
                          "OS Name"                   ...
                          "OS Version"                ...
                          "Product ID"                ...
                          "Original Install Date"     ...
                          "System Boot Time"          ...
                          "System Manufacturer"       ...
                          "System Model"              ...
                          "System Type"               ...
                          "BIOS Version"              ...
                          "Total Physical Memory"     ...
                          "Available Physical Memory" ...
                          "Virtual Memory: Max Size"  ...
                          "Virtual Memory: Available" ...
                          "Virtual Memory: In Use"    ...
                          "Nome do host"                      ...           % Portuguese values
                          "Nome do sistema operacional"       ...
                          "Versão do sistema operacional"     ...
                          "Identificação do produto"          ...
                          "Data da instalação original"       ...
                          "Tempo de Inicialização do Sistema" ...
                          "Fabricante do sistema"             ...
                          "Modelo do sistema"                 ...
                          "Tipo de sistema"                   ...
                          "Versão do BIOS"                    ...
                          "Memória física total"              ...
                          "Memória física disponível"         ...
                          "Memória Virtual: Tamanho Máximo"   ...
                          "Memória Virtual: Disponível"       ...
                          "Memória Virtual: Em Uso"];
            sysValues  = repmat(replace(sysNames(1:15), {' ', ':'}, {'', ''}), [1 2]);
            sysDict    = dictionary(sysNames, sysValues);            
            discFields = "DeviceID,FileSystem,FreeSpace,Size";            
            
            % Environment variable
            envVariables = getenv();
            envKeys      = keys(envVariables, 'uniform');
            envValues    = values(envVariables, 'uniform');
            
            [~, idx1]  = ismember(envFields, envKeys);
            idx1(~idx1) = [];
            answer.Diagnostic.EnvVariables = table(envKeys(idx1), envValues(idx1), 'VariableNames', {'env', 'value'});
            
            % System info (Prompt1)
            [status, cmdout] = system('systeminfo');
            if ~status
                try
                    cmdout = strtrim(splitlines(cmdout));
                    cmdout(cellfun(@(x) isempty(x), cmdout)) = [];
            
                    cmdout_Cell = cellfun(@(x) regexp(x, '(?<parameter>[A-Z]\D+)[:]\s+(?<value>.+)', 'names'), cmdout, 'UniformOutput', false);
                    systemInfo  = struct('parameter', {}, 'value', {});
                    
                    for ii = 1:numel(cmdout_Cell)
                        if ~isempty(cmdout_Cell{ii})
                            keyName = cmdout_Cell{ii}.parameter;
                            if isKey(sysDict, keyName)
                                systemInfo(end+1) = struct('parameter', sysDict(keyName), 'value', cmdout_Cell{ii}.value);
                            end
                        end
                    end
                    answer.Diagnostic.SystemInfo = systemInfo;
                catch
                end
            end            
            
            % Disc info (Prompt2)
            [status, cmdout] = system("wmic LOGICALDISK get " + discFields);
            if ~status
                try
                    cmdout = strtrim(splitlines(cmdout));
                    cmdout(cellfun(@(x) isempty(x), cmdout)) = [];
            
                    answer.Diagnostic.LogicalDisk = cellfun(@(x) regexp(x, '(?<DeviceID>[A-Z]:)\s+(?<FileSystem>\w+)\s+(?<FreeSpace>\d+)\s+(?<Size>\d+)', 'names'), cmdout(2:end));
                catch
                end
            end
        end

        %-----------------------------------------------------------------%
        function answer = answerPositionList(obj)
            answer = struct('stationInfo',  obj.App.General.context.CONFIG.station, ...
                            'positionList', struct('IDN', {}, 'gpsType', {}, 'gpsStatus', {}, 'Latitude', {}, 'Longitude', {}));

            tasks = obj.App.TaskController.Tasks;
            for ii = 1:numel(tasks)
                answer.positionList(ii) = struct('IDN',       tasks(ii).ReceiverId,                 ...
                                                 'gpsType',   tasks(ii).TaskSpec.Script.GPS.Type, ...
                                                 'gpsStatus', tasks(ii).GPSLastFix.Status,       ...
                                                 'Latitude',  tasks(ii).GPSLastFix.Latitude,     ...
                                                 'Longitude', tasks(ii).GPSLastFix.Longitude);
            end
        end

        %-----------------------------------------------------------------%
        function answer = answerTaskList(obj)
            answer = struct('stationInfo', obj.App.General.context.CONFIG.station, ...
                            'taskList',    struct('IDN', {}, 'TaskName', {}, 'Observation', {}, 'Band', {}, 'MaskTable', {}, 'Status', {}));
            
            tasks = obj.App.TaskController.Tasks;
            for ii = 1:numel(tasks)
                answer.taskList(ii).IDN          = tasks(ii).ReceiverId;
                answer.taskList(ii).TaskName     = tasks(ii).TaskSpec.Script.Name;
                answer.taskList(ii).Observation  = struct('Type',      tasks(ii).TaskSpec.Script.Observation.Type, ...
                                                          'BeginTime', tasks(ii).Timing.startedAt,        ...
                                                          'EndTime',   tasks(ii).Timing.endedAt);
                
                maskTable = [];
                for jj = 1:numel(tasks(ii).Bands)
                    Mask = tasks(ii).Bands(jj).Mask;
                    if ~isempty(Mask)
                        maskTable = Mask.Table;
                        Mask = rmfield(Mask, {'Table', 'Array', 'BrokenArray'});
                    end

                    answer.taskList(ii).Band(jj) = struct('FreqStart',          tasks(ii).TaskSpec.Script.Band(jj).FreqStart,                ...
                                                          'FreqStop',           tasks(ii).TaskSpec.Script.Band(jj).FreqStop,                 ...
                                                          'ObservationSamples', tasks(ii).TaskSpec.Script.Band(jj).instrObservationSamples,  ...
                                                          'nSweeps',            tasks(ii).Bands(jj).NumSweeps,                              ...
                                                          'Mask',               Mask);
                end

                if ~strcmp(tasks(ii).TaskSpec.Script.Observation.Type, 'Samples')
                    answer.taskList(ii).Band = rmfield(answer.taskList(ii).Band, 'ObservationSamples');
                end

                answer.taskList(ii).MaskTable = maskTable;
                answer.taskList(ii).Status    = tasks(ii).Status;            % 'Na fila' | 'Em andamento' | 'Cancelada' | 'Concluída' | 'Erro'
            end
        end
    end
end
