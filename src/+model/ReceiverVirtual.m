classdef ReceiverVirtual < handle

    %---------------------------------------------------------------------%
    % ## model.ReceiverVirtual ##
    %
    % Receptor virtual para testar o appColeta sem hardware: servidor TCP
    % (tcpserver) que responde aos comandos SCPI de "config/ReceiverLib/<name>.json"
    % e, no caso do R&S EB500, transmite os traços por datagramas UDP no
    % formato lido por class.EB500Lib. O traço gerado é ruído gaussiano.
    %
    % Deve ser executado em outra sessão do MATLAB, que precisa ficar ociosa 
    % (prompt livre ou "pause") para que os callbacks sejam processados.
    %
    % v = model.ReceiverVirtual("R&S FSL");                                 % nome do instrumento
    % v = model.ReceiverVirtual("C:\...\R&S FSL.json", Port=5026);          % arquivo JSON
    % delete(v)                                                             % encerra o servidor
    %---------------------------------------------------------------------%

    properties (SetAccess = private)
        Models
        Tag
        Address
        Port
        Server
        State = struct()
        Log = {}

        StreamTimer
        StreamSocket
        StreamTarget = struct('Address', "", 'Port', 0, 'Mode', '')
        DatagramId = 0
        SelectivityMap
    end


    properties
        Verbose (1, 1) logical = true
        TracePeriod (1, 1) double = 0.2
        PointsPerDatagram (1, 1) double = 500
    end


    properties (Constant, Access = private)
        MAGIC_NUMBER = 963072
        TERMINATOR_MARK = 2000
    end


    methods
        %-----------------------------------------------------------------%
        function obj = ReceiverVirtual(source, options)
            arguments
                source
                options.Address (1, 1) string = "127.0.0.1"
                options.Port double = []
                options.RootFolder (1, 1) string = ""
                options.Verbose (1, 1) logical = true
            end

            rootFolder = options.RootFolder;
            if rootFolder == ""
                rootFolder = fileparts(fileparts(mfilename('fullpath')));
            end

            definitions = loadDefinitions(source, rootFolder);

            obj.Verbose = options.Verbose;
            obj.Tag     = definitions{1}.tag;
            obj.Address = options.Address;
            obj.Port    = options.Port;
            if isempty(obj.Port)
                obj.Port = definitions{1}.connection.defaultPort;
            end

            obj.Models = compileModels(definitions);
            obj.State  = defaultState(obj.Models);

            if any(arrayfun(@(x) isfield(x.Patterns, 'setBandConfig') && ismember('selectivity', x.Patterns.setBandConfig.Names), obj.Models))
                obj.SelectivityMap = class.EB500Lib(char(rootFolder)).SelectivityMap;
            end

            obj.Server = tcpserver(obj.Address, obj.Port, 'Timeout', 1, ...
                'ConnectionChangedFcn', @(src, ~) onConnectionChanged(obj, src));
            configureTerminator(obj.Server, 'LF')
            configureCallback(obj.Server, 'terminator', @(src, ~) processCommands(obj, src))

            logMessage(obj, 'INFO', sprintf('%s (virtual) em %s:%d', obj.Tag, obj.Address, obj.Port))
        end

        %-----------------------------------------------------------------%
        function delete(obj)
            stopStreaming(obj)

            if ~isempty(obj.StreamSocket)
                delete(obj.StreamSocket)
            end

            if ~isempty(obj.Server)
                configureCallback(obj.Server, 'off')
                delete(obj.Server)
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function onConnectionChanged(obj, src)
            if src.Connected
                logMessage(obj, 'INFO', sprintf('Cliente conectado: %s:%d', src.ClientAddress, src.ClientPort))
            else
                logMessage(obj, 'INFO', 'Cliente desconectado')
                stopStreaming(obj)
            end
        end

        %-----------------------------------------------------------------%
        function processCommands(obj, src)
            while src.NumBytesAvailable > 0
                line = readline(src);
                if isempty(line)
                    break
                end

                try
                    handleCommand(obj, src, char(line))
                catch ME
                    logMessage(obj, 'ERRO', sprintf('%s (%s)', ME.message, char(line)))
                end
            end
        end

        %-----------------------------------------------------------------%
        function handleCommand(obj, src, line)
            command = normalizeCommand(line);
            if isempty(command)
                return
            end
            logMessage(obj, 'RX', line)

            exactKinds = {'queryIdentification', 'queryStatus', 'queryBandConfig', 'queryAttenuation', ...
                          'fetchTraceData', 'initReset', 'initStartup'};

            for modelIdx = 1:numel(obj.Models)
                legacy = obj.Models(modelIdx).Definition.communication.legacy;

                for kind = exactKinds
                    if ~isempty(legacy.(kind{1})) && strcmp(command, normalizeCommand(legacy.(kind{1})))
                        replyExact(obj, src, kind{1}, modelIdx)
                        return
                    end
                end
            end

            rawCommand = strtrim(regexprep(line, '^\s*:', ''));
            for modelIdx = 1:numel(obj.Models)
                patterns = obj.Models(modelIdx).Patterns;

                for kind = fieldnames(patterns)'
                    tokens = regexp(rawCommand, patterns.(kind{1}).Regexp, 'names', 'once', 'ignorecase');

                    if isstruct(tokens) && ~isempty(tokens) && ~isempty(fieldnames(tokens))
                        updateState(obj, tokens)
                        return
                    end
                end
            end

            udpTokens = regexp(rawCommand, '^TRACE:UDP:TAG:(ON|OFF)\s+"([^"]*)"\s*,\s*(\d+)\s*,\s*(\w+)', 'tokens', 'once', 'ignorecase');
            if ~isempty(udpTokens)
                if strcmpi(udpTokens{1}, 'ON')
                    startStreaming(obj, udpTokens{2}, str2double(udpTokens{3}), upper(udpTokens{4}))
                else
                    stopStreaming(obj)
                end
                return
            end

            if startsWith(command, 'trace:udp:del') 
                stopStreaming(obj)
                return
            end

            gpsText = gpsReply(obj, command);
            if ~isempty(gpsText)
                reply(obj, src, gpsText)
                return
            end

            if ~endsWith(command, '?')
                return
            end
            logMessage(obj, 'AVISO', sprintf('Consulta não reconhecida: %s', line))
        end

        %-----------------------------------------------------------------%
        function replyExact(obj, src, kind, modelIdx)
            switch kind
                case 'queryIdentification'
                    manufacturer = upper(extractBefore(obj.Models(modelIdx).Definition.name, ' '));
                    reply(obj, src, sprintf('%s VIRTUAL,%s,B000000,1.000', manufacturer, obj.Tag))

                case 'queryStatus'
                    reply(obj, src, '0,"No error"')

                case 'queryBandConfig'
                    names  = obj.Models(modelIdx).BandParameterNames;
                    values = cellfun(@(x) obj.State.(x), names, 'UniformOutput', false);
                    reply(obj, src, strjoin(values, ';'))

                case 'queryAttenuation'
                    reply(obj, src, obj.State.attenuationValue)

                case 'fetchTraceData'
                    replyTrace(obj, src)

                case 'initReset'
                    obj.State = defaultState(obj.Models);
            end
        end

        %-----------------------------------------------------------------%
        function reply(obj, src, text)
            logMessage(obj, 'TX', text)
            writeline(src, text)
        end

        %-----------------------------------------------------------------%
        function replyTrace(obj, src)
            traceData = single(baseLevel(obj) + 3 .* randn(1, traceLength(obj)));
            payload   = typecast(traceData, 'uint8');

            digits = sprintf('%d', numel(payload));
            header = uint8(sprintf('#%d%s', numel(digits), digits));

            logMessage(obj, 'TX', sprintf('bloco binário (%d pontos)', numel(traceData)))
            
            pause(.200) % 200ms
            write(src, [header, payload, uint8(10)], 'uint8')
        end

        %-----------------------------------------------------------------%
        function updateState(obj, tokens)
            names = fieldnames(tokens);
            for ii = 1:numel(names)
                if ~ismember(names{ii}, {'videoBandWidthCommand', 'autoLevel'})
                    obj.State.(names{ii}) = char(tokens.(names{ii}));
                end
            end

            % No EB500 a resolução decorre da seletividade e do passo.
            if ~isempty(obj.SelectivityMap) && ismember(obj.State.selectivity, obj.SelectivityMap.Properties.VariableNames)
                stepWidth = str2double(obj.State.stepWidth);

                if stepWidth > 0
                    stepsHz = str2double(extractBefore(obj.SelectivityMap.Properties.RowNames, ' kHz')) .* 1000;
                    [~, rowIdx] = min(abs(stepsHz - stepWidth));
                    obj.State.resolutionValue = num2str(obj.SelectivityMap{rowIdx, obj.State.selectivity});
                end
            end
        end

        %-----------------------------------------------------------------%
        function n = traceLength(obj)
            n = round(str2double(obj.State.dataPoints));

            if ~(n > 0)
                limits = obj.Models(1).Definition.features.dataPoints;
                n = 501;
                if isnumeric(limits) && ~isempty(limits)
                    n = floor(limits(1));
                end
            end
        end

        %-----------------------------------------------------------------%
        function level = baseLevel(obj)
            if contains(upper(obj.State.levelUnit), 'DBUV')
                level = 27;
            elseif contains(obj.Tag, 'EB500')
                level = 20;
            else
                level = -80;
            end
        end

        %-----------------------------------------------------------------%
        function text = gpsReply(obj, command)
            % As requisições abaixo são as usadas em model.GPS.queryReceiverGPS.

            text   = '';
            utcNow = datetime('now', 'TimeZone', 'UTC');

            switch command
                case 'system:gps:data?'
                    if contains(obj.Tag, 'EB500')
                        text = sprintf('GPS,1,0,74,11,S,12,59,35.50,W,38,27,49.10,%d,%d,%d,%d,%d,%d,0.00,0.00,338.50,940.00,1,-8.00', ...
                            year(utcNow), month(utcNow), day(utcNow), hour(utcNow), minute(utcNow), floor(second(utcNow)));
                    else
                        text = sprintf('"12 59.59167 S,38 27.78500 W,26,%sZ"', char(utcNow, 'yyyy-MM-dd HH:mm:ss'));
                    end

                case 'fetch:gps?'
                    text = sprintf('GOOD FIX,%s,-0.2267732173,-0.6713082194', upper(char(datetime(utcNow, 'Format', 'eee MMM dd HH:mm:ss yyyy', 'Locale', 'en_US'))));

                case 'system:gpsinfo?'
                    text = sprintf('-38.463093,-12.993198,40,%s', char(utcNow, 'MMddyyyy,HH:mm:ss'));

                case {'system:gps:status?;:system:gps:position?', 'system:gps:position?'}
                    text = 'GOOD;-12.993198,-38.463093';
            end
        end

        %-----------------------------------------------------------------%
        function startStreaming(obj, address, port, mode)
            if isempty(address)
                address = obj.Server.ClientAddress;
            end

            switch mode
                case 'PSCAN'
                    streamMode = 'PSCAN';
                case 'DFPAN'
                    streamMode = 'DFPAN';
                otherwise
                    logMessage(obj, 'AVISO', sprintf('Modo UDP não suportado: %s', mode))
                    return
            end

            obj.StreamTarget = struct('Address', string(address), 'Port', port, 'Mode', streamMode);

            if isempty(obj.StreamSocket)
                obj.StreamSocket = udpport('datagram', 'IPV4', 'OutputDatagramSize', 65507);
            end

            if isempty(obj.StreamTimer) || ~isvalid(obj.StreamTimer)
                obj.StreamTimer = timer('ExecutionMode', 'fixedSpacing', 'BusyMode', 'drop', ...
                    'Period', obj.TracePeriod, 'TimerFcn', @(~, ~) streamTick(obj));
            end

            if strcmp(obj.StreamTimer.Running, 'off')
                start(obj.StreamTimer)
            end
            logMessage(obj, 'INFO', sprintf('Transmissão UDP (%s) para %s:%d', streamMode, address, port))
        end

        %-----------------------------------------------------------------%
        function stopStreaming(obj)
            if ~isempty(obj.StreamTimer) && isvalid(obj.StreamTimer)
                stop(obj.StreamTimer)
                delete(obj.StreamTimer)
            end

            obj.StreamTimer = [];
            obj.StreamTarget.Mode = '';
        end

        %-----------------------------------------------------------------%
        function streamTick(obj)
            try
                switch obj.StreamTarget.Mode
                    case 'PSCAN'
                        datagrams = buildPscanTrace(obj);
                    case 'DFPAN'
                        datagrams = {buildDfDatagram(obj)};
                    otherwise
                        return
                end

                for ii = 1:numel(datagrams)
                    write(obj.StreamSocket, datagrams{ii}, 'uint8', obj.StreamTarget.Address, obj.StreamTarget.Port)
                end

            catch ME
                logMessage(obj, 'ERRO', sprintf('Transmissão UDP: %s', ME.message))
                stopStreaming(obj)
            end
        end

        %-----------------------------------------------------------------%
        function datagrams = buildPscanTrace(obj)
            % Cabeçalho de 48 bytes; os níveis (int16, dB*10, big-endian) ficam
            % no fim do datagrama e o último termina com a marca 2000.

            freqStart = str2double(obj.State.freqStart);
            freqStop  = str2double(obj.State.freqStop);
            stepWidth = round(str2double(obj.State.stepWidth));

            if ~(stepWidth > 0 && freqStop > freqStart)
                error('Banda não configurada.')
            end

            nPoints = round((freqStop - freqStart)/stepWidth) + 1;
            levels  = int16(round(10 .* (baseLevel(obj) + 2 .* randn(1, nPoints))));

            firstIdx  = 1:obj.PointsPerDatagram:nPoints;
            datagrams = cell(1, numel(firstIdx));

            for ii = 1:numel(firstIdx)
                idx    = firstIdx(ii):min(firstIdx(ii) + obj.PointsPerDatagram - 1, nPoints);
                isLast = (ii == numel(firstIdx));

                payload    = bigEndian(int16(levels(idx)));
                countField = numel(idx);
                if isLast
                    payload    = [payload, bigEndian(uint16(obj.TERMINATOR_MARK))];
                    countField = countField + 1;
                end

                header = zeros(1, 48, 'uint8');
                header( 1: 4) = bigEndian(uint32(obj.MAGIC_NUMBER));
                header( 9:10) = bigEndian(uint16(mod(obj.DatagramId, 2^16)));
                header(11:12) = bigEndian(uint16(floor(obj.DatagramId / 2^16)));
                header(13:16) = bigEndian(uint32(numel(header) + numel(payload)));
                header(21:22) = bigEndian(uint16(countField));
                header(29:32) = bigEndian(uint32(mod(freqStart, 2^32)));
                header(33:36) = bigEndian(uint32(mod(freqStop,  2^32)));
                header(37:40) = bigEndian(uint32(stepWidth));
                header(41:44) = bigEndian(uint32(floor(freqStart / 2^32)));
                header(45:48) = bigEndian(uint32(floor(freqStop  / 2^32)));

                datagrams{ii} = [header, payload];
                obj.DatagramId = obj.DatagramId + 1;
            end
        end

        %-----------------------------------------------------------------%
        function datagram = buildDfDatagram(obj)
            % Cabeçalho de 142 bytes seguido dos vetores nível, azimute e 
            % qualidade (int16, valor*10, big-endian).

            freqCenter = str2double(obj.State.freqCenter);
            freqSpan   = str2double(obj.State.freqSpan);
            stepWidth  = str2double(obj.State.stepWidth);

            if ~(stepWidth > 0 && freqSpan > 0)
                error('Banda não configurada.')
            end

            nPoints = round(freqSpan/stepWidth) + 1;

            level   = int16(round(10 .* (baseLevel(obj) + 2 .* randn(1, nPoints))));
            azimuth = int16(round(10 .* (360 .* rand(1, nPoints))));
            quality = int16(round(10 .* (100 .* rand(1, nPoints))));
            payload = [bigEndian(level), bigEndian(azimuth), bigEndian(quality)];

            header = zeros(1, 142, 'uint8');
            header(  1:  4) = bigEndian(uint32(obj.MAGIC_NUMBER));
            header( 13: 16) = bigEndian(uint32(numel(header) + numel(payload)));
            header( 21: 22) = bigEndian(uint16(nPoints));
            header( 29: 32) = bigEndian(uint32(mod(freqCenter, 2^32)));
            header( 33: 36) = bigEndian(uint32(floor(freqCenter / 2^32)));
            header( 37: 40) = bigEndian(uint32(freqSpan));
            header( 93: 94) = bigEndian(int16(1));
            header( 97: 98) = bigEndian(int16('S'));
            header( 99:100) = bigEndian(int16(12));
            header(101:104) = bigEndian(single(59.59167));
            header(105:106) = bigEndian(int16('W'));
            header(107:108) = bigEndian(int16(38));
            header(109:112) = bigEndian(single(27.785));

            datagram = [header, payload];
        end

        %-----------------------------------------------------------------%
        function logMessage(obj, direction, text)
            obj.Log{end+1} = sprintf('%s [%s] %s', char(datetime('now', 'Format', 'HH:mm:ss.SSS')), direction, text);
            obj.Log = obj.Log(max(1, end-499):end);

            if obj.Verbose
                fprintf('%s\n', obj.Log{end})
            end
        end
    end
