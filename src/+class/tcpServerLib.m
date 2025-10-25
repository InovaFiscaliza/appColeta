classdef tcpServerLib < handle

    properties
        App
        Server

        % Armazenado em "Timer" um handle para um objeto timer, o qual tem
        % como objetivo avaliar o status do servidor, realizando tentativa 
        % de reconexão, caso aplicável.
        Timer
        
        Time
        LOG  = table('Size', [0, 8],                                                                                    ...
                     'VariableTypes', {'string', 'string', 'double', 'string', 'string', 'string', 'double', 'string'}, ...
                     'VariableNames', {'Timestamp', 'ClientAddress', 'ClientPort', 'Message', 'ClientName', 'Request', 'NumBytesWritten', 'Status'});
    end


    methods
        %-----------------------------------------------------------------%
        function obj = tcpServerLib(app)
            obj.App  = app;
            obj.Time = datetime('now', 'Format', 'dd/MM/yyyy HH:mm:ss');
            
            TimerCreation(obj, app)
        end


        %-----------------------------------------------------------------%
        function TimerCreation(obj, app)
            obj.Timer = timer("ExecutionMode", "fixedSpacing",                  ...
                              "BusyMode",      "queue",                         ...
                              "StartDelay",    0,                               ...
                              "Period",        class.Constants.tcpServerPeriod, ...
                              "TimerFcn",      {@obj.ConnectAttempt, app});
            start(obj.Timer)
        end


        %-----------------------------------------------------------------%
        function ConnectAttempt(obj, src, evt, app)
            IP   = app.General.tcpServer.IP;
            Port = app.General.tcpServer.Port;

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
                    fcn.tcpSockets_PortRelease(Port)
    
                    if ~isempty(IP); obj.Server = tcpserver(IP, Port);
                    else;            obj.Server = tcpserver(Port);
                    end
                    
                    configureTerminator(obj.Server, "CR/LF")
                    configureCallback(obj.Server, "terminator", @(~,~)obj.receivedMessage)
                end

            catch
            end
        end


        %-----------------------------------------------------------------%
        function receivedMessage(obj)
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
                            if ~strcmp(decodedMsg.Key, app.General.tcpServer.Key)
                                error('tcpServerLib:IncorrectKey', 'Incorrect key')
                            end
    
                            % Verifica se o nome do cliente está na lista de possíveis 
                            % nomes que o servidor se comunica.
                            % (configurado no arquivo "GeneralSettings.json")
                            if ~isempty(app.General.tcpServer.ClientList) && ~ismember(decodedMsg.ClientName, app.General.tcpServer.ClientList)
                                error('tcpServerLib:UnauthorizedClient', 'Unauthorized client')
                            end
            
                            % Requisições...
                            switch decodedMsg.Request
                                case 'StationInfo';  msg = StationInfo(obj);
                                case 'Diagnostic';   msg = Diagnostic(obj);
                                case 'PositionList'; msg = PositionList(obj);
                                case 'TaskList';     msg = TaskList(obj);
                                otherwise;           error('tcpServerLib:UnexpectedRequest', 'Unexpected Request')
                            end
    
                            sendMessageToClient(obj, struct('Request', decodedMsg.Request, 'Answer', msg))
                            logTableFill(obj, rawMsg, decodedMsg, 'success')
                            
                        catch ME
                            sendMessageToClient(obj, struct('Request', rawMsg{ii}, 'Answer', ME.identifier))
                            logTableFill(obj, rawMsg, rawMsg{ii}, ME.message)
                        end
                    end
    
                else
                    sendMessageToClient(obj, struct('Request', rawMsg, 'Answer', 'Invalid request'))
                    logTableFill(obj, rawMsg, '', 'tcpServerLib:EmptyRequest')
                end
            end
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function sendMessageToClient(obj, structMsg)
            writeline(obj.Server, ['<JSON>' jsonencode(structMsg) '</JSON>'])
        end


        %-----------------------------------------------------------------%
        function logTableFill(obj, rawMsg, decodedMsg, statusMsg)
            if isfield(decodedMsg, 'ClientName'); ClientName = decodedMsg.ClientName;
            else;                                 ClientName = '-';
            end

            if isfield(decodedMsg, 'ClientName'); Request    = decodedMsg.Request;
            else;                                 Request    = '-';
            end

            obj.LOG(end+1,:) = {datestr(now),               ...
                                obj.Server.ClientAddress,   ...
                                obj.Server.ClientPort,      ...
                                rawMsg,                     ...
                                ClientName,                 ...
                                Request,                    ...
                                obj.Server.NumBytesWritten, ...
                                statusMsg};
        end


        %-----------------------------------------------------------------%
        function answer = StationInfo(obj)
            app = obj.App;
            answer = struct('stationInfo',  app.General.stationInfo);
        end


        %-----------------------------------------------------------------%
        function answer = Diagnostic(obj)
            app = obj.App;
            answer = struct('stationInfo',  app.General.stationInfo,                                           ...
                            'Diagnostic',   struct('appColeta', struct('Release', class.Constants.appRelease,  ...
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
        function answer = PositionList(obj)
            app = obj.App;
            answer = struct('stationInfo',  app.General.stationInfo, ...
                            'positionList', struct('IDN', {}, 'gpsType', {}, 'gpsStatus', {}, 'Latitude', {}, 'Longitude', {}));

            for ii = 1:numel(app.specObj)
                answer.positionList(ii) = struct('IDN',       app.specObj(ii).IDN,                  ...
                                                 'gpsType',   app.specObj(ii).Task.Script.GPS.Type, ...
                                                 'gpsStatus', app.specObj(ii).lastGPS.Status,       ...
                                                 'Latitude',  app.specObj(ii).lastGPS.Latitude,     ...
                                                 'Longitude', app.specObj(ii).lastGPS.Longitude);
            end
        end


        %-----------------------------------------------------------------%
        function answer = TaskList(obj)            
            app = obj.App;

            answer = struct('stationInfo', app.General.stationInfo, ...
                            'taskList',    struct('IDN', {}, 'TaskName', {}, 'Observation', {}, 'Band', {}, 'MaskTable', {}, 'Status', {}));
            
            for ii = 1:numel(app.specObj)
                answer.taskList(ii).IDN          = app.specObj(ii).IDN;
                answer.taskList(ii).TaskName     = app.specObj(ii).Task.Script.Name;
                answer.taskList(ii).Observation  = struct('Type',      app.specObj(ii).Task.Script.Observation.Type, ...
                                                          'BeginTime', app.specObj(ii).Observation.BeginTime,        ...
                                                          'EndTime',   app.specObj(ii).Observation.EndTime);
                
                maskTable = [];
                for jj = 1:numel(app.specObj(ii).Band)
                    Mask = app.specObj(ii).Band(jj).Mask;
                    if ~isempty(Mask)
                        maskTable = Mask.Table;
                        Mask = rmfield(Mask, {'Table', 'Array', 'BrokenArray'});
                    end

                    answer.taskList(ii).Band(jj) = struct('FreqStart',          app.specObj(ii).Task.Script.Band(jj).FreqStart,                ...
                                                          'FreqStop',           app.specObj(ii).Task.Script.Band(jj).FreqStop,                 ...
                                                          'ObservationSamples', app.specObj(ii).Task.Script.Band(jj).instrObservationSamples,  ...
                                                          'nSweeps',            app.specObj(ii).Band(jj).nSweeps,                              ...
                                                          'Mask',               Mask);
                end

                if ~strcmp(app.specObj(ii).Task.Script.Observation.Type, 'Samples')
                    answer.taskList(ii).Band = rmfield(answer.taskList(ii).Band, 'ObservationSamples');
                end

                answer.taskList(ii).MaskTable = maskTable;
                answer.taskList(ii).Status    = app.specObj(ii).Status;            % 'Na fila' | 'Em andamento' | 'Cancelada' | 'Concluída' | 'Erro'
            end
        end
    end
end