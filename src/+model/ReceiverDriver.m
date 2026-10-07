classdef ReceiverDriver < handle

    %---------------------------------------------------------------------%
    % ## model.ReceiverDriver ##
    %
    % Concentra toda a comunicação do appColeta com um receptor, a partir
    % do registro do instrumento em "resources/ReceiverLib/<name>.json" (ver
    % model.Receiver). Os comandos são montados a partir de "communication":
    % "set" define as etapas, a ordem dos parâmetros de cada comando (unidos por
    % ';:'), a condição "when" e o "postDelay"; "parameters" traz o "write" e o
    % "read" de cada parâmetro; "query" e "fetch" trazem as demais requisições.
    %
    % driver = model.ReceiverDriver(definition, receiverHandle);
    %---------------------------------------------------------------------%

    properties (SetAccess = private)
        Definition
        Handle
    end


    properties (Dependent)
        IsVirtual
        IsStreaming
        IsLevelAzimuth
        HasVideoBandWidth
        HasGps
    end


    methods
        %-----------------------------------------------------------------%
        function obj = ReceiverDriver(definition, receiverHandle)
            arguments
                definition (1, 1) struct
                receiverHandle = []
            end

            obj.Definition = definition;
            obj.Handle     = receiverHandle;
        end

        %-----------------------------------------------------------------%
        function value = get.IsVirtual(obj)
            % O IDN fica em UserData do handle (ver model.Receiver.connect), por
            % isso a informação vale também para drivers criados depois da conexão.
            value = ~isempty(obj.Handle) && isvalid(obj.Handle) && isprop(obj.Handle, 'UserData') && isstruct(obj.Handle.UserData) && isfield(obj.Handle.UserData, 'IDN') && contains(obj.Handle.UserData.IDN, 'VIRTUAL');
        end

        %-----------------------------------------------------------------%
        function value = get.IsStreaming(obj)
            value = strcmp(obj.Definition.connection.traceData.acquisitionMode, 'streaming');
        end

        %-----------------------------------------------------------------%
        function value = get.IsLevelAzimuth(obj)
            value = strcmp(obj.Definition.connection.traceData.dataType, 'level+azimuth');
        end

        %-----------------------------------------------------------------%
        function value = get.HasVideoBandWidth(obj)
            command = findCommand(obj, 'acquisition', 'bandConfig');
            value   = any(strcmp(cellstr(command.parameterNames), 'videoBandWidth'));
        end

        %-----------------------------------------------------------------%
        function value = get.HasGps(obj)
            value = ~isempty(obj.Definition.communication.fetch.gpsData);
        end

        %-----------------------------------------------------------------%
        function idn = identify(obj)
            % A ideia de usar writeline/readline (com loop, criando artificialmente 
            % um Timeout) é fazer duas operações de comunicações com o socket (notei 
            % que em alguns sockets desconectados, a primeira operação de escrita é realizada
            % normalmente, retornando erro apenas numa segunda operação). Isso evita, também,
            % o Timeout padrão do writeread (10 segundos).

            idn = '';

            flush(obj.Handle)
            writeline(obj.Handle, obj.Definition.communication.query.identification)

            statusTic = tic;
            t = toc(statusTic);
            while t < class.Constants.idnTimeout
                if obj.Handle.NumBytesAvailable
                    idn = readline(obj.Handle);
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
        function commands = buildInitCommands(obj, resetEnabled, syncMode)
            params   = struct('sweepMode', sweepModeValue(obj, syncMode));
            commands = struct('Name', {}, 'Text', {}, 'PostDelay', {});

            for command = model.ReceiverDriver.commandsOf(obj.Definition, 'initialization')'
                if strcmp(command.name, 'reset') && ~resetEnabled
                    continue
                end

                text = composeCommand(obj, command, params);
                if ~isempty(text)
                    commands(end+1) = struct('Name', command.name, 'Text', text, 'PostDelay', command.postDelay); %#ok<AGROW>
                end
            end
        end

        %-----------------------------------------------------------------%
        function initialize(obj, resetEnabled, syncMode)
            for command = buildInitCommands(obj, resetEnabled, syncMode)
                writeline(obj.Handle, command.Text);

                if ~obj.IsVirtual && (command.PostDelay > 0)
                    pause(command.PostDelay)
                end
            end
        end

        %-----------------------------------------------------------------%
        function setOperationMode(obj)
            % O R&S EB500 opera em dois modos: PSCAN (2), usado nas tarefas 
            % ordinárias, e FFM DF (3), usado na tarefa "Drive-test (Level+Azimuth)".

            if obj.IsStreaming
                operationMode = 2;
                if obj.IsLevelAzimuth
                    operationMode = 3;
                end

                class.EB500Lib.OperationMode(obj.Handle, operationMode)
            end
        end

        %-----------------------------------------------------------------%
        function params = bandParameters(obj, rawBand, freqStart, freqStop)
            % Converte a banda da tarefa (TaskList.json) nos valores a serem
            % programados no receptor, nomeados conforme "communicationParameters"
            % de "ReceiverLib.json".

            features = obj.Definition.features;

            traceIdx = find(strcmp(splitList(features.traceMode.items), rawBand.TraceMode), 1);
            params.traceMode = getListItem(splitList(features.traceMode.values), traceIdx);

            params.averageMode = [];
            if ~isempty(features.traceMode.requiresAverageModeFor)
                params.averageMode = features.traceMode.requiresAverageModeFor(traceIdx);
            end
            params.averageCount = rawBand.IntegrationFactor;

            detectorIdx = find(strcmp(splitList(features.detector.items), rawBand.instrDetector), 1);
            params.detector = getListItem(splitList(features.detector.values), detectorIdx);

            levelUnitIdx = 2;
            if strcmp(rawBand.instrLevelUnit, 'dBm')
                levelUnitIdx = 1;
            end
            params.levelUnit = getListItem(splitList(features.levelUnits), levelUnitIdx);

            params.freqStart  = freqStart;
            params.freqStop   = freqStop;
            params.freqCenter = (freqStart + freqStop)/2;
            params.freqSpan   = freqStop - freqStart;

            params.dataPoints = rawBand.instrDataPoints;
            params.stepWidth  = (rawBand.FreqStop - rawBand.FreqStart) ./ (rawBand.instrDataPoints - 1);

            params.resolutionMode  = 0;
            params.resolutionValue = str2double(extractBefore(rawBand.instrResolution, ' kHz')) .* 1e+3;
            params.selectivity     = rawBand.instrSelectivity;
            params.videoBandWidth  = rawBand.instrVBW;

            params.sensitivityMode = '';
            if ~isempty(rawBand.instrSensitivityMode)
                params.sensitivityMode = rawBand.instrSensitivityMode;
            end

            params.preamp = double(strcmp(rawBand.instrPreamp, 'On'));

            if strcmp(rawBand.instrAttMode, 'Auto')
                params.attenuationMode  = 1;
                params.attenuationValue = 0;
            else
                params.attenuationMode  = 0;
                params.attenuationValue = str2double(extractBefore(rawBand.instrAttFactor, ' dB'));
            end

            params.sampleTimeMode  = 1;
            params.sampleTimeValue = 0;

            params.dfSquelchMode  = rawBand.DF_SquelchMode;
            params.dfSquelchValue = rawBand.DF_SquelchValue;
            params.dfMeasTime     = rawBand.DF_MeasTime;
        end

        %-----------------------------------------------------------------%
        function commands = buildBandCommands(obj, params)
            % "configSET" é o comando "bandConfig"; "attSET", o comando "attenuationValue",
            % que só existe, e só é enviado, nos receptores que não aceitam o valor da
            % atenuação junto aos demais parâmetros.

            commands = struct('configSET', '', 'attSET', '');

            for command = model.ReceiverDriver.commandsOf(obj.Definition, 'acquisition')'
                text = composeCommand(obj, command, params);

                switch command.name
                    case 'bandConfig'
                        commands.configSET = text;
                    case 'attenuationValue'
                        commands.attSET = text;
                end
            end
        end

        %-----------------------------------------------------------------%
        function [commands, rawMetaData] = applyBandConfig(obj, params)
            % Programa a banda no receptor e confirma, consultando-o, que os
            % parâmetros com "requireMatch" foram aceitos. A ordem dos campos
            % da resposta é a de "query.bandConfigParameterNames".

            commands = buildBandCommands(obj, params);

            sendBandCommand(obj, 'bandConfig', commands.configSET)
            sendBandCommand(obj, 'attenuationValue', commands.attSET)

            flush(obj.Handle)
            writeline(obj.Handle, obj.Definition.communication.query.bandConfig);

            rawAnswer = '';

            statusTic = tic;
            t = toc(statusTic);
            while t < class.Constants.Timeout
                if obj.Handle.NumBytesAvailable
                    rawAnswer = readline(obj.Handle);
                    if ~isempty(rawAnswer)
                        rawAnswer = strtrim(rawAnswer);
                        break
                    end
                end
                t = toc(statusTic);
            end

            if isempty(rawAnswer)
                error(mismatchMessage(1, 'Empty string', commands.configSET, ''))
            end

            splitAnswer    = strsplit(rawAnswer, ';');
            parameterNames = bandConfigParameterNames(obj);

            answer = struct();
            for ii = 1:numel(parameterNames)
                answer.(parameterNames{ii}) = splitAnswer{ii};
            end
            rawMetaData = jsonencode(answer);

            parameters = model.ReceiverDriver.parametersOf(obj.Definition);
            for ii = 1:numel(parameterNames)
                parameterName = parameterNames{ii};
                parameterIdx  = find(strcmp({parameters.name}, parameterName), 1);

                if isempty(parameterIdx) || ~parameters(parameterIdx).requireMatch || ~isfield(params, parameterName)
                    continue
                end

                expectedValue = params.(parameterName);
                if isnumeric(expectedValue)
                    hasMismatch = str2double(splitAnswer{ii}) ~= expectedValue;
                else
                    hasMismatch = ~strcmp(splitAnswer{ii}, expectedValue);
                end

                if hasMismatch
                    error(mismatchMessage(2, parameterName, commands.configSET, rawMetaData))
                end
            end
        end

        %-----------------------------------------------------------------%
        function configureBand(obj, commands)
            writeline(obj.Handle, commands.configSET);
            pause(.001)

            if ~isempty(commands.attSET)
                writeline(obj.Handle, commands.attSET);
            end
        end

        %-----------------------------------------------------------------%
        function restoreConfiguration(obj, commands)
            % Se ocorrer alguma queda de energia e o receptor desligar, ao
            % religar, o receptor voltará às suas configurações de fábrica,
            % o que demandará, portanto, a sua reconfiguração.

            setOperationMode(obj)

            startup = findCommand(obj, 'initialization', 'startup');
            writeline(obj.Handle, composeCommand(obj, startup, struct()));
            pause(.001)

            configureBand(obj, commands)
        end

        %-----------------------------------------------------------------%
        function attenuation = queryAttenuation(obj)
            attenuation = -1;

            command = obj.Definition.communication.query.attenuation;
            if ~isempty(command)
                attenuation = str2double(util.InstrumentIO.queryInstrument(obj.Handle, command));
            end
        end

        %-----------------------------------------------------------------%
        function traceData = fetchTraceData(obj)
            writeline(obj.Handle, obj.Definition.communication.fetch.traceData);
            traceData = readbinblock(obj.Handle, 'single');
        end
    end


    methods (Static)
        %-----------------------------------------------------------------%
        function parameters = parametersOf(definition)
            % O jsondecode devolve um cell, e não um struct array, quando os
            % objetos não têm as mesmas chaves ("writeAuto" e "when" são opcionais).

            parameters = normalizeStructs(definition.communication.parameters, ...
                {'name', 'write', 'writeAuto', 'read', 'requireMatch', 'when'}, ...
                {'', '', '', '', false, ''});
        end

        %-----------------------------------------------------------------%
        function commands = commandsOf(definition, stepName)
            steps    = definition.communication.set;
            stepIdx  = find(strcmp({steps.step}, stepName), 1);

            commands = normalizeStructs(steps(stepIdx).commands, ...
                {'name', 'parameterNames', 'mandatory', 'postDelay', 'when'}, ...
                {'', {}, false, 0, ''});
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function text = fillTemplate(~, template, params)
            names  = fieldnames(params);
            tokens = cellfun(@(name) sprintf('%%%s%%', name), names, 'UniformOutput', false);
            values = cellfun(@(name) toText(params.(name)), names, 'UniformOutput', false);

            text = replace(template, tokens, values);
        end

        %-----------------------------------------------------------------%
        function text = composeCommand(obj, command, params)
            % Une os "write" dos parâmetros do comando com ';:', respeitando a
            % ordem de "parameterNames" e as condições "when".

            text = '';
            if ~evaluateCondition(command.when, params)
                return
            end

            parameters = model.ReceiverDriver.parametersOf(obj.Definition);
            parts      = {};

            for name = cellstr(command.parameterNames)'
                parameterIdx = find(strcmp({parameters.name}, name{1}), 1);
                if isempty(parameterIdx)
                    error('ReceiverLib:UnknownParameter', 'Parâmetro "%s" não consta em "parameters".', name{1})
                end

                parameter = parameters(parameterIdx);
                if ~evaluateCondition(parameter.when, params)
                    continue
                end

                template = parameter.write;
                if ~isempty(parameter.writeAuto) && isfield(params, name{1}) && ischar(params.(name{1})) && strcmp(params.(name{1}), 'auto')
                    template = parameter.writeAuto;
                end

                if ~isempty(template)
                    parts{end+1} = fillTemplate(obj, template, params); %#ok<AGROW>
                end
            end

            text = strjoin(parts, ';:');
        end

        %-----------------------------------------------------------------%
        function sendBandCommand(obj, name, text)
            if isempty(text)
                return
            end

            writeline(obj.Handle, text);

            if ~obj.IsVirtual
                delay = commandPostDelay(obj, 'acquisition', name);
                if delay > 0
                    pause(delay)
                end
            end
        end

        %-----------------------------------------------------------------%
        function command = findCommand(obj, stepName, commandName)
            commands = model.ReceiverDriver.commandsOf(obj.Definition, stepName);
            command  = commands(strcmp({commands.name}, commandName));
        end

        %-----------------------------------------------------------------%
        function value = sweepModeValue(obj, syncMode)
            sweepMode = obj.Definition.features.sweepMode;

            itemIdx = find(strcmp(splitList(sweepMode.items), syncMode), 1);
            if isempty(itemIdx)
                error('ReceiverLib:UnsupportedSyncMode', 'O receptor %s não suporta o sincronismo "%s".', obj.Definition.name, syncMode)
            end

            value = getListItem(splitList(sweepMode.values), itemIdx);
        end

        %-----------------------------------------------------------------%
        function names = bandConfigParameterNames(obj)
            names = cellstr(obj.Definition.communication.query.bandConfigParameterNames);
        end

        %-----------------------------------------------------------------%
        function delay = commandPostDelay(obj, stepName, commandName)
            command = findCommand(obj, stepName, commandName);
            delay   = command.postDelay;
        end
    end
