classdef winConfig_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        ToolbarGrid                    matlab.ui.container.GridLayout
        tool_LeftPanelVisibility       matlab.ui.control.Image
        DocumentGrid                   matlab.ui.container.GridLayout
        Folders_Grid                   matlab.ui.container.GridLayout
        config_FolderMapPanel          matlab.ui.container.Panel
        config_FolderMapGrid           matlab.ui.container.GridLayout
        config_Folder_tempPath         matlab.ui.control.EditField
        config_Folder_tempPathLabel    matlab.ui.control.Label
        config_Folder_userPathButton   matlab.ui.control.Image
        config_Folder_userPath         matlab.ui.control.EditField
        config_Folder_userPathLabel    matlab.ui.control.Label
        config_FolderMapLabel          matlab.ui.control.Label
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
        plot_refresh                   matlab.ui.control.Image
        plot_InteractionsLabel         matlab.ui.control.Label
        plot_Title                     matlab.ui.control.Label
        general_Grid                   matlab.ui.container.GridLayout
        general_GraphicsPanel          matlab.ui.container.Panel
        general_GraphicsGrid           matlab.ui.container.GridLayout
        openAuxiliarApp2Debug          matlab.ui.control.CheckBox
        openAuxiliarAppAsDocked        matlab.ui.control.CheckBox
        gpuType                        matlab.ui.control.DropDown
        gpuTypeLabel                   matlab.ui.control.Label
        general_GraphicsLabel          matlab.ui.control.Label
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
        general_AppVersionPanel        matlab.ui.container.Panel
        general_AppVersionGrid         matlab.ui.container.GridLayout
        AppVersion                     matlab.ui.control.HTML
        general_AppVersionRefresh      matlab.ui.control.Image
        general_AppVersionLabel        matlab.ui.control.Label
        LeftPanel_Grid                 matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        LeftPanelGrid                  matlab.ui.container.GridLayout
        LeftPanelRadioGroup            matlab.ui.container.ButtonGroup
        btnFolder                      matlab.ui.control.RadioButton
        btnPlot                        matlab.ui.control.RadioButton
        btnGeneral                     matlab.ui.control.RadioButton
        Tab1_GridTitle                 matlab.ui.container.GridLayout
        menu_ButtonLabel               matlab.ui.control.Label
        menu_ButtonIcon                matlab.ui.control.Image
    end

    
    properties
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        
        CallingApp
        rootFolder
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        function AppProperties(app)
            app.general_FileLock.UserData    = true;
            app.general_versionLock.UserData = true;

            if isdeployed
                app.openAuxiliarApp2Debug.Enable = 0;
            end
        end

        %-----------------------------------------------------------------%
        function Layout(app)
            general_updateLayout(app)

            plot_updateLayout_Interactions(app)
            plot_updateLayout_TiledSpacing(app)
            plot_updateLayout_OthersFields(app)
            
            config_updatePanel(app)
        end

        %-----------------------------------------------------------------%
        function general_updateLayout(app)
            % PAINEL "ASPECTOS GERAIS"
            % (a) Versão
            general_AppVersionRefreshImageClicked(app)

            % (b) Estação
            app.general_stationName.Value        = app.CallingApp.General.stationInfo.Name;
            app.general_stationType.Items        = {app.CallingApp.General.stationInfo.Type};
            app.general_stationLatitude.Value    = app.CallingApp.General.stationInfo.Latitude;
            app.general_stationLongitude.Value   = app.CallingApp.General.stationInfo.Longitude;
            app.general_lastSessionInfo.Value    = app.CallingApp.General.startupInfo;

            % (c) WebService
            switch app.CallingApp.General.tcpServer.Status
                case 1; app.server_Status.Value  = 'ON';
                case 0; app.server_Status.Value  = 'OFF';                
            end
            app.server_Key.Value                 = app.CallingApp.General.tcpServer.Key;
            app.server_ClientList.Value          = strjoin(app.CallingApp.General.tcpServer.ClientList, ', ');
            app.server_IP.Value                  = app.CallingApp.General.tcpServer.IP;
            app.server_Port.Value                = app.CallingApp.General.tcpServer.Port;
            
            % (d) Gráfico: RENDERIZADOR
            graphRender = opengl('data');
            switch graphRender.HardwareSupportLevel
                case 'basic'; graphRenderSupport = 'hardwarebasic';
                case 'full';  graphRenderSupport = 'hardware';
                case 'none';  graphRenderSupport = 'software';
                otherwise;    graphRenderSupport = graphRender.HardwareSupportLevel; % "driverissue"
            end

            if ~ismember(graphRenderSupport, app.gpuType.Items)
                app.gpuType.Items{end+1} = graphRenderSupport;
            end

            app.gpuType.Value = graphRenderSupport;

            % (e) Gráfico: MODO DE OPERAÇÃO
            app.openAuxiliarAppAsDocked.Value = app.CallingApp.General.operationMode.Dock;
            app.openAuxiliarApp2Debug.Value   = app.CallingApp.General.operationMode.Debug;
        end

        %-----------------------------------------------------------------%
        function plot_updateLayout_Interactions(app)
            set(findobj(app.plot_InteractionsGrid, Tag='InteractionVisibility'), Visible=0)

            for ii = 1:numel(app.CallingApp.axes1.Toolbar.Children)
                switch app.CallingApp.axes1.Toolbar.Children(ii).Tag
                    case 'datacursor';  h = app.plot_DatatipVisibility;
                    case 'pan';         h = app.plot_PanVisibility;
                    case 'zoomin';      h = app.plot_ZoomInVisibility;
                    case 'zoomout';     h = app.plot_ZoomOutVisibility;
                    case 'restoreview'; h = app.plot_RestoreViewVisibility;
                end

                if app.CallingApp.axes1.Toolbar.Children(ii).Visible
                    h.Visible = 1;
                end
            end
        end

        %-----------------------------------------------------------------%
        function plot_updateLayout_TiledSpacing(app)
            app.plot_TiledSpacing.Value = app.CallingApp.axes1.Parent.TileSpacing;
        end

        %-----------------------------------------------------------------%
        function plot_updateLayout_OthersFields(app)
            app.plot_colorsMinHold.Value     = app.CallingApp.General.Plot.MinHold.Color;
            app.plot_colorsAverage.Value     = app.CallingApp.General.Plot.Average.Color;
            app.plot_colorsMaxHold.Value     = app.CallingApp.General.Plot.MaxHold.Color;
            app.plot_colorsClearWrite.Value  = app.CallingApp.General.Plot.ClearWrite.Color;
            
            app.plot_WaterfallColormap.Items = unique([app.plot_WaterfallColormap.Items, {app.CallingApp.General.Plot.Waterfall.Colormap}]);
            app.plot_WaterfallColormap.Value = app.CallingApp.General.Plot.Waterfall.Colormap;

            app.plot_WaterfallDepth.Items    = unique([app.plot_WaterfallDepth.Items, {num2str(app.CallingApp.General.Plot.Waterfall.Depth)}], 'stable');
            app.plot_WaterfallDepth.Value    = {num2str(app.CallingApp.General.Plot.Waterfall.Depth)};

            app.plot_IntegrationTrace.Value  = app.CallingApp.General.Integration.Trace;
            app.plot_IntegrationTime.Value   = app.CallingApp.General.Integration.SampleTime;
        end

        %-----------------------------------------------------------------%
        function config_updatePanel(app)
            % Na versão webapp, a configuração das pastas não é habilitada.

            switch app.CallingApp.executionMode
                case 'webApp'
                    app.btnFolder.Enable = 0;

                otherwise    
                    % userPath & tempPath
                    app.config_Folder_userPath.Value = app.CallingApp.General.fileFolder.userPath;
                    app.config_Folder_tempPath.Value = app.CallingApp.General.fileFolder.tempPath;
            end
        end

        %-----------------------------------------------------------------%
        function status = IPv4Validation(app, ipAddress)
            status   = true;
            ipString = regexp(ipAddress, '\d*[.]{1}\d{1,3}[.]{1}\d{1,3}[.]{1}\d*', 'match');
            
            if isempty(ipString)
                status = false;
            else
                ipArray = cellfun(@(x) str2double(x), strsplit(char(ipString), '.'));
                if any(ipArray > 255) || any(isnan(ipArray))
                    status = false;
                end                    
            end
        end

        %-----------------------------------------------------------------%
        function saveGeneralSettings(app)
            appUtil.generalSettingsSave(class.Constants.appName, app.rootFolder, app.CallingApp.General_I, app.CallingApp.executionMode)
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainapp)
            
            % A razão de ser deste app é possibilitar visualização/edição 
            % de algumas das informações organizadas em "GeneralSettings.json".            
            app.CallingApp = mainapp;
            app.rootFolder = app.CallingApp.rootFolder;

            if app.isDocked
                app.GridLayout.Padding(4) = 21;
            else
                appUtil.winPosition(app.UIFigure)
            end

            AppProperties(app)
            Layout(app)
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            appBackDoor(app.CallingApp, app, 'closeFcn', 'CONFIG')
            delete(app)
            
        end

        % Selection changed function: LeftPanelRadioGroup
        function LeftPanelRadioGroupSelectionChanged(app, event)

            selectedButton = app.LeftPanelRadioGroup.SelectedObject;
            switch selectedButton
                case app.btnGeneral; app.DocumentGrid.ColumnWidth(2:4) = {'1x',0,0};
                case app.btnPlot;    app.DocumentGrid.ColumnWidth(2:4) = {0,'1x',0};
                case app.btnFolder;  app.DocumentGrid.ColumnWidth(2:4) = {0,0,'1x'};
            end

        end

        % Image clicked function: tool_LeftPanelVisibility
        function tool_LeftPanelVisibilityImageClicked(app, event)
            
            if app.DocumentGrid.ColumnWidth{1}
                app.DocumentGrid.ColumnWidth{1} = 0;
                app.tool_LeftPanelVisibility.ImageSource = 'ArrowRight_32.png';
            else
                app.DocumentGrid.ColumnWidth{1} = 325;
                app.tool_LeftPanelVisibility.ImageSource = 'ArrowLeft_32.png';
            end

        end

        % Image clicked function: general_AppVersionRefresh
        function general_AppVersionRefreshImageClicked(app, event)
            
            htmlContent = auxApp.config.htmlCode_AppVersion(app.CallingApp.General, app.CallingApp.executionMode);
            app.AppVersion.HTMLSource = htmlContent;

        end

        % Value changed function: general_lastSessionInfo, 
        % ...and 12 other components
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

                    app.CallingApp.General.stationInfo.Name      = app.general_stationName.Value;

                case app.general_stationType
                    app.CallingApp.General.stationInfo.Type      = app.general_stationType.Value;

                case app.general_stationLatitude
                    app.CallingApp.General.stationInfo.Latitude  = app.general_stationLatitude.Value;

                case app.general_stationLongitude
                    app.CallingApp.General.stationInfo.Longitude = app.general_stationLongitude.Value;

                case app.general_lastSessionInfo
                    app.CallingApp.General.startupInfo           = app.general_lastSessionInfo.Value;                    

                case app.server_Status
                    switch app.server_Status.Value
                        case 'ON';  app.CallingApp.General.tcpServer.Status = 1;
                        case 'OFF'; app.CallingApp.General.tcpServer.Status = 0;
                    end

                case app.server_Key
                    app.server_Key.Value = replace(app.server_Key.Value, ' ', '');
                    app.CallingApp.General.tcpServer.Key = app.server_Key.Value;

                case app.server_ClientList
                    app.server_ClientList.Value = replace(app.server_ClientList.Value, ' ', '');
                    
                    if isempty(app.server_ClientList.Value)
                        app.CallingApp.General.tcpServer.ClientList = {};
                    else
                        app.CallingApp.General.tcpServer.ClientList = strsplit(app.server_ClientList.Value, ',');
                    end

                    app.server_ClientList.Value = strjoin(app.CallingApp.General.tcpServer.ClientList, ', ');

                case app.server_IP
                    app.server_IP.Value = strtrim(app.server_IP.Value);

                    if IPv4Validation(app, app.server_IP.Value) || isempty(app.server_IP.Value)
                        app.CallingApp.General.tcpServer.IP = app.server_IP.Value;
                    else
                        app.server_IP.Value = event.PreviousValue;
                        appUtil.modalWindow(app.UIFigure, 'warning', 'Endereço inválido (IPv4).');
                    end

                case app.server_Port
                    app.CallingApp.General.tcpServer.Port = app.server_Port.Value;

                case app.gpuType
                    if ismember(app.gpuType.Value, {'hardwarebasic', 'hardware', 'software'})
                        app.CallingApp.General.openGL = app.gpuType.Value;
                    end

                case app.openAuxiliarAppAsDocked
                    app.CallingApp.General.operationMode.Dock  = app.openAuxiliarAppAsDocked.Value;

                case app.openAuxiliarApp2Debug
                    app.CallingApp.General.operationMode.Debug = app.openAuxiliarApp2Debug.Value;
            end

            app.CallingApp.General_I.operationMode = app.CallingApp.General.operationMode;
            app.CallingApp.General_I.stationInfo   = app.CallingApp.General.stationInfo;
            app.CallingApp.General_I.openGL        = app.CallingApp.General.openGL;
            app.CallingApp.General_I.startupInfo   = app.CallingApp.General.startupInfo;
            app.CallingApp.General_I.tcpServer     = app.CallingApp.General.tcpServer;

            saveGeneralSettings(app)
            general_updateLayout(app)
            
        end

        % Image clicked function: plot_refresh
        function plot_RefreshImageClicked(app, event)
            
            % Axes toolbar
            Interactions = class.Constants.Interactions;
            plotFcn.axesInteractions(app.CallingApp.axes1, Interactions)
            plotFcn.axesInteractions(app.CallingApp.axes2, Interactions)

            app.CallingApp.axes1.Parent.TileSpacing        = 'tight';

            % Others parameters...
            app.CallingApp.General.Plot.MinHold.Color      = '#4A90E2';
            app.CallingApp.General.Plot.ClearWrite.Color   = '#ffff12';
            app.CallingApp.General.Plot.Average.Color      = '#00cc66';
            app.CallingApp.General.Plot.MaxHold.Color      = '#FF5CAD';

            app.CallingApp.General.Plot.Waterfall.Colormap = 'hot';
            colormap(app.CallingApp.axes2, 'hot')
            app.CallingApp.General.Plot.Waterfall.Depth    = 64;            
            app.CallingApp.General.Integration             = struct('Trace', 10, 'SampleTime', 10);

            app.CallingApp.General_I.Plot        = app.CallingApp.General.Plot;
            app.CallingApp.General_I.Integration = app.CallingApp.General.Integration;
            saveGeneralSettings(app)

            plot_updateLayout_Interactions(app)
            plot_updateLayout_TiledSpacing(app)
            plot_updateLayout_OthersFields(app)

        end

        % Image clicked function: plot_Datatip, plot_Pan, 
        % ...and 3 other components
        function plot_AxesInteractionsChanged(app, event)
            
            % Interações atuais:
            for ii = 1:numel(app.CallingApp.axes1.Toolbar.Children)
                if isprop(app.CallingApp.axes1.Toolbar.Children(ii), 'Value') && app.CallingApp.axes1.Toolbar.Children(ii).Value
                    appUtil.modalWindow(app.UIFigure, 'warning', 'Operação não realizada! É preciso desabilitar qualquer interação com os plots...');
                    return
                end
            end

            % Interações desejadas:
            switch event.Source
                case app.plot_Datatip;     h = app.plot_DatatipVisibility;
                case app.plot_Pan;         h = app.plot_PanVisibility;
                case app.plot_ZoomIn;      h = app.plot_ZoomInVisibility;
                case app.plot_ZoomOut;     h = app.plot_ZoomOutVisibility;
                case app.plot_RestoreView; h = app.plot_RestoreViewVisibility;
            end
            h.Visible = ~h.Visible;
            
            finalInteractions = {};
            if app.plot_DatatipVisibility.Visible;     finalInteractions = [finalInteractions, 'datacursor' ]; end
            if app.plot_PanVisibility.Visible;         finalInteractions = [finalInteractions, 'pan'        ]; end
            if app.plot_ZoomInVisibility.Visible;      finalInteractions = [finalInteractions, 'zoomin'     ]; end
            if app.plot_ZoomOutVisibility.Visible;     finalInteractions = [finalInteractions, 'zoomout'    ]; end
            if app.plot_RestoreViewVisibility.Visible; finalInteractions = [finalInteractions, 'restoreview']; end

            plotFcn.axesInteractions(app.CallingApp.axes1, finalInteractions)
            plotFcn.axesInteractions(app.CallingApp.axes2, finalInteractions)

            if isempty(finalInteractions)
                app.CallingApp.axes1.PickableParts = 'none';
                app.CallingApp.axes2.PickableParts = 'none';
            else
                app.CallingApp.axes1.PickableParts = 'visible';
                app.CallingApp.axes2.PickableParts = 'visible';
            end

            plot_updateLayout_Interactions(app)

        end

        % Value changed function: plot_TiledSpacing
        function plot_AxesTiledSpacingChanged(app, event)
            
            app.CallingApp.axes1.Parent.TileSpacing = app.plot_TiledSpacing.Value;
            
        end

        % Callback function: plot_colorsAverage, plot_colorsClearWrite, 
        % ...and 2 other components
        function plot_ColorParameterChanged(app, event)
            
            initialColor  = event.PreviousValue;
            selectedColor = event.Value;

            if ~isequal(initialColor, selectedColor)
                selectedColor = rgb2hex(selectedColor);
    
                switch event.Source
                    case app.plot_colorsMinHold
                        app.CallingApp.General.Plot.MinHold.Color    = selectedColor;
                    case app.plot_colorsAverage
                        app.CallingApp.General.Plot.Average.Color    = selectedColor;
                    case app.plot_colorsMaxHold
                        app.CallingApp.General.Plot.MaxHold.Color    = selectedColor;
                    case app.plot_colorsClearWrite
                        app.CallingApp.General.Plot.ClearWrite.Color = selectedColor;
                end
            end

            app.CallingApp.General_I.Plot = app.CallingApp.General.Plot;
            saveGeneralSettings(app)

        end

        % Value changed function: plot_IntegrationTime, 
        % ...and 3 other components
        function plot_OthersParameterChanged(app, event)
            
            switch event.Source
                case app.plot_WaterfallColormap
                    colormap(app.CallingApp.axes2, app.plot_WaterfallColormap.Value)
                    app.CallingApp.General.Plot.Waterfall.Colormap = app.plot_WaterfallColormap.Value;

                case app.plot_WaterfallDepth
                    app.CallingApp.General.Plot.Waterfall.Depth    = str2double(app.plot_WaterfallDepth.Value);
                
                case app.plot_IntegrationTrace
                    app.CallingApp.General.Integration.Trace       = app.plot_IntegrationTrace.Value;

                case app.plot_IntegrationTime
                    app.CallingApp.General.Integration.SampleTime  = app.plot_IntegrationTime.Value;
            end

            app.CallingApp.General_I.Plot        = app.CallingApp.General.Plot;
            app.CallingApp.General_I.Integration = app.CallingApp.General.Integration;
            saveGeneralSettings(app)

        end

        % Image clicked function: general_FileLock, general_versionLock
        function general_PanelLockControl(app, event)
            
            switch event.Source
                case app.general_FileLock
                    gridContainer = app.general_stationGrid;
                case app.general_versionLock
                    gridContainer = app.server_Grid;
            end

            event.Source.UserData = ~event.Source.UserData;
            if event.Source.UserData
                event.Source.ImageSource = 'lockClose_32.png';
                set(findobj(gridContainer.Children, '-not', 'Type', 'uilabel'), 'Enable', 0)
            else
                event.Source.ImageSource = 'lockOpen_32.png';
                set(findobj(gridContainer.Children, '-not', 'Type', 'uilabel'), 'Enable', 1)
            end

        end

        % Image clicked function: config_Folder_userPathButton
        function config_getFolder(app, event)
            
            try
                relatedFolder = eval(sprintf('app.config_Folder_%s.Value', event.Source.Tag));                    
            catch
                relatedFolder = app.CallingApp.General.fileFolder.(event.Source.Tag);
            end
            
            if isfolder(relatedFolder)
                initialFolder = relatedFolder;
            elseif isfile(relatedFolder)
                initialFolder = fileparts(relatedFolder);
            else
                initialFolder = app.config_Folder_userPath.Value;
            end
            
            selectedFolder = uigetdir(initialFolder);
            figure(app.UIFigure)

            % Por enquanto, aplicável ao appColeta apenas o "userPath". Caso o 
            % app seja evoluído, consumindo base de dados do Sharepoint, por 
            % exemplo, deve-se copiar esse callback inserido no appAnalise.

            if selectedFolder
                switch event.Source
                    case app.config_Folder_userPathButton
                        app.config_Folder_userPath.Value = selectedFolder;
                        app.CallingApp.General.fileFolder.userPath = selectedFolder;

                    otherwise
                        error('Unexpected call')
                end

                app.CallingApp.General_I.fileFolder = app.CallingApp.General.fileFolder;
                saveGeneralSettings(app)
                config_updatePanel(app)
            end

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
                app.UIFigure.Position = [100 100 1146 558];
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
            app.GridLayout.ColumnWidth = {'1x'};
            app.GridLayout.RowHeight = {'1x', 34};
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create DocumentGrid
            app.DocumentGrid = uigridlayout(app.GridLayout);
            app.DocumentGrid.ColumnWidth = {325, '1x', 0, 0};
            app.DocumentGrid.RowHeight = {'1x'};
            app.DocumentGrid.RowSpacing = 5;
            app.DocumentGrid.Padding = [5 5 5 5];
            app.DocumentGrid.Layout.Row = 1;
            app.DocumentGrid.Layout.Column = 1;
            app.DocumentGrid.BackgroundColor = [1 1 1];

            % Create LeftPanel_Grid
            app.LeftPanel_Grid = uigridlayout(app.DocumentGrid);
            app.LeftPanel_Grid.ColumnWidth = {'1x'};
            app.LeftPanel_Grid.RowHeight = {22, '1x'};
            app.LeftPanel_Grid.RowSpacing = 5;
            app.LeftPanel_Grid.Padding = [0 0 0 0];
            app.LeftPanel_Grid.Layout.Row = 1;
            app.LeftPanel_Grid.Layout.Column = 1;
            app.LeftPanel_Grid.BackgroundColor = [1 1 1];

            % Create Tab1_GridTitle
            app.Tab1_GridTitle = uigridlayout(app.LeftPanel_Grid);
            app.Tab1_GridTitle.ColumnWidth = {18, '1x'};
            app.Tab1_GridTitle.RowHeight = {'1x'};
            app.Tab1_GridTitle.ColumnSpacing = 5;
            app.Tab1_GridTitle.Padding = [2 2 2 2];
            app.Tab1_GridTitle.Layout.Row = 1;
            app.Tab1_GridTitle.Layout.Column = 1;
            app.Tab1_GridTitle.BackgroundColor = [0.749 0.749 0.749];

            % Create menu_ButtonIcon
            app.menu_ButtonIcon = uiimage(app.Tab1_GridTitle);
            app.menu_ButtonIcon.ScaleMethod = 'none';
            app.menu_ButtonIcon.Tag = '1';
            app.menu_ButtonIcon.Layout.Row = 1;
            app.menu_ButtonIcon.Layout.Column = 1;
            app.menu_ButtonIcon.HorizontalAlignment = 'left';
            app.menu_ButtonIcon.ImageSource = 'Settings_18.png';

            % Create menu_ButtonLabel
            app.menu_ButtonLabel = uilabel(app.Tab1_GridTitle);
            app.menu_ButtonLabel.FontSize = 11;
            app.menu_ButtonLabel.Layout.Row = 1;
            app.menu_ButtonLabel.Layout.Column = 2;
            app.menu_ButtonLabel.Text = 'CONFIGURAÇÕES';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.LeftPanel_Grid);
            app.LeftPanel.AutoResizeChildren = 'off';
            app.LeftPanel.Layout.Row = 2;
            app.LeftPanel.Layout.Column = 1;

            % Create LeftPanelGrid
            app.LeftPanelGrid = uigridlayout(app.LeftPanel);
            app.LeftPanelGrid.ColumnWidth = {'1x'};
            app.LeftPanelGrid.RowHeight = {100, '1x'};
            app.LeftPanelGrid.Padding = [0 0 0 0];
            app.LeftPanelGrid.BackgroundColor = [1 1 1];

            % Create LeftPanelRadioGroup
            app.LeftPanelRadioGroup = uibuttongroup(app.LeftPanelGrid);
            app.LeftPanelRadioGroup.AutoResizeChildren = 'off';
            app.LeftPanelRadioGroup.SelectionChangedFcn = createCallbackFcn(app, @LeftPanelRadioGroupSelectionChanged, true);
            app.LeftPanelRadioGroup.BorderType = 'none';
            app.LeftPanelRadioGroup.BackgroundColor = [1 1 1];
            app.LeftPanelRadioGroup.Layout.Row = 1;
            app.LeftPanelRadioGroup.Layout.Column = 1;
            app.LeftPanelRadioGroup.FontSize = 11;

            % Create btnGeneral
            app.btnGeneral = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnGeneral.Text = 'Aspectos gerais';
            app.btnGeneral.FontSize = 11;
            app.btnGeneral.Position = [11 69 100 22];
            app.btnGeneral.Value = true;

            % Create btnPlot
            app.btnPlot = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnPlot.Text = 'Customização do plot';
            app.btnPlot.FontSize = 11;
            app.btnPlot.Position = [11 47 128 22];

            % Create btnFolder
            app.btnFolder = uiradiobutton(app.LeftPanelRadioGroup);
            app.btnFolder.Text = 'Mapeamento de pastas';
            app.btnFolder.FontSize = 11;
            app.btnFolder.Position = [11 25 137 22];

            % Create general_Grid
            app.general_Grid = uigridlayout(app.DocumentGrid);
            app.general_Grid.ColumnWidth = {'1x', 16, 254, 16};
            app.general_Grid.RowHeight = {22, 136, 22, 162, 22, '1x'};
            app.general_Grid.RowSpacing = 5;
            app.general_Grid.Padding = [0 0 0 0];
            app.general_Grid.Layout.Row = 1;
            app.general_Grid.Layout.Column = 2;
            app.general_Grid.BackgroundColor = [1 1 1];

            % Create general_AppVersionLabel
            app.general_AppVersionLabel = uilabel(app.general_Grid);
            app.general_AppVersionLabel.VerticalAlignment = 'bottom';
            app.general_AppVersionLabel.FontSize = 10;
            app.general_AppVersionLabel.Layout.Row = 1;
            app.general_AppVersionLabel.Layout.Column = 1;
            app.general_AppVersionLabel.Text = 'ASPECTOS GERAIS';

            % Create general_AppVersionRefresh
            app.general_AppVersionRefresh = uiimage(app.general_Grid);
            app.general_AppVersionRefresh.ImageClickedFcn = createCallbackFcn(app, @general_AppVersionRefreshImageClicked, true);
            app.general_AppVersionRefresh.Tooltip = {'Verifica atualizações'};
            app.general_AppVersionRefresh.Layout.Row = 1;
            app.general_AppVersionRefresh.Layout.Column = 2;
            app.general_AppVersionRefresh.VerticalAlignment = 'bottom';
            app.general_AppVersionRefresh.ImageSource = 'Refresh_18.png';

            % Create general_AppVersionPanel
            app.general_AppVersionPanel = uipanel(app.general_Grid);
            app.general_AppVersionPanel.AutoResizeChildren = 'off';
            app.general_AppVersionPanel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.general_AppVersionPanel.Layout.Row = [2 6];
            app.general_AppVersionPanel.Layout.Column = [1 2];

            % Create general_AppVersionGrid
            app.general_AppVersionGrid = uigridlayout(app.general_AppVersionPanel);
            app.general_AppVersionGrid.ColumnWidth = {'1x'};
            app.general_AppVersionGrid.RowHeight = {'1x'};
            app.general_AppVersionGrid.Padding = [0 0 0 0];
            app.general_AppVersionGrid.BackgroundColor = [1 1 1];

            % Create AppVersion
            app.AppVersion = uihtml(app.general_AppVersionGrid);
            app.AppVersion.HTMLSource = ' ';
            app.AppVersion.Layout.Row = 1;
            app.AppVersion.Layout.Column = 1;

            % Create general_FileLabel
            app.general_FileLabel = uilabel(app.general_Grid);
            app.general_FileLabel.VerticalAlignment = 'bottom';
            app.general_FileLabel.FontSize = 10;
            app.general_FileLabel.Layout.Row = 1;
            app.general_FileLabel.Layout.Column = 3;
            app.general_FileLabel.Text = 'ESTAÇÃO';

            % Create general_FileLock
            app.general_FileLock = uiimage(app.general_Grid);
            app.general_FileLock.ImageClickedFcn = createCallbackFcn(app, @general_PanelLockControl, true);
            app.general_FileLock.Layout.Row = 1;
            app.general_FileLock.Layout.Column = 4;
            app.general_FileLock.VerticalAlignment = 'bottom';
            app.general_FileLock.ImageSource = 'lockClose_32.png';

            % Create general_FilePanel
            app.general_FilePanel = uipanel(app.general_Grid);
            app.general_FilePanel.AutoResizeChildren = 'off';
            app.general_FilePanel.Layout.Row = 2;
            app.general_FilePanel.Layout.Column = [3 4];

            % Create general_stationGrid
            app.general_stationGrid = uigridlayout(app.general_FilePanel);
            app.general_stationGrid.RowHeight = {17, 22, 22, 22, 17};
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
            app.general_lastSessionInfo.Layout.Column = [1 2];

            % Create general_versionLabel
            app.general_versionLabel = uilabel(app.general_Grid);
            app.general_versionLabel.VerticalAlignment = 'bottom';
            app.general_versionLabel.FontSize = 10;
            app.general_versionLabel.Layout.Row = 3;
            app.general_versionLabel.Layout.Column = 3;
            app.general_versionLabel.Text = 'WEBSERVICE';

            % Create general_versionLock
            app.general_versionLock = uiimage(app.general_Grid);
            app.general_versionLock.ImageClickedFcn = createCallbackFcn(app, @general_PanelLockControl, true);
            app.general_versionLock.Layout.Row = 3;
            app.general_versionLock.Layout.Column = 4;
            app.general_versionLock.VerticalAlignment = 'bottom';
            app.general_versionLock.ImageSource = 'lockClose_32.png';

            % Create general_versionPanel
            app.general_versionPanel = uipanel(app.general_Grid);
            app.general_versionPanel.AutoResizeChildren = 'off';
            app.general_versionPanel.Layout.Row = 4;
            app.general_versionPanel.Layout.Column = [3 4];

            % Create server_Grid
            app.server_Grid = uigridlayout(app.general_versionPanel);
            app.server_Grid.RowHeight = {17, 22, 22, 22, 17, 22};
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
            app.server_IPLabel.Layout.Column = [1 2];
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

            % Create general_GraphicsLabel
            app.general_GraphicsLabel = uilabel(app.general_Grid);
            app.general_GraphicsLabel.VerticalAlignment = 'bottom';
            app.general_GraphicsLabel.FontSize = 10;
            app.general_GraphicsLabel.Layout.Row = 5;
            app.general_GraphicsLabel.Layout.Column = 3;
            app.general_GraphicsLabel.Text = 'GRÁFICO';

            % Create general_GraphicsPanel
            app.general_GraphicsPanel = uipanel(app.general_Grid);
            app.general_GraphicsPanel.AutoResizeChildren = 'off';
            app.general_GraphicsPanel.Layout.Row = 6;
            app.general_GraphicsPanel.Layout.Column = [3 4];

            % Create general_GraphicsGrid
            app.general_GraphicsGrid = uigridlayout(app.general_GraphicsPanel);
            app.general_GraphicsGrid.RowHeight = {17, 22, 38, 17};
            app.general_GraphicsGrid.RowSpacing = 5;
            app.general_GraphicsGrid.Padding = [10 10 10 4];
            app.general_GraphicsGrid.BackgroundColor = [1 1 1];

            % Create gpuTypeLabel
            app.gpuTypeLabel = uilabel(app.general_GraphicsGrid);
            app.gpuTypeLabel.VerticalAlignment = 'bottom';
            app.gpuTypeLabel.FontSize = 10;
            app.gpuTypeLabel.FontColor = [0.149 0.149 0.149];
            app.gpuTypeLabel.Layout.Row = 1;
            app.gpuTypeLabel.Layout.Column = 1;
            app.gpuTypeLabel.Text = 'Unidade gráfica:';

            % Create gpuType
            app.gpuType = uidropdown(app.general_GraphicsGrid);
            app.gpuType.Items = {'hardwarebasic', 'hardware', 'software'};
            app.gpuType.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.gpuType.FontSize = 11;
            app.gpuType.BackgroundColor = [1 1 1];
            app.gpuType.Layout.Row = 2;
            app.gpuType.Layout.Column = [1 2];
            app.gpuType.Value = 'hardwarebasic';

            % Create openAuxiliarAppAsDocked
            app.openAuxiliarAppAsDocked = uicheckbox(app.general_GraphicsGrid);
            app.openAuxiliarAppAsDocked.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.openAuxiliarAppAsDocked.Text = 'Modo DOCK: módulos auxiliares abertos na própria janela do appColeta.';
            app.openAuxiliarAppAsDocked.WordWrap = 'on';
            app.openAuxiliarAppAsDocked.FontSize = 11;
            app.openAuxiliarAppAsDocked.Layout.Row = 3;
            app.openAuxiliarAppAsDocked.Layout.Column = [1 2];

            % Create openAuxiliarApp2Debug
            app.openAuxiliarApp2Debug = uicheckbox(app.general_GraphicsGrid);
            app.openAuxiliarApp2Debug.ValueChangedFcn = createCallbackFcn(app, @general_ParameterChanged, true);
            app.openAuxiliarApp2Debug.Text = 'Modo DEBUG';
            app.openAuxiliarApp2Debug.FontSize = 11;
            app.openAuxiliarApp2Debug.Layout.Row = 4;
            app.openAuxiliarApp2Debug.Layout.Column = [1 2];

            % Create plot_Grid
            app.plot_Grid = uigridlayout(app.DocumentGrid);
            app.plot_Grid.ColumnWidth = {'1x', 16};
            app.plot_Grid.RowHeight = {22, 17, 38, 17, 22, 17, 62, 17, 63, 17, '1x'};
            app.plot_Grid.RowSpacing = 5;
            app.plot_Grid.Padding = [0 0 0 0];
            app.plot_Grid.Layout.Row = 1;
            app.plot_Grid.Layout.Column = 3;
            app.plot_Grid.BackgroundColor = [1 1 1];

            % Create plot_Title
            app.plot_Title = uilabel(app.plot_Grid);
            app.plot_Title.VerticalAlignment = 'bottom';
            app.plot_Title.FontSize = 10;
            app.plot_Title.Layout.Row = 1;
            app.plot_Title.Layout.Column = 1;
            app.plot_Title.Text = 'CUSTOMIZAÇÃO DO PLOT';

            % Create plot_InteractionsLabel
            app.plot_InteractionsLabel = uilabel(app.plot_Grid);
            app.plot_InteractionsLabel.VerticalAlignment = 'bottom';
            app.plot_InteractionsLabel.FontSize = 10;
            app.plot_InteractionsLabel.Layout.Row = 2;
            app.plot_InteractionsLabel.Layout.Column = 1;
            app.plot_InteractionsLabel.Text = 'Interações:';

            % Create plot_refresh
            app.plot_refresh = uiimage(app.plot_Grid);
            app.plot_refresh.ImageClickedFcn = createCallbackFcn(app, @plot_RefreshImageClicked, true);
            app.plot_refresh.Layout.Row = 2;
            app.plot_refresh.Layout.Column = 2;
            app.plot_refresh.HorizontalAlignment = 'left';
            app.plot_refresh.VerticalAlignment = 'bottom';
            app.plot_refresh.ImageSource = 'Refresh_18.png';

            % Create plot_InteractionsPanel
            app.plot_InteractionsPanel = uipanel(app.plot_Grid);
            app.plot_InteractionsPanel.AutoResizeChildren = 'off';
            app.plot_InteractionsPanel.BackgroundColor = [1 1 1];
            app.plot_InteractionsPanel.Layout.Row = 3;
            app.plot_InteractionsPanel.Layout.Column = [1 2];

            % Create plot_InteractionsGrid
            app.plot_InteractionsGrid = uigridlayout(app.plot_InteractionsPanel);
            app.plot_InteractionsGrid.ColumnWidth = {16, 16, 16, 16, 16, '1x'};
            app.plot_InteractionsGrid.RowHeight = {'1x', 3};
            app.plot_InteractionsGrid.RowSpacing = 0;
            app.plot_InteractionsGrid.Padding = [5 5 10 2];
            app.plot_InteractionsGrid.BackgroundColor = [1 1 1];

            % Create plot_Datatip
            app.plot_Datatip = uiimage(app.plot_InteractionsGrid);
            app.plot_Datatip.ImageClickedFcn = createCallbackFcn(app, @plot_AxesInteractionsChanged, true);
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
            app.plot_Pan.ImageClickedFcn = createCallbackFcn(app, @plot_AxesInteractionsChanged, true);
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
            app.plot_ZoomIn.ImageClickedFcn = createCallbackFcn(app, @plot_AxesInteractionsChanged, true);
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
            app.plot_ZoomOut.ImageClickedFcn = createCallbackFcn(app, @plot_AxesInteractionsChanged, true);
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
            app.plot_RestoreView.ImageClickedFcn = createCallbackFcn(app, @plot_AxesInteractionsChanged, true);
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
            app.plot_TiledSpacingLabel.Layout.Row = 4;
            app.plot_TiledSpacingLabel.Layout.Column = [1 2];
            app.plot_TiledSpacingLabel.Text = 'Espaçamento entre eixos:';

            % Create plot_TiledSpacing
            app.plot_TiledSpacing = uidropdown(app.plot_Grid);
            app.plot_TiledSpacing.Items = {'loose', 'compact', 'tight', 'none'};
            app.plot_TiledSpacing.ValueChangedFcn = createCallbackFcn(app, @plot_AxesTiledSpacingChanged, true);
            app.plot_TiledSpacing.FontSize = 11;
            app.plot_TiledSpacing.BackgroundColor = [1 1 1];
            app.plot_TiledSpacing.Layout.Row = 5;
            app.plot_TiledSpacing.Layout.Column = [1 2];
            app.plot_TiledSpacing.Value = 'loose';

            % Create plot_colorsLabel
            app.plot_colorsLabel = uilabel(app.plot_Grid);
            app.plot_colorsLabel.VerticalAlignment = 'bottom';
            app.plot_colorsLabel.FontSize = 10;
            app.plot_colorsLabel.FontWeight = 'bold';
            app.plot_colorsLabel.Layout.Row = 6;
            app.plot_colorsLabel.Layout.Column = 1;
            app.plot_colorsLabel.Text = 'Cores:';

            % Create plot_colorsPanel
            app.plot_colorsPanel = uipanel(app.plot_Grid);
            app.plot_colorsPanel.AutoResizeChildren = 'off';
            app.plot_colorsPanel.Layout.Row = 7;
            app.plot_colorsPanel.Layout.Column = [1 2];

            % Create plot_colorsGrid
            app.plot_colorsGrid = uigridlayout(app.plot_colorsPanel);
            app.plot_colorsGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
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
            app.plot_colorsMinHold.ValueChangedFcn = createCallbackFcn(app, @plot_ColorParameterChanged, true);
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
            app.plot_colorsAverage.ValueChangedFcn = createCallbackFcn(app, @plot_ColorParameterChanged, true);
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
            app.plot_colorsMaxHold.ValueChangedFcn = createCallbackFcn(app, @plot_ColorParameterChanged, true);
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
            app.plot_colorsClearWrite.ValueChangedFcn = createCallbackFcn(app, @plot_ColorParameterChanged, true);
            app.plot_colorsClearWrite.Layout.Row = 2;
            app.plot_colorsClearWrite.Layout.Column = 4;

            % Create plot_WaterfallLabel
            app.plot_WaterfallLabel = uilabel(app.plot_Grid);
            app.plot_WaterfallLabel.VerticalAlignment = 'bottom';
            app.plot_WaterfallLabel.FontSize = 10;
            app.plot_WaterfallLabel.Layout.Row = 8;
            app.plot_WaterfallLabel.Layout.Column = 1;
            app.plot_WaterfallLabel.Text = 'Waterfall:';

            % Create plot_WaterfallPanel
            app.plot_WaterfallPanel = uipanel(app.plot_Grid);
            app.plot_WaterfallPanel.AutoResizeChildren = 'off';
            app.plot_WaterfallPanel.BackgroundColor = [1 1 1];
            app.plot_WaterfallPanel.Layout.Row = 9;
            app.plot_WaterfallPanel.Layout.Column = [1 2];

            % Create plot_WaterfallGrid
            app.plot_WaterfallGrid = uigridlayout(app.plot_WaterfallPanel);
            app.plot_WaterfallGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
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
            app.plot_WaterfallColormap.ValueChangedFcn = createCallbackFcn(app, @plot_OthersParameterChanged, true);
            app.plot_WaterfallColormap.FontSize = 11;
            app.plot_WaterfallColormap.BackgroundColor = [1 1 1];
            app.plot_WaterfallColormap.Layout.Row = 2;
            app.plot_WaterfallColormap.Layout.Column = 1;
            app.plot_WaterfallColormap.Value = 'jet';

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
            app.plot_WaterfallDepth.ValueChangedFcn = createCallbackFcn(app, @plot_OthersParameterChanged, true);
            app.plot_WaterfallDepth.FontSize = 11;
            app.plot_WaterfallDepth.BackgroundColor = [1 1 1];
            app.plot_WaterfallDepth.Layout.Row = 2;
            app.plot_WaterfallDepth.Layout.Column = 2;
            app.plot_WaterfallDepth.Value = '128';

            % Create plot_IntegrationLabel
            app.plot_IntegrationLabel = uilabel(app.plot_Grid);
            app.plot_IntegrationLabel.VerticalAlignment = 'bottom';
            app.plot_IntegrationLabel.FontSize = 10;
            app.plot_IntegrationLabel.Layout.Row = 10;
            app.plot_IntegrationLabel.Layout.Column = 1;
            app.plot_IntegrationLabel.Text = 'Integração:';

            % Create plot_IntegrationPanel
            app.plot_IntegrationPanel = uipanel(app.plot_Grid);
            app.plot_IntegrationPanel.AutoResizeChildren = 'off';
            app.plot_IntegrationPanel.BackgroundColor = [1 1 1];
            app.plot_IntegrationPanel.Layout.Row = 11;
            app.plot_IntegrationPanel.Layout.Column = [1 2];

            % Create plot_IntegrationGrid
            app.plot_IntegrationGrid = uigridlayout(app.plot_IntegrationPanel);
            app.plot_IntegrationGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
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
            app.plot_IntegrationTrace.ValueChangedFcn = createCallbackFcn(app, @plot_OthersParameterChanged, true);
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
            app.plot_IntegrationTime.ValueChangedFcn = createCallbackFcn(app, @plot_OthersParameterChanged, true);
            app.plot_IntegrationTime.FontSize = 11;
            app.plot_IntegrationTime.Layout.Row = 2;
            app.plot_IntegrationTime.Layout.Column = 2;
            app.plot_IntegrationTime.Value = 10;

            % Create Folders_Grid
            app.Folders_Grid = uigridlayout(app.DocumentGrid);
            app.Folders_Grid.ColumnWidth = {'1x'};
            app.Folders_Grid.RowHeight = {22, 5, '1x', 1};
            app.Folders_Grid.RowSpacing = 0;
            app.Folders_Grid.Padding = [0 0 0 0];
            app.Folders_Grid.Layout.Row = 1;
            app.Folders_Grid.Layout.Column = 4;
            app.Folders_Grid.BackgroundColor = [1 1 1];

            % Create config_FolderMapLabel
            app.config_FolderMapLabel = uilabel(app.Folders_Grid);
            app.config_FolderMapLabel.VerticalAlignment = 'bottom';
            app.config_FolderMapLabel.FontSize = 10;
            app.config_FolderMapLabel.Layout.Row = 1;
            app.config_FolderMapLabel.Layout.Column = 1;
            app.config_FolderMapLabel.Text = 'MAPEAMENTO DE PASTAS';

            % Create config_FolderMapPanel
            app.config_FolderMapPanel = uipanel(app.Folders_Grid);
            app.config_FolderMapPanel.AutoResizeChildren = 'off';
            app.config_FolderMapPanel.Layout.Row = 3;
            app.config_FolderMapPanel.Layout.Column = 1;

            % Create config_FolderMapGrid
            app.config_FolderMapGrid = uigridlayout(app.config_FolderMapPanel);
            app.config_FolderMapGrid.ColumnWidth = {'1x', 20};
            app.config_FolderMapGrid.RowHeight = {17, 22, 17, 22, '1x'};
            app.config_FolderMapGrid.ColumnSpacing = 5;
            app.config_FolderMapGrid.RowSpacing = 5;
            app.config_FolderMapGrid.BackgroundColor = [1 1 1];

            % Create config_Folder_userPathLabel
            app.config_Folder_userPathLabel = uilabel(app.config_FolderMapGrid);
            app.config_Folder_userPathLabel.VerticalAlignment = 'bottom';
            app.config_Folder_userPathLabel.FontSize = 10;
            app.config_Folder_userPathLabel.Layout.Row = 1;
            app.config_Folder_userPathLabel.Layout.Column = 1;
            app.config_Folder_userPathLabel.Text = 'Pasta do usuário:';

            % Create config_Folder_userPath
            app.config_Folder_userPath = uieditfield(app.config_FolderMapGrid, 'text');
            app.config_Folder_userPath.Editable = 'off';
            app.config_Folder_userPath.FontSize = 11;
            app.config_Folder_userPath.Layout.Row = 2;
            app.config_Folder_userPath.Layout.Column = 1;

            % Create config_Folder_userPathButton
            app.config_Folder_userPathButton = uiimage(app.config_FolderMapGrid);
            app.config_Folder_userPathButton.ImageClickedFcn = createCallbackFcn(app, @config_getFolder, true);
            app.config_Folder_userPathButton.Tag = 'userPath';
            app.config_Folder_userPathButton.Layout.Row = 2;
            app.config_Folder_userPathButton.Layout.Column = 2;
            app.config_Folder_userPathButton.ImageSource = 'OpenFile_36x36.png';

            % Create config_Folder_tempPathLabel
            app.config_Folder_tempPathLabel = uilabel(app.config_FolderMapGrid);
            app.config_Folder_tempPathLabel.VerticalAlignment = 'bottom';
            app.config_Folder_tempPathLabel.FontSize = 10;
            app.config_Folder_tempPathLabel.Layout.Row = 3;
            app.config_Folder_tempPathLabel.Layout.Column = 1;
            app.config_Folder_tempPathLabel.Text = 'Pasta temporária:';

            % Create config_Folder_tempPath
            app.config_Folder_tempPath = uieditfield(app.config_FolderMapGrid, 'text');
            app.config_Folder_tempPath.Editable = 'off';
            app.config_Folder_tempPath.FontSize = 11;
            app.config_Folder_tempPath.Layout.Row = 4;
            app.config_Folder_tempPath.Layout.Column = 1;

            % Create ToolbarGrid
            app.ToolbarGrid = uigridlayout(app.GridLayout);
            app.ToolbarGrid.ColumnWidth = {22, '1x'};
            app.ToolbarGrid.RowHeight = {'1x'};
            app.ToolbarGrid.ColumnSpacing = 5;
            app.ToolbarGrid.Padding = [1 7 5 7];
            app.ToolbarGrid.Layout.Row = 2;
            app.ToolbarGrid.Layout.Column = 1;

            % Create tool_LeftPanelVisibility
            app.tool_LeftPanelVisibility = uiimage(app.ToolbarGrid);
            app.tool_LeftPanelVisibility.ImageClickedFcn = createCallbackFcn(app, @tool_LeftPanelVisibilityImageClicked, true);
            app.tool_LeftPanelVisibility.Layout.Row = 1;
            app.tool_LeftPanelVisibility.Layout.Column = 1;
            app.tool_LeftPanelVisibility.ImageSource = 'ArrowLeft_32.png';

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
