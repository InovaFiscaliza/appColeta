classdef scpiLib

    % ?? EVOLUÇÃO ??
    % Inserir conexão VISA?! Caso sim, mapear objeto transporte relacionado
    % struct(struct(hReceiver).Client).Transport.connect

    properties
        Config
        List
        Table = table('Size', [0, 5],                                                    ...
                      'VariableTypes', {'string', 'string', 'string', 'cell', 'string'}, ...
                      'VariableNames', {'Type', 'IDN', 'Socket', 'Handle', 'Status'})
    end


    methods
        %-----------------------------------------------------------------%
        function obj = scpiLib(RootFolder)
            % Config
            obj.Config = struct2table(jsondecode(fileread(fullfile(RootFolder, 'Settings', 'scpiLib_Config.json'))));

            % List
            tempList = jsondecode(fileread(fullfile(RootFolder, 'Settings', 'scpiLib_List.json')));
            for ii = 1:numel(tempList)
                tempList(ii).Parameters = jsonencode(tempList(ii).Parameters);
            end

            obj.List = struct2table(tempList, 'AsArray', true);
        end


        %-----------------------------------------------------------------%
        function [obj, idx, msgError] = Connect(obj, instrSelected)
            % Características do instrumento em que se deseja controlar:
            Type   = instrSelected.Type;
            Tag    = instrSelected.Tag;
            [IP, Port, Localhost_publicIP, Localhost_localIP] = obj.MissingParameters(instrSelected);
            Socket = sprintf('%s:%d', IP, Port);

            % Consulta se há objeto "tcpclient" criado para o instrumento:
            IDN = '';
            msgError = '';
            idx = find(strcmp(obj.Table.Socket, Socket), 1);

            if ~isempty(idx)
                hReceiver = obj.Table.Handle{idx};

                % Três tentativas para reestabelecer a comunicação, caso
                % esteja com falha.
                for kk = 1:3
                    try
                        warning('off', 'MATLAB:structOnObject')
                        if ~struct(struct(hReceiver).TCPCustomClient).Transport.Connected
                            struct(struct(hReceiver).TCPCustomClient).Transport.connect
                        end
                        IDN = obj.ConnectionStatus(hReceiver);
                        break

                    catch ME
                        msgError = ME.message;
                        switch ME.identifier
                            case 'network:tcpclient:connectFailed'
                                obj.Table.Status(idx) = 'Disconnected';
                                return
                            case {'MATLAB:class:InvalidHandle', 'testmeaslib:CustomDisplay:PropertyError'}
                                delete(obj.Table.Handle{idx})
                                obj.Table(idx,:) = [];
                                idx = [];
                                break
                        end
                    end
                    pause(.100)
                end

                if isempty(IDN)
                    idx = [];
                end
            end

            try
                if isempty(idx)
                    idx = height(obj.Table)+1;
                    switch Type
                        case {'TCPIP Socket', 'TCP/UDP IP Socket'}                    
                            hReceiver = tcpclient(IP, Port);
                            IDN = obj.ConnectionStatus(hReceiver);
                        case 'TCPIP Visa'
                            error('Not supported connection type: TCPIP Visa')
                            % hReceiver = visadev(sprintf('TCPIP::%s::INSTR', IP));
                            % hReceiver = visadev(sprintf('TCPIP::%s::%d::SOCKET', IP, Port));
                    end
                end                

                if ~isempty(IDN)
                    if contains(IDN, Tag, "IgnoreCase", true) 
                        if idx > height(obj.Table)
                            ClientIP = '';
                            if     ~isempty(Localhost_publicIP); ClientIP      = Localhost_publicIP;
                            elseif ~isempty(Localhost_localIP);  ClientIP      = Localhost_localIP;
                            elseif ~strcmp(IP, '127.0.0.1');     [~, ClientIP] = obj.IPsFind(IP);
                            end
        
                            hReceiver.UserData = struct('IDN', IDN, 'ClientIP', ClientIP, 'nTasks', 0, 'SyncMode', '', 'instrSelected', instrSelected);
                            obj.Table{idx,:}   = {Type, IDN, Socket, hReceiver, "Connected"};
        
                        elseif ~contains(instrHandles.IDN(idx), Tag, "IgnoreCase", true)
                            error('O instrumento mapeado (%s) difere do identificado (%s).', obj.Table.IDN(idx), IDN)
                        end        
                    else
                        error('O instrumento identificado (%s) difere do configurado (%s).', IDN, Tag)
                    end        
                else
                    error('Não recebida resposta à requisição "*IDN?".')
                end        
            catch ME
                msgError = ME.message;
                if (idx > height(obj.Table)) & exist('hReceiver', 'var')
                    clear hReceiver
                end
                idx = [];
            end
        end


        %-----------------------------------------------------------------%
        function obj = ReconnectAttempt(obj, instrSelected)

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
        % recriação, ou po meio da alteração do seu estado (método "connect" do objeto "TCPClient").
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



        end


        %-----------------------------------------------------------------%
        function obj = StatusUpdate(obj)
            for ii = 1:height(Handle)
                hReceiver = obj.Table.Handle{ii};

                if hReceiver.Status
                    try
                        obj.Table.Handle{ii}.NumBytesAvailable;
                    catch ME
                        ME.identifier
                    end
                end
            end
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function [IP, Port, Localhost_publicIP, Localhost_localIP] = MissingParameters(obj, instrSelected)
            % IP
            if isfield(instrSelected.Parameters, 'IP');   IP = instrSelected.Parameters.IP;
            else;                                         IP = '';
            end

            if strcmpi(IP, 'localhost');                  IP = '127.0.0.1';
            end
        
            % Port
            if isfield(instrSelected.Parameters, 'Port'); Port = instrSelected.Parameters.Port;
            else;                                         Port = [];
            end
            
            if ~isnumeric(Port);                          Port = str2double(Port);
            end
        
            % Localhost_publicIP
            if isfield(instrSelected.Parameters, 'Localhost_publicIP'); Localhost_publicIP = instrSelected.Parameters.Localhost_publicIP;
            else;                                                       Localhost_publicIP = '';
            end
        
            % Localhost_localIP
            if isfield(instrSelected.Parameters, 'Localhost_localIP');  Localhost_localIP = instrSelected.Parameters.Localhost_localIP;
            else;                                                       Localhost_localIP = '';
            end
        end


        %-----------------------------------------------------------------%
        function IDN = ConnectionStatus(obj, hReceiver)
            IDN = '';            

            % A ideia de usar writeline/readline (com loop, criando artificialmente 
            % um Timeout) é fazer duas operações de comunicações com o socket (notei 
            % que em alguns sockets desconectados, a primeira operação de escrita é realizada
            % normalmente, retornando erro apenas numa segunda operação). Isso evita, também,
            % o Timeout padrão do writeread (10 segundos).

            flush(hReceiver)
            % IDN = writeread(hReceiver, '*IDN?');
            writeline(hReceiver, '*IDN?')

            statusTic = tic;
            t = toc(statusTic);
            while t < class.Constants.idnTimeout
                if hReceiver.NumBytesAvailable
                    IDN = readline(hReceiver);
                    if ~isempty(IDN)
                        IDN = replace(deblank(IDN), {'"', ''''}, {'', ''});
                        break
                    end
                end
                t = toc(statusTic);
            end
            
            if isempty(IDN)
                error('scpiLib:EmptyIDN', 'Empty identification')
            end
        end


        %-----------------------------------------------------------------%
        function [localIP, publicIP] = IPsFind(obj, instrIP)
            [~, msg] = system('arp -a');            
            msgCell  = splitlines(msg);
            msgCell(cellfun(@(x) isempty(x), msgCell)) = [];
            
            idx_localIPs = find(cellfun(@(x) contains(x, ' --- '), msgCell));
            idx_instrIPs = find(cellfun(@(x) contains(x, [' ' instrIP ' ']), msgCell));
            
            localIP = '';
            regExp  = '(\d{1,3}[.]\d{1,3}[.]\d{1,3}[.]\d{1,3})';
            if ~isempty(idx_instrIPs)
                idx_instrIPs = idx_instrIPs(1);
                
                temp = idx_localIPs - idx_instrIPs;
                idx  = find(temp<0);
                idx  = idx(end);
                        
                localIP  = char(regexp(msgCell{idx_localIPs(idx)}, regExp, 'match'));
                publicIP = localIP;
                
            else
                localIPs = {};
                for ii = 1:numel(idx_localIPs)
                    localIPs = [localIPs, regexp(msgCell{idx_localIPs(ii)}, regExp, 'match')];
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