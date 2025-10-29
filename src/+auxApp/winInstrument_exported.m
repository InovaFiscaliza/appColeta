classdef winInstrument_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        DockModuleGroup         matlab.ui.container.GridLayout
        dockModule_Undock       matlab.ui.control.Image
        dockModule_Close        matlab.ui.control.Image
        TabGroup                matlab.ui.container.TabGroup
        Tab                     matlab.ui.container.Tab
        TabGrid                 matlab.ui.container.GridLayout
        Tab1_Grid               matlab.ui.container.GridLayout
        Image_downArrow         matlab.ui.control.Image
        Image_upArrow           matlab.ui.control.Image
        Image_del               matlab.ui.control.Image
        Image_add               matlab.ui.control.Image
        Tree                    matlab.ui.container.Tree
        TreeNode_Receiver       matlab.ui.container.TreeNode
        TreeNode_GPS            matlab.ui.container.TreeNode
        Panel                   matlab.ui.container.Panel
        Tab2_PanelGrid          matlab.ui.container.GridLayout
        AspectostcnicosLabel    matlab.ui.control.Label
        instrImage              matlab.ui.control.Image
        instrMetadata           matlab.ui.control.Label
        ParametersPanel         matlab.ui.container.Panel
        ParametersGrid          matlab.ui.container.GridLayout
        LocalhostPanel          matlab.ui.container.Panel
        LocalhostGrid2          matlab.ui.container.GridLayout
        publicIP                matlab.ui.control.EditField
        publicIPLabel           matlab.ui.control.Label
        localIP                 matlab.ui.control.EditField
        localIPLabel            matlab.ui.control.Label
        LocalhostCheckBox       matlab.ui.control.CheckBox
        Timeout                 matlab.ui.control.NumericEditField
        TimeoutLabel            matlab.ui.control.Label
        BaudRate                matlab.ui.control.NumericEditField
        BaudRateLabel           matlab.ui.control.Label
        Port                    matlab.ui.control.EditField
        PortLabel               matlab.ui.control.Label
        IP                      matlab.ui.control.EditField
        IPLabel                 matlab.ui.control.Label
        Type                    matlab.ui.control.DropDown
        TypeLabel               matlab.ui.control.Label
        Description             matlab.ui.control.TextArea
        DescriptionLabel        matlab.ui.control.Label
        Name                    matlab.ui.control.DropDown
        NameLabel               matlab.ui.control.Label
        Family                  matlab.ui.control.DropDown
        FamilyLabel             matlab.ui.control.Label
        Status                  matlab.ui.control.DropDown
        StatusLabel             matlab.ui.control.Label
        PanelLabel              matlab.ui.control.Label
        TreeLabel               matlab.ui.control.Label
        ModePanel               matlab.ui.container.ButtonGroup
        ButtonGroup_Edit        matlab.ui.control.RadioButton
        ButtonGroup_View        matlab.ui.control.RadioButton
        ModePanelLabel          matlab.ui.control.Label
        Toolbar                 matlab.ui.container.GridLayout
        toolButton_export       matlab.ui.control.Image
        toolButton_open         matlab.ui.control.Image
        toolButton_edit         matlab.ui.control.Button
        toolButton_connectTest  matlab.ui.control.Button
        toolSeparator           matlab.ui.control.Image
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

        receiverObj
        gpsObj

        instrumentList
        editedList
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

        %-----------------------------------------------------------------%
        % function ipcSecundaryMatlabCallsHandler(app, callingApp, varargin)
        %     % ...
        % end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % JSBACKDOOR: CUSTOMIZAÇÃO GUI (ESTÉTICA/COMPORTAMENTAL)
        %-----------------------------------------------------------------%
        function jsBackDoor_Initialization(app, varargin)
            app.jsBackDoor = uihtml(app.UIFigure, "HTMLSource",           appUtil.jsBackDoorHTMLSource(),                              ...
                                                  "HTMLEventReceivedFcn", @(~, evt)ipcSecundaryJSEventsHandler(app, evt, varargin{:}), ...
                                                  "Visible",              "off");
        end

        %-----------------------------------------------------------------%
        function jsBackDoor_Customizations(app)
            if app.isDocked
                app.progressDialog = app.mainApp.progressDialog;
            else
                sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);
            end

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
            elToModify = {app.instrMetadata};
            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
            if ~isempty(elDataTag)
                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        % INICIALIZAÇÃO
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

            jsBackDoor_Customizations(app)
            startup_AppProperties(app)
            startup_GUIComponents(app)
        end

        %-----------------------------------------------------------------%
        function startup_AppProperties(app)
            app.receiverObj    = app.mainApp.receiverObj;
            app.gpsObj         = app.mainApp.gpsObj;
            app.instrumentList = [app.receiverObj.List; app.gpsObj.List];
            app.editedList     = app.instrumentList;
        end

        %-----------------------------------------------------------------%
        function startup_GUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
            end

            TreeBuilding(app, [])
        end

        %-----------------------------------------------------------------%
        function TreeBuilding(app, idxSelectedNode)
            if ~isempty(app.TreeNode_Receiver.Children)
                delete(app.TreeNode_Receiver.Children)
            end
            
            if ~isempty(app.TreeNode_GPS.Children)
                delete(app.TreeNode_GPS.Children)
            end

            % Tree creation
            for ii = 1:height(app.editedList)
                switch app.editedList.Family{ii}
                    case 'Receiver'
                        Parent = app.TreeNode_Receiver;
                    case 'GPS'
                        Parent = app.TreeNode_GPS;                    
                    otherwise
                        continue
                end

                if ~ismember(app.editedList.Type{ii}, {'TCPIP Socket', 'TCP/UDP IP Socket', 'Serial'})
                    continue
                end

                nodeText = TreeBuilding_nodeText(app, ii);
                nodeTree = uitreenode(Parent, 'Text', nodeText, 'NodeData', ii, 'UserData', numel(Parent.Children)+1);

                if ~isempty(idxSelectedNode) && (ii == idxSelectedNode)
                    SelectedNode = nodeTree;
                end
            end            
            TreeBuilding_addStyle(app);

            % SelectedNode
            if exist('SelectedNode', 'var')
                app.Tree.SelectedNodes = SelectedNode;
            else
                app.Tree.SelectedNodes = app.Tree.Children(1).Children(1);
            end

            TreeSelectionChanged(app)
            expand(app.Tree, 'all')
        end

        %-----------------------------------------------------------------%
        function nodeText = TreeBuilding_nodeText(app, idx)
            Parameters = jsondecode(app.editedList.Parameters{idx});

            switch app.editedList.Type{idx}
                case 'Serial'
                    Socket = sprintf('%s', Parameters.Port);
                case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                    Socket = sprintf('%s:%s', Parameters.IP, Parameters.Port);
            end

            nodeText = sprintf('%s - %s', app.editedList.Name{idx}, Socket);
        end

        %-----------------------------------------------------------------%
        function TreeBuilding_addStyle(app)
            if ~isempty(app.Tree.StyleConfigurations)
                removeStyle(app.Tree)
            end

            h = [allchild(app.TreeNode_Receiver); ...
                 allchild(app.TreeNode_GPS)];

            DisableNodes = [];
            for ii = 1:numel(h)
                idx = h(ii).NodeData;
                if ~app.editedList.Enable(idx)
                    DisableNodes = [DisableNodes, h(ii)];
                end
            end

            if ~isempty(DisableNodes)
                s = uistyle('FontColor', [.5 .5 .5]);
                addStyle(app.Tree, s, 'node', DisableNodes)
            end
        end

        %-----------------------------------------------------------------%
        function Layout_FamilyChanged(app, srcFcn)
            switch app.Family.Value
                case 'Receiver'
                    idx = strcmp(app.receiverObj.Config.Family, app.Family.Value);
                    app.Name.Items = unique(app.receiverObj.Config.Name(idx));

                case 'GPS'
                    idx = strcmp(app.gpsObj.Config.Family, app.Family.Value);
                    app.Name.Items = app.gpsObj.Config.Name(idx);
            end

            if strcmp(srcFcn, 'InstrumentParameterChanged')
                Layout_NameChanged(app, srcFcn)
            end
        end

        %-----------------------------------------------------------------%
        function Layout_NameChanged(app, srcFcn)
            switch app.Family.Value
                case 'Receiver'
                    idx = find(strcmp(app.receiverObj.Config.Name, app.Name.Value), 1);
                    app.Type.Items = app.receiverObj.Config.connectType(idx);

                case 'GPS'
                    idx = strcmp(app.gpsObj.Config.Name, app.Name.Value);
                    app.Type.Items = app.gpsObj.Config.connectType(idx);
            end

            if strcmp(srcFcn, 'InstrumentParameterChanged')
                Layout_TypeValueChanged(app)
            end
        end

        %-----------------------------------------------------------------%
        function Layout_TypeValueChanged(app)
            switch app.Type.Value
                case 'Serial'
                    app.ParametersGrid.ColumnWidth([1 3]) = {0, '1x'};
                    portValidation = contains(app.Port.Value, 'COM');

                otherwise
                    app.ParametersGrid.ColumnWidth([1 3]) = {110, 0};

                    if isempty(app.IP.Value)
                        app.IP.Value = '127.0.0.1';
                    end
                    portValidation = ~isnan(str2double(app.Port.Value));
            end

            switch app.Family.Value
                case 'Receiver'
                    idx = find(strcmp(app.receiverObj.Config.Name, app.Name.Value), 1);
                    app.Port.Value = num2str(app.receiverObj.Config.connectPort(idx));

                case 'GPS'
                    if ~portValidation
                        idx = find(strcmp(app.gpsObj.Config.Name, app.Name.Value), 1);
                        app.Port.Value = app.gpsObj.Config.connectPort{idx};
                    end
            end

            Layout_LocalhostCheckBox1(app)
            Layout_LocalhostCheckBox2(app)
        end

        %-----------------------------------------------------------------%
        function Layout_LocalhostCheckBox1(app)
            app.LocalhostCheckBox.Enable = 0;

            if app.ButtonGroup_Edit.Value && strcmp(app.Type.Value, "TCP/UDP IP Socket")
                app.LocalhostCheckBox.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function Layout_LocalhostCheckBox2(app)
            if app.LocalhostCheckBox.Value
                set(app.LocalhostGrid2.Children, 'Enable', 1)

            else
                idx = app.Tree.SelectedNodes.NodeData;
                Parameters = jsondecode(app.editedList.Parameters{idx});

                if isfield(Parameters, 'Localhost_Enable')
                    Localhost_localIP  = Parameters.Localhost_localIP;
                    Localhost_publicIP = Parameters.Localhost_publicIP;
                else
                    Localhost_localIP  = '';
                    Localhost_publicIP = ''; 
                end

                set(app.localIP,  'Enable', 0, 'Value', Localhost_localIP)
                set(app.publicIP, 'Enable', 0, 'Value', Localhost_publicIP)
            end
        end

        %-----------------------------------------------------------------%
        function Layout_InstrumentSpecifications(app)            
            idx1 = app.Tree.SelectedNodes.NodeData;
            [htmlContent, imgSource] = util.HtmlTextGenerator.Instrument(app.receiverObj, app.gpsObj, app.editedList, idx1);

            app.instrMetadata.Text   = htmlContent;
            set(app.instrImage, 'ImageSource', imgSource, 'Visible', 'on')
        end

        %-----------------------------------------------------------------%
        function ParameterUpdate(app)
            idx = app.Tree.SelectedNodes.NodeData;

            switch app.Type.Value
                case 'Serial'
                    app.editedList.Parameters{idx} = jsonencode(struct('Port',     app.Port.Value,     ...
                                                                       'BaudRate', app.BaudRate.Value, ...
                                                                       'Timeout',  app.Timeout.Value));

                case 'TCPIP Socket'
                    app.editedList.Parameters{idx} = jsonencode(struct('IP',       app.IP.Value,       ...
                                                                       'Port',     app.Port.Value,     ...
                                                                       'Timeout',  app.Timeout.Value));
                
                case 'TCP/UDP IP Socket'
                    if app.LocalhostCheckBox.Value; Localhost_Enable = 1;
                    else;                           Localhost_Enable = 0;
                    end

                    app.editedList.Parameters{idx} = jsonencode(struct('IP',       app.IP.Value,                ...
                                                                       'Port',     app.Port.Value,              ...
                                                                       'Timeout',  app.Timeout.Value,           ...
                                                                       'Localhost_Enable',   Localhost_Enable,  ...
                                                                       'Localhost_localIP',  app.localIP.Value, ...
                                                                       'Localhost_publicIP', app.publicIP.Value));
            end
        end

        %-----------------------------------------------------------------%
        function Flag = IPv4Validation(app, event)            
            switch event.Source
                case app.IP;       ipAddress = app.IP.Value;
                case app.localIP;  ipAddress = app.localIP.Value;
                case app.publicIP; ipAddress = app.publicIP.Value;
            end

            ipString = regexp(ipAddress, '\d*[.]{1}\d{1,3}[.]{1}\d{1,3}[.]{1}\d*', 'match');

            Flag = 0;
            if isempty(ipString)
                Flag = 1;
            else
                ipArray = cellfun(@(x) str2double(x), strsplit(char(ipString), '.'));
                if any(ipArray > 255) || any(isnan(ipArray))
                    Flag = 1;
                end                    
            end

            if Flag
                appUtil.modalWindow(app.UIFigure, 'warning', 'Endereço IP inválido');

                switch event.Source
                    case app.IP;       app.IP.Value       = event.PreviousValue;
                    case app.localIP;  app.localIP.Value  = event.PreviousValue;
                    case app.publicIP; app.publicIP.Value = event.PreviousValue;
                end
            else
                if ~strcmp(ipAddress, char(ipString))
                    switch event.Source
                        case app.IP;       app.IP.Value       = char(ipString);
                        case app.localIP;  app.localIP.Value  = char(ipString);
                        case app.publicIP; app.publicIP.Value = char(ipString);
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function Flag = PortValidation(app, event)
            Flag = 0;

            switch app.Type.Value
                case 'Serial'
                    portValidation = regexpi(app.Port.Value, 'COM\d+', 'match');
                    if isempty(portValidation)
                        Flag = 1;
                    end

                case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                    portValidation = regexp(app.Port.Value, '\d+', 'match');
                    if isempty(portValidation)
                        Flag = 1;
                    else
                        if str2double(portValidation) > 65535
                            Flag = 1;
                        end
                    end
            end

            if Flag
                appUtil.modalWindow(app.UIFigure, 'warning', 'Porta inválida');
                app.Port.Value = event.PreviousValue;
                
            else
                if ~strcmpi(app.Port.Value, char(portValidation))
                    app.Port.Value = upper(char(portValidation));
                end
            end
        end

        %-----------------------------------------------------------------%
        function [idx, msgError] = SelectionNodeValidation(app)
            try
                idx = app.Tree.SelectedNodes.NodeData;

                if isempty(idx)
                    switch app.Tree.SelectedNodes
                        case app.TreeNode_Receiver
                            app.Tree.SelectedNodes = app.TreeNode_Receiver.Children(1);
    
                        case app.TreeNode_GPS
                            if ~isempty(app.TreeNode_GPS.Children)
                                app.Tree.SelectedNodes = app.TreeNode_GPS.Children(1);
                            else
                                app.Tree.SelectedNodes = app.TreeNode_Receiver.Children(1);
                            end
                    end
                    idx = app.Tree.SelectedNodes.NodeData;
                end

                msgError = '';

            catch ME
                app.Tree.SelectedNodes = app.TreeNode_Receiver.Children(1);
                idx = app.Tree.SelectedNodes.NodeData;

                msgError = ME.message;
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function update(app)
            saveNewFile(app, fullfile(app.mainApp.rootFolder, 'config'), false)

            % Após salva a nova versão de "instrumentList.json", atualizam-se
            % as listas dos objetos HANDLE app.receiverObj e app.gpsObj.
            app.receiverObj.List = FileRead(app.receiverObj, app.mainApp.rootFolder);                
            gpsObjList = FileRead(app.gpsObj, app.mainApp.rootFolder);
            if ~isempty(gpsObjList)
                app.gpsObj.List = gpsObjList;
            else
                app.gpsObj.List(:,:) = [];
            end

            % Fecha o módulo auxiliar "auxApp.winAddTask.mlapp", caso aberto.
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'TASK:ADD')
        end

        %-----------------------------------------------------------------%
        function saveNewFile(app, Folder, ShowAlert)

            fileList = table2struct(app.instrumentList);
            for ii = 1:numel(fileList)
                fileList(ii).Parameters = jsondecode(fileList(ii).Parameters);

                % Eliminar informação relacionada à localhost, caso não tenha 
                % sido preenchidos ao menos um dos campos de IP - "ip_local" 
                % ou "ip_público".

                if isfield(fileList(ii).Parameters, 'Localhost_Enable')
                    if fileList(ii).Parameters.Localhost_Enable  && isempty(fileList(ii).Parameters.Localhost_localIP) && isempty(fileList(ii).Parameters.Localhost_publicIP)
                        fileList(ii).Parameters = rmfield(fileList(ii).Parameters, {'Localhost_Enable', 'Localhost_localIP', 'Localhost_publicIP'});
                    end
                end
            end

            try
                fileID = fopen(fullfile(Folder, 'instrumentList.json'), 'wt');
                fwrite(fileID, jsonencode(fileList, 'PrettyPrint', true));
                fclose(fileID);

                if ShowAlert
                    appUtil.modalWindow(app.UIFigure, 'warning', sprintf('Arquivo <b>instrumentList.json</b> salvo na pasta "%s"', Folder));
                end
            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end
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
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'INSTRUMENT')
            delete(app)
            
        end

        % Selection changed function: Tree
        function TreeSelectionChanged(app, event)
            
            % Caso o nó selecionado da árvore seja o "RECEPTOR" ou "GPS",
            % busca-se o seu primeiro filho, caso existente.

            idx = SelectionNodeValidation(app);

            % Ajuste dos itens que são listas suspensas (uidropdown)
            % porque no "MODO DE EDIÇÃO" todos os possíveis valores
            % estão disponíveis para escolha, enquanto que no "MODO DE
            % VISUALIZAÇÃO" ficará disponível apenas o valor indicado
            % no "taskList.json".

            %---------------------------------------------------------%
            % ## MODO DE VISUALIZAÇÃO ##
            %---------------------------------------------------------%
            if app.ButtonGroup_View.Value
                if app.editedList.Enable(idx); app.Status.Items = {'ON'};
                else;                          app.Status.Items = {'OFF'};
                end

                app.Family.Items = app.editedList.Family(idx);
                app.Name.Items   = app.editedList.Name(idx);
                app.Type.Items   = app.editedList.Type(idx);

            %---------------------------------------------------------%
            % ## MODO DE EDIÇÃO ##
            %---------------------------------------------------------%
            else
                if app.editedList.Enable(idx); app.Status.Value = 'ON';
                else;                          app.Status.Value = 'OFF';
                end

                app.Family.Value = app.editedList.Family{idx};
                Layout_FamilyChanged(app, '')
                
                app.Name.Value = app.editedList.Name{idx};
                Layout_NameChanged(app, 'InstrumentParameterChanged')

                app.Type.Value = app.editedList.Type{idx};
            end            

            % Ajustes nos outros campos (que não são listas suspensas), 
            % além de especificidades do campo "Fator integração" e dos
            % parâmetros relacionados à busca de emissões.

            app.Description.Value = app.editedList.Description{idx};
            app.LocalhostCheckBox.Value = 0;

            Parameters = jsondecode(app.editedList.Parameters{idx});
            switch app.Type.Value
                case 'Serial'
                    app.IP.Value       = '';
                    app.Port.Value     = Parameters.Port;
                    app.BaudRate.Value = Parameters.BaudRate;

                case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                    app.IP.Value       = Parameters.IP;
                    app.Port.Value     = Parameters.Port;

                    if isfield(Parameters, 'Localhost_Enable')
                        app.LocalhostCheckBox.Value = Parameters.Localhost_Enable;
                        app.localIP.Value  = Parameters.Localhost_localIP;
                        app.publicIP.Value = Parameters.Localhost_publicIP;
                    else
                        app.LocalhostCheckBox.Value = 0;
                        app.localIP.Value           = '';
                        app.publicIP.Value          = '';
                    end
            end

            if isfield(Parameters, 'Timeout');  app.Timeout.Value = Parameters.Timeout;
            else;                               app.Timeout.Value = class.Constants.Timeout;
            end
            
            % Os últimos ajustes consistem na validação do campo "Port",
            % assim como atualização estética do instrumento.

            Layout_TypeValueChanged(app)
            Layout_InstrumentSpecifications(app)
            
        end

        % Selection changed function: ModePanel
        function ValueChanged_OperationMode(app, event)
            
            %-------------------------------------------------------------%
            % ## MODO DE VISUALIZAÇÃO ##
            %-------------------------------------------------------------%
            if app.ButtonGroup_View.Value
                % Aspectos relacionados à indicação visual de que se trata 
                % do modo de visualização:

                set(findobj(app.Tab1_Grid, 'Type', 'uiimage'), Enable='off')
                app.Tab1_Grid.ColumnWidth{end} = 0;
                app.toolButton_edit.Visible  = 0;
                app.toolButton_open.Enable   = 'on';
                app.toolButton_export.Enable = 'on';                

                % Desabilita edição do conteúdo dos campos...

                app.Description.Editable = 'off';
                set(findobj(app.ParametersGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')
                set(findobj(app.LocalhostGrid2, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')
                app.LocalhostCheckBox.Enable = 0;

                set(app.Status, 'Items', {app.Status.Value})
                set(app.Family, 'Items', {app.Family.Value})
                set(app.Name,   'Items', {app.Name.Value})
                set(app.Type,   'Items', {app.Type.Value})

                % Essa última validação é essencial para desfazer alterações 
                % que não foram salvas. Ou seja, o usuário fez alterações
                % em app.taskList (que estavam armazenadas na sua cópia -
                % app.editedList) e não clicou no botão "Confirma edição".

                if ~isequal(app.instrumentList, app.editedList)
                    app.editedList = app.instrumentList;
                    TreeBuilding(app, [])
                end

            %-------------------------------------------------------------%
            % ## MODO DE EDIÇÃO ##
            %-------------------------------------------------------------%
            else
                % Aspectos relacionados à indicação visual de que se trata 
                % do modo de edição:

                set(app.Tab1_Grid.Children, Enable='on')
                app.Tab1_Grid.ColumnWidth{end} = 16;
                app.toolButton_edit.Visible  = 1;
                app.toolButton_open.Enable   = 'off';
                app.toolButton_export.Enable = 'off';

                % Habilita edição do conteúdo dos campos...

                app.Description.Editable = 'on';
                set(findobj(app.ParametersGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                set(findobj(app.LocalhostGrid2, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                app.LocalhostCheckBox.Enable = 1;

                set(app.Status, 'Items', {'ON', 'OFF'})
                set(app.Family, 'Items', {'Receiver', 'GPS'})
                Layout_FamilyChanged(app, 'InstrumentParameterChanged')
            end

        end

        % Value changed function: BaudRate, Description, Family, IP, 
        % ...and 8 other components
        function ValueChanged_Parameter(app, event)
            
            [idx, msgError] = SelectionNodeValidation(app);

            if ~isempty(msgError)
                TreeSelectionChanged(app)
                return
            end


            switch event.Source
                %---------------------------------------------------------%
                case app.Status
                    if app.Status.Value == "ON"
                        app.editedList.Enable(idx) = 1;
                    else
                        app.editedList.Enable(idx) = 0;
                    end

                %---------------------------------------------------------%
                case app.Family
                    Layout_FamilyChanged(app, 'InstrumentParameterChanged')
                    
                    app.editedList.Family{idx} = app.Family.Value;
                    app.editedList.Name{idx}   = app.Name.Value;
                    app.editedList.Type{idx}   = app.Type.Value;
                    
                    Layout_InstrumentSpecifications(app)
                    ParameterUpdate(app)
                    
                %---------------------------------------------------------%
                case app.Name
                    Layout_NameChanged(app, 'InstrumentParameterChanged')

                    app.editedList.Name{idx} = app.Name.Value;
                    app.editedList.Type{idx} = app.Type.Value;

                    Layout_InstrumentSpecifications(app)
                    ParameterUpdate(app)

                %---------------------------------------------------------%
                case app.Type
                    Layout_TypeValueChanged(app)                    

                    app.editedList.Type{idx} = app.Type.Value;
                    ParameterUpdate(app)

                %---------------------------------------------------------%
                case {app.Port, app.IP, app.localIP, app.publicIP}
                    Flag = 0;

                    if ~isempty(event.Source.Value)
                        if event.Source == app.Port
                            Flag = PortValidation(app, event);
                        else
                            Flag = IPv4Validation(app, event);
                        end
                    end

                    if ~Flag
                        ParameterUpdate(app)
                    end

                %---------------------------------------------------------%
                case app.BaudRate
                    ParameterUpdate(app)

                %---------------------------------------------------------%
                case app.Timeout
                    ParameterUpdate(app)

                %---------------------------------------------------------%
                case app.LocalhostCheckBox
                    Layout_LocalhostCheckBox2(app)
                    ParameterUpdate(app)

                %---------------------------------------------------------%
                case app.Description
                    app.editedList.Description{idx} = strjoin(app.Description.Value);
            end

            % Recriando a árvore...
            TreeBuilding(app, idx)
            
        end

        % Image clicked function: Image_add
        function ImageClicked_add(app, event)
            
            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                idx_old = idx;
                idx_new = height(app.editedList) + 1;
    
                app.editedList(idx_new,:) = app.editedList(idx_old,:);
                TreeBuilding(app, idx_new)
            end

        end

        % Image clicked function: Image_del
        function ImageClicked_del(app, event)
            
            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                nodeParent = app.Tree.SelectedNodes.Parent;

                if nodeParent == app.TreeNode_Receiver    
                    if isscalar(nodeParent.Children)
                        return;
                    end
                end

                app.editedList(idx,:) = [];
                TreeBuilding(app, [])
            end

        end

        % Image clicked function: Image_downArrow, Image_upArrow
        function ImageClicked_UpDownArrows(app, event)
            
            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                idx1_old = idx;
                idx2_old = app.Tree.SelectedNodes.UserData;
                Parent   = app.Tree.SelectedNodes.Parent;
    
                Flag     = 0;
                switch event.Source
                    case app.Image_upArrow
                        if idx2_old > 1
                            idx1_new = Parent.Children(idx2_old-1).NodeData;
                            Flag     = 1;
                        end
    
                    case app.Image_downArrow
                        if idx2_old < numel(Parent.Children)
                            idx1_new = Parent.Children(idx2_old+1).NodeData;
                            Flag     = 1;
                        end
                end
    
                if Flag
                    app.editedList([idx1_old, idx1_new],:) = flip(app.editedList([idx1_old, idx1_new],:));
                    TreeBuilding(app, idx1_new)
                end
            end

        end

        % Image clicked function: toolButton_open
        function toolButtonPushed_open(app, event)
            
            [File, Folder] = uigetfile({'*.json', '*.json'}, 'Selecione um arquivo', 'MultiSelect', 'off');
            figure(app.UIFigure)

            if File
                try
                    tempList = fcn.instrumentListRead(fullfile(Folder, File));

                    if ~isempty(tempList)
                        app.instrumentList = [app.instrumentList; tempList];
                        app.editedList     = app.instrumentList;
                        update(app)
    
                        TreeBuilding(app, [])
                    end

                catch ME
                    appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
                end
            end

        end

        % Image clicked function: toolButton_export
        function toolButtonPushed_export(app, event)
            
            Folder = uigetdir(app.mainApp.General.fileFolder.userPath, 'Escolha o diretório em que será salva a lista de instrumentos');
            figure(app.UIFigure)

            if Folder
                saveNewFile(app, Folder, true)
            end

        end

        % Button pushed function: toolButton_connectTest
        function toolButtonPushed_connectTest(app, event)
            
            app.progressDialog.Visible = 'visible';

            % O "idx1" se refere ao índice da tabela completa extraída de
            % "instrumentList.json" (possivelmente já editada), incluindo 
            % receptores e GPSs.

            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                idx1 = idx;
    
                switch app.Family.Value
                    case 'Receiver'
                        idx2 = find(strcmp(app.receiverObj.Config.Name, app.Name.Value), 1);
                        instrSelected = struct('Type',       app.Type.Value,                   ...
                                               'Tag',        app.receiverObj.Config.Tag{idx2}, ...
                                               'Parameters', jsondecode(app.editedList.Parameters{idx1}));
    
                        fcn.ConnectivityTest_Receiver(app, instrSelected, 1);
    
                    case 'GPS'
                        instrSelected = struct('Type',       app.Type.Value, ...
                                               'Parameters', jsondecode(app.editedList.Parameters{idx1}));
    
                        fcn.ConnectivityTest_GPS(app, instrSelected, 1);
                end
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Button pushed function: toolButton_edit
        function toolButtonPushed_edit(app, event)
            
            % Finalizada a edição, avalia-se se algum parâmetro foi, de fato, 
            % alterado, salvando uma nova versão do arquivo "instrumentList.json",
            % caso necessário.             
            if ~isequal(app.instrumentList, app.editedList)
                app.instrumentList = app.editedList;
                update(app)
            end
            
            app.ButtonGroup_View.Value = 1;
            ValueChanged_OperationMode(app)

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
                app.UIFigure.Position = [100 100 1146 540];
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
            app.Toolbar.ColumnWidth = {22, 22, 5, 22, '1x', 110};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 5];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create toolSeparator
            app.toolSeparator = uiimage(app.Toolbar);
            app.toolSeparator.ScaleMethod = 'none';
            app.toolSeparator.Enable = 'off';
            app.toolSeparator.Layout.Row = 1;
            app.toolSeparator.Layout.Column = 3;
            app.toolSeparator.ImageSource = 'LineV.svg';

            % Create toolButton_connectTest
            app.toolButton_connectTest = uibutton(app.Toolbar, 'push');
            app.toolButton_connectTest.ButtonPushedFcn = createCallbackFcn(app, @toolButtonPushed_connectTest, true);
            app.toolButton_connectTest.Icon = 'Connectivity_32.png';
            app.toolButton_connectTest.BackgroundColor = [0.9412 0.9412 0.9412];
            app.toolButton_connectTest.Tooltip = {'Teste de conectividade'};
            app.toolButton_connectTest.Layout.Row = 1;
            app.toolButton_connectTest.Layout.Column = 4;
            app.toolButton_connectTest.Text = '';

            % Create toolButton_edit
            app.toolButton_edit = uibutton(app.Toolbar, 'push');
            app.toolButton_edit.ButtonPushedFcn = createCallbackFcn(app, @toolButtonPushed_edit, true);
            app.toolButton_edit.Icon = 'Edit_32White.png';
            app.toolButton_edit.IconAlignment = 'right';
            app.toolButton_edit.HorizontalAlignment = 'right';
            app.toolButton_edit.BackgroundColor = [0.6392 0.0784 0.1804];
            app.toolButton_edit.FontSize = 11;
            app.toolButton_edit.FontColor = [1 1 1];
            app.toolButton_edit.Visible = 'off';
            app.toolButton_edit.Layout.Row = 1;
            app.toolButton_edit.Layout.Column = 6;
            app.toolButton_edit.Text = 'Confirma edição';

            % Create toolButton_open
            app.toolButton_open = uiimage(app.Toolbar);
            app.toolButton_open.ScaleMethod = 'none';
            app.toolButton_open.ImageClickedFcn = createCallbackFcn(app, @toolButtonPushed_open, true);
            app.toolButton_open.Tooltip = {'Abre arquivo .json com lista de tarefas'};
            app.toolButton_open.Layout.Row = 1;
            app.toolButton_open.Layout.Column = 1;
            app.toolButton_open.ImageSource = 'Import_16.png';

            % Create toolButton_export
            app.toolButton_export = uiimage(app.Toolbar);
            app.toolButton_export.ScaleMethod = 'none';
            app.toolButton_export.ImageClickedFcn = createCallbackFcn(app, @toolButtonPushed_export, true);
            app.toolButton_export.Tooltip = {'Exporta arquivo .json com lista de tarefas'};
            app.toolButton_export.Layout.Row = 1;
            app.toolButton_export.Layout.Column = 2;
            app.toolButton_export.ImageSource = 'Export_16.png';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.AutoResizeChildren = 'off';
            app.TabGroup.Layout.Row = [3 4];
            app.TabGroup.Layout.Column = [2 3];

            % Create Tab
            app.Tab = uitab(app.TabGroup);
            app.Tab.AutoResizeChildren = 'off';
            app.Tab.Title = 'LISTA DE INSTRUMENTOS';

            % Create TabGrid
            app.TabGrid = uigridlayout(app.Tab);
            app.TabGrid.ColumnWidth = {310, '1x'};
            app.TabGrid.RowHeight = {17, 34, 22, '1x'};
            app.TabGrid.RowSpacing = 5;
            app.TabGrid.BackgroundColor = [1 1 1];

            % Create ModePanelLabel
            app.ModePanelLabel = uilabel(app.TabGrid);
            app.ModePanelLabel.VerticalAlignment = 'bottom';
            app.ModePanelLabel.FontSize = 10;
            app.ModePanelLabel.Layout.Row = 1;
            app.ModePanelLabel.Layout.Column = 1;
            app.ModePanelLabel.Text = 'MODO:';

            % Create ModePanel
            app.ModePanel = uibuttongroup(app.TabGrid);
            app.ModePanel.AutoResizeChildren = 'off';
            app.ModePanel.SelectionChangedFcn = createCallbackFcn(app, @ValueChanged_OperationMode, true);
            app.ModePanel.BackgroundColor = [1 1 1];
            app.ModePanel.Layout.Row = 2;
            app.ModePanel.Layout.Column = 1;
            app.ModePanel.FontSize = 10;

            % Create ButtonGroup_View
            app.ButtonGroup_View = uiradiobutton(app.ModePanel);
            app.ButtonGroup_View.Text = '<font style="color:#0000ff;">VISUALIZAR</font> lista';
            app.ButtonGroup_View.FontSize = 11;
            app.ButtonGroup_View.Interpreter = 'html';
            app.ButtonGroup_View.Position = [6 5 117 22];
            app.ButtonGroup_View.Value = true;

            % Create ButtonGroup_Edit
            app.ButtonGroup_Edit = uiradiobutton(app.ModePanel);
            app.ButtonGroup_Edit.Text = '<font style="color:#a2142f;"><b>EDITAR</b></font> lista';
            app.ButtonGroup_Edit.FontSize = 11;
            app.ButtonGroup_Edit.Interpreter = 'html';
            app.ButtonGroup_Edit.Position = [150 5 92 22];

            % Create TreeLabel
            app.TreeLabel = uilabel(app.TabGrid);
            app.TreeLabel.VerticalAlignment = 'bottom';
            app.TreeLabel.FontSize = 10;
            app.TreeLabel.Layout.Row = 3;
            app.TreeLabel.Layout.Column = 1;
            app.TreeLabel.Text = 'INSTRUMENTOS:';

            % Create PanelLabel
            app.PanelLabel = uilabel(app.TabGrid);
            app.PanelLabel.VerticalAlignment = 'bottom';
            app.PanelLabel.FontSize = 10;
            app.PanelLabel.Layout.Row = 1;
            app.PanelLabel.Layout.Column = 2;
            app.PanelLabel.Text = 'CARACTERÍSTICAS:';

            % Create Panel
            app.Panel = uipanel(app.TabGrid);
            app.Panel.AutoResizeChildren = 'off';
            app.Panel.Layout.Row = [2 4];
            app.Panel.Layout.Column = 2;

            % Create Tab2_PanelGrid
            app.Tab2_PanelGrid = uigridlayout(app.Panel);
            app.Tab2_PanelGrid.ColumnWidth = {110, 190, '1x', 140, 22};
            app.Tab2_PanelGrid.RowHeight = {17, 22, 22, 22, 22, '1x', 22, 22, 150};
            app.Tab2_PanelGrid.RowSpacing = 5;
            app.Tab2_PanelGrid.BackgroundColor = [1 1 1];

            % Create StatusLabel
            app.StatusLabel = uilabel(app.Tab2_PanelGrid);
            app.StatusLabel.VerticalAlignment = 'bottom';
            app.StatusLabel.FontSize = 10;
            app.StatusLabel.FontColor = [0.149 0.149 0.149];
            app.StatusLabel.Layout.Row = 1;
            app.StatusLabel.Layout.Column = 1;
            app.StatusLabel.Text = 'Estado:';

            % Create Status
            app.Status = uidropdown(app.Tab2_PanelGrid);
            app.Status.Items = {'ON', 'OFF'};
            app.Status.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Status.FontSize = 11;
            app.Status.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Status.Layout.Row = 2;
            app.Status.Layout.Column = 1;
            app.Status.Value = 'ON';

            % Create FamilyLabel
            app.FamilyLabel = uilabel(app.Tab2_PanelGrid);
            app.FamilyLabel.VerticalAlignment = 'bottom';
            app.FamilyLabel.FontSize = 10;
            app.FamilyLabel.Layout.Row = 1;
            app.FamilyLabel.Layout.Column = 2;
            app.FamilyLabel.Text = 'Família:';

            % Create Family
            app.Family = uidropdown(app.Tab2_PanelGrid);
            app.Family.Items = {};
            app.Family.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Family.FontSize = 11;
            app.Family.BackgroundColor = [1 1 1];
            app.Family.Layout.Row = 2;
            app.Family.Layout.Column = 2;
            app.Family.Value = {};

            % Create NameLabel
            app.NameLabel = uilabel(app.Tab2_PanelGrid);
            app.NameLabel.VerticalAlignment = 'bottom';
            app.NameLabel.FontSize = 10;
            app.NameLabel.Layout.Row = 3;
            app.NameLabel.Layout.Column = 1;
            app.NameLabel.Text = 'Fabricante e modelo:';

            % Create Name
            app.Name = uidropdown(app.Tab2_PanelGrid);
            app.Name.Items = {};
            app.Name.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Name.FontSize = 11;
            app.Name.BackgroundColor = [1 1 1];
            app.Name.Layout.Row = 4;
            app.Name.Layout.Column = [1 2];
            app.Name.Value = {};

            % Create DescriptionLabel
            app.DescriptionLabel = uilabel(app.Tab2_PanelGrid);
            app.DescriptionLabel.VerticalAlignment = 'bottom';
            app.DescriptionLabel.FontSize = 10;
            app.DescriptionLabel.Layout.Row = 5;
            app.DescriptionLabel.Layout.Column = 1;
            app.DescriptionLabel.Text = 'Descrição (opcional):';

            % Create Description
            app.Description = uitextarea(app.Tab2_PanelGrid);
            app.Description.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Description.Editable = 'off';
            app.Description.FontSize = 11;
            app.Description.Layout.Row = 6;
            app.Description.Layout.Column = [1 2];

            % Create TypeLabel
            app.TypeLabel = uilabel(app.Tab2_PanelGrid);
            app.TypeLabel.VerticalAlignment = 'bottom';
            app.TypeLabel.FontSize = 10;
            app.TypeLabel.Layout.Row = 7;
            app.TypeLabel.Layout.Column = 1;
            app.TypeLabel.Text = 'Tipo de conexão:';

            % Create Type
            app.Type = uidropdown(app.Tab2_PanelGrid);
            app.Type.Items = {};
            app.Type.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Type.FontSize = 11;
            app.Type.BackgroundColor = [1 1 1];
            app.Type.Layout.Row = 8;
            app.Type.Layout.Column = [1 2];
            app.Type.Value = {};

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.Tab2_PanelGrid);
            app.ParametersPanel.AutoResizeChildren = 'off';
            app.ParametersPanel.Layout.Row = 9;
            app.ParametersPanel.Layout.Column = [1 2];

            % Create ParametersGrid
            app.ParametersGrid = uigridlayout(app.ParametersPanel);
            app.ParametersGrid.ColumnWidth = {110, '1x', '1x', '1x'};
            app.ParametersGrid.RowHeight = {17, 22, 17, '1x'};
            app.ParametersGrid.RowSpacing = 5;
            app.ParametersGrid.Padding = [10 10 10 5];
            app.ParametersGrid.BackgroundColor = [1 1 1];

            % Create IPLabel
            app.IPLabel = uilabel(app.ParametersGrid);
            app.IPLabel.VerticalAlignment = 'bottom';
            app.IPLabel.FontSize = 10;
            app.IPLabel.Layout.Row = 1;
            app.IPLabel.Layout.Column = 1;
            app.IPLabel.Text = 'Endereço IP:';

            % Create IP
            app.IP = uieditfield(app.ParametersGrid, 'text');
            app.IP.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.IP.Editable = 'off';
            app.IP.FontSize = 11;
            app.IP.Layout.Row = 2;
            app.IP.Layout.Column = 1;

            % Create PortLabel
            app.PortLabel = uilabel(app.ParametersGrid);
            app.PortLabel.VerticalAlignment = 'bottom';
            app.PortLabel.FontSize = 10;
            app.PortLabel.Layout.Row = 1;
            app.PortLabel.Layout.Column = 2;
            app.PortLabel.Text = 'Porta:';

            % Create Port
            app.Port = uieditfield(app.ParametersGrid, 'text');
            app.Port.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Port.Editable = 'off';
            app.Port.FontSize = 11;
            app.Port.Layout.Row = 2;
            app.Port.Layout.Column = 2;

            % Create BaudRateLabel
            app.BaudRateLabel = uilabel(app.ParametersGrid);
            app.BaudRateLabel.VerticalAlignment = 'bottom';
            app.BaudRateLabel.FontSize = 10;
            app.BaudRateLabel.Layout.Row = 1;
            app.BaudRateLabel.Layout.Column = 3;
            app.BaudRateLabel.Text = 'BaudRate:';

            % Create BaudRate
            app.BaudRate = uieditfield(app.ParametersGrid, 'numeric');
            app.BaudRate.Limits = [0 Inf];
            app.BaudRate.RoundFractionalValues = 'on';
            app.BaudRate.ValueDisplayFormat = '%.0f';
            app.BaudRate.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.BaudRate.Editable = 'off';
            app.BaudRate.FontSize = 11;
            app.BaudRate.Layout.Row = 2;
            app.BaudRate.Layout.Column = 3;
            app.BaudRate.Value = 9600;

            % Create TimeoutLabel
            app.TimeoutLabel = uilabel(app.ParametersGrid);
            app.TimeoutLabel.VerticalAlignment = 'bottom';
            app.TimeoutLabel.FontSize = 10;
            app.TimeoutLabel.Layout.Row = 1;
            app.TimeoutLabel.Layout.Column = 4;
            app.TimeoutLabel.Text = 'Timeout:';

            % Create Timeout
            app.Timeout = uieditfield(app.ParametersGrid, 'numeric');
            app.Timeout.Limits = [1 20];
            app.Timeout.RoundFractionalValues = 'on';
            app.Timeout.ValueDisplayFormat = '%.0f';
            app.Timeout.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Timeout.Editable = 'off';
            app.Timeout.FontSize = 11;
            app.Timeout.Layout.Row = 2;
            app.Timeout.Layout.Column = 4;
            app.Timeout.Value = 5;

            % Create LocalhostCheckBox
            app.LocalhostCheckBox = uicheckbox(app.ParametersGrid);
            app.LocalhostCheckBox.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.LocalhostCheckBox.Enable = 'off';
            app.LocalhostCheckBox.Text = 'Localhost';
            app.LocalhostCheckBox.FontSize = 10;
            app.LocalhostCheckBox.Layout.Row = 3;
            app.LocalhostCheckBox.Layout.Column = [1 4];

            % Create LocalhostPanel
            app.LocalhostPanel = uipanel(app.ParametersGrid);
            app.LocalhostPanel.AutoResizeChildren = 'off';
            app.LocalhostPanel.Layout.Row = 4;
            app.LocalhostPanel.Layout.Column = [1 4];

            % Create LocalhostGrid2
            app.LocalhostGrid2 = uigridlayout(app.LocalhostPanel);
            app.LocalhostGrid2.RowHeight = {17, 22};
            app.LocalhostGrid2.RowSpacing = 5;
            app.LocalhostGrid2.Padding = [10 10 10 5];
            app.LocalhostGrid2.BackgroundColor = [1 1 1];

            % Create localIPLabel
            app.localIPLabel = uilabel(app.LocalhostGrid2);
            app.localIPLabel.FontSize = 10;
            app.localIPLabel.Layout.Row = 1;
            app.localIPLabel.Layout.Column = 1;
            app.localIPLabel.Text = 'IP local:';

            % Create localIP
            app.localIP = uieditfield(app.LocalhostGrid2, 'text');
            app.localIP.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.localIP.Editable = 'off';
            app.localIP.FontSize = 11;
            app.localIP.Enable = 'off';
            app.localIP.Layout.Row = 2;
            app.localIP.Layout.Column = 1;

            % Create publicIPLabel
            app.publicIPLabel = uilabel(app.LocalhostGrid2);
            app.publicIPLabel.FontSize = 10;
            app.publicIPLabel.Layout.Row = 1;
            app.publicIPLabel.Layout.Column = 2;
            app.publicIPLabel.Text = 'IP público:';

            % Create publicIP
            app.publicIP = uieditfield(app.LocalhostGrid2, 'text');
            app.publicIP.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.publicIP.Editable = 'off';
            app.publicIP.FontSize = 11;
            app.publicIP.Enable = 'off';
            app.publicIP.Layout.Row = 2;
            app.publicIP.Layout.Column = 2;

            % Create instrMetadata
            app.instrMetadata = uilabel(app.Tab2_PanelGrid);
            app.instrMetadata.VerticalAlignment = 'top';
            app.instrMetadata.WordWrap = 'on';
            app.instrMetadata.FontSize = 11;
            app.instrMetadata.Layout.Row = [2 9];
            app.instrMetadata.Layout.Column = [3 5];
            app.instrMetadata.Interpreter = 'html';
            app.instrMetadata.Text = '';

            % Create instrImage
            app.instrImage = uiimage(app.Tab2_PanelGrid);
            app.instrImage.Visible = 'off';
            app.instrImage.Layout.Row = [3 5];
            app.instrImage.Layout.Column = 4;
            app.instrImage.HorizontalAlignment = 'right';
            app.instrImage.VerticalAlignment = 'top';

            % Create AspectostcnicosLabel
            app.AspectostcnicosLabel = uilabel(app.Tab2_PanelGrid);
            app.AspectostcnicosLabel.VerticalAlignment = 'bottom';
            app.AspectostcnicosLabel.FontSize = 10;
            app.AspectostcnicosLabel.Layout.Row = 1;
            app.AspectostcnicosLabel.Layout.Column = 3;
            app.AspectostcnicosLabel.Text = 'Aspectos técnicos:';

            % Create Tab1_Grid
            app.Tab1_Grid = uigridlayout(app.TabGrid);
            app.Tab1_Grid.ColumnWidth = {2, 146, '1x', 0};
            app.Tab1_Grid.RowHeight = {16, 5, 16, '1x', 16, 5, 16};
            app.Tab1_Grid.ColumnSpacing = 5;
            app.Tab1_Grid.RowSpacing = 0;
            app.Tab1_Grid.Padding = [0 0 0 0];
            app.Tab1_Grid.Layout.Row = 4;
            app.Tab1_Grid.Layout.Column = 1;
            app.Tab1_Grid.BackgroundColor = [1 1 1];

            % Create Tree
            app.Tree = uitree(app.Tab1_Grid);
            app.Tree.SelectionChangedFcn = createCallbackFcn(app, @TreeSelectionChanged, true);
            app.Tree.FontSize = 10;
            app.Tree.Layout.Row = [1 7];
            app.Tree.Layout.Column = [1 3];

            % Create TreeNode_Receiver
            app.TreeNode_Receiver = uitreenode(app.Tree);
            app.TreeNode_Receiver.Text = 'RECEPTOR';

            % Create TreeNode_GPS
            app.TreeNode_GPS = uitreenode(app.Tree);
            app.TreeNode_GPS.Text = 'GPS';

            % Create Image_add
            app.Image_add = uiimage(app.Tab1_Grid);
            app.Image_add.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_add, true);
            app.Image_add.Enable = 'off';
            app.Image_add.Tooltip = {'Adiciona novo instrumento'};
            app.Image_add.Layout.Row = 1;
            app.Image_add.Layout.Column = 4;
            app.Image_add.ImageSource = 'addFileWithPlus_32.png';

            % Create Image_del
            app.Image_del = uiimage(app.Tab1_Grid);
            app.Image_del.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_del, true);
            app.Image_del.Enable = 'off';
            app.Image_del.Tooltip = {'Exclui instrumento selecionado'};
            app.Image_del.Layout.Row = 3;
            app.Image_del.Layout.Column = 4;
            app.Image_del.ImageSource = 'Delete_32Red.png';

            % Create Image_upArrow
            app.Image_upArrow = uiimage(app.Tab1_Grid);
            app.Image_upArrow.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_UpDownArrows, true);
            app.Image_upArrow.Enable = 'off';
            app.Image_upArrow.Tooltip = {'Troca ordem do instrumento selecionado'};
            app.Image_upArrow.Layout.Row = 5;
            app.Image_upArrow.Layout.Column = 4;
            app.Image_upArrow.ImageSource = 'ArrowUp_32.png';

            % Create Image_downArrow
            app.Image_downArrow = uiimage(app.Tab1_Grid);
            app.Image_downArrow.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_UpDownArrows, true);
            app.Image_downArrow.Enable = 'off';
            app.Image_downArrow.Tooltip = {'Troca ordem do instrumento selecionado'};
            app.Image_downArrow.Layout.Row = 7;
            app.Image_downArrow.Layout.Column = 4;
            app.Image_downArrow.ImageSource = 'ArrowDown_32.png';

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
        function app = winInstrument_exported(Container, varargin)

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
