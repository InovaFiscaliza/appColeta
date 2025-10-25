classdef winServer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure              matlab.ui.Figure
        GridLayout            matlab.ui.container.GridLayout
        MainPanelGrid         matlab.ui.container.GridLayout
        UITable               matlab.ui.control.Table
        general_refresh       matlab.ui.control.Image
        general_versionPanel  matlab.ui.container.Panel
        general_versionGrid   matlab.ui.container.GridLayout
        general_version       matlab.ui.control.HTML
        Tab1_GridTitle        matlab.ui.container.GridLayout
        Tab1_Title            matlab.ui.control.Label
        Tab1_Image            matlab.ui.control.Image
        toolGrid              matlab.ui.container.GridLayout
        jsBackDoor            matlab.ui.control.HTML
        toolButton_edit       matlab.ui.control.Button
        toolLampLabel         matlab.ui.control.Label
        toolLamp              matlab.ui.control.Lamp
    end

    
    properties
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        
        mainApp
        rootFolder

        timerObj

        tcpServer
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR: CUSTOMIZAÇÃO GUI (ESTÉTICA/COMPORTAMENTAL)
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            if app.isDocked
                delete(app.jsBackDoor)
                app.jsBackDoor = app.mainApp.jsBackDoor;
            else
                app.jsBackDoor.HTMLSource = appUtil.jsBackDoorHTMLSource();
            end            
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app)
            if ~app.isDocked
                sendEventToHTMLSource(app.jsBackDoor, 'htmlClassCustomization', struct('className',        '.mw-theme-light',                                                   ...
                                                                                       'classAttributes', ['--mw-backgroundColor-dataWidget-selected: rgb(180 222 255 / 45%); ' ...
                                                                                                           '--mw-backgroundColor-selected: rgb(180 222 255 / 45%); '            ...
                                                                                                           '--mw-backgroundColor-selectedFocus: rgb(180 222 255 / 45%);']));
    
                sendEventToHTMLSource(app.jsBackDoor, 'htmlClassCustomization', struct('className',        '.mw-default-header-cell', ...
                                                                                       'classAttributes',  'font-size: 10px; white-space: pre-wrap; margin-bottom: 5px;'));
            end
        end
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO
        %-----------------------------------------------------------------%
        function startup_timerCreation(app)            
            % A criação desse timer tem como objetivo garantir uma renderização 
            % mais rápida dos componentes principais da GUI, possibilitando a 
            % visualização da sua tela inicialpelo usuário. Trata-se de aspecto 
            % essencial quando o app é compilado como webapp.

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

                startup_Controller(app)
            end
        end

        %-----------------------------------------------------------------%
        function startup_Controller(app)
            drawnow

            % Customiza as aspectos estéticos de alguns dos componentes da GUI 
            % (diretamente em JS).
            jsBackDoor_Customizations(app)
            
            Layout(app)
        end

        %-----------------------------------------------------------------%
        function Layout(app)
            app.tcpServer = app.mainApp.tcpServer;

            if isempty(app.tcpServer)
                app.general_version.HTMLSource = ' ';
                app.general_refresh.Visible = 0;

                app.toolLamp.Color = [.64 .08 .18];
                app.toolLampLabel.Text = 'Servidor não está em execução.';

                app.UITable.Data = table('Size', [0, 8],                                                                                    ...
                                               'VariableTypes', {'string', 'string', 'double', 'string', 'string', 'string', 'double', 'string'}, ...
                                               'VariableNames', {'Timestamp', 'ClientAddress', 'ClientPort', 'Message', 'ClientName', 'Request', 'NumBytesWritten', 'Status'});
                set(app.toolButton_edit, Text='Iniciar servidor', Icon='play_32.png')

            elseif isempty(app.tcpServer.Server)
                app.general_version.HTMLSource = ' ';
                app.general_refresh.Visible = 0;

                app.toolLamp.Color = [.5 .5 .5];
                app.toolLampLabel.Text = sprintf('Servidor ainda não está em execução, apesar do objeto "class.tcpServerLib" já ter sido criado. Será realizada uma nova tentativa para executá-lo a cada %d segundos.', class.Constants.tcpServerPeriod);

                app.UITable.Data = app.tcpServer.LOG;
                set(app.toolButton_edit, Text='Excluir objeto', Icon='Delete_32Red.png')

            else
                verMetaData(1).group = 'CARACTERÍSTICAS';
                verMetaData(1).value = struct('ServerAddress',     app.tcpServer.Server.ServerAddress,     ...
                                              'ServerPort',        app.tcpServer.Server.ServerPort,        ...
                                              'Connected',         app.tcpServer.Server.Connected,         ...
                                              'ClientAddress',     app.tcpServer.Server.ClientAddress,     ...
                                              'ClientPort',        app.tcpServer.Server.ClientPort,        ...
                                              'NumBytesAvailable', app.tcpServer.Server.NumBytesAvailable, ...
                                              'Timeout',           app.tcpServer.Server.Timeout,           ...
                                              'ByteOrder',         app.tcpServer.Server.ByteOrder,         ...
                                              'Terminator',        app.tcpServer.Server.Terminator,        ...
                                              'NumBytesWritten',   app.tcpServer.Server.NumBytesWritten);

                app.general_version.HTMLSource = textFormatGUI.struct2PrettyPrintList(verMetaData);
                app.general_refresh.Visible = 1;

                app.toolLamp.Color = [.47 .67 .19];
                app.toolLampLabel.Text = sprintf('Servidor em execução desde %s.', char(app.tcpServer.Time));

                app.UITable.Data = app.tcpServer.LOG;
                set(app.toolButton_edit, Text='Parar servidor', Icon='stop_32.png')
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp)
            
            app.mainApp    = mainApp;
            app.rootFolder = mainApp.rootFolder;

            jsBackDoor_Initialization(app)

            if app.isDocked
                app.GridLayout.Padding(4) = 21;
                startup_Controller(app)
            else
                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)
            end
            
        end

        % Close request function: UIFigure
        function closeFcn(app, event)

            appBackDoor(app.mainApp, app, 'closeFcn', 'SERVER')
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

            Layout(app)

        end

        % Image clicked function: general_refresh
        function general_refreshImageClicked(app, event)
            
            Layout(app)

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

            % Create toolGrid
            app.toolGrid = uigridlayout(app.GridLayout);
            app.toolGrid.ColumnWidth = {18, '1x', 22, 110};
            app.toolGrid.RowHeight = {'1x'};
            app.toolGrid.ColumnSpacing = 5;
            app.toolGrid.Padding = [5 6 5 6];
            app.toolGrid.Layout.Row = 2;
            app.toolGrid.Layout.Column = 1;
            app.toolGrid.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create toolLamp
            app.toolLamp = uilamp(app.toolGrid);
            app.toolLamp.Layout.Row = 1;
            app.toolLamp.Layout.Column = 1;
            app.toolLamp.Color = [0.4706 0.6706 0.1882];

            % Create toolLampLabel
            app.toolLampLabel = uilabel(app.toolGrid);
            app.toolLampLabel.FontSize = 11;
            app.toolLampLabel.Layout.Row = 1;
            app.toolLampLabel.Layout.Column = 2;
            app.toolLampLabel.Text = 'Desconectado';

            % Create toolButton_edit
            app.toolButton_edit = uibutton(app.toolGrid, 'push');
            app.toolButton_edit.ButtonPushedFcn = createCallbackFcn(app, @toolButtonPushed_edit, true);
            app.toolButton_edit.Icon = 'play_32.png';
            app.toolButton_edit.IconAlignment = 'right';
            app.toolButton_edit.HorizontalAlignment = 'right';
            app.toolButton_edit.BackgroundColor = [1 1 1];
            app.toolButton_edit.FontSize = 11;
            app.toolButton_edit.Layout.Row = 1;
            app.toolButton_edit.Layout.Column = 4;
            app.toolButton_edit.Text = 'Iniciar servidor';

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.toolGrid);
            app.jsBackDoor.Layout.Row = 1;
            app.jsBackDoor.Layout.Column = 3;

            % Create MainPanelGrid
            app.MainPanelGrid = uigridlayout(app.GridLayout);
            app.MainPanelGrid.ColumnWidth = {325, '1x', 16};
            app.MainPanelGrid.RowHeight = {22, 128, 22, '1x'};
            app.MainPanelGrid.RowSpacing = 5;
            app.MainPanelGrid.Padding = [5 5 5 5];
            app.MainPanelGrid.Layout.Row = 1;
            app.MainPanelGrid.Layout.Column = 1;
            app.MainPanelGrid.BackgroundColor = [1 1 1];

            % Create Tab1_GridTitle
            app.Tab1_GridTitle = uigridlayout(app.MainPanelGrid);
            app.Tab1_GridTitle.ColumnWidth = {18, '1x'};
            app.Tab1_GridTitle.RowHeight = {'1x'};
            app.Tab1_GridTitle.ColumnSpacing = 5;
            app.Tab1_GridTitle.RowSpacing = 5;
            app.Tab1_GridTitle.Padding = [2 2 2 2];
            app.Tab1_GridTitle.Tag = 'COLORLOCKED';
            app.Tab1_GridTitle.Layout.Row = 1;
            app.Tab1_GridTitle.Layout.Column = 1;
            app.Tab1_GridTitle.BackgroundColor = [0.749 0.749 0.749];

            % Create Tab1_Image
            app.Tab1_Image = uiimage(app.Tab1_GridTitle);
            app.Tab1_Image.Layout.Row = 1;
            app.Tab1_Image.Layout.Column = 1;
            app.Tab1_Image.HorizontalAlignment = 'left';
            app.Tab1_Image.ImageSource = 'Server_36.png';

            % Create Tab1_Title
            app.Tab1_Title = uilabel(app.Tab1_GridTitle);
            app.Tab1_Title.FontSize = 11;
            app.Tab1_Title.Layout.Row = 1;
            app.Tab1_Title.Layout.Column = 2;
            app.Tab1_Title.Text = 'SERVIDOR';

            % Create general_versionPanel
            app.general_versionPanel = uipanel(app.MainPanelGrid);
            app.general_versionPanel.AutoResizeChildren = 'off';
            app.general_versionPanel.BackgroundColor = [1 1 1];
            app.general_versionPanel.Layout.Row = [2 3];
            app.general_versionPanel.Layout.Column = 1;

            % Create general_versionGrid
            app.general_versionGrid = uigridlayout(app.general_versionPanel);
            app.general_versionGrid.ColumnWidth = {'1x'};
            app.general_versionGrid.RowHeight = {'1x'};
            app.general_versionGrid.ColumnSpacing = 0;
            app.general_versionGrid.RowSpacing = 0;
            app.general_versionGrid.Padding = [0 0 0 0];
            app.general_versionGrid.BackgroundColor = [1 1 1];

            % Create general_version
            app.general_version = uihtml(app.general_versionGrid);
            app.general_version.Layout.Row = 1;
            app.general_version.Layout.Column = 1;

            % Create general_refresh
            app.general_refresh = uiimage(app.MainPanelGrid);
            app.general_refresh.ScaleMethod = 'none';
            app.general_refresh.ImageClickedFcn = createCallbackFcn(app, @general_refreshImageClicked, true);
            app.general_refresh.Layout.Row = 3;
            app.general_refresh.Layout.Column = 3;
            app.general_refresh.HorizontalAlignment = 'left';
            app.general_refresh.VerticalAlignment = 'bottom';
            app.general_refresh.ImageSource = 'Refresh_18.png';

            % Create UITable
            app.UITable = uitable(app.MainPanelGrid);
            app.UITable.ColumnName = {'INSTANTE'; 'IP'; 'PORTA'; 'MENSAGEM'; 'CLIENTE'; 'REQUISIÇÃO'; 'BYTES'; 'ESTADO'};
            app.UITable.RowName = {};
            app.UITable.Layout.Row = 4;
            app.UITable.Layout.Column = [1 3];
            app.UITable.FontSize = 10;

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
