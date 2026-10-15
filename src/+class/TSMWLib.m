classdef TSMWLib

    %---------------------------------------------------------------------%
    % ## class.TSMWLib ##
    %
    % Codec do protocolo do receptor Rohde & Schwarz TSMW (EtherDLL): monta
    % as requisições e interpreta as respostas, trocadas como JSON em linhas.
    % A classe não abre socket nem mantém estado; a comunicação é feita por
    % model.ReceiverDriverTSMW, a partir de "resources/ReceiverLib/R&S TSMW.json".
    %
    % Requisição: {"CODE":<n>,"COMMAND":"<nome>","ARGS":{...}}
    % Respostas : linhas com a chave "ACK" são apenas confirmações de recebimento;
    %             as demais trazem os dados, em chaves próprias de cada comando:
    %             "message" (*idn?), "sweepSettings" (getSettings), 
    %             "spectrumDbmBase64" (startPowerScanMeasurement) e 
    %             "latitude"/"longitude"/"altitude" (gpsGetLocation).
    %---------------------------------------------------------------------%

    properties (Constant)
        IDN_KEY      = 'message'
        SETTINGS_KEY = 'sweepSettings'
        TRACE_KEY    = 'spectrumDbmBase64'
    end


    methods (Static)
        %-----------------------------------------------------------------%
        function text = buildRequest(code, command, members)
            % "members" são os membros de "ARGS" já em texto JSON (ex.:
            % '"a":1,"b":true'). Não são reserializados para preservar o formato
            % numérico (88000000, e não 8.8E+7); a sintaxe é validada.

            arguments
                code (1, 1) double
                command (1, :) char
                members (1, :) char = ''
            end

            try
                jsondecode(['{' members '}']);
            catch ME
                error('ReceiverLib:InvalidRequest', 'Argumentos do comando "%s" inválidos: %s', command, ME.message)
            end

            text = sprintf('{"CODE":%d,"COMMAND":"%s","ARGS":{%s}}', code, command, members);
        end

        %-----------------------------------------------------------------%
        function value = isAck(line)
            value = contains(line, '"ACK"');
        end

        %-----------------------------------------------------------------%
        function key = responseKey(request)
            % Chave que identifica a resposta de dados de cada comando. Retorna
            % '' para comandos desconhecidos, cuja resposta não é filtrada.

            key = '';

            command = lower(string(jsondecode(char(request)).COMMAND));
            switch command
                case "*idn?"
                    key = class.TSMWLib.IDN_KEY;
                case "getsettings"
                    key = class.TSMWLib.SETTINGS_KEY;
                case "startpowerscanmeasurement"
                    key = class.TSMWLib.TRACE_KEY;
                case "gpsgetlocation"
                    key = 'latitude';
            end
        end

        %-----------------------------------------------------------------%
        function payload = parseResponse(line)
            try
                payload = jsondecode(char(line));
            catch ME
                error('ReceiverLib:InvalidResponse', 'Resposta do TSMW não é um JSON válido: %s', ME.message)
            end

            if ~isstruct(payload)
                error('ReceiverLib:InvalidResponse', 'Resposta do TSMW não é um objeto JSON.')
            end
        end

        %-----------------------------------------------------------------%
        function idn = parseIdentification(payload)
            idn = '';

            if isfield(payload, class.TSMWLib.IDN_KEY)
                idn = strtrim(char(string(payload.(class.TSMWLib.IDN_KEY))));
            end
        end

        %-----------------------------------------------------------------%
        function settings = parseSettings(payload)
            settings = struct();

            if isfield(payload, class.TSMWLib.SETTINGS_KEY) && isstruct(payload.(class.TSMWLib.SETTINGS_KEY))
                settings = payload.(class.TSMWLib.SETTINGS_KEY);
            end
        end

        %-----------------------------------------------------------------%
        function trace = decodeTrace(payload)
            % O traço é um vetor de "single" (IEEE 754, little-endian) em dBm,
            % codificado em Base64. Retorna [] se a resposta não o traz.

            trace = [];

            if isfield(payload, class.TSMWLib.TRACE_KEY) && ~isempty(payload.(class.TSMWLib.TRACE_KEY))
                spectrumRaw = matlab.net.base64decode(payload.(class.TSMWLib.TRACE_KEY));
                trace = reshape(typecast(uint8(spectrumRaw), 'single'), 1, []);
            end
        end

        %-----------------------------------------------------------------%
        function gps = parseGps(payload, gps)
            % Preenche "gps" (ver model.GPS.DEFAULT). A posição só é válida
            % se informada e diferente de (0, 0), valor reportado sem fix.

            if all(isfield(payload, {'latitude', 'longitude'}))
                latitude  = double(payload.latitude);
                longitude = double(payload.longitude);

                if isscalar(latitude) && isscalar(longitude) && isfinite(latitude) && isfinite(longitude) && any([latitude, longitude])
                    gps.Status    = 1;
                    gps.Latitude  = latitude;
                    gps.Longitude = longitude;
                end
            end
        end
    end
end
