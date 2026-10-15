classdef ReceiverDriverTSMW < model.ReceiverDriver

    %---------------------------------------------------------------------%
    % ## model.ReceiverDriverTSMW ##
    %
    % Driver do R&S TSMW ("connection.protocol": "json"). Difere de 
    % model.ReceiverDriver porque as requisições e as respostas são objetos
    % JSON (ver class.TSMWLib), e não texto SCPI:
    %
    % - composeCommand: os "write" dos parâmetros são membros JSON (ex.: 
    %   "startFrequency":%freqStart%) reunidos em "ARGS"; "code" e "request"
    %   do comando definem "CODE" e "COMMAND";
    % - readResponse: descarta os "ACK" e as linhas que não trazem os dados do
    %   comando requisitado;
    % - parseIdentification, parseBandConfig, fetchTraceData e fetchGps: leem as
    %   chaves da resposta (o "read" de cada parâmetro é a chave em "sweepSettings").
    %
    % O modo de leitura continua sendo "polling" (ver TaskController).
    %---------------------------------------------------------------------%

    properties (Constant, Access = private)
        % Parâmetros que o TSMW recebe como booleanos JSON (true|false).
        BOOLEAN_PARAMETERS = {'sensitivityMode', 'preamp', 'attenuationMode'}
    end


    methods
        %-----------------------------------------------------------------%
        function obj = ReceiverDriverTSMW(definition, receiverHandle)
            arguments
                definition (1, 1) struct
                receiverHandle = []
            end

            obj@model.ReceiverDriver(definition, receiverHandle);
        end

        %-----------------------------------------------------------------%
        function params = bandParameters(obj, rawBand, freqStart, freqStop, syncMode)
            arguments
                obj
                rawBand
                freqStart
                freqStop
                syncMode = ''
            end

            params = bandParameters@model.ReceiverDriver(obj, rawBand, freqStart, freqStop, syncMode);

            for name = obj.BOOLEAN_PARAMETERS
                params.(name{1}) = booleanText(params.(name{1}));
            end
        end

        %-----------------------------------------------------------------%
        function traceData = fetchTraceData(obj)
            response = request(obj, obj.Definition.communication.fetch.traceData, class.Constants.Timeout);

            traceData = [];
            if ~isempty(response)
                traceData = class.TSMWLib.decodeTrace(class.TSMWLib.parseResponse(response));
            end
        end

        %-----------------------------------------------------------------%
        function value = usesDriverGps(~)
            value = true;
        end

        %-----------------------------------------------------------------%
        function gps = fetchGps(obj, gps)
            response = request(obj, obj.Definition.communication.fetch.gpsData, class.Constants.Timeout);

            if ~isempty(response)
                gps = class.TSMWLib.parseGps(class.TSMWLib.parseResponse(response), gps);
            end
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function response = request(obj, text, timeout)
            flush(obj.Handle)
            sendCommand(obj, text)
            response = readJsonResponse(obj, timeout, class.TSMWLib.responseKey(text));
        end

        %-----------------------------------------------------------------%
        function response = readResponse(obj, timeout)
            response = readJsonResponse(obj, timeout, '');
        end

        %-----------------------------------------------------------------%
        function idn = parseIdentification(~, response)
            idn = class.TSMWLib.parseIdentification(class.TSMWLib.parseResponse(response));
        end

        %-----------------------------------------------------------------%
        function answer = parseBandConfig(obj, response)
            settings = class.TSMWLib.parseSettings(class.TSMWLib.parseResponse(response));
            if isempty(fieldnames(settings))
                error('ReceiverLib:EmptySettings', 'A resposta do TSMW não traz os parâmetros da varredura ("%s").', class.TSMWLib.SETTINGS_KEY)
            end

            parameters = model.ReceiverDriver.parametersOf(obj.Definition);

            % Apenas os parâmetros com "read" (chave em "sweepSettings") presentes
            % na resposta são devolvidos.
            answer = struct();
            for parameterName = bandConfigParameterNames(obj)'
                parameterIdx = find(strcmp({parameters.name}, parameterName{1}), 1);

                if ~isempty(parameterIdx)
                    key = parameters(parameterIdx).read;
                    if ~isempty(key) && isfield(settings, key)
                        answer.(parameterName{1}) = settings.(key);
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function text = composeCommand(obj, command, params)
            [parts, isActive] = composeParts(obj, command, params);

            text = '';
            if ~isActive
                return
            end

            if isempty(command.code) || isempty(command.request)
                error('ReceiverLib:MissingRequest', 'O comando "%s" não define "code" e "request".', command.name)
            end

            args = '';
            if ~isempty(parts)
                args = strjoin(parts, ',');
            end

            text = class.TSMWLib.buildRequest(command.code, command.request, args);
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function response = readJsonResponse(obj, timeout, key)
            % Retorna a primeira linha de dados, ignorando "ACK" e, se "key" for
            % informada, as linhas que não a contêm. '' se não houver no prazo.

            response = '';

            statusTic = tic;
            while toc(statusTic) < timeout
                if obj.Handle.NumBytesAvailable
                    line = strtrim(readline(obj.Handle));

                    if (strlength(line) > 0) && ~class.TSMWLib.isAck(line) && (isempty(key) || contains(line, ['"' key '"']))
                        response = line;
                        return
                    end

                else
                    pause(.001)
                end
            end
        end
    end
end


%-------------------------------------------------------------------------%
function text = booleanText(value)
    number = str2double(string(value));

    text = 'false';
    if ~isnan(number) && (number ~= 0)
        text = 'true';
    end
end
