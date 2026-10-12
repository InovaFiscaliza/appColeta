classdef winInstrument_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        GridLayout                matlab.ui.container.GridLayout
        ConfirmEditionButtonGrid  matlab.ui.container.GridLayout
        ConfirmEditionButton      matlab.ui.control.Button
        DockModule                matlab.ui.container.GridLayout
        DockCloseButton           matlab.ui.control.Image
        DockUndockButton          matlab.ui.control.Image
        Toolbar                   matlab.ui.container.GridLayout
        TestConnectivityButton    matlab.ui.control.Button
        ButtonsSeparator          matlab.ui.control.Image
        ExportButton              matlab.ui.control.Image
        ImportButton              matlab.ui.control.Image
        BandPanel                 matlab.ui.container.Panel
        GridLayout2               matlab.ui.container.GridLayout
        ImageGrid                 matlab.ui.container.GridLayout
        Image                     matlab.ui.control.Image
        StatusLabel_3             matlab.ui.control.Label
        StatusLabel_2             matlab.ui.control.Label
        BandTitle                 matlab.ui.control.Label
        Features                  matlab.ui.control.Label
        TaskPanel                 matlab.ui.container.Panel
        InstrumentGrid            matlab.ui.container.GridLayout
        TaskTitle                 matlab.ui.control.Label
        ParametersPanel           matlab.ui.container.Panel
        ParametersGrid            matlab.ui.container.GridLayout
        LocalHostPanel            matlab.ui.container.Panel
        LocalHostGrid             matlab.ui.container.GridLayout
        IPublic                   matlab.ui.control.EditField
        IPPublicLabel             matlab.ui.control.Label
        IPLocal                   matlab.ui.control.EditField
        IPLocalLabel              matlab.ui.control.Label
        LocalhostCheckBox         matlab.ui.control.CheckBox
        Timeout                   matlab.ui.control.NumericEditField
        TimeoutLabel              matlab.ui.control.Label
        BaudRate                  matlab.ui.control.NumericEditField
        BaudRateLabel             matlab.ui.control.Label
        Port                      matlab.ui.control.EditField
        PortLabel                 matlab.ui.control.Label
        IP                        matlab.ui.control.EditField
        IPLabel                   matlab.ui.control.Label
        ConnectionType            matlab.ui.control.DropDown
        ConnectionTypeLabel       matlab.ui.control.Label
        Description               matlab.ui.control.TextArea
        DescriptionLabel          matlab.ui.control.Label
        Name                      matlab.ui.control.DropDown
        NameLabel                 matlab.ui.control.Label
        Family                    matlab.ui.control.DropDown
        FamilyLabel               matlab.ui.control.Label
        Status                    matlab.ui.control.DropDown
        StatusLabel               matlab.ui.control.Label
        EditStateButton           matlab.ui.control.StateButton
        ViewStateButton           matlab.ui.control.StateButton
        TreePanel                 matlab.ui.container.GridLayout
        TreeTitle                 matlab.ui.control.Label
        TreeIcon                  matlab.ui.control.Image
        TreeModeDown              matlab.ui.control.Image
        TreeMoveUp                matlab.ui.control.Image
        TreeDelNode               matlab.ui.control.Image
        TreeAddNode               matlab.ui.control.Image
        Tree                      matlab.ui.container.Tree
        TreeNodeReceiver          matlab.ui.container.TreeNode
        TreeNodeGPS               matlab.ui.container.TreeNode
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
        SubTabGroup = struct('Children', -1, 'UserData', [])

        mainApp
        jsBackDoor
        progressDialog

        receiverObj
        gpsObj

        ViewMode = true
        InstrumentList
        InstrumentListEdited
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
                        app.ImageGrid;
                        app.Features;
                        app.ViewStateButton;
                        app.EditStateButton;
                        app.ConfirmEditionButtonGrid;
                        ...
                        app.ImportButton;
                        app.ExportButton;
                        app.TestConnectivityButton;
                        ...
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
                            struct('appName', appName, 'dataTag', app.ImageGrid.UserData.id, 'generation', 0, 'styleImportant', struct('borderRadius', '0 10px 0 0')), ...
                            struct('appName', appName, 'dataTag', app.ViewStateButton.UserData.id, 'generation', 1, 'styleImportant', struct('borderRadius', '5px 0px 0px 5px')), ...
                            struct('appName', appName, 'dataTag', app.EditStateButton.UserData.id, 'generation', 1, 'styleImportant', struct('borderRadius', '0px 5px 5px 0px')), ...
                            struct('appName', appName, 'dataTag', app.ConfirmEditionButtonGrid.UserData.id, 'style', struct('background', 'none')), ...
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
            app.receiverObj = app.mainApp.receiverObj;
            app.gpsObj = app.mainApp.gpsObj;

            app.InstrumentList = [app.receiverObj.List; app.gpsObj.List];
            app.InstrumentListEdited = app.InstrumentList;
        end

        %-----------------------------------------------------------------%
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.DockUndockButton.Enable = 1;
            end

            app.TaskPanel.BorderColor = [0.9412 0.9412 0.9412];
            app.BandPanel.BorderColor = [0.9412 0.9412 0.9412];
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            buildTaskTree(app, [])
            focus(app.Tree)
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function buildTaskTree(app, selectedNodeIdx)
            if ~isempty(app.TreeNodeReceiver.Children)
                delete(app.TreeNodeReceiver.Children)
            end
            
            if ~isempty(app.TreeNodeGPS.Children)
                delete(app.TreeNodeGPS.Children)
            end

            selectedNode = [];

            for instrIdx = 1:height(app.InstrumentListEdited)
                switch app.InstrumentListEdited.Family{instrIdx}
                    case 'Receiver'
                        nodeParent = app.TreeNodeReceiver;
                    case 'GPS'
                        nodeParent = app.TreeNodeGPS;                    
                    otherwise
                        continue
                end

                if ~ismember(app.InstrumentListEdited.Type{instrIdx}, {'TCPIP Socket', 'TCP/UDP IP Socket', 'Serial'})
                    continue
                end

                nodeTree = uitreenode(nodeParent, 'Text', getInstrumentTag(app, instrIdx), 'NodeData', struct('instrIdx', instrIdx, 'nodeParentIdx', numel(nodeParent.Children)+1));

                if ~isempty(selectedNodeIdx) && (instrIdx == selectedNodeIdx)
                    selectedNode = nodeTree;
                end
            end            
            
            if isempty(selectedNode)
                selectedNode = app.Tree.Children(1).Children(1);
            end

            expand(app.Tree, 'all')
            app.Tree.SelectedNodes = selectedNode;
            onTreeSelectionChanged(app)
        end

        %-----------------------------------------------------------------%
        function instrTag = getInstrumentTag(app, idx)
            parameters = jsondecode(app.InstrumentListEdited.Parameters{idx});

            switch app.InstrumentListEdited.Type{idx}
                case 'Serial'
                    socket = sprintf('%s', parameters.Port);

                case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                    socket = sprintf('%s:%s', parameters.IP, parameters.Port);
            end

            instrTag = sprintf('%s - %s', app.InstrumentListEdited.Name{idx}, socket);
        end

        %-----------------------------------------------------------------%
        function applyTreeStyle(app)
            if ~isempty(app.Tree.StyleConfigurations)
                removeStyle(app.Tree)
            end

            h = [allchild(app.TreeNodeReceiver); allchild(app.TreeNodeGPS)];

            disableNodes = [];
            for ii = 1:numel(h)
                instrIdx = h(ii).NodeData.instrIdx;
                if ~app.InstrumentListEdited.Enable(instrIdx)
                    disableNodes = [disableNodes, h(ii)];
                end
            end

            if ~isempty(disableNodes)
                addStyle(app.Tree, uistyle('FontColor', [.5 .5 .5]), 'node', disableNodes)
            end

            addStyle(app.Tree, uistyle('FontWeight', 'bold'), 'node', app.Tree.SelectedNodes)
        end

        %-----------------------------------------------------------------%
        function updateUIControlState(app)
            % Painel à esquerda
            if app.ViewMode
                set(app.ViewStateButton, 'BackgroundColor', [0 0.451 0.7412], 'FontColor', [1 1 1], 'Value', true)
                set(app.EditStateButton, 'BackgroundColor', [0.9412 0.9412 0.9412], 'FontColor', [0 0.4471 0.7412], 'Value', false)
                app.TreePanel.ColumnWidth{end} = 0;

            else
                set(app.ViewStateButton, 'BackgroundColor', [0.9412 0.9412 0.9412], 'FontColor', [0 0.4471 0.7412], 'Value', false)
                set(app.EditStateButton, 'BackgroundColor', [0 0.451 0.7412], 'FontColor', [1 1 1], 'Value', true)
                app.TreePanel.ColumnWidth{end} = 16;
            end

            set(setdiff(findobj(app.TreePanel, 'Type', 'uiimage'), app.TreeIcon), 'Enable', ~app.ViewMode)
            
            % Painéis do centro e à direita
            % ...
            app.Description.Editable = 'off';
            set(findobj(app.ParametersGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')
            set(findobj(app.LocalHostGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')
            app.LocalhostCheckBox.Enable = 0;

            if ~app.ViewMode
                app.Description.Editable = 'on';
                set(findobj(app.ParametersGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                set(findobj(app.LocalHostGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                app.LocalhostCheckBox.Enable = 1;
            end

            % Toolbar
            app.ConfirmEditionButtonGrid.Visible = ~app.ViewMode;

            set([
                app.ImportButton;
                app.ExportButton
            ], 'Enable', app.ViewMode)
        end

        %-----------------------------------------------------------------%
        function updateUIControlContent(app)
            instrIdx = app.Tree.SelectedNodes.NodeData.instrIdx;

            if app.InstrumentListEdited.Enable(instrIdx)
                app.Status.Items = {'ON'};
            else
                app.Status.Items = {'OFF'};
            end

            app.Family.Items = app.InstrumentListEdited.Family(instrIdx);
            Layout_FamilyChanged(app, '')

            app.Name.Items = app.InstrumentListEdited.Name(instrIdx);
            Layout_NameChanged(app, 'InstrumentParameterChanged')

            app.Description.Value = app.InstrumentListEdited.Description{instrIdx};
            app.ConnectionType.Items = app.InstrumentListEdited.Type(instrIdx);

            parameters = jsondecode(app.InstrumentListEdited.Parameters{instrIdx});
            switch app.ConnectionType.Value
                case 'Serial'
                    app.IP.Value = '';
                    app.Port.Value = parameters.Port;
                    app.BaudRate.Value = parameters.BaudRate;
                    app.LocalhostCheckBox.Value = 0;

                case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                    app.IP.Value = parameters.IP;
                    app.Port.Value = parameters.Port;

                    if isfield(parameters, 'Localhost_Enable')
                        app.LocalhostCheckBox.Value = parameters.Localhost_Enable;
                        app.IPLocal.Value  = parameters.Localhost_localIP;
                        app.IPublic.Value = parameters.Localhost_publicIP;
                    else
                        app.LocalhostCheckBox.Value = 0;
                        app.IPLocal.Value = '';
                        app.IPublic.Value = '';
                    end
            end

            if isfield(parameters, 'Timeout')
                app.Timeout.Value = parameters.Timeout;
            else
                app.Timeout.Value = class.Constants.Timeout;
            end

            if ~app.ViewMode
                set(app.Status, 'Items', {'ON', 'OFF'})
                set(app.Family, 'Items', {'Receiver', 'GPS'})
                Layout_FamilyChanged(app, 'InstrumentParameterChanged')
            end

            Layout_TypeValueChanged(app)
            Layout_InstrumentSpecifications(app)
        end

        %-----------------------------------------------------------------%
        function userAccepted = confirmDiscardEdition(app)
            userAccepted = true;

            if app.ViewMode || isequal(app.InstrumentList, app.InstrumentListEdited)
                return
            end

            questionMsg = [ ...
                'Foi evidenciada alteração de ao menos uma das tarefas. ' ...
                'Se as alterações não forem salvas, elas serão perdidas.' ...
                '<br><br>Confirma descartar as alterações?' ...
            ];
            userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);
            userAccepted  = userSelection == "Sim";
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

            if ~app.ViewMode && strcmp(app.ConnectionType.Value, "TCP/UDP IP Socket")
                app.LocalhostCheckBox.Enable = 1;
            end
        end

        %-----------------------------------------------------------------%
        function Layout_LocalhostCheckBox2(app)
            if app.LocalhostCheckBox.Value
                set(app.LocalHostGrid.Children, 'Enable', 1)

            else
                instrIdx = app.Tree.SelectedNodes.NodeData.instrIdx;
                parameters = jsondecode(app.InstrumentListEdited.Parameters{instrIdx});

                if isfield(parameters, 'Localhost_Enable')
                    localhostLocalIP  = parameters.Localhost_localIP;
                    localhostPublicIP = parameters.Localhost_publicIP;
                else
                    localhostLocalIP  = '';
                    localhostPublicIP = ''; 
                end

                set(app.IPLocal, 'Enable', 0, 'Value', localhostLocalIP)
                set(app.IPublic, 'Enable', 0, 'Value', localhostPublicIP)
            end
        end

        %-----------------------------------------------------------------%
        function Layout_InstrumentSpecifications(app)            
            instrIdx = app.Tree.SelectedNodes.NodeData.instrIdx;
            [tag, features, img] = util.HtmlTextGenerator.Instrument(app.receiverObj, app.gpsObj, app.InstrumentListEdited, instrIdx);

            app.StatusLabel_3.Text = tag;
            app.Features.Text = features;
            set(app.Image, 'ImageSource', img, 'Visible', 'on')
        end

        %-----------------------------------------------------------------%
        function updateParametersField(app)
            instrIdx = app.Tree.SelectedNodes.NodeData.instrIdx;

            switch app.ConnectionType.Value
                case 'Serial'
                    app.InstrumentListEdited.Parameters{instrIdx} = jsonencode(struct( ...
                        'Port', app.Port.Value, ...
                        'BaudRate', app.BaudRate.Value, ...
                        'Timeout', app.Timeout.Value ...
                    ));

                case 'TCPIP Socket'
                    app.InstrumentListEdited.Parameters{instrIdx} = jsonencode(struct( ...
                        'IP', app.IP.Value, ...
                        'Port', app.Port.Value, ...
                        'Timeout',  app.Timeout.Value ...
                    ));
                
                case 'TCP/UDP IP Socket'
                    if app.LocalhostCheckBox.Value
                        localhostEnable = 1;
                    else
                        localhostEnable = 0;
                    end

                    app.InstrumentListEdited.Parameters{instrIdx} = jsonencode(struct( ...
                        'IP', app.IP.Value, ...
                        'Port', app.Port.Value, ...
                        'Timeout', app.Timeout.Value, ...
                        'Localhost_Enable', localhostEnable, ...
                        'Localhost_localIP', app.IPLocal.Value, ...
                        'Localhost_publicIP', app.IPublic.Value ...
                    ));
            end
        end

        %-----------------------------------------------------------------%
        function flag = validateParameterValue(app, parameterName, event)
            flag = false;

            switch parameterName
                case 'Port'
                    flag = 0;
        
                    switch app.ConnectionType.Value
                        case 'Serial'
                            portValidation = regexpi(app.Port.Value, 'COM\d+', 'match');
                            if isempty(portValidation)
                                flag = true;
                            end
        
                        case {'TCPIP Socket', 'TCP/UDP IP Socket'}
                            portValidation = regexp(app.Port.Value, '\d+', 'match');
                            if isempty(portValidation)
                                flag = true;
                            else
                                if str2double(portValidation) > 65535
                                    flag = true;
                                end
                            end
                    end
        
                    if flag
                        ui.Dialog(app.UIFigure, 'warning', 'Porta inválida');
                        app.Port.Value = event.PreviousValue;
                        
                    else
                        if ~strcmpi(app.Port.Value, char(portValidation))
                            app.Port.Value = upper(char(portValidation));
                        end
                    end

                case 'IPv4'
                    switch event.Source
                        case app.IP
                            ipAddress = app.IP.Value;

                        case app.IPLocal
                            ipAddress = app.IPLocal.Value;

                        case app.IPublic
                            ipAddress = app.IPublic.Value;
                    end
        
                    ipString = regexp(ipAddress, '\d*[.]{1}\d{1,3}[.]{1}\d{1,3}[.]{1}\d*', 'match');
        
                    if isempty(ipString)
                        flag = true;
                    else
                        ipArray = cellfun(@(x) str2double(x), strsplit(char(ipString), '.'));
                        if any(ipArray > 255) || any(isnan(ipArray))
                            flag = true;
                        end                    
                    end
        
                    if flag
                        ui.Dialog(app.UIFigure, 'warning', 'Endereço IP inválido');
        
                        switch event.Source
                            case app.IP
                                app.IP.Value = event.PreviousValue;

                            case app.IPLocal
                                app.IPLocal.Value = event.PreviousValue;

                            case app.IPublic
                                app.IPublic.Value = event.PreviousValue;
                        end

                    else
                        if ~strcmp(ipAddress, char(ipString))
                            switch event.Source
                                case app.IP
                                    app.IP.Value = char(ipString);

                                case app.IPLocal
                                    app.IPLocal.Value = char(ipString);

                                case app.IPublic
                                    app.IPublic.Value = char(ipString);
                            end
                        end
                    end
            end
        end

        %-----------------------------------------------------------------%
        function [instrIdx, msgError] = SelectionNodeValidation(app)
            try
                instrIdx = app.Tree.SelectedNodes.NodeData.instrIdx;

                if isempty(instrIdx)
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

                    instrIdx = app.Tree.SelectedNodes.NodeData.instrIdx;
                end

                msgError = '';

            catch ME
                app.Tree.SelectedNodes = app.TreeNodeReceiver.Children(1);
                instrIdx = app.Tree.SelectedNodes.NodeData.instrIdx;
                msgError = ME.message;
            end
        end

        %-----------------------------------------------------------------%
        function updateInstrumentFile(app)
            appName = class.Constants.appName;
            [~, programDataFolder] = appEngine.util.Path(appName, app.mainApp.rootFolder);
            saveInstrumentFile(app, programDataFolder, false)

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
            buildTaskTree(app, [])

            % Fecha o módulo auxiliar "auxApp.winAddTask.mlapp", caso aberto.
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'TASK_ADD')
        end

        %-----------------------------------------------------------------%
        function saveInstrumentFile(app, folder, showAlert)
            fileList = table2struct(app.InstrumentList);
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
                writematrix(jsonencode(fileList, 'PrettyPrint', true), fullfile(folder, 'InstrumentList.json'), 'FileType', 'text', 'QuoteStrings', 'none', 'WriteMode', 'overwrite', 'Encoding', 'UTF-8')
                if showAlert
                    ui.Dialog(app.UIFigure, 'warning', sprintf('Arquivo <b>InstrumentList.json</b> salvo na pasta "%s"', folder));
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
        function onTreeSelectionChanged(app, event)
            
            if exist('event', 'var')
                if isempty(event.SelectedNodes) || event.SelectedNodes == app.TreeNodeReceiver || event.SelectedNodes == app.TreeNodeGPS
                    app.Tree.SelectedNodes = event.PreviousSelectedNodes;
                    return
                end
            end

            applyTreeStyle(app)

            updateUIControlState(app)
            updateUIControlContent(app)
            
        end

        % Value changed function: EditStateButton, ViewStateButton
        function onViewModeChanged(app, event)
            
            if event.PreviousValue
                event.Source.Value = true;
                return
            end

            switch event.Source 
                case app.ViewStateButton
                    hasChanged = ~isequal(app.InstrumentList, app.InstrumentListEdited);

                    if ~confirmDiscardEdition(app)
                        app.ViewStateButton.Value = false;
                        return
                    end

                    app.ViewMode = true;
                    
                    if hasChanged
                        app.InstrumentListEdited = app.InstrumentList;

                        instrIdx = min(app.Tree.SelectedNodes.NodeData.instrIdx, numel(app.InstrumentList));
                        buildTaskTree(app, instrIdx)
                        return
                    end

                case app.EditStateButton
                    app.ViewMode = false;
            end

            updateUIControlState(app)
            updateUIControlContent(app)
            
        end

        % Value changed function: BaudRate, ConnectionType, Description, 
        % ...and 9 other components
        function onParameterValueChanged(app, event)
            
            [instrIdx, msgError] = SelectionNodeValidation(app);

            if ~isempty(msgError)
                onTreeSelectionChanged(app)
                return
            end

            switch event.Source
                %---------------------------------------------------------%
                case app.Status
                    if app.Status.Value == "ON"
                        app.InstrumentListEdited.Enable(instrIdx) = 1;
                    else
                        app.InstrumentListEdited.Enable(instrIdx) = 0;
                    end

                %---------------------------------------------------------%
                case app.Family
                    Layout_FamilyChanged(app, 'InstrumentParameterChanged')
                    
                    app.InstrumentListEdited.Family{instrIdx} = app.Family.Value;
                    app.InstrumentListEdited.Name{instrIdx}   = app.Name.Value;
                    app.InstrumentListEdited.Type{instrIdx}   = app.ConnectionType.Value;

                    if strcmp(app.Family.Value, 'Receiver')
                        Layout_DefaultPort(app)
                    end
                    
                    Layout_InstrumentSpecifications(app)
                    updateParametersField(app)
                    
                %---------------------------------------------------------%
                case app.Name
                    Layout_NameChanged(app, 'InstrumentParameterChanged')

                    app.InstrumentListEdited.Name{instrIdx} = app.Name.Value;
                    app.InstrumentListEdited.Type{instrIdx} = app.ConnectionType.Value;

                    if strcmp(app.Family.Value, 'Receiver')
                        Layout_DefaultPort(app)
                    end

                    Layout_InstrumentSpecifications(app)
                    updateParametersField(app)

                %---------------------------------------------------------%
                case app.ConnectionType
                    Layout_TypeValueChanged(app)                    

                    app.InstrumentListEdited.Type{instrIdx} = app.ConnectionType.Value;
                    updateParametersField(app)

                %---------------------------------------------------------%
                case {app.Port, app.IP, app.IPLocal, app.IPublic}
                    Flag = 0;

                    if ~isempty(event.Source.Value)
                        if event.Source == app.Port
                            Flag = validateParameterValue(app, 'Port', event);
                        else
                            Flag = validateParameterValue(app, 'IPv4', event);
                        end
                    end

                    if ~Flag
                        updateParametersField(app)
                    end

                %---------------------------------------------------------%
                case app.BaudRate
                    updateParametersField(app)

                %---------------------------------------------------------%
                case app.Timeout
                    updateParametersField(app)

                %---------------------------------------------------------%
                case app.LocalhostCheckBox
                    Layout_LocalhostCheckBox2(app)
                    updateParametersField(app)

                %---------------------------------------------------------%
                case app.Description
                    app.InstrumentListEdited.Description{instrIdx} = strjoin(app.Description.Value);
            end

            % Recriando a árvore...
            buildTaskTree(app, instrIdx)
            
        end

        % Image clicked function: TreeAddNode
        function onTreeAddNodeButtonClicked(app, event)
            
            [instrIdx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                idx_old = instrIdx;
                idx_new = height(app.InstrumentListEdited) + 1;
    
                app.InstrumentListEdited(idx_new,:) = app.InstrumentListEdited(idx_old,:);
                buildTaskTree(app, idx_new)
            end

        end

        % Image clicked function: TreeDelNode
        function onTreeDelNodeButtonClicked(app, event)
            
            [instrIdx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                nodeParent = app.Tree.SelectedNodes.Parent;

                if nodeParent == app.TreeNodeReceiver    
                    if isscalar(nodeParent.Children)
                        return;
                    end
                end

                app.InstrumentListEdited(instrIdx,:) = [];
                buildTaskTree(app, [])
            end

        end

        % Image clicked function: TreeModeDown, TreeMoveUp
        function onTreeNodeUpDownButtonClicked(app, event)
            
            [instrIdx, msgError] = SelectionNodeValidation(app);

            if isempty(msgError)
                instrIdxPrevious = instrIdx;
                nodeParentIdxPrevious = app.Tree.SelectedNodes.NodeData.nodeParentIdx;
                parentNode = app.Tree.SelectedNodes.Parent;
    
                flag = false;
                switch event.Source
                    case app.TreeMoveUp
                        if nodeParentIdxPrevious > 1
                            instrIdxNew = parentNode.Children(nodeParentIdxPrevious-1).NodeData.instrIdx;
                            flag = true;
                        end
    
                    case app.TreeModeDown
                        if nodeParentIdxPrevious < numel(parentNode.Children)
                            instrIdxNew = parentNode.Children(nodeParentIdxPrevious+1).NodeData.instrIdx;
                            flag = true;
                        end
                end
    
                if flag
                    app.InstrumentListEdited([instrIdxPrevious, instrIdxNew],:) = flip(app.InstrumentListEdited([instrIdxPrevious, instrIdxNew],:));
                    buildTaskTree(app, instrIdxNew)
                end
            end

        end

        % Callback function: ExportButton, ImportButton, 
        % ...and 1 other component
        function onToolbarButtonClicked(app, event)
            
            switch event.Source
                case app.ImportButton
                    [file, folder] = uigetfile({'*.json', '*.json'}, 'Selecione um arquivo', 'MultiSelect', 'off');
                    figure(app.UIFigure)
        
                    if file
                        try
                            tempList = util.InstrumentIO.readInstrumentList(fullfile(folder, file));
        
                            if ~isempty(tempList)
                                app.InstrumentList = [app.InstrumentList; tempList];
                                app.InstrumentListEdited     = app.InstrumentList;
                                updateInstrumentFile(app)
                            end
        
                        catch ME
                            ui.Dialog(app.UIFigure, 'error', getReport(ME));
                        end
                    end

                case app.ExportButton
                    folder = uigetdir(app.mainApp.General.fileFolder.userPath, 'Escolha o diretório em que será salva a lista de instrumentos');
                    figure(app.UIFigure)
        
                    if folder
                        saveInstrumentFile(app, folder, true)
                    end

                case app.TestConnectivityButton
                    app.progressDialog.Visible = 'visible';
        
                    [instrIdx, msgError] = SelectionNodeValidation(app);
        
                    if isempty(msgError)
                        notification = [];
            
                        switch app.Family.Value
                            case 'Receiver'
                                receiverIdx = find(strcmp(app.receiverObj.Config.Name, app.Name.Value), 1);
                                instrInfo = struct( ...
                                    'Type', app.ConnectionType.Value, ...
                                    'Tag', app.receiverObj.Config.Tag{receiverIdx}, ...
                                    'Parameters', jsondecode(app.InstrumentListEdited.Parameters{instrIdx}) ...
                                );
            
                                [~, notification] = testConnectivity(app.receiverObj, instrInfo, 1);
            
                            case 'GPS'
                                instrInfo = struct( ...
                                    'Type', app.ConnectionType.Value, ...
                                    'Parameters', jsondecode(app.InstrumentListEdited.Parameters{instrIdx}) ...
                                );
            
                                [~, ~, notification] = testConnectivity(app.gpsObj, instrInfo, 1);
                        end

                        if ~isempty(notification)
                            ui.Dialog(app.UIFigure, notification.type, notification.message);
                        end
                    end
        
                    app.progressDialog.Visible = 'hidden';
            end

        end

        % Button pushed function: ConfirmEditionButton
        function onConfirmEditionButtonClicked(app, event)
            
            hasChanged = ~isequal(app.InstrumentList, app.InstrumentListEdited);

            if hasChanged
                app.InstrumentList = app.InstrumentListEdited;
                updateInstrumentFile(app)
            end

            app.ViewMode = true;

            updateUIControlState(app)
            updateUIControlContent(app)

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
            app.GridLayout.ColumnWidth = {20, 160, 160, 10, 320, 10, '1x', 122, 38, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, '1x', 10, 34, 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TreePanel
            app.TreePanel = uigridlayout(app.GridLayout);
            app.TreePanel.ColumnWidth = {24, '1x', 0};
            app.TreePanel.RowHeight = {36, 36, 16, 5, 16, '1x', 16, 5, 16};
            app.TreePanel.ColumnSpacing = 5;
            app.TreePanel.RowSpacing = 0;
            app.TreePanel.Padding = [0 0 0 0];
            app.TreePanel.Layout.Row = [4 5];
            app.TreePanel.Layout.Column = [2 3];
            app.TreePanel.BackgroundColor = [1 1 1];

            % Create Tree
            app.Tree = uitree(app.TreePanel);
            app.Tree.SelectionChangedFcn = createCallbackFcn(app, @onTreeSelectionChanged, true);
            app.Tree.FontSize = 11;
            app.Tree.FontColor = [0.2 0.2 0.2];
            app.Tree.Layout.Row = [3 9];
            app.Tree.Layout.Column = [1 2];

            % Create TreeNodeReceiver
            app.TreeNodeReceiver = uitreenode(app.Tree);
            app.TreeNodeReceiver.Text = 'RECEPTOR';

            % Create TreeNodeGPS
            app.TreeNodeGPS = uitreenode(app.Tree);
            app.TreeNodeGPS.Text = 'GPS';

            % Create TreeAddNode
            app.TreeAddNode = uiimage(app.TreePanel);
            app.TreeAddNode.ImageClickedFcn = createCallbackFcn(app, @onTreeAddNodeButtonClicked, true);
            app.TreeAddNode.Enable = 'off';
            app.TreeAddNode.Tooltip = {''};
            app.TreeAddNode.Layout.Row = 3;
            app.TreeAddNode.Layout.Column = 3;
            app.TreeAddNode.ImageSource = 'addFileWithPlus_32.png';

            % Create TreeDelNode
            app.TreeDelNode = uiimage(app.TreePanel);
            app.TreeDelNode.ImageClickedFcn = createCallbackFcn(app, @onTreeDelNodeButtonClicked, true);
            app.TreeDelNode.Enable = 'off';
            app.TreeDelNode.Tooltip = {''};
            app.TreeDelNode.Layout.Row = 5;
            app.TreeDelNode.Layout.Column = 3;
            app.TreeDelNode.ImageSource = 'Delete_32Red.png';

            % Create TreeMoveUp
            app.TreeMoveUp = uiimage(app.TreePanel);
            app.TreeMoveUp.ImageClickedFcn = createCallbackFcn(app, @onTreeNodeUpDownButtonClicked, true);
            app.TreeMoveUp.Enable = 'off';
            app.TreeMoveUp.Tooltip = {''};
            app.TreeMoveUp.Layout.Row = 7;
            app.TreeMoveUp.Layout.Column = 3;
            app.TreeMoveUp.ImageSource = 'ArrowUp_32.png';

            % Create TreeModeDown
            app.TreeModeDown = uiimage(app.TreePanel);
            app.TreeModeDown.ImageClickedFcn = createCallbackFcn(app, @onTreeNodeUpDownButtonClicked, true);
            app.TreeModeDown.Enable = 'off';
            app.TreeModeDown.Tooltip = {''};
            app.TreeModeDown.Layout.Row = 9;
            app.TreeModeDown.Layout.Column = 3;
            app.TreeModeDown.ImageSource = 'ArrowDown_32.png';

            % Create TreeIcon
            app.TreeIcon = uiimage(app.TreePanel);
            app.TreeIcon.ScaleMethod = 'none';
            app.TreeIcon.Layout.Row = 1;
            app.TreeIcon.Layout.Column = 1;
            app.TreeIcon.VerticalAlignment = 'top';
            app.TreeIcon.ImageSource = 'circuit-board - blue.svg';

            % Create TreeTitle
            app.TreeTitle = uilabel(app.TreePanel);
            app.TreeTitle.VerticalAlignment = 'top';
            app.TreeTitle.WordWrap = 'on';
            app.TreeTitle.FontSize = 15;
            app.TreeTitle.FontColor = [0 0.4471 0.7412];
            app.TreeTitle.Layout.Row = [1 2];
            app.TreeTitle.Layout.Column = [2 3];
            app.TreeTitle.Interpreter = 'html';
            app.TreeTitle.Text = {'<b>Instrumentos</b>'; '<font style="color: gray; font-size: 11px;">Selecione um instrumento para visualizar seus detalhes e editar parâmetros (ou adicione um novo instrumento)</font>'};

            % Create ViewStateButton
            app.ViewStateButton = uibutton(app.GridLayout, 'state');
            app.ViewStateButton.ValueChangedFcn = createCallbackFcn(app, @onViewModeChanged, true);
            app.ViewStateButton.Text = 'Visualizar lista';
            app.ViewStateButton.BackgroundColor = [0 0.451 0.7412];
            app.ViewStateButton.FontSize = 11;
            app.ViewStateButton.FontWeight = 'bold';
            app.ViewStateButton.FontColor = [1 1 1];
            app.ViewStateButton.Layout.Row = 7;
            app.ViewStateButton.Layout.Column = 2;
            app.ViewStateButton.Value = true;

            % Create EditStateButton
            app.EditStateButton = uibutton(app.GridLayout, 'state');
            app.EditStateButton.ValueChangedFcn = createCallbackFcn(app, @onViewModeChanged, true);
            app.EditStateButton.Text = 'Editar lista';
            app.EditStateButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.EditStateButton.FontSize = 11;
            app.EditStateButton.FontWeight = 'bold';
            app.EditStateButton.FontColor = [0 0.4471 0.7412];
            app.EditStateButton.Layout.Row = 7;
            app.EditStateButton.Layout.Column = 3;

            % Create TaskPanel
            app.TaskPanel = uipanel(app.GridLayout);
            app.TaskPanel.Layout.Row = [4 7];
            app.TaskPanel.Layout.Column = 5;

            % Create InstrumentGrid
            app.InstrumentGrid = uigridlayout(app.TaskPanel);
            app.InstrumentGrid.ColumnWidth = {110, 178};
            app.InstrumentGrid.RowHeight = {34, 17, 22, 22, 22, 22, '1x', 22, 22, 150};
            app.InstrumentGrid.RowSpacing = 5;
            app.InstrumentGrid.BackgroundColor = [1 1 1];

            % Create StatusLabel
            app.StatusLabel = uilabel(app.InstrumentGrid);
            app.StatusLabel.VerticalAlignment = 'bottom';
            app.StatusLabel.FontSize = 10;
            app.StatusLabel.FontColor = [0.149 0.149 0.149];
            app.StatusLabel.Layout.Row = 2;
            app.StatusLabel.Layout.Column = 1;
            app.StatusLabel.Text = 'ESTADO';

            % Create Status
            app.Status = uidropdown(app.InstrumentGrid);
            app.Status.Items = {'ON', 'OFF'};
            app.Status.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Status.FontSize = 11;
            app.Status.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Status.Layout.Row = 3;
            app.Status.Layout.Column = 1;
            app.Status.Value = 'ON';

            % Create FamilyLabel
            app.FamilyLabel = uilabel(app.InstrumentGrid);
            app.FamilyLabel.VerticalAlignment = 'bottom';
            app.FamilyLabel.FontSize = 10;
            app.FamilyLabel.Layout.Row = 2;
            app.FamilyLabel.Layout.Column = 2;
            app.FamilyLabel.Text = 'FAMÍLIA';

            % Create Family
            app.Family = uidropdown(app.InstrumentGrid);
            app.Family.Items = {};
            app.Family.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Family.FontSize = 11;
            app.Family.BackgroundColor = [1 1 1];
            app.Family.Layout.Row = 3;
            app.Family.Layout.Column = 2;
            app.Family.Value = {};

            % Create NameLabel
            app.NameLabel = uilabel(app.InstrumentGrid);
            app.NameLabel.VerticalAlignment = 'bottom';
            app.NameLabel.FontSize = 10;
            app.NameLabel.Layout.Row = 4;
            app.NameLabel.Layout.Column = [1 2];
            app.NameLabel.Text = 'FABRICANTE E MODELO';

            % Create Name
            app.Name = uidropdown(app.InstrumentGrid);
            app.Name.Items = {};
            app.Name.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Name.FontSize = 11;
            app.Name.BackgroundColor = [1 1 1];
            app.Name.Layout.Row = 5;
            app.Name.Layout.Column = [1 2];
            app.Name.Value = {};

            % Create DescriptionLabel
            app.DescriptionLabel = uilabel(app.InstrumentGrid);
            app.DescriptionLabel.VerticalAlignment = 'bottom';
            app.DescriptionLabel.FontSize = 10;
            app.DescriptionLabel.Layout.Row = 6;
            app.DescriptionLabel.Layout.Column = [1 2];
            app.DescriptionLabel.Text = 'DESCRIÇÃO';

            % Create Description
            app.Description = uitextarea(app.InstrumentGrid);
            app.Description.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Description.Editable = 'off';
            app.Description.FontSize = 11;
            app.Description.Layout.Row = 7;
            app.Description.Layout.Column = [1 2];

            % Create ConnectionTypeLabel
            app.ConnectionTypeLabel = uilabel(app.InstrumentGrid);
            app.ConnectionTypeLabel.VerticalAlignment = 'bottom';
            app.ConnectionTypeLabel.FontSize = 10;
            app.ConnectionTypeLabel.Layout.Row = 8;
            app.ConnectionTypeLabel.Layout.Column = [1 2];
            app.ConnectionTypeLabel.Text = 'TIPO DE CONEXÃO';

            % Create ConnectionType
            app.ConnectionType = uidropdown(app.InstrumentGrid);
            app.ConnectionType.Items = {};
            app.ConnectionType.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.ConnectionType.FontSize = 11;
            app.ConnectionType.BackgroundColor = [1 1 1];
            app.ConnectionType.Layout.Row = 9;
            app.ConnectionType.Layout.Column = [1 2];
            app.ConnectionType.Value = {};

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.InstrumentGrid);
            app.ParametersPanel.AutoResizeChildren = 'off';
            app.ParametersPanel.Layout.Row = 10;
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
            app.IP.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
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
            app.Port.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
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
            app.BaudRate.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
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
            app.Timeout.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.Timeout.Editable = 'off';
            app.Timeout.FontSize = 11;
            app.Timeout.Layout.Row = 2;
            app.Timeout.Layout.Column = 4;
            app.Timeout.Value = 5;

            % Create LocalhostCheckBox
            app.LocalhostCheckBox = uicheckbox(app.ParametersGrid);
            app.LocalhostCheckBox.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
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
            app.IPLocal.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
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
            app.IPublic.ValueChangedFcn = createCallbackFcn(app, @onParameterValueChanged, true);
            app.IPublic.Editable = 'off';
            app.IPublic.FontSize = 11;
            app.IPublic.Enable = 'off';
            app.IPublic.Layout.Row = 2;
            app.IPublic.Layout.Column = 2;

            % Create TaskTitle
            app.TaskTitle = uilabel(app.InstrumentGrid);
            app.TaskTitle.VerticalAlignment = 'top';
            app.TaskTitle.WordWrap = 'on';
            app.TaskTitle.FontColor = [0 0.451 0.7412];
            app.TaskTitle.Layout.Row = 1;
            app.TaskTitle.Layout.Column = [1 2];
            app.TaskTitle.Interpreter = 'html';
            app.TaskTitle.Text = {'<b>Instrumento selecionado</b>'; '<font style="color: gray; font-size: 10px;">Configurações gerais do instrumento</font>'};

            % Create BandPanel
            app.BandPanel = uipanel(app.GridLayout);
            app.BandPanel.Layout.Row = [4 7];
            app.BandPanel.Layout.Column = [7 9];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.BandPanel);
            app.GridLayout2.ColumnWidth = {144, '1x'};
            app.GridLayout2.RowHeight = {34, 17, 103, '1x'};
            app.GridLayout2.ColumnSpacing = 6;
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.Scrollable = 'on';
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create Features
            app.Features = uilabel(app.GridLayout2);
            app.Features.VerticalAlignment = 'top';
            app.Features.WordWrap = 'on';
            app.Features.FontSize = 11;
            app.Features.Layout.Row = 4;
            app.Features.Layout.Column = [1 2];
            app.Features.Interpreter = 'html';
            app.Features.Text = '';

            % Create BandTitle
            app.BandTitle = uilabel(app.GridLayout2);
            app.BandTitle.VerticalAlignment = 'top';
            app.BandTitle.WordWrap = 'on';
            app.BandTitle.FontColor = [0 0.4471 0.7412];
            app.BandTitle.Layout.Row = 1;
            app.BandTitle.Layout.Column = [1 2];
            app.BandTitle.Interpreter = 'html';
            app.BandTitle.Text = {'<b>Especificação técnica</b>'; '<font style="color: gray; font-size: 10px;">Parâmetros técnicos de aquisição e detecção</font>'};

            % Create StatusLabel_2
            app.StatusLabel_2 = uilabel(app.GridLayout2);
            app.StatusLabel_2.VerticalAlignment = 'bottom';
            app.StatusLabel_2.FontSize = 10;
            app.StatusLabel_2.FontColor = [0.149 0.149 0.149];
            app.StatusLabel_2.Layout.Row = 2;
            app.StatusLabel_2.Layout.Column = [1 2];
            app.StatusLabel_2.Text = 'IDENTIFICAÇÃO';

            % Create StatusLabel_3
            app.StatusLabel_3 = uilabel(app.GridLayout2);
            app.StatusLabel_3.VerticalAlignment = 'bottom';
            app.StatusLabel_3.FontColor = [0.149 0.149 0.149];
            app.StatusLabel_3.Layout.Row = 3;
            app.StatusLabel_3.Layout.Column = 2;
            app.StatusLabel_3.Interpreter = 'html';
            app.StatusLabel_3.Text = '';

            % Create ImageGrid
            app.ImageGrid = uigridlayout(app.GridLayout2);
            app.ImageGrid.ColumnWidth = {'1x'};
            app.ImageGrid.RowHeight = {'1x'};
            app.ImageGrid.Layout.Row = 3;
            app.ImageGrid.Layout.Column = 1;

            % Create Image
            app.Image = uiimage(app.ImageGrid);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, 5, 22, '1x'};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.RowSpacing = 0;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 9;
            app.Toolbar.Layout.Column = [1 12];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create ImportButton
            app.ImportButton = uiimage(app.Toolbar);
            app.ImportButton.ScaleMethod = 'none';
            app.ImportButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.ImportButton.Tooltip = {''};
            app.ImportButton.Layout.Row = 1;
            app.ImportButton.Layout.Column = 1;
            app.ImportButton.ImageSource = 'Import_16.png';

            % Create ExportButton
            app.ExportButton = uiimage(app.Toolbar);
            app.ExportButton.ScaleMethod = 'none';
            app.ExportButton.ImageClickedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
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
            app.TestConnectivityButton.ButtonPushedFcn = createCallbackFcn(app, @onToolbarButtonClicked, true);
            app.TestConnectivityButton.Icon = 'Connectivity_32.png';
            app.TestConnectivityButton.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TestConnectivityButton.Tooltip = {''};
            app.TestConnectivityButton.Layout.Row = 1;
            app.TestConnectivityButton.Layout.Column = 4;
            app.TestConnectivityButton.Text = '';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [9 11];
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

            % Create ConfirmEditionButtonGrid
            app.ConfirmEditionButtonGrid = uigridlayout(app.GridLayout);
            app.ConfirmEditionButtonGrid.ColumnWidth = {'1x'};
            app.ConfirmEditionButtonGrid.RowHeight = {'1x'};
            app.ConfirmEditionButtonGrid.Padding = [0 10 0 10];
            app.ConfirmEditionButtonGrid.Visible = 'off';
            app.ConfirmEditionButtonGrid.Layout.Row = [8 9];
            app.ConfirmEditionButtonGrid.Layout.Column = [8 9];
            app.ConfirmEditionButtonGrid.BackgroundColor = [1 1 1];

            % Create ConfirmEditionButton
            app.ConfirmEditionButton = uibutton(app.ConfirmEditionButtonGrid, 'push');
            app.ConfirmEditionButton.ButtonPushedFcn = createCallbackFcn(app, @onConfirmEditionButtonClicked, true);
            app.ConfirmEditionButton.Icon = 'save-16px-white.svg';
            app.ConfirmEditionButton.BackgroundColor = [0 0.451 0.7412];
            app.ConfirmEditionButton.FontSize = 11;
            app.ConfirmEditionButton.FontColor = [1 1 1];
            app.ConfirmEditionButton.Layout.Row = 1;
            app.ConfirmEditionButton.Layout.Column = 1;
            app.ConfirmEditionButton.Text = 'Salvar alterações';

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
