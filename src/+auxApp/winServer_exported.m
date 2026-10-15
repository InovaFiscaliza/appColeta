classdef winServer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        DockModule                matlab.ui.container.GridLayout
        DockCloseButton           matlab.ui.control.Image
        DockUndockButton          matlab.ui.control.Image
        ConfirmEditionButtonGrid  matlab.ui.container.GridLayout
        ConfirmEditionButton      matlab.ui.control.Button
        Toolbar                   matlab.ui.container.GridLayout
        StatusLampLabel           matlab.ui.control.Label
        StatusLamp                matlab.ui.control.Lamp
        UITable                   matlab.ui.control.Table
        UITableRefresh            matlab.ui.control.Image
        UITableLabel              matlab.ui.control.Label
        ServerInfo                matlab.ui.control.TextArea
        ServerInfoLabel           matlab.ui.control.Label
        HeaderTitle               matlab.ui.control.Label
        HeaderIcon                matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'SERVER'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        SubTabGroup = struct('Children', -1, 'UserData', [])

        mainApp
        jsBackDoor
        progressDialog
    end


    methods (Access = public)
        %-----------------------------------------------------------------%
        function ipcSecondaryJSEventsHandler(app, event)
            try
                switch event.HTMLEventName
                    case 'renderer'
                        appEngine.activate(app, app.Role)

                    otherwise
                        ipcMainJSEventsHandler(app.mainApp, event)
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
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
                        app.ConfirmEditionButtonGrid;
                        app.UITableRefresh;
                        app.DockUndockButton;
                        app.DockCloseButton
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.ConfirmEditionButtonGrid.UserData.id, 'style', struct('background', 'none')), ...
                            struct('appName', appName, 'dataTag', app.UITableRefresh.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Atualiza registro de comunicação')), ...
                            struct('appName', appName, 'dataTag', app.DockUndockButton.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.DockCloseButton.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                otherwise
                    % ...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % ...
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.DockUndockButton.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            updateLayout(app)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function updateLayout(app)
            if isempty(app.mainApp.tcpServer)
                app.ServerInfo.Value = '';
                app.UITableRefresh.Visible = 0;

                app.StatusLamp.Color = [.64 .08 .18];
                app.StatusLampLabel.Text = 'Servidor não está em execução.';

                app.UITable.Data = table( ...
                    'Size', [0, 8], ...
                    'VariableTypes', {'string', 'string', 'double', 'string', 'string', 'string', 'double', 'string'}, ...
                    'VariableNames', {'Timestamp', 'ClientAddress', 'ClientPort', 'Message', 'ClientName', 'Request', 'NumBytesWritten', 'Status'} ...
                );

                buttonText = 'Iniciar servidor';
                buttonIcon = 'play-16px-white.svg';

            elseif isempty(app.mainApp.tcpServer.Server)
                app.ServerInfo.Value = '';
                app.UITableRefresh.Visible = 0;

                app.StatusLamp.Color = [.5 .5 .5];
                app.StatusLampLabel.Text = sprintf('Servidor ainda não está em execução, apesar do objeto "model.TcpServer" já ter sido criado. Será realizada uma nova tentativa para executá-lo a cada %d segundos.', class.Constants.tcpServerPeriod);

                app.UITable.Data = app.mainApp.tcpServer.Log;

                buttonText = 'Excluir objeto';
                buttonIcon = 'close-16px-white.svg';

            else
                app.ServerInfo.Value = util.HtmlTextGenerator.Server(app.mainApp.tcpServer);
                app.UITableRefresh.Visible = 1;

                app.StatusLamp.Color = [.47 .67 .19];
                app.StatusLampLabel.Text = sprintf('Servidor em execução desde %s.', char(app.mainApp.tcpServer.StartTime));

                app.UITable.Data = app.mainApp.tcpServer.Log;
                
                buttonText = 'Parar servidor';
                buttonIcon = 'debug-stop-16px-white.svg';
            end

            set(app.ConfirmEditionButton, 'Text', buttonText, 'Icon', buttonIcon)
            app.ConfirmEditionButtonGrid.Visible = true;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)

            try
                appEngine.boot(app, app.Role, mainApp)
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', app.Context)
            delete(app)
            
        end

        % Image clicked function: DockCloseButton, DockUndockButton
        function onDockModuleGroupButtonClicked(app, event)
            
            [idx, auxAppTag, relatedButton] = getAppInfoFromHandle(app.mainApp.tabGroupController, app);

            switch event.Source
                case app.DockUndockButton
                    appGeneral = app.mainApp.General;
                    appGeneral.operationMode.Dock = false;

                    inputArguments = ipcMainMatlabCallsHandler(app.mainApp, app, 'dockButtonPushed', auxAppTag);
                    app.mainApp.tabGroupController.Components.appHandle{idx} = [];
                    
                    openModule(app.mainApp.tabGroupController, relatedButton, false, appGeneral, inputArguments{:})
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General, 'undock')
                    
                    delete(app)

                case app.DockCloseButton
                    closeModule(app.mainApp.tabGroupController, auxAppTag, app.mainApp.General)
            end

        end

        % Button pushed function: ConfirmEditionButton
        function toolButtonPushed_edit(app, event)
            
            if isempty(app.mainApp.tcpServer)
                app.mainApp.tcpServer = model.TcpServer(app.mainApp);
            
            else
                stop(app.mainApp.tcpServer.Timer)
                delete(app.mainApp.tcpServer.Timer)
                delete(app.mainApp.tcpServer.Server)
                app.mainApp.tcpServer = [];
            end

            updateLayout(app)

        end

        % Image clicked function: UITableRefresh
        function UITableRefreshUITableRefreshClicked(app, event)
            
            updateLayout(app)

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
                app.UIFigure.Position = [100 100 940 540];
                app.UIFigure.Name = 'appColeta';
                app.UIFigure.Icon = 'icon_32.png';
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
            app.GridLayout.ColumnWidth = {24, 24, 5, '1x', 122, 20, 18, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, 22, 36, 17, 5, 88, 5, 22, 5, '1x', 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create HeaderIcon
            app.HeaderIcon = uiimage(app.GridLayout);
            app.HeaderIcon.ScaleMethod = 'none';
            app.HeaderIcon.Layout.Row = [4 5];
            app.HeaderIcon.Layout.Column = 2;
            app.HeaderIcon.VerticalAlignment = 'top';
            app.HeaderIcon.ImageSource = 'cloud-upload - blue.svg';

            % Create HeaderTitle
            app.HeaderTitle = uilabel(app.GridLayout);
            app.HeaderTitle.VerticalAlignment = 'top';
            app.HeaderTitle.WordWrap = 'on';
            app.HeaderTitle.FontSize = 15;
            app.HeaderTitle.FontColor = [0 0.4471 0.7412];
            app.HeaderTitle.Layout.Row = [4 6];
            app.HeaderTitle.Layout.Column = [4 7];
            app.HeaderTitle.Interpreter = 'html';
            app.HeaderTitle.Text = {'<b>Servidor de comunicação (TCP)</b>'; '<font style="color: gray; font-size: 11px;">Controle o estado do servidor que atende requisições de clientes externos (Zabbix, por exemplo), compartilhando informações acerca do computador, estação e tarefas de monitoração, e acompanhe o registro de comunicação</font>'};

            % Create ServerInfoLabel
            app.ServerInfoLabel = uilabel(app.GridLayout);
            app.ServerInfoLabel.VerticalAlignment = 'bottom';
            app.ServerInfoLabel.FontSize = 10;
            app.ServerInfoLabel.Layout.Row = 7;
            app.ServerInfoLabel.Layout.Column = [2 4];
            app.ServerInfoLabel.Text = 'CARACTERÍSTICAS';

            % Create ServerInfo
            app.ServerInfo = uitextarea(app.GridLayout);
            app.ServerInfo.Editable = 'off';
            app.ServerInfo.FontSize = 11;
            app.ServerInfo.Layout.Row = 9;
            app.ServerInfo.Layout.Column = [2 7];

            % Create UITableLabel
            app.UITableLabel = uilabel(app.GridLayout);
            app.UITableLabel.VerticalAlignment = 'bottom';
            app.UITableLabel.FontSize = 10;
            app.UITableLabel.Layout.Row = 11;
            app.UITableLabel.Layout.Column = [2 4];
            app.UITableLabel.Text = 'COMUNICAÇÃO';

            % Create UITableRefresh
            app.UITableRefresh = uiimage(app.GridLayout);
            app.UITableRefresh.ScaleMethod = 'none';
            app.UITableRefresh.ImageClickedFcn = createCallbackFcn(app, @UITableRefreshUITableRefreshClicked, true);
            app.UITableRefresh.Visible = 'off';
            app.UITableRefresh.Layout.Row = 11;
            app.UITableRefresh.Layout.Column = 7;
            app.UITableRefresh.ImageSource = 'Refresh_18.png';

            % Create UITable
            app.UITable = uitable(app.GridLayout);
            app.UITable.ColumnName = {'INSTANTE'; 'IP'; 'PORTA'; 'MENSAGEM'; 'CLIENTE'; 'REQUISIÇÃO'; 'BYTES'; 'ESTADO'};
            app.UITable.RowName = {};
            app.UITable.Layout.Row = 13;
            app.UITable.Layout.Column = [2 7];
            app.UITable.FontSize = 10;

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {18, '1x', 110};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 15;
            app.Toolbar.Layout.Column = [1 10];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create StatusLamp
            app.StatusLamp = uilamp(app.Toolbar);
            app.StatusLamp.Layout.Row = 1;
            app.StatusLamp.Layout.Column = 1;
            app.StatusLamp.Color = [0.4706 0.6706 0.1882];

            % Create StatusLampLabel
            app.StatusLampLabel = uilabel(app.Toolbar);
            app.StatusLampLabel.FontSize = 11;
            app.StatusLampLabel.Layout.Row = 1;
            app.StatusLampLabel.Layout.Column = 2;
            app.StatusLampLabel.Text = 'Desconectado';

            % Create ConfirmEditionButtonGrid
            app.ConfirmEditionButtonGrid = uigridlayout(app.GridLayout);
            app.ConfirmEditionButtonGrid.ColumnWidth = {'1x'};
            app.ConfirmEditionButtonGrid.RowHeight = {'1x'};
            app.ConfirmEditionButtonGrid.Padding = [0 10 0 10];
            app.ConfirmEditionButtonGrid.Visible = 'off';
            app.ConfirmEditionButtonGrid.Layout.Row = [14 15];
            app.ConfirmEditionButtonGrid.Layout.Column = [5 7];
            app.ConfirmEditionButtonGrid.BackgroundColor = [1 1 1];

            % Create ConfirmEditionButton
            app.ConfirmEditionButton = uibutton(app.ConfirmEditionButtonGrid, 'push');
            app.ConfirmEditionButton.ButtonPushedFcn = createCallbackFcn(app, @toolButtonPushed_edit, true);
            app.ConfirmEditionButton.Icon = 'play-16px-white.svg';
            app.ConfirmEditionButton.BackgroundColor = [0 0.451 0.7412];
            app.ConfirmEditionButton.FontSize = 11;
            app.ConfirmEditionButton.FontColor = [1 1 1];
            app.ConfirmEditionButton.Layout.Row = 1;
            app.ConfirmEditionButton.Layout.Column = 1;
            app.ConfirmEditionButton.Text = 'Iniciar servidor';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [6 9];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create DockUndockButton
            app.DockUndockButton = uiimage(app.DockModule);
            app.DockUndockButton.ScaleMethod = 'none';
            app.DockUndockButton.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.DockUndockButton.Enable = 'off';
            app.DockUndockButton.Layout.Row = 1;
            app.DockUndockButton.Layout.Column = 1;
            app.DockUndockButton.ImageSource = 'Undock_18White.png';

            % Create DockCloseButton
            app.DockCloseButton = uiimage(app.DockModule);
            app.DockCloseButton.ScaleMethod = 'none';
            app.DockCloseButton.ImageClickedFcn = createCallbackFcn(app, @onDockModuleGroupButtonClicked, true);
            app.DockCloseButton.Layout.Row = 1;
            app.DockCloseButton.Layout.Column = 2;
            app.DockCloseButton.ImageSource = 'Delete_12SVG_white.svg';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winServer_exported(Container, varargin)

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
