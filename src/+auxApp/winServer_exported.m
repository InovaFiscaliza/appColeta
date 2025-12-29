classdef winServer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        DockModule                 matlab.ui.container.GridLayout
        dockModule_Undock          matlab.ui.control.Image
        dockModule_Close           matlab.ui.control.Image
        SubTabGroup                matlab.ui.container.TabGroup
        SubTab1                    matlab.ui.container.Tab
        SubGrid1                   matlab.ui.container.GridLayout
        communicationTable         matlab.ui.control.Table
        communicationTableRefresh  matlab.ui.control.Image
        communicationTableLabel    matlab.ui.control.Label
        serverInfo                 matlab.ui.control.TextArea
        serverInfoLabel            matlab.ui.control.Label
        Toolbar                    matlab.ui.container.GridLayout
        toolButton_edit            matlab.ui.control.Button
        toolLampLabel              matlab.ui.control.Label
        toolLamp                   matlab.ui.control.Lamp
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
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
                        error('UnexpectedEvent')
                end

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
            end
        end

        %-----------------------------------------------------------------%
        function applyJSCustomizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = zeros(1, numel(app.SubTabGroup.Children), 'logical');
            end

            if customizationStatus(tabIndex)
                return
            end

            customizationStatus(tabIndex) = true;
            switch tabIndex
                case 1
                    % ...

                otherwise
                    % Previsto pensando em evolução, caso adicionado uitab
                    % ao app.SubTabGrid...
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            % ...
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
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
                app.serverInfo.Value = '';
                app.communicationTableRefresh.Visible = 0;

                app.toolLamp.Color = [.64 .08 .18];
                app.toolLampLabel.Text = 'Servidor não está em execução.';

                app.communicationTable.Data = table('Size', [0, 8],                                                                                    ...
                                               'VariableTypes', {'string', 'string', 'double', 'string', 'string', 'string', 'double', 'string'}, ...
                                               'VariableNames', {'Timestamp', 'ClientAddress', 'ClientPort', 'Message', 'ClientName', 'Request', 'NumBytesWritten', 'Status'});
                set(app.toolButton_edit, 'Text', 'Iniciar servidor', 'Icon', 'play_32.png')

            elseif isempty(app.mainApp.tcpServer.Server)
                app.serverInfo.Value = '';
                app.communicationTableRefresh.Visible = 0;

                app.toolLamp.Color = [.5 .5 .5];
                app.toolLampLabel.Text = sprintf('Servidor ainda não está em execução, apesar do objeto "class.tcpServerLib" já ter sido criado. Será realizada uma nova tentativa para executá-lo a cada %d segundos.', class.Constants.tcpServerPeriod);

                app.communicationTable.Data = app.mainApp.tcpServer.LOG;
                set(app.toolButton_edit, 'Text', 'Excluir objeto', 'Icon', 'Delete_32Red.png')

            else
                app.serverInfo.Value = util.HtmlTextGenerator.Server(app.mainApp.tcpServer);
                app.communicationTableRefresh.Visible = 1;

                app.toolLamp.Color = [.47 .67 .19];
                app.toolLampLabel.Text = sprintf('Servidor em execução desde %s.', char(app.mainApp.tcpServer.Time));

                app.communicationTable.Data = app.mainApp.tcpServer.LOG;
                set(app.toolButton_edit, 'Text', 'Parar servidor', 'Icon', 'stop_32.png')
            end
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

            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'SERVER')
            delete(app)
            
        end

        % Button pushed function: toolButton_edit
        function toolButtonPushed_edit(app, event)
            
            if isempty(app.mainApp.tcpServer)
                app.mainApp.tcpServer = class.tcpServerLib(app.mainApp);
            
            else
                stop(app.mainApp.tcpServer.Timer)
                delete(app.mainApp.tcpServer.Timer)
                delete(app.mainApp.tcpServer.Server)
                
                app.mainApp.tcpServer = [];
            end

            updateLayout(app)

        end

        % Image clicked function: communicationTableRefresh
        function communicationTableRefreshImageClicked(app, event)
            
            updateLayout(app)

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
            app.GridLayout.ColumnWidth = {10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {18, '1x', 110};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create toolLamp
            app.toolLamp = uilamp(app.Toolbar);
            app.toolLamp.Layout.Row = 1;
            app.toolLamp.Layout.Column = 1;
            app.toolLamp.Color = [0.4706 0.6706 0.1882];

            % Create toolLampLabel
            app.toolLampLabel = uilabel(app.Toolbar);
            app.toolLampLabel.FontSize = 11;
            app.toolLampLabel.Layout.Row = 1;
            app.toolLampLabel.Layout.Column = 2;
            app.toolLampLabel.Text = 'Desconectado';

            % Create toolButton_edit
            app.toolButton_edit = uibutton(app.Toolbar, 'push');
            app.toolButton_edit.ButtonPushedFcn = createCallbackFcn(app, @toolButtonPushed_edit, true);
            app.toolButton_edit.Icon = 'play_32.png';
            app.toolButton_edit.IconAlignment = 'right';
            app.toolButton_edit.HorizontalAlignment = 'right';
            app.toolButton_edit.BackgroundColor = [0.9412 0.9412 0.9412];
            app.toolButton_edit.FontSize = 11;
            app.toolButton_edit.Layout.Row = 1;
            app.toolButton_edit.Layout.Column = 3;
            app.toolButton_edit.Text = 'Iniciar servidor';

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.Layout.Row = [3 4];
            app.SubTabGroup.Layout.Column = [2 3];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'SERVIDOR';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {320, '1x', 18};
            app.SubGrid1.RowHeight = {17, 128, 22, '1x'};
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create serverInfoLabel
            app.serverInfoLabel = uilabel(app.SubGrid1);
            app.serverInfoLabel.VerticalAlignment = 'bottom';
            app.serverInfoLabel.FontSize = 10;
            app.serverInfoLabel.Layout.Row = 1;
            app.serverInfoLabel.Layout.Column = 1;
            app.serverInfoLabel.Text = 'CARACTERÍSTICAS:';

            % Create serverInfo
            app.serverInfo = uitextarea(app.SubGrid1);
            app.serverInfo.Editable = 'off';
            app.serverInfo.FontSize = 11;
            app.serverInfo.Layout.Row = 2;
            app.serverInfo.Layout.Column = [1 3];

            % Create communicationTableLabel
            app.communicationTableLabel = uilabel(app.SubGrid1);
            app.communicationTableLabel.VerticalAlignment = 'bottom';
            app.communicationTableLabel.FontSize = 10;
            app.communicationTableLabel.Layout.Row = 3;
            app.communicationTableLabel.Layout.Column = 1;
            app.communicationTableLabel.Text = 'COMUNICAÇÃO:';

            % Create communicationTableRefresh
            app.communicationTableRefresh = uiimage(app.SubGrid1);
            app.communicationTableRefresh.ScaleMethod = 'none';
            app.communicationTableRefresh.ImageClickedFcn = createCallbackFcn(app, @communicationTableRefreshImageClicked, true);
            app.communicationTableRefresh.Tooltip = {'Atualiza registro de comunicação'};
            app.communicationTableRefresh.Layout.Row = 3;
            app.communicationTableRefresh.Layout.Column = 3;
            app.communicationTableRefresh.HorizontalAlignment = 'left';
            app.communicationTableRefresh.VerticalAlignment = 'bottom';
            app.communicationTableRefresh.ImageSource = 'Refresh_18.png';

            % Create communicationTable
            app.communicationTable = uitable(app.SubGrid1);
            app.communicationTable.ColumnName = {'INSTANTE'; 'IP'; 'PORTA'; 'MENSAGEM'; 'CLIENTE'; 'REQUISIÇÃO'; 'BYTES'; 'ESTADO'};
            app.communicationTable.RowName = {};
            app.communicationTable.Layout.Row = 4;
            app.communicationTable.Layout.Column = [1 3];
            app.communicationTable.FontSize = 10;

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 3];
            app.DockModule.Layout.Column = [3 4];
            app.DockModule.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModule);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.DockModule);
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
