classdef InstrumentBase < handle

    properties
        %-----------------------------------------------------------------%
        Type {mustBeMember(Type, {'Receiver', 'Gps'})} = 'Receiver'
        Config
        Registry
        Session = table( ...
            'Size', [0, 4], ...
            'VariableTypes', {'string', 'string', 'cell', 'string'}, ...
            'VariableNames', {'Family', 'Socket', 'Handle', 'Status'} ...
        )
    end


    properties (Access = private, Constant)
        %-----------------------------------------------------------------%
        REGISTRY_FILE = 'InstrumentList-v2.json'
        RECEIVER_FILE = 'ReceiverLib-v2.json'
        GPS_FILE      = 'GpsLib-v2.json'
    end


    methods
        %-----------------------------------------------------------------%
        function obj = InstrumentBase(type, rootFolder)
            appName = class.Constants.appName;
            [projectFolder, localCacheFolder] = appEngine.util.Path(appName, rootFolder);

            obj.Type = type;

            configFile = obj.(upper([type '_FILE']));
            obj.Config = model.InstrumentBase.readConfigFile(projectFolder, localCacheFolder, configFile);
            
            registryFile = obj.REGISTRY_FILE;
            obj.Registry = model.InstrumentBase.readRegistryFile(projectFolder, localCacheFolder, registryFile, type);

            if ~isdeployed()
                arrayfun(@(x) delete(x), tcpclientfind())
                arrayfun(@(x) delete(x), udpportfind())
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function msgError = reconnectAttempt(obj, instrument, connectFlag, StartUp, SpecificSCPI)
            [idx, msgError] = connect(obj, instrument);

            % Se ocorrer alguma queda de energia e o receptor desligar, ao
            % religar, o receptor voltará às suas configurações de fábrica,
            % o que demandará, portanto, a sua reconfiguração (FreqStart,
            % FreqStop, Resolution etc).

            if isempty(msgError)
                try
                    hReceiver = obj.Session.Handle{idx};

                    if ismember(connectFlag, [2, 3])
                        class.EB500Lib.OperationMode(hReceiver, connectFlag)
                    end
    
                    writeline(hReceiver, StartUp);
                    pause(.001)
    
                    writeline(hReceiver, SpecificSCPI.configSET);
                    pause(.001)
                    
                    if ~isempty(SpecificSCPI.attSET)
                        writeline(hReceiver, SpecificSCPI.attSET);
                    end
    
                catch ME
                    msgError = ME.message;
                end
            end
        end

        %-----------------------------------------------------------------%
        function [index, msgError] = connect(obj, connectionType, instrumentParameters)
            instrumentParameters = model.InstrumentBase.validateParameters(instrumentParameters);
            instrumentSocket = model.InstrumentBase.getSocket(instrumentParameters.ip, instrumentParameters.port);

            index = find(strcmp(obj.Session.Socket, instrumentSocket), 1);
            msgError = '';
            

            if ~isempty(index)
                hReceiver = obj.Session.Handle{index};

                for ii = 1:3
                    try
                        hTransport = struct(struct(hReceiver).TCPCustomClient).Transport;
                        if ~hTransport.Connected
                            hTransport.connect
                        end
                        break

                    catch ME
                        switch ME.identifier
                            case 'network:tcpclient:connectFailed'
                                msgError = ME.message;
                                obj.Session.Status(index) = "Disconnected";
                                return

                            case {'MATLAB:class:InvalidHandle', 'testmeaslib:CustomDisplay:PropertyError'}
                                delete(obj.Session.Handle{index})
                                obj.Session(index, :) = [];
                                index = [];
                                break
                        end
                    end
                    pause(.100)
                end
            end

            try
                if isempty(index)
                    index = height(obj.Session) + 1;
                    switch connectionType
                        case {'TCPIP Socket', 'TCP/UDP IP Socket'}                    
                            hReceiver = tcpclient(IP, Port);
                            configureTerminator(hReceiver, instrumentParameters.terminator)
                        otherwise
                            error('appColetaV2 supports only TCPIP Socket connection type.')
                            % hReceiver = visadev(sprintf('TCPIP::%s::INSTR', IP));
                            % hReceiver = visadev(sprintf('TCPIP::%s::%d::SOCKET', IP, Port));
                    end
                    hReceiver.Timeout = Timeout;
                end

            catch ME
                msgError = ME.message;
                if (index > height(obj.Session)) & exist('hReceiver', 'var')
                    clear hReceiver
                end
                index = [];
            end
        end
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function socket = getSocket(ip, port)
            if strcmpi(ip, 'localhost')
                ip = '127.0.0.1';
            end
            socket = sprintf('%s:%d', ip, port);
        end

        %-----------------------------------------------------------------%
        function configTable = readConfigFile(projectFolder, localCacheFolder, configFile)
            try
                configList = jsondecode(fileread(fullfile(localCacheFolder, configFile)));
            catch ME
                configList = jsondecode(fileread(fullfile(projectFolder, configFile)));
            end

            configTable = table( ...
                configList.instrumentNames, ...
                repmat(structUtil.createStructFromCell(configList.configFileKeys), numel(configList.instrumentNames), 1), ...
                false(numel(configList.instrumentNames), 1), ...
                'VariableNames', {'InstrumentID', 'CachedConfig', 'IsConfigLoaded'} ...
            );

            configTable.InstrumentID(1:numel(configList.instrumentNames)) = configList.instrumentNames;
        end

        %-----------------------------------------------------------------%
        function registryList = readRegistryFile(projectFolder, localCacheFolder, registryFile, type)
            try
                registryList = model.InstrumentBase.loadRegistryFromFile(fullfile(localCacheFolder, registryFile));
            catch ME
                registryList = model.InstrumentBase.loadRegistryFromFile(fullfile(projectFolder, registryFile));
            end

            registryList(~strcmp(registryList.Family, type), :) = [];
            if strcmp(type, 'Receiver')
                if ~isempty(registryList)
                    if ~any([registryList.Enable])
                        registryList.Enable(1) = 1;
                    end
                else
                    registryList(end+1,:) = model.InstrumentBase.getDefaultReceiver();
                end
            end
        end

        %-----------------------------------------------------------------%
        function registry = loadRegistryFromFile(registryFile)
            registry = jsondecode(fileread(registryFile));
        
            for ii = numel(registry):-1:1
                switch registry(ii).Type
                    case 'Serial';       essentialFields = {'Port', 'BaudRate'};
                    case 'TCPIP Socket'; essentialFields = {'IP', 'Port'};
                    otherwise;           essentialFields = {};
                end
            
                if ~all(ismember(essentialFields, fields(registry(ii).Parameters)))
                    registry(ii) = [];
                else
                    registry(ii).Parameters = jsonencode(registry(ii).Parameters);
                end                    
            end
            
            registry = struct2table(registry, 'AsArray', true);
        end

        %-----------------------------------------------------------------%
        function defaultReceiver = getDefaultReceiver()
            defaultReceiver = { ...
                'Receiver', ...
                'Tektronix SA2500', ...
                'TCPIP Socket', ...
                '{"IP":"127.0.0.1","Port":"34835","Timeout":5}', ...
                'Modo servidor/cliente. Loopback (127.0.0.1).', ...
                true...
            };
        end

        %-----------------------------------------------------------------%
        function parameters = validateParameters(parameters)
            parametersToCheck = {
                'ip';
                'port';
                'baudRate';
                'timeout';
                'localHostPublicIP';
                'localHostPrivateIP'
            };

            for ii = 1:numel(parametersToCheck)
                field = parametersToCheck{ii};

                if isfield(parameters, field)
                    switch field
                        case 'ip'
                            if strcmpi(parameters.ip, 'localhost')
                                parameters.ip = '127.0.0.1';
                            end
                        case 'port'
                            if ~isnumeric(parameters.port)
                                parameters.port = str2double(parameters.port);
                            end
                    end
                else
                    parameters.(field) = '';
                end
            end
        end
    end

end