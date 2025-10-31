classdef winAppColeta_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        GridLayout             matlab.ui.container.GridLayout
        popupContainerGrid     matlab.ui.container.GridLayout
        SplashScreen           matlab.ui.control.Image
        menu_Grid              matlab.ui.container.GridLayout
        FigurePosition         matlab.ui.control.Image
        AppInfo                matlab.ui.control.Image
        menu_AppIcon           matlab.ui.control.Image
        menu_AppName           matlab.ui.control.Label
        jsBackDoor             matlab.ui.control.HTML
        menu_Button6           matlab.ui.control.StateButton
        menu_Button5           matlab.ui.control.StateButton
        menu_Separator2        matlab.ui.control.Image
        menu_Button4           matlab.ui.control.StateButton
        menu_Button3           matlab.ui.control.StateButton
        menu_Button2           matlab.ui.control.StateButton
        menu_Separator1        matlab.ui.control.Image
        menu_Button1           matlab.ui.control.StateButton
        TabGroup               matlab.ui.container.TabGroup
        Tab1_Task              matlab.ui.container.Tab
        Tab1Grid               matlab.ui.container.GridLayout
        task_toolGrid          matlab.ui.container.GridLayout
        tool_RevisitTime       matlab.ui.control.Label
        tool_ButtonLOG         matlab.ui.control.Image
        tool_Separator         matlab.ui.control.Image
        tool_ButtonDel         matlab.ui.control.Image
        tool_ButtonPlay        matlab.ui.control.Image
        tool_LeftPanel         matlab.ui.control.Image
        task_docGrid           matlab.ui.container.GridLayout
        MetaData               matlab.ui.control.Label
        DropDown               matlab.ui.control.DropDown
        FAIXADEFREQUNCIALabel  matlab.ui.control.Label
        play_axesToolbar       matlab.ui.container.GridLayout
        axesTool_MinHold_2     matlab.ui.control.Image
        axesTool_PlotSource    matlab.ui.control.DropDown
        axesTool_Waterfall     matlab.ui.control.Image
        axesTool_Peak          matlab.ui.control.Image
        axesTool_MaxHold       matlab.ui.control.Image
        axesTool_Average       matlab.ui.control.Image
        axesTool_MinHold       matlab.ui.control.Image
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
        Table                  matlab.ui.control.Table
        Tab2_InstrumentList    matlab.ui.container.Tab
        Tab3_TaskEdition       matlab.ui.container.Tab
        Tab4_TaskAdd           matlab.ui.container.Tab
        Tab5_Server            matlab.ui.container.Tab
        Tab6_Config            matlab.ui.container.Tab
    end

    
    properties (Access = public)
        %-----------------------------------------------------------------%
        % PROPRIEDADES COMUNS A TODOS OS APPS
        %-----------------------------------------------------------------%
        General
        General_I

        rootFolder

        % Essa propriedade registra o tipo de execução da aplicação, podendo
        % ser: 'built-in', 'desktopApp' ou 'webApp'.
        executionMode

        % A função do timer é executada uma única vez após a renderização
        % da figura, lendo arquivos de configuração, iniciando modo de operação
        % paralelo etc. A ideia é deixar o MATLAB focar apenas na criação dos 
        % componentes essenciais da GUI (especificados em "createComponents"), 
        % mostrando a GUI para o usuário o mais rápido possível.
        timerObj

        % Controla a seleção da TabGroup a partir do menu.
        tabGroupController
        renderCount = 0

        % Janela de progresso já criada no DOM. Dessa forma, controla-se 
        % apenas a sua visibilidade - e tornando desnecessário criá-la a
        % cada chamada (usando uiprogressdlg, por exemplo).
        progressDialog
        popupContainer

        %-----------------------------------------------------------------%
        % PROPRIEDADES ESPECÍFICAS
        %-----------------------------------------------------------------%
        specObj
        revisitObj
        timerObj_task
        taskList

        Flag_running = 0
        Flag_editing = 0
        plotStyleEditing = 0

        %-----------------------------------------------------------------%
        % PLOT
        %-----------------------------------------------------------------%
        axes1
        axes2
        restoreView = struct('ID', {}, 'xLim', {}, 'yLim', {}, 'cLim', {})
        
        line_ClrWrite
        line_MinHold
        line_Average
        line_MaxHold
        peakExcursion
        surface_WFall

        %-----------------------------------------------------------------%
        % COMMUNICATION
        %-----------------------------------------------------------------%
        tcpServer
        
        receiverObj
        gpsObj
        udpPortArray = {}

        EB500Obj
        EMSatObj
        ERMxObj
    end


    methods
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
                    % JSBACKDOOR (compCustomization.js)
                    case 'renderer'
                        if ~app.renderCount
                            startup_Controller(app)
                        else
                            % Esse fluxo será executado especificamente na
                            % versão webapp, quando o navegador atualiza a
                            % página (decorrente de F5 ou CTRL+F5).

                            if ~app.menu_Button1.Value
                                app.menu_Button1.Value = true;                    
                                menu_mainButtonPushed(app, struct('Source', app.menu_Button1, 'PreviousValue', false))
                                drawnow
                            end

                            closeModule(app.tabGroupController, ["INSTRUMENT", "TASK:EDIT", "TASK:ADD", "SERVER", "CONFIG"], app.General)
    
                            if ~isempty(app.AppInfo.Tag)
                                app.AppInfo.Tag = '';
                            end

                            startup_Controller(app)

                            app.progressDialog.Visible = 'hidden';
                        end
                        
                        app.renderCount = app.renderCount+1;

                    case 'unload'
                        closeFcn(app)

                    case 'BackgroundColorTurnedInvisible'
                        switch event.HTMLEventData
                            case 'SplashScreen'
                                if isvalid(app.popupContainerGrid)
                                    delete(app.popupContainerGrid)
                                end

                            otherwise
                                error('UnexpectedEvent')
                        end
                    
                    case 'customForm'
                        switch event.HTMLEventData.uuid
                            case 'eFiscalizaSignInPage'
                                report_uploadInfoController(app, event.HTMLEventData, 'uploadDocument', event.HTMLEventData.context)

                            case 'openDevTools'
                                if isequal(app.General.operationMode.DevTools, rmfield(event.HTMLEventData, 'uuid'))
                                    webWin = struct(struct(struct(app.UIFigure).Controller).PlatformHost).CEF;
                                    webWin.openDevTools();
                                end
                        end

                    case 'getNavigatorBasicInformation'
                        app.General.AppVersion.browser = event.HTMLEventData;

                    % MAINAPP
                    case 'mainApp.file_Tree'
                        file_ContextMenu_delTreeNodeSelected(app)

                    % AUXAPP.WINEXTERNALREQUEST
                    case 'auxApp.winExternalRequest.TreePoints'
                        ipcMainMatlabCallAuxiliarApp(app, 'EXTERNALREQUEST', 'JS', event)

                    otherwise
                        error('UnexpectedEvent')
                end
                drawnow

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end
        end

        %-----------------------------------------------------------------%
        function varargout = ipcMainMatlabCallsHandler(app, callingApp, operationType, varargin)
            varargout = {};

            try
                switch operationType
                    case 'closeFcn'
                        auxAppTag    = varargin{1};
                        closeModule(app.tabGroupController, auxAppTag, app.General)

                    case 'dockButtonPushed'
                        auxAppTag    = varargin{1};
                        varargout{1} = auxAppInputArguments(app, auxAppTag);
                    
                    case 'openDevTools'
                        dialogBox    = struct('id', 'login',    'label', 'Usuário: ', 'type', 'text');
                        dialogBox(2) = struct('id', 'password', 'label', 'Senha: ',   'type', 'password');
                        sendEventToHTMLSource(app.jsBackDoor, 'customForm', struct('UUID', 'openDevTools', 'Fields', dialogBox))

                    case 'AddOrEditTask'
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
                                appUtil.modalWindow(app.UIFigure, 'warning', msgError);
                            end
                        catch ME
                            struct2table(ME.stack)
                        end

                    case 'AxesTileSpacingChanged'
                        tileSpacing = varargin{1};
                        app.axes1.Parent.TileSpacing = tileSpacing;

                    case 'PlotColorChanged'
                        plotTag = varargin{1};
                        if ~isempty(eval(['app.line_' plotTag]))
                            app.plotStyleEditing = 1;
                        end

                    case 'WaterfallColormapChanged'
                        waterfallColormap = varargin{1};
                        colormap(app.axes2, waterfallColormap)

                    otherwise
                        error('Unexpected call "%s" from %s', operationType, class(callingApp))
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);            
            end

            % Caso um app auxiliar esteja em modo DOCK, o progressDialog do
            % app auxiliar coincide com o do appAnalise. Força-se, portanto, 
            % a condição abaixo para evitar possível bloqueio da tela.
            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabCallAuxiliarApp(app, auxAppName, communicationType, varargin)
            hAuxApp = auxAppHandle(app, auxAppName);

            if ~isempty(hAuxApp)
                switch communicationType
                    case 'MATLAB'
                        operationType = varargin{1};
                        ipcSecundaryMatlabCallsHandler(hAuxApp, app, operationType, varargin{2:end});
                    case 'JS'
                        event = varargin{1};
                        ipcSecundaryJSEventsHandler(hAuxApp, event)
                end
            end
        end

        %-----------------------------------------------------------------%
        function ipcMainMatlabOpenPopupApp(app, auxiliarApp, varargin)
            arguments
                app
                auxiliarApp char {mustBeMember(auxiliarApp, {'Tracking'})}
            end

            arguments (Repeating)
                varargin 
            end

            switch auxAppName
                case 'Tracking'
                    screenWidth  = 622;
                    screenHeight = 302;
                otherwise
                    % ...
            end

            ui.PopUpContainer(app, class.Constants.appName, screenWidth, screenHeight)

            % Executa o app auxiliar.
            inputArguments = [{app.mainApp}, varargin];
            
            if app.General.operationMode.Debug
                eval(sprintf('auxApp.dock%s(inputArguments{:})', auxiliarApp))
            else
                eval(sprintf('auxApp.dock%s_exported(app.popupContainer, inputArguments{:})', auxiliarApp))
                app.popupContainer.Parent.Visible = 1;
            end            
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app)
            app.jsBackDoor.HTMLSource           = ccTools.fcn.jsBackDoorHTMLSource;
            app.jsBackDoor.HTMLEventReceivedFcn = @(~, evt)ipcMainJSEventsHandler(app, evt);
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_AppCustomizations(app, tabIndex)
            persistent customizationStatus
            if isempty(customizationStatus)
                customizationStatus = [false, false, false, false, false, false];
            end

            switch tabIndex
                case 0 % STARTUP
                    sendEventToHTMLSource(app.jsBackDoor, 'startup', app.executionMode);
                    customizationStatus = [false, false, false, false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1
                            elToModify = { ...
                                app.popupContainerGrid, ...
                                app.MetaData, ...
                                app.play_axesToolbar ...
                            };
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);

                            appName = class(app);
                            if isvalid(app.popupContainerGrid)
                                try
                                    sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('backgroundColor', 'rgba(255,255,255,0.65)'))});
                                catch
                                end
                            end

                            try
                                ui.TextView.startup(app.jsBackDoor, elToModify{2}, appName);
                            catch
                            end

                            try
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', {struct('appName', appName, 'dataTag', elDataTag{3}, 'styleImportant', struct('borderTopLeftRadius', '0', 'borderTopRightRadius', '0'))});
                            catch
                            end

                        otherwise
                            % Customização dos módulos que são renderizados
                            % nesta figura são controladas pelos próprios
                            % módulos.
                    end
            end
        end
    end

    
    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO DO APP
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

            if ~app.renderCount
                % Essa propriedade registra o tipo de execução da aplicação, podendo
                % ser: 'built-in', 'desktopApp' ou 'webApp'.
                app.executionMode  = appUtil.ExecutionMode(app.UIFigure);
                if ~strcmp(app.executionMode, 'webApp')
                    app.FigurePosition.Visible = 1;
                    appUtil.winMinSize(app.UIFigure, class.Constants.windowMinSize)
                end

                % Identifica o local deste arquivo .MLAPP, caso se trate das versões 
                % "built-in" ou "webapp", ou do .EXE relacionado, caso se trate da
                % versão executável (neste caso, o ctfroot indicará o local do .MLAPP).    
                appName = class.Constants.appName;
                MFilePath = fileparts(mfilename('fullpath'));
                app.rootFolder = appUtil.RootFolder(appName, MFilePath);
    
                % Customizações...
                jsBackDoor_AppCustomizations(app, 0)
                jsBackDoor_AppCustomizations(app, 1)
                pause(.100)

                % Cria tela de progresso...
                app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);

                startup_ConfigFileRead(app, appName, MFilePath)
                startup_AppProperties(app)
                startup_GUIComponents(app)
                
                RegularTask_timerCreation(app)
                if app.General.startupInfo
                    startup_specObjRead(app)
                end
    
                % Por fim, exclui-se o splashscreen, um segundo após envio do comando 
                % para que diminua a transparência do background.
                sendEventToHTMLSource(app.jsBackDoor, 'turningBackgroundColorInvisible', struct('componentName', 'SplashScreen', 'componentDataTag', struct(app.SplashScreen).Controller.ViewModel.Id));
                drawnow
            
                pause(1)
                delete(app.popupContainerGrid)

            else
                jsBackDoor_AppCustomizations(app, 0)
                jsBackDoor_AppCustomizations(app, 1)
                pause(.100)
            end
        end

        %-----------------------------------------------------------------%
        function startup_ConfigFileRead(app, appName, MFilePath)
            % "GeneralSettings.json"
            [app.General_I, msgWarning] = appUtil.generalSettingsLoad(appName, app.rootFolder);
            if ~isempty(msgWarning)
                appUtil.modalWindow(app.UIFigure, 'error', msgWarning);
            end

            % Para criação de arquivos temporários, cria-se uma pasta da 
            % sessão.
            tempDir = tempname;
            mkdir(tempDir)
            app.General_I.fileFolder.tempPath  = tempDir;
            app.General_I.fileFolder.MFilePath = MFilePath;

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
                    userPaths = appUtil.UserPaths(app.General_I.fileFolder.userPath);
                    app.General_I.fileFolder.userPath = userPaths{end};

                    switch app.executionMode
                        case 'desktopStandaloneApp'
                            app.General_I.operationMode.Debug = false;
                        case 'MATLABEnvironment'
                            app.General_I.operationMode.Debug = true;
                    end
            end

            app.General            = app.General_I;
            app.General.AppVersion = util.getAppVersion(app.rootFolder, MFilePath, tempDir);
            sendEventToHTMLSource(app.jsBackDoor, 'getNavigatorBasicInformation')
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            % app.taskList
            [app.taskList, msgError] =  class.taskList.file2raw(fullfile(app.rootFolder, 'config', 'taskList.json'), 'winAppColetaV2');
            if ~isempty(msgError)
                appUtil.modalWindow(app.UIFigure, 'error', msgError);
            end

            % Others...
            app.specObj     = class.specClass.empty;
            app.receiverObj = class.ReceiverLib(app.rootFolder);
            app.gpsObj      = class.GPSLib(app.rootFolder);            
            app.EB500Obj    = class.EB500Lib(app.rootFolder);
            app.EMSatObj    = class.EMSatLib(app.rootFolder);
            app.ERMxObj     = class.ERMxLib(app.rootFolder);            

            if app.General.tcpServer.Status
                try
                    app.tcpServer = class.tcpServerLib(app);
                catch
                    app.tcpServer = [];
                end
            end
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            % Cria o objeto que conecta o TabGroup com o GraphicMenu.
            app.tabGroupController = tabGroupGraphicMenu(app.menu_Grid, app.TabGroup, app.progressDialog, @app.jsBackDoor_AppCustomizations, '');

            addComponent(app.tabGroupController, "Built-in", "",                     app.menu_Button1, "AlwaysOn", struct('On', 'Playback_32Yellow.png', 'Off', 'Playback_32White.png'), matlab.graphics.GraphicsPlaceholder, 1)
            addComponent(app.tabGroupController, "External", "auxApp.winInstrument", app.menu_Button2, "AlwaysOn", struct('On', 'Connect_36Yellow.png',  'Off', 'Connect_36White.png'),  app.menu_Button1,                    2)
            addComponent(app.tabGroupController, "External", "auxApp.winTaskList",   app.menu_Button3, "AlwaysOn", struct('On', 'Task_36Yellow.png',     'Off', 'Task_36White.png'),     app.menu_Button1,                    3)
            addComponent(app.tabGroupController, "External", "auxApp.winAddTask",    app.menu_Button4, "AlwaysOn", struct('On', 'AddFile_36Yellow.png',  'Off', 'AddFile_36White.png'),  app.menu_Button1,                    4)
            addComponent(app.tabGroupController, "External", "auxApp.winServer",     app.menu_Button5, "AlwaysOn", struct('On', 'Server_36Yellow.png',   'Off', 'Server_36White.png'),   app.menu_Button1,                    5)
            addComponent(app.tabGroupController, "External", "auxApp.winConfig",     app.menu_Button6, "AlwaysOn", struct('On', 'Settings_36Yellow.png', 'Off', 'Settings_36White.png'), app.menu_Button1,                    6)

            app.axesTool_MinHold.UserData    = struct('id', '', 'status', false, 'icon', struct('On', 'MinHold_32Filled.png', 'Off', 'MinHold_32.png'));
            app.axesTool_Average.UserData    = struct('id', '', 'status', false, 'icon', struct('On', 'Average_32Filled.png', 'Off', 'Average_32.png'));
            app.axesTool_MaxHold.UserData    = struct('id', '', 'status', false, 'icon', struct('On', 'MaxHold_32Filled.png', 'Off', 'MaxHold_32.png'));
            app.axesTool_Peak.UserData       = struct('id', '', 'status', false);
            app.axesTool_Waterfall.UserData  = struct('id', '', 'status', false);

            startup_Axes(app)
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
            [~, programDataFolder] = appUtil.Path(class.Constants.appName, app.rootFolder);
            if isfile(fullfile(programDataFolder, 'startupInfo.mat'))
                app.progressDialog.Visible = 'visible';

                load(fullfile(programDataFolder, 'startupInfo.mat'), 'SpecObj');

                % É possível que o MATLAB não consiga instancionar o objeto
                % "class.specClass", lendo-o como "uint32", o que inviabiliza 
                % o aproveitamento da informação salva...

                % Warning: Variable 'SpecObj' originally saved as a class.specClass cannot be instantiated as an object and will be read in as a uint32.

                if exist('SpecObj', 'var') && isa(SpecObj, 'class.specClass') && ~isempty(SpecObj)
                    for ii = 1:numel(SpecObj)
                        SpecObj(ii) = startup_specObjRead_Receiver(app, SpecObj(ii));
                        SpecObj(ii) = startup_specObjRead_Streaming(app, SpecObj(ii));
                        SpecObj(ii) = startup_specObjRead_GPS(app, SpecObj(ii));

                        if ismember(SpecObj(ii).Status, {'Na fila', 'Em andamento'})
                            SpecObj(ii).Status = 'Erro';
                        end
                    end

                    app.specObj = SpecObj;
                    Layout_tableBuilding(app, 1)

                    % Ida ao modo de "Execução das tarefas da monitoração"
                    % de forma programática:
                    app.menu_Button1.Value = 1;
                    menu_mainButtonPushed(app, struct('Source', app.menu_Button1, 'PreviousValue', 0))
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
                SpecObj.Task.Receiver.Handle = app.receiverObj.Table.Handle{idx};
                SpecObj.hReceiver            = SpecObj.Task.Receiver.Handle;
            end
        end


        %-----------------------------------------------------------------%
        function SpecObj = startup_specObjRead_Streaming(app, SpecObj)

            receiverName = SpecObj.Task.Receiver.Selection.Name{1};
            taskType     = SpecObj.Task.Type;

            idx1 = SelectedReceiverIndex(app, receiverName, taskType);
            if ismember(app.receiverObj.Config.connectFlag(idx1), [2, 3])
                [app.udpPortArray, idx2] = fcn.udpSockets(app.udpPortArray, app.EB500Obj.udpPort);
                if ~isempty(idx2)
                    SpecObj.Task.Streaming.Handle = app.udpPortArray{idx2};
                    SpecObj.hStreaming            = SpecObj.Task.Streaming.Handle;
                end
            end
        end


        %-----------------------------------------------------------------%
        function [SpecObj, msgError] = startup_specObjRead_GPS(app, SpecObj)

            % Função funcionalmente idêntica à fcn.ConnectivityTest_GPS.
            % A "duplicação" garante que seja usado a informação constante
            % no objeto SpecObj, ao invés da informação constante no arquivo 
            % "instrumentList.json", que pode ter sido editado.

            msgError = '';

            if ~isempty(SpecObj.Task.GPS.Selection)
                instrSelected = struct('Type',       SpecObj.Task.GPS.Selection.Type{1}, ...
                                       'Parameters', jsondecode(SpecObj.Task.GPS.Selection.Parameters{1}));

                [idx2, msgError] = app.gpsObj.Connect(instrSelected);
                if isempty(msgError)
                    SpecObj.Task.GPS.Handle = app.gpsObj.Table.Handle{idx2};
                    SpecObj.GPS             = SpecObj.Task.GPS.Handle;
                end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % CHAVEANDO ENTRE MÓDULOS
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
        function idx = SelectedReceiverIndex(app, receiverName, taskType)
            idx = find(strcmp(app.receiverObj.Config.Name, receiverName));
            if numel(idx) > 1
                connectFlagList = app.receiverObj.Config.connectFlag(idx);
                if contains(taskType, 'Drive-test (Level+Azimuth)')
                    idx = idx(connectFlagList == 3);
                else
                    idx = idx(connectFlagList ~= 3);
                end
                idx = idx(1);
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
                    if RegularTask_StatusTaskCheck(app, ii, '')
                        Flag = true;
                        break
                    end
                end

                if Flag
                    RegularTask_MainLoop(app)
                end
            end

            if numel(app.specObj) ~= height(app.Table.Data)
                Layout_tableBuilding(app, app.Table.Selection)
            end
        end


        %-----------------------------------------------------------------%
        % REGULAR TASK
        %-----------------------------------------------------------------%
        function RegularTask_specObjSave(app)
            % Ao salvar "app.specObj" em um arquivo .MAT, reabrindo-o
            % posteriormente, os objetos de comunicação (tcpclient, por
            % exemplo) não retém o valor da propriedade "UserData".
            %
            % Por essa razão, esses objetos não serão salvos, devendo ser
            % recriados na inicialização do app.

            SpecObj = copy(app.specObj);
            
            for ii = 1:numel(SpecObj)
                SpecObj(ii).hReceiver  = [];
                SpecObj(ii).hStreaming = [];
                SpecObj(ii).hGPS       = [];

                SpecObj(ii).Task.Receiver.Handle  = [];
                SpecObj(ii).Task.Streaming.Handle = [];
                SpecObj(ii).Task.GPS.Handle       = [];
            end

            [~, programDataFolder] = appUtil.Path(class.Constants.appName, app.rootFolder);
            save(fullfile(programDataFolder, 'startupInfo.mat'), 'SpecObj')
        end


        %-----------------------------------------------------------------%
        function Flag = RegularTask_StatusTaskCheck(app, idx, evtName)
            % Função responsável por trocar o estado das tarefas, de "Na
            % fila" para "Em andamento", "Em andamento" para "Cancelada",
            % "Em andamento" para "Erro" e por aí vai...
            %
            % Lembrando que o estado de uma nova tarefa é "Na fila", exceto
            % quando ocorre algum erro no processo de criação (decorrente 
            % de uma configuração de um parâmetro não aceito pelo receptor,
            % por exemplo). Nesse caso, o estado será "Erro".
            %
            % Caso não exista alguma tarefa em execução, o app.Flag_running
            % será igual a 0, e o app.timerObj estará ativo, o que o fará
            % avaliar a cada minuto o estado de todas as tarefas, nesta 
            % função, de forma que:
            % (a) Seja iniciada uma tarefa no estado "Na fila";
            % (b) Seja realizada uma nova tentativa de iniciar uma tarefa 
            %     no estado "Erro" (o que ocorrerá a cada 15 minutos).
            
            Timestamp = datetime('now');

            Flag = false;
            initialStatus = app.specObj(idx).Status;
            
            switch app.specObj(idx).Status
                case 'Em andamento'
                    if app.specObj(idx).Observation.EndTime < Timestamp || ismember(evtName, {'DeleteButtonPushed', 'ErrorTrigger'})
                        Flag = true;

                        if app.specObj(idx).Observation.EndTime < Timestamp
                            app.specObj(idx).Status = 'Concluída';
                        else
                            switch evtName
                                case 'DeleteButtonPushed'
                                    app.specObj(idx).Status = 'Cancelada';
                                case 'ErrorTrigger'
                                    app.specObj(idx).Status = 'Erro';
                            end
                        end
                        
                        app.specObj(idx).hReceiver.UserData.nTasks = app.specObj(idx).hReceiver.UserData.nTasks-1;
                        app.specObj(idx).LOG(end+1) = struct('type', 'task', 'time', char(Timestamp), 'msg', sprintf('Alterado o estado da tarefa: Em andamento → %s.', app.specObj(idx).Status));

                        for ii = 1:numel(app.specObj(idx).Band)
                            app.specObj(idx) = class.RFlookBinLib.CloseFile(app.specObj(idx), ii);
                            app.specObj(idx).Band(ii).Status = false;
                        end

                    else
                        if strcmp(app.specObj(idx).Task.Script.Observation.Type, 'Samples')
                            tempFlag = [];                            
                            for ii = 1:numel(app.specObj(idx).Band)
                                if app.specObj(idx).Band(ii).Status
                                    if app.specObj(idx).Band(ii).nSweeps == app.specObj(idx).Task.Script.Band(ii).instrObservationSamples
                                        app.specObj(idx) = class.RFlookBinLib.CloseFile(app.specObj(idx), ii);
                                        app.specObj(idx).Band(ii).Status = false;
                                        tempFlag(end+1) = true;

                                    else
                                        tempFlag(end+1) = false;
                                    end
                                end
                            end

                            if all(tempFlag)
                                Flag = true;

                                app.specObj(idx).Status = 'Concluída';
                                app.specObj(idx).hReceiver.UserData.nTasks = app.specObj(idx).hReceiver.UserData.nTasks-1;
                                app.specObj(idx).Observation.EndTime = Timestamp;
                                app.specObj(idx).LOG(end+1) = struct('type', 'task', 'time', char(Timestamp), 'msg', sprintf('Alterado o estado da tarefa: Em andamento → %s.', app.specObj(idx).Status));

                            elseif any(tempFlag)
                                Flag = true;
                            end
                        end
                    end

                case {'Na fila', 'Erro'}
                    if strcmp(app.specObj(idx).Status, 'Erro') 
                        if isnat(app.specObj(idx).Observation.StartUp)
                            app.specObj(idx).Observation.StartUp = Timestamp;
                        end

                        StartUp = app.specObj(idx).Observation.StartUp;
                        if isequal([year(Timestamp), month(Timestamp), day(Timestamp), hour(Timestamp), minute(Timestamp)], ...
                                [year(StartUp), month(StartUp), day(StartUp), hour(StartUp), minute(StartUp)])
                            return
                        end
                    end

                    if app.specObj(idx).Observation.BeginTime < Timestamp
                        switch app.specObj(idx).Task.Script.Observation.Type
                            case {'Duration', 'Time'}
                                if isnat(app.specObj(idx).Observation.EndTime) || (app.specObj(idx).Observation.EndTime > Timestamp)
                                    Flag = true;
                                end

                            case 'Samples'
                                Flag = true;
                        end
                    end

                    if Flag
                        try
                            if strcmp(app.timerObj_task.Running, 'on')
                                stop(app.timerObj_task)
                            end
                            RegularTask_StartUp(app, idx);

                            app.specObj(idx).Status = 'Em andamento';
                            app.specObj(idx).hReceiver.UserData.nTasks   = app.specObj(idx).hReceiver.UserData.nTasks+1;
                            app.specObj(idx).hReceiver.UserData.SyncMode = app.specObj(idx).Task.Receiver.Sync;
                            app.specObj(idx).LOG(end+1) = struct('type', 'task', 'time', char(Timestamp), 'msg', 'Iniciada a execução da tarefa.');

                        catch ME
                            if strcmp(app.timerObj_task.Running, 'off') && ~app.Flag_running
                                start(app.timerObj_task)
                            end
                            app.specObj(idx).Status = 'Erro';
                            app.specObj(idx).LOG(end+1) = struct('type', 'error', 'time', char(Timestamp), 'msg', getReport(ME));

                            Flag = false;
                        end
                    end
            end

            if Flag
                Layout_tableBuilding(app, app.Table.Selection)
            end

            if ~strcmp(initialStatus, app.specObj(idx).Status)
                RegularTask_specObjSave(app)
            end
        end


        %-----------------------------------------------------------------%
        function RegularTask_RestartStatus(app, idx, nSweepsFlag)

            for ii = 1:numel(app.specObj(idx).Band)
                app.specObj(idx).Band(ii).SyncModeRef   = -1;
                app.specObj(idx).Band(ii).LastTimeStamp = [];
                app.specObj(idx).Band(ii).Status        = true;

                if nSweepsFlag
                    app.specObj(idx).Band(ii).nSweeps   = 0;
                end
            end
        end


        %-----------------------------------------------------------------%
        % Notas sobre a interface TCPCLIENT:
        % (a) Não existe uma função que retorna os objetos TCPCLIENT 
        %     (como instrfind p/ os objetos TCPIP). 
        % (b) Algumas chamadas a um objeto não mais válido (decorrente 
        %     de uma perda de conectividade, por exemplo) apresentam a 
        %     mensagem de erro na janela de comandos do Matlab, mesmo 
        %     "protegidos" num bloco try/catch. A execução não para, 
        %     mas imprimir a mensagem na janela de comandos é um 
        %     comportamento não esperado.
        % (c) A propriedade que indica que o objeto não mais está conectado 
        %     ao instrumento é privada, sendo acessível usando struct.
        % (d) A propriedade "UserData" se perde quando da reinicialização
        %     do app, sendo necessária criá-la novamente.
        %-----------------------------------------------------------------%


        %-----------------------------------------------------------------%
        function RegularTask_StartUp(app, idx)
            Task = app.specObj(idx).Task;
            
            % RECEIVER
            msgError = app.receiverObj.ReconnectAttempt(Instrument(app.specObj(idx)),                      ...
                                                        app.specObj(idx).Task.Receiver.Config.connectFlag, ...
                                                        app.specObj(idx).Task.Receiver.Config.StartUp{1},  ...
                                                        app.specObj(idx).Band(1).SpecificSCPI);
            if ~isempty(msgError)
                error(msgError)
            end
            hReceiver = app.specObj(idx).hReceiver;

            % STREAMING
            if isempty(app.specObj(idx).hStreaming)
                if ismember(Task.Receiver.Config.connectFlag, [2, 3])
                    app.specObj(idx) = startup_specObjRead_Streaming(app, app.specObj(idx));
                end
            else
                if contains(app.specObj(idx).IDN, 'EB500')                 && ...
                        ~contains(Task.Type, 'Drive-test (Level+Azimuth)') &&...
                        isempty(app.specObj(idx).Band(1).Datagrams)

                    hStreaming = app.specObj(idx).hStreaming;
                    app.specObj(idx) = class.EB500Lib.DatagramRead_PSCAN_PreTask(app.EB500Obj, app.specObj(idx), hReceiver, hStreaming);
                end
            end

            % GPS
            if isempty(app.specObj(idx).hGPS)
                if ~isempty(Task.GPS.Selection)
                    [app.specObj(idx), msgError] = startup_specObjRead_GPS(app, app.specObj(idx));
                    if ~isempty(msgError)
                        error(msgError)
                    end
                end
            end

            % ANTENNA TRACKING (EMSat)
            if strcmp(Task.Antenna.Switch.Name, 'EMSat')
                fcn.antennaTracking(app, Task.Antenna.MetaData, app.progressDialog);
            end

            % MASK, FILE & WATERFALL MATRIX
            baseName = sprintf('appColeta_%s', datestr(now, 'yymmdd_THHMMSS'));
            for ii = 1:numel(app.specObj(idx).Band)
                ID = Task.Script.Band(ii).ID;

                % ANTENNA SWITCH & ACU
                % Esse trecho do código consiste na tentativa de obter a posição 
                % da antena, inserindo-a no arquivo binário e apresentando no 
                % painel de metadados. 
                % 
                % Erros retornáveis:
                % - Caso não tenha sido desabilitado o Polling/Bus da ACU 
                % no Compass.
                % - Caso a ACU não esteja acessível ('MCL-3' e 'MCC-1' ainda
                % não possuem); e 'MKA-1' ainda não é controlável por falta
                % de conectividade de rede (o app não "enxerga" a ACU).
                %
                % Os erros não travam a execução do código pois a antena
                % pode ter sido apontada manualmente ou automaticamente - este
                % último poderia ter sido conduzido no momento de criação da 
                % tarefa (e posteriormente reabilitado o controle da ACU pelo 
                % Compass.
                if strcmp(Task.Antenna.Switch.Name, 'EMSat')
                    antennaName = extractBefore(Task.Script.Band(ii).instrAntenna, ' ');
                    [antennaPos, errorMsg] = app.EMSatObj.AntennaPositionGET(antennaName);
                    app.specObj(idx).Band(ii).Antenna.Position = jsonencode(antennaPos);

                    if ~isempty(errorMsg)
                        app.specObj(idx).LOG(end+1) = struct('type', 'startup', 'time', datestr(now), 'msg', sprintf('ID: %.0f\n%s ACU - %s', ID, antennaName, errorMsg));
                    end
                end

                % MASK
                app.specObj(idx).Band(ii).Mask = [];
                if contains(Task.Type, 'Rompimento de Máscara Espectral') && Task.Script.Band(ii).MaskTrigger.Status
                    maskInfo  = class.maskLib.FileRead(Task.MaskFile);
                    maskArray = class.maskLib.ArrayConstructor(maskInfo, Task.Script.Band(ii));

                    FindPeaks = Task.Script.Band(ii).MaskTrigger.FindPeaks;
                    if isempty(FindPeaks)
                        FindPeaks = class.Constants.FindPeaks;
                    end

                    app.specObj(idx).Band(ii).Mask = struct('Table', maskInfo.Table, 'Array', maskArray, 'Validations', 0, ...
                                                            'BrokenArray', zeros(1, Task.Script.Band(ii).instrDataPoints), ...
                                                            'BrokenCount', 0, 'Peaks', '', 'TimeStamp', NaT, 'FindPeaks', FindPeaks);
                    app.specObj(idx).LOG(end+1)    = struct('type', 'mask', 'time', datestr(now), 'msg', sprintf('ID %.0f\n%s', ID, jsonencode(maskInfo.Table)));
                end

                % FILE
                app.specObj(idx).Band(ii).File = struct('Fileversion', class.Constants.fileVersion,     ...
                                                        'Basename', sprintf('%s_ID%.0f', baseName, ID), ...
                                                        'Filecount', 0, 'WritedSamples', 0, 'CurrentFile', []);

                [app.specObj(idx).Band(ii).File.Filecount, ...
                    app.specObj(idx).Band(ii).File.CurrentFile] = class.RFlookBinLib.OpenFile(app.specObj(idx), ii, app.General.fileFolder.userPath);

                logMsg = sprintf(['ID: %.0f\n'             ...
                                  'scpiSet_Config: "%s"\n' ...
                                  'scpiSet_Att: "%s"\n'    ...
                                  'rawMetaData: "%s"\n'    ...
                                  'Filename (base): %s'], ID,                                               ...
                                                          app.specObj(idx).Band(ii).SpecificSCPI.configSET, ...
                                                          app.specObj(idx).Band(ii).SpecificSCPI.attSET,    ...
                                                          app.specObj(idx).Band(ii).rawMetaData,            ...
                                                          app.specObj(idx).Band(ii).File.Basename);                
                app.specObj(idx).LOG(end+1) = struct('type', 'startup', 'time', datestr(now), 'msg', logMsg);


                % WATERFALL MATRIX
                DataPoints     = Task.Script.Band(ii).instrDataPoints;
                WaterfallDepth = app.General.Plot.Waterfall.Depth;
                if strcmp(Task.Script.Observation.Type, 'Samples')
                    WaterfallDepth = min([WaterfallDepth, Task.Script.Band(ii).instrObservationSamples]);
                end              

                app.specObj(idx).Band(ii).Waterfall = struct('idx', 0, 'Depth', WaterfallDepth, 'Matrix', -1000 .* ones(WaterfallDepth, DataPoints, 'single'));
            end

            RegularTask_RestartStatus(app, idx, 0)
        end


        %-----------------------------------------------------------------%
        function RegularTask_MainLoop(app)
            app.Flag_running = 1;
            app.Flag_editing = 1;

            stop(app.timerObj_task)

            while app.Flag_running
                if app.Flag_editing
                    app.revisitObj = fcn.RevisitFactors(app.specObj);
                    Layout_metadataTab(app)

                    if isempty(app.revisitObj.GlobalRevisitTime)
                        app.Flag_running = 0;
                        break
                    end
                    
                    nn = 0;
                    app.Flag_editing = 0;
                end

                sweepTic = tic;
                for ii = 1:numel(app.specObj)
                    if RegularTask_StatusTaskCheck(app, ii, '')
                        app.Flag_editing = 1;
                        break
                    end

                    if ~strcmp(app.specObj(ii).Status, 'Em andamento')
                        continue
                    end

                    regularTask = ~contains(app.specObj(ii).Task.Type, 'PRÉVIA');
                    
                    hReceiver   = app.specObj(ii).hReceiver;
                    hStreaming  = app.specObj(ii).hStreaming;
                    hGPS        = app.specObj(ii).hGPS;

                    configMode  = true;

                    nBands = numel(app.specObj(ii).Band);    
                    for jj = 0:nBands
                        if mod(nn, app.revisitObj.Band(ii).RevisitFactors(jj+1)) || app.revisitObj.Band(ii).RevisitFactors(jj+1) == -1
                            continue
                        end
                        newTimeStamp = datetime('now');
    
                        if jj == 0
                            % A atualização das coordenadas geográficas do
                            % ponto de monitoração não precisa ser feita para 
                            % a tarefa "Drive-test (Level+Azimuth)" porque essa 
                            % tarefa já possui, no seu datagrama, a informação 
                            % das coordenadas.

                            if app.specObj(ii).Task.Receiver.Config.connectFlag ~= 3
                                RegularTask_gpsData(app, ii, hReceiver, hGPS, newTimeStamp);
                            end

                        else
                            app.specObj(ii) = class.RFlookBinLib.CheckFile(app.specObj(ii), jj, app.General.fileFolder.userPath);
                            
                            try
                                % ANTENNA SWITCH (IF APPLICABLE)
                                RegularTask_AntennaSwitch(app, ii, jj)

                                % RECEIVER RECONFIGURATION (IF APPLICABLE)
                                if (nBands > 1) || (hReceiver.UserData.nTasks > 1)
                                    if configMode
                                        if ismember(app.specObj(ii).Task.Receiver.Config.connectFlag, [2, 3])                                            
                                            class.EB500Lib.OperationMode(hReceiver, app.specObj(ii).Task.Receiver.Config.connectFlag)
                                        end
                                        configMode = false;
                                    end

                                    RegularTask_ConfigBand(app, ii, jj, hReceiver)
                                end

                                attFactor = -1;
                                if ~isempty(app.specObj(ii).GeneralSCPI.attGET)
                                % Bloco try/catch protege eventual erro, o que não causará dano à 
                                % monitoração em si por se tratar de informação não essencial.
                                    try
                                        attFactor = str2double(fcn.WriteRead(hReceiver, app.specObj(ii).GeneralSCPI.attGET));
                                    catch
                                    end
                                end

                                % maskTrigger: Variável local que registra se foi evidenciado rompimento da máscara espectral.
                                maskTrigger = 0;

                                if isempty(app.specObj(ii).Band(jj).Mask)
                                    % SINGLE TRACE
                                    newArray = RegularTask_specData(app, ii, jj, hReceiver, hStreaming, newTimeStamp);
                                    app.specObj(ii).Band(jj).nSweeps = app.specObj(ii).Band(jj).nSweeps+1;
                                
                                else
                                    % BURST OF TRACES
                                    nSweeps  = app.specObj(ii).Band(jj).Mask.FindPeaks.nSweeps;
                                    newArray = zeros(nSweeps, app.specObj(ii).Band(jj).DataPoints, 'single');                                    
                                    for kk = 1:nSweeps
                                        newArray(kk,:) = RegularTask_specData(app, ii, jj, hReceiver, hStreaming, newTimeStamp);
                                        app.specObj(ii).Band(jj).nSweeps = app.specObj(ii).Band(jj).nSweeps+1;
                                    end
                                    smoothedArray = mean(newArray, 1);

                                    % METADATA UPDATE
                                    app.specObj(ii).Band(jj).Mask.Validations = app.specObj(ii).Band(jj).Mask.Validations + 1;

                                    % MASK BROKEN ANALISYS                                    
                                    validationArray = (smoothedArray - app.specObj(ii).Band(jj).Mask.Array) > 0;
                                    if any(validationArray)
                                        app.specObj(ii).Band(jj).Mask.BrokenArray = app.specObj(ii).Band(jj).Mask.BrokenArray + validationArray;

                                        peaksTable = fcn.FindPeaks(app.specObj(ii), jj, smoothedArray, validationArray);
                                        if ~isempty(peaksTable)
                                            app.specObj(ii).Band(jj).Mask.BrokenCount = app.specObj(ii).Band(jj).Mask.BrokenCount + 1;
                                            app.specObj(ii).Band(jj).Mask.Peaks       = peaksTable;
                                            app.specObj(ii).Band(jj).Mask.TimeStamp   = newTimeStamp;

                                            if regularTask
                                                writematrix(jsonencode(rmfield(app.specObj(ii).Band(jj).Mask, {'Table', 'Array', 'Validations', 'BrokenArray', 'FindPeaks'})), ...
                                                    replace(app.specObj(ii).Band(jj).File.CurrentFile.FullPath, {'~', '.bin'}, {'', '.txt'}), "QuoteStrings", "none", "WriteMode", "append")
                                            end

                                            maskTrigger = 1;
                                        end
                                    end

                                    newArray = newArray(end,:);
                                end
                                
                                app.specObj(ii).Error(1,2:4) = {NaT, NaT, 0};

                                % WATERFALL MATRIX
                                idx = app.specObj(ii).Band(jj).Waterfall.idx + 1;
                                if idx > app.specObj(ii).Band(jj).Waterfall.Depth; idx = 1;
                                end

                                app.specObj(ii).Band(jj).Waterfall.idx = idx;
                                app.specObj(ii).Band(jj).Waterfall.Matrix(idx,:) = newArray(:,:,1);

                                [~, ~, nDim] = size(newArray);
                                if nDim > 1
                                    app.specObj(ii).Band(jj).Azimuth = newArray(:,:,2);
                                end

                                % ESTIMATED REVISIT TIME
                                if isempty(app.specObj(ii).Band(jj).LastTimeStamp)
                                    app.specObj(ii).Band(jj).RevisitTime = app.revisitObj.GlobalRevisitTime * app.revisitObj.Band(ii).RevisitFactors(jj+1);
                                else
                                    app.specObj(ii).Band(jj).RevisitTime = ((app.General.Integration.SampleTime-1)*app.specObj(ii).Band(jj).RevisitTime + seconds(newTimeStamp-app.specObj(ii).Band(jj).LastTimeStamp))/app.General.Integration.SampleTime;
                                end
                                app.specObj(ii).Band(jj).LastTimeStamp = newTimeStamp;

                                % PLOT, WRITEDSAMPLES & MASKINFO (IF APPLICABLE)
                                if app.Table.Selection == ii
                                    Layout_errorCount(app, ii)

                                    if app.DropDown.Value == jj
                                        plot_Draw(app, ii, jj)
                                        if ~isempty(app.specObj(ii).Band(jj).Mask)
                                            Layout_lastMaskValidation(app, maskTrigger, ii, jj)
                                        end
                                        app.tool_RevisitTime.Text = sprintf('%d varreduras\n%.3f seg', app.specObj(ii).Band(jj).nSweeps, app.specObj(ii).Band(jj).RevisitTime);
                                    end
                                end

                                % FILE
                                if regularTask && (isempty(app.specObj(ii).Band(jj).Mask) || ismember(app.specObj(ii).Task.Script.Band(jj).MaskTrigger.Status, [0, 3]) || ((app.specObj(ii).Task.Script.Band(jj).MaskTrigger.Status == 2) && maskTrigger))
                                    class.RFlookBinLib.EditFile(app.specObj(ii), jj, newArray, attFactor, newTimeStamp)
                                    app.specObj(ii).Band(jj).File.WritedSamples = app.specObj(ii).Band(jj).File.WritedSamples + 1;

                                    if (app.Table.Selection == ii) && (app.DropDown.Value == jj)
                                        app.Sweeps.Text = string(app.specObj(ii).Band(jj).File.WritedSamples);
                                    end                                    
                                end

                                if (app.Table.Selection == ii) && (app.DropDown.Value == jj)
                                    drawnow
                                end
    
                            catch ME
                                % O controle de erro do GPS se dá na função "RegularTask_gpsData".
                                % 
                                % O controle de erro do RECEPTOR se dá aqui, neste trecho da função 
                                % "RegularTask_MainLoop".
                                %
                                % O app tentará reativar a conexão toda vez que o contador de
                                % erro atingir um múltiplo de "class.Constants.errorCountTrigger".
                                % E, além disso, caso ultrapassado o tempo (em segundos) definido 
                                % em "class.Constants.errorTimeTrigger", o app trocará o estado da 
                                % tarefa de "Em andamento" → "Erro".

                                if ME.message == "If you specify a message identifier argument, you must specify the message text argument."
                                    pause(1)
                                end

                                app.specObj(ii).LOG(end+1) = struct('type', 'error (RECEIVER)', 'time', char(newTimeStamp), 'msg', ME.message);
                                RegularTask_errorHandle(app, 'Receiver', ii, newTimeStamp)

                                if app.Table.Selection == ii
                                    Layout_errorCount(app, ii)
                                    drawnow
                                end
                                beep

                                msgError = app.receiverObj.ReconnectAttempt(app.specObj(ii).hReceiver.UserData.instrSelected, ...
                                                                            app.specObj(ii).Task.Receiver.Config.connectFlag, ...
                                                                            app.specObj(ii).Task.Receiver.Config.StartUp{1},  ...
                                                                            app.specObj(ii).Band(jj).SpecificSCPI);
                                if ~isempty(msgError)
                                    RegularTask_StatusTaskCheck(app, ii, 'ErrorTrigger');
                                    break
                                end
                            end
                        end
                    end
                end

                nn = nn+1;
                pause(max(app.revisitObj.GlobalRevisitTime-toc(sweepTic), .001))
            end

            start(app.timerObj_task)

            app.revisitObj = [];
            Layout_metadataTab(app)
        end


        %-----------------------------------------------------------------%
        function RegularTask_ConfigBand(app, ii, jj, hReceiver)
            writeline(hReceiver, app.specObj(ii).Band(jj).SpecificSCPI.configSET);
            pause(.001)
            
            if ~isempty(app.specObj(ii).Band(jj).SpecificSCPI.attSET)
                writeline(hReceiver, app.specObj(ii).Band(jj).SpecificSCPI.attSET);
            end
        end


        %-----------------------------------------------------------------%
        function RegularTask_gpsData(app, ii, hReceiver, hGPS, newTimeStamp)
            % O controle de erro do RECEPTOR se dá na função "RegularTask_MainLoop".
            %
            % O controle de erro do GPS, por outro lado, se dá diretamente aqui, 
            % nesta função, e é restrito ao caso em que o receptor é "External",
            % ou seja, não se trata de GPS embarcado no RECEPTOR (GPS conectado
            % à porta USB do computador que executa o app, por exemplo).
            %
            % Caso a tarefa seja do tipo "Drive-test", toda vez que for manifestada 
            % uma desconexão, o app tentará reativar a conexao. Ou, em sendo uma tarefa 
            % de outro tipo, o app tentará reativar a conexão toda vez que o contador de
            % erro atingir um múltiplo de "class.Constants.errorGPSCountTrigger".
             
            gpsData = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '');

            try
                switch app.specObj(ii).Task.Script.GPS.Type
                    case 'Built-in'
                        gpsData = fcn.gpsBuiltInReader(hReceiver);
                    case 'External'
                        gpsData = fcn.gpsExternalReader(hGPS, 1);
                        app.specObj(ii).Error(2,2:4) = {NaT, NaT, 0};
                end

            catch ME
                app.specObj(ii).LOG(end+1) = struct('type', 'error (GPS)', 'time', char(newTimeStamp), 'msg', ME.message);

                if strcmp(app.specObj(ii).Task.Script.GPS.Type, 'External')
                    RegularTask_errorHandle(app, 'GPS', ii, newTimeStamp)

                    if contains(app.specObj(ii).Task.Type, 'Drive-test') || ~mod(app.specObj(ii).Error.Count(2), class.Constants.errorGPSCountTrigger)
                        app.gpsObj.ReconnectAttempt(hGPS.UserData.instrSelected);
                    end
                end
            end

            % As coordenadas da estação - registradas em app.General.stationInfo
            % - são atualizadas apenas se a estação for do tipo móvel ("Mobile") 
            % e as novas coordenadas geográficas forem válidas.

            if strcmp(app.General.stationInfo.Type, 'Mobile') && gpsData.Status
                app.General.stationInfo.Latitude  = gpsData.Latitude;
                app.General.stationInfo.Longitude = gpsData.Longitude;
            end

            RegularTask_gpsUpdate(app, ii, gpsData, newTimeStamp)
        end


        %-----------------------------------------------------------------%
        function RegularTask_gpsUpdate(app, ii, gpsData, newTimeStamp)
            if isempty(gpsData.TimeStamp)
                gpsData.TimeStamp = char(newTimeStamp);
            end
            app.specObj(ii).lastGPS = gpsData;

            if (app.Table.Selection == ii)
                Layout_lastGPS(app, gpsData)
            end
        end
        
        
        %-----------------------------------------------------------------%
        function RegularTask_AntennaSwitch(app, ii, jj)
            switch app.specObj(ii).Task.Antenna.Switch.Name
                case 'EMSat'
                    msgError = app.EMSatObj.MatrixSwitch(app.specObj(ii).Band(jj).Antenna.SwitchPort,    ...
                                                         app.specObj(ii).Task.Antenna.Switch.OutputPort, ...
                                                         app.specObj(ii).Band(jj).Antenna.LNBChannel,    ...
                                                         app.specObj(ii).Band(jj).Antenna.LNBIndex);
                    if ~isempty(msgError)
                        error(msgError)
                    end

                case 'ERMx'
                    msgError = app.ERMxObj.MatrixSwitch( app.specObj(ii).Band(jj).Antenna.SwitchPort, ...
                                                         app.specObj(ii).Task.Antenna.Switch.OutputPort);
                    if ~isempty(msgError)
                        error(msgError)
                    end
            end
        end


        %-----------------------------------------------------------------%
        function newArray = RegularTask_specData(app, ii, jj, hReceiver, hStreaming, newTimeStamp)
            Timeout = class.Constants.Timeout;
            Flag_success = false;

            switch app.specObj(ii).Task.Receiver.Config.connectFlag
                case 1
                    % Spectrum analyzers (R&S, KeySight, Tektronix, Anritsu)

                    recTic = tic;
                    t1 = toc(recTic);
                    while t1 < Timeout
                        try
                            writeline(hReceiver, app.specObj(ii).GeneralSCPI.dataGET);
                            newArray = readbinblock(hReceiver, 'single');
                                                        
                            if numel(newArray) == app.specObj(ii).Band(jj).DataPoints
                                if strcmp(app.specObj(ii).Task.Receiver.Sync, 'Continuous Sweep')
                                    SyncModeRef = sum(newArray);

                                    if SyncModeRef ~= app.specObj(ii).Band(jj).SyncModeRef
                                        app.specObj(ii).Band(jj).SyncModeRef = SyncModeRef;
                                    else
                                        continue
                                    end                                    
                                end

                                Flag_success = true;
                                break
                            end
    
                        catch
                        end
                        t1 = toc(recTic);
                    end
                    
                case 2
                    % R&S EB500: Tarefas ordinárias
                    
                    taskInfo = struct('Type',       app.specObj(ii).Task.Type,                      ...
                                      'FreqStart',  app.specObj(ii).Task.Script.Band(jj).FreqStart, ...
                                      'FreqStop',   app.specObj(ii).Task.Script.Band(jj).FreqStop,  ...
                                      'DataPoints', app.specObj(ii).Band(jj).DataPoints,            ...
                                      'nDatagrams', app.specObj(ii).Band(jj).Datagrams,             ...
                                      'udpPort',    app.EB500Obj.udpPort);

                    [newArray, Flag_success] = class.EB500Lib.DatagramRead_PSCAN(taskInfo, hReceiver, hStreaming);

                case 3
                    % R&S EB500 - Tarefa "Drive-test (Level+Azimuth)"
                    % O newArray gerado aqui, e apenas aqui, possui informações
                    % de nível, azimute e nota de qualidade do azimute. A dimensão 
                    % dele é 1 (Height) x DataPoints (Width) x 3 (Depth).

                    taskInfo = struct('Type',       app.specObj(ii).Task.Type,                                                                          ...
                                      'FreqCenter', (app.specObj(ii).Task.Script.Band(jj).FreqStart + app.specObj(ii).Task.Script.Band(jj).FreqStop)/2, ...
                                      'FreqSpan',   app.specObj(ii).Task.Script.Band(jj).FreqStop - app.specObj(ii).Task.Script.Band(jj).FreqStart,     ...
                                      'DataPoints', app.specObj(ii).Band(jj).DataPoints,                                                                ...
                                      'udpPort',    app.EB500Obj.udpPort);

                    [newArray, gpsData, Flag_success] = class.EB500Lib.DatagramRead_FFM(taskInfo, hReceiver, hStreaming);

                    % No datagrama tem a informação de gps... então vamos aproveitar! :)
                    RegularTask_gpsUpdate(app, ii, gpsData, newTimeStamp)
            end
            flush(hReceiver)
            
            if Flag_success
                if app.specObj(ii).Band(jj).FlipArray
                    newArray(:,:,1) = flip(newArray(:,:,1));
                end
            else
                error('Não foi lido corretamente o vetor de nível do receptor dentro do tempo limite (%.0f segundos).', Timeout)
            end            
        end


        %-----------------------------------------------------------------%
        function RegularTask_errorHandle(app, errorType, ii, newTimeStamp)
            switch errorType
                case 'Receiver'; idx = 1;
                case 'GPS';      idx = 2;
            end
                                
            if isnat(app.specObj(ii).Error.CreatedTime(idx))
                app.specObj(ii).Error.CreatedTime(idx) = newTimeStamp;
            end
            app.specObj(ii).Error.LastTime(idx) = newTimeStamp;
            app.specObj(ii).Error.Count(idx) = app.specObj(ii).Error.Count(idx) + 1;
        end

        %-----------------------------------------------------------------%
        function Layout_tableBuilding(app, idx)
            tempTable = table('Size', [0, 7],                                                                          ...
                              'VariableTypes', {'double', 'string', 'string', 'string', 'string', 'string', 'string'}, ...
                              'VariableNames', {'ID', 'Name', 'Receiver', 'Created', 'BeginTime', 'EndTime', 'Status'});
            tempTable.Properties.UserData = char(matlab.lang.internal.uuid());
            
            for ii = 1:numel(app.specObj)
                EndTime = '-';
                if ~isnat(app.specObj(ii).Observation.EndTime) && ~isinf(app.specObj(ii).Observation.EndTime)
                    EndTime = datestr(app.specObj(ii).Observation.EndTime, 'dd/mm/yyyy HH:MM:SS');
                end
        
                tempTable(end+1,:) = {app.specObj(ii).ID,                        ...
                                      app.specObj(ii).Task.Script.Name,          ...
                                      app.specObj(ii).IDN,                       ...
                                      app.specObj(ii).Observation.Created,       ...
                                      datestr(app.specObj(ii).Observation.BeginTime, 'dd/mm/yyyy HH:MM:SS'), ...
                                      EndTime,                                   ...
                                      app.specObj(ii).Status};
            end    
        
            if all(~strcmp(tempTable.Status, "Em andamento"))
                app.Flag_running = 0;
            end
        
            if height(tempTable)
                app.Table.Data      = tempTable;
                app.Table.Selection = max([1, idx]);
                app.Table.UserData  = app.Table.Selection;
        
                app.tool_ButtonPlay.Enable = 1;
                app.tool_ButtonDel.Enable  = 1;
                app.tool_ButtonLOG.Enable  = 1;
            else
                app.Table.Data     = table;
                app.Table.UserData = [];
        
                app.tool_ButtonPlay.Enable = 0;
                app.tool_ButtonDel.Enable  = 0;
                app.tool_ButtonLOG.Enable  = 0;
            end
            Layout_errorCount(app, app.Table.Selection)
            drawnow
        
            previousSelection = 1;
            if ~isempty(app.DropDown.Items)
                previousSelection = app.DropDown.Value;
            end
            Layout_treeBuilding(app, previousSelection)
        end

        %-----------------------------------------------------------------%
        function Layout_treeBuilding(app, Selection)
            if app.Table.Selection
                idx = app.Table.Selection;
                numBands = numel(app.specObj(idx).Task.Script.Band);
                ids = {};

                for ii = 1:numBands
                    Antenna = app.specObj(idx).Task.Script.Band(ii).instrAntenna;
                    if ~isempty(Antenna)
                        Antenna = sprintf('(%s)', Antenna);
                    end
                    
                    ids{end+1} = sprintf('ID %d: %.3f - %.3f MHz %s',                            ...
                                         app.specObj(idx).Task.Script.Band(ii).ID,               ...
                                         app.specObj(idx).Task.Script.Band(ii).FreqStart / 1e+6, ...
                                         app.specObj(idx).Task.Script.Band(ii).FreqStop  / 1e+6, ...
                                         Antenna);
                end
                
                set(app.DropDown, 'Items', ids, 'ItemsData', 1:numBands, 'Value', Selection)
                task_TreeSelectionChanged(app)
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
            app.MetaData.Text = util.HtmlTextGenerator.Task(app.specObj, app.revisitObj, app.Table.Selection, app.DropDown.Value);
        end

        %-----------------------------------------------------------------%
        function Layout_errorCount(app, idx)
            if ~isempty(idx) && app.specObj(idx).Error.Count(1)
                set(app.errorCount_txt, 'Text', string(app.specObj(idx).Error.Count(1)), 'Visible', 'on')
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
                Validations = app.specObj(ii).Band(jj).Mask.Validations;
                BrokenCount = app.specObj(ii).Band(jj).Mask.BrokenCount;
        
                if ~isempty(app.specObj(ii).Band(jj).Mask.Peaks)
                    nPeaks      = sprintf(' (%d)', height(app.specObj(ii).Band(jj).Mask.Peaks));
                    FreqCenter  = app.specObj(ii).Band(jj).Mask.Peaks.FreqCenter(1);
                    BandWidth   = app.specObj(ii).Band(jj).Mask.Peaks.BW(1);
                    Prominence  = app.specObj(ii).Band(jj).Mask.Peaks.Prominence(1);
                    dTimeStamp  = extractBefore(char(app.specObj(ii).Band(jj).Mask.TimeStamp), ' ');
                    hTimeStamp  = extractAfter(char(app.specObj(ii).Band(jj).Mask.TimeStamp), ' ');
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
                    sprintf('<b style="color: #a2142f; font-size: 14;">%.0f</b> \nVALIDAÇÕES', app.specObj(ii).Band(jj).Mask.Validations));
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
                if contains(app.specObj(ii).Task.Type, 'Drive-test (Level+Azimuth)')
                    sources{end+1} = 'Azimute';
                end
    
                % Se a tarefa for "Rompimento de Máscara Espectral" e o Status for 
                % maior do que zero, então o campo "Mask" será diferente de vazio.
                % A validação abaixo é idêntica (funcionalmente) à:
                
              % if contains(app.specObj(ii).Task.Type, 'Rompimento de Máscara Espectral') && app.specObj(ii).Task.Script.Band(jj).MaskTrigger.Status
                if ~isempty(app.specObj(ii).Band(jj).Mask)
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
            FreqStart = app.specObj(ii).Task.Script.Band(jj).FreqStart / 1e+6;
            FreqStop  = app.specObj(ii).Task.Script.Band(jj).FreqStop  / 1e+6;
            LevelUnit = app.specObj(ii).Task.Script.Band(jj).instrLevelUnit;
            xArray    = linspace(FreqStart, FreqStop, app.specObj(ii).Band(jj).DataPoints);
    
            % General settings
            [~, strUnit] = class.Constants.yAxisUpLimit(app.specObj(ii).Task.Script.Band(jj).instrLevelUnit);
    
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
            idx = app.specObj(ii).Band(jj).Waterfall.idx;
            newArray = app.specObj(ii).Band(jj).Waterfall.Matrix(idx,:);

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
                        if ~isempty(app.specObj(ii).Band(jj).Mask)
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

                        app.line_ClrWrite = plot.draw2D.clearWrite(app.axes1, xArray, app.specObj(ii).Band(jj).Azimuth, LevelUnit, 'ClrWrite', app.General, 'Marker', '.', 'MarkerSize', 12, 'LineStyle', 'none');

                    case 'Máscara'
                        ylabel(app.axes1, 'Rompimento (%)');
                        set(app.axes1, XLim=[FreqStart, FreqStop], YLim=[.1, 100], YScale='log')
            
                        KK = 100/app.specObj(ii).Band(jj).Mask.Validations;
                        app.line_ClrWrite = plot.draw2D.clearWrite(app.axes1, xArray, KK.*app.specObj(ii).Band(jj).Mask.BrokenArray, '%%', 'MaskPlot', app.General, 'Marker', '.', 'MarkerSize', 12, 'LineStyle', 'none');
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
                        plot.draw2D.update(app.line_ClrWrite, app.specObj(ii).Band(jj).Azimuth, app.General)

                    case 'Máscara'
                        KK = 100/app.specObj(ii).Band(jj).Mask.Validations;
                        plot.draw2D.update(app.line_ClrWrite, KK.*app.specObj(ii).Band(jj).Mask.BrokenArray, app.General)
                end
            end

            % Waterfall
            if app.axesTool_Waterfall.UserData.status
                if isempty(app.surface_WFall)
                    if ~exist('xArray', 'var')
                        [xArray, downYLim, upYLim, FreqStart, FreqStop] = plot_AxesParameters(app, ii, jj, newArray);
                    end
                    set(app.axes2, 'YLim', [1, app.specObj(ii).Band(jj).Waterfall.Depth], 'View', [0, 90], 'CLim', [downYLim, upYLim])
                    app.restoreView(2) = struct('ID', 'app.axes2', 'xLim', [FreqStart, FreqStop], 'yLim', app.axes2.YLim,  'cLim', app.axes2.CLim);

                    app.surface_WFall = plot.draw3D.Waterfall(app.axes2, app.specObj(ii), jj, xArray);
                else
                    app.surface_WFall.CData = circshift(app.specObj(ii).Band(jj).Waterfall.Matrix, -idx);
                end
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % TABGROUPCONTROLLER
        %-----------------------------------------------------------------%
        function hAuxApp = auxAppHandle(app, auxAppName)
            arguments
                app
                auxAppName string {mustBeMember(auxAppName, ["INSTRUMENT", "TASK:EDIT", "TASK:ADD", "SERVER", "CONFIG"])}
            end

            hAuxApp = app.tabGroupController.Components.appHandle{app.tabGroupController.Components.Tag == auxAppName};
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
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            try
                % WARNING MESSAGES
                appUtil.disablingWarningMessages()

                % <GUI>
                app.popupContainerGrid.Layout.Row = [1,2];
                app.GridLayout.RowHeight(end) = [];

                app.menu_AppName.Text = sprintf('%s v. %s\n<font style="font-size: 9px;">%s</font>', ...
                    class.Constants.appName, class.Constants.appVersion, class.Constants.appRelease);
                % </GUI>

                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
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
                appUtil.modalWindow(app.UIFigure, 'warning', 'Existe uma tarefa em execução...');
                return
            end
            % </EspecificidadeAppColeta1>

            if ~strcmp(app.executionMode, 'webApp') && ~isempty(app.specObj)
                msgQuestion   = 'Deseja fechar o aplicativo?';
                userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Sim', 'Não'}, 1, 2);
                if userSelection == "Não"
                    return
                end
            end

            % <EspecificidadeAppColeta2>
            if app.General.startupInfo
                RegularTask_specObjSave(app)
            else
                [~, programDataFolder] = appUtil.Path(class.Constants.appName, app.rootFolder);
                if isfile(fullfile(programDataFolder, 'startupInfo.mat'))
                    delete(fullfile(programDataFolder, 'startupInfo.mat'))
                end
            end

            if app.General.stationInfo.Type == "Mobile"
                fcn.GeneralSettings(app.General, app.rootFolder)
            end

            if ~isempty(app.tcpServer)
                delete(app.tcpServer.Server)
            end
            % </EspecificidadeAppColeta2>

            % Aspectos gerais (carregar em todos os apps):
            appUtil.beforeDeleteApp(app.progressDialog, app.General_I.fileFolder.tempPath, app.tabGroupController, app.executionMode)
            delete(app)
            
        end

        % Value changed function: menu_Button1, menu_Button2, 
        % ...and 4 other components
        function menu_mainButtonPushed(app, event)

            % em sendo o ADICIONAR TAREFA, verificar se existe alguma
            % tarefa selecionado em tabela. Caso sim, pergunta se se deseja
            % editar ou adicionar uma nova. ao incluir a tarefa, o módulo é
            % encerrado.

            clickedButton  = event.Source;
            auxAppTag      = clickedButton.Tag;
            inputArguments = menu_auxAppInputArguments(app, auxAppTag);

            if event.Source == app.menu_Button4
                % A operação padrão, ao clicar em app.menu_Button4, é criar uma 
                % nova tarefa. Caso esteja selecionado o módulo de visualização 
                % de tarefas, e esteja selecionada uma tarefa, questiona-se se 
                % deve ser feito a inclusão de uma nova tarefa ou a edição da 
                % selecionada. 
                idx = app.Table.Selection;

                if  ~checkStatusModule(app.tabGroupController, 'TASK:ADD') && app.menu_Button1.Value && ~isempty(idx)
                    msgQuestion   = 'Deseja criar uma nova tarefa, ou editar a tarefa selecionada em tabela?';
                    userSelection = appUtil.modalWindow(app.UIFigure, 'uiconfirm', msgQuestion, {'Criar nova', 'Editar selecionada', 'Cancelar'}, 1, 3);
                    switch userSelection
                        case 'Editar selecionada'
                            if ismember(app.specObj(idx).Status, {'Na fila', 'Em andamento'})
                                appUtil.modalWindow(app.UIFigure, 'warning', 'Uma tarefa no estado "Na fila" ou "Em andamento" não poderá ser editada.');
                                app.menu_Button4.Value = 0;
                                return
                            end

                            inputArguments = {app, struct('type', 'edit', 'idx', idx)};

                        case 'Cancelar'
                            app.menu_Button4.Value = 0;
                            return
                    end
                end
            end

            openModule(app.tabGroupController, event.Source, event.PreviousValue, app.General, inputArguments{:})
            
        end

        % Image clicked function: AppInfo, FigurePosition
        function menu_ToolbarImageCliced(app, event)
            
            switch event.Source
                case app.FigurePosition
                    app.UIFigure.Position(3:4) = class.Constants.windowSize;
                    appUtil.winPosition(app.UIFigure)

                case app.AppInfo
                    if isempty(app.AppInfo.Tag)
                        app.progressDialog.Visible = 'visible';
                        app.AppInfo.Tag = util.HtmlTextGenerator.AppInfo(app.General, app.rootFolder, app.executionMode, app.renderCount, "popup");
                        app.progressDialog.Visible = 'hidden';
                    end

                    msgInfo = app.AppInfo.Tag;
                    appUtil.modalWindow(app.UIFigure, 'info', msgInfo);
            end

        end

        % Image clicked function: tool_ButtonPlay
        function menu_PushButtonPushed_playTask(app, event)
            
            idx = app.Table.Selection;
            if idx 
                switch app.specObj(idx).Status
                    %-----------------------------------------------------%
                    % PLAY
                    %-----------------------------------------------------%
                    case {'Cancelada', 'Erro', 'Concluída'}
                        Timestamp = datetime('now');
        
                        switch app.specObj(idx).Task.Script.Observation.Type
                            case 'Duration'
                                app.specObj(idx).Observation.BeginTime = Timestamp;
                                app.specObj(idx).Observation.EndTime   = Timestamp + seconds(app.specObj(idx).Task.Script.Observation.Duration);
            
                            case 'Time'
                                if strcmp(app.specObj(idx).Status, 'Concluída')
                                    appUtil.modalWindow(app.UIFigure, 'warning', 'Uma tarefa no estado "Concluída" somente poderá ser executada novamente se o tipo do período de observação for "Duração" ou "Quantidade específica de amostras".');
                                    return
                                end
            
                            case 'Samples'
                                app.specObj(idx).Observation.BeginTime = Timestamp;
                                app.specObj(idx).Observation.EndTime   = NaT;
                        end
        
                        app.specObj(idx).Status = 'Na fila';
                        app.specObj(idx).LOG(end+1) = struct('type', 'task', 'time', char(Timestamp), 'msg', 'Reincluída na fila a tarefa.');

                        RegularTask_RestartStatus(app, idx, 1)        
                        RegularTask_timerFcn(app)

                    %-----------------------------------------------------%
                    % STOP
                    %-----------------------------------------------------%
                    case 'Em andamento'
                        RegularTask_StatusTaskCheck(app, idx, 'DeleteButtonPushed');
                end
            end
            
        end

        % Image clicked function: tool_ButtonDel
        function menu_PushButtonPushed_delTask(app, event)
            
            idx = app.Table.Selection;
            if idx
                switch app.specObj(idx).Status
                    case 'Em andamento'
                        appUtil.modalWindow(app.UIFigure, 'warning', 'A tarefa precisa ser interrompida antes da tentativa de exclusão.');

                    otherwise
                        if ~app.Flag_running
                            app.specObj(idx) = [];    
                            Layout_tableBuilding(app, 1)
                        else
                            appUtil.modalWindow(app.UIFigure, 'warning', 'Uma tarefa poderá ser excluída, sendo eliminada da lista de tarefas, somente se não estiver sendo executada nenhuma tarefa.');
                        end
                end
            end

        end

        % Image clicked function: tool_ButtonLOG
        function menu_PushButtonPushed_logTask(app, event)

            idx = app.Table.Selection;
            if idx
                log = util.HtmlTextGenerator.LOG(app.specObj, idx);
                appUtil.modalWindow(app.UIFigure, 'warning', log);
            end

        end

        % Image clicked function: tool_LeftPanel
        function menu_LayoutPanelVisibility(app, event)
            
            if app.task_docGrid.ColumnWidth{1}
                app.tool_LeftPanel.ImageSource = 'ArrowRight_32.png';
                app.task_docGrid.ColumnWidth(1:2) = {0,0};
                % app.TabGroup2.Visible = 0;
            else
                app.tool_LeftPanel.ImageSource = 'ArrowLeft_32.png';
                app.task_docGrid.ColumnWidth(1:2) = {320,10};
                % app.TabGroup2.Visible = 1;
            end
            
        end

        % Selection changed function: Table
        function task_TableSelectionChanged(app, event)

            oldSelection = app.Table.UserData;
            newSelection = app.Table.Selection;

            if isempty(newSelection) && ~isempty(oldSelection)
                app.Table.Selection = oldSelection;
                drawnow

            else
                app.Table.UserData = newSelection;
                Layout_treeBuilding(app, 1)
            end
            
        end

        % Value changed function: DropDown
        function task_TreeSelectionChanged(app, event)

            try
                ii = app.Table.Selection;
                jj = app.DropDown.Value;

                plot_Startup(app)
                plot_PlotSource(app, ii, jj);
                
                if ~isempty(app.specObj(ii).Band(jj).Waterfall)
                    idx = app.specObj(ii).Band(jj).Waterfall.idx;
    
                    if idx
                        plot_Draw(app, ii, jj)
                    end
                end
    
                % TASK INFO THAT ARE UPDATED IN REAL TIME
                % (LEFT PANEL)
                Layout_metadataTab(app)
    
                % (RIGHT PANEL)
                if ~isempty(app.specObj(ii).Band(jj).File); WritedSamples = app.specObj(ii).Band(jj).File.WritedSamples;
                else;                                       WritedSamples = -1; 
                end
                app.Sweeps.Text = string(WritedSamples);
    
                if ~contains(app.specObj(ii).Task.Type, 'PRÉVIA') && strcmp(app.specObj(ii).Status, 'Em andamento') && app.specObj(ii).Band(jj).Status
                    app.Sweeps_REC.Visible = 1;
                else
                    app.Sweeps_REC.Visible = 0;
                end
                
                if ~isempty(app.specObj(ii).Band(jj).Mask)                    
                    app.lastMask_text.Enable = 1;
                    Layout_lastMaskValidation(app, true, ii, jj)
                else
                    Layout_lastMaskInitialState(app)
                end
                Layout_lastGPS(app, app.specObj(ii).lastGPS)
    
                % (DOWN STATUS PANEL)
                ysecondarylabel(app.axes1, sprintf('%s\n%s\n', app.Table.Data.Receiver(ii), app.DropDown.Items{app.DropDown.Value}))
                if ~isempty(app.tool_RevisitTime.Text); app.tool_RevisitTime.Text = sprintf('%d varreduras\n%.3f seg', app.specObj(ii).Band(jj).nSweeps, app.specObj(ii).Band(jj).RevisitTime);
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
                    task_TreeSelectionChanged(app)
                end

                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end
            drawnow

        end

        % Image clicked function: axesTool_Average, axesTool_MaxHold, 
        % ...and 2 other components
        function task_ButtonPushed_plotTraceMode(app, event)
            
            event.Source.UserData.status = ~event.Source.UserData.status;
            if isfield(event.Source.UserData, 'icon')
                if event.Source.UserData.status
                    event.Source.ImageSource = event.Source.UserData.icon.On;
                else
                    event.Source.ImageSource = event.Source.UserData.icon.Off;
                end
            end

            if isempty(app.Table.Selection) || isempty(app.DropDown.Items) || strcmp(app.axesTool_PlotSource.Value, 'Máscara')
                return
            end

            ii = app.Table.Selection;
            jj = app.DropDown.Value;

            if ~isempty(app.specObj(ii).Band(jj).Waterfall)
                idx = app.specObj(ii).Band(jj).Waterfall.idx;

                if idx
                    FreqStart = app.specObj(ii).Task.Script.Band(jj).FreqStart / 1e+6;
                    FreqStop  = app.specObj(ii).Task.Script.Band(jj).FreqStop  / 1e+6;
                    LevelUnit = app.specObj(ii).Task.Script.Band(jj).instrLevelUnit;

                    xArray    = linspace(FreqStart, FreqStop, app.specObj(ii).Band(jj).DataPoints);
                    newArray = app.specObj(ii).Band(jj).Waterfall.Matrix(idx,:);

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
        function task_ButtonPushed_plotLayout(app, event)
            
            event.Source.UserData.status = ~event.Source.UserData.status;
            plot_Layout(app)

            if ~isempty(app.Table.Selection) && ~app.Flag_running
                axesTool_PlotSourceValueChanged(app)
            end

        end

        % Image clicked function: axesTool_MinHold_2
        function axesTool_MinHold_2ImageClicked(app, event)
            
            if ~isempty(app.axes1.Children)
                set(app.axes1, 'XLim', app.restoreView(1).xLim, 'YLim', app.restoreView(1).yLim)
            end

            if ~isempty(app.axes2.Children)
                set(app.axes2, 'XLim', app.restoreView(2).xLim, 'YLim', app.restoreView(2).yLim, 'CLim', app.restoreView(2).cLim)
            end

        end

        % Value changed function: axesTool_PlotSource
        function axesTool_PlotSourceValueChanged(app, event)
            
            set([app.axesTool_MinHold, app.axesTool_Average, app.axesTool_MaxHold, app.axesTool_Peak], 'Enable', strcmp(app.axesTool_PlotSource.Value, 'Nível'))
            
            ii = app.Table.Selection;
            jj = app.DropDown.Value;
            
            if ~isempty(app.specObj(ii).Band(jj).Waterfall)
                idx = app.specObj(ii).Band(jj).Waterfall.idx;

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
            app.GridLayout.RowHeight = {54, '1x', 44};
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

            % Create Table
            app.Table = uitable(app.task_docGrid);
            app.Table.ColumnName = {'ID'; 'TAREFA'; 'RECEPTOR'; 'INCLUSÃO'; 'INÍCIO|OBSERVAÇÃO'; 'FIM|OBSERVAÇÃO'; 'ESTADO'};
            app.Table.ColumnWidth = {40, 'auto', 'auto', 120, 120, 120, 120};
            app.Table.RowName = {};
            app.Table.SelectionType = 'row';
            app.Table.SelectionChangedFcn = createCallbackFcn(app, @task_TableSelectionChanged, true);
            app.Table.Multiselect = 'off';
            app.Table.Layout.Row = 1;
            app.Table.Layout.Column = [1 7];
            app.Table.FontSize = 11;

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

            % Create axesTool_MinHold
            app.axesTool_MinHold = uiimage(app.play_axesToolbar);
            app.axesTool_MinHold.ImageClickedFcn = createCallbackFcn(app, @task_ButtonPushed_plotTraceMode, true);
            app.axesTool_MinHold.Tag = 'MinHold';
            app.axesTool_MinHold.Tooltip = {'MinHold'};
            app.axesTool_MinHold.Layout.Row = 2;
            app.axesTool_MinHold.Layout.Column = 5;
            app.axesTool_MinHold.VerticalAlignment = 'bottom';
            app.axesTool_MinHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MinHold_32.png');

            % Create axesTool_Average
            app.axesTool_Average = uiimage(app.play_axesToolbar);
            app.axesTool_Average.ImageClickedFcn = createCallbackFcn(app, @task_ButtonPushed_plotTraceMode, true);
            app.axesTool_Average.Tag = 'Average';
            app.axesTool_Average.Tooltip = {'Média'};
            app.axesTool_Average.Layout.Row = 2;
            app.axesTool_Average.Layout.Column = 6;
            app.axesTool_Average.VerticalAlignment = 'bottom';
            app.axesTool_Average.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Average_32.png');

            % Create axesTool_MaxHold
            app.axesTool_MaxHold = uiimage(app.play_axesToolbar);
            app.axesTool_MaxHold.ImageClickedFcn = createCallbackFcn(app, @task_ButtonPushed_plotTraceMode, true);
            app.axesTool_MaxHold.Tag = 'MaxHold';
            app.axesTool_MaxHold.Tooltip = {'MaxHold'};
            app.axesTool_MaxHold.Layout.Row = 2;
            app.axesTool_MaxHold.Layout.Column = 7;
            app.axesTool_MaxHold.VerticalAlignment = 'bottom';
            app.axesTool_MaxHold.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'MaxHold_32.png');

            % Create axesTool_Peak
            app.axesTool_Peak = uiimage(app.play_axesToolbar);
            app.axesTool_Peak.ScaleMethod = 'none';
            app.axesTool_Peak.ImageClickedFcn = createCallbackFcn(app, @task_ButtonPushed_plotTraceMode, true);
            app.axesTool_Peak.Tag = 'Persistance';
            app.axesTool_Peak.Tooltip = {'Excursão de pico'};
            app.axesTool_Peak.Layout.Row = 2;
            app.axesTool_Peak.Layout.Column = 8;
            app.axesTool_Peak.VerticalAlignment = 'bottom';
            app.axesTool_Peak.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Detection_18.png');

            % Create axesTool_Waterfall
            app.axesTool_Waterfall = uiimage(app.play_axesToolbar);
            app.axesTool_Waterfall.ScaleMethod = 'none';
            app.axesTool_Waterfall.ImageClickedFcn = createCallbackFcn(app, @task_ButtonPushed_plotLayout, true);
            app.axesTool_Waterfall.Tag = 'Waterfall';
            app.axesTool_Waterfall.Tooltip = {'Waterfall'};
            app.axesTool_Waterfall.Layout.Row = 2;
            app.axesTool_Waterfall.Layout.Column = 9;
            app.axesTool_Waterfall.HorizontalAlignment = 'left';
            app.axesTool_Waterfall.VerticalAlignment = 'bottom';
            app.axesTool_Waterfall.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Waterfall_24.png');

            % Create axesTool_PlotSource
            app.axesTool_PlotSource = uidropdown(app.play_axesToolbar);
            app.axesTool_PlotSource.Items = {'Nível'};
            app.axesTool_PlotSource.ValueChangedFcn = createCallbackFcn(app, @axesTool_PlotSourceValueChanged, true);
            app.axesTool_PlotSource.Enable = 'off';
            app.axesTool_PlotSource.Tooltip = {'Fonte de dados'};
            app.axesTool_PlotSource.FontSize = 11;
            app.axesTool_PlotSource.FontColor = [0.129411764705882 0.129411764705882 0.129411764705882];
            app.axesTool_PlotSource.BackgroundColor = [1 1 1];
            app.axesTool_PlotSource.Layout.Row = [1 3];
            app.axesTool_PlotSource.Layout.Column = 3;
            app.axesTool_PlotSource.Value = 'Nível';

            % Create axesTool_MinHold_2
            app.axesTool_MinHold_2 = uiimage(app.play_axesToolbar);
            app.axesTool_MinHold_2.ImageClickedFcn = createCallbackFcn(app, @axesTool_MinHold_2ImageClicked, true);
            app.axesTool_MinHold_2.Tag = 'MinHold';
            app.axesTool_MinHold_2.Tooltip = {'RestoreView'};
            app.axesTool_MinHold_2.Layout.Row = 2;
            app.axesTool_MinHold_2.Layout.Column = 1;
            app.axesTool_MinHold_2.VerticalAlignment = 'bottom';
            app.axesTool_MinHold_2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Home_18.png');

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
            app.DropDown.ValueChangedFcn = createCallbackFcn(app, @task_TreeSelectionChanged, true);
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
            app.task_toolGrid.ColumnWidth = {22, 22, 22, 5, 22, '1x'};
            app.task_toolGrid.RowHeight = {4, 17, 2};
            app.task_toolGrid.ColumnSpacing = 5;
            app.task_toolGrid.RowSpacing = 0;
            app.task_toolGrid.Padding = [5 6 10 6];
            app.task_toolGrid.Layout.Row = 2;
            app.task_toolGrid.Layout.Column = 1;

            % Create tool_LeftPanel
            app.tool_LeftPanel = uiimage(app.task_toolGrid);
            app.tool_LeftPanel.ImageClickedFcn = createCallbackFcn(app, @menu_LayoutPanelVisibility, true);
            app.tool_LeftPanel.Tooltip = {'Visibilidade do painel à esquerda'};
            app.tool_LeftPanel.Layout.Row = 2;
            app.tool_LeftPanel.Layout.Column = 1;
            app.tool_LeftPanel.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'ArrowLeft_32.png');

            % Create tool_ButtonPlay
            app.tool_ButtonPlay = uiimage(app.task_toolGrid);
            app.tool_ButtonPlay.ImageClickedFcn = createCallbackFcn(app, @menu_PushButtonPushed_playTask, true);
            app.tool_ButtonPlay.Enable = 'off';
            app.tool_ButtonPlay.Tooltip = {'Inicia ou interrompe tarefa'};
            app.tool_ButtonPlay.Layout.Row = 2;
            app.tool_ButtonPlay.Layout.Column = 2;
            app.tool_ButtonPlay.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'play_32.png');

            % Create tool_ButtonDel
            app.tool_ButtonDel = uiimage(app.task_toolGrid);
            app.tool_ButtonDel.ImageClickedFcn = createCallbackFcn(app, @menu_PushButtonPushed_delTask, true);
            app.tool_ButtonDel.Enable = 'off';
            app.tool_ButtonDel.Tooltip = {'Exclui tarefa'};
            app.tool_ButtonDel.Layout.Row = 2;
            app.tool_ButtonDel.Layout.Column = 3;
            app.tool_ButtonDel.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Delete_32Red.png');

            % Create tool_Separator
            app.tool_Separator = uiimage(app.task_toolGrid);
            app.tool_Separator.ScaleMethod = 'none';
            app.tool_Separator.Enable = 'off';
            app.tool_Separator.Layout.Row = 2;
            app.tool_Separator.Layout.Column = 4;
            app.tool_Separator.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV.svg');

            % Create tool_ButtonLOG
            app.tool_ButtonLOG = uiimage(app.task_toolGrid);
            app.tool_ButtonLOG.ImageClickedFcn = createCallbackFcn(app, @menu_PushButtonPushed_logTask, true);
            app.tool_ButtonLOG.Enable = 'off';
            app.tool_ButtonLOG.Tooltip = {'LOG tarefa'};
            app.tool_ButtonLOG.Layout.Row = 2;
            app.tool_ButtonLOG.Layout.Column = 5;
            app.tool_ButtonLOG.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LOG_32.png');

            % Create tool_RevisitTime
            app.tool_RevisitTime = uilabel(app.task_toolGrid);
            app.tool_RevisitTime.HorizontalAlignment = 'right';
            app.tool_RevisitTime.WordWrap = 'on';
            app.tool_RevisitTime.FontSize = 10;
            app.tool_RevisitTime.Layout.Row = [1 3];
            app.tool_RevisitTime.Layout.Column = 6;
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

            % Create menu_Grid
            app.menu_Grid = uigridlayout(app.GridLayout);
            app.menu_Grid.ColumnWidth = {22, 74, '1x', 34, 5, 34, 34, 34, 5, 34, 34, '1x', 20, 20, 20, 0, 0};
            app.menu_Grid.RowHeight = {5, 7, 20, 7, 5};
            app.menu_Grid.ColumnSpacing = 5;
            app.menu_Grid.RowSpacing = 0;
            app.menu_Grid.Padding = [10 5 5 5];
            app.menu_Grid.Tag = 'COLORLOCKED';
            app.menu_Grid.Layout.Row = 1;
            app.menu_Grid.Layout.Column = 1;
            app.menu_Grid.BackgroundColor = [0.2 0.2 0.2];

            % Create menu_Button1
            app.menu_Button1 = uibutton(app.menu_Grid, 'state');
            app.menu_Button1.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button1.Tag = 'TASK:VIEW';
            app.menu_Button1.Tooltip = {'Acompanha execução de tarefas'};
            app.menu_Button1.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'Playback_32Yellow.png');
            app.menu_Button1.IconAlignment = 'top';
            app.menu_Button1.Text = '';
            app.menu_Button1.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button1.FontSize = 11;
            app.menu_Button1.Layout.Row = [2 4];
            app.menu_Button1.Layout.Column = 4;
            app.menu_Button1.Value = true;

            % Create menu_Separator1
            app.menu_Separator1 = uiimage(app.menu_Grid);
            app.menu_Separator1.ScaleMethod = 'none';
            app.menu_Separator1.Enable = 'off';
            app.menu_Separator1.Layout.Row = [2 4];
            app.menu_Separator1.Layout.Column = 5;
            app.menu_Separator1.VerticalAlignment = 'bottom';
            app.menu_Separator1.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create menu_Button2
            app.menu_Button2 = uibutton(app.menu_Grid, 'state');
            app.menu_Button2.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button2.Tag = 'INSTRUMENT';
            app.menu_Button2.Tooltip = {'Edita lista de instrumentos'};
            app.menu_Button2.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'Connect_36White.png');
            app.menu_Button2.IconAlignment = 'right';
            app.menu_Button2.Text = '';
            app.menu_Button2.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button2.FontSize = 11;
            app.menu_Button2.Layout.Row = [2 4];
            app.menu_Button2.Layout.Column = 6;

            % Create menu_Button3
            app.menu_Button3 = uibutton(app.menu_Grid, 'state');
            app.menu_Button3.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button3.Tag = 'TASK:EDIT';
            app.menu_Button3.Tooltip = {'Edita lista de tarefas'};
            app.menu_Button3.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'Task_36White.png');
            app.menu_Button3.IconAlignment = 'right';
            app.menu_Button3.Text = '';
            app.menu_Button3.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button3.FontSize = 11;
            app.menu_Button3.Layout.Row = [2 4];
            app.menu_Button3.Layout.Column = 7;

            % Create menu_Button4
            app.menu_Button4 = uibutton(app.menu_Grid, 'state');
            app.menu_Button4.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button4.Tag = 'TASK:ADD';
            app.menu_Button4.Tooltip = {'Adiciona nova tarefa'};
            app.menu_Button4.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'AddFile_36White.png');
            app.menu_Button4.IconAlignment = 'right';
            app.menu_Button4.Text = '';
            app.menu_Button4.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button4.FontSize = 11;
            app.menu_Button4.Layout.Row = [2 4];
            app.menu_Button4.Layout.Column = 8;

            % Create menu_Separator2
            app.menu_Separator2 = uiimage(app.menu_Grid);
            app.menu_Separator2.ScaleMethod = 'none';
            app.menu_Separator2.Enable = 'off';
            app.menu_Separator2.Layout.Row = [2 4];
            app.menu_Separator2.Layout.Column = 9;
            app.menu_Separator2.VerticalAlignment = 'bottom';
            app.menu_Separator2.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'LineV_White.svg');

            % Create menu_Button5
            app.menu_Button5 = uibutton(app.menu_Grid, 'state');
            app.menu_Button5.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button5.Tag = 'SERVER';
            app.menu_Button5.Tooltip = {'API'};
            app.menu_Button5.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'Server_36White.png');
            app.menu_Button5.IconAlignment = 'right';
            app.menu_Button5.Text = '';
            app.menu_Button5.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button5.FontSize = 11;
            app.menu_Button5.Layout.Row = [2 4];
            app.menu_Button5.Layout.Column = 10;

            % Create menu_Button6
            app.menu_Button6 = uibutton(app.menu_Grid, 'state');
            app.menu_Button6.ValueChangedFcn = createCallbackFcn(app, @menu_mainButtonPushed, true);
            app.menu_Button6.Tag = 'CONFIG';
            app.menu_Button6.Tooltip = {'Configurações gerais'};
            app.menu_Button6.Icon = fullfile(pathToMLAPP, 'resources', 'Icons', 'Settings_36White.png');
            app.menu_Button6.IconAlignment = 'right';
            app.menu_Button6.Text = '';
            app.menu_Button6.BackgroundColor = [0.2 0.2 0.2];
            app.menu_Button6.FontSize = 11;
            app.menu_Button6.Layout.Row = [2 4];
            app.menu_Button6.Layout.Column = 11;

            % Create jsBackDoor
            app.jsBackDoor = uihtml(app.menu_Grid);
            app.jsBackDoor.Layout.Row = 3;
            app.jsBackDoor.Layout.Column = 13;

            % Create menu_AppName
            app.menu_AppName = uilabel(app.menu_Grid);
            app.menu_AppName.WordWrap = 'on';
            app.menu_AppName.FontSize = 11;
            app.menu_AppName.FontColor = [1 1 1];
            app.menu_AppName.Layout.Row = [1 5];
            app.menu_AppName.Layout.Column = [2 3];
            app.menu_AppName.Interpreter = 'html';
            app.menu_AppName.Text = {'appColeta v. 1.63.0'; '<font style="font-size: 9px;">R2024a</font>'};

            % Create menu_AppIcon
            app.menu_AppIcon = uiimage(app.menu_Grid);
            app.menu_AppIcon.Layout.Row = [1 5];
            app.menu_AppIcon.Layout.Column = 1;
            app.menu_AppIcon.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Playback_32White.png');

            % Create AppInfo
            app.AppInfo = uiimage(app.menu_Grid);
            app.AppInfo.ImageClickedFcn = createCallbackFcn(app, @menu_ToolbarImageCliced, true);
            app.AppInfo.Tooltip = {'Informações gerais'};
            app.AppInfo.Layout.Row = 3;
            app.AppInfo.Layout.Column = 15;
            app.AppInfo.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'Dots_32White.png');

            % Create FigurePosition
            app.FigurePosition = uiimage(app.menu_Grid);
            app.FigurePosition.ImageClickedFcn = createCallbackFcn(app, @menu_ToolbarImageCliced, true);
            app.FigurePosition.Visible = 'off';
            app.FigurePosition.Tooltip = {'Reposiciona janela'};
            app.FigurePosition.Layout.Row = 3;
            app.FigurePosition.Layout.Column = 14;
            app.FigurePosition.ImageSource = fullfile(pathToMLAPP, 'resources', 'Icons', 'layout1_32White.png');

            % Create popupContainerGrid
            app.popupContainerGrid = uigridlayout(app.GridLayout);
            app.popupContainerGrid.ColumnWidth = {'1x', 880, '1x'};
            app.popupContainerGrid.RowHeight = {'1x', 90, 300, 90, '1x'};
            app.popupContainerGrid.ColumnSpacing = 0;
            app.popupContainerGrid.RowSpacing = 0;
            app.popupContainerGrid.Padding = [13 10 0 10];
            app.popupContainerGrid.Layout.Row = 3;
            app.popupContainerGrid.Layout.Column = 1;
            app.popupContainerGrid.BackgroundColor = [1 1 1];

            % Create SplashScreen
            app.SplashScreen = uiimage(app.popupContainerGrid);
            app.SplashScreen.Layout.Row = 3;
            app.SplashScreen.Layout.Column = 2;
            app.SplashScreen.ImageSource = 'SplashScreen.gif';

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
