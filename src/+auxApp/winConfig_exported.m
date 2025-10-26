classdef winConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        DockModuleGroup                matlab.ui.container.GridLayout
        dockModule_Undock              matlab.ui.control.Image
        dockModule_Close               matlab.ui.control.Image
        TabGroup                       matlab.ui.container.TabGroup
        Tab1                           matlab.ui.container.Tab
        Tab1Grid                       matlab.ui.container.GridLayout
        openAuxiliarApp2Debug          matlab.ui.control.CheckBox
        openAuxiliarAppAsDocked        matlab.ui.control.CheckBox
        tool_versionInfoRefresh        matlab.ui.control.Image
        versionInfo                    matlab.ui.control.Label
        versionInfoLabel               matlab.ui.control.Label
        Tab2                           matlab.ui.container.Tab
        general_Grid                   matlab.ui.container.GridLayout
        general_versionPanel           matlab.ui.container.Panel
        server_Grid                    matlab.ui.container.GridLayout
        server_Port                    matlab.ui.control.NumericEditField
        server_PortLabel               matlab.ui.control.Label
        server_IP                      matlab.ui.control.EditField
        server_IPLabel                 matlab.ui.control.Label
        server_ClientList              matlab.ui.control.EditField
        server_ClientListLabel         matlab.ui.control.Label
        server_Key                     matlab.ui.control.EditField
        server_KeyLabel                matlab.ui.control.Label
        server_Status                  matlab.ui.control.DropDown
        server_StatusLabel             matlab.ui.control.Label
        general_versionLock            matlab.ui.control.Image
        general_versionLabel           matlab.ui.control.Label
        general_FilePanel              matlab.ui.container.Panel
        general_stationGrid            matlab.ui.container.GridLayout
        general_lastSessionInfo        matlab.ui.control.CheckBox
        general_stationLongitude       matlab.ui.control.NumericEditField
        general_stationLongitudeLabel  matlab.ui.control.Label
        general_stationLatitude        matlab.ui.control.NumericEditField
        general_stationLatitudeLabel   matlab.ui.control.Label
        general_stationType            matlab.ui.control.DropDown
        general_stationTypeLabel       matlab.ui.control.Label
        general_stationName            matlab.ui.control.EditField
        general_stationNameLabel       matlab.ui.control.Label
        general_FileLock               matlab.ui.control.Image
        general_FileLabel              matlab.ui.control.Label
        Tab3                           matlab.ui.container.Tab
        plot_Grid                      matlab.ui.container.GridLayout
        plot_IntegrationPanel          matlab.ui.container.Panel
        plot_IntegrationGrid           matlab.ui.container.GridLayout
        plot_IntegrationTime           matlab.ui.control.NumericEditField
        plot_IntegrationTimeLabel      matlab.ui.control.Label
        plot_IntegrationTrace          matlab.ui.control.NumericEditField
        plot_IntegrationTraceLabel     matlab.ui.control.Label
        plot_IntegrationLabel          matlab.ui.control.Label
        plot_WaterfallPanel            matlab.ui.container.Panel
        plot_WaterfallGrid             matlab.ui.container.GridLayout
        plot_WaterfallDepth            matlab.ui.control.DropDown
        plot_WaterfallDepthLabel       matlab.ui.control.Label
        plot_WaterfallColormap         matlab.ui.control.DropDown
        plot_WaterfallColormapLabel    matlab.ui.control.Label
        plot_WaterfallLabel            matlab.ui.control.Label
        plot_colorsPanel               matlab.ui.container.Panel
        plot_colorsGrid                matlab.ui.container.GridLayout
        plot_colorsClearWrite          matlab.ui.control.ColorPicker
        plot_colorsClearWriteLabel     matlab.ui.control.Label
        plot_colorsMaxHold             matlab.ui.control.ColorPicker
        plot_colorsMaxHoldLabel        matlab.ui.control.Label
        plot_colorsAverage             matlab.ui.control.ColorPicker
        plot_colorsAverageLabel        matlab.ui.control.Label
        plot_colorsMinHold             matlab.ui.control.ColorPicker
        plot_colorsMinHoldLabel        matlab.ui.control.Label
        plot_colorsLabel               matlab.ui.control.Label
        plot_TiledSpacing              matlab.ui.control.DropDown
        plot_TiledSpacingLabel         matlab.ui.control.Label
        plot_InteractionsPanel         matlab.ui.container.Panel
        plot_InteractionsGrid          matlab.ui.container.GridLayout
        plot_RestoreViewVisibility     matlab.ui.control.Image
        plot_RestoreView               matlab.ui.control.Image
        plot_ZoomOutVisibility         matlab.ui.control.Image
        plot_ZoomOut                   matlab.ui.control.Image
        plot_ZoomInVisibility          matlab.ui.control.Image
        plot_ZoomIn                    matlab.ui.control.Image
        plot_PanVisibility             matlab.ui.control.Image
        plot_Pan                       matlab.ui.control.Image
        plot_DatatipVisibility         matlab.ui.control.Image
        plot_Datatip                   matlab.ui.control.Image
        configPlotRefresh              matlab.ui.control.Image
        plot_InteractionsLabel         matlab.ui.control.Label
        Tab5                           matlab.ui.container.Tab
        Tab5Grid                       matlab.ui.container.GridLayout
        userPathButton                 matlab.ui.control.Image
        userPath                       matlab.ui.control.EditField
        userPathLabel                  matlab.ui.control.Label
        DataHubPOSTButton              matlab.ui.control.Image
        DataHubPOST                    matlab.ui.control.EditField
        DATAHUBPOSTLabel               matlab.ui.control.Label
        Toolbar                        matlab.ui.container.GridLayout
        tool_openDevTools              matlab.ui.control.Image
        tool_simulationMode            matlab.ui.control.Image
    end

    
    properties
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        
        mainApp

        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos 
        % componentes essenciais da GUI (especificados em "createComponents"), 
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj
        jsBackDoor

        % Janela de progresso já criada no DOM. Dessa forma, controla-se 
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog

        stableVersion
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        defaultValues
    end


    methods
        %-----------------------------------------------------------------%
        % IPC: COMUNICAÇÃO ENTRE PROCESSOS
        %-----------------------------------------------------------------%
        function ipcSecundaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        startup_Controller(app)

                    otherwise
                        error('UnexpectedEvent')
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
            end
        end
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor = uihtml(app.UIFigure, "HTMLSource",           appUtil.jsBackDoorHTMLSource(),                 ...
                                                  "HTMLEventReceivedFcn", @(~, evt)ipcSecundaryJSEventsHandler(app, evt), ...
                                                  "Visible",              "off");
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false, false, false];
            end

            switch tabIndex
                case 0 % STARTUP
                    if app.isDocked
                        app.progressDialog = app.mainApp.progressDialog;
                    else
                        sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                        app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);
                    end
                    customizationStatus = [false, false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1
                            appName = class(app);

                            % Grid botões "dock":
                            if app.isDocked
                                elToModify = {app.DockModuleGroup};
                                elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                                if ~isempty(elDataTag)
                                    sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                        struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('transition', 'opacity 2s ease', 'opacity', '0.5')), ...
                                    });
                                end
                            end
                            
                            % Outros elementos:
                            elToModify = {app.versionInfo};
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                ui.TextView.startup(app.jsBackDoor, app.versionInfo, appName);
                            end

                        case 2
                            updatePanel_ERMx(app)

                        case 3
                            updatePanel_Plot(app)

                        case 4
                            updatePanel_Folder(app)
                    end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function startup_timerCreation(app)
            app.timerObj = timer("ExecutionMode", "fixedSpacing", ...
                                 "StartDelay",    1.5,            ...
                                 "Period",        .1,             ...
                                 "TimerFcn",      @(~,~)app.startup_timerFcn);
            start(app.timerObj)
        end

        %-----------------------------------------------------------------%
        function startup_timerFcn(app)
            if ccTools.fcn.UIFigureRenderStatus(app.UIFigure)
                stop(app.timerObj)
                delete(app.timerObj)

                jsBackDoor_Initialization(app)
            end
        end

        %-----------------------------------------------------------------%
        function startup_Controller(app)
            drawnow
            jsBackDoor_Customizations(app, 0)
            jsBackDoor_Customizations(app, 1)

            startup_AppProperties(app)
            startup_GUIComponents(app)
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            % Lê a versão de "GeneralSettings.json" que vem junto ao
            % projeto (e não a versão armazenada em "ProgramData").
            projectFolder     = appUtil.Path(class.Constants.appName, app.mainApp.rootFolder);
            projectFilePath   = fullfile(projectFolder, 'GeneralSettings.json');
            projectGeneral    = jsondecode(fileread(projectFilePath));

            app.defaultValues = struct('Plot',        projectGeneral.Plot, ...
                                       'Integration', projectGeneral.Integration);
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
                app.tool_openDevTools.Enable = 1;

                set([app.DataHubPOSTButton, app.userPathButton], 'Enable', 1)
                app.tool_versionInfoRefresh.Enable = 1;
                app.openAuxiliarAppAsDocked.Enable = 1;
            end

            if ~isdeployed
                app.openAuxiliarApp2Debug.Enable = 1;
            end

            updatePanel_General(app)
        end

        %-----------------------------------------------------------------%
        function updatePanel_General(app)
            % Versão
            ui.TextView.update(app.versionInfo, util.HtmlTextGenerator.AppInfo(app.mainApp.General, app.mainApp.rootFolder, app.mainApp.executionMode, app.mainApp.renderCount, "textview"));

            % Modo de operação
            app.openAuxiliarAppAsDocked.Value = app.mainApp.General.operationMode.Dock;
            app.openAuxiliarApp2Debug.Value   = app.mainApp.General.operationMode.Debug;
        end

        %-----------------------------------------------------------------%
        function updatePanel_ERMx(app)
            % ERMx
            app.general_stationName.Value       = app.mainApp.General.stationInfo.Name;
            app.general_stationType.Items       = {app.mainApp.General.stationInfo.Type};
            app.general_stationLatitude.Value   = app.mainApp.General.stationInfo.Latitude;
            app.general_stationLongitude.Value  = app.mainApp.General.stationInfo.Longitude;
            app.general_lastSessionInfo.Value   = app.mainApp.General.startupInfo;

            % WEBSERVICE
            switch app.mainApp.General.tcpServer.Status
                case 1; app.server_Status.Value = 'ON';
                case 0; app.server_Status.Value = 'OFF';
            end

            app.server_Key.Value                = app.mainApp.General.tcpServer.Key;
            app.server_ClientList.Value         = strjoin(app.mainApp.General.tcpServer.ClientList, ', ');
            app.server_IP.Value                 = app.mainApp.General.tcpServer.IP;
            app.server_Port.Value               = app.mainApp.General.tcpServer.Port;
        end

        %-----------------------------------------------------------------%
        function updatePanel_Plot(app)
            set(findobj(app.plot_InteractionsGrid, Tag='InteractionVisibility'), Visible=0)

            for ii = 1:numel(app.mainApp.axes1.Toolbar.Children)
                switch app.mainApp.axes1.Toolbar.Children(ii).Tag
                    case 'datacursor';  h = app.plot_DatatipVisibility;
                    case 'pan';         h = app.plot_PanVisibility;
                    case 'zoomin';      h = app.plot_ZoomInVisibility;
                    case 'zoomout';     h = app.plot_ZoomOutVisibility;
                    case 'restoreview'; h = app.plot_RestoreViewVisibility;
                end

                if app.mainApp.axes1.Toolbar.Children(ii).Visible
                    h.Visible = 1;
                end
            end

            app.plot_TiledSpacing.Value = app.mainApp.axes1.Parent.TileSpacing;

            app.plot_colorsMinHold.Value     = app.mainApp.General.Plot.MinHold.Color;
            app.plot_colorsAverage.Value     = app.mainApp.General.Plot.Average.Color;
            app.plot_colorsMaxHold.Value     = app.mainApp.General.Plot.MaxHold.Color;
            app.plot_colorsClearWrite.Value  = app.mainApp.General.Plot.ClearWrite.Color;
            
            app.plot_WaterfallColormap.Items = unique([app.plot_WaterfallColormap.Items, {app.mainApp.General.Plot.Waterfall.Colormap}]);
            app.plot_WaterfallColormap.Value = app.mainApp.General.Plot.Waterfall.Colormap;

            app.plot_WaterfallDepth.Items    = unique([app.plot_WaterfallDepth.Items, {num2str(app.mainApp.General.Plot.Waterfall.Depth)}], 'stable');
            app.plot_WaterfallDepth.Value    = {num2str(app.mainApp.General.Plot.Waterfall.Depth)};

            app.plot_IntegrationTrace.Value  = app.mainApp.General.Integration.Trace;
            app.plot_IntegrationTime.Value   = app.mainApp.General.Integration.SampleTime;

            if checkEdition(app, 'PLOT')
                app.configPlotRefresh.Visible = 1;
            else
                app.configPlotRefresh.Visible = 0;
            end
        end

        %-----------------------------------------------------------------%
        function updatePanel_Folder(app)
            DataHub_POST = app.mainApp.General.fileFolder.DataHub_POST;    
            if isfolder(DataHub_POST)
                app.DataHubPOST.Value = DataHub_POST;
            end

            app.userPath.Value = app.mainApp.General.fileFolder.userPath;                
        end

        %-----------------------------------------------------------------%
        function editionFlag = checkEdition(app, tabName)
            editionFlag   = false;
            currentValues = struct('Plot',        app.mainApp.General.Plot, ...
                                   'Integration', app.mainApp.General.Integration);

            switch tabName
                case 'ERMx'
                    % ...
                case 'PLOT'
                    if ~isequal(currentValues, app.defaultValues)
                        editionFlag = true;
                    end
            end
        end

        %-----------------------------------------------------------------%
        function saveGeneralSettings(app)
            appUtil.generalSettingsSave(class.Constants.appName, app.mainApp.rootFolder, app.mainApp.General_I, app.mainApp.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            app.mainApp = mainApp;

            if app.isDocked
                app.GridLayout.Padding(4) = 30;
                app.DockModuleGroup.Visible = 1;
                app.jsBackDoor = mainApp.jsBackDoor;
                startup_Controller(app)
            else
                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn')
            delete(app)
            
        end

        % Image clicked function: dockModule_Close, dockModule_Undock
        function DockModuleGroup_ButtonPushed(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.dockModule_Undock
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;

                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];
                    
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.dockModule_Close
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Selection change function: TabGroup
        function TabGroup_TabSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.TabGroup.SelectedTab, app.TabGroup.Children);
            jsBackDoor_Customizations(app, tabIndex)

        end

        % Image clicked function: tool_versionInfoRefresh
        function Toolbar_AppEnvRefreshButtonPushed(app, event)
            
            app.progressDialog.Visible = 'visible';

            [htmlContent, app.stableVersion] = util.HtmlTextGenerator.checkAvailableUpdate(app.mainApp.General, app.mainApp.rootFolder);
            appUtil.modalWindow(app.UIFigure, "info", htmlContent);

            app.progressDialog.Visible = 'hidden';

        end

        % Image clicked function: tool_simulationMode
        function Toolbar_SimulationModeButtonPushed(app, event)
            
            msgQuestion   = 'Deseja abrir arquivos de <b>simulação</b>?';
            userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
            
            if strcmp(userSelection, 'Não')
                return
            end

            app.mainApp.General.operationMode.Simulation = true;
            ipcMainMatlabCallsHandler(app.mainApp, app, 'simulationModeChanged')

        end

        % Image clicked function: tool_openDevTools
        function Toolbar_OpenDevToolsClicked(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'openDevTools')

        end

        % Value changed function: openAuxiliarApp2Debug, 
        % ...and 1 other component
        function Config_GeneralParameterValueChanged(app, event)
            
            switch event.Source
                case app.openAuxiliarAppAsDocked
                    app.mainApp.General.operationMode.Dock  = app.openAuxiliarAppAsDocked.Value;

                case app.openAuxiliarApp2Debug
                    app.mainApp.General.operationMode.Debug = app.openAuxiliarApp2Debug.Value;
            end

            app.mainApp.General_I.operationMode = app.mainApp.General.operationMode;
            saveGeneralSettings(app)

        end

        % Image clicked function: DataHubPOSTButton, userPathButton
        function Config_FolderButtonPushed(app, event)
            
            try
                relatedFolder = eval(sprintf('app.%s.Value', event.Source.Tag));
            catch
                relatedFolder = app.mainApp.General.fileFolder.(event.Source.Tag);
            end
            
            if isfolder(relatedFolder)
                initialFolder = relatedFolder;
            elseif isfile(relatedFolder)
                initialFolder = fileparts(relatedFolder);
            else
                initialFolder = app.userPath.Value;
            end

            selectedFolder = uigetdir(initialFolder);
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                figure(app.UIFigure)
            end

            if selectedFolder
                switch event.Source
                    case app.DataHubPOSTButton
                        if strcmp(app.mainApp.General.fileFolder.DataHub_POST, selectedFolder) 
                            return
                        else
                            selectedFolderFiles = dir(selectedFolder);
                            if ~ismember('.monitorrni_post', {selectedFolderFiles.name})
                                appUtil.modalWindow(app.UIFigure, 'error', 'Não se trata da pasta "DataHub - POST", do monitorRNI.');
                                return
                            end

                            app.DataHubPOST.Value = selectedFolder;
                            app.mainApp.General.fileFolder.DataHub_POST = selectedFolder;
    
                            ipcMainMatlabCallsHandler(app.mainApp, app, 'checkDataHubLampStatus')
                        end

                    case app.userPathButton
                        app.userPath.Value = selectedFolder;
                        app.mainApp.General.fileFolder.userPath = selectedFolder;
                end

                app.mainApp.General_I.fileFolder = app.mainApp.General.fileFolder;

                updatePanel_Folder(app)
                saveGeneralSettings(app)
            end

        end

        % Value changed function: general_lastSessionInfo, 
        % ...and 9 other components
        function general_ParameterChanged(app, event)
            
            switch event.Source
                case app.general_stationName
                    if isempty(regexp(app.general_stationName.Value, '^EMSat$|^UMS.*|^ERMx-[A-Z]{2}-[0-9][1-9]$', 'once'))
                        msgQuestion   = ['O nome esperado de uma estação é <b>"ERMx-UF-XX"</b>, sendo "UF" a sigla da unidade da '     ...
                                         'federação e XX dois dígitos numéricos (01 a 99). Além disso, são previstas inclusões '       ...
                                         'de nomes de estações iniciando com <b>"UMS</b>" ou <b>"EMSat"</b>.<br><br>O nome inserido, ' ...
                                         'contudo, difere dessas opções. Deseja continuar?'];
                        userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 2, 2);
                            if strcmp(userSelection, 'Não')
                                app.general_stationName.Value = event.PreviousValue;
                                return
                            end
                    end

                    app.mainApp.General.stationInfo.Name      = app.general_stationName.Value;

                case app.general_stationType
                    app.mainApp.General.stationInfo.Type      = app.general_stationType.Value;

                case app.general_stationLatitude
                    app.mainApp.General.stationInfo.Latitude  = app.general_stationLatitude.Value;

                case app.general_stationLongitude
                    app.mainApp.General.stationInfo.Longitude = app.general_stationLongitude.Value;

                case app.general_lastSessionInfo
                    app.mainApp.General.startupInfo           = app.general_lastSessionInfo.Value;                    

                case app.server_Status
                    switch app.server_Status.Value
                        case 'ON';  app.mainApp.General.tcpServer.Status = 1;
                        case 'OFF'; app.mainApp.General.tcpServer.Status = 0;
                    end

                case app.server_Key
                    app.server_Key.Value = replace(app.server_Key.Value, ' ', '');
                    app.mainApp.General.tcpServer.Key = app.server_Key.Value;

                case app.server_ClientList
                    app.server_ClientList.Value = replace(app.server_ClientList.Value, ' ', '');
                    
                    if isempty(app.server_ClientList.Value)
                        app.mainApp.General.tcpServer.ClientList = {};
                    else
                        app.mainApp.General.tcpServer.ClientList = strsplit(app.server_ClientList.Value, ',');
                    end

                    app.server_ClientList.Value = strjoin(app.mainApp.General.tcpServer.ClientList, ', ');

                case app.server_IP
                    app.server_IP.Value = strtrim(app.server_IP.Value);

                    if IPv4Validation(app, app.server_IP.Value) || isempty(app.server_IP.Value)
                        app.mainApp.General.tcpServer.IP = app.server_IP.Value;
                    else
                        app.server_IP.Value = event.PreviousValue;
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Endereço inválido (IPv4).');
                    end

                case app.server_Port
                    app.mainApp.General.tcpServer.Port = app.server_Port.Value;
            end
            
            app.mainApp.General_I.stationInfo   = app.mainApp.General.stationInfo;
            app.mainApp.General_I.startupInfo   = app.mainApp.General.startupInfo;
            app.mainApp.General_I.tcpServer     = app.mainApp.General.tcpServer;

            saveGeneralSettings(app)
            general_updateLayout(app)

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app, Container)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            if isempty(Container)
                app.UIFigure = uifigure('Visible', 'off');
                app.UIFigure.AutoResizeChildren = 'off';
                app.UIFigure.Position = [100 100 1244 660];
                app.UIFigure.Name = 'appColeta';
                app.UIFigure.Icon = 'icon_48.png';
                app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @closeFcn, true);

                app.Container = app.UIFigure;

            else
                if ~isempty(Container.Children)
                    delete(Container.Children)
                end

                app.UIFigure  = ancestor(Container, 'figure');
                app.Container = Container;
                if ~isprop(Container, 'RunningAppInstance')
                    addprop(app.Container, 'RunningAppInstance');
                end
                app.Container.RunningAppInstance = app;
                app.isDocked  = true;
            end

            % Create GridLayout
            app.GridLayout = uigridlayout(app.Container);
            app.GridLayout.ColumnWidth = {10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, '1x', 22, 22};
            app.Toolbar.RowHeight = {4, 17, '1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 5 10 5];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create tool_simulationMode
            app.tool_simulationMode = uiimage(app.Toolbar);
            app.tool_simulationMode.ScaleMethod = 'none';
            app.tool_simulationMode.ImageClickedFcn = createCallbackFcn(app, @Toolbar_SimulationModeButtonPushed, true);
            app.tool_simulationMode.Tooltip = {'Leitura arquivos de simulação'};
            app.tool_simulationMode.Layout.Row = 2;
            app.tool_simulationMode.Layout.Column = 1;
            app.tool_simulationMode.ImageSource = 'Import_16.png';

            % Create tool_openDevTools
            app.tool_openDevTools = uiimage(app.Toolbar);
            app.tool_openDevTools.ScaleMethod = 'none';
            app.tool_openDevTools.ImageClickedFcn = createCallbackFcn(app, @Toolbar_OpenDevToolsClicked, true);
            app.tool_openDevTools.Enable = 'off';
            app.tool_openDevTools.Tooltip = {'Abre DevTools'};
            app.tool_openDevTools.Layout.Row = 2;
            app.tool_openDevTools.Layout.Column = 4;
            app.tool_openDevTools.ImageSource = 'Debug_18.png';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.SelectionChangedFcn = createCallbackFcn(app, @TabGroup_TabSelectionChanged, true);
            app.TabGroup.Layout.Row = [3 4];
            app.TabGroup.Layout.Column = [2 3];

            % Create Tab1
            app.Tab1 = uitab(app.TabGroup);
            app.Tab1.AutoResizeChildren = 'off';
            app.Tab1.Title = 'ASPECTOS GERAIS';
            app.Tab1.BackgroundColor = 'none';

            % Create Tab1Grid
            app.Tab1Grid = uigridlayout(app.Tab1);
            app.Tab1Grid.ColumnWidth = {'1x', 22};
            app.Tab1Grid.RowHeight = {17, '1x', 1, 22, 15};
            app.Tab1Grid.ColumnSpacing = 5;
            app.Tab1Grid.RowSpacing = 5;
            app.Tab1Grid.BackgroundColor = [1 1 1];

            % Create versionInfoLabel
            app.versionInfoLabel = uilabel(app.Tab1Grid);
            app.versionInfoLabel.VerticalAlignment = 'bottom';
            app.versionInfoLabel.FontSize = 10;
            app.versionInfoLabel.Layout.Row = 1;
            app.versionInfoLabel.Layout.Column = 1;
            app.versionInfoLabel.Text = 'AMBIENTE:';

            % Create versionInfo
            app.versionInfo = uilabel(app.Tab1Grid);
            app.versionInfo.BackgroundColor = [1 1 1];
            app.versionInfo.VerticalAlignment = 'top';
            app.versionInfo.WordWrap = 'on';
            app.versionInfo.FontSize = 11;
            app.versionInfo.Layout.Row = 2;
            app.versionInfo.Layout.Column = [1 2];
            app.versionInfo.Interpreter = 'html';
            app.versionInfo.Text = '';

            % Create tool_versionInfoRefresh
            app.tool_versionInfoRefresh = uiimage(app.Tab1Grid);
            app.tool_versionInfoRefresh.ScaleMethod = 'none';
            app.tool_versionInfoRefresh.ImageClickedFcn = createCallbackFcn(app, @Toolbar_AppEnvRefreshButtonPushed, true);
            app.tool_versionInfoRefresh.Enable = 'off';
            app.tool_versionInfoRefresh.Tooltip = {'Verifica atualizações'};
            app.tool_versionInfoRefresh.Layout.Row = 1;
            app.tool_versionInfoRefresh.Layout.Column = 2;
            app.tool_versionInfoRefresh.VerticalAlignment = 'bottom';
            app.tool_versionInfoRefresh.ImageSource = 'Refresh_18.png';

            % Create openAuxiliarAppAsDocked
            app.openAuxiliarAppAsDocked = uicheckbox(app.Tab1Grid);
            app.openAuxiliarAppAsDocked.ValueChangedFcn = createCallbackFcn(app, @Config_GeneralParameterValueChanged, true);
            app.openAuxiliarAppAsDocked.Enable = 'off';
            app.openAuxiliarAppAsDocked.Text = 'Modo DOCK: módulos auxiliares abertos na janela principal do app';
            app.openAuxiliarAppAsDocked.FontSize = 11;
            app.openAuxiliarAppAsDocked.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.openAuxiliarAppAsDocked.Layout.Row = 4;
            app.openAuxiliarAppAsDocked.Layout.Column = 1;

            % Create openAuxiliarApp2Debug
            app.openAuxiliarApp2Debug = uicheckbox(app.Tab1Grid);
            app.openAuxiliarApp2Debug.ValueChangedFcn = createCallbackFcn(app, @Config_GeneralParameterValueChanged, true);
            app.openAuxiliarApp2Debug.Enable = 'off';
            app.openAuxiliarApp2Debug.Text = 'Modo DEBUG';
            app.openAuxiliarApp2Debug.FontSize = 11;
            app.openAuxiliarApp2Debug.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.openAuxiliarApp2Debug.Layout.Row = 5;
            app.openAuxiliarApp2Debug.Layout.Column = 1;

            % Create Tab2
            app.Tab2 = uitab(app.TabGroup);
            app.Tab2.AutoResizeChildren = 'off';
            app.Tab2.Title = 'ERMx';
            app.Tab2.BackgroundColor = 'none';

            % Create general_Grid
            app.general_Grid = uigridlayout(app.Tab2);
            app.general_Grid.ColumnWidth = {'1x', 16};
            app.general_Grid.RowHeight = {17, 136, 22, '1x'};
            app.general_Grid.RowSpacing = 5;
            app.general_Grid.BackgroundColor = [1 1 1];

            % Create general_FileLabel
            app.general_FileLabel = uilabel(app.general_Grid);
            app.general_FileLabel.VerticalAlignment = 'bottom';
            app.general_FileLabel.FontSize = 10;
            app.general_FileLabel.Layout.Row = 1;
            app.general_FileLabel.Layout.Column = 1;
            app.general_FileLabel.Text = 'ESTAÇÃO';

            % Create general_FileLock
            app.general_FileLock = uiimage(app.general_Grid);
            app.general_FileLock.Layout.Row = 1;
            app.general_FileLock.Layout.Column = 2;
            app.general_FileLock.VerticalAlignment = 'bottom';
            app.general_FileLock.ImageSource = 'lockClose_32.png';

            % Create general_FilePanel
            app.general_FilePanel = uipanel(app.general_Grid);
            app.general_FilePanel.AutoResizeChildren = 'off';
            app.general_FilePanel.Layout.Row = 2;
            app.general_FilePanel.Layout.Column = [1 2];

            % Create general_stationGrid
            app.general_stationGrid = uigridlayout(app.general_FilePanel);
            app.general_stationGrid.ColumnWidth = {150, 150, '1x'};
            app.general_stationGrid.RowHeight = {17, 22, 25, 22, 17};
            app.general_stationGrid.RowSpacing = 5;
            app.general_stationGrid.Padding = [10 9 10 4];
            app.general_stationGrid.BackgroundColor = [1 1 1];

            % Create general_stationNameLabel
            app.general_stationNameLabel = uilabel(app.general_stationGrid);
            app.general_stationNameLabel.VerticalAlignment = 'bottom';
            app.general_stationNameLabel.FontSize = 10;
            app.general_stationNameLabel.Layout.Row = 1;
            app.general_stationNameLabel.Layout.Column = 1;
            app.general_stationNameLabel.Text = 'Nome:';

            % Create general_stationName
            app.general_stationName = uieditfield(app.general_stationGrid, 'text');
            app.general_stationName.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.general_stationName.FontSize = 11;
            app.general_stationName.Enable = 'off';
            app.general_stationName.Layout.Row = 2;
            app.general_stationName.Layout.Column = 1;

            % Create general_stationTypeLabel
            app.general_stationTypeLabel = uilabel(app.general_stationGrid);
            app.general_stationTypeLabel.VerticalAlignment = 'bottom';
            app.general_stationTypeLabel.FontSize = 10;
            app.general_stationTypeLabel.Layout.Row = 1;
            app.general_stationTypeLabel.Layout.Column = 2;
            app.general_stationTypeLabel.Text = 'Tipo:';

            % Create general_stationType
            app.general_stationType = uidropdown(app.general_stationGrid);
            app.general_stationType.Items = {'Fixed', 'Mobile'};
            app.general_stationType.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.general_stationType.Enable = 'off';
            app.general_stationType.FontSize = 11;
            app.general_stationType.BackgroundColor = [1 1 1];
            app.general_stationType.Layout.Row = 2;
            app.general_stationType.Layout.Column = 2;
            app.general_stationType.Value = 'Fixed';

            % Create general_stationLatitudeLabel
            app.general_stationLatitudeLabel = uilabel(app.general_stationGrid);
            app.general_stationLatitudeLabel.VerticalAlignment = 'bottom';
            app.general_stationLatitudeLabel.FontSize = 10;
            app.general_stationLatitudeLabel.Layout.Row = 3;
            app.general_stationLatitudeLabel.Layout.Column = 1;
            app.general_stationLatitudeLabel.Text = {'Latitude:'; '(graus decimais)'};

            % Create general_stationLatitude
            app.general_stationLatitude = uieditfield(app.general_stationGrid, 'numeric');
            app.general_stationLatitude.ValueDisplayFormat = '%.6f';
            app.general_stationLatitude.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.general_stationLatitude.Tag = 'task_Editable';
            app.general_stationLatitude.FontSize = 11;
            app.general_stationLatitude.Enable = 'off';
            app.general_stationLatitude.Layout.Row = 4;
            app.general_stationLatitude.Layout.Column = 1;
            app.general_stationLatitude.Value = -1;

            % Create general_stationLongitudeLabel
            app.general_stationLongitudeLabel = uilabel(app.general_stationGrid);
            app.general_stationLongitudeLabel.VerticalAlignment = 'bottom';
            app.general_stationLongitudeLabel.FontSize = 10;
            app.general_stationLongitudeLabel.Layout.Row = 3;
            app.general_stationLongitudeLabel.Layout.Column = 2;
            app.general_stationLongitudeLabel.Text = {'Longitude:'; '(graus decimais)'};

            % Create general_stationLongitude
            app.general_stationLongitude = uieditfield(app.general_stationGrid, 'numeric');
            app.general_stationLongitude.ValueDisplayFormat = '%.6f';
            app.general_stationLongitude.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.general_stationLongitude.Tag = 'task_Editable';
            app.general_stationLongitude.FontSize = 11;
            app.general_stationLongitude.Enable = 'off';
            app.general_stationLongitude.Layout.Row = 4;
            app.general_stationLongitude.Layout.Column = 2;
            app.general_stationLongitude.Value = -1;

            % Create general_lastSessionInfo
            app.general_lastSessionInfo = uicheckbox(app.general_stationGrid);
            app.general_lastSessionInfo.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.general_lastSessionInfo.Enable = 'off';
            app.general_lastSessionInfo.Text = 'Leitura dados armazenados na última sessão.';
            app.general_lastSessionInfo.FontSize = 10;
            app.general_lastSessionInfo.Layout.Row = 5;
            app.general_lastSessionInfo.Layout.Column = [1 3];

            % Create general_versionLabel
            app.general_versionLabel = uilabel(app.general_Grid);
            app.general_versionLabel.VerticalAlignment = 'bottom';
            app.general_versionLabel.FontSize = 10;
            app.general_versionLabel.Layout.Row = 3;
            app.general_versionLabel.Layout.Column = 1;
            app.general_versionLabel.Text = 'WEBSERVICE';

            % Create general_versionLock
            app.general_versionLock = uiimage(app.general_Grid);
            app.general_versionLock.Layout.Row = 3;
            app.general_versionLock.Layout.Column = 2;
            app.general_versionLock.VerticalAlignment = 'bottom';
            app.general_versionLock.ImageSource = 'lockClose_32.png';

            % Create general_versionPanel
            app.general_versionPanel = uipanel(app.general_Grid);
            app.general_versionPanel.AutoResizeChildren = 'off';
            app.general_versionPanel.Layout.Row = 4;
            app.general_versionPanel.Layout.Column = [1 2];

            % Create server_Grid
            app.server_Grid = uigridlayout(app.general_versionPanel);
            app.server_Grid.ColumnWidth = {150, 150};
            app.server_Grid.RowHeight = {17, 22, 25, 22, 17, 22};
            app.server_Grid.RowSpacing = 5;
            app.server_Grid.Padding = [10 8 10 4];
            app.server_Grid.BackgroundColor = [1 1 1];

            % Create server_StatusLabel
            app.server_StatusLabel = uilabel(app.server_Grid);
            app.server_StatusLabel.VerticalAlignment = 'bottom';
            app.server_StatusLabel.FontSize = 10;
            app.server_StatusLabel.Layout.Row = 1;
            app.server_StatusLabel.Layout.Column = 1;
            app.server_StatusLabel.Text = 'Estado:';

            % Create server_Status
            app.server_Status = uidropdown(app.server_Grid);
            app.server_Status.Items = {'ON', 'OFF'};
            app.server_Status.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.server_Status.Enable = 'off';
            app.server_Status.FontSize = 11;
            app.server_Status.BackgroundColor = [0.9412 0.9412 0.9412];
            app.server_Status.Layout.Row = 2;
            app.server_Status.Layout.Column = 1;
            app.server_Status.Value = 'ON';

            % Create server_KeyLabel
            app.server_KeyLabel = uilabel(app.server_Grid);
            app.server_KeyLabel.VerticalAlignment = 'bottom';
            app.server_KeyLabel.FontSize = 10;
            app.server_KeyLabel.Layout.Row = 1;
            app.server_KeyLabel.Layout.Column = 2;
            app.server_KeyLabel.Text = 'Chave:';

            % Create server_Key
            app.server_Key = uieditfield(app.server_Grid, 'text');
            app.server_Key.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.server_Key.FontSize = 11;
            app.server_Key.Enable = 'off';
            app.server_Key.Layout.Row = 2;
            app.server_Key.Layout.Column = 2;

            % Create server_ClientListLabel
            app.server_ClientListLabel = uilabel(app.server_Grid);
            app.server_ClientListLabel.VerticalAlignment = 'bottom';
            app.server_ClientListLabel.FontSize = 10;
            app.server_ClientListLabel.Layout.Row = 3;
            app.server_ClientListLabel.Layout.Column = [1 2];
            app.server_ClientListLabel.Text = {'Lista de clientes:'; '(valores separados por vírgula)'};

            % Create server_ClientList
            app.server_ClientList = uieditfield(app.server_Grid, 'text');
            app.server_ClientList.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.server_ClientList.FontSize = 11;
            app.server_ClientList.Enable = 'off';
            app.server_ClientList.Layout.Row = 4;
            app.server_ClientList.Layout.Column = [1 2];

            % Create server_IPLabel
            app.server_IPLabel = uilabel(app.server_Grid);
            app.server_IPLabel.VerticalAlignment = 'bottom';
            app.server_IPLabel.FontSize = 10;
            app.server_IPLabel.Layout.Row = 5;
            app.server_IPLabel.Layout.Column = 1;
            app.server_IPLabel.Text = 'Endereço IP (OpenVPN):';

            % Create server_IP
            app.server_IP = uieditfield(app.server_Grid, 'text');
            app.server_IP.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.server_IP.FontSize = 11;
            app.server_IP.Enable = 'off';
            app.server_IP.Layout.Row = 6;
            app.server_IP.Layout.Column = 1;

            % Create server_PortLabel
            app.server_PortLabel = uilabel(app.server_Grid);
            app.server_PortLabel.VerticalAlignment = 'bottom';
            app.server_PortLabel.FontSize = 10;
            app.server_PortLabel.Layout.Row = 5;
            app.server_PortLabel.Layout.Column = 2;
            app.server_PortLabel.Text = 'Porta:';

            % Create server_Port
            app.server_Port = uieditfield(app.server_Grid, 'numeric');
            app.server_Port.Limits = [1 65535];
            app.server_Port.RoundFractionalValues = 'on';
            app.server_Port.ValueDisplayFormat = '%d';
            app.server_Port.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.server_Port.FontSize = 11;
            app.server_Port.Enable = 'off';
            app.server_Port.Layout.Row = 6;
            app.server_Port.Layout.Column = 2;
            app.server_Port.Value = 1;

            % Create Tab3
            app.Tab3 = uitab(app.TabGroup);
            app.Tab3.AutoResizeChildren = 'off';
            app.Tab3.Title = 'PLOT';

            % Create plot_Grid
            app.plot_Grid = uigridlayout(app.Tab3);
            app.plot_Grid.ColumnWidth = {150, '1x', 16};
            app.plot_Grid.RowHeight = {17, 38, 22, 22, 22, 62, 22, 63, 22, '1x'};
            app.plot_Grid.RowSpacing = 5;
            app.plot_Grid.BackgroundColor = [1 1 1];

            % Create plot_InteractionsLabel
            app.plot_InteractionsLabel = uilabel(app.plot_Grid);
            app.plot_InteractionsLabel.VerticalAlignment = 'bottom';
            app.plot_InteractionsLabel.FontSize = 10;
            app.plot_InteractionsLabel.Layout.Row = 1;
            app.plot_InteractionsLabel.Layout.Column = 1;
            app.plot_InteractionsLabel.Text = 'INTERAÇÕES:';

            % Create configPlotRefresh
            app.configPlotRefresh = uiimage(app.plot_Grid);
            app.configPlotRefresh.ScaleMethod = 'none';
            app.configPlotRefresh.Layout.Row = 1;
            app.configPlotRefresh.Layout.Column = 3;
            app.configPlotRefresh.HorizontalAlignment = 'left';
            app.configPlotRefresh.VerticalAlignment = 'bottom';
            app.configPlotRefresh.ImageSource = 'Refresh_18.png';

            % Create plot_InteractionsPanel
            app.plot_InteractionsPanel = uipanel(app.plot_Grid);
            app.plot_InteractionsPanel.AutoResizeChildren = 'off';
            app.plot_InteractionsPanel.BackgroundColor = [1 1 1];
            app.plot_InteractionsPanel.Layout.Row = 2;
            app.plot_InteractionsPanel.Layout.Column = [1 3];

            % Create plot_InteractionsGrid
            app.plot_InteractionsGrid = uigridlayout(app.plot_InteractionsPanel);
            app.plot_InteractionsGrid.ColumnWidth = {16, 16, 16, 16, 16, '1x'};
            app.plot_InteractionsGrid.RowHeight = {'1x', 3};
            app.plot_InteractionsGrid.RowSpacing = 0;
            app.plot_InteractionsGrid.Padding = [5 5 10 2];
            app.plot_InteractionsGrid.BackgroundColor = [1 1 1];

            % Create plot_Datatip
            app.plot_Datatip = uiimage(app.plot_InteractionsGrid);
            app.plot_Datatip.Tooltip = {'Datatip'};
            app.plot_Datatip.Layout.Row = 1;
            app.plot_Datatip.Layout.Column = 1;
            app.plot_Datatip.ImageSource = 'AxesToolbar_Datatip.png';

            % Create plot_DatatipVisibility
            app.plot_DatatipVisibility = uiimage(app.plot_InteractionsGrid);
            app.plot_DatatipVisibility.ScaleMethod = 'fill';
            app.plot_DatatipVisibility.Tag = 'InteractionVisibility';
            app.plot_DatatipVisibility.Tooltip = {'Datatip'};
            app.plot_DatatipVisibility.Layout.Row = 2;
            app.plot_DatatipVisibility.Layout.Column = 1;
            app.plot_DatatipVisibility.ImageSource = 'LineH.png';

            % Create plot_Pan
            app.plot_Pan = uiimage(app.plot_InteractionsGrid);
            app.plot_Pan.Tooltip = {'Pan'};
            app.plot_Pan.Layout.Row = 1;
            app.plot_Pan.Layout.Column = 2;
            app.plot_Pan.ImageSource = 'AxesToolbar_Pan.png';

            % Create plot_PanVisibility
            app.plot_PanVisibility = uiimage(app.plot_InteractionsGrid);
            app.plot_PanVisibility.ScaleMethod = 'fill';
            app.plot_PanVisibility.Tag = 'InteractionVisibility';
            app.plot_PanVisibility.Tooltip = {'Datatip'};
            app.plot_PanVisibility.Layout.Row = 2;
            app.plot_PanVisibility.Layout.Column = 2;
            app.plot_PanVisibility.ImageSource = 'LineH.png';

            % Create plot_ZoomIn
            app.plot_ZoomIn = uiimage(app.plot_InteractionsGrid);
            app.plot_ZoomIn.Tooltip = {'Zoom in'};
            app.plot_ZoomIn.Layout.Row = 1;
            app.plot_ZoomIn.Layout.Column = 3;
            app.plot_ZoomIn.ImageSource = 'AxesToolbar_ZoomIn.png';

            % Create plot_ZoomInVisibility
            app.plot_ZoomInVisibility = uiimage(app.plot_InteractionsGrid);
            app.plot_ZoomInVisibility.ScaleMethod = 'fill';
            app.plot_ZoomInVisibility.Tag = 'InteractionVisibility';
            app.plot_ZoomInVisibility.Tooltip = {'Datatip'};
            app.plot_ZoomInVisibility.Layout.Row = 2;
            app.plot_ZoomInVisibility.Layout.Column = 3;
            app.plot_ZoomInVisibility.ImageSource = 'LineH.png';

            % Create plot_ZoomOut
            app.plot_ZoomOut = uiimage(app.plot_InteractionsGrid);
            app.plot_ZoomOut.Tooltip = {'Zoom out'};
            app.plot_ZoomOut.Layout.Row = 1;
            app.plot_ZoomOut.Layout.Column = 4;
            app.plot_ZoomOut.ImageSource = 'AxesToolbar_ZoomOut.png';

            % Create plot_ZoomOutVisibility
            app.plot_ZoomOutVisibility = uiimage(app.plot_InteractionsGrid);
            app.plot_ZoomOutVisibility.ScaleMethod = 'fill';
            app.plot_ZoomOutVisibility.Tag = 'InteractionVisibility';
            app.plot_ZoomOutVisibility.Tooltip = {'Datatip'};
            app.plot_ZoomOutVisibility.Layout.Row = 2;
            app.plot_ZoomOutVisibility.Layout.Column = 4;
            app.plot_ZoomOutVisibility.ImageSource = 'LineH.png';

            % Create plot_RestoreView
            app.plot_RestoreView = uiimage(app.plot_InteractionsGrid);
            app.plot_RestoreView.Tooltip = {'Restore view'};
            app.plot_RestoreView.Layout.Row = 1;
            app.plot_RestoreView.Layout.Column = 5;
            app.plot_RestoreView.ImageSource = 'AxesToolbar_RestoreView.png';

            % Create plot_RestoreViewVisibility
            app.plot_RestoreViewVisibility = uiimage(app.plot_InteractionsGrid);
            app.plot_RestoreViewVisibility.ScaleMethod = 'fill';
            app.plot_RestoreViewVisibility.Tag = 'InteractionVisibility';
            app.plot_RestoreViewVisibility.Tooltip = {'Datatip'};
            app.plot_RestoreViewVisibility.Layout.Row = 2;
            app.plot_RestoreViewVisibility.Layout.Column = 5;
            app.plot_RestoreViewVisibility.ImageSource = 'LineH.png';

            % Create plot_TiledSpacingLabel
            app.plot_TiledSpacingLabel = uilabel(app.plot_Grid);
            app.plot_TiledSpacingLabel.VerticalAlignment = 'bottom';
            app.plot_TiledSpacingLabel.FontSize = 10;
            app.plot_TiledSpacingLabel.Layout.Row = 3;
            app.plot_TiledSpacingLabel.Layout.Column = [1 3];
            app.plot_TiledSpacingLabel.Text = 'ESPAÇAMENTO ENTRE EIXOS:';

            % Create plot_TiledSpacing
            app.plot_TiledSpacing = uidropdown(app.plot_Grid);
            app.plot_TiledSpacing.Items = {'loose', 'compact', 'tight', 'none'};
            app.plot_TiledSpacing.FontSize = 11;
            app.plot_TiledSpacing.BackgroundColor = [1 1 1];
            app.plot_TiledSpacing.Layout.Row = 4;
            app.plot_TiledSpacing.Layout.Column = 1;
            app.plot_TiledSpacing.Value = 'loose';

            % Create plot_colorsLabel
            app.plot_colorsLabel = uilabel(app.plot_Grid);
            app.plot_colorsLabel.VerticalAlignment = 'bottom';
            app.plot_colorsLabel.FontSize = 10;
            app.plot_colorsLabel.Layout.Row = 5;
            app.plot_colorsLabel.Layout.Column = 1;
            app.plot_colorsLabel.Text = 'CORES:';

            % Create plot_colorsPanel
            app.plot_colorsPanel = uipanel(app.plot_Grid);
            app.plot_colorsPanel.AutoResizeChildren = 'off';
            app.plot_colorsPanel.Layout.Row = 6;
            app.plot_colorsPanel.Layout.Column = [1 3];

            % Create plot_colorsGrid
            app.plot_colorsGrid = uigridlayout(app.plot_colorsPanel);
            app.plot_colorsGrid.ColumnWidth = {150, 150, 150, 150};
            app.plot_colorsGrid.RowHeight = {17, 22};
            app.plot_colorsGrid.ColumnSpacing = 20;
            app.plot_colorsGrid.RowSpacing = 5;
            app.plot_colorsGrid.Padding = [10 10 10 5];
            app.plot_colorsGrid.BackgroundColor = [1 1 1];

            % Create plot_colorsMinHoldLabel
            app.plot_colorsMinHoldLabel = uilabel(app.plot_colorsGrid);
            app.plot_colorsMinHoldLabel.VerticalAlignment = 'bottom';
            app.plot_colorsMinHoldLabel.FontSize = 10;
            app.plot_colorsMinHoldLabel.Layout.Row = 1;
            app.plot_colorsMinHoldLabel.Layout.Column = 1;
            app.plot_colorsMinHoldLabel.Text = 'MinHold:';

            % Create plot_colorsMinHold
            app.plot_colorsMinHold = uicolorpicker(app.plot_colorsGrid);
            app.plot_colorsMinHold.Layout.Row = 2;
            app.plot_colorsMinHold.Layout.Column = 1;

            % Create plot_colorsAverageLabel
            app.plot_colorsAverageLabel = uilabel(app.plot_colorsGrid);
            app.plot_colorsAverageLabel.VerticalAlignment = 'bottom';
            app.plot_colorsAverageLabel.FontSize = 10;
            app.plot_colorsAverageLabel.Layout.Row = 1;
            app.plot_colorsAverageLabel.Layout.Column = 2;
            app.plot_colorsAverageLabel.Text = 'Average:';

            % Create plot_colorsAverage
            app.plot_colorsAverage = uicolorpicker(app.plot_colorsGrid);
            app.plot_colorsAverage.Layout.Row = 2;
            app.plot_colorsAverage.Layout.Column = 2;

            % Create plot_colorsMaxHoldLabel
            app.plot_colorsMaxHoldLabel = uilabel(app.plot_colorsGrid);
            app.plot_colorsMaxHoldLabel.VerticalAlignment = 'bottom';
            app.plot_colorsMaxHoldLabel.FontSize = 10;
            app.plot_colorsMaxHoldLabel.Layout.Row = 1;
            app.plot_colorsMaxHoldLabel.Layout.Column = 3;
            app.plot_colorsMaxHoldLabel.Text = 'MaxHold:';

            % Create plot_colorsMaxHold
            app.plot_colorsMaxHold = uicolorpicker(app.plot_colorsGrid);
            app.plot_colorsMaxHold.Layout.Row = 2;
            app.plot_colorsMaxHold.Layout.Column = 3;

            % Create plot_colorsClearWriteLabel
            app.plot_colorsClearWriteLabel = uilabel(app.plot_colorsGrid);
            app.plot_colorsClearWriteLabel.VerticalAlignment = 'bottom';
            app.plot_colorsClearWriteLabel.FontSize = 10;
            app.plot_colorsClearWriteLabel.Layout.Row = 1;
            app.plot_colorsClearWriteLabel.Layout.Column = 4;
            app.plot_colorsClearWriteLabel.Text = 'ClearWrite:';

            % Create plot_colorsClearWrite
            app.plot_colorsClearWrite = uicolorpicker(app.plot_colorsGrid);
            app.plot_colorsClearWrite.Layout.Row = 2;
            app.plot_colorsClearWrite.Layout.Column = 4;

            % Create plot_WaterfallLabel
            app.plot_WaterfallLabel = uilabel(app.plot_Grid);
            app.plot_WaterfallLabel.VerticalAlignment = 'bottom';
            app.plot_WaterfallLabel.FontSize = 10;
            app.plot_WaterfallLabel.Layout.Row = 7;
            app.plot_WaterfallLabel.Layout.Column = 1;
            app.plot_WaterfallLabel.Text = 'WATERFALL:';

            % Create plot_WaterfallPanel
            app.plot_WaterfallPanel = uipanel(app.plot_Grid);
            app.plot_WaterfallPanel.AutoResizeChildren = 'off';
            app.plot_WaterfallPanel.BackgroundColor = [1 1 1];
            app.plot_WaterfallPanel.Layout.Row = 8;
            app.plot_WaterfallPanel.Layout.Column = [1 3];

            % Create plot_WaterfallGrid
            app.plot_WaterfallGrid = uigridlayout(app.plot_WaterfallPanel);
            app.plot_WaterfallGrid.ColumnWidth = {150, 150};
            app.plot_WaterfallGrid.RowHeight = {17, 22};
            app.plot_WaterfallGrid.ColumnSpacing = 20;
            app.plot_WaterfallGrid.RowSpacing = 5;
            app.plot_WaterfallGrid.Padding = [10 10 10 5];
            app.plot_WaterfallGrid.BackgroundColor = [1 1 1];

            % Create plot_WaterfallColormapLabel
            app.plot_WaterfallColormapLabel = uilabel(app.plot_WaterfallGrid);
            app.plot_WaterfallColormapLabel.VerticalAlignment = 'bottom';
            app.plot_WaterfallColormapLabel.FontSize = 10;
            app.plot_WaterfallColormapLabel.Layout.Row = 1;
            app.plot_WaterfallColormapLabel.Layout.Column = 1;
            app.plot_WaterfallColormapLabel.Text = 'Mapa de cor:';

            % Create plot_WaterfallColormap
            app.plot_WaterfallColormap = uidropdown(app.plot_WaterfallGrid);
            app.plot_WaterfallColormap.Items = {'gray', 'hot', 'jet', 'summer', 'turbo', 'winter'};
            app.plot_WaterfallColormap.FontSize = 11;
            app.plot_WaterfallColormap.BackgroundColor = [1 1 1];
            app.plot_WaterfallColormap.Layout.Row = 2;
            app.plot_WaterfallColormap.Layout.Column = 1;
            app.plot_WaterfallColormap.Value = 'gray';

            % Create plot_WaterfallDepthLabel
            app.plot_WaterfallDepthLabel = uilabel(app.plot_WaterfallGrid);
            app.plot_WaterfallDepthLabel.VerticalAlignment = 'bottom';
            app.plot_WaterfallDepthLabel.FontSize = 10;
            app.plot_WaterfallDepthLabel.Layout.Row = 1;
            app.plot_WaterfallDepthLabel.Layout.Column = 2;
            app.plot_WaterfallDepthLabel.Text = 'Profundidade:';

            % Create plot_WaterfallDepth
            app.plot_WaterfallDepth = uidropdown(app.plot_WaterfallGrid);
            app.plot_WaterfallDepth.Items = {'64', '128', '256', '512'};
            app.plot_WaterfallDepth.FontSize = 11;
            app.plot_WaterfallDepth.BackgroundColor = [1 1 1];
            app.plot_WaterfallDepth.Layout.Row = 2;
            app.plot_WaterfallDepth.Layout.Column = 2;
            app.plot_WaterfallDepth.Value = '64';

            % Create plot_IntegrationLabel
            app.plot_IntegrationLabel = uilabel(app.plot_Grid);
            app.plot_IntegrationLabel.VerticalAlignment = 'bottom';
            app.plot_IntegrationLabel.FontSize = 10;
            app.plot_IntegrationLabel.Layout.Row = 9;
            app.plot_IntegrationLabel.Layout.Column = 1;
            app.plot_IntegrationLabel.Text = 'INTEGRAÇÃO:';

            % Create plot_IntegrationPanel
            app.plot_IntegrationPanel = uipanel(app.plot_Grid);
            app.plot_IntegrationPanel.AutoResizeChildren = 'off';
            app.plot_IntegrationPanel.BackgroundColor = [1 1 1];
            app.plot_IntegrationPanel.Layout.Row = 10;
            app.plot_IntegrationPanel.Layout.Column = [1 3];

            % Create plot_IntegrationGrid
            app.plot_IntegrationGrid = uigridlayout(app.plot_IntegrationPanel);
            app.plot_IntegrationGrid.ColumnWidth = {150, 150};
            app.plot_IntegrationGrid.RowHeight = {17, 22};
            app.plot_IntegrationGrid.ColumnSpacing = 20;
            app.plot_IntegrationGrid.RowSpacing = 5;
            app.plot_IntegrationGrid.Padding = [10 10 10 5];
            app.plot_IntegrationGrid.BackgroundColor = [1 1 1];

            % Create plot_IntegrationTraceLabel
            app.plot_IntegrationTraceLabel = uilabel(app.plot_IntegrationGrid);
            app.plot_IntegrationTraceLabel.VerticalAlignment = 'bottom';
            app.plot_IntegrationTraceLabel.FontSize = 10;
            app.plot_IntegrationTraceLabel.Layout.Row = 1;
            app.plot_IntegrationTraceLabel.Layout.Column = 1;
            app.plot_IntegrationTraceLabel.Text = 'Traço médio:';

            % Create plot_IntegrationTrace
            app.plot_IntegrationTrace = uieditfield(app.plot_IntegrationGrid, 'numeric');
            app.plot_IntegrationTrace.Limits = [3 100];
            app.plot_IntegrationTrace.RoundFractionalValues = 'on';
            app.plot_IntegrationTrace.ValueDisplayFormat = '%d';
            app.plot_IntegrationTrace.FontSize = 11;
            app.plot_IntegrationTrace.Layout.Row = 2;
            app.plot_IntegrationTrace.Layout.Column = 1;
            app.plot_IntegrationTrace.Value = 10;

            % Create plot_IntegrationTimeLabel
            app.plot_IntegrationTimeLabel = uilabel(app.plot_IntegrationGrid);
            app.plot_IntegrationTimeLabel.VerticalAlignment = 'bottom';
            app.plot_IntegrationTimeLabel.FontSize = 10;
            app.plot_IntegrationTimeLabel.Layout.Row = 1;
            app.plot_IntegrationTimeLabel.Layout.Column = 2;
            app.plot_IntegrationTimeLabel.Text = 'Tempo médio escrita:';

            % Create plot_IntegrationTime
            app.plot_IntegrationTime = uieditfield(app.plot_IntegrationGrid, 'numeric');
            app.plot_IntegrationTime.Limits = [3 100];
            app.plot_IntegrationTime.RoundFractionalValues = 'on';
            app.plot_IntegrationTime.ValueDisplayFormat = '%d';
            app.plot_IntegrationTime.FontSize = 11;
            app.plot_IntegrationTime.Layout.Row = 2;
            app.plot_IntegrationTime.Layout.Column = 2;
            app.plot_IntegrationTime.Value = 10;

            % Create Tab5
            app.Tab5 = uitab(app.TabGroup);
            app.Tab5.AutoResizeChildren = 'off';
            app.Tab5.Title = 'MAPEAMENTO DE PASTAS';
            app.Tab5.BackgroundColor = 'none';

            % Create Tab5Grid
            app.Tab5Grid = uigridlayout(app.Tab5);
            app.Tab5Grid.ColumnWidth = {'1x', 20};
            app.Tab5Grid.RowHeight = {17, 22, 22, 22, '1x'};
            app.Tab5Grid.ColumnSpacing = 5;
            app.Tab5Grid.RowSpacing = 5;
            app.Tab5Grid.BackgroundColor = [1 1 1];

            % Create DATAHUBPOSTLabel
            app.DATAHUBPOSTLabel = uilabel(app.Tab5Grid);
            app.DATAHUBPOSTLabel.VerticalAlignment = 'bottom';
            app.DATAHUBPOSTLabel.FontSize = 10;
            app.DATAHUBPOSTLabel.Layout.Row = 1;
            app.DATAHUBPOSTLabel.Layout.Column = 1;
            app.DATAHUBPOSTLabel.Text = 'DATAHUB - POST:';

            % Create DataHubPOST
            app.DataHubPOST = uieditfield(app.Tab5Grid, 'text');
            app.DataHubPOST.Editable = 'off';
            app.DataHubPOST.FontSize = 11;
            app.DataHubPOST.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.DataHubPOST.Layout.Row = 2;
            app.DataHubPOST.Layout.Column = 1;

            % Create DataHubPOSTButton
            app.DataHubPOSTButton = uiimage(app.Tab5Grid);
            app.DataHubPOSTButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.DataHubPOSTButton.Tag = 'DataHub_POST';
            app.DataHubPOSTButton.Enable = 'off';
            app.DataHubPOSTButton.Layout.Row = 2;
            app.DataHubPOSTButton.Layout.Column = 2;
            app.DataHubPOSTButton.ImageSource = 'OpenFile_36x36.png';

            % Create userPathLabel
            app.userPathLabel = uilabel(app.Tab5Grid);
            app.userPathLabel.VerticalAlignment = 'bottom';
            app.userPathLabel.FontSize = 10;
            app.userPathLabel.Layout.Row = 3;
            app.userPathLabel.Layout.Column = 1;
            app.userPathLabel.Text = 'PASTA DO USUÁRIO:';

            % Create userPath
            app.userPath = uieditfield(app.Tab5Grid, 'text');
            app.userPath.Editable = 'off';
            app.userPath.FontSize = 11;
            app.userPath.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.userPath.Layout.Row = 4;
            app.userPath.Layout.Column = 1;

            % Create userPathButton
            app.userPathButton = uiimage(app.Tab5Grid);
            app.userPathButton.ImageClickedFcn = createCallbackFcn(app, @Config_FolderButtonPushed, true);
            app.userPathButton.Tag = 'userPath';
            app.userPathButton.Enable = 'off';
            app.userPathButton.Layout.Row = 4;
            app.userPathButton.Layout.Column = 2;
            app.userPathButton.ImageSource = 'OpenFile_36x36.png';

            % Create DockModuleGroup
            app.DockModuleGroup = uigridlayout(app.GridLayout);
            app.DockModuleGroup.RowHeight = {'1x'};
            app.DockModuleGroup.ColumnSpacing = 2;
            app.DockModuleGroup.Padding = [5 2 5 2];
            app.DockModuleGroup.Visible = 'off';
            app.DockModuleGroup.Layout.Row = [2 3];
            app.DockModuleGroup.Layout.Column = [3 4];
            app.DockModuleGroup.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModuleGroup);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModuleGroup);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winConfig_exported(Container, varargin)

            % Create UIFigure and components
            createComponents(app, Container)

            % Execute the startup function
            runStartupFcn(app, @(app)startupFcn(app, varargin{:}))

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            if app.isDocked
                delete(app.Container.Children)
            else
                delete(app.UIFigure)
            end
        end
    end
end
