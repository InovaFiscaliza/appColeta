classdef Receiver < handle

    %---------------------------------------------------------------------%
    % ## model.Receiver ##
    %
    % Concentra lista de receptores disponíveis e gerencia suas conexões.
    %
    % O objeto "tcpclient" possui uma propriedade privada da classe - "TCPCustomClient" -, o qual armazena o objeto "TCPCustomClient".
    % É essa propriedade que possibilita acesso ao objeto "TCPClient".
    %
    % O objeto "TCPClient" possui as propriedades "Connect" (true|false) e "ConnectionStatus" ('Connected'|'Disconnected') que registram o 
    % estado da conexão, o qual só é alterado quando realizada alguma operação de escrita (write, writeline etc) ou leitura no objeto "tcpclient".
    %
    % O MATLAB retorna os seguintes erros em operações de escrita e leitura de um objeto "tcpclient" desconectado:
    % 'MATLAB:networklib:tcpclient:connectTerminated'  (write)
    % 'transportclients:string:writeFailed'            (writeline|writeread)
    % 'network:tcpclient:sendFailed'                   (write|writeline)
    % 'transportclients:string:timeoutToken'           (writeread)
    % 'transportclients:string:invalidConnectionState' (read|readline)
    %
    % E esse objeto "TCPClient" possui os métodos "connect" e "disconnect", os quais tentam alterar ativamente o estado da conexão.
    %
    % O controle da conexão do appColeta com o objeto "tcpclient" pode ser feito com a exclusão do objeto (delete/clear) e posterior
    % recriação, ou por meio da alteração do seu estado (método "connect" do objeto "TCPClient").
    %
    % Notei, contudo, que o objeto "TCPCustomClient" às vezes é deletado, desvinculando o objeto "tcpclient" do "TCPClient". Quando isso
    % acontece, o MATLAB retorna os seguintes erros:
    % 'MATLAB:networklib:tcpclient:writeFailed'        (write)
    % 'MATLAB:class:InvalidHandle'                     (writeline|writeread|read|readline)
    % 'testmeaslib:CustomDisplay:PropertyError'        (acesso à propriedade)
    %
    % Nesse caso, o objeto "tcpclient" deve ser recriado. Não é adequado armazenar um handle pro objeto "TCPClient" porque, mesmo
    % existente, ele pode não mais estar relacionado ao objeto "tcpclient".
    %
    % Na maioria das vezes, contudo, isso não ocorre, e aí basta chamar o método "connect" do objeto "TCPClient". Se a conexão não for
    % reestabelecida, o MATLAB retorna o erro:
    % 'network:tcpclient:connectFailed'
    %---------------------------------------------------------------------%

    properties
        Config

        List = table( ...
            'Size', [0, 6], ...
            'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'cell', 'double'}, ...
            'VariableNames', {'Family', 'Name', 'Type', 'Parameters', 'Description', 'Enable'} ...
        )

        Table = table( ...
            'Size', [0, 4], ...
            'VariableTypes', {'string', 'string', 'cell', 'string'}, ...
            'VariableNames', {'Family', 'Socket', 'Handle', 'Status'} ...
        )
    end


    methods
        %-----------------------------------------------------------------%
        function obj = Receiver(rootFolder, resourcesFolder)
            obj.Config = loadDefinitions(obj, resourcesFolder);
            obj.List   = fileRead(obj, rootFolder);

            if ~isdeployed()
                arrayfun(@(x) delete(x), tcpclientfind())
                arrayfun(@(x) delete(x), udpportfind())
            end
        end

        %-----------------------------------------------------------------%
        function tempList = fileRead(obj, rootFolder)
            appName = class.Constants.appName;
            [projectFolder, programDataFolder] = appEngine.util.Path(appName, rootFolder);

            try
                tempList = util.InstrumentIO.readInstrumentList(fullfile(programDataFolder, 'InstrumentList.json'));
            catch ME
                tempList = util.InstrumentIO.readInstrumentList(fullfile(projectFolder,     'InstrumentList.json'));
            end

            tempList(~strcmp(tempList.Family, 'Receiver'), :) = [];
            if height(tempList)
                if ~any(tempList.Enable)
                    tempList.Enable(1) = 1;
                end
            else
                tempList(end+1, :) = defaultInstrument(obj);
            end
        end

        %-----------------------------------------------------------------%
        function [idx, msgError] = connect(obj, receiver)
            % Características do instrumento em que se deseja controlar:
            type = receiver.Type;
            tag  = receiver.Tag;
            [ip, port, timeout, localhostPublicIP, localhostLocalIP] = missingParameters(obj, receiver.Parameters);
            socketTag = sprintf('%s:%d', ip, port);

            % Consulta se há objeto "tcpclient" criado para o instrumento:
            idn = '';
            msgError = '';
            idx = [];

            if isfield(receiver, 'Definition')
                definition = receiver.Definition;
            else
                definition = findDefinitionByTag(obj, tag);
            end

            if isempty(definition)
                msgError = sprintf('O receptor "%s" não consta da biblioteca de receptores.', tag);
                return
            end

            idx = find(strcmp(obj.Table.Socket, socketTag), 1);

            if ~isempty(idx)
                receiverHandle = obj.Table.Handle{idx};

                warning('off', 'MATLAB:structOnObject')
                warning('off', 'transportlib:legacy:PropertyNotSupported')

                % Três tentativas para reestabelecer a comunicação, caso
                % esteja com falha.
                for kk = 1:3
                    try
                        transportHandle = struct(struct(receiverHandle).TCPCustomClient).Transport;
                        if ~transportHandle.Connected
                            transportHandle.connect
                        end

                        idn = identify(model.ReceiverDriver(definition, receiverHandle));
                        break

                    catch ME
                        switch ME.identifier
                            case 'network:tcpclient:connectFailed'
                                msgError = ME.message;
                                obj.Table.Status(idx) = 'Disconnected';
                                return

                            case {'MATLAB:class:InvalidHandle', 'testmeaslib:CustomDisplay:PropertyError'}
                                delete(obj.Table.Handle{idx})
                                obj.Table(idx, :) = [];
                                idx = [];
                                break
                        end
                    end
                    pause(.100)
                end

                if isempty(idn)
                    idx = [];
                end
            end

            try
                if isempty(idx)
                    idx = height(obj.Table)+1;
                    switch type
                        case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                            receiverHandle = tcpclient(ip, port);
                            idn = identify(model.ReceiverDriver(definition, receiverHandle));

                        otherwise
                            error('appColeta supports only TCPIP Socket connection type.')
                            % receiverHandle = visadev(sprintf('TCPIP::%s::INSTR', ip));
                            % receiverHandle = visadev(sprintf('TCPIP::%s::%d::SOCKET', ip, port));
                    end
                    receiverHandle.Timeout = timeout;
                end

                if ~isempty(idn)
                    if contains(idn, tag, "IgnoreCase", true)
                        if idx > height(obj.Table)
                            clientIP = '';
                            if ~isempty(localhostPublicIP)
                                clientIP = localhostPublicIP;
                            elseif ~isempty(localhostLocalIP)
                                clientIP = localhostLocalIP;
                            elseif ~strcmp(ip, '127.0.0.1')
                                [~, clientIP] = ipsFind(obj, ip);
                            end

                            receiverHandle.UserData = struct('IDN', idn, 'ClientIP', clientIP, 'SyncMode', '', 'Config', receiver);
                            obj.Table{idx, :} = {"Receiver", socketTag, receiverHandle, "Connected"};

                        else
                            obj.Table.Status(idx) = "Connected";
                        end

                    else
                        obj.Table.Status(idx) = "Disconnected";
                        error('O instrumento identificado (%s) difere do configurado (%s).', idn, tag)
                    end

                else
                    obj.Table.Status(idx) = "Disconnected";
                    error('Não recebida resposta à requisição "*IDN?".')
                end

            catch ME
                msgError = ME.message;
                if (idx > height(obj.Table)) && exist('receiverHandle', 'var')
                    clear receiverHandle
                end
                idx = [];
            end
        end

        %-----------------------------------------------------------------%
        function msgError = reconnectAttempt(obj, receiverConfig, definition, bandCommands)
            receiverConfig.Definition = definition;
            [idx, msgError] = connect(obj, receiverConfig);

            if isempty(msgError)
                try
                    restoreConfiguration(model.ReceiverDriver(definition, obj.Table.Handle{idx}), bandCommands)

                catch ME
                    msgError = ME.message;
                end
            end
        end

        %-----------------------------------------------------------------%
        function [instrHandle, notification] = testConnectivity(obj, instrSelected, emitNotification)
            notification = [];

            [idx, msgError] = connect(obj, instrSelected);

            if isempty(msgError)
                instrHandle = obj.Table.Handle{idx};
                if emitNotification
                    notification = struct('type', 'warning', 'message', sprintf('Conectado ao %s', instrHandle.UserData.IDN));
                end

            else
                instrHandle = [];
                if emitNotification
                    notification = struct('type', 'error', 'message', msgError);
                end
            end
        end

        %-----------------------------------------------------------------%
        function definition = findDefinition(obj, receiverName, taskType)
            % O R&S EB500 tem dois registros em "ReceiverLib", um relacionado 
            % às tarefas normais e outro à tarefa "Drive-test (Level+Azimuth)".

            idx = find(strcmp(obj.Config.Name, receiverName));

            if numel(idx) > 1
                isLevelAzimuth = cellfun(@(x) strcmp(x.connection.traceData.dataType, 'level+azimuth'), obj.Config.Definition(idx));

                if contains(taskType, 'Drive-test (Level+Azimuth)')
                    idx = idx(isLevelAzimuth);
                else
                    idx = idx(~isLevelAzimuth);
                end
            end

            definition = [];
            if ~isempty(idx)
                definition = obj.Config.Definition{idx(1)};
            end
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function instrument = defaultInstrument(~)
            instrument = { ...
                'Receiver', ...
                'Tektronix SA2500', ...
                'TCPIP Socket', ...
                '{ "IP": "127.0.0.1", "Port": "34835", "Timeout": 5 }', ...
                'Modo servidor/cliente. Loopback (127.0.0.1).', ...
                1 ...
            };
        end

        %-----------------------------------------------------------------%
        function [ip, port, timeout, localhostPublicIP, localhostLocalIP] = missingParameters(~, Parameters)
            % IP
            ip = '';
            if isfield(Parameters, 'IP')
                ip = Parameters.IP;
            end

            if strcmpi(ip, 'localhost')
                ip = '127.0.0.1';
            end
        
            % Port
            port = [];
            if isfield(Parameters, 'Port')
                port = Parameters.Port;                   
            end
            
            if ~isnumeric(port)
                port = str2double(port);
            end

            % Timeout
            timeout = class.Constants.Timeout;
            if isfield(Parameters, 'Timeout')
                timeout = Parameters.Timeout;
            end
        
            % localhostPublicIP & localhostLocalIP
            localhostPublicIP = '';
            localhostLocalIP  = '';

            if isfield(Parameters, 'Localhost_Enable') && Parameters.Localhost_Enable
                if isfield(Parameters, 'Localhost_publicIP')
                    localhostPublicIP = Parameters.Localhost_publicIP;
                end        
                
                if isfield(Parameters, 'Localhost_localIP')
                    localhostLocalIP = Parameters.Localhost_localIP;
                end
            end
        end

        %-----------------------------------------------------------------%
        function config = loadDefinitions(~, resourcesFolder)
            library      = jsondecode(fileread(fullfile(resourcesFolder, 'ReceiverLib.json')));

            % O arquivo de um instrumento contém um registro ou, quando o instrumento
            % tem mais de um modo de operação (R&S EB500), um array de registros.
            definitions = {};
            for ii = 1:numel(library.instrumentNames)
                records = jsondecode(fileread(fullfile(resourcesFolder, 'ReceiverLib', [library.instrumentNames{ii} '.json'])));
                if isstruct(records)
                    records = num2cell(records);
                end

                definitions = [definitions; records(:)];
            end

            config = table( ...
                cellfun(@(x) x.family, definitions, 'UniformOutput', false), ...
                cellfun(@(x) x.name,   definitions, 'UniformOutput', false), ...
                cellfun(@(x) x.tag,    definitions, 'UniformOutput', false), ...
                cellfun(@(x) x.band,   definitions, 'UniformOutput', false), ...
                cellfun(@(x) x.image,  definitions, 'UniformOutput', false), ...
                definitions, ...
                'VariableNames', {'Family', 'Name', 'Tag', 'Band', 'Image', 'Definition'} ...
            );
        end

        %-----------------------------------------------------------------%
        function definition = findDefinitionByTag(obj, tag)
            idx = find(strcmp(obj.Config.Tag, tag), 1);

            definition = [];
            if ~isempty(idx)
                definition = obj.Config.Definition{idx};
            end
        end

        %-----------------------------------------------------------------%
        function [localIP, publicIP] = ipsFind(~, instrIP)
            [~, msg] = system('arp -a');            
            msgCell  = splitlines(msg);
            msgCell(cellfun(@(x) isempty(x), msgCell)) = [];
            
            idxLocalIPs = find(cellfun(@(x) contains(x, ' --- '), msgCell));
            idxInstrIPs = find(cellfun(@(x) contains(x, [' ' instrIP ' ']), msgCell));
            
            localIP = '';
            regExp  = '(\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3})';
            if ~isempty(idxInstrIPs)
                idxInstrIPs = idxInstrIPs(1);
                
                temp = idxLocalIPs - idxInstrIPs;
                idx  = find(temp<0);
                idx  = idx(end);
                        
                localIP  = char(regexp(msgCell{idxLocalIPs(idx)}, regExp, 'match'));
                publicIP = localIP;
                
            else
                localIPs = {};
                for ii = 1:numel(idxLocalIPs)
                    localIPs = [localIPs, regexp(msgCell{idxLocalIPs(ii)}, regExp, 'match')];
                end
                
                for jj = 1:numel(localIPs)
                    if ~system(sprintf('ping -n 3 -w 1000 -S %s %s', localIPs{jj}, instrIP))
                        localIP = localIPs{jj};
                        break
                    end
                end                
                publicIP = char(regexp(webread(class.Constants.checkIP), regExp, 'match'));
            end
        end
    end
end
