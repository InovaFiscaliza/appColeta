classdef winAppColeta_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        NavBar                 matlab.ui.container.GridLayout
        AppInfo                matlab.ui.control.Image
        FigurePosition         matlab.ui.control.Image
        jsBackDoor             matlab.ui.control.HTML
        Tab6Button             matlab.ui.control.StateButton
        Tab5Button             matlab.ui.control.StateButton
        ButtonsSeparator2      matlab.ui.control.Image
        Tab4Button             matlab.ui.control.StateButton
        Tab3Button             matlab.ui.control.StateButton
        Tab2Button             matlab.ui.control.StateButton
        ButtonsSeparator1      matlab.ui.control.Image
        Tab1Button             matlab.ui.control.StateButton
        AppName                matlab.ui.control.Label
        TabGroup               matlab.ui.container.TabGroup
        Tab1_Task              matlab.ui.container.Tab
        Tab1Grid               matlab.ui.container.GridLayout
        task_toolGrid          matlab.ui.container.GridLayout
        tool_RevisitTime       matlab.ui.control.Label
        tool_ButtonLOG         matlab.ui.control.Image
        tool_Separator2        matlab.ui.control.Image
        tool_ButtonDel         matlab.ui.control.Image
        tool_ButtonPlay        matlab.ui.control.Image
        tool_Separator1        matlab.ui.control.Image
        tool_LeftPanel         matlab.ui.control.Image
        task_docGrid           matlab.ui.container.GridLayout
        MetaData               matlab.ui.control.Label
        DropDown               matlab.ui.control.DropDown
        FAIXADEFREQUNCIALabel  matlab.ui.control.Label
        play_axesToolbar       matlab.ui.container.GridLayout
        axesTool_Waterfall     matlab.ui.control.Image
        axesTool_Peak          matlab.ui.control.Image
        axesTool_MaxHold       matlab.ui.control.Image
        axesTool_Average       matlab.ui.control.Image
        axesTool_MinHold       matlab.ui.control.Image
        axesTool_PlotSource    matlab.ui.control.DropDown
        axesTool_RestoreView   matlab.ui.control.Image
        TaskInfo_Panel         matlab.ui.container.GridLayout
        lastGPS_Panel          matlab.ui.container.Panel
        lastGPS_Grid1          matlab.ui.container.GridLayout
        errorCount_img_2       matlab.ui.control.Image
        errorCount_txt_2       matlab.ui.control.Label
        lastGPS_Grid2          matlab.ui.container.GridLayout
        lastGPS_color          matlab.ui.control.Lamp
        lastGPS_text           matlab.ui.control.Label
        lastGPS_label          matlab.ui.control.Label
        lastMask_Panel         matlab.ui.container.Panel
        lastMask_Grid          matlab.ui.container.GridLayout
        lastMask_text          matlab.ui.control.Label
        lastMask_label         matlab.ui.control.Label
        Sweeps_Panel           matlab.ui.container.Panel
        Sweeps_Grid            matlab.ui.container.GridLayout
        errorCount_img         matlab.ui.control.Image
        errorCount_txt         matlab.ui.control.Label
        Sweeps                 matlab.ui.control.Label
        Sweeps_Label           matlab.ui.control.Label
        Sweeps_REC             matlab.ui.control.Image
        Plot_Panel             matlab.ui.container.Panel
        UITable                matlab.ui.control.Table
        Tab2_InstrumentList    matlab.ui.container.Tab
        Tab3_TaskEdition       matlab.ui.container.Tab
        Tab4_TaskAdd           matlab.ui.container.Tab
        Tab5_Server            matlab.ui.container.Tab
        Tab6_Config            matlab.ui.container.Tab
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'mainApp'
        Context = 'TASK:VIEW'
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

        % A organização das tarefas (antiga "class.specClass") e a lógica de
        % execução do loop de monitoração (antigo "RegularTask_MainLoop")
        % foram migradas para model.Task / model.TaskController. As
        % propriedades "specObj", "revisitObj", "udpPortArray" e
        % "Flag_running", declaradas mais abaixo como "Dependent", são
        % mantidas apenas como referências de conveniência para o estado
        % armazenado em "TaskController", preservando os demais trechos
        % deste arquivo sem necessidade de alteração.
        TaskController
        timerObj_task
        taskList

        plotStyleEditing = 0

        axes1
        axes2
        restoreView = struct('ID', {}, 'xLim', {}, 'yLim', {}, 'cLim', {})
        
        line_ClrWrite
        line_MinHold
        line_Average
        line_MaxHold
        peakExcursion
        surface_WFall

        tcpServer
        
        receiverObj
        gpsObj

        EB500Obj
        EMSatObj
        ERMxObj
    end


    properties (Dependent, Access = public)
        %-----------------------------------------------------------------%
        specObj                                                             % app.TaskController.Tasks
        revisitObj                                                          % app.TaskController.RevisitInfo
        udpPortArray                                                        % app.TaskController.UDPPortArray
        Flag_running                                                        % app.TaskController.IsRunning
    end


    methods
        %-----------------------------------------------------------------%
        function value = get.specObj(app)
            value = app.TaskController.Tasks;
        end

        function set.specObj(app, value)
            app.TaskController.Tasks = value;
        end

        %-----------------------------------------------------------------%
        function value = get.revisitObj(app)
            value = app.TaskController.RevisitInfo;
        end

        %-----------------------------------------------------------------%
        function value = get.udpPortArray(app)
            value = app.TaskController.UDPPortArray;
        end

        function set.udpPortArray(app, value)
            app.TaskController.UDPPortArray = value;
        end

        %-----------------------------------------------------------------%
        function value = get.Flag_running(app)
            value = app.TaskController.IsRunning;
        end

        function set.Flag_running(app, value)
            app.TaskController.IsRunning = value;
        end
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
                    case 'renderer'
                        MFilePath   = fileparts(mfilename('fullpath'));
                        parpoolFlag = false;

                        if ~app.renderCount
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)
                        else
                            selection = app.UITable.Selection;
                            if ~isempty(selection)
                                app.UITable.Selection = [];
                                onTableSelectionChanged(app)
                            end

                            appEngine.beforeReload(app, app.Role)
                            appEngine.activate(app, app.Role, MFilePath, parpoolFlag)

                            if ~isempty(selection)
                                app.UITable.Selection = selection;
                                onTableSelectionChanged(app)
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
                        varargout{1} = auxAppInputArguments(app, auxAppTag);

                    case 'onUpdateLastVisitedFolder'
                        filePath = varargin{1};
                        updateLastVisitedFolder(app, filePath)

                    otherwise
                        switch class(callingApp)
                            % auxApp.winConfig (CONFIG)
                            case {'auxApp.winConfig', 'auxApp.winConfig_exported'}
                                switch eventName
                                    case 'checkDataHubLampStatus'
                                        DataHubWarningLamp(app)

                                    case 'openDevTools'
                                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))
        
                                    case 'onAxesTileSpacingChange'
                                        tileSpacing = varargin{1};
                                        app.axes1.Parent.TileSpacing = tileSpacing;
                
                                    case 'onPlotColorChange'
                                        plotTag = varargin{1};
                                        if ~isempty(eval(['app.line_' plotTag]))
                                            app.plotStyleEditing = 1;
                                        end
                
                                    case 'onWaterfallColormapChange'
                                        waterfallColormap = varargin{1};
                                        colormap(app.axes2, waterfallColormap)
        
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
                                            [app.specObj, msgError]    = app.specObj.AddOrEditTask(infoEdition, newTask, app.EMSatObj, app.ERMxObj);
                                            app.progressDialog.Visible = 'hidden';
                            
                                            if isempty(msgError)
                                                RegularTask_timerFcn(app)                                 % Startup of every task
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
                        app.MetaData;
                        app.play_axesToolbar;
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
                            struct('appName', appName, 'dataTag', app.play_axesToolbar.UserData.id, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0')), ...
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
            app.taskList    = class.taskList.rawFileParser(app.rootFolder, 'winAppColetaV2');

            % Others...
            app.receiverObj = class.ReceiverLib(app.rootFolder);
            app.gpsObj      = class.GPSLib(app.rootFolder);            
            app.EB500Obj    = class.EB500Lib(app.rootFolder);
            app.EMSatObj    = class.EMSatLib(app.rootFolder);
            app.ERMxObj     = class.ERMxLib(app.rootFolder);            

            app.TaskController = model.TaskController(app);
            app.specObj         = model.Task.empty;
            wireTaskController(app)

            if app.General.tcpServer.Status
                try
                    app.tcpServer = class.tcpServerLib(app);
                catch
                    app.tcpServer = [];
                end
            end
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
            
            startup_Axes(app)
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            RegularTask_timerCreation(app)

            if app.General.startupInfo
                startup_specObjRead(app)
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function DataHubWarningLamp(app)
            % if isfolder(app.General.fileFolder.DataHub_POST)
            %     app.DataHubLamp.Visible = 0;
            % else
            %     app.DataHubLamp.Visible = 1;
            % end
        end


        %-----------------------------------------------------------------%
        function startup_Axes(app)
            % Axes creation:
            hParent   = tiledlayout(app.Plot_Panel, 3, 1, "Padding", "compact", "TileSpacing", "compact");
            app.axes1 = plot.axesCreation(hParent, 'Cartesian', {'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.axes1.Layout.Tile = 1;
            app.axes1.Layout.TileSpan = [3,1];
            
            app.axes2 = plot.axesCreation(hParent, 'Cartesian', {'Visible', 0, 'Layer', 'top', 'Box', 'on', 'XGrid', 'off', 'XMinorGrid', 'off', 'YGrid', 'off', 'YMinorGrid', 'off', 'UserData', struct('CLimMode', 'auto', 'Colormap', '')});
            app.axes2.Layout.Tile = 4;

            colormap(app.axes2, app.General.Plot.Waterfall.Colormap);
            plot.axesColorbar(app.axes2, "eastoutside", {'Visible', false})

            % Axes fixed labels:
            xlabel(app.axes1, 'Frequência (MHz)')
            ylabel(app.axes1, 'Nível (dB)')
            ysecondarylabel(app.axes1, sprintf('\n\n'))
            
            xlabel(app.axes2, 'Frequência (MHz)')
            ylabel(app.axes2, 'Amostras')

            % Axes listeners:
            linkaxes([app.axes1, app.axes2], 'x')

            % Axes interactions:
            plot.axesInteractivity.DefaultCreation([app.axes1, app.axes2], [dataTipInteraction, regionZoomInteraction, rulerPanInteraction ])
        end

        %-----------------------------------------------------------------%
        function startup_specObjRead(app)
            [~, programDataFolder] = appEngine.util.Path(class.Constants.appName, app.rootFolder);
            if isfile(fullfile(programDataFolder, 'taskListState.mat'))
                app.progressDialog.Visible = 'visible';

                load(fullfile(programDataFolder, 'taskListState.mat'), 'Tasks');

                % É possível que o MATLAB não consiga instancionar o objeto
                % "model.Task", lendo-o como "uint32", o que inviabiliza 
                % o aproveitamento da informação salva...

                % Warning: Variable 'Tasks' originally saved as a model.Task cannot be instantiated as an object and will be read in as a uint32.

                if exist('Tasks', 'var') && isa(Tasks, 'model.Task') && ~isempty(Tasks)
                    for ii = 1:numel(Tasks)
                        Tasks(ii)      = startup_specObjRead_Receiver(app, Tasks(ii));
                        Tasks(ii)      = app.TaskController.resolveStreamingHandle(Tasks(ii));
                        [Tasks(ii), ~] = app.TaskController.resolveGpsHandle(Tasks(ii));

                        if ismember(Tasks(ii).Status, {'Na fila', 'Em andamento'})
                            Tasks(ii).Status = 'Erro';
                        end
                    end

                    app.specObj = Tasks;
                    Layout_tableBuilding(app, 1)

                    % Ida ao modo de "Execução das tarefas da monitoração"
                    % de forma programática:
                    app.Tab1Button.Value = 1;
                    onTabNavigatorButtonPushed(app, struct('Source', app.Tab1Button, 'PreviousValue', 0))
                end

                app.progressDialog.Visible = 'hidden';
            end
        end

        %-----------------------------------------------------------------%
        function [SpecObj, msgError] = startup_specObjRead_Receiver(app, SpecObj)
            % Função funcionalmente idêntica à fcn.ConnectivityTest_Receiver.
            % A "duplicação" garante que seja usado a informação constante
            % no objeto SpecObj, ao invés da informação constante no arquivo 
            % "instrumentList.json", que pode ter sido editado.

            instrSelected = Instrument(SpecObj);
            [idx, msgError] = Connect(app.receiverObj ,instrSelected);
            
            if isempty(msgError)
                SpecObj.TaskSpec.Receiver.Handle = app.receiverObj.Table.Handle{idx};
                SpecObj.Connections.receiver      = SpecObj.TaskSpec.Receiver.Handle;
            end
        end

        %-----------------------------------------------------------------%
        function inputArguments = menu_auxAppInputArguments(app, auxAppName)
            arguments
                app
                auxAppName char {mustBeMember(auxAppName, {'TASK:VIEW', 'INSTRUMENT', 'TASK:EDIT', 'TASK:ADD', 'SERVER', 'CONFIG'})}
            end

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


        %-----------------------------------------------------------------%
        % TIMER 
        %-----------------------------------------------------------------%
        function RegularTask_timerCreation(app)
            app.timerObj_task = timer("ExecutionMode", "fixedRate", ...
                                      "Period",        10,          ...
                                      "TimerFcn",      @(~,~)app.RegularTask_timerFcn);
            start(app.timerObj_task)
        end


        %-----------------------------------------------------------------%
        function RegularTask_timerFcn(app)
            if ~app.Flag_running
                Flag = false;
                for ii = 1:numel(app.specObj)
                    if app.TaskController.statusTaskCheck(ii, '')
                        Flag = true;
                        break
                    end
                end

                if Flag
                    app.TaskController.runLoop()
                end
            end

            if numel(app.specObj) ~= height(app.UITable.Data)
                Layout_tableBuilding(app, app.UITable.Selection)
            end
        end


        %-----------------------------------------------------------------%
        % REGULAR TASK
        %-----------------------------------------------------------------%
        function wireTaskController(app)
            % Inscreve o app nos eventos disparados por "app.TaskController"
            % (model.TaskController), substituindo as antigas chamadas diretas
            % a métodos de interface dentro do loop de monitoração (antigo
            % "RegularTask_MainLoop" e demais funções "RegularTask_*" que
            % foram migradas para model.TaskController).

            addlistener(app.TaskController, 'StatusChanged',      @(~,~)   Layout_tableBuilding(app, app.UITable.Selection));
            addlistener(app.TaskController, 'TasksChanged',       @(~,~)   RegularTask_TasksSave(app));
            addlistener(app.TaskController, 'BandDataAcquired',   @(~,evt) onTaskBandDataAcquired(app, evt));
            addlistener(app.TaskController, 'GpsUpdated',         @(~,evt) onTaskGpsUpdated(app, evt));
            addlistener(app.TaskController, 'ErrorRaised',        @(~,evt) onTaskErrorRaised(app, evt));
            addlistener(app.TaskController, 'RevisitInfoChanged', @(~,~)   Layout_metadataTab(app));
        end


        %-----------------------------------------------------------------%
        function onTaskBandDataAcquired(app, evt)
            % Substitui o trecho de "RegularTask_MainLoop" que atualizava a
            % interface gráfica (Layout_errorCount, plot_Draw,
            % Layout_lastMaskValidation, tool_RevisitTime.Text, Sweeps.Text)
            % a cada novo traço adquirido pela tarefa em execução.

            ii          = evt.TaskId;
            jj          = evt.BandId;
            maskTrigger = evt.Payload;

            if app.UITable.Selection == ii
                Layout_errorCount(app, ii)

                if app.DropDown.Value == jj
                    plot_Draw(app, ii, jj)
                    if ~isempty(app.specObj(ii).Bands(jj).Mask)
                        Layout_lastMaskValidation(app, maskTrigger, ii, jj)
                    end
                    app.tool_RevisitTime.Text = sprintf('%d varreduras\n%.3f seg', app.specObj(ii).Bands(jj).nSweeps, app.specObj(ii).Bands(jj).RevisitTime);
                    app.Sweeps.Text           = string(app.specObj(ii).Bands(jj).File.WritedSamples);
                    drawnow
                end
            end
        end


        %-----------------------------------------------------------------%
        function onTaskGpsUpdated(app, evt)
            % Substitui o trecho de "RegularTask_gpsData" que atualizava a
            % interface gráfica (Layout_lastGPS) e as coordenadas da estação
            % (app.General.stationInfo), a cada nova leitura de GPS.

            ii      = evt.TaskId;
            gpsData = evt.Payload;

            % As coordenadas da estação - registradas em app.General.stationInfo
            % - são atualizadas apenas se a estação for do tipo móvel ("Mobile") 
            % e as novas coordenadas geográficas forem válidas.
            if strcmp(app.General.stationInfo.Type, 'Mobile') && gpsData.Status
                app.General.stationInfo.Latitude  = gpsData.Latitude;
                app.General.stationInfo.Longitude = gpsData.Longitude;
            end

            if app.UITable.Selection == ii
                Layout_lastGPS(app, gpsData)
            end
        end


        %-----------------------------------------------------------------%
        function onTaskErrorRaised(app, evt)
            % Substitui o trecho de "RegularTask_MainLoop" que atualizava a
            % interface gráfica (Layout_errorCount) e emitia um "beep" a cada
            % erro de aquisição (RECEIVER ou GPS).

            ii = evt.TaskId;

            if app.UITable.Selection == ii
                Layout_errorCount(app, ii)
                drawnow
            end
            beep
        end


        %-----------------------------------------------------------------%
        function RegularTask_TasksSave(app)
            % Ao salvar "app.specObj" (app.TaskController.Tasks) em um arquivo
            % .MAT, reabrindo-o posteriormente, os objetos de comunicação
            % (tcpclient, por exemplo) não retém o valor da propriedade "UserData".
            %
            % Por essa razão, esses objetos não serão salvos, devendo ser
            % recriados na inicialização do app.

            Tasks = copy(app.specObj);
            
            for ii = 1:numel(Tasks)
                Tasks(ii).Connections.receiver = [];
                Tasks(ii).Connections.stream   = [];
                Tasks(ii).Connections.gps      = [];

                Tasks(ii).TaskSpec.Receiver.Handle  = [];
                Tasks(ii).TaskSpec.Streaming.Handle = [];
                Tasks(ii).TaskSpec.GPS.Handle       = [];
            end

            [~, programDataFolder] = appEngine.util.Path(class.Constants.appName, app.rootFolder);
            save(fullfile(programDataFolder, 'taskListState.mat'), 'Tasks')
        end


        %-----------------------------------------------------------------%
        function Layout_tableBuilding(app, idx)
            tempTable = table('Size', [0, 7],                                                                          ...
                              'VariableTypes', {'double', 'string', 'string', 'string', 'string', 'string', 'string'}, ...
                              'VariableNames', {'ID', 'Name', 'Receiver', 'Created', 'BeginTime', 'EndTime', 'Status'});
            tempTable.Properties.UserData = char(matlab.lang.internal.uuid());
            
            for ii = 1:numel(app.specObj)
                EndTime = '-';
                if ~isnat(app.specObj(ii).Timing.endedAt) && ~isinf(app.specObj(ii).Timing.endedAt)
                    EndTime = datestr(app.specObj(ii).Timing.endedAt, 'dd/mm/yyyy HH:MM:SS');
                end
        
                tempTable(end+1,:) = {app.specObj(ii).TaskId,                    ...
                                      app.specObj(ii).TaskSpec.Script.Name,      ...
                                      app.specObj(ii).ReceiverId,                ...
                                      app.specObj(ii).Timing.createdAt,          ...
                                      datestr(app.specObj(ii).Timing.startedAt, 'dd/mm/yyyy HH:MM:SS'), ...
                                      EndTime,                                   ...
                                      app.specObj(ii).Status};
            end    
        
            if all(~strcmp(tempTable.Status, "Em andamento"))
                app.Flag_running = 0;
            end
        
            if height(tempTable)
                app.UITable.Data      = tempTable;
                app.UITable.Selection = max([1, idx]);
                app.UITable.UserData  = app.UITable.Selection;
                pause(.100)
        
                app.tool_ButtonPlay.Enable = 1;
                app.tool_ButtonDel.Enable  = 1;
                app.tool_ButtonLOG.Enable  = 1;
            else
                app.UITable.Data     = table;
                app.UITable.UserData = [];
        
                app.tool_ButtonPlay.Enable = 0;
                app.tool_ButtonDel.Enable  = 0;
                app.tool_ButtonLOG.Enable  = 0;
            end
            Layout_errorCount(app, app.UITable.Selection)
            drawnow
        
            previousSelection = 1;
            if ~isempty(app.DropDown.Items)
                previousSelection = app.DropDown.Value;
            end
            Layout_treeBuilding(app, previousSelection)
        end

        %-----------------------------------------------------------------%
        function Layout_treeBuilding(app, Selection)
            if app.UITable.Selection
                idx = app.UITable.Selection;
                numBands = numel(app.specObj(idx).TaskSpec.Script.Band);
                ids = {};

                for ii = 1:numBands
                    Antenna = app.specObj(idx).TaskSpec.Script.Band(ii).instrAntenna;
                    if ~isempty(Antenna)
                        Antenna = sprintf('(%s)', Antenna);
                    end
                    
                    ids{end+1} = sprintf('ID %d: %.3f - %.3f MHz %s',                            ...
                                         app.specObj(idx).TaskSpec.Script.Band(ii).ID,               ...
                                         app.specObj(idx).TaskSpec.Script.Band(ii).FreqStart / 1e+6, ...
                                         app.specObj(idx).TaskSpec.Script.Band(ii).FreqStop  / 1e+6, ...
                                         Antenna);
                end
                
                set(app.DropDown, 'Items', ids, 'ItemsData', 1:numBands, 'Value', Selection)
                onTaskSelectionChanged(app)
            else
                app.DropDown.Items = {};
                app.MetaData.Text = '';

                plot_Startup(app)
                plot_PlotSource(app, -1, -1)

                app.Sweeps.Text = '-1';
                app.Sweeps_REC.Visible = 0;
                Layout_errorCount(app, [])                
                Layout_lastMaskInitialState(app)
                app.lastGPS_text.Text = {'<b style="color: #a2142f; font-size: 14;">-1.000</b> LAT '; '<b style="color: #a2142f; font-size: 14;">-1.000</b> LON '; 'dd-mmm-yyyy '; 'HH:MM:SS '};
                app.tool_RevisitTime.Text = '';
            end            
            drawnow
        end

        %-----------------------------------------------------------------%
        function Layout_metadataTab(app)
            app.MetaData.Text = util.HtmlTextGenerator.Task(app.specObj, app.revisitObj, app.UITable.Selection, app.DropDown.Value);
        end

        %-----------------------------------------------------------------%
        function Layout_errorCount(app, idx)
            if ~isempty(idx) && app.specObj(idx).RetryPolicy.receiver.failureCount
                set(app.errorCount_txt, 'Text', string(app.specObj(idx).RetryPolicy.receiver.failureCount), 'Visible', 'on')
                app.errorCount_img.Visible = 'on';
            else
                set(app.errorCount_txt, 'Text', '0', 'Visible', 'off')
                app.errorCount_img.Visible = 'off';
            end
        end

        %-----------------------------------------------------------------%
        function Layout_lastGPS(app, gpsData)
            switch gpsData.Status
                case  1; newColor = [0.47,0.67,0.19];
                case  0; newColor = [0.64,0.08,0.18];
                case -1; newColor = [0.50,0.50,0.50];
            end
        
            app.lastGPS_text.Text   = sprintf(['<b style="color: #a2142f; font-size: 14;">%.3f</b> LAT \n' ...
                                               '<b style="color: #a2142f; font-size: 14;">%.3f</b> LON \n' ...
                                               '%s \n%s '], gpsData.Latitude, gpsData.Longitude,           ...
                                                            extractBefore(gpsData.TimeStamp, ' '),         ...
                                                            extractAfter(gpsData.TimeStamp, ' '));
            app.lastGPS_color.Color = newColor;
        end

        %-----------------------------------------------------------------%
        function Layout_lastMaskInitialState(app)
            app.lastMask_text.Enable = 0;
            app.lastMask_text.Text   = {'<b style="color: #a2142f; font-size: 14;">-1</b> ';                ...
                                        'VALIDAÇÕES '; '<b style="color: #a2142f; font-size: 14;">-1</b> '; ...
                                        'ROMPIMENTOS '; '<font style="color: #a2142f;">-1.000 MHz ';        ...
                                        '⌂ -1.0 kHz ';                                                      ...
                                        'Ʌ -1.0 dB </font>';                                                ...
                                        'dd-mmm-yyyy ';                                                     ...
                                        'HH:MM:SS '};
        end

        %-----------------------------------------------------------------%
        function Layout_lastMaskValidation(app, maskTrigger, ii, jj)
            if maskTrigger
                Validations = app.specObj(ii).Bands(jj).Mask.Validations;
                BrokenCount = app.specObj(ii).Bands(jj).Mask.BrokenCount;
        
                if ~isempty(app.specObj(ii).Bands(jj).Mask.Peaks)
                    nPeaks      = sprintf(' (%d)', height(app.specObj(ii).Bands(jj).Mask.Peaks));
                    FreqCenter  = app.specObj(ii).Bands(jj).Mask.Peaks.FreqCenter(1);
                    BandWidth   = app.specObj(ii).Bands(jj).Mask.Peaks.BW(1);
                    Prominence  = app.specObj(ii).Bands(jj).Mask.Peaks.Prominence(1);
                    dTimeStamp  = extractBefore(char(app.specObj(ii).Bands(jj).Mask.TimeStamp), ' ');
                    hTimeStamp  = extractAfter(char(app.specObj(ii).Bands(jj).Mask.TimeStamp), ' ');
                else
                    nPeaks      = '';
                    FreqCenter  = -1;
                    BandWidth   = -1;
                    Prominence  = -1;
                    dTimeStamp  = 'dd-mmm-yyyy';
                    hTimeStamp  = 'HH:MM:SS';
                end
        
                app.lastMask_text.Text = sprintf(['<b style="color: #a2142f; font-size: 14;">%.0f</b> \nVALIDAÇÕES \n'                  ...
                                                  '<b style="color: #a2142f; font-size: 14;">%.0f%s</b> \nROMPIMENTOS \n'               ...
                                                  '<font style="color: #a2142f;">%.3f MHz \n⌂ %.1f kHz \nɅ %.1f dB</font> \n%s \n%s '], ...
                                                  Validations, BrokenCount, nPeaks, FreqCenter, BandWidth, Prominence, dTimeStamp, hTimeStamp);
            else
                app.lastMask_text.Text = replace(app.lastMask_text.Text, [extractBefore(app.lastMask_text.Text, 'VALIDAÇÕES') 'VALIDAÇÕES'], ...
                    sprintf('<b style="color: #a2142f; font-size: 14;">%.0f</b> \nVALIDAÇÕES', app.specObj(ii).Bands(jj).Mask.Validations));
            end
        end

        %-----------------------------------------------------------------%
        % PLOT
        %-----------------------------------------------------------------%
        function plot_Layout(app)
            if app.axesTool_Waterfall.UserData.status
                set(app.axes1,          Visible=1)
                set(app.axes1.Children, Visible=1)
                app.axes1.Layout.Tile     = 1;
                app.axes1.Layout.TileSpan = [1 1];
                app.axes1.XTickLabel      = {};
                xlabel(app.axes1, '')

                set(app.axes2,          Visible=1)
                set(app.axes2.Children, Visible=1)
                app.axes2.Layout.Tile     = 2;
                app.axes2.Layout.TileSpan = [2 1];
            else
                set(app.axes1,          Visible=1)
                set(app.axes1.Children, Visible=1)
                app.axes1.Layout.Tile     = 1;
                app.axes1.Layout.TileSpan = [3 1];
                app.axes1.XTickLabelMode  = 'auto';
                xlabel(app.axes1, 'Frequência (MHz)')
                
                set(app.axes2,          Visible=0)
                set(app.axes2.Children, Visible=0)
                app.axes2.Layout.Tile     = 4;
                app.axes2.Layout.TileSpan = [1 1];
            end

            cb = findobj(app.axes2.Parent.Children, 'Type', 'colorbar');
            if ~isempty(cb)
                cb.Visible = app.axesTool_Waterfall.UserData.status;
            end
        end

        %-----------------------------------------------------------------%
        function plot_PlotSource(app, ii, jj)
            sources = {'Nível'};

            if ii > 0 && jj > 0
                if contains(app.specObj(ii).TaskSpec.Type, 'Drive-test (Level+Azimuth)')
                    sources{end+1} = 'Azimute';
                end
    
                % Se a tarefa for "Rompimento de Máscara Espectral" e o Status for 
                % maior do que zero, então o campo "Mask" será diferente de vazio.
                % A validação abaixo é idêntica (funcionalmente) à:
                
              % if contains(app.specObj(ii).TaskSpec.Type, 'Rompimento de Máscara Espectral') && app.specObj(ii).TaskSpec.Script.Band(jj).MaskTrigger.Status
                if ~isempty(app.specObj(ii).Bands(jj).Mask)
                    sources{end+1} = 'Máscara';
                end
            end

            set(app.axesTool_PlotSource, 'Items', sources, 'Enable', numel(sources) > 1)
            set([app.axesTool_MinHold, app.axesTool_Average, app.axesTool_MaxHold, app.axesTool_Peak], 'Enable', strcmp(app.axesTool_PlotSource.Value, 'Nível'))
        end

        %-----------------------------------------------------------------%
        function plot_Startup(app)
            cla(app.axes1)
            cla(app.axes2)
            ysecondarylabel(app.axes1, sprintf('\n\n'))
        
            app.line_ClrWrite = [];
            app.line_MinHold  = [];
            app.line_Average  = [];
            app.line_MaxHold  = [];
            app.peakExcursion = [];
            app.surface_WFall = [];            
        end

        %-----------------------------------------------------------------%
        function [xArray, downYLim, upYLim, FreqStart, FreqStop, LevelUnit, strUnit] = plot_AxesParameters(app, ii, jj, newArray)
            % xArray
            FreqStart = app.specObj(ii).TaskSpec.Script.Band(jj).FreqStart / 1e+6;
            FreqStop  = app.specObj(ii).TaskSpec.Script.Band(jj).FreqStop  / 1e+6;
            LevelUnit = app.specObj(ii).TaskSpec.Script.Band(jj).instrLevelUnit;
            xArray    = linspace(FreqStart, FreqStop, app.specObj(ii).Bands(jj).DataPoints);
    
            % General settings
            [~, strUnit] = class.Constants.yAxisUpLimit(app.specObj(ii).TaskSpec.Script.Band(jj).instrLevelUnit);
    
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
        function plot_Draw(app, ii, jj)
            idx = app.specObj(ii).Bands(jj).Waterfall.idx;
            newArray = app.specObj(ii).Bands(jj).Waterfall.Matrix(idx,:);

            if app.plotStyleEditing
                app.plotStyleEditing = 0;

                cla(app.axes1)
                app.line_ClrWrite = [];
            end
        
            if isempty(app.line_ClrWrite)
                [xArray, downYLim, upYLim, FreqStart, FreqStop, LevelUnit, strUnit] = plot_AxesParameters(app, ii, jj, newArray);

                switch app.axesTool_PlotSource.Value
                    case 'Nível'
                        % ORDINARY PLOT (SPECTRUM + MASK THRESHOLD)
                        ylabel(app.axes1, sprintf('Nível (%s)', strUnit));
                        set(app.axes1, XLim=[FreqStart, FreqStop], YLim=[downYLim, upYLim], YScale='linear')
            
                        % Mask threshold
                        if ~isempty(app.specObj(ii).Bands(jj).Mask)
                            plot.draw2D.mask(app.axes1, app.specObj(ii), jj)
                        end
                
                        % ClearWrite, MinHold, Average and MaxHold
                        app.line_ClrWrite = plot.draw2D.clearWrite(app.axes1, xArray, newArray, LevelUnit, 'ClrWrite', app.General);
                        
                        if app.axesTool_MinHold.UserData.status
                            app.line_MinHold  = plot.draw2D.minHold(app.axes1, app.specObj(ii), jj, xArray, newArray, LevelUnit, app.General);
                        end
                
                        if app.axesTool_Average.UserData.status
                            app.line_Average  = plot.draw2D.Average(app.axes1, app.specObj(ii), jj, xArray, newArray, LevelUnit, app.General);
                        end
                
                        if app.axesTool_MaxHold.UserData.status
                            app.line_MaxHold  = plot.draw2D.maxHold(app.axes1, app.specObj(ii), jj, xArray, newArray, LevelUnit, app.General);
                        end
            
                        if app.axesTool_Peak.UserData.status
                            app.peakExcursion = plot.draw2D.peakExcursion(app.peakExcursion, app.line_ClrWrite, app.specObj(ii), jj, newArray);
                        end

                    case 'Azimute'
                        ylabel(app.axes1, 'Azimute (º)');
                        set(app.axes1, XLim=[FreqStart, FreqStop], YLim=[0, 360], YScale='linear')

                        app.line_ClrWrite = plot.draw2D.clearWrite(app.axes1, xArray, app.specObj(ii).Bands(jj).Azimuth, LevelUnit, 'ClrWrite', app.General, 'Marker', '.', 'MarkerSize', 12, 'LineStyle', 'none');

                    case 'Máscara'
                        ylabel(app.axes1, 'Rompimento (%)');
                        set(app.axes1, XLim=[FreqStart, FreqStop], YLim=[.1, 100], YScale='log')
            
                        KK = 100/app.specObj(ii).Bands(jj).Mask.Validations;
                        app.line_ClrWrite = plot.draw2D.clearWrite(app.axes1, xArray, KK.*app.specObj(ii).Bands(jj).Mask.BrokenArray, '%%', 'MaskPlot', app.General, 'Marker', '.', 'MarkerSize', 12, 'LineStyle', 'none');
                end
                app.restoreView(1) = struct('ID', 'app.axes1', 'xLim', app.axes1.XLim, 'yLim', app.axes1.YLim,  'cLim', 'auto');

            else
                switch app.axesTool_PlotSource.Value
                    case 'Nível'
                        plot.draw2D.update(app.line_ClrWrite, newArray, app.General)
                        
                        if ~isempty(app.line_MinHold)
                            plot.draw2D.update(app.line_MinHold, newArray, app.General)
                        end
                        
                        if ~isempty(app.line_Average)
                            plot.draw2D.update(app.line_Average, newArray, app.General)
                        end
                        
                        if ~isempty(app.line_MaxHold)
                            plot.draw2D.update(app.line_MaxHold, newArray, app.General)
                        end
    
                        if ~isempty(app.peakExcursion)
                            app.peakExcursion = plot.draw2D.peakExcursion(app.peakExcursion, app.line_ClrWrite, app.specObj(ii), jj, newArray);
                        end

                    case 'Azimute'
                        plot.draw2D.update(app.line_ClrWrite, app.specObj(ii).Bands(jj).Azimuth, app.General)

                    case 'Máscara'
                        KK = 100/app.specObj(ii).Bands(jj).Mask.Validations;
                        plot.draw2D.update(app.line_ClrWrite, KK.*app.specObj(ii).Bands(jj).Mask.BrokenArray, app.General)
                end
            end

            % Waterfall
            if app.axesTool_Waterfall.UserData.status
                if isempty(app.surface_WFall)
                    if ~exist('xArray', 'var')
                        [xArray, downYLim, upYLim, FreqStart, FreqStop] = plot_AxesParameters(app, ii, jj, newArray);
                    end
                    set(app.axes2, 'YLim', [1, app.specObj(ii).Bands(jj).Waterfall.Depth], 'View', [0, 90], 'CLim', [downYLim, upYLim])
                    app.restoreView(2) = struct('ID', 'app.axes2', 'xLim', [FreqStart, FreqStop], 'yLim', app.axes2.YLim,  'cLim', app.axes2.CLim);

                    app.surface_WFall = plot.draw3D.Waterfall(app.axes2, app.specObj(ii), jj, xArray);
                else
                    app.surface_WFall.CData = circshift(app.specObj(ii).Bands(jj).Waterfall.Matrix, -idx);
                end
            end
        end

        %-----------------------------------------------------------------%
        function inputArguments = auxAppInputArguments(app, auxAppName)
            arguments
                app
                auxAppName char {mustBeMember(auxAppName, {'INSTRUMENT', 'TASK:EDIT', 'TASK:ADD', 'SERVER', 'CONFIG'})}
            end
            
            [auxAppIsOpen, ...
             auxAppHandle] = checkStatusModule(app.tabGroupController, auxAppName);

            inputArguments = {app};

            switch auxAppName
                case 'TASK:ADD'
                    if auxAppIsOpen
                        inputArguments = {app, auxAppHandle.infoEdition};
                    end

                otherwise
                    % ...
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

            % <EspecificidadeAppColeta1>
            if app.Flag_running
                ui.Dialog(app.UIFigure, 'warning', 'Existe uma tarefa em execução...');
                return
            end
            % </EspecificidadeAppColeta1>

            if ~strcmp(app.executionMode, 'webApp') && ~isempty(app.specObj)
                msgQuestion   = 'Deseja fechar o aplicativo?';
                userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            % <EspecificidadeAppColeta2>
            if app.General.startupInfo
                RegularTask_TasksSave(app)
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
            % </EspecificidadeAppColeta2>

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
                    inputArguments = menu_auxAppInputArguments(app, auxAppTag);
        
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
                                    if ismember(app.specObj(idx).Status, {'Na fila', 'Em andamento'})
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
            
        end

        % Selection changed function: UITable
        function onTableSelectionChanged(app, event)

            oldSelection = app.UITable.UserData;
            newSelection = app.UITable.Selection;

            if isempty(newSelection) && ~isempty(oldSelection)
                app.UITable.Selection = oldSelection;
                drawnow

            else
                app.UITable.UserData = newSelection;
                Layout_treeBuilding(app, 1)
            end
            
        end

        % Value changed function: DropDown
        function onTaskSelectionChanged(app, event)

            try
                ii = app.UITable.Selection;
                jj = app.DropDown.Value;

                plot_Startup(app)
                plot_PlotSource(app, ii, jj);
                
                if ~isempty(app.specObj(ii).Bands(jj).Waterfall)
                    idx = app.specObj(ii).Bands(jj).Waterfall.idx;
    
                    if idx
                        plot_Draw(app, ii, jj)
                    end
                end
    
                % TASK INFO THAT ARE UPDATED IN REAL TIME
                % (LEFT PANEL)
                Layout_metadataTab(app)
    
                % (RIGHT PANEL)
                if ~isempty(app.specObj(ii).Bands(jj).File); WritedSamples = app.specObj(ii).Bands(jj).File.WritedSamples;
                else;                                       WritedSamples = -1; 
                end
                app.Sweeps.Text = string(WritedSamples);
    
                if ~contains(app.specObj(ii).TaskSpec.Type, 'PRÉVIA') && strcmp(app.specObj(ii).Status, 'Em andamento') && app.specObj(ii).Bands(jj).Status
                    app.Sweeps_REC.Visible = 1;
                else
                    app.Sweeps_REC.Visible = 0;
                end
                
                if ~isempty(app.specObj(ii).Bands(jj).Mask)                    
                    app.lastMask_text.Enable = 1;
                    Layout_lastMaskValidation(app, true, ii, jj)
                else
                    Layout_lastMaskInitialState(app)
                end
                Layout_lastGPS(app, app.specObj(ii).GPSLastFix)
    
                % (DOWN STATUS PANEL)
                ysecondarylabel(app.axes1, sprintf('%s\n%s\n', app.UITable.Data.Receiver(ii), app.DropDown.Items{app.DropDown.Value}))
                if ~isempty(app.tool_RevisitTime.Text); app.tool_RevisitTime.Text = sprintf('%d varreduras\n%.3f seg', app.specObj(ii).Bands(jj).nSweeps, app.specObj(ii).Bands(jj).RevisitTime);
                else;                                   app.tool_RevisitTime.Text = '';
                end

                % PLAY BUTTON
                switch app.specObj(ii).Status
                    case 'Na fila';      set(app.tool_ButtonPlay, 'Enable', 'off', 'ImageSource', 'play_32.png')
                    case 'Em andamento'; set(app.tool_ButtonPlay, 'Enable', 'on',  'ImageSource', 'stop_32.png')
                    otherwise;           set(app.tool_ButtonPlay, 'Enable', 'on',  'ImageSource', 'play_32.png')
                end

            catch ME
                if exist('event', 'var')
                    event.Source.Value = event.Source.PreviousValue;
                    onTaskSelectionChanged(app)
                end

                ui.Dialog(app.UIFigure, 'error', getReport(ME));
            end
            drawnow

        end

        % Image clicked function: tool_ButtonPlay
        function Toolbar_ToggleTaskStatusButtonPushed(app, event)
            
            idx = app.UITable.Selection;
            if idx 
                switch app.specObj(idx).Status
                    %-----------------------------------------------------%
                    % PLAY
                    %-----------------------------------------------------%
                    case {'Cancelada', 'Erro', 'Concluída'}
                        Timestamp = datetime('now');
        
                        switch app.specObj(idx).TaskSpec.Script.Observation.Type
                            case 'Duration'
                                app.specObj(idx).Timing.startedAt = Timestamp;
                                app.specObj(idx).Timing.endedAt   = Timestamp + seconds(app.specObj(idx).TaskSpec.Script.Observation.Duration);
            
                            case 'Time'
                                if strcmp(app.specObj(idx).Status, 'Concluída')
                                    ui.Dialog(app.UIFigure, 'warning', 'Uma tarefa no estado "Concluída" somente poderá ser executada novamente se o tipo do período de observação for "Duração" ou "Quantidade específica de amostras".');
                                    return
                                end
            
                            case 'Samples'
                                app.specObj(idx).Timing.startedAt = Timestamp;
                                app.specObj(idx).Timing.endedAt   = NaT;
                        end
        
                        app.specObj(idx).Status = 'Na fila';
                        app.specObj(idx).LogEntries(end+1) = struct('level', 'task', 'timestamp', char(Timestamp), 'message', 'Reincluída na fila a tarefa.');

                        app.TaskController.restartStatus(idx, 1)
                        RegularTask_timerFcn(app)

                    %-----------------------------------------------------%
                    % STOP
                    %-----------------------------------------------------%
                    case 'Em andamento'
                        app.TaskController.statusTaskCheck(idx, 'DeleteButtonPushed');
                end
            end
            
        end

        % Image clicked function: tool_ButtonDel
        function Toolbar_DelTaskButtonPushed(app, event)
            
            idx = app.UITable.Selection;
            if idx
                switch app.specObj(idx).Status
                    case 'Em andamento'
                        ui.Dialog(app.UIFigure, 'warning', 'A tarefa precisa ser interrompida antes da tentativa de exclusão.');

                    otherwise
                        if ~app.Flag_running
                            app.specObj(idx) = [];    
                            Layout_tableBuilding(app, 1)
                        else
                            ui.Dialog(app.UIFigure, 'warning', 'Uma tarefa poderá ser excluída, sendo eliminada da lista de tarefas, somente se não estiver sendo executada nenhuma tarefa.');
                        end
                end
            end

        end

        % Image clicked function: tool_ButtonLOG
        function Toolbar_ShowTaskLogButtonPushed(app, event)

            idx = app.UITable.Selection;
            if idx
                log = util.HtmlTextGenerator.LOG(app.specObj, idx);
                ui.Dialog(app.UIFigure, 'warning', log);
            end

        end

        % Image clicked function: tool_LeftPanel
        function Toolbar_PanelVisibilityImageClicked(app, event)
            
            if app.task_docGrid.ColumnWidth{1}
                app.tool_LeftPanel.ImageSource = 'layout-sidebar-left-off.svg';
                app.task_docGrid.ColumnWidth(1:2) = {0,0};
            else
                app.tool_LeftPanel.ImageSource = 'layout-sidebar-left.svg';
                app.task_docGrid.ColumnWidth(1:2) = {320,10};
            end
            
        end

        % Image clicked function: axesTool_Average, axesTool_MaxHold, 
        % ...and 2 other components
        function axesTool_TraceModeImageClicked(app, event)
            
            event.Source.UserData.status = ~event.Source.UserData.status;
            if isfield(event.Source.UserData, 'icon')
                if event.Source.UserData.status
                    event.Source.ImageSource = event.Source.UserData.icon.On;
                else
                    event.Source.ImageSource = event.Source.UserData.icon.Off;
                end
            end

            if isempty(app.UITable.Selection) || isempty(app.DropDown.Items) || strcmp(app.axesTool_PlotSource.Value, 'Máscara')
                return
            end

            ii = app.UITable.Selection;
            jj = app.DropDown.Value;

            if ~isempty(app.specObj(ii).Bands(jj).Waterfall)
                idx = app.specObj(ii).Bands(jj).Waterfall.idx;

                if idx
                    FreqStart = app.specObj(ii).TaskSpec.Script.Band(jj).FreqStart / 1e+6;
                    FreqStop  = app.specObj(ii).TaskSpec.Script.Band(jj).FreqStop  / 1e+6;
                    LevelUnit = app.specObj(ii).TaskSpec.Script.Band(jj).instrLevelUnit;

                    xArray    = linspace(FreqStart, FreqStop, app.specObj(ii).Bands(jj).DataPoints);
                    newArray = app.specObj(ii).Bands(jj).Waterfall.Matrix(idx,:);

                    switch event.Source
                        case app.axesTool_MinHold
                            if event.Source.UserData.status
                                app.line_MinHold  = plot.draw2D.minHold(app.axes1, app.specObj(ii), jj, xArray, newArray, LevelUnit, app.General);
                            else
                                delete(app.line_MinHold)
                                app.line_MinHold  = [];
                            end

                        case app.axesTool_Average
                            if event.Source.UserData.status
                                app.line_Average  = plot.draw2D.Average(app.axes1, app.specObj(ii), jj, xArray, newArray, LevelUnit, app.General);
                            else
                                delete(app.line_Average)
                                app.line_Average  = [];
                            end

                        case app.axesTool_MaxHold
                            if event.Source.UserData.status
                                app.line_MaxHold  = plot.draw2D.maxHold(app.axes1, app.specObj(ii), jj, xArray, newArray, LevelUnit, app.General);
                            else
                                delete(app.line_MaxHold)
                                app.line_MaxHold  = [];
                            end

                        case app.axesTool_Peak
                            if event.Source.UserData.status
                                app.peakExcursion = plot.draw2D.peakExcursion(app.peakExcursion, app.line_ClrWrite, app.specObj(ii), jj, newArray);
                            else
                                delete(app.peakExcursion)
                                app.peakExcursion = [];
                            end
                    end
                    drawnow
                end
            end

        end

        % Image clicked function: axesTool_Waterfall
        function axesTool_ShowWaterfallImageClicked(app, event)
            
            event.Source.UserData.status = ~event.Source.UserData.status;
            plot_Layout(app)

            if ~isempty(app.UITable.Selection) && ~app.Flag_running
                axesTool_PlotSourceImageClicked(app)
            end

        end

        % Image clicked function: axesTool_RestoreView
        function axesTool_RestoreViewImageClicked(app, event)
            
            if ~isempty(app.axes1.Children)
                set(app.axes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)
            end

            if ~isempty(app.axes2.Children)
                set(app.axes2, 'XLim', app.restoreView(2).xLim, 'YLim', app.restoreView(2).yLim, 'CLim', app.restoreView(2).cLim)
            end

        end

        % Value changed function: axesTool_PlotSource
        function axesTool_PlotSourceImageClicked(app, event)
            
            set([app.axesTool_MinHold, app.axesTool_Average, app.axesTool_MaxHold, app.axesTool_Peak], 'Enable', strcmp(app.axesTool_PlotSource.Value, 'Nível'))
            
            ii = app.UITable.Selection;
            jj = app.DropDown.Value;
            
            if ~isempty(app.specObj(ii).Bands(jj).Waterfall)
                idx = app.specObj(ii).Bands(jj).Waterfall.idx;

                if idx
                    app.plotStyleEditing = 1;
                    plot_Draw(app, ii, jj)
                end
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

            % Create task_docGrid
            app.task_docGrid = uigridlayout(app.Tab1Grid);
            app.task_docGrid.ColumnWidth = {320, 10, '1x', 258, 5, 10, 130};
            app.task_docGrid.RowHeight = {140, 10, 17, 5, 2, 20, 5, '1x'};
            app.task_docGrid.ColumnSpacing = 0;
            app.task_docGrid.RowSpacing = 0;
            app.task_docGrid.Padding = [10 10 10 40];
            app.task_docGrid.Layout.Row = 1;
            app.task_docGrid.Layout.Column = 1;
            app.task_docGrid.BackgroundColor = [1 1 1];

            % Create UITable
            app.UITable = uitable(app.task_docGrid);
            app.UITable.ColumnName = {'ID'; 'TAREFA'; 'RECEPTOR'; 'INCLUSÃO'; 'INÍCIO|OBSERVAÇÃO'; 'FIM|OBSERVAÇÃO'; 'ESTADO'};
            app.UITable.ColumnWidth = {40, 'auto', 'auto', 120, 120, 120, 120};
            app.UITable.RowName = {};
            app.UITable.SelectionType = 'row';
            app.UITable.SelectionChangedFcn = createCallbackFcn(app, @onTableSelectionChanged, true);
            app.UITable.Multiselect = 'off';
            app.UITable.Layout.Row = 1;
            app.UITable.Layout.Column = [1 7];
            app.UITable.FontSize = 11;

            % Create Plot_Panel
            app.Plot_Panel = uipanel(app.task_docGrid);
            app.Plot_Panel.AutoResizeChildren = 'off';
            app.Plot_Panel.BorderType = 'none';
            app.Plot_Panel.BackgroundColor = [0 0 0];
            app.Plot_Panel.Layout.Row = [3 8];
            app.Plot_Panel.Layout.Column = [3 5];

            % Create TaskInfo_Panel
            app.TaskInfo_Panel = uigridlayout(app.task_docGrid);
            app.TaskInfo_Panel.ColumnWidth = {'1x'};
            app.TaskInfo_Panel.RowHeight = {82, '1x', '1x'};
            app.TaskInfo_Panel.Padding = [0 0 0 0];
            app.TaskInfo_Panel.Layout.Row = [3 8];
            app.TaskInfo_Panel.Layout.Column = 7;
            app.TaskInfo_Panel.BackgroundColor = [1 1 1];

            % Create Sweeps_Panel
            app.Sweeps_Panel = uipanel(app.TaskInfo_Panel);
            app.Sweeps_Panel.AutoResizeChildren = 'off';
            app.Sweeps_Panel.Layout.Row = 1;
            app.Sweeps_Panel.Layout.Column = 1;

            % Create Sweeps_Grid
            app.Sweeps_Grid = uigridlayout(app.Sweeps_Panel);
            app.Sweeps_Grid.ColumnWidth = {32, '1x', 18};
            app.Sweeps_Grid.RowHeight = {27, '1x', 18};
            app.Sweeps_Grid.ColumnSpacing = 0;
            app.Sweeps_Grid.RowSpacing = 0;
            app.Sweeps_Grid.Padding = [5 5 5 5];
            app.Sweeps_Grid.Tag = 'COLORLOCKED';
            app.Sweeps_Grid.BackgroundColor = [1 1 1];

            % Create Sweeps_REC
            app.Sweeps_REC = uiimage(app.Sweeps_Grid);
            app.Sweeps_REC.ScaleMethod = 'scaledown';
            app.Sweeps_REC.Visible = 'off';
            app.Sweeps_REC.Layout.Row = 3;
            app.Sweeps_REC.Layout.Column = 1;
            app.Sweeps_REC.HorizontalAlignment = 'left';
            app.Sweeps_REC.VerticalAlignment = 'bottom';
            app.Sweeps_REC.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'REC.gif');

            % Create Sweeps_Label
            app.Sweeps_Label = uilabel(app.Sweeps_Grid);
            app.Sweeps_Label.FontSize = 10;
            app.Sweeps_Label.FontColor = [0.149 0.149 0.149];
            app.Sweeps_Label.Layout.Row = 1;
            app.Sweeps_Label.Layout.Column = [1 3];
            app.Sweeps_Label.Text = {'VARREDURAS'; 'EM ARQUIVO'};

            % Create Sweeps
            app.Sweeps = uilabel(app.Sweeps_Grid);
            app.Sweeps.HorizontalAlignment = 'right';
            app.Sweeps.WordWrap = 'on';
            app.Sweeps.FontSize = 14;
            app.Sweeps.FontWeight = 'bold';
            app.Sweeps.FontColor = [0.6706 0.302 0.349];
            app.Sweeps.Layout.Row = 2;
            app.Sweeps.Layout.Column = [1 3];
            app.Sweeps.Text = '-1';

            % Create errorCount_txt
            app.errorCount_txt = uilabel(app.Sweeps_Grid);
            app.errorCount_txt.HorizontalAlignment = 'right';
            app.errorCount_txt.FontSize = 10;
            app.errorCount_txt.FontWeight = 'bold';
            app.errorCount_txt.FontColor = [1 0.651 0.651];
            app.errorCount_txt.Visible = 'off';
            app.errorCount_txt.Layout.Row = 3;
            app.errorCount_txt.Layout.Column = 2;
            app.errorCount_txt.Text = '0';

            % Create errorCount_img
            app.errorCount_img = uiimage(app.Sweeps_Grid);
            app.errorCount_img.ScaleMethod = 'none';
            app.errorCount_img.Visible = 'off';
            app.errorCount_img.Layout.Row = 3;
            app.errorCount_img.Layout.Column = 3;
            app.errorCount_img.HorizontalAlignment = 'right';
            app.errorCount_img.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Warn_18.png');

            % Create lastMask_Panel
            app.lastMask_Panel = uipanel(app.TaskInfo_Panel);
            app.lastMask_Panel.AutoResizeChildren = 'off';
            app.lastMask_Panel.Layout.Row = 2;
            app.lastMask_Panel.Layout.Column = 1;

            % Create lastMask_Grid
            app.lastMask_Grid = uigridlayout(app.lastMask_Panel);
            app.lastMask_Grid.ColumnWidth = {'1x'};
            app.lastMask_Grid.RowHeight = {15, '1x'};
            app.lastMask_Grid.ColumnSpacing = 2;
            app.lastMask_Grid.RowSpacing = 0;
            app.lastMask_Grid.Padding = [5 5 5 5];
            app.lastMask_Grid.Tag = 'COLORLOCKED';
            app.lastMask_Grid.BackgroundColor = [1 1 1];

            % Create lastMask_label
            app.lastMask_label = uilabel(app.lastMask_Grid);
            app.lastMask_label.VerticalAlignment = 'top';
            app.lastMask_label.FontSize = 10;
            app.lastMask_label.FontColor = [0.149 0.149 0.149];
            app.lastMask_label.Layout.Row = 1;
            app.lastMask_label.Layout.Column = 1;
            app.lastMask_label.Text = 'MÁSCARA';

            % Create lastMask_text
            app.lastMask_text = uilabel(app.lastMask_Grid);
            app.lastMask_text.HorizontalAlignment = 'right';
            app.lastMask_text.VerticalAlignment = 'top';
            app.lastMask_text.WordWrap = 'on';
            app.lastMask_text.FontSize = 10;
            app.lastMask_text.FontColor = [0.502 0.502 0.502];
            app.lastMask_text.Enable = 'off';
            app.lastMask_text.Layout.Row = 2;
            app.lastMask_text.Layout.Column = 1;
            app.lastMask_text.Interpreter = 'html';
            app.lastMask_text.Text = {'<b style="color: #a2142f; font-size: 14;">-1</b> '; 'VALIDAÇÕES '; '<b style="color: #a2142f; font-size: 14;">-1</b> '; 'ROMPIMENTOS '; '<font style="color: #a2142f;">-1.000 MHz '; '⌂ -1.0 kHz '; 'Ʌ -1.0 dB </font>'; 'dd-mmm-yyyy '; 'HH:MM:SS '};

            % Create lastGPS_Panel
            app.lastGPS_Panel = uipanel(app.TaskInfo_Panel);
            app.lastGPS_Panel.AutoResizeChildren = 'off';
            app.lastGPS_Panel.Layout.Row = 3;
            app.lastGPS_Panel.Layout.Column = 1;

            % Create lastGPS_Grid1
            app.lastGPS_Grid1 = uigridlayout(app.lastGPS_Panel);
            app.lastGPS_Grid1.ColumnWidth = {'1x', 18};
            app.lastGPS_Grid1.RowHeight = {27, '1x', 18};
            app.lastGPS_Grid1.ColumnSpacing = 0;
            app.lastGPS_Grid1.RowSpacing = 0;
            app.lastGPS_Grid1.Padding = [5 5 5 5];
            app.lastGPS_Grid1.Tag = 'COLORLOCKED';
            app.lastGPS_Grid1.BackgroundColor = [1 1 1];

            % Create lastGPS_label
            app.lastGPS_label = uilabel(app.lastGPS_Grid1);
            app.lastGPS_label.VerticalAlignment = 'top';
            app.lastGPS_label.FontSize = 10;
            app.lastGPS_label.FontColor = [0.149 0.149 0.149];
            app.lastGPS_label.Layout.Row = 1;
            app.lastGPS_label.Layout.Column = [1 2];
            app.lastGPS_label.Text = {'COORDENADAS'; 'GEOGRÁFICAS'};

            % Create lastGPS_text
            app.lastGPS_text = uilabel(app.lastGPS_Grid1);
            app.lastGPS_text.HorizontalAlignment = 'right';
            app.lastGPS_text.VerticalAlignment = 'top';
            app.lastGPS_text.WordWrap = 'on';
            app.lastGPS_text.FontSize = 10;
            app.lastGPS_text.FontColor = [0.502 0.502 0.502];
            app.lastGPS_text.Layout.Row = [2 3];
            app.lastGPS_text.Layout.Column = [1 2];
            app.lastGPS_text.Interpreter = 'html';
            app.lastGPS_text.Text = {'<b style="color: #a2142f; font-size: 14;">-1.000</b> LAT '; '<b style="color: #a2142f; font-size: 14;">-1.000</b> LON '; 'dd-mmm-yyyy '; 'HH:MM:SS '};

            % Create lastGPS_Grid2
            app.lastGPS_Grid2 = uigridlayout(app.lastGPS_Grid1);
            app.lastGPS_Grid2.ColumnWidth = {'1x'};
            app.lastGPS_Grid2.RowHeight = {12, '1x'};
            app.lastGPS_Grid2.ColumnSpacing = 0;
            app.lastGPS_Grid2.RowSpacing = 0;
            app.lastGPS_Grid2.Padding = [0 0 0 0];
            app.lastGPS_Grid2.Layout.Row = 1;
            app.lastGPS_Grid2.Layout.Column = 2;
            app.lastGPS_Grid2.BackgroundColor = [1 1 1];

            % Create lastGPS_color
            app.lastGPS_color = uilamp(app.lastGPS_Grid2);
            app.lastGPS_color.Layout.Row = 1;
            app.lastGPS_color.Layout.Column = 1;
            app.lastGPS_color.Color = [0.502 0.502 0.502];

            % Create errorCount_txt_2
            app.errorCount_txt_2 = uilabel(app.lastGPS_Grid1);
            app.errorCount_txt_2.HorizontalAlignment = 'right';
            app.errorCount_txt_2.FontSize = 10;
            app.errorCount_txt_2.FontWeight = 'bold';
            app.errorCount_txt_2.FontColor = [1 0.651 0.651];
            app.errorCount_txt_2.Visible = 'off';
            app.errorCount_txt_2.Layout.Row = 3;
            app.errorCount_txt_2.Layout.Column = 1;
            app.errorCount_txt_2.Text = '0';

            % Create errorCount_img_2
            app.errorCount_img_2 = uiimage(app.lastGPS_Grid1);
            app.errorCount_img_2.ScaleMethod = 'none';
            app.errorCount_img_2.Visible = 'off';
            app.errorCount_img_2.Layout.Row = 3;
            app.errorCount_img_2.Layout.Column = 2;
            app.errorCount_img_2.HorizontalAlignment = 'right';
            app.errorCount_img_2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Warn_18.png');

            % Create play_axesToolbar
            app.play_axesToolbar = uigridlayout(app.task_docGrid);
            app.play_axesToolbar.ColumnWidth = {22, 5, 110, 5, 22, 22, 22, 22, 22};
            app.play_axesToolbar.RowHeight = {2, 18, 2};
            app.play_axesToolbar.ColumnSpacing = 0;
            app.play_axesToolbar.RowSpacing = 0;
            app.play_axesToolbar.Padding = [2 2 2 0];
            app.play_axesToolbar.Layout.Row = [3 5];
            app.play_axesToolbar.Layout.Column = 4;
            app.play_axesToolbar.BackgroundColor = [1 1 1];

            % Create axesTool_RestoreView
            app.axesTool_RestoreView = uiimage(app.play_axesToolbar);
            app.axesTool_RestoreView.ImageClickedFcn = createCallbackFcn(app, @axesTool_RestoreViewImageClicked, true);
            app.axesTool_RestoreView.Tag = 'MinHold';
            app.axesTool_RestoreView.Tooltip = {'RestoreView'};
            app.axesTool_RestoreView.Layout.Row = 2;
            app.axesTool_RestoreView.Layout.Column = 1;
            app.axesTool_RestoreView.VerticalAlignment = 'bottom';
            app.axesTool_RestoreView.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Home_18.png');

            % Create axesTool_PlotSource
            app.axesTool_PlotSource = uidropdown(app.play_axesToolbar);
            app.axesTool_PlotSource.Items = {'Nível'};
            app.axesTool_PlotSource.ValueChangedFcn = createCallbackFcn(app, @axesTool_PlotSourceImageClicked, true);
            app.axesTool_PlotSource.Enable = 'off';
            app.axesTool_PlotSource.Tooltip = {'Fonte de dados'};
            app.axesTool_PlotSource.FontSize = 11;
            app.axesTool_PlotSource.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_PlotSource.BackgroundColor = [1 1 1];
            app.axesTool_PlotSource.Layout.Row = [1 3];
            app.axesTool_PlotSource.Layout.Column = 3;
            app.axesTool_PlotSource.Value = 'Nível';

            % Create axesTool_MinHold
            app.axesTool_MinHold = uiimage(app.play_axesToolbar);
            app.axesTool_MinHold.ImageClickedFcn = createCallbackFcn(app, @axesTool_TraceModeImageClicked, true);
            app.axesTool_MinHold.Tag = 'MinHold';
            app.axesTool_MinHold.Tooltip = {'MinHold'};
            app.axesTool_MinHold.Layout.Row = 2;
            app.axesTool_MinHold.Layout.Column = 5;
            app.axesTool_MinHold.VerticalAlignment = 'bottom';
            app.axesTool_MinHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MinHold_32.png');

            % Create axesTool_Average
            app.axesTool_Average = uiimage(app.play_axesToolbar);
            app.axesTool_Average.ImageClickedFcn = createCallbackFcn(app, @axesTool_TraceModeImageClicked, true);
            app.axesTool_Average.Tag = 'Average';
            app.axesTool_Average.Tooltip = {'Média'};
            app.axesTool_Average.Layout.Row = 2;
            app.axesTool_Average.Layout.Column = 6;
            app.axesTool_Average.VerticalAlignment = 'bottom';
            app.axesTool_Average.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Average_32.png');

            % Create axesTool_MaxHold
            app.axesTool_MaxHold = uiimage(app.play_axesToolbar);
            app.axesTool_MaxHold.ImageClickedFcn = createCallbackFcn(app, @axesTool_TraceModeImageClicked, true);
            app.axesTool_MaxHold.Tag = 'MaxHold';
            app.axesTool_MaxHold.Tooltip = {'MaxHold'};
            app.axesTool_MaxHold.Layout.Row = 2;
            app.axesTool_MaxHold.Layout.Column = 7;
            app.axesTool_MaxHold.VerticalAlignment = 'bottom';
            app.axesTool_MaxHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MaxHold_32.png');

            % Create axesTool_Peak
            app.axesTool_Peak = uiimage(app.play_axesToolbar);
            app.axesTool_Peak.ScaleMethod = 'none';
            app.axesTool_Peak.ImageClickedFcn = createCallbackFcn(app, @axesTool_TraceModeImageClicked, true);
            app.axesTool_Peak.Tag = 'Persistance';
            app.axesTool_Peak.Tooltip = {'Excursão de pico'};
            app.axesTool_Peak.Layout.Row = 2;
            app.axesTool_Peak.Layout.Column = 8;
            app.axesTool_Peak.VerticalAlignment = 'bottom';
            app.axesTool_Peak.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Detection_18.png');

            % Create axesTool_Waterfall
            app.axesTool_Waterfall = uiimage(app.play_axesToolbar);
            app.axesTool_Waterfall.ScaleMethod = 'none';
            app.axesTool_Waterfall.ImageClickedFcn = createCallbackFcn(app, @axesTool_ShowWaterfallImageClicked, true);
            app.axesTool_Waterfall.Tag = 'Waterfall';
            app.axesTool_Waterfall.Tooltip = {'Waterfall'};
            app.axesTool_Waterfall.Layout.Row = 2;
            app.axesTool_Waterfall.Layout.Column = 9;
            app.axesTool_Waterfall.HorizontalAlignment = 'left';
            app.axesTool_Waterfall.VerticalAlignment = 'bottom';
            app.axesTool_Waterfall.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Waterfall_24.png');

            % Create FAIXADEFREQUNCIALabel
            app.FAIXADEFREQUNCIALabel = uilabel(app.task_docGrid);
            app.FAIXADEFREQUNCIALabel.VerticalAlignment = 'bottom';
            app.FAIXADEFREQUNCIALabel.FontSize = 10;
            app.FAIXADEFREQUNCIALabel.Layout.Row = 3;
            app.FAIXADEFREQUNCIALabel.Layout.Column = 1;
            app.FAIXADEFREQUNCIALabel.Text = 'FAIXA DE FREQUÊNCIA:';

            % Create DropDown
            app.DropDown = uidropdown(app.task_docGrid);
            app.DropDown.Items = {};
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @onTaskSelectionChanged, true);
            app.DropDown.FontSize = 11;
            app.DropDown.BackgroundColor = [1 1 1];
            app.DropDown.Layout.Row = [5 6];
            app.DropDown.Layout.Column = 1;
            app.DropDown.Value = {};

            % Create MetaData
            app.MetaData = uilabel(app.task_docGrid);
            app.MetaData.BackgroundColor = [1 1 1];
            app.MetaData.VerticalAlignment = 'top';
            app.MetaData.WordWrap = 'on';
            app.MetaData.FontSize = 11;
            app.MetaData.Layout.Row = 8;
            app.MetaData.Layout.Column = 1;
            app.MetaData.Interpreter = 'html';
            app.MetaData.Text = '';

            % Create task_toolGrid
            app.task_toolGrid = uigridlayout(app.Tab1Grid);
            app.task_toolGrid.ColumnWidth = {22, 5, 22, 22, 5, 22, '1x'};
            app.task_toolGrid.RowHeight = {4, 17, 2};
            app.task_toolGrid.ColumnSpacing = 5;
            app.task_toolGrid.RowSpacing = 0;
            app.task_toolGrid.Padding = [10 5 10 5];
            app.task_toolGrid.Layout.Row = 2;
            app.task_toolGrid.Layout.Column = 1;

            % Create tool_LeftPanel
            app.tool_LeftPanel = uiimage(app.task_toolGrid);
            app.tool_LeftPanel.ScaleMethod = 'none';
            app.tool_LeftPanel.ImageClickedFcn = createCallbackFcn(app, @Toolbar_PanelVisibilityImageClicked, true);
            app.tool_LeftPanel.Tooltip = {''};
            app.tool_LeftPanel.Layout.Row = [1 3];
            app.tool_LeftPanel.Layout.Column = 1;
            app.tool_LeftPanel.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'layout-sidebar-left.svg');

            % Create tool_Separator1
            app.tool_Separator1 = uiimage(app.task_toolGrid);
            app.tool_Separator1.ScaleMethod = 'none';
            app.tool_Separator1.Enable = 'off';
            app.tool_Separator1.Layout.Row = [1 3];
            app.tool_Separator1.Layout.Column = 2;
            app.tool_Separator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_ButtonPlay
            app.tool_ButtonPlay = uiimage(app.task_toolGrid);
            app.tool_ButtonPlay.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ToggleTaskStatusButtonPushed, true);
            app.tool_ButtonPlay.Enable = 'off';
            app.tool_ButtonPlay.Tooltip = {''};
            app.tool_ButtonPlay.Layout.Row = 2;
            app.tool_ButtonPlay.Layout.Column = 3;
            app.tool_ButtonPlay.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'play_32.png');

            % Create tool_ButtonDel
            app.tool_ButtonDel = uiimage(app.task_toolGrid);
            app.tool_ButtonDel.ImageClickedFcn = createCallbackFcn(app, @Toolbar_DelTaskButtonPushed, true);
            app.tool_ButtonDel.Enable = 'off';
            app.tool_ButtonDel.Tooltip = {''};
            app.tool_ButtonDel.Layout.Row = 2;
            app.tool_ButtonDel.Layout.Column = 4;
            app.tool_ButtonDel.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Delete_32Red.png');

            % Create tool_Separator2
            app.tool_Separator2 = uiimage(app.task_toolGrid);
            app.tool_Separator2.ScaleMethod = 'none';
            app.tool_Separator2.Enable = 'off';
            app.tool_Separator2.Layout.Row = [1 3];
            app.tool_Separator2.Layout.Column = 5;
            app.tool_Separator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_ButtonLOG
            app.tool_ButtonLOG = uiimage(app.task_toolGrid);
            app.tool_ButtonLOG.ImageClickedFcn = createCallbackFcn(app, @Toolbar_ShowTaskLogButtonPushed, true);
            app.tool_ButtonLOG.Enable = 'off';
            app.tool_ButtonLOG.Tooltip = {''};
            app.tool_ButtonLOG.Layout.Row = 2;
            app.tool_ButtonLOG.Layout.Column = 6;
            app.tool_ButtonLOG.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LOG_32.png');

            % Create tool_RevisitTime
            app.tool_RevisitTime = uilabel(app.task_toolGrid);
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
