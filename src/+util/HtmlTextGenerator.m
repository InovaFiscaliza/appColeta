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
                    computerName = appUtil.OperationSystem('computerName');
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
                                                'Receiver',      specObj(idxTask).IDN,                     ...
                                                'gpsType',       Script.GPS.Type));

            if contains(Task.Type, 'Rompimento de Máscara Espectral')
                maskTrigger = Task.Script.Band(idxBand).MaskTrigger;
                maskTrigger.StatusInfo = class.taskList.maskTriggerStatus(Task.Script.Band(idxBand).MaskTrigger.Status);

                dataStruct(end+1) = struct( ...
                    'group', 'TASKTRIGGER', ...
                    'value', maskTrigger ...
                );
            end
            
            dataStruct(end+1) = struct( ...
                'group', 'RECEPTOR', ...
                'value', struct( ...
                    'FreqStart', Script.Band(idxBand).FreqStart, ...
                    'FreqStop', Script.Band(idxBand).FreqStop, ...
                    'StepWidth', StepWidth, ...
                    'DataPoints', Script.Band(idxBand).instrDataPoints, ...
                    'Resolution', Script.Band(idxBand).instrResolution, ...
                    'Detector', Script.Band(idxBand).instrDetector, ...
                    'TraceMode', Script.Band(idxBand).TraceMode, ...
                    'IntegrationFactor', Script.Band(idxBand).IntegrationFactor, ...
                    'Reset', Task.Receiver.Reset, ...
                    'Sync', Task.Receiver.Sync ...
                ) ...
            );
            
            % VBW
            % instrVBW será igual a {} caso se trate do R&S EB500; em se tratando de
            % um analisador, o instrVBW será originalmente igual a "auto" (caso na
            % tarefa o seu valor seja igual a -1) ou o valor mais próximo da relação 
            % de VBWs disponíveis no analisador (atualmente incluído apenas R&S FSL, 
            % FSVR e FSW).
            if ~isempty(Script.Band(idxBand).instrVBW) && ~strcmp(Script.Band(idxBand).instrVBW, 'auto')
                dataStruct(end).value.VBW = Script.Band(idxBand).instrVBW;
            end
            
            dataStruct(end+1) = struct( ...
                'group', 'ANTENA', ...
                'value', specObj(idxTask).Band(idxBand).Antenna ...
            );
        
            dataStruct(end+1) = struct( ...
                'group', 'TEMPO DE REVISITA', ...
                'value', struct( ...
                    'Receiver', receiverRevisitTime, ...
                    'GPS', gpsRevisitTime ...
                ) ...
            );
        
            dataStruct(end+1) = struct( ...
                'group', 'OUTROS ASPECTOS', ...
                'value', struct( ...
                    'Description', Script.Band(idxBand).Description, ...
                    'ObservationSamples', observationSamples,          ...
                    'MaskTrigger', maskTrigger ...
                ) ...
            );
            
            htmlContent = textFormatGUI.struct2PrettyPrintList(dataStruct);
        end

        %-----------------------------------------------------------------%
        function [htmlContent, imgSource] = Instrument(receiverObj, gpsObj, editedList, idx1)
            switch editedList.Family{idx1}
                case 'Receiver'
                    idx2 = find(strcmp(receiverObj.Config.Name, editedList.Name{idx1}), 1);
                    imgSource = receiverObj.Config.Image{idx2};

                    dataStruct    = struct('group', 'IDENTIFICAÇÃO', ...
                                           'value', table2struct(receiverObj.Config(idx2,1:4)));        
                    dataStruct(2) = struct('group', 'PARÂMETROS', ...
                                           'value', table2struct(receiverObj.Config(idx2,[7:9, 21:end])));

                case 'GPS'
                    idx2 = find(strcmp(gpsObj.Config.Name, editedList.Name{idx1}), 1);
                    imgSource = gpsObj.Config.Image{idx2};

                    dataStruct    = struct('group', 'IDENTIFICAÇÃO', ...
                                           'value', table2struct(gpsObj.Config(idx2,1:3)));        
                    dataStruct(2) = struct('group', 'PARÂMETROS', ...
                                           'value', table2struct(gpsObj.Config(idx2,6:7)));
            end

            htmlContent = textFormatGUI.struct2PrettyPrintList(dataStruct);
        end

        %-----------------------------------------------------------------%
        function htmlContent = Server(tcpServer)
            dataStruct = struct( ...
                    'ServerAddress',     tcpServer.Server.ServerAddress,     ...
                    'ServerPort',        tcpServer.Server.ServerPort,        ...
                    'Connected',         tcpServer.Server.Connected,         ...
                    'ClientAddress',     tcpServer.Server.ClientAddress,     ...
                    'ClientPort',        tcpServer.Server.ClientPort,        ...
                    'NumBytesAvailable', tcpServer.Server.NumBytesAvailable, ...
                    'Timeout',           tcpServer.Server.Timeout,           ...
                    'ByteOrder',         tcpServer.Server.ByteOrder,         ...
                    'Terminator',        tcpServer.Server.Terminator,        ...
                    'NumBytesWritten',   tcpServer.Server.NumBytesWritten ...
            );

            htmlContent = jsonencode(dataStruct);
        end

        %-----------------------------------------------------------------%
        function htmlContent = checkUpdate(appGeneral, rootFolder)
            try
                % Versão instalada no computador:
                appName          = class.Constants.appName;
                presentVersion   = struct(appName, appGeneral.AppVersion.application.version); 
                
                % Versão estável, indicada nos arquivos de referência (na nuvem):
                generalURL       = util.publicLink(appName, rootFolder);
                generalVersions  = webread(generalURL, weboptions("ContentType", "json"));        
                stableVersion    = struct(appName, generalVersions.(appName).Version);
                
                % Validação:
                if isequal(presentVersion, stableVersion)
                    msgWarning   = 'O appColeta está atualizado';
                else
                    updatedModule    = {};
                    nonUpdatedModule = {};
                    if strcmp(presentVersion.(appName), stableVersion.(appName))
                        updatedModule(end+1)    = {appName};
                    else
                        nonUpdatedModule(end+1) = {appName};
                    end
        
                    dataStruct    = struct('group', 'VERSÃO INSTALADA', 'value', presentVersion);
                    dataStruct(2) = struct('group', 'VERSÃO ESTÁVEL',   'value', stableVersion);
                    dataStruct(3) = struct('group', 'SITUAÇÃO',         'value', struct('updated', strjoin(updatedModule, ', '), 'nonupdated', strjoin(nonUpdatedModule, ', ')));
        
                    msgWarning    = textFormatGUI.struct2PrettyPrintList(dataStruct, "print -1", '', 'popup');
                end
                
            catch ME
                msgWarning = ME.message;
            end
        
            htmlContent = msgWarning;
        end

        %-----------------------------------------------------------------%
        % AUXAPP.WINADDTASK
        %-----------------------------------------------------------------%
        function htmlContent = AddTask_BandView(taskList, idxTask, idxBand)
            dataStruct    = struct('group', 'RECEPTOR',                                                                                       ...
                                   'value', struct('StepWidth',         sprintf('%.3f kHz', taskList(idxTask).Band(idxBand).StepWidth/1e+3),  ...
                                                   'Resolution',        sprintf('%.3f kHz', taskList(idxTask).Band(idxBand).Resolution/1e+3), ...
                                                   'VBW',               taskList(idxTask).Band(idxBand).VBW,                                  ...
                                                   'Detector',          taskList(idxTask).Band(idxBand).Detector,                             ...
                                                   'TraceMode',         taskList(idxTask).Band(idxBand).TraceMode,                            ...
                                                   'IntegrationFactor', taskList(idxTask).Band(idxBand).IntegrationFactor,                    ...
                                                   'RFMode',            taskList(idxTask).Band(idxBand).RFMode,                               ...
                                                   'LevelUnit',         taskList(idxTask).Band(idxBand).LevelUnit));            
            dataStruct(2) = struct('group', 'TEMPO DE REVISITA', ...
                                   'value', struct('Receiver', sprintf('%.3f seg', taskList(idxTask).Band(idxBand).RevisitTime)));        
            dataStruct(3) = struct('group', 'OUTROS ASPECTOS',                                                               ...
                                   'value', struct('Description',        taskList(idxTask).Band(idxBand).Description,        ...
                                                   'ObservationSamples', taskList(idxTask).Band(idxBand).ObservationSamples, ...
                                                   'MaskTrigger',        taskList(idxTask).Band(idxBand).MaskTrigger));

            htmlContent   = textFormatGUI.struct2PrettyPrintList(dataStruct);
        end
    end
end