end


%-------------------------------------------------------------------------%
function definitions = loadDefinitions(source, rootFolder)
    if isstruct(source)
        definitions = {source};
        return
    end

    filePath = char(source);
    if ~isfile(filePath)
        filePath = fullfile(rootFolder, 'config', 'ReceiverLib', [filePath '.json']);
    end

    % O arquivo do R&S EB500 tem um array com os registros RX e DF.
    records = jsondecode(fileread(filePath));
    if isstruct(records)
        records = num2cell(records);
    end
    definitions = records(:)';
end

%-------------------------------------------------------------------------%
function models = compileModels(definitions)
    models = struct('Definition', {}, 'Patterns', {}, 'BandParameterNames', {});

    for ii = 1:numel(definitions)
        legacy = definitions{ii}.communication.legacy;

        patterns = struct();
        for kind = {'setBandConfig', 'setAttenuation', 'initSweepMode'}
            if ~isempty(legacy.(kind{1}))
                patterns.(kind{1}) = compileTemplate(legacy.(kind{1}));
            end
        end

        steps    = definitions{ii}.communication.set;
        commands = steps(strcmp({steps.step}, 'acquisition')).commands;

        models(ii).Definition         = definitions{ii};
        models(ii).Patterns           = patterns;
        models(ii).BandParameterNames = commands(strcmp({commands.name}, 'bandConfig')).parameterNames;
    end