end


%-------------------------------------------------------------------------%
function items = normalizeStructs(raw, fields, defaults)
    if iscell(raw)
        list = raw(:);
    else
        list = num2cell(raw(:));
    end

    items = repmat(cell2struct(defaults(:), fields(:), 1), numel(list), 1);
    for ii = 1:numel(list)
        for jj = 1:numel(fields)
            if isfield(list{ii}, fields{jj})
                items(ii).(fields{jj}) = list{ii}.(fields{jj});
            end
        end
    end
end

%-------------------------------------------------------------------------%
function isTrue = evaluateCondition(condition, params)
    % Formato: "<parametro>==<número>" ou "<parametro>~=<número>".

    isTrue = true;
    if isempty(condition)
        return
    end

    tokens = regexp(condition, '^\s*(\w+)\s*(==|~=)\s*(-?[\d.]+)\s*$', 'tokens', 'once');
    if isempty(tokens)
        error('ReceiverLib:InvalidCondition', 'Condição "when" inválida: %s', condition)
    end

    if ~isfield(params, tokens{1})
        isTrue = false;
        return
    end

    isTrue = (params.(tokens{1}) == str2double(tokens{3}));
    if strcmp(tokens{2}, '~=')
        isTrue = ~isTrue;
    end
end


%-------------------------------------------------------------------------%
function items = splitList(text)
    items = strsplit(text, ',', 'CollapseDelimiters', false);
end

%-------------------------------------------------------------------------%
function item = getListItem(items, idx)
    if isempty(idx) || (idx > numel(items))
        error('ReceiverLib:ItemNotFound', 'Item da lista de características do receptor não encontrado.')
    end

    item = items{idx};
end

%-------------------------------------------------------------------------%
function text = toText(value)
    if isnumeric(value)
        text = num2str(value);
    else
        text = char(value);
    end
end

%-------------------------------------------------------------------------%
function msg = mismatchMessage(type, trigger, configMsg, responseMsg)
    switch type
        case 1
            msg = sprintf('Triggered parameter: "%s\n"scpiSet_Config: %s', trigger, configMsg);
        case 2
            msg = sprintf('Triggered parameter: "%s"\nscpiSet_Config: %s\nscpiSet_Answer: %s', trigger, configMsg, responseMsg);
    end
end
