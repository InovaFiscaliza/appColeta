classdef (Abstract) HtmlTextGenerator

    % Essa classe abstrata organiza a criação de "textos decorados",
    % valendo-se das funcionalidades do HTML+CSS. Um texto aqui produzido
    % será renderizado em um componente uihtml, uilabel ou outro que tenha 
    % html como interpretador.

    % Antes de cada função, consta a indicação do módulo que chama a
    % função.

    properties (Constant)
        %-----------------------------------------------------------------%
    end

    
    methods (Static = true)
        %-----------------------------------------------------------------%
        function htmlContent = AppInfo(appGeneral, rootFolder, executionMode, renderCount, outputFormat)
            arguments
                appGeneral 
                rootFolder 
                executionMode 
                renderCount
                outputFormat char {mustBeMember(outputFormat, {'popup', 'textview'})} = 'textview'
            end
        
            appName    = class.Constants.appName;
            appVersion = appGeneral.AppVersion;
            appURL     = util.publicLink(appName, rootFolder, appName);
        
            switch executionMode
                case {'MATLABEnvironment', 'desktopStandaloneApp'}
                    appMode = 'desktopApp';        
                case 'webApp'
                    computerName = ccTools.fcn.OperationSystem('computerName');
                    if strcmpi(computerName, appGeneral.computerName.webServer)
                        appMode = 'webServer';
                    else
                        appMode = 'deployServer';                    
                    end
            end

            dataStruct    = struct('group', 'COMPUTADOR',     'value', struct('Machine', rmfield(appVersion.machine, 'name'), 'Mode', sprintf('%s - %s', executionMode, appMode)));
            dataStruct(2) = struct('group', 'MATLAB',         'value', rmfield(appVersion.matlab, 'name'));
            if ~isempty(appVersion.browser)
                dataStruct(3) = struct('group', 'NAVEGADOR',  'value', rmfield(appVersion.browser, 'name'));
            end
            dataStruct(end+1) = struct('group', 'RENDERIZAÇÕES','value', renderCount);
            dataStruct(end+1) = struct('group', 'APLICATIVO', 'value', appVersion.application);
        
            freeInitialText = sprintf('<font style="font-size: 12px;">O repositório das ferramentas desenvolvidas no Laboratório de inovação da SFI pode ser acessado <a href="%s" target="_blank">aqui</a>.</font>\n\n', appURL.Sharepoint);
            htmlContent     = textFormatGUI.struct2PrettyPrintList(dataStruct, 'print -1', freeInitialText, outputFormat);
        end

        %-----------------------------------------------------------------%
        function log = LOG(specObj, idx)
            log = '';

            if ~isempty(specObj(idx).LOG)
                logTable = struct2table(specObj(idx).LOG);
                log = strjoin("<b>" + logTable.time + " - " + upper(logTable.type) + "</b>" + newline + logTable.msg, '\n\n');
            end
        end

        %-----------------------------------------------------------------%
        function htmlContent = Task(specObj, revisitObj, idxTask, idxBand)
            Task   = specObj(idxTask).Task;
            Script = Task.Script;

            % ObservationType
            switch Script.Observation.Type
                case "Duration"; observationType = "Duração específica";
                case "Samples";  observationType = "Quantidade específica de amostras";
                case "Time";     observationType = "Período específico";
            end
        
            % ObservationSamples
            if observationType == "Quantidade específica de amostras"
                observationSamples = Script.Band(idxBand).instrObservationSamples;
            else
                observationSamples = -1;
            end
        
            % StepWidth
            if isnumeric(Script.Band(idxBand).instrStepWidth)
                StepWidth = sprintf('%.3f kHz', Script.Band(idxBand).instrStepWidth/1e+3);
            else
                StepWidth = Script.Band(idxBand).instrStepWidth;
            end
            
            % Receiver RevisitTime
            receiverRevisitTime = sprintf('%.3f seg', Script.Band(idxBand).RevisitTime);
            try
                if revisitObj.Band(idxTask).RevisitFactors(idxBand+1) ~= -1
                    receiverRevisitTime = sprintf('%.3f → %.3f seg (norm)', Script.Band(idxBand).RevisitTime, ...
                                                                            revisitObj.GlobalRevisitTime * revisitObj.Band(idxTask).RevisitFactors(idxBand+1));
                end
            catch
            end
               
            % GPS RevisitTime
            if ~isempty(Script.GPS.RevisitTime)
                gpsRevisitTime = sprintf('%.3f seg', Script.GPS.RevisitTime);
        
                try
                    if revisitObj.Band(idxTask).RevisitFactors(1) ~= -1
                        gpsRevisitTime = sprintf('%.3f → %.3f seg (norm)', Script.GPS.RevisitTime, ...
                                                                           revisitObj.GlobalRevisitTime * revisitObj.Band(idxTask).RevisitFactors(1));
                    end
                catch
                end
            else
                gpsRevisitTime = 'NA';
            end
        
            % MaskTrigger
            if ~isempty(specObj(idxTask).Band(idxBand).Mask)
                maskTrigger = struct('Status',    Task.Script.Band(idxBand).MaskTrigger.Status, ...
                                     'FindPeaks', specObj(idxTask).Band(idxBand).Mask.FindPeaks);
            else
                maskTrigger = 'NA';
            end
            
            dataStruct = struct('group', 'TAREFA',                                                         ...
                                'value', struct('Type',          Task.Type,                                ...
                                                'Observation',   observationType,                          ...
                                                'FileVersion',   class.Constants.fileVersion,              ...
                                                'BitsPerSample', sprintf('%d bits', Script.BitsPerSample), ...
                                                'Receiver',      specObj(idxTask).IDN,                      ...
                                                'gpsType',       Script.GPS.Type));
            
            dataStruct(2).group = 'RECEPTOR';
            dataStruct(2).value = struct('StepWidth',  StepWidth,                       ...
                                         'DataPoints', Script.Band(idxBand).instrDataPoints, ...
                                         'Resolution', Script.Band(idxBand).instrResolution);
            
            % VBW
            % instrVBW será igual a {} caso se trate do R&S EB500; em se tratando de
            % um analisador, o instrVBW será originalmente igual a "auto" (caso na
            % tarefa o seu valor seja igual a -1) ou o valor mais próximo da relação 
            % de VBWs disponíveis no analisador (atualmente incluído apenas R&S FSL, 
            % FSVR e FSW).
            if ~isempty(Script.Band(idxBand).instrVBW) && ~strcmp(Script.Band(idxBand).instrVBW, 'auto')
                dataStruct(2).value.VBW = Script.Band(idxBand).instrVBW;
            end
        
            dataStruct(2).value.Detector          = Script.Band(idxBand).instrDetector;
            dataStruct(2).value.TraceMode         = Script.Band(idxBand).TraceMode;
            dataStruct(2).value.IntegrationFactor = Script.Band(idxBand).IntegrationFactor;
            dataStruct(2).value.Reset             = Task.Receiver.Reset;
            dataStruct(2).value.Sync              = Task.Receiver.Sync;
            
            dataStruct(3).group = 'ANTENA';
            dataStruct(3).value = specObj(idxTask).Band(idxBand).Antenna;
        
            dataStruct(4).group = 'TEMPO DE REVISITA';
            dataStruct(4).value = struct('Receiver', receiverRevisitTime, ...
                                         'GPS',      gpsRevisitTime);
        
            dataStruct(5).group = 'OUTROS ASPECTOS';
            dataStruct(5).value = struct('Description',        Script.Band(idxBand).Description, ...
                                         'ObservationSamples', observationSamples,          ...
                                         'MaskTrigger',        maskTrigger);
            
            htmlContent = textFormatGUI.struct2PrettyPrintList(dataStruct);
        end
    end
end