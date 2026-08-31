classdef Receiver < handle
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
        function obj = Receiver(rootFolder)
            obj.Config = struct2table(jsondecode(fileread(fullfile(rootFolder, 'config', 'ReceiverLib.json'))));
            obj.List   = fileRead(obj, rootFolder);

            if ~isdeployed()
                arrayfun(@(x) delete(x), tcpclientfind())
                arrayfun(@(x) delete(x), udpportfind())
            end
        end

        %-----------------------------------------------------------------%
        % ## tcpclient ##
        % O objeto "tcpclient" possui uma propriedade privada da classe - "TCPCustomClient" -, o qual armazena o objeto "TCPCustomClient".
        % É essa propriedade que possibilita acesso ao objeto "TCPClient".
        %
        % ## TCPClient ##
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

                        idn = connectionStatus(obj, receiverHandle);
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
                            idn = connectionStatus(obj, receiverHandle);

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
        function msgError = reconnectAttempt(obj, instrSelected, connectFlag, startUp, specificSCPI)

            [idx, msgError] = connect(obj, instrSelected);

            % Se ocorrer alguma queda de energia e o receptor desligar, ao
            % religar, o receptor voltará às suas configurações de fábrica,
            % o que demandará, portanto, a sua reconfiguração (FreqStart,
            % FreqStop, Resolution etc).

            if isempty(msgError)
                try
                    receiverHandle = obj.Table.Handle{idx};

                    if ismember(connectFlag, [2, 3])
                        class.EB500Lib.OperationMode(receiverHandle, connectFlag)
                    end

                    writeline(receiverHandle, startUp);
                    pause(.001)

                    writeline(receiverHandle, specificSCPI.configSET);
                    pause(.001)

                    if ~isempty(specificSCPI.attSET)
                        writeline(receiverHandle, specificSCPI.attSET);
                    end

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
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function tempList = fileRead(obj, rootFolder)
            appName = class.Constants.appName;
            [projectFolder, programDataFolder] = appEngine.util.Path(appName, rootFolder);

            try
                tempList = fcn.instrumentListRead(fullfile(programDataFolder, 'instrumentList.json'));
            catch ME
                tempList = fcn.instrumentListRead(fullfile(projectFolder,     'instrumentList.json'));
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
        function instrument = defaultInstrument(~)
            instrument = {'Receiver', 'Tektronix SA2500', 'TCPIP Socket', '{"IP":"127.0.0.1","Port":"34835","Timeout":5}', 'Modo servidor/cliente. Loopback (127.0.0.1).', 1};
        end

        %-----------------------------------------------------------------%
        function [ip, port, timeout, localhostPublicIP, localhostLocalIP] = missingParameters(~, Parameters)
            % IP
            if isfield(Parameters, 'IP');                 ip = Parameters.IP;
            else;                                         ip = '';
            end

            if strcmpi(ip, 'localhost');                  ip = '127.0.0.1';
            end
        
            % Port
            if isfield(Parameters, 'Port');               port = Parameters.Port;
            else;                                         port = [];
            end
            
            if ~isnumeric(port);                          port = str2double(port);
            end

            % Timeout
            if isfield(Parameters, 'Timeout');            timeout = Parameters.Timeout;
            else;                                         timeout = class.Constants.Timeout;
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
        function idn = connectionStatus(~, receiverHandle)
            idn = '';            

            % A ideia de usar writeline/readline (com loop, criando artificialmente 
            % um Timeout) é fazer duas operações de comunicações com o socket (notei 
            % que em alguns sockets desconectados, a primeira operação de escrita é realizada
            % normalmente, retornando erro apenas numa segunda operação). Isso evita, também,
            % o Timeout padrão do writeread (10 segundos).

            flush(receiverHandle)
            writeline(receiverHandle, '*IDN?')

            statusTic = tic;
            t = toc(statusTic);
            while t < class.Constants.idnTimeout
                if receiverHandle.NumBytesAvailable
                    idn = readline(receiverHandle);
                    if ~isempty(idn)
                        idn = replace(strtrim(idn), {'"', ''''}, {'', ''});
                        break
                    end
                end
                t = toc(statusTic);
            end
            
            if isempty(idn)
                error('ReceiverLib:EmptyIDN', 'Empty identification')
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