end

%-------------------------------------------------------------------------%
function compiled = compileTemplate(template)
    % Converte "%param%" em grupos nomeados de uma expressão regular.

    tokens    = regexp(template, '%(\w+)%', 'tokens');
    names     = cellfun(@(x) x{1}, tokens, 'UniformOutput', false);
    literals  = regexp(template, '%\w+%', 'split');
    numerics  = numericTokens();

    expression = '^\s*';
    for ii = 1:numel(literals)
        expression = [expression, regexptranslate('escape', literals{ii})]; %#ok<AGROW>

        if ii <= numel(names)
            if ismember(names{ii}, numerics)
                groupPattern = '[-+0-9.eE]*';
            else
                groupPattern = '.*?';
            end
            expression = [expression, sprintf('(?<%s>%s)', names{ii}, groupPattern)]; %#ok<AGROW>
        end
    end

    compiled = struct('Regexp', [expression, '\s*$'], 'Names', {names});
end

%-------------------------------------------------------------------------%
function names = numericTokens()
    names = {'averageMode', 'averageCount', 'freqStart', 'freqStop', 'freqCenter', 'freqSpan', ...
             'dataPoints', 'stepWidth', 'resolutionMode', 'resolutionValue', 'preamp', ...
             'attenuationMode', 'attenuationValue', 'sampleTimeMode', 'sampleTimeValue', ...
             'dfSquelchValue', 'dfMeasTime'};
end

%-------------------------------------------------------------------------%
function state = defaultState(models)
    state = struct();

    for ii = 1:numel(models)
        for jj = 1:numel(models(ii).BandParameterNames)
            state.(models(ii).BandParameterNames{jj}) = '0';
        end

        for kind = fieldnames(models(ii).Patterns)'
            for name = models(ii).Patterns.(kind{1}).Names
                state.(name{1}) = '0';
            end
        end
    end

    for name = {'dataPoints', 'levelUnit', 'attenuationValue', 'freqStart', 'freqStop', 'freqCenter', 'freqSpan', 'stepWidth', 'selectivity'}
        if ~isfield(state, name{1})
            state.(name{1}) = '0';
        end
    end
    state.sampleTimeValue = '0.01';
end

%-------------------------------------------------------------------------%
function command = normalizeCommand(text)
    command = lower(strtrim(regexprep(char(text), '^\s*:', '')));
end

%-------------------------------------------------------------------------%
function bytes = bigEndian(values)
    bytes = typecast(swapbytes(values), 'uint8');
end
