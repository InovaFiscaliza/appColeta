classdef winAppColeta_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        GridLayout               matlab.ui.container.GridLayout
        NavBar                   matlab.ui.container.GridLayout
        AppInfo                  matlab.ui.control.Image
        FigurePosition           matlab.ui.control.Image
        DataHubLamp              matlab.ui.control.Image
        jsBackDoor               matlab.ui.control.HTML
        Tab6Button               matlab.ui.control.StateButton
        Tab5Button               matlab.ui.control.StateButton
        ButtonsSeparator2        matlab.ui.control.Image
        Tab4Button               matlab.ui.control.StateButton
        Tab3Button               matlab.ui.control.StateButton
        Tab2Button               matlab.ui.control.StateButton
        ButtonsSeparator1        matlab.ui.control.Image
        Tab1Button               matlab.ui.control.StateButton
        AppName                  matlab.ui.control.Label
        TabGroup                 matlab.ui.container.TabGroup
        Tab1_Task                matlab.ui.container.Tab
        Tab1Grid                 matlab.ui.container.GridLayout
        Toolbar                  matlab.ui.container.GridLayout
        tool_RevisitTime         matlab.ui.control.Label
        tool_ButtonLOG           matlab.ui.control.Image
        tool_Separator2          matlab.ui.control.Image
        tool_ButtonDel           matlab.ui.control.Image
        tool_ButtonPlay          matlab.ui.control.Image
        tool_Separator1          matlab.ui.control.Image
        tool_LeftPanel           matlab.ui.control.Image
        Document                 matlab.ui.container.GridLayout
        TaskStatusGrid           matlab.ui.container.GridLayout
        GPSLastFixPanel          matlab.ui.container.Panel
        GPSLastFixGrid           matlab.ui.container.GridLayout
        GPSErrorCountIcon        matlab.ui.control.Image
        GPSErrorCount            matlab.ui.control.Label
        GPSLastFix               matlab.ui.control.Label
        GPSLastFixIconGrid       matlab.ui.container.GridLayout
        GPSLastFixIcon           matlab.ui.control.Lamp
        GPSLastFixLabel          matlab.ui.control.Label
        MaskPanel                matlab.ui.container.Panel
        MaskGrid                 matlab.ui.container.GridLayout
        MaskStatus               matlab.ui.control.Label
        MaskLabel                matlab.ui.control.Label
        SweepsPanel              matlab.ui.container.Panel
        SweepsGrid               matlab.ui.container.GridLayout
        ReceiverErrorCountIcon   matlab.ui.control.Image
        ReceiverErrorCount       matlab.ui.control.Label
        RecordingIcon            matlab.ui.control.Image
        Sweeps                   matlab.ui.control.Label
        SweepsLabel              matlab.ui.control.Label
        AxesToolbar              matlab.ui.container.GridLayout
        axesTool_Waterfall       matlab.ui.control.Image
        axesTool_Peak            matlab.ui.control.Image
        axesTool_MaxHold         matlab.ui.control.Image
        axesTool_Average         matlab.ui.control.Image
        axesTool_MinHold         matlab.ui.control.Image
        axesTool_PlotSource      matlab.ui.control.DropDown
        axesTool_ExportGraphics  matlab.ui.control.Image
        axesTool_RestoreView     matlab.ui.control.Image
        AxesContainer            matlab.ui.container.Panel
        MetaData                 matlab.ui.control.Label
        SpectrumFlowList         matlab.ui.control.DropDown
        UITable                  matlab.ui.control.Table
        Tab2_InstrumentList      matlab.ui.container.Tab
        Tab3_TaskEdition         matlab.ui.container.Tab
        Tab4_TaskAdd             matlab.ui.container.Tab
        Tab5_Server              matlab.ui.container.Tab
        Tab6_Config              matlab.ui.container.Tab
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'mainApp'
        Context = 'TASK:VIEW'
        appHandleNameInBase
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        General
        General_I

        rootFolder
        tabGroupController
        renderCount = 0

        executionMode
        progressDialog
        popupContainer
        popupCurrentApp

        SubTabGroup = struct('Children', -1, 'UserData', [])

        % TAREFA+INSTRUMENTOS
        TaskController
        TaskSchedulerTimer

        taskList
        tcpServer
        receiverObj
        gpsObj
        EB500Obj
        EMSatObj
        ERMxObj

        % PLOT
        UIAxes1
        UIAxes2
        RestoreView = struct('Id', {}, 'XLim', {}, 'YLim', {}, 'CLim', {})

        PlotHandles
        PlotStyleDirty (1, 1) logical = false
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        % COMUNICAÇÃO ENTRE PROCESSOS:
        % • ipcMainJSEventsHandler
        %   Eventos recebidos do objeto app.jsBackDoor por meio de chamada 
        %   ao método "sendEventToMATLAB" do objeto "htmlComponent" (no JS).
        %
        % • ipcMainMatlabCallsHandler
        %   Eventos recebidos dos apps secundários.
        %
        % • ipcMainMatlabCallAuxiliarApp
        %   Reencaminha eventos recebidos aos apps secundários, viabilizando
        %   comunicação entre apps secundários e, também, redirecionando os 
        %   eventos JS quando o app secundário é executado em modo DOCK (e, 
        %   por essa razão, usa o "jsBackDoor" do app principal).
        %
        % • ipcMainMatlabOpenPopupApp
        %   Abre um app secundário como popup, no mainApp.
        %-----------------------------------------------------------------%
        function ipcMainJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    % MATLAB-JS BRIDGE (matlabJSBridge.js)
                    case {'Play', 'Stop', 'Delete'}
                        uialert(app.UIFigure, sprintf('HTMLEventName: %s, HTMLEventData: %d', event.HTMLEventName, event.HTMLEventData), '', 'Icon', 'success')

                    case 'renderer'
                        MFilePath   = fileparts(mfilename('fullpath'));
                        parpoolFlag = false;

                        if ~app.renderCount
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        else
                            currentTaskIdx = app.UITable.Selection;
                            if ~isempty(currentTaskIdx)
                                app.UITable.Selection = [];
                                onTaskSelectionChanged(app, struct('PreviousSelection', [], 'Selection', []))
                            end

                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)

                            if ~isempty(currentTaskIdx)
                                app.UITable.Selection = currentTaskIdx;
                                onTaskSelectionChanged(app, struct('PreviousSelection', [], 'Selection', currentTaskIdx))
                            end
                        end
                        
                        app.renderCount = app.renderCount+1;

                    case 'unload'
                        closeFcn(app)

                    case 'closeFcnCallFromPopupApp'
                        context = event.HTMLEventData.context;
                        popupCurrentAppTag = event.HTMLEventData.dockAppName;

                        switch context
                            case {'mainApp', app.Context}
                                hApp = app;
                            otherwise
                                hApp = getAppHandle(app.tabGroupController, context);
                        end
                        
                        if ~isempty(hApp) && isvalid(hApp)
                            deleteContextMenu(app.tabGroupController, hApp.UIFigure, popupCurrentAppTag)
                        end

                        delete(app.popupCurrentApp)
                        app.popupCurrentApp = [];
                    
                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end

                            otherwise
                                error('UnexpectedEvent')
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;

                    case 'findResourceStaticURL'
                        resourceStaticURL = event.HTMLEventData;
                        if ~isempty(resourceStaticURL)
                            app.General.AppVersion.application.resourceStaticURL = resourceStaticURL;
                        end

                    case 'auxApp.winAddTask.AntennaList_Tree'
                        ipcMainMatlabCallAuxiliarApp(app, 'TASK:ADD', 'MATLAB', 'deleteAddedAntenna')

                    otherwise
                        error('winAppColeta:UnexpectedEvent', 'Unexpected event "%s"', event.HTMLEventName)
                end
                drawnow

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = ipcMainMatlabCallsHandler(app, callingApp, eventName, varargin)
            varargout = {};

            try
                switch eventName
                    case 'closeFcn'
                        auxAppTag = varargin{1};
                        closeModule(app.tabGroupController, auxAppTag, app.General)

                    case 'dockButtonPushed'
                        auxAppTag = varargin{1};
                        varargout{1} = {app};

                        if strcmp(auxAppTag, 'TASK:ADD')
                            [auxAppIsOpen, auxAppHandle] = checkStatusModule(app.tabGroupController, auxAppTag);

                            if auxAppIsOpen
                                varargout{1} = {app, auxAppHandle.infoEdition};
                            end
                        end

                    case 'onUpdateLastVisitedFolder'
                        filePath = varargin{1};
                        updateLastVisitedFolder(app, filePath)

                    otherwise
                        switch class(callingApp)
                            % auxApp.winConfig (CONFIG)
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch eventName
                                    case 'checkDataHubLampStatus'
                                        updateWarningLampVisibility(app)

                                    case 'openDevTools'
                                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))
        
                                    case 'onAxesTileSpacingChange'
                                        tileSpacing = varargin{1};
                                        app.UIAxes1.Parent.TileSpacing = tileSpacing;
                
                                    case 'onPlotColorChange'
                                        error('pendente')
                                        plotTag = varargin{1};
                                        if ~isempty(eval(sprintf('app.PlotHandles.%s', plotTag)))
                                            app.PlotStyleDirty = true;
                                        end
                
                                    case 'onWaterfallColormapChange'
                                        waterfallColormap = varargin{1};
                                        colormap(app.UIAxes2, waterfallColormap)
        
                                    otherwise
                                        error('winAppColeta:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end

                            % auxApp.winTaskList (TASK:EDIT)
                            case {'auxApp.winTaskList', 'auxApp.winTaskList_exported'}
                                switch eventName
                                    case 'onTaskListEdit'
                                        app.taskList = class.taskList.rawFileParser(app.rootFolder, 'winAppColetaV2');
        
                                    otherwise
                                        error('winAppColeta:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end

                            % auxApp.winAddTask (TASK:ADD)
                            case {'auxApp.winAddTask', 'auxApp.winAddTask_exported'}
                                switch eventName
                                    case 'onTaskAddingOrEditing'
                                        auxAppTag   = varargin{1};
                                        infoEdition = varargin{2};
                                        newTask     = varargin{3};
                
                                        closeModule(app.tabGroupController, auxAppTag, app.General)
                
                                        % O try/catch possibilita a inclusão do progressDialog sem que 
                                        % exista o risco dele ficar visível, caso ocorra algum erro não
                                        % mapeado no método da classe.
                                        try
                                            app.progressDialog.Visible = 'visible';
                                            [app.TaskController.Tasks, msgError]    = AddOrEditTask(app.TaskController.Tasks, infoEdition, newTask, app.EMSatObj, app.ERMxObj);
                                            app.progressDialog.Visible = 'hidden';
                            
                                            if isempty(msgError)
                                                taskSchedulerTimerFcn(app)                                 % Startup of every task
                                            else
                                                ui.Dialog(app.UIFigure, 'warning', msgError);
                                            end
                                        catch ME
                                            struct2table(ME.stack)
                                        end

                                    otherwise
                                        error('winAppColeta:UnexpectedCall', 'Unexpected call "%s"', eventName)
                                end

                            otherwise
                                error('winAppColeta:UnexpectedCaller', 'Unexpected caller "%s"', class(callingApp))
                        end
                end                

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);            
            end
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallAuxiliarApp(app, auxAppName, communicationType, varargin)
            hAuxApp = getAppHandle(app.tabGroupController, auxAppName);

            if ~isempty(hAuxApp)
                switch communicationType
                    case 'MATLAB'
                        operationType = varargin{1};
                        ipcSecondaryMatlabCallsHandler(hAuxApp, app, operationType, varargin{2:end});
                    case 'JS'
                        event = varargin{1};
                        ipcSecondaryJSEventsHandler(hAuxApp, event)
                end
            end
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabOpenPopupApp(app, callingApp, auxAppName, context, varargin)
            arguments
                app
                callingApp
                auxAppName char {mustBeMember(auxAppName, {'Tracking'})}
                context    char {mustBeMember(context, {'mainApp', 'TASK:VIEW', 'TASK:EDIT', 'TASK:ADD', 'INSTRUMENT', 'SERVER', 'CONFIG'})}
            end

            arguments (Repeating)
                varargin 
            end

            requestVisibilityChange(callingApp.progressDialog, 'visible', 'unlocked')
            inputArguments = [{app, callingApp, context}, varargin];

            if app.General.operationMode.Debug
                app.popupCurrentApp = eval(sprintf('auxApp.dock%s(inputArguments{:})', auxAppName));
                app.popupCurrentApp.isDocked = false;

            else
                popupSpecifications = table( ...
                    'Size', [15, 4], ...
                    'VariableTypes', {'string', 'double', 'double', 'logical'}, ...
                    'VariableNames', {'AuxAppName', 'Width', 'Height', 'IsFluid'} ...
                );
                popupSpecifications(1, :) = {"Tracking", 622, 302, false};

                auxAppNameIdx = find(popupSpecifications.AuxAppName == string(auxAppName), 1);
                screenWidth = popupSpecifications.Width(auxAppNameIdx);
                screenHeight = popupSpecifications.Height(auxAppNameIdx);
                isFluid = popupSpecifications.IsFluid(auxAppNameIdx);

                ui.PopUpContainer(callingApp, screenWidth, screenHeight)
                auxDockAppName = sprintf('auxApp.dock%s', auxAppName);
                app.popupCurrentApp = feval([auxDockAppName '_exported'], callingApp.popupContainer, inputArguments{:});
                
                ui.CustomizationBase.getElementsDataTag({
                    callingApp.popupContainer;
                    app.popupCurrentApp.GridLayout
                });

                if isFluid
                    sizing = struct('type', 'fluid', 'width', 90, 'height', 80);
                else
                    sizing = struct('type', 'fixed', 'width', screenWidth, 'height', screenHeight+31);
                end

                sendEventToHTMLSource(callingApp.jsBackDoor, 'dockContainer', struct( ...
                    'dockAppName', auxDockAppName, ...
                    'dockAppDataTag', app.popupCurrentApp.GridLayout.UserData.id, ...
                    'dockAppContainerDataTag', callingApp.popupContainer.UserData.id, ...
                    'sizing', sizing, ...
                    'context', context, ...
                    'numCanvasElements', numel(findobj(app.popupCurrentApp.Container, 'Type', 'axes')) ...
                ))

                app.popupCurrentApp.GridLayout.UserData.auxDockAppName = auxDockAppName;
                callingApp.popupContainer.UserData.auxDockAppName = auxDockAppName;
            end

            requestVisibilityChange(callingApp.progressDialog, 'hidden', 'unlocked')
        end
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function navigateToTab(app, clickedButton)
            onTabNavigatorButtonPushed(app, struct('Source', clickedButton, 'PreviousValue', false))
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            if app.SubTabGroup.UserData.isTabInitialized(tabIndex)
                return
            end
            app.SubTabGroup.UserData.isTabInitialized(tabIndex) = true;

            switch tabIndex
                case 1
                    appName = class(app);
                    elToModify = {
                        app.Tab1Button;
                        app.Tab2Button;
                        app.Tab3Button;
                        app.Tab4Button;
                        app.Tab5Button;
                        app.Tab6Button;
                        ...
                        app.SpectrumFlowList;
                        app.MetaData;
                        app.AxesToolbar;
                        ...
                        app.tool_LeftPanel;
                        app.tool_ButtonPlay;
                        app.tool_ButtonDel;
                        app.tool_ButtonLOG
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.MetaData, appName);
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AxesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
                            struct('appName', appName, 'dataTag', app.SpectrumFlowList.UserData.id, 'selector', 'input', 'styleImportant', struct('height', '44px'), 'dropDownBackgroundColor', struct('items', 'rgba(183, 49, 44, 0.75)', 'selectedItem', 'rgb(108, 4, 4)')), ...
                            struct('appName', appName, 'dataTag', app.tool_LeftPanel.UserData.id,   'tooltip', struct('defaultPosition', 'top', 'textContent', 'Visibilidade do painel à esquerda')), ...
                            struct('appName', appName, 'dataTag', app.tool_ButtonPlay.UserData.id,  'tooltip', struct('defaultPosition', 'top', 'textContent', 'Inicia ou interrompe tarefa')), ...
                            struct('appName', appName, 'dataTag', app.tool_ButtonDel.UserData.id,   'tooltip', struct('defaultPosition', 'top', 'textContent', 'Exclui tarefa')), ...
                            struct('appName', appName, 'dataTag', app.tool_ButtonLOG.UserData.id,   'tooltip', struct('defaultPosition', 'top', 'textContent', 'LOG tarefa')) ...
                        });
                    catch
                    end

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function loadConfigurationFile(app, appName, MFilePath)
            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appEngine.util.generalSettingsLoad(appName, app.rootFolder);
            if ~isempty(msgWarning)
                ui.Dialog(app.UIFigure, 'error', msgWarning);
            end

            % Para criação de arquivos temporários, cria-se uma pasta da 
            % sessão.
            tempDir = tempname;
            mkdir(tempDir)
            app.General_I.fileFolder.tempPath  = tempDir;
            app.General_I.fileFolder.MFilePath = MFilePath;
            app.General_I.stationInfo.Computer = appEngine.util.OperationSystem("computerName");

            switch app.executionMode
                case 'webApp'
                    % Força a exclusão do SplashScreen do MATLAB Web Server.
                    sendEventToHTMLSource(app.jsBackDoor, "delProgressDialog");

                    app.General_I.operationMode.Debug = false;
                    app.General_I.operationMode.Dock  = true;
                    
                    % A pasta do usuário não é configurável, mas obtida por 
                    % meio de chamada a uiputfile. 
                    app.General_I.fileFolder.userPath = tempDir;

                otherwise    
                    % Resgata a pasta de trabalho do usuário (configurável).
                    userPaths = appEngine.util.UserPaths(app.General_I.fileFolder.userPath);
                    app.General_I.fileFolder.userPath = userPaths{end};

                    switch app.executionMode
                        case 'desktopStandaloneApp'
                            app.General_I.operationMode.Debug = false;
                        case 'MATLABEnvironment'
                            app.General_I.operationMode.Debug = true;
                    end
            end

            app.General = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')

            % Ideia é identificar URL de pasta estática servida pelo backend, de 
            % forma que possam ser inseridas imagens em uilabel (como ui.TextView).
            try
                [~, resourceName, resourceExt] = fileparts(app.tool_ButtonPlay.ImageSource);
                sendEventToHTMLSource(app.jsBackDoor, 'findResourceStaticURL', struct('resourceName', [resourceName resourceExt], 'resourceTag', 'img', 'resourceId', app.tool_ButtonPlay.UserData.id))
            catch
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % Um dos arquivos que compõem a subpasta "config", copiada para
            % "ProgramData/ANATEL/appColeta" na primeira execução, é o arquivo 
            % "taskList.json".
            app.taskList = class.taskList.rawFileParser(app.rootFolder, 'winAppColetaV2');

            % Others...
            app.receiverObj = model.Receiver(app.rootFolder);
            app.gpsObj = model.GPS(app.rootFolder);            
            app.EB500Obj = class.EB500Lib(app.rootFolder);
            app.EMSatObj = class.EMSatLib(app.rootFolder);
            app.ERMxObj = class.ERMxLib(app.rootFolder);            

            app.TaskController = model.TaskController(app);
            registerTaskControllerListeners(app)

            if app.General.tcpServer.Status
                try
                    app.tcpServer = class.tcpServerLib(app);
                catch
                    app.tcpServer = [];
                end
            end

            resetRestoreView(app)
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            app.tabGroupController = ui.TabNavigator(app.NavBar, app.TabGroup, app.progressDialog, app.jsBackDoor);
            addComponent(app.tabGroupController, "Built-in", "",                     app.Tab1Button, "AlwaysOn", struct('On', '', 'Off', ''), matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winInstrument", app.Tab2Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      2)
            addComponent(app.tabGroupController, "External", "auxApp.winTaskList",   app.Tab3Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      3)
            addComponent(app.tabGroupController, "External", "auxApp.winAddTask",    app.Tab4Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      4)
            addComponent(app.tabGroupController, "External", "auxApp.winServer",     app.Tab5Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      5)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",     app.Tab6Button, "AlwaysOn", struct('On', '', 'Off', ''), app.Tab1Button,                      6)
            app.tabGroupController.inlineSVG = true;

            app.axesTool_MinHold.UserData    = struct('id', '', 'status', false, 'icon', struct('On', 'MinHold_32Filled.png', 'Off', 'MinHold_32.png'));
            app.axesTool_Average.UserData    = struct('id', '', 'status', false, 'icon', struct('On', 'Average_32Filled.png', 'Off', 'Average_32.png'));
            app.axesTool_MaxHold.UserData    = struct('id', '', 'status', false, 'icon', struct('On', 'MaxHold_32Filled.png', 'Off', 'MaxHold_32.png'));
            app.axesTool_Peak.UserData       = struct('id', '', 'status', false);
            app.axesTool_Waterfall.UserData  = struct('id', '', 'status', false);
            
            initializeAxes(app)

            % Customiza uitable, atualizando-se em seguida.
            addStyle(app.UITable, uistyle("Interpreter", "html"));
            addStyle(app.UITable, uistyle("HorizontalAlignment", "center"), "column", 7);
            app.UITable.RowName = 'numbered';
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateWarningLampVisibility(app)
            createTaskSchedulerTimer(app)

            if app.General.startupInfo
                restoreTasksFromFile(app)
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function refreshTaskTable(app, selectedTaskIdx)
            arguments
                app
                selectedTaskIdx = []
            end

            taskTable = table( ...
                'Size', [0, 7], ...
                'VariableTypes', {'string', 'string', 'string', 'string', 'string', 'string', 'cell'}, ...
                'VariableNames', {'Name', 'Receiver', 'Created', 'BeginTime', 'EndTime', 'Status', 'Operation'} ...
            );
            
            for taskIdx = 1:numel(app.TaskController.Tasks)
                endedAt = '-';
                if ~isnat(app.TaskController.Tasks(taskIdx).Timing.endedAt) && ~isinf(app.TaskController.Tasks(taskIdx).Timing.endedAt)
                    endedAt = datestr(app.TaskController.Tasks(taskIdx).Timing.endedAt, 'dd/mm/yyyy HH:MM:SS');
                end

                operation = {
                    sprintf('<a href="matlab:evalin(''base'', ''ipcMainJSEventsHandler(%s, struct(''''HTMLEventName'''', ''''onStartTaskRequest'''',   ''''HTMLEventData'''', %d))'')">▶&ensp;</a>', app.appHandleNameInBase, taskIdx);
                    sprintf('<a href="matlab:evalin(''base'', ''ipcMainJSEventsHandler(%s, struct(''''HTMLEventName'''', ''''onStopTaskRequest'''',    ''''HTMLEventData'''', %d))'')">⬛</a>', app.appHandleNameInBase, taskIdx);
                    sprintf('<a href="matlab:evalin(''base'', ''ipcMainJSEventsHandler(%s, struct(''''HTMLEventName'''', ''''onDeleteTaskRequest'''',  ''''HTMLEventData'''', %d))'')">❌</a>', app.appHandleNameInBase, taskIdx);
                    sprintf('<a href="matlab:evalin(''base'', ''ipcMainJSEventsHandler(%s, struct(''''HTMLEventName'''', ''''onViewLogRequest'''',     ''''HTMLEventData'''', %d))'')">≡ Log</a>', app.appHandleNameInBase, taskIdx)
                };

                if strcmp(app.TaskController.Tasks(taskIdx).Status, 'Em andamento')
                    operation(1) = [];
                else
                    operation(2) = [];
                end
        
                taskTable(end+1,:) = { ...
                    app.TaskController.Tasks(taskIdx).TaskSpec.Script.Name, ...
                    app.TaskController.Tasks(taskIdx).ReceiverId, ...
                    app.TaskController.Tasks(taskIdx).Timing.createdAt, ...
                    datestr(app.TaskController.Tasks(taskIdx).Timing.startedAt, 'dd/mm/yyyy HH:MM:SS'), ...
                    endedAt, ...
                    app.TaskController.Tasks(taskIdx).Status, ...
                    strjoin(operation, '&emsp;') ...
                };
            end

            if ~isempty(taskTable)
                if isempty(selectedTaskIdx) || selectedTaskIdx > height(taskTable)
                    selectedTaskIdx = 1;
                end
            end

            set(app.UITable, 'Data', taskTable, 'Selection', selectedTaskIdx)
            updateErrorCount(app, app.UITable.Selection)
        
            selectedBandIdx = 1;
            loadSelectedTask(app, selectedBandIdx)
            updateToolbar(app)
            
            drawnow
        end

        %-----------------------------------------------------------------%
        function loadSelectedTask(app, selectedBandIdx)
            taskTable = app.UITable.Data;
            taskIdx = app.UITable.Selection;

            cellStyleIdxs = find(app.UITable.StyleConfigurations.Target == "cell");
            if ~isempty(cellStyleIdxs)
                removeStyle(app.UITable, cellStyleIdxs)
            end

            if ~isempty(taskTable) && ~isempty(taskIdx)
                addStyle(app.UITable, uistyle('Icon', 'eye.svg', 'IconAlignment', 'rightmargin'), 'cell', [taskIdx, 1])

                numBands = numel(app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band);
                items = {};

                for bandIdx = 1:numBands
                    if bandIdx < 10
                        charSpace = '&emsp;&emsp;&ensp;';
                    else
                        charSpace = '&emsp;&emsp;&emsp;';
                    end


                    antenna = app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrAntenna;
                    if ~isempty(antenna)
                        antenna = sprintf('(%s)', antenna);
                    end
                    
                    items{end+1} = sprintf('ID %d: %.3f – %.3f MHz %s<br>%s%d pts&nbsp;&nbsp;•&nbsp;&nbsp;%s&nbsp;&nbsp;•&nbsp;&nbsp;%s', ...
                         app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).ID, ...
                         app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStart / 1e+6, ...
                         app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStop  / 1e+6, ...
                         antenna, ...
                         charSpace, ...
                         app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrDataPoints, ...
                         app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrResolution, ...
                         app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrDetector ...
                     );
                end
                
                if isempty(app.SpectrumFlowList.StyleConfigurations)
                    addStyle(app.SpectrumFlowList, uistyle('Interpreter', 'html'))
                end

                set(app.SpectrumFlowList, 'Items', items, 'ItemsData', 1:numBands, 'Value', selectedBandIdx)

            else
                removeStyle(app.SpectrumFlowList)
                app.SpectrumFlowList.Items = {};
            end

            onBandSelectionChanged(app)
            drawnow
        end

        %-----------------------------------------------------------------%
        function loadSelectedBand(app, taskIdx, bandIdx)
            taskTable = app.UITable.Data;
            hasSelection = ~isempty(taskTable) && ~isempty(taskIdx);

            resetPlotState(app)
            updatePlotSourceOptions(app, taskIdx, bandIdx);

            updateTaskMetaData(app)
            updateMaskStatus(app, true, taskIdx, bandIdx)

            if hasSelection
                if ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall)
                    waterfallIdx = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.idx;

                    if waterfallIdx
                        updatePlot(app, taskIdx, bandIdx)
                    end
                end

                if ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).File)
                    recordedSweeps = app.TaskController.Tasks(taskIdx).Bands(bandIdx).File.WritedSamples;
                else
                    recordedSweeps = -1;
                end
                app.Sweeps.Text = string(recordedSweeps);

                if ~contains(app.TaskController.Tasks(taskIdx).TaskSpec.Type, 'PRÉVIA') && strcmp(app.TaskController.Tasks(taskIdx).Status, 'Em andamento') && app.TaskController.Tasks(taskIdx).Bands(bandIdx).Status
                    app.RecordingIcon.Visible = 'on';
                else
                    app.RecordingIcon.Visible = 'off';
                end

                updateGPSStatus(app, app.TaskController.Tasks(taskIdx).GPSLastFix)

                app.tool_RevisitTime.Text = sprintf('%d varreduras\n%.3f seg', app.TaskController.Tasks(taskIdx).Bands(bandIdx).nSweeps, app.TaskController.Tasks(taskIdx).Bands(bandIdx).RevisitTime);

                switch app.TaskController.Tasks(taskIdx).Status
                    case 'Na fila'
                        set(app.tool_ButtonPlay, 'Enable', 'off', 'ImageSource', 'play_32.png')
                    case 'Em andamento'
                        set(app.tool_ButtonPlay, 'Enable', 'on',  'ImageSource', 'stop_32.png')
                    otherwise
                        set(app.tool_ButtonPlay, 'Enable', 'on',  'ImageSource', 'play_32.png')
                end

            else
                app.Sweeps.Text = string(-1);
                app.RecordingIcon.Visible = 'off';
                updateGPSStatus(app, [])
                app.tool_RevisitTime.Text = '';
            end
        end

        %-----------------------------------------------------------------%
        function updateTaskMetaData(app)
            taskTable = app.UITable.Data;
            taskIdx = app.UITable.Selection;
            bandIdx = app.SpectrumFlowList.Value;

            if ~isempty(taskTable) && ~isempty(taskIdx)
                app.MetaData.Text = util.HtmlTextGenerator.Task(app.TaskController.Tasks, app.TaskController.RevisitInfo, taskIdx, bandIdx);
            else
                app.MetaData.Text = '';
            end
        end

        %-----------------------------------------------------------------%
        function updateErrorCount(app, taskIdx)
            if ~isempty(taskIdx) && app.TaskController.Tasks(taskIdx).RetryPolicy.receiver.failureCount
                set(app.ReceiverErrorCount, 'Text', string(app.TaskController.Tasks(taskIdx).RetryPolicy.receiver.failureCount), 'Visible', 'on')
                app.ReceiverErrorCountIcon.Visible = 'on';
            else
                set(app.ReceiverErrorCount, 'Text', '0', 'Visible', 'off')
                app.ReceiverErrorCountIcon.Visible = 'off';
            end
        end

        %-----------------------------------------------------------------%
        function updateGPSStatus(app, gpsData)
            if isempty(gpsData)
                app.GPSLastFix.Text = {'<b style="color: #a2142f; font-size: 14;">-1.000</b> LAT '; '<b style="color: #a2142f; font-size: 14;">-1.000</b> LON '; 'dd-mmm-yyyy '; 'HH:MM:SS '};
                app.GPSLastFixIcon.Color = [0.50,0.50,0.50];
                return
            end

            switch gpsData.Status
                case  1
                    iconColor = [0.47,0.67,0.19];
                case  0
                    iconColor = [0.64,0.08,0.18];
                case -1
                    iconColor = [0.50,0.50,0.50];
            end
        
            app.GPSLastFix.Text = sprintf([ ...
                '<b style="color: #a2142f; font-size: 14;">%.3f</b> LAT \n' ...
                '<b style="color: #a2142f; font-size: 14;">%.3f</b> LON \n' ...
                '%s \n%s ' ...
            ], gpsData.Latitude, gpsData.Longitude, extractBefore(gpsData.TimeStamp, ' '), extractAfter(gpsData.TimeStamp, ' '));
            app.GPSLastFixIcon.Color = iconColor;
        end

        %-----------------------------------------------------------------%
        function updateMaskStatus(app, maskTrigger, taskIdx, bandIdx)
            hasMask = ~isempty(taskIdx) && ~isempty(bandIdx) && ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask);

            if ~hasMask
                app.MaskStatus.Enable = 0;
                app.MaskStatus.Text = {
                    '<b style="color: #a2142f; font-size: 14;">-1</b> ';
                    'VALIDAÇÕES '; '<b style="color: #a2142f; font-size: 14;">-1</b> ';
                    'ROMPIMENTOS '; '<font style="color: #a2142f;">-1.000 MHz ';
                    '⌂ -1.0 kHz ';
                    'Ʌ -1.0 dB </font>';
                    'dd-mmm-yyyy ';
                    'HH:MM:SS '
                };
                return
            end

            app.MaskStatus.Enable = 1;
            validations = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Validations;
            brokenCount = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.BrokenCount;

            if maskTrigger
                if ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Peaks)
                    numPeaks = sprintf(' (%d)', height(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Peaks));
                    freqCenter = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Peaks.FreqCenter(1);
                    bandWidth = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Peaks.BW(1);
                    prominence = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Peaks.Prominence(1);
                    dayTimeStamp = extractBefore(char(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.TimeStamp), ' ');
                    hourTimeStamp = extractAfter(char(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.TimeStamp), ' ');
                else
                    numPeaks = '';
                    freqCenter = -1;
                    bandWidth = -1;
                    prominence = -1;
                    dayTimeStamp = 'dd-mmm-yyyy';
                    hourTimeStamp = 'HH:MM:SS';
                end
        
                app.MaskStatus.Text = sprintf([ ...
                    '<b style="color: #a2142f; font-size: 14;">%.0f</b> \nVALIDAÇÕES \n' ...
                    '<b style="color: #a2142f; font-size: 14;">%.0f%s</b> \nROMPIMENTOS \n' ...
                    '<font style="color: #a2142f;">%.3f MHz \n⌂ %.1f kHz \nɅ %.1f dB</font> \n%s \n%s ' ...
                ], validations, brokenCount, numPeaks, freqCenter, bandWidth, prominence, dayTimeStamp, hourTimeStamp);

            else
                app.MaskStatus.Text = replace(app.MaskStatus.Text, [extractBefore(app.MaskStatus.Text, 'VALIDAÇÕES') 'VALIDAÇÕES'], sprintf('<b style="color: #a2142f; font-size: 14;">%.0f</b> \nVALIDAÇÕES', validations));
            end
        end


        %-----------------------------------------------------------------%
        % ## PLOT CONTROLLER ##
        %-----------------------------------------------------------------%
        function resetPlotState(app)
            cla(app.UIAxes1)
            cla(app.UIAxes2)
            
            resetRestoreView(app)

            app.PlotHandles = struct( ...
                'ClearWrite', [], ...
                'MinHold', [], ...
                'Average', [], ...
                'MaxHold', [], ...
                'PeakExcursion', [], ...
                'Waterfall', [] ...
            );          
        end

        %-----------------------------------------------------------------%
        function resetRestoreView(app)
            app.RestoreView(1) = struct('Id', 'app.UIAxes1', 'XLim', [0, 1], 'YLim', [0, 1], 'CLim', 'auto');
            app.RestoreView(2) = struct('Id', 'app.UIAxes2', 'XLim', [0, 1], 'YLim', [0, 1], 'CLim', 'auto');
        end

        %-----------------------------------------------------------------%
        function updatePlotLayout(app)
            if app.axesTool_Waterfall.UserData.status
                set(findobj(app.UIAxes1), 'Visible', true)
                
                app.UIAxes1.Layout.Tile = 1;
                app.UIAxes1.Layout.TileSpan = [1 1];
                app.UIAxes1.XTickLabel = {};
                xlabel(app.UIAxes1, '')

                set(findobj(app.UIAxes2), 'Visible', true)
                app.UIAxes2.Layout.Tile = 2;
                app.UIAxes2.Layout.TileSpan = [2 1];

            else
                set(findobj(app.UIAxes1), 'Visible', true)

                app.UIAxes1.Layout.Tile = 1;
                app.UIAxes1.Layout.TileSpan = [3 1];
                app.UIAxes1.XTickLabelMode = 'auto';
                xlabel(app.UIAxes1, 'Frequência (MHz)')
                
                set(findobj(app.UIAxes2), 'Visible', false)
                app.UIAxes2.Layout.Tile = 4;
                app.UIAxes2.Layout.TileSpan = [1 1];
            end

            cb = findobj(app.UIAxes2.Parent.Children, 'Type', 'colorbar');
            if ~isempty(cb)
                cb.Visible = app.axesTool_Waterfall.UserData.status;
            end
        end

        %-----------------------------------------------------------------%
        function updatePlotSourceOptions(app, taskIdx, bandIdx)
            sources = {'Nível'};

            if ~isempty(taskIdx) && ~isempty(bandIdx) && taskIdx > 0 && bandIdx > 0
                if contains(app.TaskController.Tasks(taskIdx).TaskSpec.Type, 'Drive-test (Level+Azimuth)')
                    sources{end+1} = 'Azimute';
                end
    
                % Se a tarefa for "Rompimento de Máscara Espectral" e o Status for 
                % maior do que zero, então o campo "Mask" será diferente de vazio.
                if ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask)
                    sources{end+1} = 'Máscara';
                end
            end

            set(app.axesTool_PlotSource, 'Items', sources, 'Enable', numel(sources) > 1)
            updateToolbar(app)
        end

        %-----------------------------------------------------------------%
        function [xArray, downYLim, upYLim, freqStart, freqStop, levelUnit, strUnit] = getPlotParameters(app, taskIdx, bandIdx, newArray)
            % xArray
            freqStart = app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStart / 1e+6;
            freqStop  = app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStop  / 1e+6;
            levelUnit = app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrLevelUnit;
            xArray    = linspace(freqStart, freqStop, app.TaskController.Tasks(taskIdx).Bands(bandIdx).DataPoints);
    
            % General settings
            [~, strUnit] = class.Constants.yAxisUpLimit(app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrLevelUnit);
    
            [downYLim, upYLim] = bounds(newArray);
            downYLim  = downYLim - mod(downYLim, 10);
            upYLim    = upYLim + 10 - mod(upYLim, 10);        
            diffArray = upYLim - downYLim;
    
            if diffArray < class.Constants.yMinLimRange
                upYLim = downYLim + class.Constants.yMinLimRange;        
            elseif diffArray > class.Constants.yMaxLimRange
                downYLim = upYLim - class.Constants.yMaxLimRange;
            end
        end

        %-----------------------------------------------------------------%
        function updatePlot(app, taskIdx, bandIdx)
            waterfallIdx = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.idx;
            newArray = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.Matrix(waterfallIdx, :);

            if app.PlotStyleDirty
                app.PlotStyleDirty = false;

                cla(app.UIAxes1)
                app.PlotHandles.ClearWrite = [];
            end
        
            if isempty(app.PlotHandles.ClearWrite)
                [xArray, downYLim, upYLim, freqStart, freqStop, LevelUnit, strUnit] = getPlotParameters(app, taskIdx, bandIdx, newArray);

                switch app.axesTool_PlotSource.Value
                    case 'Nível'
                        % ORDINARY PLOT (SPECTRUM + MASK THRESHOLD)
                        ylabel(app.UIAxes1, sprintf('Nível (%s)', strUnit));
                        set(app.UIAxes1, XLim=[freqStart, freqStop], YLim=[downYLim, upYLim], YScale='linear')
            
                        % Mask threshold
                        if ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask)
                            plot.draw2D.mask(app.UIAxes1, app.TaskController.Tasks(taskIdx), bandIdx)
                        end
                
                        % ClearWrite, MinHold, Average and MaxHold
                        app.PlotHandles.ClearWrite = plot.draw2D.clearWrite(app.UIAxes1, xArray, newArray, LevelUnit, 'ClrWrite', app.General);
                        
                        if app.axesTool_MinHold.UserData.status
                            app.PlotHandles.MinHold  = plot.draw2D.minHold(app.UIAxes1, app.TaskController.Tasks(taskIdx), bandIdx, xArray, newArray, LevelUnit, app.General);
                        end
                
                        if app.axesTool_Average.UserData.status
                            app.PlotHandles.Average  = plot.draw2D.Average(app.UIAxes1, app.TaskController.Tasks(taskIdx), bandIdx, xArray, newArray, LevelUnit, app.General);
                        end
                
                        if app.axesTool_MaxHold.UserData.status
                            app.PlotHandles.MaxHold  = plot.draw2D.maxHold(app.UIAxes1, app.TaskController.Tasks(taskIdx), bandIdx, xArray, newArray, LevelUnit, app.General);
                        end
            
                        if app.axesTool_Peak.UserData.status
                            app.PlotHandles.PeakExcursion = plot.draw2D.peakExcursion(app.PlotHandles.PeakExcursion, app.PlotHandles.ClearWrite, app.TaskController.Tasks(taskIdx), bandIdx, newArray);
                        end

                    case 'Azimute'
                        ylabel(app.UIAxes1, 'Azimute (º)');
                        set(app.UIAxes1, XLim=[freqStart, freqStop], YLim=[0, 360], YScale='linear')

                        app.PlotHandles.ClearWrite = plot.draw2D.clearWrite(app.UIAxes1, xArray, app.TaskController.Tasks(taskIdx).Bands(bandIdx).Azimuth, LevelUnit, 'ClrWrite', app.General, 'Marker', '.', 'MarkerSize', 12, 'LineStyle', 'none');

                    case 'Máscara'
                        ylabel(app.UIAxes1, 'Rompimento (%)');
                        set(app.UIAxes1, XLim=[freqStart, freqStop], YLim=[.1, 100], YScale='log')
            
                        KK = 100/app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Validations;
                        app.PlotHandles.ClearWrite = plot.draw2D.clearWrite(app.UIAxes1, xArray, KK.*app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.BrokenArray, '%%', 'MaskPlot', app.General, 'Marker', '.', 'MarkerSize', 12, 'LineStyle', 'none');
                end
                
                app.RestoreView(1).XLim = app.UIAxes1.XLim;
                app.RestoreView(1).YLim = app.UIAxes1.YLim;

            else
                switch app.axesTool_PlotSource.Value
                    case 'Nível'
                        plot.draw2D.update(app.PlotHandles.ClearWrite, newArray, app.General)
                        
                        if ~isempty(app.PlotHandles.MinHold)
                            plot.draw2D.update(app.PlotHandles.MinHold, newArray, app.General)
                        end
                        
                        if ~isempty(app.PlotHandles.Average)
                            plot.draw2D.update(app.PlotHandles.Average, newArray, app.General)
                        end
                        
                        if ~isempty(app.PlotHandles.MaxHold)
                            plot.draw2D.update(app.PlotHandles.MaxHold, newArray, app.General)
                        end
    
                        if ~isempty(app.PlotHandles.PeakExcursion)
                            app.PlotHandles.PeakExcursion = plot.draw2D.peakExcursion(app.PlotHandles.PeakExcursion, app.PlotHandles.ClearWrite, app.TaskController.Tasks(taskIdx), bandIdx, newArray);
                        end

                    case 'Azimute'
                        plot.draw2D.update(app.PlotHandles.ClearWrite, app.TaskController.Tasks(taskIdx).Bands(bandIdx).Azimuth, app.General)

                    case 'Máscara'
                        KK = 100/app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.Validations;
                        plot.draw2D.update(app.PlotHandles.ClearWrite, KK.*app.TaskController.Tasks(taskIdx).Bands(bandIdx).Mask.BrokenArray, app.General)
                end
            end

            % Waterfall
            if app.axesTool_Waterfall.UserData.status
                if isempty(app.PlotHandles.Waterfall)
                    if ~exist('xArray', 'var')
                        [xArray, downYLim, upYLim, freqStart, freqStop] = getPlotParameters(app, taskIdx, bandIdx, newArray);
                    end
                    set(app.UIAxes2, 'YLim', [1, app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.Depth], 'View', [0, 90], 'CLim', [downYLim, upYLim])

                    app.RestoreView(2).XLim = [freqStart, freqStop];
                    app.RestoreView(2).YLim = app.UIAxes2.YLim;
                    app.RestoreView(2).CLim = app.UIAxes2.CLim;

                    app.PlotHandles.Waterfall = plot.draw3D.Waterfall(app.UIAxes2, app.TaskController.Tasks(taskIdx), bandIdx, xArray);
                else
                    app.PlotHandles.Waterfall.CData = circshift(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.Matrix, -waterfallIdx);
                end
            end
        end

        %-----------------------------------------------------------------%
        function updateToolbar(app)
            hasTask = ~isempty(app.TaskController.Tasks);
            isLevel = strcmp(app.axesTool_PlotSource.Value, 'Nível');

            set([ ...
                app.tool_ButtonPlay, ...
                app.tool_ButtonDel, ...
                app.tool_ButtonLOG ...
            ], 'Enable', hasTask)

            set([ ...
                app.axesTool_MinHold, ...
                app.axesTool_Average, ...
                app.axesTool_MaxHold, ...
                app.axesTool_Peak ...
            ], 'Enable', isLevel)
        end


        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO E CICLO DE VIDA
        %-----------------------------------------------------------------%
        function initializeAxes(app)
            axesContainer = tiledlayout(app.AxesContainer, 3, 1, "Padding", "compact", "TileSpacing", "compact");

            app.UIAxes1 = plot.axesCreation(axesContainer, 'Cartesian', {'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes1.Layout.Tile = 1;
            app.UIAxes1.Layout.TileSpan = [3,1];
            
            app.UIAxes2 = plot.axesCreation(axesContainer, 'Cartesian', {'Visible', 0, 'Layer', 'top', 'Box', 'on', 'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.UIAxes2.Layout.Tile = 4;

            colormap(app.UIAxes2, app.General.Plot.Waterfall.Colormap);
            plot.axesColorbar(app.UIAxes2, "eastoutside", {'Visible', false})

            xlabel(app.UIAxes1, 'Frequência (MHz)')
            ylabel(app.UIAxes1, 'Nível (dB)')
            ysecondarylabel(app.UIAxes1, sprintf('\n\n'))
            
            xlabel(app.UIAxes2, 'Frequência (MHz)')
            ylabel(app.UIAxes2, 'Amostras')

            linkaxes([app.UIAxes1, app.UIAxes2], 'x')

            plot.axesInteractivity.DefaultCreation([app.UIAxes1, app.UIAxes2], [dataTipInteraction, regionZoomInteraction, rulerPanInteraction])
        end

        %-----------------------------------------------------------------%
        function restoreTasksFromFile(app)
            [~, programDataFolder] = appEngine.util.Path(class.Constants.appName, app.rootFolder);
            if isfile(fullfile(programDataFolder, 'taskListState.mat'))
                app.progressDialog.Visible = 'visible';

                load(fullfile(programDataFolder, 'taskListState.mat'), 'tasks');

                % É possível que o MATLAB não consiga instancionar o objeto
                % "model.Task", lendo-o como "uint32", o que inviabiliza 
                % o aproveitamento da informação salva...

                % Warning: Variable 'Tasks' originally saved as a model.Task cannot be instantiated as an object and will be read in as a uint32.

                if exist('Tasks', 'var') && isa(tasks, 'model.Task') && ~isempty(tasks)
                    for ii = 1:numel(tasks)
                        tasks(ii) = initializeTaskReceiver(tasks(ii));
                        tasks(ii) = resolveStreamingHandle(app.TaskController, tasks(ii));
                        tasks(ii) = resolveGpsHandle(app.TaskController, tasks(ii));

                        if ismember(tasks(ii).Status, {'Na fila', 'Em andamento'})
                            tasks(ii).Status = 'Erro';
                        end
                    end

                    app.TaskController.Tasks = tasks;
                    refreshTaskTable(app)

                    % Ida ao modo de "Execução das tarefas da monitoração"
                    % de forma programática:
                    app.Tab1Button.Value = 1;
                    onTabNavigatorButtonPushed(app, struct('Source', app.Tab1Button, 'PreviousValue', 0))
                end

                app.progressDialog.Visible = 'hidden';
            end

            function [task, msgError] = initializeTaskReceiver(task)
                % Função quase idêntica a model.Receiver.testConnectivity.
                % Uso de informação constante no objeto "model.Task" ao
                % invés da constante em arquivo "instrumentList.json".
    
                receiver = getReceiverConfig(task);
                [idx, msgError] = connect(app.receiverObj, receiver);
                
                if isempty(msgError)
                    task.TaskSpec.Receiver.Handle = app.receiverObj.Table.Handle{idx};
                    task.Connections.receiver = task.TaskSpec.Receiver.Handle;
                end
            end
        end

        %-----------------------------------------------------------------%
        function saveTasksToFile(app)
            tasks = copy(app.TaskController.Tasks);
            
            for ii = 1:numel(tasks)
                tasks(ii).Connections.receiver = [];
                tasks(ii).Connections.stream = [];
                tasks(ii).Connections.gps = [];

                tasks(ii).TaskSpec.Receiver.Handle = [];
                tasks(ii).TaskSpec.Streaming.Handle = [];
                tasks(ii).TaskSpec.GPS.Handle = [];
            end

            [~, programDataFolder] = appEngine.util.Path(class.Constants.appName, app.rootFolder);
            save(fullfile(programDataFolder, 'taskListState.mat'), 'tasks')
        end

        %-----------------------------------------------------------------%
        % TIMER 
        %-----------------------------------------------------------------%
        function createTaskSchedulerTimer(app)
            app.TaskSchedulerTimer = timer("ExecutionMode", "fixedRate", "Period", 10, "TimerFcn", @(~,~) taskSchedulerTimerFcn(app));
            start(app.TaskSchedulerTimer)
        end

        %-----------------------------------------------------------------%
        function taskSchedulerTimerFcn(app)
            if ~app.TaskController.IsRunning
                runLoop(app.TaskController)
            end

            % Validação que garante sincronismo entre tarefas e a sua
            % disposição na tabela da GUI.
            if numel(app.TaskController.Tasks) ~= height(app.UITable.Data)
                refreshTaskTable(app, app.UITable.Selection)
            end
        end


        %-----------------------------------------------------------------%
        % REGISTRO DOS LISTENERS E SEUS CALLBACKS
        %-----------------------------------------------------------------%
        function registerTaskControllerListeners(app)
            % Inscreve o app nos eventos disparados por "app.TaskController"
            % (model.TaskController), substituindo as antigas chamadas diretas
            % a métodos de interface dentro do loop de monitoração (antigo
            % "RegularTask_MainLoop" e demais funções "RegularTask_*" que
            % foram migradas para model.TaskController).

            addlistener(app.TaskController, 'StatusChanged',      @(~,~)   refreshTaskTable(app, app.UITable.Selection));
            addlistener(app.TaskController, 'TasksChanged',       @(~,~)   saveTasksToFile(app));
            addlistener(app.TaskController, 'BandDataAcquired',   @(~,evt) onTaskBandDataAcquired(evt));
            addlistener(app.TaskController, 'GpsUpdated',         @(~,evt) onTaskGpsUpdated(evt));
            addlistener(app.TaskController, 'ErrorRaised',        @(~,evt) onTaskErrorRaised(evt));
            addlistener(app.TaskController, 'RevisitInfoChanged', @(~,~)   updateTaskMetaData(app));

            function onTaskBandDataAcquired(evt)
                taskIdx = evt.TaskId;
                bandIdx = evt.BandId;
                maskTrigger = evt.Payload;
    
                if app.UITable.Selection == taskIdx
                    updateErrorCount(app, taskIdx)
    
                    if app.SpectrumFlowList.Value == bandIdx
                        updatePlot(app, taskIdx, bandIdx)
                        updateMaskStatus(app, maskTrigger, taskIdx, bandIdx)
                        app.tool_RevisitTime.Text = sprintf('%d varreduras\n%.3f seg', app.TaskController.Tasks(taskIdx).Bands(bandIdx).nSweeps, app.TaskController.Tasks(taskIdx).Bands(bandIdx).RevisitTime);
                        app.Sweeps.Text = string(app.TaskController.Tasks(taskIdx).Bands(bandIdx).File.WritedSamples);
                        drawnow
                    end
                end
            end
    
            function onTaskGpsUpdated(evt)
                taskIdx = evt.TaskId;
                gpsData = evt.Payload;
    
                % As coordenadas da estação - registradas em app.General.stationInfo
                % - são atualizadas apenas se a estação for do tipo móvel ("Mobile") 
                % e as novas coordenadas geográficas forem válidas.
                if strcmp(app.General.stationInfo.Type, 'Mobile') && gpsData.Status
                    app.General.stationInfo.Latitude  = gpsData.Latitude;
                    app.General.stationInfo.Longitude = gpsData.Longitude;
                end
    
                if app.UITable.Selection == taskIdx
                    updateGPSStatus(app, gpsData)
                end
            end

            function onTaskErrorRaised(evt)
                taskIdx = evt.TaskId;
    
                if app.UITable.Selection == taskIdx
                    updateErrorCount(app, taskIdx)
                end
                beep
            end
        end


        %-----------------------------------------------------------------%
        % MISCELÂNEAS
        %-----------------------------------------------------------------%
        function updateWarningLampVisibility(app)
            if isfolder(app.General.fileFolder.DataHub_POST)
                app.DataHubLamp.Visible = 0;
            else
                app.DataHubLamp.Visible = 1;
            end
        end

        %-----------------------------------------------------------------%
        function updateLastVisitedFolder(app, filePath)
            app.General_I.fileFolder.lastVisited = filePath;
            app.General.fileFolder.lastVisited   = filePath;

            appEngine.util.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General_I, app.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            try
                appEngine.boot(app, app.Role)
                
                % Registra handle deste app no workspace "base", o que possibilita 
                % excluir registros de tabelas por meio de cliques na uitable.
                app.appHandleNameInBase = ui.Table.exportAppHandleToBaseWorkspace(app);

            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            if strcmp(app.progressDialog.Visible, 'visible')
                app.progressDialog.Visible = 'hidden';
                return
            end

            if app.TaskController.IsRunning
                ui.Dialog(app.UIFigure, 'warning', 'Existe uma tarefa em execução...');
                return
            end

            if ~strcmp(app.executionMode, 'webApp')
                questionMsg = 'Deseja fechar o aplicativo?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            if app.General.startupInfo
                saveTasksToFile(app)
            else
                [~, programDataFolder] = appEngine.util.Path(class.Constants.appName, app.rootFolder);
                if isfile(fullfile(programDataFolder, 'taskListState.mat'))
                    delete(fullfile(programDataFolder, 'taskListState.mat'))
                end
            end

            if app.General.stationInfo.Type == "Mobile"
                appEngine.util.generalSettingsSave(class.Constants.appName, app.rootFolder, app.General_I, app.executionMode)
            end

            if ~isempty(app.tcpServer)
                delete(app.tcpServer.Server)
            end

            % Aspectos gerais (carregar em todos os apps):
            appEngine.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)
            
        end

        % Callback function: AppInfo, FigurePosition, Tab1Button, 
        % ...and 5 other components
        function onTabNavigatorButtonPushed(app, event)

            switch event.Source
                case {app.Tab1Button, app.Tab2Button, app.Tab3Button, app.Tab4Button, app.Tab5Button, app.Tab6Button}
                    clickedButton  = event.Source;
                    auxAppTag      = clickedButton.Tag;
                    inputArguments = resolveAuxAppInputArguments(auxAppTag);
        
                    if event.Source == app.Tab4Button
                        % A operação padrão, ao clicar em app.Tab4Button, é criar uma 
                        % nova tarefa. Caso esteja selecionado o módulo de visualização 
                        % de tarefas, e esteja selecionada uma tarefa, questiona-se se 
                        % deve ser feito a inclusão de uma nova tarefa ou a edição da 
                        % selecionada. 
                        idx = app.UITable.Selection;
        
                        if  ~checkStatusModule(app.tabGroupController, 'TASK:ADD') && app.Tab1Button.Value && ~isempty(idx)
                            msgQuestion   = 'Deseja criar uma nova tarefa, ou editar a tarefa selecionada em tabela?';
                            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Criar nova', 'Editar selecionada', 'Cancelar'}, 1, 3);
                            switch userSelection
                                case 'Editar selecionada'
                                    if ismember(app.TaskController.Tasks(idx).Status, {'Na fila', 'Em andamento'})
                                        ui.Dialog(app.UIFigure, 'warning', 'Uma tarefa no estado "Na fila" ou "Em andamento" não poderá ser editada.');
                                        app.Tab4Button.Value = 0;
                                        return
                                    end
        
                                    inputArguments = {app, struct('type', 'edit', 'idx', idx)};
        
                                case 'Cancelar'
                                    app.Tab4Button.Value = 0;
                                    return
                            end
                        end
                    end
        
                    openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, inputArguments{:})

                case app.FigurePosition
                    app.UIFigure.Position(3:4) = class.Constants.windowSize;
                    appEngine.util.setWindowPosition(app.UIFigure)
                    focus(findobj(app.NavBar.Children, 'Type', 'uistatebutton', 'Value', true))

                case app.AppInfo
                    appInfo = util.HtmlTextGenerator.AppInfo( ...
                        app.General, ...
                        app.rootFolder, ...
                        app.executionMode, ...
                        app.renderCount, ...
                        "popup" ...
                    );
                    ui.Dialog(app.UIFigure, 'info', appInfo);
            end

            function inputArguments = resolveAuxAppInputArguments(auxAppName)
                mustBeMember(auxAppName, {'TASK:VIEW', 'INSTRUMENT', 'TASK:EDIT', 'TASK:ADD', 'SERVER', 'CONFIG'})

                switch auxAppName
                    case 'TASK:ADD'
                        [~, idxApp] = ismember(auxAppName, app.tabGroupController.Components.Tag);
                        appHandle   = app.tabGroupController.Components.appHandle{idxApp};
                        if ~isempty(appHandle) && isvalid(appHandle)
                            inputArguments = {app, appHandle.infoEdition};
                        else
                            inputArguments = {app, struct('type', 'new')};
                        end
                    otherwise
                        inputArguments = {app};
                end
            end
            
        end

        % Selection changed function: UITable
        function onTaskSelectionChanged(app, event)

            if isempty(event.Selection)
                if ~isempty(event.PreviousSelection)
                    app.UITable.Selection = event.Selection;
                end

                return
            end

            loadSelectedTask(app, 1)
            
        end

        % Value changed function: SpectrumFlowList
        function onBandSelectionChanged(app, event)

            try
                taskIdx = app.UITable.Selection;
                bandIdx = app.SpectrumFlowList.Value;
                loadSelectedBand(app, taskIdx, bandIdx)

            catch ME
                if exist('event', 'var')
                    event.Source.Value = event.Source.PreviousValue;
                    onBandSelectionChanged(app)
                end

                ui.Dialog(app.UIFigure, 'error', getReport(ME));
            end
            drawnow

        end

        % Image clicked function: axesTool_RestoreView
        function onAxesToolbarRestoreViewImageClicked(app, event)
            
            set(app.UIAxes1, 'XLim', app.RestoreView(1).XLim, 'YLim', app.RestoreView(1).YLim)
            set(app.UIAxes2, 'XLim', app.RestoreView(2).XLim, 'YLim', app.RestoreView(2).YLim)

        end

        % Image clicked function: axesTool_ExportGraphics
        function onAxesToolbarExportGraphicsClicked(app, event)
            
            fileFormats = {'*.jpeg', '(*.jpeg)'};
            fileFullPath = ui.Dialog(app.UIFigure, 'uiputfile', '', fileFormats, app.General.fileFolder.userPath);
            if isempty(fileFullPath)
                return
            end

            app.progressDialog.Visible = 'visible';

            try
                exportgraphics(app.AxesContainer, fileFullPath, 'ContentType', 'image', 'Resolution', app.General.reportLib.image.resolutionDpi, 'BackgroundColor', [0,0,0])
            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Value changed function: axesTool_PlotSource
        function onAxesToolbarPlotSourceImageClicked(app, event)
            
            taskIdx = app.UITable.Selection;
            bandIdx = app.SpectrumFlowList.Value;
            
            if ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall)
                waterfallIdx = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.idx;

                if waterfallIdx
                    app.PlotStyleDirty = true;
                    updatePlot(app, taskIdx, bandIdx)
                end
            end

            updateToolbar(app)
            
        end

        % Image clicked function: axesTool_Average, axesTool_MaxHold, 
        % ...and 2 other components
        function onAxesToolbarTraceModeImageClicked(app, event)
            
            event.Source.UserData.status = ~event.Source.UserData.status;
            if isfield(event.Source.UserData, 'icon')
                if event.Source.UserData.status
                    event.Source.ImageSource = event.Source.UserData.icon.On;
                else
                    event.Source.ImageSource = event.Source.UserData.icon.Off;
                end
            end

            if isempty(app.UITable.Selection) || isempty(app.SpectrumFlowList.Items) || strcmp(app.axesTool_PlotSource.Value, 'Máscara')
                return
            end

            taskIdx = app.UITable.Selection;
            bandIdx = app.SpectrumFlowList.Value;

            if ~isempty(app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall)
                waterfallIdx = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.idx;

                if waterfallIdx
                    freqStart = app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStart / 1e+6;
                    freqStop  = app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).FreqStop  / 1e+6;
                    levelUnit = app.TaskController.Tasks(taskIdx).TaskSpec.Script.Band(bandIdx).instrLevelUnit;

                    xArray    = linspace(freqStart, freqStop, app.TaskController.Tasks(taskIdx).Bands(bandIdx).DataPoints);
                    newArray  = app.TaskController.Tasks(taskIdx).Bands(bandIdx).Waterfall.Matrix(waterfallIdx, :);

                    switch event.Source
                        case app.axesTool_MinHold
                            if event.Source.UserData.status
                                app.PlotHandles.MinHold = plot.draw2D.minHold(app.UIAxes1, app.TaskController.Tasks(taskIdx), bandIdx, xArray, newArray, levelUnit, app.General);
                            else
                                delete(app.PlotHandles.MinHold)
                                app.PlotHandles.MinHold = [];
                            end

                        case app.axesTool_Average
                            if event.Source.UserData.status
                                app.PlotHandles.Average = plot.draw2D.Average(app.UIAxes1, app.TaskController.Tasks(taskIdx), bandIdx, xArray, newArray, levelUnit, app.General);
                            else
                                delete(app.PlotHandles.Average)
                                app.PlotHandles.Average = [];
                            end

                        case app.axesTool_MaxHold
                            if event.Source.UserData.status
                                app.PlotHandles.MaxHold = plot.draw2D.maxHold(app.UIAxes1, app.TaskController.Tasks(taskIdx), bandIdx, xArray, newArray, levelUnit, app.General);
                            else
                                delete(app.PlotHandles.MaxHold)
                                app.PlotHandles.MaxHold = [];
                            end

                        case app.axesTool_Peak
                            if event.Source.UserData.status
                                app.PlotHandles.PeakExcursion = plot.draw2D.peakExcursion(app.PlotHandles.PeakExcursion, app.PlotHandles.ClearWrite, app.TaskController.Tasks(taskIdx), bandIdx, newArray);
                            else
                                delete(app.PlotHandles.PeakExcursion)
                                app.PlotHandles.PeakExcursion = [];
                            end
                    end
                    drawnow
                end
            end

        end

        % Image clicked function: axesTool_Waterfall
        function onAxesToolbarShowWaterfallImageClicked(app, event)
            
            event.Source.UserData.status = ~event.Source.UserData.status;
            updatePlotLayout(app)

            if ~isempty(app.UITable.Selection) && ~app.TaskController.IsRunning
                onAxesToolbarPlotSourceImageClicked(app)
            end

        end

        % Image clicked function: tool_LeftPanel
        function onToolbarPanelVisibilityImageClicked(app, event)
            
            if app.Document.ColumnWidth{1}
                app.tool_LeftPanel.ImageSource = 'layout-sidebar-left-off.svg';
                app.Document.ColumnWidth(1:2) = {0,0};
            else
                app.tool_LeftPanel.ImageSource = 'layout-sidebar-left.svg';
                app.Document.ColumnWidth(1:2) = {320,10};
            end
            
        end

        % Image clicked function: tool_ButtonPlay
        function onToolbarToggleTaskStatusButtonPushed(app, event)
            
            taskIdx = app.UITable.Selection;

            if taskIdx 
                switch app.TaskController.Tasks(taskIdx).Status
                    %-----------------------------------------------------%
                    % PLAY
                    %-----------------------------------------------------%
                    case {'Cancelada', 'Erro', 'Concluída'}
                        Timestamp = datetime('now');
        
                        switch app.TaskController.Tasks(taskIdx).TaskSpec.Script.Observation.Type
                            case 'Duration'
                                app.TaskController.Tasks(taskIdx).Timing.startedAt = Timestamp;
                                app.TaskController.Tasks(taskIdx).Timing.endedAt   = Timestamp + seconds(app.TaskController.Tasks(taskIdx).TaskSpec.Script.Observation.Duration);
            
                            case 'Time'
                                if strcmp(app.TaskController.Tasks(taskIdx).Status, 'Concluída')
                                    ui.Dialog(app.UIFigure, 'warning', 'Uma tarefa no estado "Concluída" somente poderá ser executada novamente se o tipo do período de observação for "Duração" ou "Quantidade específica de amostras".');
                                    return
                                end
            
                            case 'Samples'
                                app.TaskController.Tasks(taskIdx).Timing.startedAt = Timestamp;
                                app.TaskController.Tasks(taskIdx).Timing.endedAt   = NaT;
                        end
        
                        app.TaskController.Tasks(taskIdx).Status = 'Na fila';
                        app.TaskController.Tasks(taskIdx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(Timestamp), 'message', 'Reincluída na fila a tarefa.');

                        resetTaskBands(app.TaskController, taskIdx, 1)
                        taskSchedulerTimerFcn(app)

                    %-----------------------------------------------------%
                    % STOP
                    %-----------------------------------------------------%
                    case 'Em andamento'
                        updateTaskStatus(app.TaskController, taskIdx, 'cancellationRequested');
                end
            end
            
        end

        % Image clicked function: tool_ButtonDel
        function onToolbarDelTaskButtonPushed(app, event)
            
            taskIdx = app.UITable.Selection;

            if taskIdx
                switch app.TaskController.Tasks(taskIdx).Status
                    case 'Em andamento'
                        ui.Dialog(app.UIFigure, 'warning', 'A tarefa precisa ser interrompida antes da tentativa de exclusão.');

                    otherwise
                        if all(~strcmp({app.TaskController.Tasks.Status}, 'Em andamento')) && app.TaskController.IsRunning
                            app.TaskController.IsRunning = false;
                        end

                        if ~app.TaskController.IsRunning
                            app.TaskController.Tasks(taskIdx) = [];    
                            refreshTaskTable(app)
                        else
                            ui.Dialog(app.UIFigure, 'warning', 'Uma tarefa poderá ser excluída, sendo eliminada da lista de tarefas, somente se não estiver sendo executada nenhuma tarefa.');
                        end
                end
            end

        end

        % Image clicked function: tool_ButtonLOG
        function onToolbarShowTaskLogButtonPushed(app, event)

            taskIdx = app.UITable.Selection;

            if taskIdx
                log = util.HtmlTextGenerator.LOG(app.TaskController.Tasks, taskIdx);
                ui.Dialog(app.UIFigure, 'warning', log);
            end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 1244 660];
            app.UIFigure.Name = 'appColeta';
            app.UIFigure.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'icon_32.png');
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {54, '1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [1 2];
            app.TabGroup.Layout.Column = 1;

            % Create Tab1_Task
            app.Tab1_Task = uitab(app.TabGroup);
            app.Tab1_Task.AutoResizeChildren = 'off';
            app.Tab1_Task.Title = 'TASK:VIEW';

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1_Task);
            app.Tab1Grid.ColumnWidth = {'1x'};
            app.Tab1Grid.RowHeight = {'1x', 34};
            app.Tab1Grid.ColumnSpacing = 0;
            app.Tab1Grid.RowSpacing = 0;
            app.Tab1Grid.Padding = [0 0 0 0];
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create Document
            app.Document = uigridlayout(app.Tab1Grid);
            app.Document.ColumnWidth = {320, 10, 5, 292, '1x', 10, 130};
            app.Document.RowHeight = {130, 10, 17, 5, 2, 20, 5, '1x'};
            app.Document.ColumnSpacing = 0;
            app.Document.RowSpacing = 0;
            app.Document.Padding = [20 20 20 50];
            app.Document.Layout.Row = 1;
            app.Document.Layout.Column = 1;
            app.Document.BackgroundColor = [1 1 1];

            % Create UITable
            app.UITable = uitable(app.Document);
            app.UITable.ColumnName = {'TAREFA'; 'RECEPTOR'; 'INCLUSÃO'; 'INÍCIO|OBSERVAÇÃO'; 'FIM|OBSERVAÇÃO'; 'ESTADO'; ''};
            app.UITable.ColumnWidth = {'auto', 'auto', 'auto', 'auto', 'auto', 'auto', 110};
            app.UITable.RowName = {};
            app.UITable.ColumnSortable = [true true true true true true false];
            app.UITable.SelectionType = 'row';
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTaskSelectionChanged, true);
            app.UITable.Multiselect = 'off';
            app.UITable.Layout.Row = 1;
            app.UITable.Layout.Column = [1 7];
            app.UITable.FontSize = 11;

            % Create SpectrumFlowList
            app.SpectrumFlowList = uidropdown(app.Document);
            app.SpectrumFlowList.Items = {};
            app.SpectrumFlowList.ValueChangedFcn = createCallbackFcn(app, @onBandSelectionChanged, true);
            app.SpectrumFlowList.FontSize = 11;
            app.SpectrumFlowList.FontColor = [1 1 1];
            app.SpectrumFlowList.BackgroundColor = [0.7216 0.1882 0.1686];
            app.SpectrumFlowList.Layout.Row = [3 6];
            app.SpectrumFlowList.Layout.Column = 1;
            app.SpectrumFlowList.Value = {};

            % Create MetaData
            app.MetaData = uilabel(app.Document);
            app.MetaData.BackgroundColor = [1 1 1];
            app.MetaData.VerticalAlignment = 'top';
            app.MetaData.WordWrap = 'on';
            app.MetaData.FontSize = 11;
            app.MetaData.Layout.Row = 8;
            app.MetaData.Layout.Column = 1;
            app.MetaData.Interpreter = 'html';
            app.MetaData.Text = '';

            % Create AxesContainer
            app.AxesContainer = uipanel(app.Document);
            app.AxesContainer.AutoResizeChildren = 'off';
            app.AxesContainer.BorderType = 'none';
            app.AxesContainer.BackgroundColor = [0 0 0];
            app.AxesContainer.Layout.Row = [3 8];
            app.AxesContainer.Layout.Column = [3 5];

            % Create AxesToolbar
            app.AxesToolbar = uigridlayout(app.Document);
            app.AxesToolbar.ColumnWidth = {8, 25, 25, 5, '1x', 5, 25, 25, 25, 25, 25, 8};
            app.AxesToolbar.RowHeight = {2, 18, 2};
            app.AxesToolbar.ColumnSpacing = 0;
            app.AxesToolbar.RowSpacing = 0;
            app.AxesToolbar.Padding = [2 2 2 0];
            app.AxesToolbar.Layout.Row = [3 5];
            app.AxesToolbar.Layout.Column = 4;
            app.AxesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.AxesToolbar);
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarRestoreViewImageClicked, true);
            app.axesTool_RestoreView.Tag = 'MinHold';
            app.axesTool_RestoreView.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView.Layout.Row = 2;
            app.axesTool_RestoreView.Layout.Column = 2;
            app.axesTool_RestoreView.VerticalAlignment = 'bottom';
            app.axesTool_RestoreView.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Home_18.png');

            % Create axesTool_ExportGraphics
            app.axesTool_ExportGraphics = uiimage(app.AxesToolbar);
            app.axesTool_ExportGraphics.ScaleMethod = 'none';
            app.axesTool_ExportGraphics.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarExportGraphicsClicked, true);
            app.axesTool_ExportGraphics.Layout.Row = 2;
            app.axesTool_ExportGraphics.Layout.Column = 3;
            app.axesTool_ExportGraphics.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'screen-cut.svg');

            % Create axesTool_PlotSource
            app.axesTool_PlotSource = uidropdown(app.AxesToolbar);
            app.axesTool_PlotSource.Items = {'Nível'};
            app.axesTool_PlotSource.ValueChangedFcn = createCallbackFcn(app, @onAxesToolbarPlotSourceImageClicked, true);
            app.axesTool_PlotSource.Enable = 'off';
            app.axesTool_PlotSource.Tooltip = {'Fonte de dados'};
            app.axesTool_PlotSource.FontSize = 11;
            app.axesTool_PlotSource.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_PlotSource.BackgroundColor = [1 1 1];
            app.axesTool_PlotSource.Layout.Row = [1 3];
            app.axesTool_PlotSource.Layout.Column = 5;
            app.axesTool_PlotSource.Value = 'Nível';

            % Create axesTool_MinHold
            app.axesTool_MinHold = uiimage(app.AxesToolbar);
            app.axesTool_MinHold.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarTraceModeImageClicked, true);
            app.axesTool_MinHold.Tag = 'MinHold';
            app.axesTool_MinHold.Tooltip = {'MinHold'};
            app.axesTool_MinHold.Layout.Row = 2;
            app.axesTool_MinHold.Layout.Column = 7;
            app.axesTool_MinHold.VerticalAlignment = 'bottom';
            app.axesTool_MinHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MinHold_32.png');

            % Create axesTool_Average
            app.axesTool_Average = uiimage(app.AxesToolbar);
            app.axesTool_Average.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarTraceModeImageClicked, true);
            app.axesTool_Average.Tag = 'Average';
            app.axesTool_Average.Tooltip = {'Média'};
            app.axesTool_Average.Layout.Row = 2;
            app.axesTool_Average.Layout.Column = 8;
            app.axesTool_Average.VerticalAlignment = 'bottom';
            app.axesTool_Average.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Average_32.png');

            % Create axesTool_MaxHold
            app.axesTool_MaxHold = uiimage(app.AxesToolbar);
            app.axesTool_MaxHold.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarTraceModeImageClicked, true);
            app.axesTool_MaxHold.Tag = 'MaxHold';
            app.axesTool_MaxHold.Tooltip = {'MaxHold'};
            app.axesTool_MaxHold.Layout.Row = 2;
            app.axesTool_MaxHold.Layout.Column = 9;
            app.axesTool_MaxHold.VerticalAlignment = 'bottom';
            app.axesTool_MaxHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MaxHold_32.png');

            % Create axesTool_Peak
            app.axesTool_Peak = uiimage(app.AxesToolbar);
            app.axesTool_Peak.ScaleMethod = 'none';
            app.axesTool_Peak.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarTraceModeImageClicked, true);
            app.axesTool_Peak.Tag = 'Persistance';
            app.axesTool_Peak.Tooltip = {'Excursão de pico'};
            app.axesTool_Peak.Layout.Row = 2;
            app.axesTool_Peak.Layout.Column = 10;
            app.axesTool_Peak.VerticalAlignment = 'bottom';
            app.axesTool_Peak.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Detection_18.png');

            % Create axesTool_Waterfall
            app.axesTool_Waterfall = uiimage(app.AxesToolbar);
            app.axesTool_Waterfall.ScaleMethod = 'none';
            app.axesTool_Waterfall.ImageClickedFcn = createCallbackFcn(app, @onAxesToolbarShowWaterfallImageClicked, true);
            app.axesTool_Waterfall.Tag = 'Waterfall';
            app.axesTool_Waterfall.Tooltip = {'Waterfall'};
            app.axesTool_Waterfall.Layout.Row = 2;
            app.axesTool_Waterfall.Layout.Column = 11;
            app.axesTool_Waterfall.HorizontalAlignment = 'left';
            app.axesTool_Waterfall.VerticalAlignment = 'bottom';
            app.axesTool_Waterfall.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Waterfall_24.png');

            % Create TaskStatusGrid
            app.TaskStatusGrid = uigridlayout(app.Document);
            app.TaskStatusGrid.ColumnWidth = {'1x'};
            app.TaskStatusGrid.RowHeight = {82, '1x', '1x'};
            app.TaskStatusGrid.Padding = [0 0 0 0];
            app.TaskStatusGrid.Layout.Row = [3 8];
            app.TaskStatusGrid.Layout.Column = 7;
            app.TaskStatusGrid.BackgroundColor = [1 1 1];

            % Create SweepsPanel
            app.SweepsPanel = uipanel(app.TaskStatusGrid);
            app.SweepsPanel.AutoResizeChildren = 'off';
            app.SweepsPanel.Layout.Row = 1;
            app.SweepsPanel.Layout.Column = 1;

            % Create SweepsGrid
            app.SweepsGrid = uigridlayout(app.SweepsPanel);
            app.SweepsGrid.ColumnWidth = {32, '1x', 18};
            app.SweepsGrid.RowHeight = {27, '1x', 18};
            app.SweepsGrid.ColumnSpacing = 0;
            app.SweepsGrid.RowSpacing = 0;
            app.SweepsGrid.Padding = [5 5 5 5];
            app.SweepsGrid.Tag = 'COLORLOCKED';
            app.SweepsGrid.BackgroundColor = [1 1 1];

            % Create SweepsLabel
            app.SweepsLabel = uilabel(app.SweepsGrid);
            app.SweepsLabel.FontSize = 10;
            app.SweepsLabel.FontColor = [0.149 0.149 0.149];
            app.SweepsLabel.Layout.Row = 1;
            app.SweepsLabel.Layout.Column = [1 3];
            app.SweepsLabel.Text = {'VARREDURAS'; 'EM ARQUIVO'};

            % Create Sweeps
            app.Sweeps = uilabel(app.SweepsGrid);
            app.Sweeps.HorizontalAlignment = 'right';
            app.Sweeps.WordWrap = 'on';
            app.Sweeps.FontSize = 14;
            app.Sweeps.FontWeight = 'bold';
            app.Sweeps.FontColor = [0.6706 0.302 0.349];
            app.Sweeps.Layout.Row = 2;
            app.Sweeps.Layout.Column = [1 3];
            app.Sweeps.Text = '-1';

            % Create RecordingIcon
            app.RecordingIcon = uiimage(app.SweepsGrid);
            app.RecordingIcon.ScaleMethod = 'scaledown';
            app.RecordingIcon.Visible = 'off';
            app.RecordingIcon.Layout.Row = 3;
            app.RecordingIcon.Layout.Column = 1;
            app.RecordingIcon.HorizontalAlignment = 'left';
            app.RecordingIcon.VerticalAlignment = 'bottom';
            app.RecordingIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'REC.gif');

            % Create ReceiverErrorCount
            app.ReceiverErrorCount = uilabel(app.SweepsGrid);
            app.ReceiverErrorCount.HorizontalAlignment = 'right';
            app.ReceiverErrorCount.FontSize = 10;
            app.ReceiverErrorCount.FontWeight = 'bold';
            app.ReceiverErrorCount.FontColor = [1 0.651 0.651];
            app.ReceiverErrorCount.Visible = 'off';
            app.ReceiverErrorCount.Layout.Row = 3;
            app.ReceiverErrorCount.Layout.Column = 2;
            app.ReceiverErrorCount.Text = '0';

            % Create ReceiverErrorCountIcon
            app.ReceiverErrorCountIcon = uiimage(app.SweepsGrid);
            app.ReceiverErrorCountIcon.ScaleMethod = 'none';
            app.ReceiverErrorCountIcon.Visible = 'off';
            app.ReceiverErrorCountIcon.Layout.Row = 3;
            app.ReceiverErrorCountIcon.Layout.Column = 3;
            app.ReceiverErrorCountIcon.HorizontalAlignment = 'right';
            app.ReceiverErrorCountIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Warn_18.png');

            % Create MaskPanel
            app.MaskPanel = uipanel(app.TaskStatusGrid);
            app.MaskPanel.AutoResizeChildren = 'off';
            app.MaskPanel.Layout.Row = 2;
            app.MaskPanel.Layout.Column = 1;

            % Create MaskGrid
            app.MaskGrid = uigridlayout(app.MaskPanel);
            app.MaskGrid.ColumnWidth = {'1x'};
            app.MaskGrid.RowHeight = {15, '1x'};
            app.MaskGrid.ColumnSpacing = 2;
            app.MaskGrid.RowSpacing = 0;
            app.MaskGrid.Padding = [5 5 5 5];
            app.MaskGrid.Tag = 'COLORLOCKED';
            app.MaskGrid.BackgroundColor = [1 1 1];

            % Create MaskLabel
            app.MaskLabel = uilabel(app.MaskGrid);
            app.MaskLabel.VerticalAlignment = 'top';
            app.MaskLabel.FontSize = 10;
            app.MaskLabel.FontColor = [0.149 0.149 0.149];
            app.MaskLabel.Layout.Row = 1;
            app.MaskLabel.Layout.Column = 1;
            app.MaskLabel.Text = 'MÁSCARA';

            % Create MaskStatus
            app.MaskStatus = uilabel(app.MaskGrid);
            app.MaskStatus.HorizontalAlignment = 'right';
            app.MaskStatus.VerticalAlignment = 'top';
            app.MaskStatus.WordWrap = 'on';
            app.MaskStatus.FontSize = 10;
            app.MaskStatus.FontColor = [0.502 0.502 0.502];
            app.MaskStatus.Enable = 'off';
            app.MaskStatus.Layout.Row = 2;
            app.MaskStatus.Layout.Column = 1;
            app.MaskStatus.Interpreter = 'html';
            app.MaskStatus.Text = {'<b style="color: #a2142f; font-size: 14;">-1</b> '; 'VALIDAÇÕES '; '<b style="color: #a2142f; font-size: 14;">-1</b> '; 'ROMPIMENTOS '; '<font style="color: #a2142f;">-1.000 MHz '; '⌂ -1.0 kHz '; 'Ʌ -1.0 dB </font>'; 'dd-mmm-yyyy '; 'HH:MM:SS '};

            % Create GPSLastFixPanel
            app.GPSLastFixPanel = uipanel(app.TaskStatusGrid);
            app.GPSLastFixPanel.AutoResizeChildren = 'off';
            app.GPSLastFixPanel.Layout.Row = 3;
            app.GPSLastFixPanel.Layout.Column = 1;

            % Create GPSLastFixGrid
            app.GPSLastFixGrid = uigridlayout(app.GPSLastFixPanel);
            app.GPSLastFixGrid.ColumnWidth = {'1x', 18};
            app.GPSLastFixGrid.RowHeight = {27, '1x', 18};
            app.GPSLastFixGrid.ColumnSpacing = 0;
            app.GPSLastFixGrid.RowSpacing = 0;
            app.GPSLastFixGrid.Padding = [5 5 5 5];
            app.GPSLastFixGrid.Tag = 'COLORLOCKED';
            app.GPSLastFixGrid.BackgroundColor = [1 1 1];

            % Create GPSLastFixLabel
            app.GPSLastFixLabel = uilabel(app.GPSLastFixGrid);
            app.GPSLastFixLabel.VerticalAlignment = 'top';
            app.GPSLastFixLabel.FontSize = 10;
            app.GPSLastFixLabel.FontColor = [0.149 0.149 0.149];
            app.GPSLastFixLabel.Layout.Row = 1;
            app.GPSLastFixLabel.Layout.Column = [1 2];
            app.GPSLastFixLabel.Text = {'COORDENADAS'; 'GEOGRÁFICAS'};

            % Create GPSLastFixIconGrid
            app.GPSLastFixIconGrid = uigridlayout(app.GPSLastFixGrid);
            app.GPSLastFixIconGrid.ColumnWidth = {'1x'};
            app.GPSLastFixIconGrid.RowHeight = {12, '1x'};
            app.GPSLastFixIconGrid.ColumnSpacing = 0;
            app.GPSLastFixIconGrid.RowSpacing = 0;
            app.GPSLastFixIconGrid.Padding = [0 0 0 0];
            app.GPSLastFixIconGrid.Layout.Row = 1;
            app.GPSLastFixIconGrid.Layout.Column = 2;
            app.GPSLastFixIconGrid.BackgroundColor = [1 1 1];

            % Create GPSLastFixIcon
            app.GPSLastFixIcon = uilamp(app.GPSLastFixIconGrid);
            app.GPSLastFixIcon.Layout.Row = 1;
            app.GPSLastFixIcon.Layout.Column = 1;
            app.GPSLastFixIcon.Color = [0.502 0.502 0.502];

            % Create GPSLastFix
            app.GPSLastFix = uilabel(app.GPSLastFixGrid);
            app.GPSLastFix.HorizontalAlignment = 'right';
            app.GPSLastFix.VerticalAlignment = 'top';
            app.GPSLastFix.WordWrap = 'on';
            app.GPSLastFix.FontSize = 10;
            app.GPSLastFix.FontColor = [0.502 0.502 0.502];
            app.GPSLastFix.Layout.Row = [2 3];
            app.GPSLastFix.Layout.Column = [1 2];
            app.GPSLastFix.Interpreter = 'html';
            app.GPSLastFix.Text = {'<b style="color: #a2142f; font-size: 14;">-1.000</b> LAT '; '<b style="color: #a2142f; font-size: 14;">-1.000</b> LON '; 'dd-mmm-yyyy '; 'HH:MM:SS '};

            % Create GPSErrorCount
            app.GPSErrorCount = uilabel(app.GPSLastFixGrid);
            app.GPSErrorCount.HorizontalAlignment = 'right';
            app.GPSErrorCount.FontSize = 10;
            app.GPSErrorCount.FontWeight = 'bold';
            app.GPSErrorCount.FontColor = [1 0.651 0.651];
            app.GPSErrorCount.Visible = 'off';
            app.GPSErrorCount.Layout.Row = 3;
            app.GPSErrorCount.Layout.Column = 1;
            app.GPSErrorCount.Text = '0';

            % Create GPSErrorCountIcon
            app.GPSErrorCountIcon = uiimage(app.GPSLastFixGrid);
            app.GPSErrorCountIcon.ScaleMethod = 'none';
            app.GPSErrorCountIcon.Visible = 'off';
            app.GPSErrorCountIcon.Layout.Row = 3;
            app.GPSErrorCountIcon.Layout.Column = 2;
            app.GPSErrorCountIcon.HorizontalAlignment = 'right';
            app.GPSErrorCountIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Warn_18.png');

            % Create Toolbar
            app.Toolbar = uigridlayout(app.Tab1Grid);
            app.Toolbar.ColumnWidth = {22, 5, 22, 22, 5, 22, '1x'};
            app.Toolbar.RowHeight = {4, 17, 2};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 2;
            app.Toolbar.Layout.Column = 1;

            % Create tool_LeftPanel
            app.tool_LeftPanel = uiimage(app.Toolbar);
            app.tool_LeftPanel.ScaleMethod = 'none';
            app.tool_LeftPanel.ImageClickedFcn = createCallbackFcn(app, @onToolbarPanelVisibilityImageClicked, true);
            app.tool_LeftPanel.Tooltip = {''};
            app.tool_LeftPanel.Layout.Row = [1 3];
            app.tool_LeftPanel.Layout.Column = 1;
            app.tool_LeftPanel.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'layout-sidebar-left.svg');

            % Create tool_Separator1
            app.tool_Separator1 = uiimage(app.Toolbar);
            app.tool_Separator1.ScaleMethod = 'none';
            app.tool_Separator1.Enable = 'off';
            app.tool_Separator1.Layout.Row = [1 3];
            app.tool_Separator1.Layout.Column = 2;
            app.tool_Separator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_ButtonPlay
            app.tool_ButtonPlay = uiimage(app.Toolbar);
            app.tool_ButtonPlay.ImageClickedFcn = createCallbackFcn(app, @onToolbarToggleTaskStatusButtonPushed, true);
            app.tool_ButtonPlay.Enable = 'off';
            app.tool_ButtonPlay.Tooltip = {''};
            app.tool_ButtonPlay.Layout.Row = 2;
            app.tool_ButtonPlay.Layout.Column = 3;
            app.tool_ButtonPlay.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'play_32.png');

            % Create tool_ButtonDel
            app.tool_ButtonDel = uiimage(app.Toolbar);
            app.tool_ButtonDel.ImageClickedFcn = createCallbackFcn(app, @onToolbarDelTaskButtonPushed, true);
            app.tool_ButtonDel.Enable = 'off';
            app.tool_ButtonDel.Tooltip = {''};
            app.tool_ButtonDel.Layout.Row = 2;
            app.tool_ButtonDel.Layout.Column = 4;
            app.tool_ButtonDel.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Delete_32Red.png');

            % Create tool_Separator2
            app.tool_Separator2 = uiimage(app.Toolbar);
            app.tool_Separator2.ScaleMethod = 'none';
            app.tool_Separator2.Enable = 'off';
            app.tool_Separator2.Layout.Row = [1 3];
            app.tool_Separator2.Layout.Column = 5;
            app.tool_Separator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_ButtonLOG
            app.tool_ButtonLOG = uiimage(app.Toolbar);
            app.tool_ButtonLOG.ImageClickedFcn = createCallbackFcn(app, @onToolbarShowTaskLogButtonPushed, true);
            app.tool_ButtonLOG.Enable = 'off';
            app.tool_ButtonLOG.Tooltip = {''};
            app.tool_ButtonLOG.Layout.Row = 2;
            app.tool_ButtonLOG.Layout.Column = 6;
            app.tool_ButtonLOG.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LOG_32.png');

            % Create tool_RevisitTime
            app.tool_RevisitTime = uilabel(app.Toolbar);
            app.tool_RevisitTime.HorizontalAlignment = 'right';
            app.tool_RevisitTime.WordWrap = 'on';
            app.tool_RevisitTime.FontSize = 10;
            app.tool_RevisitTime.Layout.Row = [1 3];
            app.tool_RevisitTime.Layout.Column = 7;
            app.tool_RevisitTime.Text = '';

            % Create Tab2_InstrumentList
            app.Tab2_InstrumentList = uitab(app.TabGroup);
            app.Tab2_InstrumentList.AutoResizeChildren = 'off';
            app.Tab2_InstrumentList.Title = 'INSTRUMENT';

            % Create Tab3_TaskEdition
            app.Tab3_TaskEdition = uitab(app.TabGroup);
            app.Tab3_TaskEdition.AutoResizeChildren = 'off';
            app.Tab3_TaskEdition.Title = 'TASK:EDIT';

            % Create Tab4_TaskAdd
            app.Tab4_TaskAdd = uitab(app.TabGroup);
            app.Tab4_TaskAdd.AutoResizeChildren = 'off';
            app.Tab4_TaskAdd.Title = 'TASK:ADD';

            % Create Tab5_Server
            app.Tab5_Server = uitab(app.TabGroup);
            app.Tab5_Server.AutoResizeChildren = 'off';
            app.Tab5_Server.Title = 'SERVER';

            % Create Tab6_Config
            app.Tab6_Config = uitab(app.TabGroup);
            app.Tab6_Config.AutoResizeChildren = 'off';
            app.Tab6_Config.Title = 'CONFIG';

            % Create NavBar
            app.NavBar = uigridlayout(app.GridLayout);
            app.NavBar.ColumnWidth = {101, '1x', 34, 5, 34, 34, 34, 5, 34, 34, '1x', 20, 20, 1, 20, 20, 0, 0};
            app.NavBar.RowHeight = {5, 7, 20, 7, 5};
            app.NavBar.ColumnSpacing = 5;
            app.NavBar.RowSpacing = 0;
            app.NavBar.Padding = [10 5 5 5];
            app.NavBar.Tag = 'COLORLOCKED';
            app.NavBar.Layout.Row = 1;
            app.NavBar.Layout.Column = 1;
            app.NavBar.BackgroundColor = [0.2 0.2 0.2];

            % Create AppName
            app.AppName = uilabel(app.NavBar);
            app.AppName.WordWrap = 'on';
            app.AppName.FontSize = 11;
            app.AppName.FontColor = [1 1 1];
            app.AppName.Layout.Row = [1 5];
            app.AppName.Layout.Column = [1 2];
            app.AppName.Interpreter = 'html';
            app.AppName.Text = {'appColeta v. 1.64.0'; '<font style="font-size: 9px;">R2024a</font>'};

            % Create Tab1Button
            app.Tab1Button = uibutton(app.NavBar, 'state');
            app.Tab1Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab1Button.Tag = 'TASK:VIEW';
            app.Tab1Button.Tooltip = {'Acompanha execução de tarefas'};
            app.Tab1Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'run-all-24px-yellow.svg');
            app.Tab1Button.Text = '';
            app.Tab1Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab1Button.FontSize = 11;
            app.Tab1Button.Layout.Row = [2 4];
            app.Tab1Button.Layout.Column = 3;
            app.Tab1Button.Value = true;

            % Create ButtonsSeparator1
            app.ButtonsSeparator1 = uiimage(app.NavBar);
            app.ButtonsSeparator1.ScaleMethod = 'none';
            app.ButtonsSeparator1.Enable = 'off';
            app.ButtonsSeparator1.Layout.Row = [2 4];
            app.ButtonsSeparator1.Layout.Column = 4;
            app.ButtonsSeparator1.VerticalAlignment = 'bottom';
            app.ButtonsSeparator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create Tab2Button
            app.Tab2Button = uibutton(app.NavBar, 'state');
            app.Tab2Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab2Button.Tag = 'INSTRUMENT';
            app.Tab2Button.Tooltip = {'Edita lista de instrumentos'};
            app.Tab2Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'circuit-board.svg');
            app.Tab2Button.Text = '';
            app.Tab2Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab2Button.FontSize = 11;
            app.Tab2Button.Layout.Row = [2 4];
            app.Tab2Button.Layout.Column = 5;

            % Create Tab3Button
            app.Tab3Button = uibutton(app.NavBar, 'state');
            app.Tab3Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab3Button.Tag = 'TASK:EDIT';
            app.Tab3Button.Tooltip = {'Edita lista de tarefas'};
            app.Tab3Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'server-process.svg');
            app.Tab3Button.Text = '';
            app.Tab3Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab3Button.FontSize = 11;
            app.Tab3Button.Layout.Row = [2 4];
            app.Tab3Button.Layout.Column = 6;

            % Create Tab4Button
            app.Tab4Button = uibutton(app.NavBar, 'state');
            app.Tab4Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab4Button.Tag = 'TASK:ADD';
            app.Tab4Button.Tooltip = {'Adiciona nova tarefa'};
            app.Tab4Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'empty-window.svg');
            app.Tab4Button.Text = '';
            app.Tab4Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab4Button.FontSize = 11;
            app.Tab4Button.Layout.Row = [2 4];
            app.Tab4Button.Layout.Column = 7;

            % Create ButtonsSeparator2
            app.ButtonsSeparator2 = uiimage(app.NavBar);
            app.ButtonsSeparator2.ScaleMethod = 'none';
            app.ButtonsSeparator2.Enable = 'off';
            app.ButtonsSeparator2.Layout.Row = [2 4];
            app.ButtonsSeparator2.Layout.Column = 8;
            app.ButtonsSeparator2.VerticalAlignment = 'bottom';
            app.ButtonsSeparator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create Tab5Button
            app.Tab5Button = uibutton(app.NavBar, 'state');
            app.Tab5Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab5Button.Tag = 'SERVER';
            app.Tab5Button.Tooltip = {'API'};
            app.Tab5Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'cloud-upload.svg');
            app.Tab5Button.Text = '';
            app.Tab5Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab5Button.FontSize = 11;
            app.Tab5Button.Layout.Row = [2 4];
            app.Tab5Button.Layout.Column = 9;

            % Create Tab6Button
            app.Tab6Button = uibutton(app.NavBar, 'state');
            app.Tab6Button.ValueChangedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.Tab6Button.Tag = 'CONFIG';
            app.Tab6Button.Tooltip = {'Configurações gerais'};
            app.Tab6Button.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'gear-24px-white.svg');
            app.Tab6Button.Text = '';
            app.Tab6Button.BackgroundColor = [0.2 0.2 0.2];
            app.Tab6Button.FontSize = 11;
            app.Tab6Button.Layout.Row = [2 4];
            app.Tab6Button.Layout.Column = 10;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.NavBar);
            app.jsBackDoor.Layout.Row = 3;
            app.jsBackDoor.Layout.Column = 12;

            % Create DataHubLamp
            app.DataHubLamp = uiimage(app.NavBar);
            app.DataHubLamp.Visible = 'off';
            app.DataHubLamp.Layout.Row = 3;
            app.DataHubLamp.Layout.Column = 13;
            app.DataHubLamp.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'red-circle-blink.gif');

            % Create FigurePosition
            app.FigurePosition = uiimage(app.NavBar);
            app.FigurePosition.ScaleMethod = 'none';
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Tooltip = {'Reposiciona janela'};
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 15;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'screen-normal-24px-white.svg');

            % Create AppInfo
            app.AppInfo = uiimage(app.NavBar);
            app.AppInfo.ScaleMethod = 'none';
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @onTabNavigatorButtonPushed, true);
            app.AppInfo.Tooltip = {'Informações gerais'};
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 16;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'kebab-vertical-24px-white.svg');

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winAppColeta_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
