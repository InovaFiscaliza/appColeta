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
                    computerName = appEngine.util.OperationSystem('computerName');
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

            if ~isempty(specObj(idx).LogEntries)
                logTable = struct2table(specObj(idx).LogEntries);
                log = strjoin("<b>" + logTable.timestamp + " - " + upper(logTable.level) + "</b>" + newline + logTable.message, '\n\n');
            end
        end

        %-----------------------------------------------------------------%
        function htmlContent = Task(specObj, revisitObj, taskIdx, bandIdx)
            Task   = specObj(taskIdx).TaskSpec;
            Script = Task.Script;

            % ObservationType
            switch Script.Observation.Type
                case "Duration"; observationType = "Duração específica";
                case "Samples";  observationType = "Quantidade específica de amostras";
                case "Time";     observationType = "Período específico";
            end
        
            % ObservationSamples
            if observationType == "Quantidade específica de amostras"
                observationSamples = Script.Band(bandIdx).instrObservationSamples;
            else
                observationSamples = -1;
            end
        
            % StepWidth
            if isnumeric(Script.Band(bandIdx).instrStepWidth)
                StepWidth = sprintf('%.3f kHz', Script.Band(bandIdx).instrStepWidth/1e+3);
            else
                StepWidth = Script.Band(bandIdx).instrStepWidth;
            end
            
            % Receiver RevisitTime
            receiverRevisitTime = sprintf('%.3f seg', Script.Band(bandIdx).RevisitTime);
            try
                if revisitObj.Band(taskIdx).RevisitFactors(bandIdx+1) ~= -1
                    receiverRevisitTime = sprintf('%.3f → %.3f seg (norm)', Script.Band(bandIdx).RevisitTime, ...
                                                                            revisitObj.GlobalRevisitTime * revisitObj.Band(taskIdx).RevisitFactors(bandIdx+1));
                end
            catch
            end
               
            % GPS RevisitTime
            if ~isempty(Script.GPS.RevisitTime)
                gpsRevisitTime = sprintf('%.3f seg', Script.GPS.RevisitTime);
        
                try
                    if revisitObj.Band(taskIdx).RevisitFactors(1) ~= -1
                        gpsRevisitTime = sprintf('%.3f → %.3f seg (norm)', Script.GPS.RevisitTime, ...
                                                                           revisitObj.GlobalRevisitTime * revisitObj.Band(taskIdx).RevisitFactors(1));
                    end
                catch
                end
            else
                gpsRevisitTime = 'NA';
            end
        
            % MaskTrigger
            if ~isempty(specObj(taskIdx).Bands(bandIdx).Mask)
                maskTrigger = struct('Status',    Task.Script.Band(bandIdx).MaskTrigger.Status, ...
                                     'FindPeaks', specObj(taskIdx).Bands(bandIdx).Mask.FindPeaks);
            else
                maskTrigger = 'NA';
            end
            
            dataStruct = struct('group', 'TAREFA',                                                         ...
                                'value', struct('Type',          Task.Type,                                ...
                                                'Observation',   observationType,                          ...
                                                'FileVersion',   class.Constants.fileVersion,              ...
                                                'BitsPerSample', sprintf('%d bits', Script.BitsPerSample), ...
                                                'Receiver',      specObj(taskIdx).ReceiverId,                     ...
                                                'gpsType',       Script.GPS.Type));

            if contains(Task.Type, 'Rompimento de Máscara Espectral')
                maskTrigger = Task.Script.Band(bandIdx).MaskTrigger;
                maskTrigger.StatusInfo = class.taskList.maskTriggerStatus(Task.Script.Band(bandIdx).MaskTrigger.Status);

                dataStruct(end+1) = struct( ...
                    'group', 'TASKTRIGGER', ...
                    'value', maskTrigger ...
                );
            end
            
            dataStruct(end+1) = struct( ...
                'group', 'RECEPTOR', ...
                'value', struct( ...
                    'FreqStart', Script.Band(bandIdx).FreqStart, ...
                    'FreqStop', Script.Band(bandIdx).FreqStop, ...
                    'StepWidth', StepWidth, ...
                    'DataPoints', Script.Band(bandIdx).instrDataPoints, ...
                    'Resolution', Script.Band(bandIdx).instrResolution, ...
                    'Detector', Script.Band(bandIdx).instrDetector, ...
                    'TraceMode', Script.Band(bandIdx).TraceMode, ...
                    'IntegrationFactor', Script.Band(bandIdx).IntegrationFactor, ...
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
            if ~isempty(Script.Band(bandIdx).instrVBW) && ~strcmp(Script.Band(bandIdx).instrVBW, 'auto')
                dataStruct(end).value.VBW = Script.Band(bandIdx).instrVBW;
            end
            
            dataStruct(end+1) = struct( ...
                'group', 'ANTENA', ...
                'value', specObj(taskIdx).Bands(bandIdx).Antenna ...
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
                    'Description', Script.Band(bandIdx).Description, ...
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