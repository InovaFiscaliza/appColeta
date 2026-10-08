classdef winInstrument_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        DockModule              matlab.ui.container.GridLayout
        DockCloseButton         matlab.ui.control.Image
        DockUndockButton        matlab.ui.control.Image
        Toolbar                 matlab.ui.container.GridLayout
        ConfirmEditionButton    matlab.ui.control.Button
        TestConnectivityButton  matlab.ui.control.Button
        ButtonsSeparator        matlab.ui.control.Image
        ExportButton            matlab.ui.control.Image
        ImportButton            matlab.ui.control.Image
        SubTabGroup             matlab.ui.container.TabGroup
        SubTab1                 matlab.ui.container.Tab
        SubGrid1                matlab.ui.container.GridLayout
        InstrumentGrid          matlab.ui.container.GridLayout
        Image                   matlab.ui.control.Image
        Features                matlab.ui.control.Label
        FeaturesLabel           matlab.ui.control.Label
        ParametersPanel         matlab.ui.container.Panel
        ParametersGrid          matlab.ui.container.GridLayout
        LocalHostPanel          matlab.ui.container.Panel
        LocalHostGrid           matlab.ui.container.GridLayout
        IPublic                 matlab.ui.control.EditField
        IPPublicLabel           matlab.ui.control.Label
        IPLocal                 matlab.ui.control.EditField
        IPLocalLabel            matlab.ui.control.Label
        LocalhostCheckBox       matlab.ui.control.CheckBox
        Timeout                 matlab.ui.control.NumericEditField
        TimeoutLabel            matlab.ui.control.Label
        BaudRate                matlab.ui.control.NumericEditField
        BaudRateLabel           matlab.ui.control.Label
        Port                    matlab.ui.control.EditField
        PortLabel               matlab.ui.control.Label
        IP                      matlab.ui.control.EditField
        IPLabel                 matlab.ui.control.Label
        ConnectionType          matlab.ui.control.DropDown
        ConnectionTypeLabel     matlab.ui.control.Label
        Description             matlab.ui.control.TextArea
        DescriptionLabel        matlab.ui.control.Label
        Name                    matlab.ui.control.DropDown
        NameLabel               matlab.ui.control.Label
        Family                  matlab.ui.control.DropDown
        FamilyLabel             matlab.ui.control.Label
        Status                  matlab.ui.control.DropDown
        StatusLabel             matlab.ui.control.Label
        ModeRadioGroup          matlab.ui.container.ButtonGroup
        EditModeGroup           matlab.ui.control.RadioButton
        ViewModeButton          matlab.ui.control.RadioButton
        ModePanelLabel          matlab.ui.control.Label
        TreeGrid                matlab.ui.container.GridLayout
        TreeModeDown            matlab.ui.control.Image
        TreeMoveUp              matlab.ui.control.Image
        TreeDelNode             matlab.ui.control.Image
        TreeAddNode             matlab.ui.control.Image
        Tree                    matlab.ui.container.Tree
        TreeNodeReceiver        matlab.ui.container.TreeNode
        TreeNodeGPS             matlab.ui.container.TreeNode
        TreeLabel               matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'INSTRUMENT'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        mainApp
        jsBackDoor
        progressDialog

        receiverObj
        gpsObj
        instrumentList
        editedList
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
                        app.Features;
                        app.ImportButton;
                        app.ExportButton;
                        app.TestConnectivityButton;
                        app.DockUndockButton;
                        app.DockCloseButton
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.Features, appName);
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.ImportButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Importa lista de instrumentos')), ...
                            struct('appName', appName, 'dataTag', app.ExportButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Exporta lista de instrumentos')), ...
                            struct('appName', appName, 'dataTag', app.TestConnectivityButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Testa conectividade de instrumento selecionado')), ...
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
            app.receiverObj    = app.mainApp.receiverObj;
            app.gpsObj         = app.mainApp.gpsObj;
            app.instrumentList = [app.receiverObj.List; app.gpsObj.List];
            app.editedList     = app.instrumentList;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.DockUndockButton.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            TreeBuilding(app, [])
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function TreeBuilding(app, idxSelectedNode)
            if ~isempty(app.TreeNodeReceiver.Children)
                delete(app.TreeNodeReceiver.Children)
            end
            
            if ~isempty(app.TreeNodeGPS.Children)
                delete(app.TreeNodeGPS.Children)
            end

            % Tree creation
            for ii = 1:height(app.editedList)
                switch app.editedList.Family{ii}
                    case 'Receiver'
                        Parent = app.TreeNodeReceiver;
                    case 'GPS'
                        Parent = app.TreeNodeGPS;                    
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

            h = [allchild(app.TreeNodeReceiver); ...
                 allchild(app.TreeNodeGPS)];

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
                    app.ConnectionType.Items = app.receiverObj.Config.Definition{idx}.connection.types;

                case 'GPS'
                    idx = strcmp(app.gpsObj.Config.Name, app.Name.Value);
                    app.ConnectionType.Items = app.gpsObj.Config.connectType(idx);
            end

            if strcmp(srcFcn, 'InstrumentParameterChanged')
                Layout_TypeValueChanged(app)
            end
        end

        %-----------------------------------------------------------------%
        function Layout_TypeValueChanged(app)
            switch app.ConnectionType.Value
                case 'Serial'
                    app.ParametersGrid.ColumnWidth([1 3]) = {0, '1x'};
                    app.BaudRateLabel.Visible = 'on';
                    portValidation = contains(app.Port.Value, 'COM');

                otherwise
                    app.ParametersGrid.ColumnWidth([1 3]) = {110, 0};
                    app.BaudRateLabel.Visible = 'off';

                    if isempty(app.IP.Value)
                        app.IP.Value = '127.0.0.1';
                    end
                    portValidation = ~isnan(str2double(app.Port.Value));
            end

            if ~portValidation
                Layout_DefaultPort(app)
            end

            Layout_LocalhostCheckBox1(app)
            Layout_LocalhostCheckBox2(app)
        end

        %-----------------------------------------------------------------%
        function Layout_DefaultPort(app)
            switch app.Family.Value
                case 'Receiver'
                    idx = find(strcmp(app.receiverObj.Config.Name, app.Name.Value), 1);
                    app.Port.Value = num2str(app.receiverObj.Config.Definition{idx}.connection.defaultPort);

                case 'GPS'
                    idx = find(strcmp(app.gpsObj.Config.Name, app.Name.Value), 1);
                    app.Port.Value = app.gpsObj.Config.connectPort{idx};
            end
        end

        %-----------------------------------------------------------------%
        function Layout_LocalhostCheckBox1(app)
            app.LocalhostCheckBox.Enable = 0;

            if app.EditModeGroup.Value && strcmp(app.ConnectionType.Value, "TCP/UDP IP Socket")
                app.LocalhostCheckBox.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function Layout_LocalhostCheckBox2(app)
            if app.LocalhostCheckBox.Value
                set(app.LocalHostGrid.Children, 'Enable', 1)

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

                set(app.IPLocal,  'Enable', 0, 'Value', Localhost_localIP)
                set(app.IPublic, 'Enable', 0, 'Value', Localhost_publicIP)
            end
        end

        %-----------------------------------------------------------------%
        function Layout_InstrumentSpecifications(app)            
            idx1 = app.Tree.SelectedNodes.NodeData;
            [htmlContent, imgSource] = util.HtmlTextGenerator.Instrument(app.receiverObj, app.gpsObj, app.editedList, idx1);

            app.Features.Text   = htmlContent;
            set(app.Image, 'ImageSource', imgSource, 'Visible', 'on')
        end

        %-----------------------------------------------------------------%
        function ParameterUpdate(app)
            idx = app.Tree.SelectedNodes.NodeData;

            switch app.ConnectionType.Value
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
                                                                       'Localhost_localIP',  app.IPLocal.Value, ...
                                                                       'Localhost_publicIP', app.IPublic.Value));
            end
        end

        %-----------------------------------------------------------------%
        function Flag = IPv4Validation(app, event)            
            switch event.Source
                case app.IP;       ipAddress = app.IP.Value;
                case app.IPLocal;  ipAddress = app.IPLocal.Value;
                case app.IPublic; ipAddress = app.IPublic.Value;
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
                ui.Dialog(app.UIFigure, 'warning', 'Endereço IP inválido');

                switch event.Source
                    case app.IP;       app.IP.Value       = event.PreviousValue;
                    case app.IPLocal;  app.IPLocal.Value  = event.PreviousValue;
                    case app.IPublic; app.IPublic.Value = event.PreviousValue;
                end
            else
                if ~strcmp(ipAddress, char(ipString))
                    switch event.Source
                        case app.IP;       app.IP.Value       = char(ipString);
                        case app.IPLocal;  app.IPLocal.Value  = char(ipString);
                        case app.IPublic; app.IPublic.Value = char(ipString);
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function Flag = PortValidation(app, event)
            Flag = 0;

            switch app.ConnectionType.Value
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
                ui.Dialog(app.UIFigure, 'warning', 'Porta inválida');
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
                        case app.TreeNodeReceiver
                            app.Tree.SelectedNodes = app.TreeNodeReceiver.Children(1);
    
                        case app.TreeNodeGPS
                            if ~isempty(app.TreeNodeGPS.Children)
                                app.Tree.SelectedNodes = app.TreeNodeGPS.Children(1);
                            else
                                app.Tree.SelectedNodes = app.TreeNodeReceiver.Children(1);
                            end
                    end
                    idx = app.Tree.SelectedNodes.NodeData;
                end

                msgError = '';

            catch ME
                app.Tree.SelectedNodes = app.TreeNodeReceiver.Children(1);
                idx = app.Tree.SelectedNodes.NodeData;

                msgError = ME.message;
            end
        end

        %-----------------------------------------------------------------%
        function update(app)
            appName = class.Constants.appName;
            [~, programDataFolder] = appEngine.util.Path(appName, app.mainApp.rootFolder);
            saveNewFile(app, programDataFolder, false)

            % Após salva a nova versão de "InstrumentList.json", atualizam-se
            % as listas dos objetos HANDLE app.receiverObj e app.gpsObj.
            app.receiverObj.List = fileRead(app.receiverObj, app.mainApp.rootFolder);                
            gpsObjList = fileRead(app.gpsObj, app.mainApp.rootFolder);
            if ~isempty(gpsObjList)
                app.gpsObj.List = gpsObjList;
            else
                app.gpsObj.List(:,:) = [];
            end

            % Atualiza as propriedades (app.instrumentList e app.editedList
            % pois podem estar desatualizadas, no caso da edição excluir
            % todos os instrumentos, ou desabilitar todos):
            initializeAppProperties(app)
            TreeBuilding(app, [])

            % Fecha o módulo auxiliar "auxApp.winAddTask.mlapp", caso aberto.
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'TASK_ADD')
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
                writematrix(jsonencode(fileList, 'PrettyPrint', true), fullfile(Folder, 'InstrumentList.json'), 'FileType', 'text', 'QuoteStrings', 'none', 'WriteMode', 'overwrite', 'Encoding', 'UTF-8')
                if ShowAlert
                    ui.Dialog(app.UIFigure, 'warning', sprintf('Arquivo <b>InstrumentList.json</b> salvo na pasta "%s"', Folder));
                end
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME));
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

        % Selection changed function: Tree
        function TreeSelectionChanged(app, event)
            
            % Caso o nó selecionado da árvore seja o "RECEPTOR" ou "GPS",
            % busca-se o seu primeiro filho, caso existente.
            idx = SelectionNodeValidation(app);

            % Ajuste dos itens que são listas suspensas (uidropdown)
            % porque no "MODO DE EDIÇÃO" todos os possíveis valores
            % estão disponíveis para escolha, enquanto que no "MODO DE
            % VISUALIZAÇÃO" ficará disponível apenas o valor indicado
            % no "TaskList.json".

            %---------------------------------------------------------%
            % ## MODO DE VISUALIZAÇÃO ##
            %---------------------------------------------------------%
            if app.ViewModeButton.Value
                if app.editedList.Enable(idx); app.Status.Items = {'ON'};
                else;                          app.Status.Items = {'OFF'};
                end

                app.Family.Items = app.editedList.Family(idx);
                app.Name.Items   = app.editedList.Name(idx);
                app.ConnectionType.Items   = app.editedList.Type(idx);

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

                app.ConnectionType.Value = app.editedList.Type{idx};
            end            

            % Ajustes nos outros campos (que não são listas suspensas), 
            % além de especificidades do campo "Fator integração" e dos
            % parâmetros relacionados à busca de emissões.

            app.Description.Value = app.editedList.Description{idx};
            app.LocalhostCheckBox.Value = 0;

            Parameters = jsondecode(app.editedList.Parameters{idx});
            switch app.ConnectionType.Value
                case 'Serial'
                    app.IP.Value       = '';
                    app.Port.Value     = Parameters.Port;
                    app.BaudRate.Value = Parameters.BaudRate;

                case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                    app.IP.Value       = Parameters.IP;
                    app.Port.Value     = Parameters.Port;

                    if isfield(Parameters, 'Localhost_Enable')
                        app.LocalhostCheckBox.Value = Parameters.Localhost_Enable;
                        app.IPLocal.Value  = Parameters.Localhost_localIP;
                        app.IPublic.Value = Parameters.Localhost_publicIP;
                    else
                        app.LocalhostCheckBox.Value = 0;
                        app.IPLocal.Value           = '';
                        app.IPublic.Value          = '';
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

        % Selection changed function: ModeRadioGroup
        function ValueChanged_OperationMode(app, event)
            
            %-------------------------------------------------------------%
            % ## MODO DE VISUALIZAÇÃO ##
            %-------------------------------------------------------------%
            if app.ViewModeButton.Value
                % Aspectos relacionados à indicação visual de que se trata 
                % do modo de visualização:

                set(findobj(app.TreeGrid, 'Type', 'uiimage'), Enable='off')
                app.TreeGrid.ColumnWidth{end} = 0;
                app.ConfirmEditionButton.Visible  = 0;
                app.ImportButton.Enable   = 'on';
                app.ExportButton.Enable = 'on';                

                % Desabilita edição do conteúdo dos campos...

                app.Description.Editable = 'off';
                set(findobj(app.ParametersGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')
                set(findobj(app.LocalHostGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')
                app.LocalhostCheckBox.Enable = 0;

                set(app.Status, 'Items', {app.Status.Value})
                set(app.Family, 'Items', {app.Family.Value})
                set(app.Name,   'Items', {app.Name.Value})
                set(app.ConnectionType,   'Items', {app.ConnectionType.Value})

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

                set(app.TreeGrid.Children, Enable='on')
                app.TreeGrid.ColumnWidth{end} = 16;
                app.ConfirmEditionButton.Visible  = 1;
                app.ImportButton.Enable   = 'off';
                app.ExportButton.Enable = 'off';

                % Habilita edição do conteúdo dos campos...

                app.Description.Editable = 'on';
                set(findobj(app.ParametersGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                set(findobj(app.LocalHostGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                app.LocalhostCheckBox.Enable = 1;

                set(app.Status, 'Items', {'ON', 'OFF'})
                set(app.Family, 'Items', {'Receiver', 'GPS'})
                Layout_FamilyChanged(app, 'InstrumentParameterChanged')
            end

        end

        % Value changed function: BaudRate, ConnectionType, Description, 
        % ...and 9 other components
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
                    app.editedList.Type{idx}   = app.ConnectionType.Value;

                    if strcmp(app.Family.Value, 'Receiver')
                        Layout_DefaultPort(app)
                    end
                    
                    Layout_InstrumentSpecifications(app)
                    ParameterUpdate(app)
                    
                %---------------------------------------------------------%
                case app.Name
                    Layout_NameChanged(app, 'InstrumentParameterChanged')

                    app.editedList.Name{idx} = app.Name.Value;
                    app.editedList.Type{idx} = app.ConnectionType.Value;

                    if strcmp(app.Family.Value, 'Receiver')
                        Layout_DefaultPort(app)
                    end

                    Layout_InstrumentSpecifications(app)
                    ParameterUpdate(app)

                %---------------------------------------------------------%
                case app.ConnectionType
                    Layout_TypeValueChanged(app)                    

                    app.editedList.Type{idx} = app.ConnectionType.Value;
                    ParameterUpdate(app)

                %---------------------------------------------------------%
                case {app.Port, app.IP, app.IPLocal, app.IPublic}
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

        % Image clicked function: TreeAddNode
        function ImageClicked_add(app, event)
            
            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                idx_old = idx;
                idx_new = height(app.editedList) + 1;
    
                app.editedList(idx_new,:) = app.editedList(idx_old,:);
                TreeBuilding(app, idx_new)
            end

        end

        % Image clicked function: TreeDelNode
        function ImageClicked_del(app, event)
            
            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                nodeParent = app.Tree.SelectedNodes.Parent;

                if nodeParent == app.TreeNodeReceiver    
                    if isscalar(nodeParent.Children)
                        return;
                    end
                end

                app.editedList(idx,:) = [];
                TreeBuilding(app, [])
            end

        end

        % Image clicked function: TreeModeDown, TreeMoveUp
        function ImageClicked_UpDownArrows(app, event)
            
            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                idx1_old = idx;
                idx2_old = app.Tree.SelectedNodes.UserData;
                Parent   = app.Tree.SelectedNodes.Parent;
    
                Flag     = 0;
                switch event.Source
                    case app.TreeMoveUp
                        if idx2_old > 1
                            idx1_new = Parent.Children(idx2_old-1).NodeData;
                            Flag     = 1;
                        end
    
                    case app.TreeModeDown
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

        % Image clicked function: ImportButton
        function toolButtonPushed_open(app, event)
            
            [File, Folder] = uigetfile({'*.json', '*.json'}, 'Selecione um arquivo', 'MultiSelect', 'off');
            figure(app.UIFigure)

            if File
                try
                    tempList = util.InstrumentIO.readInstrumentList(fullfile(Folder, File));

                    if ~isempty(tempList)
                        app.instrumentList = [app.instrumentList; tempList];
                        app.editedList     = app.instrumentList;
                        update(app)
                    end

                catch ME
                    ui.Dialog(app.UIFigure, 'error', getReport(ME));
                end
            end

        end

        % Image clicked function: ExportButton
        function toolButtonPushed_export(app, event)
            
            Folder = uigetdir(app.mainApp.General.fileFolder.userPath, 'Escolha o diretório em que será salva a lista de instrumentos');
            figure(app.UIFigure)

            if Folder
                saveNewFile(app, Folder, true)
            end

        end

        % Button pushed function: TestConnectivityButton
        function toolButtonPushed_connectTest(app, event)
            
            app.progressDialog.Visible = 'visible';

            % O "idx1" se refere ao índice da tabela completa extraída de
            % "InstrumentList.json" (possivelmente já editada), incluindo 
            % receptores e GPSs.

            [idx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                idx1 = idx;
    
                switch app.Family.Value
                    case 'Receiver'
                        idx2 = find(strcmp(app.receiverObj.Config.Name, app.Name.Value), 1);
                        instrSelected = struct('Type',       app.ConnectionType.Value,                   ...
                                               'Tag',        app.receiverObj.Config.Tag{idx2}, ...
                                               'Parameters', jsondecode(app.editedList.Parameters{idx1}));
    
                        [~, notification] = testConnectivity(app.receiverObj, instrSelected, 1);
                        if ~isempty(notification)
                            ui.Dialog(app.UIFigure, notification.type, notification.message);
                        end
    
                    case 'GPS'
                        instrSelected = struct('Type',       app.ConnectionType.Value, ...
                                               'Parameters', jsondecode(app.editedList.Parameters{idx1}));
    
                        [~, ~, notification] = testConnectivity(app.gpsObj, instrSelected, 1);
                        if ~isempty(notification)
                            ui.Dialog(app.UIFigure, notification.type, notification.message);
                        end
                end
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Button pushed function: ConfirmEditionButton
        function toolButtonPushed_edit(app, event)
            
            % Finalizada a edição, avalia-se se algum parâmetro foi, de fato, 
            % alterado, salvando uma nova versão do arquivo "InstrumentList.json",
            % caso necessário.             
            if ~isequal(app.instrumentList, app.editedList)
                app.instrumentList = app.editedList;
                update(app)
            end
            
            app.ViewModeButton.Value = 1;
            ValueChanged_OperationMode(app)

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
            app.GridLayout.ColumnWidth = {20, '1x', 38, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, '1x', 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.Layout.Row = [4 5];
            app.SubTabGroup.Layout.Column = [2 3];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'LISTA DE INSTRUMENTOS';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {310, '1x'};
            app.SubGrid1.RowHeight = {17, '1x', 22, 34};
            app.SubGrid1.ColumnSpacing = 20;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create TreeLabel
            app.TreeLabel = uilabel(app.SubGrid1);
            app.TreeLabel.VerticalAlignment = 'bottom';
            app.TreeLabel.FontSize = 10;
            app.TreeLabel.Layout.Row = 1;
            app.TreeLabel.Layout.Column = 1;
            app.TreeLabel.Text = 'INSTRUMENTOS';

            % Create TreeGrid
            app.TreeGrid = uigridlayout(app.SubGrid1);
            app.TreeGrid.ColumnWidth = {146, '1x', 0};
            app.TreeGrid.RowHeight = {16, 5, 16, '1x', 16, 5, 16};
            app.TreeGrid.ColumnSpacing = 5;
            app.TreeGrid.RowSpacing = 0;
            app.TreeGrid.Padding = [0 0 0 0];
            app.TreeGrid.Layout.Row = 2;
            app.TreeGrid.Layout.Column = 1;
            app.TreeGrid.BackgroundColor = [1 1 1];

            % Create Tree
            app.Tree = uitree(app.TreeGrid);
            app.Tree.SelectionChangedFcn = createCallbackFcn(app, @TreeSelectionChanged, true);
            app.Tree.FontSize = 11;
            app.Tree.Layout.Row = [1 7];
            app.Tree.Layout.Column = [1 2];

            % Create TreeNodeReceiver
            app.TreeNodeReceiver = uitreenode(app.Tree);
            app.TreeNodeReceiver.Text = 'RECEPTOR';

            % Create TreeNodeGPS
            app.TreeNodeGPS = uitreenode(app.Tree);
            app.TreeNodeGPS.Text = 'GPS';

            % Create TreeAddNode
            app.TreeAddNode = uiimage(app.TreeGrid);
            app.TreeAddNode.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_add, true);
            app.TreeAddNode.Enable = 'off';
            app.TreeAddNode.Tooltip = {''};
            app.TreeAddNode.Layout.Row = 1;
            app.TreeAddNode.Layout.Column = 3;
            app.TreeAddNode.ImageSource = 'addFileWithPlus_32.png';

            % Create TreeDelNode
            app.TreeDelNode = uiimage(app.TreeGrid);
            app.TreeDelNode.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_del, true);
            app.TreeDelNode.Enable = 'off';
            app.TreeDelNode.Tooltip = {''};
            app.TreeDelNode.Layout.Row = 3;
            app.TreeDelNode.Layout.Column = 3;
            app.TreeDelNode.ImageSource = 'Delete_32Red.png';

            % Create TreeMoveUp
            app.TreeMoveUp = uiimage(app.TreeGrid);
            app.TreeMoveUp.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_UpDownArrows, true);
            app.TreeMoveUp.Enable = 'off';
            app.TreeMoveUp.Tooltip = {''};
            app.TreeMoveUp.Layout.Row = 5;
            app.TreeMoveUp.Layout.Column = 3;
            app.TreeMoveUp.ImageSource = 'ArrowUp_32.png';

            % Create TreeModeDown
            app.TreeModeDown = uiimage(app.TreeGrid);
            app.TreeModeDown.ImageClickedFcn = createCallbackFcn(app, @ImageClicked_UpDownArrows, true);
            app.TreeModeDown.Enable = 'off';
            app.TreeModeDown.Tooltip = {''};
            app.TreeModeDown.Layout.Row = 7;
            app.TreeModeDown.Layout.Column = 3;
            app.TreeModeDown.ImageSource = 'ArrowDown_32.png';

            % Create ModePanelLabel
            app.ModePanelLabel = uilabel(app.SubGrid1);
            app.ModePanelLabel.VerticalAlignment = 'bottom';
            app.ModePanelLabel.FontSize = 10;
            app.ModePanelLabel.Layout.Row = 3;
            app.ModePanelLabel.Layout.Column = 1;
            app.ModePanelLabel.Text = 'MODO';

            % Create ModeRadioGroup
            app.ModeRadioGroup = uibuttongroup(app.SubGrid1);
            app.ModeRadioGroup.AutoResizeChildren = 'off';
            app.ModeRadioGroup.SelectionChangedFcn = createCallbackFcn(app, @ValueChanged_OperationMode, true);
            app.ModeRadioGroup.BackgroundColor = [1 1 1];
            app.ModeRadioGroup.Layout.Row = 4;
            app.ModeRadioGroup.Layout.Column = 1;
            app.ModeRadioGroup.FontSize = 10;

            % Create ViewModeButton
            app.ViewModeButton = uiradiobutton(app.ModeRadioGroup);
            app.ViewModeButton.Text = '<font style="color:#0000ff;">VISUALIZAR</font> lista';
            app.ViewModeButton.FontSize = 11;
            app.ViewModeButton.Interpreter = 'html';
            app.ViewModeButton.Position = [6 5 117 22];
            app.ViewModeButton.Value = true;

            % Create EditModeGroup
            app.EditModeGroup = uiradiobutton(app.ModeRadioGroup);
            app.EditModeGroup.Text = '<font style="color:#a2142f;"><b>EDITAR</b></font> lista';
            app.EditModeGroup.FontSize = 11;
            app.EditModeGroup.Interpreter = 'html';
            app.EditModeGroup.Position = [150 5 92 22];

            % Create InstrumentGrid
            app.InstrumentGrid = uigridlayout(app.SubGrid1);
            app.InstrumentGrid.ColumnWidth = {110, 190, 1, '1x', 140, 22};
            app.InstrumentGrid.RowHeight = {17, 22, 22, 22, 22, '1x', 22, 22, 150};
            app.InstrumentGrid.RowSpacing = 5;
            app.InstrumentGrid.Padding = [0 0 0 0];
            app.InstrumentGrid.Layout.Row = [1 4];
            app.InstrumentGrid.Layout.Column = 2;
            app.InstrumentGrid.BackgroundColor = [1 1 1];

            % Create StatusLabel
            app.StatusLabel = uilabel(app.InstrumentGrid);
            app.StatusLabel.VerticalAlignment = 'bottom';
            app.StatusLabel.FontSize = 10;
            app.StatusLabel.FontColor = [0.149 0.149 0.149];
            app.StatusLabel.Layout.Row = 1;
            app.StatusLabel.Layout.Column = 1;
            app.StatusLabel.Text = 'ESTADO';

            % Create Status
            app.Status = uidropdown(app.InstrumentGrid);
            app.Status.Items = {'ON', 'OFF'};
            app.Status.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Status.FontSize = 11;
            app.Status.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Status.Layout.Row = 2;
            app.Status.Layout.Column = 1;
            app.Status.Value = 'ON';

            % Create FamilyLabel
            app.FamilyLabel = uilabel(app.InstrumentGrid);
            app.FamilyLabel.VerticalAlignment = 'bottom';
            app.FamilyLabel.FontSize = 10;
            app.FamilyLabel.Layout.Row = 1;
            app.FamilyLabel.Layout.Column = 2;
            app.FamilyLabel.Text = 'FAMÍLIA';

            % Create Family
            app.Family = uidropdown(app.InstrumentGrid);
            app.Family.Items = {};
            app.Family.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Family.FontSize = 11;
            app.Family.BackgroundColor = [1 1 1];
            app.Family.Layout.Row = 2;
            app.Family.Layout.Column = 2;
            app.Family.Value = {};

            % Create NameLabel
            app.NameLabel = uilabel(app.InstrumentGrid);
            app.NameLabel.VerticalAlignment = 'bottom';
            app.NameLabel.FontSize = 10;
            app.NameLabel.Layout.Row = 3;
            app.NameLabel.Layout.Column = [1 3];
            app.NameLabel.Text = 'FABRICANTE E MODELO';

            % Create Name
            app.Name = uidropdown(app.InstrumentGrid);
            app.Name.Items = {};
            app.Name.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Name.FontSize = 11;
            app.Name.BackgroundColor = [1 1 1];
            app.Name.Layout.Row = 4;
            app.Name.Layout.Column = [1 2];
            app.Name.Value = {};

            % Create DescriptionLabel
            app.DescriptionLabel = uilabel(app.InstrumentGrid);
            app.DescriptionLabel.VerticalAlignment = 'bottom';
            app.DescriptionLabel.FontSize = 10;
            app.DescriptionLabel.Layout.Row = 5;
            app.DescriptionLabel.Layout.Column = [1 2];
            app.DescriptionLabel.Text = 'DESCRIÇÃO';

            % Create Description
            app.Description = uitextarea(app.InstrumentGrid);
            app.Description.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.Description.Editable = 'off';
            app.Description.FontSize = 11;
            app.Description.Layout.Row = 6;
            app.Description.Layout.Column = [1 2];

            % Create ConnectionTypeLabel
            app.ConnectionTypeLabel = uilabel(app.InstrumentGrid);
            app.ConnectionTypeLabel.VerticalAlignment = 'bottom';
            app.ConnectionTypeLabel.FontSize = 10;
            app.ConnectionTypeLabel.Layout.Row = 7;
            app.ConnectionTypeLabel.Layout.Column = [1 2];
            app.ConnectionTypeLabel.Text = 'TIPO DE CONEXÃO';

            % Create ConnectionType
            app.ConnectionType = uidropdown(app.InstrumentGrid);
            app.ConnectionType.Items = {};
            app.ConnectionType.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.ConnectionType.FontSize = 11;
            app.ConnectionType.BackgroundColor = [1 1 1];
            app.ConnectionType.Layout.Row = 8;
            app.ConnectionType.Layout.Column = [1 2];
            app.ConnectionType.Value = {};

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.InstrumentGrid);
            app.ParametersPanel.AutoResizeChildren = 'off';
            app.ParametersPanel.Layout.Row = 9;
            app.ParametersPanel.Layout.Column = [1 2];

            % Create ParametersGrid
            app.ParametersGrid = uigridlayout(app.ParametersPanel);
            app.ParametersGrid.ColumnWidth = {110, '1x', 0, '1x'};
            app.ParametersGrid.RowHeight = {17, 22, 17, '1x'};
            app.ParametersGrid.RowSpacing = 5;
            app.ParametersGrid.Padding = [10 10 10 5];
            app.ParametersGrid.BackgroundColor = [1 1 1];

            % Create IPLabel
            app.IPLabel = uilabel(app.ParametersGrid);
            app.IPLabel.VerticalAlignment = 'bottom';
            app.IPLabel.FontSize = 11;
            app.IPLabel.Layout.Row = 1;
            app.IPLabel.Layout.Column = 1;
            app.IPLabel.Text = 'IP:';

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
            app.PortLabel.FontSize = 11;
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
            app.BaudRateLabel.FontSize = 11;
            app.BaudRateLabel.Visible = 'off';
            app.BaudRateLabel.Layout.Row = 1;
            app.BaudRateLabel.Layout.Column = [3 4];
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
            app.TimeoutLabel.FontSize = 11;
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
            app.LocalhostCheckBox.FontSize = 11;
            app.LocalhostCheckBox.Layout.Row = 3;
            app.LocalhostCheckBox.Layout.Column = [1 2];

            % Create LocalHostPanel
            app.LocalHostPanel = uipanel(app.ParametersGrid);
            app.LocalHostPanel.AutoResizeChildren = 'off';
            app.LocalHostPanel.Layout.Row = 4;
            app.LocalHostPanel.Layout.Column = [1 4];

            % Create LocalHostGrid
            app.LocalHostGrid = uigridlayout(app.LocalHostPanel);
            app.LocalHostGrid.RowHeight = {17, 22};
            app.LocalHostGrid.RowSpacing = 5;
            app.LocalHostGrid.Padding = [10 10 10 5];
            app.LocalHostGrid.BackgroundColor = [1 1 1];

            % Create IPLocalLabel
            app.IPLocalLabel = uilabel(app.LocalHostGrid);
            app.IPLocalLabel.FontSize = 11;
            app.IPLocalLabel.Layout.Row = 1;
            app.IPLocalLabel.Layout.Column = 1;
            app.IPLocalLabel.Text = 'IP local:';

            % Create IPLocal
            app.IPLocal = uieditfield(app.LocalHostGrid, 'text');
            app.IPLocal.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.IPLocal.Editable = 'off';
            app.IPLocal.FontSize = 11;
            app.IPLocal.Enable = 'off';
            app.IPLocal.Layout.Row = 2;
            app.IPLocal.Layout.Column = 1;

            % Create IPPublicLabel
            app.IPPublicLabel = uilabel(app.LocalHostGrid);
            app.IPPublicLabel.FontSize = 11;
            app.IPPublicLabel.Layout.Row = 1;
            app.IPPublicLabel.Layout.Column = 2;
            app.IPPublicLabel.Text = 'IP público:';

            % Create IPublic
            app.IPublic = uieditfield(app.LocalHostGrid, 'text');
            app.IPublic.ValueChangedFcn = createCallbackFcn(app, @ValueChanged_Parameter, true);
            app.IPublic.Editable = 'off';
            app.IPublic.FontSize = 11;
            app.IPublic.Enable = 'off';
            app.IPublic.Layout.Row = 2;
            app.IPublic.Layout.Column = 2;

            % Create FeaturesLabel
            app.FeaturesLabel = uilabel(app.InstrumentGrid);
            app.FeaturesLabel.VerticalAlignment = 'bottom';
            app.FeaturesLabel.FontSize = 10;
            app.FeaturesLabel.Layout.Row = 1;
            app.FeaturesLabel.Layout.Column = [4 6];
            app.FeaturesLabel.Text = 'ESPECIFICAÇÕES TÉCNICAS';

            % Create Features
            app.Features = uilabel(app.InstrumentGrid);
            app.Features.VerticalAlignment = 'top';
            app.Features.WordWrap = 'on';
            app.Features.FontSize = 11;
            app.Features.Layout.Row = [2 9];
            app.Features.Layout.Column = [4 6];
            app.Features.Interpreter = 'html';
            app.Features.Text = '';

            % Create Image
            app.Image = uiimage(app.InstrumentGrid);
            app.Image.Visible = 'off';
            app.Image.Layout.Row = [3 5];
            app.Image.Layout.Column = 5;
            app.Image.HorizontalAlignment = 'right';
            app.Image.VerticalAlignment = 'top';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, 5, 22, '1x', 116};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 7;
            app.Toolbar.Layout.Column = [1 6];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create ImportButton
            app.ImportButton = uiimage(app.Toolbar);
            app.ImportButton.ScaleMethod = 'none';
            app.ImportButton.ImageClickedFcn = createCallbackFcn(app, @toolButtonPushed_open, true);
            app.ImportButton.Tooltip = {''};
            app.ImportButton.Layout.Row = 1;
            app.ImportButton.Layout.Column = 1;
            app.ImportButton.ImageSource = 'Import_16.png';

            % Create ExportButton
            app.ExportButton = uiimage(app.Toolbar);
            app.ExportButton.ScaleMethod = 'none';
            app.ExportButton.ImageClickedFcn = createCallbackFcn(app, @toolButtonPushed_export, true);
            app.ExportButton.Tooltip = {''};
            app.ExportButton.Layout.Row = 1;
            app.ExportButton.Layout.Column = 2;
            app.ExportButton.ImageSource = 'Export_16.png';

            % Create ButtonsSeparator
            app.ButtonsSeparator = uiimage(app.Toolbar);
            app.ButtonsSeparator.ScaleMethod = 'none';
            app.ButtonsSeparator.Enable = 'off';
            app.ButtonsSeparator.Layout.Row = 1;
            app.ButtonsSeparator.Layout.Column = 3;
            app.ButtonsSeparator.ImageSource = 'LineV.svg';

            % Create TestConnectivityButton
            app.TestConnectivityButton = uibutton(app.Toolbar, 'push');
            app.TestConnectivityButton.ButtonPushedFcn = createCallbackFcn(app, @toolButtonPushed_connectTest, true);
            app.TestConnectivityButton.Icon = 'Connectivity_32.png';
            app.TestConnectivityButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TestConnectivityButton.Tooltip = {''};
            app.TestConnectivityButton.Layout.Row = 1;
            app.TestConnectivityButton.Layout.Column = 4;
            app.TestConnectivityButton.Text = '';

            % Create ConfirmEditionButton
            app.ConfirmEditionButton = uibutton(app.Toolbar, 'push');
            app.ConfirmEditionButton.ButtonPushedFcn = createCallbackFcn(app, @toolButtonPushed_edit, true);
            app.ConfirmEditionButton.Icon = 'save-16px-white.svg';
            app.ConfirmEditionButton.BackgroundColor = [0.6392 0.0784 0.1804];
            app.ConfirmEditionButton.FontSize = 11;
            app.ConfirmEditionButton.FontColor = [1 1 1];
            app.ConfirmEditionButton.Visible = 'off';
            app.ConfirmEditionButton.Layout.Row = 1;
            app.ConfirmEditionButton.Layout.Column = 6;
            app.ConfirmEditionButton.Text = 'Salva alterações';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [3 5];
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
