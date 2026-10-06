classdef ReceiverDriver < handle

    %---------------------------------------------------------------------%
    % ## model.ReceiverDriver ##
    %
    % Concentra toda a comunicação do appColeta com um receptor, a partir
    % do registro do instrumento em "config/ReceiverLib/<name>.json" (ver
    % model.Receiver). Os comandos em uso hoje ficam em "communication.legacy";
    % "set" (postDelay e ordem dos parâmetros de "bandConfig") e "parameters"
    % ("requireMatch" e "autoLevel") complementam a informação.
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
            value = ~isempty(obj.Definition.communication.legacy.setVideoBandWidth);
        end

        %-----------------------------------------------------------------%
        function value = get.HasGps(obj)
            value = ~isempty(obj.Definition.communication.legacy.fetchGpsData);
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
            writeline(obj.Handle, obj.Definition.communication.legacy.queryIdentification)

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
        function initialize(obj, resetEnabled, syncMode)
            legacy = obj.Definition.communication.legacy;

            if resetEnabled
                writeline(obj.Handle, legacy.initReset);
                if ~obj.IsVirtual
                    pause(commandPostDelay(obj, 'initialization', 'reset'))
                end
            end

            writeline(obj.Handle, legacy.initStartup);
            writeline(obj.Handle, fillTemplate(obj, legacy.initSweepMode, struct('sweepMode', sweepModeValue(obj, syncMode))));
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
            % Converte a banda da tarefa (taskList.json) nos valores a serem
            % programados no receptor, nomeados conforme "communicationParameters"
            % de "ReceiverLib-v2.json".

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

            params.videoBandWidthCommand = '';
            if obj.HasVideoBandWidth
                fragments = splitList(obj.Definition.communication.legacy.setVideoBandWidth);
                if strcmp(rawBand.instrVBW, 'auto')
                    params.videoBandWidthCommand = fragments{1};
                else
                    params.videoBandWidthCommand = replace(fragments{2}, '%videoBandWidth%', rawBand.instrVBW);
                end
            end

            params.sensitivityMode = '';
            if ~isempty(rawBand.instrSensitivityMode)
                params.sensitivityMode = rawBand.instrSensitivityMode;
            end

            params.preamp = double(strcmp(rawBand.instrPreamp, 'On'));

            params.autoLevel = '';
            if strcmp(rawBand.instrAttMode, 'Auto')
                params.attenuationMode  = 1;
                params.attenuationValue = 0;
                params.autoLevel        = autoLevelCommand(obj);
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
        function [commands, rawMetaData] = applyBandConfig(obj, params)
            % Programa a banda no receptor e confirma, consultando-o, que os
            % parâmetros com "requireMatch" foram aceitos. A ordem dos campos
            % da resposta é a de "parameterNames" do comando "bandConfig".

            legacy = obj.Definition.communication.legacy;

            commands = struct( ...
                'configSET', fillTemplate(obj, legacy.setBandConfig, params), ...
                'attSET', '' ...
            );

            writeline(obj.Handle, commands.configSET);
            if ~obj.IsVirtual
                pause(commandPostDelay(obj, 'acquisition', 'bandConfig'))
            end

            if ~params.attenuationMode && ~isempty(legacy.setAttenuation)
                commands.attSET = fillTemplate(obj, legacy.setAttenuation, params);
                writeline(obj.Handle, commands.attSET);
            end

            flush(obj.Handle)
            writeline(obj.Handle, legacy.queryBandConfig);

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

            parameters = obj.Definition.communication.parameters;
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

            writeline(obj.Handle, obj.Definition.communication.legacy.initStartup);
            pause(.001)

            configureBand(obj, commands)
        end

        %-----------------------------------------------------------------%
        function attenuation = queryAttenuation(obj)
            attenuation = -1;

            command = obj.Definition.communication.legacy.queryAttenuation;
            if ~isempty(command)
                attenuation = str2double(fcn.WriteRead(obj.Handle, command));
            end
        end

        %-----------------------------------------------------------------%
        function traceData = fetchTraceData(obj)
            writeline(obj.Handle, obj.Definition.communication.legacy.fetchTraceData);
            traceData = readbinblock(obj.Handle, 'single');
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
        function value = sweepModeValue(obj, syncMode)
            sweepMode = obj.Definition.features.sweepMode;

            itemIdx = find(strcmp(splitList(sweepMode.items), syncMode), 1);
            if isempty(itemIdx)
                error('ReceiverLib:UnsupportedSyncMode', 'O receptor %s não suporta o sincronismo "%s".', obj.Definition.name, syncMode)
            end

            value = getListItem(splitList(sweepMode.values), itemIdx);
        end

        %-----------------------------------------------------------------%
        function command = autoLevelCommand(obj)
            command = '';

            parameters   = obj.Definition.communication.parameters;
            parameterIdx = find(strcmp({parameters.name}, 'autoLevel'), 1);

            if ~isempty(parameterIdx) && ~isempty(parameters(parameterIdx).write)
                command = [';:' parameters(parameterIdx).write];
            end
        end

        %-----------------------------------------------------------------%
        function names = bandConfigParameterNames(obj)
            commands = acquisitionCommands(obj);
            names    = commands(strcmp({commands.name}, 'bandConfig')).parameterNames;
        end

        %-----------------------------------------------------------------%
        function delay = commandPostDelay(obj, stepName, commandName)
            delay = 0;

            if strcmp(stepName, 'acquisition')
                commands = acquisitionCommands(obj);
            else
                steps    = obj.Definition.communication.set;
                commands = steps(strcmp({steps.step}, stepName)).commands;
            end

            commandIdx = find(strcmp({commands.name}, commandName), 1);
            if ~isempty(commandIdx)
                delay = commands(commandIdx).postDelay;
            end
        end

        %-----------------------------------------------------------------%
        function commands = acquisitionCommands(obj)
            steps    = obj.Definition.communication.set;
            commands = steps(strcmp({steps.step}, 'acquisition')).commands;
        end
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
