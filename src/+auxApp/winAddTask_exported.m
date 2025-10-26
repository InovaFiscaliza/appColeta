classdef winAddTask_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        dockModuleGrid             matlab.ui.container.GridLayout
        dockModule_Undock          matlab.ui.control.Image
        dockModule_Close           matlab.ui.control.Image
        Toolbar                    matlab.ui.container.GridLayout
        okBtn                      matlab.ui.control.Button
        BandCustomizable           matlab.ui.container.GridLayout
        Band_Refresh               matlab.ui.control.Image
        Band_AntennaPanel          matlab.ui.container.Panel
        Band_AntennaGrid           matlab.ui.container.GridLayout
        Band_TargetListRefresh     matlab.ui.control.Image
        Band_Antenna               matlab.ui.control.DropDown
        Band_AntennaLabel          matlab.ui.control.Label
        Band_TargetList            matlab.ui.control.DropDown
        Band_TargetListLabel       matlab.ui.control.Label
        Band_AntenaLabel           matlab.ui.control.Label
        Band_DFPanel               matlab.ui.container.Panel
        Band_DFGrid                matlab.ui.container.GridLayout
        Band_DFMeasTime            matlab.ui.control.Spinner
        Band_DFMeasTimeLabel       matlab.ui.control.Label
        Band_DFSquelchValue        matlab.ui.control.Spinner
        Band_DFSquelchValueLabel   matlab.ui.control.Label
        Band_DFSquelchMode         matlab.ui.control.DropDown
        Band_DFSquelchModeLabel    matlab.ui.control.Label
        Band_DFLabel               matlab.ui.control.Label
        Band_ReceiverPanel         matlab.ui.container.Panel
        Band_ReceiverGrid          matlab.ui.container.GridLayout
        Band_IntegrationTime       matlab.ui.control.NumericEditField
        Band_IntegrationTimeLabel  matlab.ui.control.Label
        Band_Detector              matlab.ui.control.DropDown
        Band_DetectorLabel         matlab.ui.control.Label
        Band_attValue              matlab.ui.control.DropDown
        Band_attValueLabel         matlab.ui.control.Label
        Band_attMode               matlab.ui.control.DropDown
        Band_attModeLabel          matlab.ui.control.Label
        Band_Preamp                matlab.ui.control.DropDown
        Band_PreampLabel           matlab.ui.control.Label
        Band_VBW                   matlab.ui.control.DropDown
        Band_VBWLabel              matlab.ui.control.Label
        Band_Resolution            matlab.ui.control.DropDown
        Band_ResolutionLabel       matlab.ui.control.Label
        Band_Selectivity           matlab.ui.control.DropDown
        Band_SelectivityLabel      matlab.ui.control.Label
        Band_DataPoints2           matlab.ui.control.NumericEditField
        Band_DataPoints1           matlab.ui.control.Spinner
        Band_DataPointsLabel       matlab.ui.control.Label
        Band_StepWidth2            matlab.ui.control.DropDown
        Band_StepWidth1            matlab.ui.control.NumericEditField
        Band_StepWidthLabel        matlab.ui.control.Label
        Band_ReceiverLabel         matlab.ui.control.Label
        Band_Samples               matlab.ui.control.NumericEditField
        Band_SamplesLabel          matlab.ui.control.Label
        BandsInfo                  matlab.ui.container.GridLayout
        MetaData                   matlab.ui.control.Label
        MetaDataLabel              matlab.ui.control.Label
        Band_Tree                  matlab.ui.container.Tree
        Band_TreeLabel             matlab.ui.control.Label
        TaskControl                matlab.ui.container.TabGroup
        TAREFATab                  matlab.ui.container.Tab
        Tab1_Panel                 matlab.ui.container.GridLayout
        TaskType                   matlab.ui.control.DropDown
        TaskTypeLabel              matlab.ui.control.Label
        PreviewTaskCheckbox        matlab.ui.control.CheckBox
        AddMaskFile_Button         matlab.ui.control.Button
        MaskFile_Button            matlab.ui.control.Button
        TaskName                   matlab.ui.control.DropDown
        TaskNameLabel              matlab.ui.control.Label
        BitsPerPointLabel          matlab.ui.control.Label
        ObservationPanel           matlab.ui.container.Panel
        ObservationPanel_Grid      matlab.ui.container.GridLayout
        SpecificTime_Grid          matlab.ui.container.GridLayout
        SpecificTime_Mark2         matlab.ui.control.Label
        SpecificTime_Mark1         matlab.ui.control.Label
        SpecificTime_Spinner4      matlab.ui.control.Spinner
        SpecificTime_Spinner3      matlab.ui.control.Spinner
        SpecificTime_DatePicker2   matlab.ui.control.DatePicker
        SpecificTime_Spinner2      matlab.ui.control.Spinner
        SpecificTime_Spinner1      matlab.ui.control.Spinner
        SpecificTime_DatePicker1   matlab.ui.control.DatePicker
        Duration_Grid              matlab.ui.container.GridLayout
        DurationUnit               matlab.ui.control.DropDown
        Duration                   matlab.ui.control.NumericEditField
        ObservationType            matlab.ui.control.DropDown
        ObservationTypeLabel       matlab.ui.control.Label
        ObservationLabel           matlab.ui.control.Label
        BitsPerPoint               matlab.ui.control.DropDown
        INSTRUMENTOSTab            matlab.ui.container.Tab
        Tab2_Panel                 matlab.ui.container.GridLayout
        GPS_List                   matlab.ui.control.DropDown
        GPS_ListLabel              matlab.ui.control.Label
        GPS_FixedStation           matlab.ui.control.Button
        Receiver_ListLabel         matlab.ui.control.Label
        Receiver_List              matlab.ui.control.DropDown
        Receiver_Connectivity      matlab.ui.control.Button
        GPS_Connectivity           matlab.ui.control.Button
        GPS_Panel                  matlab.ui.container.Panel
        GPS_Grid                   matlab.ui.container.GridLayout
        GPS_manualLongitudeLabel   matlab.ui.control.Label
        GPS_manualLatitudeLabel    matlab.ui.control.Label
        GPS_RevisitTimeLabel       matlab.ui.control.Label
        GPS_RevisitTime            matlab.ui.control.NumericEditField
        GPS_manualLongitude        matlab.ui.control.NumericEditField
        GPS_manualLatitude         matlab.ui.control.NumericEditField
        Receiver_Panel             matlab.ui.container.Panel
        Receiver_Grid              matlab.ui.container.GridLayout
        Receiver_SyncRef           matlab.ui.control.DropDown
        Receiver_SyncRefLabel      matlab.ui.control.Label
        Receiver_RstCommand        matlab.ui.control.DropDown
        Receiver_RstCommandLabel   matlab.ui.control.Label
        ANTENASTab                 matlab.ui.container.Tab
        Tab3_Panel                 matlab.ui.container.GridLayout
        AntennaSwitch_Name         matlab.ui.control.EditField
        AntennaSwitch_Mode         matlab.ui.control.CheckBox
        AntennaList_Tree           matlab.ui.container.Tree
        AddAntenna_Image           matlab.ui.control.Image
        Antenna_Panel              matlab.ui.container.Panel
        Antenna_Grid               matlab.ui.container.GridLayout
        AntennaPolarization        matlab.ui.control.NumericEditField
        AntennaPolarizationLabel   matlab.ui.control.Label
        AntennaElevation           matlab.ui.control.NumericEditField
        AntennaElevationLabel      matlab.ui.control.Label
        AntennaAzimuth_Grid        matlab.ui.container.GridLayout
        AntennaAzimuthRef          matlab.ui.control.DropDown
        AntennaAzimuth             matlab.ui.control.NumericEditField
        AntennaAzimuthLabel        matlab.ui.control.Label
        AntennaHeight              matlab.ui.control.NumericEditField
        AntennaHeightLabel         matlab.ui.control.Label
        Antenna_TrackingMode       matlab.ui.control.DropDown
        Antenna_TrackingModeLabel  matlab.ui.control.Label
        AntennaName                matlab.ui.control.DropDown
        AntennaNameLabel           matlab.ui.control.Label
        ContextMenu                matlab.ui.container.ContextMenu
        delAntennaEntry            matlab.ui.container.Menu
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

        %-----------------------------------------------------------------%
        % ESPECIFICIDADES AUXAPP.WINADDTASK
        %-----------------------------------------------------------------%
        taskList
        infoEdition

        receiverObj
        gpsObj
        EMSatObj
        EB500Map
        switchList
        targetList
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

                    case 'auxApp.winAddTask.AntennaList_Tree'
                        % ...

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
        % JSBACKDOOR: CUSTOMIZAÇÃO GUI (ESTÉTICA/COMPORTAMENTAL)
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
                customizationStatus = [false, false, false];
            end

            switch tabIndex
                case 0 % STARTUP
                    if app.isDocked
                        app.progressDialog = app.mainApp.progressDialog;
                    else
                        sendEventToHTMLSource(app.jsBackDoor, 'startup', app.mainApp.executionMode);
                        app.progressDialog = ccTools.ProgressDialog(app.jsBackDoor);                        
                    end
                    customizationStatus = [false, false, false];

                otherwise
                    if customizationStatus(tabIndex)
                        return
                    end

                    appName = class(app);
                    customizationStatus(tabIndex) = true;
                    switch tabIndex
                        case 1
                            % Grid botões "dock":
                            if app.isDocked
                                elToModify = {app.dockModuleGrid};
                                elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                                if ~isempty(elDataTag)                                    
                                    sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                        struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('transition', 'opacity 2s ease', 'opacity', '0.5')) ...
                                    });
                                end
                            end

                            % Outros elementos:
                            elToModify = {app.MetaData};
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                ui.TextView.startup(app.jsBackDoor, elToModify{1}, appName);
                            end

                        case 2
                            % ...
                            
                        case 3
                            elToModify = {app.AntennaList_Tree};
                            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
                            if ~isempty(elDataTag)
                                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                                    struct('appName', appName, 'dataTag', elDataTag{1}, 'listener', struct('componentName', 'auxApp.winAddTask.AntennaList_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                                });
                            end
                    end
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

            jsBackDoor_Customizations(app, 0)
            jsBackDoor_Customizations(app, 1)

            % Define tamanho mínimo do app (não aplicável à versão webapp).
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.dockModule_Undock.Enable = 1;
                if ~app.isDocked
                    appUtil.winMinSize(app.UIFigure, class.Constants.windowMinSize)
                end
            end

            app.progressDialog.Visible = 'visible';

            app.receiverObj = app.mainApp.receiverObj;
            app.gpsObj      = app.mainApp.gpsObj;
            app.EB500Map    = app.mainApp.EB500Obj.SelectivityMap;            
            app.switchList  = struct2table(jsondecode(fileread(fullfile(app.mainApp.rootFolder, 'config', 'switchList.json'))));
            app.EMSatObj    = app.mainApp.EMSatObj;
            startup_tgtList(app)
            startup_Layout(app)

            app.progressDialog.Visible = 'hidden';
        end

        %-----------------------------------------------------------------%
        function startup_tgtList(app)
            tgtList = app.EMSatObj.TargetList;

            app.targetList = {};
            for ii = 1:numel(tgtList)
                if ~isempty(tgtList(ii).Target)
                    app.targetList = [app.targetList, {tgtList(ii).Target.Name}];
                end
            end
            app.targetList = unique(app.targetList);
        end

        %-----------------------------------------------------------------%
        function startup_Layout(app)
            % PAINEL À ESQUERDA 2: "INSTRUMENTOS"
            % (a) Lista de receptores.
            idx2 = find(app.receiverObj.List.Enable)';
            app.Receiver_List.Items = {};
            for ii = idx2
                receiverSocket = InstrumentSocket(app, app.receiverObj.List.Parameters{ii});
                app.Receiver_List.Items(end+1) = {sprintf('ID %d: %s - %s', ii, app.receiverObj.List.Name{ii}, receiverSocket)};
            end

            receiverFlag = false;
            if strcmp(app.infoEdition.type, 'edit')    
                selectedReceiverSocket = InstrumentSocket(app, app.mainApp.specObj(app.infoEdition.idx).Task.Receiver.Selection.Parameters{1});
                selectedReceiverName   = sprintf('%s - %s', app.mainApp.specObj(app.infoEdition.idx).Task.Receiver.Selection.Name{1}, selectedReceiverSocket);
                selectedReceiverIndex  = find(contains(app.Receiver_List.Items, selectedReceiverName), 1);

                if ~isempty(selectedReceiverIndex)
                    receiverFlag = true;
                end
            end

            % PAINEL À ESQUERDA 1: "ASPECTOS GERAIS"
            % (a) Lista de tarefas:
            % A tarefa padrão é a primeira. Exceto caso se trate da edição
            % de uma tarefa, cujo nome da tarefa consta na lista app.taskList.
            app.TaskName.Items = {app.taskList.Name};
            if strcmp(app.infoEdition.type, 'edit') && ismember(app.mainApp.specObj(app.infoEdition.idx).Task.Script.Name, app.TaskName.Items)
                app.TaskName.Value = app.mainApp.specObj(app.infoEdition.idx).Task.Script.Name;
            end
            General_Task(app)

            % O campo "EditedFlag" não existe originalmente no arquivo 
            % "taskList.json", devendo ser criado.
            for ii = 1:numel(app.taskList)
                for jj = 1:numel(app.taskList(ii).Band)
                    app.taskList(ii).Band(jj).EditedFlag = 0;
                end
            end

            % (b) Tipo de tarefa:
            if strcmp(app.infoEdition.type, 'edit')
                app.TaskType.Value = replace(app.mainApp.specObj(app.infoEdition.idx).Task.Type, ' (PRÉVIA)', '');
                if contains(app.mainApp.specObj(app.infoEdition.idx).Task.Type, '(PRÉVIA)')                    
                    app.PreviewTaskCheckbox.Value = true;
                end                
                General_TaskType(app)

                if strcmp(app.TaskType.Value, 'Rompimento de Máscara Espectral')
                    set(app.MaskFile_Button, 'Enable', 1, 'Tooltip', {app.mainApp.specObj(app.infoEdition.idx).Task.MaskFile})
                end
            end

            % PAINEIS À ESQUERDA 2 e 3: "INSTRUMENTOS" e "ANTENAS"
            if receiverFlag
                app.Receiver_List.Value = app.Receiver_List.Items{selectedReceiverIndex};

                % Ajustes finais relacionados ao receptor, caso se trate de 
                % tarefa em edição... o try/catch aqui é importante porque as 
                % referências dos valores "Sync", "Antenna" etc são obtidas de 
                % arquivos externos editáveis.

                try
                    app.Receiver_RstCommand.Value = app.mainApp.specObj(app.infoEdition.idx).Task.Receiver.Reset;
                    app.Receiver_SyncRef.Value    = app.mainApp.specObj(app.infoEdition.idx).Task.Receiver.Sync;

                    gpsMetaData = app.mainApp.specObj(app.infoEdition.idx).Task.Script.GPS;
                    if strcmp(gpsMetaData.Type, 'Manual')
                        app.GPS_List.Value            = 'ID 0: Manual';
                        GPS_instrSelection(app)

                        app.GPS_manualLatitude.Value  = gpsMetaData.Latitude;
                        app.GPS_manualLongitude.Value = gpsMetaData.Longitude;
                    end

                    switchMetaData = app.mainApp.specObj(app.infoEdition.idx).Task.Antenna.Switch;
                    if app.AntennaSwitch_Mode.Enable && ~isempty(switchMetaData.Name)
                        app.AntennaSwitch_Mode.Value = 1;
                        AntennaSwitch_ModeSelection(app)
                    end

                    antennaMetaData = app.mainApp.specObj(app.infoEdition.idx).Task.Antenna.MetaData;
                    if ismember(antennaMetaData.Name, app.AntennaName.Items)
                        app.AntennaName.Value = antennaMetaData.Name;
                        AntennaConfig_Selection(app)

                        app.Antenna_TrackingMode.Value = antennaMetaData.TrackingMode;
                        AntennaConfig_TrackingMode(app)

                        if antennaMetaData.Height ~= "NA"
                            app.AntennaHeight.Value = str2double(extractBefore(antennaMetaData.Height, 'm'));
                        end

                        if antennaMetaData.Azimuth ~= "NA"
                            app.AntennaAzimuth.Value = str2double(extractBefore(antennaMetaData.Azimuth, 'º'));
                        end

                        if antennaMetaData.Elevation ~= "NA"
                            app.AntennaElevation.Value = str2double(extractBefore(antennaMetaData.Elevation, 'º'));
                        end

                        if antennaMetaData.Polarization ~= "NA"
                            app.AntennaPolarization.Value = str2double(extractBefore(antennaMetaData.Polarization, 'º'));
                        end

                        AntennaConfig_Add(app)
                    end
                catch
                end
            end

            % (b) Visibilidade do botão "Pin", que possibilita importação
            %     das coordenadas geográficas da estação.
            if strcmp(app.mainApp.General.stationInfo.Type, 'Fixed')  && ...
                    (app.mainApp.General.stationInfo.Latitude  ~= -1) && ...
                    (app.mainApp.General.stationInfo.Longitude ~= -1)
                app.Tab2_Panel.ColumnWidth{2} = 22;
            else
                app.Tab2_Panel.ColumnWidth{2} = 0;
            end
        end


        %-----------------------------------------------------------------%
        function instrumentSocket = InstrumentSocket(app, instrumentParameters)
            Parameters = jsondecode(instrumentParameters);

            if isfield(Parameters, 'IP') && isfield(Parameters, 'Port')
                instrumentSocket = sprintf('%s:%s', Parameters.IP, Parameters.Port);
            elseif isfield(Parameters, 'IP')
                instrumentSocket = Parameters.IP;
            else
                instrumentSocket = Parameters.Port;
            end
        end


        %-----------------------------------------------------------------%
        function [instrHandle, msgError] = ConnectivityTest_Receiver_Aux(app, MessageBoxFlag)
            receiverName = SelectedReceiverName(app);

            idx1 = str2double(char(extractBetween(app.Receiver_List.Value, 'ID', ':')));
            idx2 = find(strcmp(app.receiverObj.Config.Name, receiverName), 1);

            instrSelected = struct('Type',       app.receiverObj.List.Type{idx1},  ...
                                   'Tag',        app.receiverObj.Config.Tag{idx2}, ...
                                   'Parameters', jsondecode(app.receiverObj.List.Parameters{idx1}));

            [instrHandle, msgError] = fcn.ConnectivityTest_Receiver(app, instrSelected, MessageBoxFlag);
        end


        %-----------------------------------------------------------------%
        function [instrHandle, gpsData, msgError] = ConnectivityTest_GPS_Aux(app, MessageBoxFlag)

            idx1 = str2double(char(extractBetween(app.GPS_List.Value, 'ID', ':'))) - numel(app.Receiver_List.Items);

            instrSelected = struct('Type',       app.gpsObj.List.Type{idx1}, ...
                                   'Parameters', jsondecode(app.gpsObj.List.Parameters{idx1}));
            
            [instrHandle, gpsData, msgError] = fcn.ConnectivityTest_GPS(app, instrSelected, MessageBoxFlag);
        end


        %-----------------------------------------------------------------%
        function AntennaConfig_Layout(app, Type)
            switch Type
                case "Enable"
                    set(findobj('Parent', app.Antenna_Grid, '-not', 'Type', 'uigrid'), 'Enable', 1)
                    set(app.AntennaAzimuth_Grid.Children, 'Enable', 1)                                

                case "Disable"
                    set(findobj('Parent', app.Antenna_Grid,        '-not', {'Type', 'uigrid', '-or', 'Type', 'uilabel'}), 'Enable', 0)
                    set(findobj('Parent', app.AntennaAzimuth_Grid, '-not', 'Type', 'uilabel'),                            'Enable', 0)
            end
        end


        %-----------------------------------------------------------------%
        function AntennaConfig_TrackingMode_Aux(app)
            app.Antenna_TrackingMode.Items = {'LookAngles', 'Manual'};
            app.Band_TargetList.Value = '';
            
            initialAntenna = app.Band_Antenna.Value;
            switchIndex    = SwitchIndex(app, 'default');
            set(app.Band_Antenna, 'Items', app.switchList.Antennas{switchIndex}, 'Value', initialAntenna)
        end


        %-----------------------------------------------------------------%
        function BandView_TreeBuilding(app, idx1)
            delete(app.Band_Tree.Children);
            for ii = 1:numel(app.taskList(idx1).Band)
                str = sprintf('ID %d: %.3f - %.3f MHz', app.taskList(idx1).Band(ii).ID,                ...
                                                        app.taskList(idx1).Band(ii).FreqStart ./ 1e+6, ...
                                                        app.taskList(idx1).Band(ii).FreqStop  ./ 1e+6);

                node = uitreenode(app.Band_Tree, 'Text', str, 'NodeData', ii, 'Icon', 'Playback_32.png');

                if strcmp(app.TaskType.Value, 'Rompimento de Máscara Espectral') && app.taskList(idx1).Band(ii).MaskTrigger.Status
                    node.Icon = "Occupancy_32.png";
                end
            end
            app.Band_Tree.SelectedNodes = app.Band_Tree.Children(1);
        end


        %-----------------------------------------------------------------%
        function BandView_SatelliteList(app)            
            if isempty(app.Band_TargetList.Value)
                switchIndex = SwitchIndex(app, 'default');

                switch app.AntennaSwitch_Name.Value                    
                    case 'EMSat'
                        set(app.Band_Antenna, 'Items', app.switchList.Antennas{switchIndex}, 'Value', '')

                    case 'ERMx'
                        app.Band_Antenna.Items = app.switchList.Antennas{switchIndex};
                end
                
            else
                tgtList = app.EMSatObj.TargetList;
                lnbList = app.EMSatObj.LNB;

                filteredList = {};
                for ii = 1:numel(tgtList)
                    if ~isempty(tgtList(ii).Target)
                        idx1 = find(string({tgtList(ii).Target.Name}) == app.Band_TargetList.Value, 1);
                        if ~isempty(idx1)
                            idx2 = find(contains(lnbList.Name, tgtList(ii).Name));
                            filteredList = [filteredList; lnbList.Name(idx2)];
                        end
                    end
                end
                set(app.Band_Antenna, 'Items', [{''}; filteredList], 'Value', '')
            end
        end


        %-----------------------------------------------------------------%
        function BandView_SatelliteValues(app)
            idx1 = find(strcmp({app.EMSatObj.Antenna.Name}, extractBefore(app.Band_Antenna.Value, ' ')), 1);
            idx2 = find(strcmp({app.EMSatObj.TargetList(idx1).Target.Name}, app.Band_TargetList.Value), 1);

            app.AntennaAzimuth.Value      = app.EMSatObj.TargetList(idx1).Target(idx2).Azimuth;
            app.AntennaElevation.Value    = app.EMSatObj.TargetList(idx1).Target(idx2).Elevation;
            app.AntennaPolarization.Value = app.EMSatObj.TargetList(idx1).Target(idx2).Polarization;
        end


        %-----------------------------------------------------------------%
        function BandView_EditablesParameters_Visibility(app)
            idx3 = SelectedReceiverIndex(app);

            switch app.receiverObj.Config.connectFlag(idx3)
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case 1
                    app.Band_ReceiverGrid.RowHeight(2:3)        = {22,0};
                    set(findobj(groot, 'Parent', app.Band_ReceiverGrid, 'Tag', 'task_Set1'), 'Enable', 1)
                    set(findobj(groot, 'Parent', app.Band_ReceiverGrid, 'Tag', 'task_Set2'), 'Enable', 0)

                    app.Band_Preamp.Enable                 = 1;                    
                    app.Band_SelectivityLabel.Visible      = 0;
                    app.Band_Selectivity.Visible           = 0;

                    if ~isempty(app.receiverObj.Config.scpiVBW_Options{idx3})
                        app.Band_VBWLabel.Visible          = 1;
                        app.Band_VBW.Visible               = 1;
                    else
                        app.Band_VBWLabel.Visible          = 0;
                        app.Band_VBW.Visible               = 0;
                    end
                    
                    app.Band_ResolutionLabel.Layout.Column = 1;
                    app.Band_Resolution.Layout.Column      = 1;
                    app.Band_IntegrationTimeLabel.Visible  = 0;
                    app.Band_IntegrationTime.Visible       = 0;

                % R&S EB500
                case {2, 3}
                    app.Band_ReceiverGrid.RowHeight(2:3)        = {0,22};
                    set(findobj(groot, 'Parent', app.Band_ReceiverGrid, 'Tag', 'task_Set1'), 'Enable', 0)
                    set(findobj(groot, 'Parent', app.Band_ReceiverGrid, 'Tag', 'task_Set2'), 'Enable', 1)

                    app.Band_Preamp.Enable                 = 0;
                    app.Band_SelectivityLabel.Visible      = 1;
                    app.Band_Selectivity.Visible           = 1;
                    app.Band_VBWLabel.Visible              = 0;
                    app.Band_VBW.Visible                   = 0;
                    app.Band_ResolutionLabel.Layout.Column = 2;
                    app.Band_Resolution.Layout.Column      = 2;
            end
        end


        %-----------------------------------------------------------------%
        function instrSettings = BandView_EditablesParameters_GetValues(app, idx1, idx2)
            idx3 = SelectedReceiverIndex(app);

            instrSettings = struct('StepWidth_Items',   [], 'StepWidth',       [], ...
                                   'DataPoints_Limits', [], 'DataPoints',      [], ...
                                   'Resolution_Items',  [], 'Resolution',      [], ...
                                   'VBW_Items',       {{}}, 'VBW',           {{}}, ...
                                   'Selectivity_Items', [], 'Selectivity',     [], ...
                                   'SensitivityMode',   [], 'Preamp',          [], ...
                                   'AttMode',           [], 'AttFactor_Items', [], ...
                                   'AttFactor',         [], 'LevelUnit',       [], ...
                                   'Detector_Items',    [], 'IntegrationTime', [], ...
                                   'DF_SquelchMode',    '', 'DF_SquelchValue', [], ...
                                   'DF_MeasTime',       []);

            span = app.taskList(idx1).Band(idx2).FreqStop - app.taskList(idx1).Band(idx2).FreqStart;            
            
            instrSettings.AttMode         = 'Auto';
            instrSettings.AttFactor_Items = strsplit(app.receiverObj.Config.Attenuation_Values{idx3}, ',');
            instrSettings.AttFactor       = instrSettings.AttFactor_Items{1};
            instrSettings.Detector_Items  = strsplit(app.receiverObj.Config.Detector_Items{idx3}, ',');

            switch app.receiverObj.Config.connectFlag(idx3)
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case 1
                    % RBW
                    instrSettings.Resolution_Items = strsplit(app.receiverObj.Config.Resolution_Values{idx3}, ',');
                    rbwValues                      = str2double(extractBefore(instrSettings.Resolution_Items, 'kHz'))*1000;
                    [~, rbwIndex]                  = min(abs(rbwValues - app.taskList(idx1).Band(idx2).Resolution));
                    instrSettings.Resolution       = instrSettings.Resolution_Items{rbwIndex};

                    % VBW
                    if ~isempty(app.receiverObj.Config.scpiVBW_Options{idx3})
                        instrSettings.VBW_Items = strsplit(app.receiverObj.Config.VBW_Values{idx3}, ',');

                        switch app.taskList(idx1).Band(idx2).VBW
                            case 'auto'
                                instrSettings.VBW = 'auto';

                            otherwise
                                switch app.taskList(idx1).Band(idx2).VBW
                                    case 'RBW';     VBW = app.taskList(idx1).Band(idx2).Resolution;
                                    case 'RBW/10';  VBW = app.taskList(idx1).Band(idx2).Resolution/10;
                                    case 'RBW/100'; VBW = app.taskList(idx1).Band(idx2).Resolution/100;
                                end

                                vbwValues         = str2double(extractBefore(instrSettings.VBW_Items, 'kHz'))*1000;                        
                                [~, vbwIndex]     = min(abs(vbwValues - VBW));
                                instrSettings.VBW = instrSettings.VBW_Items{vbwIndex};
                        end
                    end

                    % Others parameters...
                    instrSettings.DataPoints_Limits = app.receiverObj.Config.DataPoints_Limits{idx3};

                    DataPoints = round(span/app.taskList(idx1).Band(idx2).StepWidth + 1);
                    if     DataPoints < instrSettings.DataPoints_Limits(1); instrSettings.DataPoints = instrSettings.DataPoints_Limits(1);
                    elseif DataPoints > instrSettings.DataPoints_Limits(2); instrSettings.DataPoints = fix(instrSettings.DataPoints_Limits(2));
                    else;                                                   instrSettings.DataPoints = DataPoints;
                    end
                    instrSettings.StepWidth = span/(instrSettings.DataPoints - 1);

                    instrSettings.Selectivity     = '';

                    instrSettings.SensitivityMode = '0';
                    instrSettings.Preamp          = 'On';

                    instrSettings.LevelUnit       = app.taskList(idx1).Band(idx2).LevelUnit;
                    if contains(app.Receiver_List.Value, 'N9344C')
                        instrSettings.LevelUnit   = 'dBm';
                    end

                    switch app.taskList(idx1).Band(idx2).RFMode
                        case 'High Sensitivity'
                            instrSettings.AttMode         = 'Manual';
                            instrSettings.SensitivityMode = '1';
                        case 'Low Distortion'
                            instrSettings.Preamp          = 'Off';
                    end

                % R&S EB500
                case {2, 3}
                    instrSettings.StepWidth_Items   = strsplit(app.receiverObj.Config.StepWidth_Values{idx3}, ',');
                    instrSettings.Selectivity_Items = {'Normal', 'Narrow', 'Sharp'};

                    stepValues = [];
                    for ii = 1:length(instrSettings.StepWidth_Items)
                        stepValues = [stepValues, str2double(extractBefore(instrSettings.StepWidth_Items{ii}, ' kHz')).*1000];
                    end

                    stepIndex  = abs(stepValues - app.taskList(idx1).Band(idx2).StepWidth) == min(abs(stepValues - app.taskList(idx1).Band(idx2).StepWidth));
                    instrSettings.StepWidth  = instrSettings.StepWidth_Items{stepIndex};

                    instrSettings.DataPoints = span/(str2double(extractBefore(instrSettings.StepWidth, ' kHz'))*1000) + 1;

                    rbwValues = [];
                    rbwItems  = {};
                    for ii = 1:3
                        rbwValues = [rbwValues, app.EB500Map{instrSettings.StepWidth, ii}];
                        rbwItems  = [rbwItems,  sprintf('%.3f kHz', rbwValues(ii)/1000)];
                    end
                    instrSettings.Resolution_Items = rbwItems;

                    rbwIndex = find(abs(rbwValues - app.taskList(idx1).Band(idx2).Resolution) == min(abs(rbwValues - app.taskList(idx1).Band(idx2).Resolution)));
                    instrSettings.Resolution  = instrSettings.Resolution_Items{rbwIndex};
                    instrSettings.Selectivity = app.Band_Selectivity.Items{rbwIndex};

                    instrSettings.SensitivityMode = 'NORM';
                    instrSettings.Preamp          = 'Off';
                    instrSettings.LevelUnit       = 'dBµV';

                    switch app.taskList(idx1).Band(idx2).RFMode
                        case 'High Sensitivity'
                            instrSettings.AttMode = 'Manual';
                        case 'Low Distortion'
                            instrSettings.SensitivityMode = 'LOWD';
                    end

                    switch app.taskList(idx1).Band(idx2).TraceMode
                        case 'ClearWrite'
                            instrSettings.IntegrationTime = 0;
                        otherwise
                            instrSettings.IntegrationTime = 10 * app.taskList(idx1).Band(idx2).IntegrationFactor;
                    end
            end
        end


        %-----------------------------------------------------------------%
        function BandView_EditablesParameters_SaveValues(app, idx1, idx2)
            instrSettings = BandView_EditablesParameters_GetValues(app, idx1, idx2);

            app.taskList(idx1).Band(idx2).instrStepWidth_Items    = instrSettings.StepWidth_Items;
            app.taskList(idx1).Band(idx2).instrStepWidth          = instrSettings.StepWidth;
            app.taskList(idx1).Band(idx2).instrDataPoints_Limits  = instrSettings.DataPoints_Limits;
            app.taskList(idx1).Band(idx2).instrDataPoints         = instrSettings.DataPoints;
            app.taskList(idx1).Band(idx2).instrResolution_Items   = instrSettings.Resolution_Items;
            app.taskList(idx1).Band(idx2).instrResolution         = instrSettings.Resolution;
            app.taskList(idx1).Band(idx2).instrVBW_Items          = instrSettings.VBW_Items;
            app.taskList(idx1).Band(idx2).instrVBW                = instrSettings.VBW;            
            app.taskList(idx1).Band(idx2).instrSelectivity        = instrSettings.Selectivity;
            app.taskList(idx1).Band(idx2).instrSensitivityMode    = instrSettings.SensitivityMode;            
            app.taskList(idx1).Band(idx2).instrPreamp             = instrSettings.Preamp;
            app.taskList(idx1).Band(idx2).instrAttMode            = instrSettings.AttMode;
            app.taskList(idx1).Band(idx2).instrAttFactor_Items    = instrSettings.AttFactor_Items;
            app.taskList(idx1).Band(idx2).instrAttFactor          = instrSettings.AttFactor;
            app.taskList(idx1).Band(idx2).instrDetector_Items     = instrSettings.Detector_Items;
            app.taskList(idx1).Band(idx2).instrDetector           = instrSettings.Detector_Items{max([1, find(strcmp(app.taskList(idx1).Band(idx2).instrDetector_Items, app.taskList(idx1).Band(idx2).Detector), 1)])};
            app.taskList(idx1).Band(idx2).instrLevelUnit          = instrSettings.LevelUnit;
            app.taskList(idx1).Band(idx2).instrIntegrationTime    = instrSettings.IntegrationTime;
            app.taskList(idx1).Band(idx2).instrObservationSamples = app.taskList(idx1).Band(idx2).ObservationSamples;
            app.taskList(idx1).Band(idx2).DF_SquelchMode          = instrSettings.DF_SquelchMode;
            app.taskList(idx1).Band(idx2).DF_SquelchValue         = instrSettings.DF_SquelchValue;
            app.taskList(idx1).Band(idx2).DF_MeasTime             = instrSettings.DF_MeasTime;
            app.taskList(idx1).Band(idx2).instrTarget             = '';
            app.taskList(idx1).Band(idx2).instrAntenna            = '';
            app.taskList(idx1).Band(idx2).EditedFlag              = 0;

            app.Band_Refresh.Visible                              = 0;
        end


        %-----------------------------------------------------------------%
        function BandView_EditablesParameters_ShowValues(app, idx1, idx2)
            idx3 = SelectedReceiverIndex(app);
            
            if ~app.taskList(idx1).Band(idx2).EditedFlag
                BandView_EditablesParameters_SaveValues(app, idx1, idx2)
            else
                app.Band_Refresh.Visible = 1;
            end

            switch app.receiverObj.Config.connectFlag(idx3)
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case 1
                    if fix(diff(app.receiverObj.Config.DataPoints_Limits{idx3}))
                        set(app.Band_StepWidth1,  'Editable', 1, ...
                                                  'Value',  app.taskList(idx1).Band(idx2).instrStepWidth / 1000);
                        set(app.Band_DataPoints1, 'Limits', app.taskList(idx1).Band(idx2).instrDataPoints_Limits, ...
                                                  'Value',  app.taskList(idx1).Band(idx2).instrDataPoints)
                    else
                        set(app.Band_StepWidth1,  'Editable', 0, ...
                                                  'Value',  app.taskList(idx1).Band(idx2).instrStepWidth / 1000);
                        set(app.Band_DataPoints1, 'Limits', app.taskList(idx1).Band(idx2).instrDataPoints_Limits, ...
                                                  'Value',  app.receiverObj.Config.DataPoints_Limits{idx3}(1))
                    end

                    app.Band_IntegrationTimeLabel.Visible = 0;
                    app.Band_IntegrationTime.Visible      = 0;

                % R&S EB500
                case {2, 3}
                    set(app.Band_StepWidth2, 'Items', app.taskList(idx1).Band(idx2).instrStepWidth_Items, ...
                                             'Value', app.taskList(idx1).Band(idx2).instrStepWidth)
                    app.Band_DataPoints2.Value = app.taskList(idx1).Band(idx2).instrDataPoints;
                    app.Band_Selectivity.Value = app.taskList(idx1).Band(idx2).instrSelectivity;
                    app.Band_VBW.Items         = {};

                    app.Band_IntegrationTimeLabel.Visible = 1;
                    set(app.Band_IntegrationTime, 'Visible', 1, ...
                                                  'Value', app.taskList(idx1).Band(idx2).instrIntegrationTime)

                    switch app.taskList(idx1).Band(idx2).TraceMode
                        case 'ClearWrite'
                            app.Band_IntegrationTime.Enable = 0;
                        otherwise
                            app.Band_IntegrationTime.Enable = 1;
                    end
            end

            set(app.Band_Resolution, 'Items', app.taskList(idx1).Band(idx2).instrResolution_Items, ...
                                     'Value', app.taskList(idx1).Band(idx2).instrResolution)

            set(app.Band_VBW,        'Items', app.taskList(idx1).Band(idx2).instrVBW_Items,        ...
                                     'Value', app.taskList(idx1).Band(idx2).instrVBW)

            app.Band_Preamp.Value  = app.taskList(idx1).Band(idx2).instrPreamp;
            app.Band_attMode.Value = app.taskList(idx1).Band(idx2).instrAttMode;

            set(app.Band_attValue,   'Items', app.taskList(idx1).Band(idx2).instrAttFactor_Items,  ...
                                     'Value', app.taskList(idx1).Band(idx2).instrAttFactor)

            set(app.Band_Detector,   'Items', app.taskList(idx1).Band(idx2).instrDetector_Items,   ...
                                     'Value', app.taskList(idx1).Band(idx2).instrDetector)

            if strcmp(app.Band_attMode.Value, 'Auto')
                app.Band_attValueLabel.Visible = 0;
                app.Band_attValue.Visible      = 0;
            else
                app.Band_attValueLabel.Visible = 1;
                app.Band_attValue.Visible      = 1;
            end

            if ~isempty(app.taskList(idx1).Band(idx2).instrObservationSamples)
                app.Band_Samples.Value = app.taskList(idx1).Band(idx2).instrObservationSamples;
            end

            if ismember(app.taskList(idx1).Band(idx2).instrTarget, app.Band_TargetList.Items)
                app.Band_TargetList.Value = app.taskList(idx1).Band(idx2).instrTarget;
            end
            BandView_SatelliteList(app)

            if ismember(app.taskList(idx1).Band(idx2).instrAntenna, app.Band_Antenna.Items)
                app.Band_Antenna.Value = app.taskList(idx1).Band(idx2).instrAntenna;
            end

            % Parâmetros relacionados ao Direction Finder (DF):
            if isempty(app.taskList(idx1).Band(idx2).DF_SquelchMode)
                app.taskList(idx1).Band(idx2).DF_SquelchMode  = 'OFF';
            end

            if isempty(app.taskList(idx1).Band(idx2).DF_SquelchValue)
                app.taskList(idx1).Band(idx2).DF_SquelchValue = 10;
            end

            if isempty(app.taskList(idx1).Band(idx2).DF_MeasTime)
                app.taskList(idx1).Band(idx2).DF_MeasTime     = 1;
            end

            app.Band_DFSquelchMode.Value  = app.taskList(idx1).Band(idx2).DF_SquelchMode;
            app.Band_DFSquelchValue.Value = app.taskList(idx1).Band(idx2).DF_SquelchValue;
            app.Band_DFMeasTime.Value     = app.taskList(idx1).Band(idx2).DF_MeasTime * 1000;
        end


        %-----------------------------------------------------------------%
        function GPSRevisitTime(app)
            idx1 = SelectedTaskIndex(app);

            switch app.TaskType.Value
                case {'Drive-test', 'Drive-test (Level+Azimuth)'}
                    app.GPS_RevisitTime.Value = max([min([app.taskList(idx1).Band.RevisitTime]), app.GPS_RevisitTime.Limits(1)]);

                otherwise
                    if ~isempty(app.taskList(idx1).GPS.RevisitTime)
                        app.GPS_RevisitTime.Value = app.taskList(idx1).GPS.RevisitTime;
                    else
                        app.GPS_RevisitTime.Value = 60;
                    end
            end
        end


        %-----------------------------------------------------------------%
        function idx = SelectedTaskIndex(app)
            [~, idx] = ismember(app.TaskName.Value, app.TaskName.Items);
        end


        %-----------------------------------------------------------------%
        function idx = SelectedReceiverIndex(app)
            receiverName = SelectedReceiverName(app);
            
            idx = find(strcmp(app.receiverObj.Config.Name, receiverName));
            if numel(idx) > 1
                connectFlagList = app.receiverObj.Config.connectFlag(idx);

                switch app.TaskType.Value
                    case 'Drive-test (Level+Azimuth)'
                        idx = idx(connectFlagList == 3);

                    otherwise
                        idx = idx(connectFlagList ~= 3);
                end
                idx = idx(1);
            end
        end


        %-----------------------------------------------------------------%
        function receiverName = SelectedReceiverName(app)
            receiverName = char(extractBetween(app.Receiver_List.Value, ': ', ' -'));
        end


        %-----------------------------------------------------------------%
        function switchIndex = SwitchIndex(app, sourceType)
            % Se o modo comutador está ativado, identifica-se o seu índice
            % na tabela app.switchList. Isso permite, por exemplo, identificar
            % lista de antenas controladas pelo comutador.
            %            
            % Caso contrário, identifica-se lista de "antenas avulsas" que
            % podem ser usadas numa monitoração.

            if strcmp(sourceType, 'ReceiverChanged') || app.AntennaSwitch_Mode.Value
                receiverName = SelectedReceiverName(app);
                switchIndex  = find(strcmp(app.switchList.Receiver, receiverName), 1);
            else
                switchIndex  = find(strcmp(app.switchList.Switch, 'none'), 1);
            end
        end


        %-----------------------------------------------------------------%
        function MainButtonPushed_Validations(app)
            idx1 = SelectedTaskIndex(app);

            % VALIDATIONS
            % (a) SELECTED SPECTRAL MASK FILE
            switch app.TaskType.Value
                case 'Drive-test'
                    if strcmp(app.GPS_List.Value, 'ID 0: Manual')
                        error('Uma monitoração do tipo "%s" deve contemplar o uso de um GPS.', app.TaskType.Value)
                    end

                case 'Drive-test (Level+Azimuth)'
                    if strcmp(app.GPS_List.Value, 'ID 0: Manual')
                        error('Uma monitoração do tipo "%s" deve contemplar o uso de um GPS.', app.TaskType.Value)

                    elseif ~contains(app.Receiver_List.Value, 'EB500')
                        error('Uma monitoração do tipo "%s" é limitada ao receptor R&S EB500.', app.TaskType.Value)

                    else
                        jj = [];
                        for ii = 1:numel(app.taskList(idx1).Band)
                            FreqSpan  = app.taskList(idx1).Band(ii).FreqStop - app.taskList(idx1).Band(ii).FreqStart;
                            StepWidth = class.Constants.FreqStr2NumConversion(app.taskList(idx1).Band(ii).instrStepWidth);

                            % Retorna erro se escolhido um Span diferente de 1, 
                            % 2, 5, 10 ou 20 MHz. E retorna erro se for selecionado 
                            % um StepWidth não aceito pelo EB500.
                            %
                            % O mapeamento desses parâmetros, do EB500, consta 
                            % na classe EB500Lib e foram transcritos do manual 
                            % de operação do EB500, com a ressalva que alguns 
                            % valores foram ajustados diretamente no EB500 GUI 
                            % porque o manual parece estar desatualizado.

                            spanIdx   = find(app.mainApp.EB500Obj.FFMSpanStepMap.Span == FreqSpan, 1);
                            if isempty(spanIdx)
                                jj = [jj, ii];
                            else
                                minStep = app.mainApp.EB500Obj.FFMSpanStepMap.minStepWidth(spanIdx);
                                maxStep = app.mainApp.EB500Obj.FFMSpanStepMap.maxStepWidth(spanIdx);

                                if (StepWidth < minStep) || (StepWidth > maxStep)
                                    jj = [jj, ii];
                                end
                            end
                        end
    
                        if ~isempty(jj)
                            error('Inserido valores inválidos para ao menos um dos seguintes parâmetros: "Span" ou "StepWidth".\nID: %s\n\nOs valores permitidos de "Span" são 1, 2, 5, 10 ou 20 MHz. Já o <i>range</i> de valores permitidos de "StepWidth" dependem do valor do "Span".', strjoin(string(jj), ', '))
                        end
                    end
                
                case 'Rompimento de Máscara Espectral'
                    if isempty(app.MaskFile_Button.Tooltip{1})
                        error('Não selecionado o arquivo de máscara espectral.')
                    end
            end

            % (b) VALID OBSERVATION PERIOD
            switch app.ObservationType.Value
                case 'Período específico'
                    BeginTime = app.SpecificTime_DatePicker1.Value + hours(app.SpecificTime_Spinner1.Value) + minutes(app.SpecificTime_Spinner2.Value);
                    EndTime   = app.SpecificTime_DatePicker2.Value + hours(app.SpecificTime_Spinner3.Value) + minutes(app.SpecificTime_Spinner4.Value);
                    
                    if isnat(BeginTime) || isnat(EndTime) || (BeginTime > EndTime) || (EndTime < datetime('now'))
                        error('Período de observação inválido.')
                    end

                case 'Quantidade específica de amostras'
                    jj = [];
                    for ii = 1:numel(app.taskList(idx1).Band)
                        if app.taskList(idx1).Band(ii).instrObservationSamples <= 1
                            jj = [jj, ii];
                        end
                    end

                    if ~isempty(jj)
                        error('Quantidade inválida de varreduras da(s) faixa(s) de frequência indicada(s) a seguir.\nID: %s\n\nO valor mínimo são duas varreduras.', strjoin(string(jj), ', '))
                    end
            end

            % (c) COORDINATES DIFFERENT FROM (-1,-1)
            if strcmp(app.GPS_List.Value, 'ID 0: Manual') && (app.GPS_manualLatitude.Value == -1) && (app.GPS_manualLongitude.Value == -1)
                error('Coordenadas geográficas inválidas.')
            end

            % (d) REVISIT TIME (GPS x BANDS)
            if ~strcmp(app.GPS_List.Value, 'ID 0: Manual')
                RevisitTimeArray = [app.GPS_RevisitTime.Value, [app.taskList(idx1).Band.RevisitTime]];
                if isequal(find(RevisitTimeArray == min(RevisitTimeArray)), 1)
                    error('O tempo de revisita do GPS não pode ser inferior ao mínimo tempo de revisita da(s) faixa(s) de frequência.')
                end
            end

            % (e) ADDED CONFIG PARAMETERS FOR EACH ANTENNA TO BE USED
            if isempty(app.AntennaList_Tree.Children)
                error('Não configurados os parâmetros de instalação da(s) antena(s) em uso.')
            elseif ~app.AntennaSwitch_Mode.Value && (numel(app.AntennaList_Tree.Children) > 1)
                    error('A configuração dos parâmetros de instalação de mais de uma antena é possível apenas quando habilitado o comutador.')
            end

            if app.AntennaSwitch_Mode.Value
                jj = [];
                AntennaList = {};

                for ii = 1:numel(app.taskList(idx1).Band)
                    if isempty(app.taskList(idx1).Band(ii).instrAntenna)
                        jj = [jj, ii];
                    else
                        AntennaList{end+1} = app.taskList(idx1).Band(ii).instrAntenna;
                    end
                end
                AntennaList = unique(AntennaList);

                if ~isempty(jj)
                    error('Não selecionada a antena da(s) faixa(s) de frequência indicada(s) a seguir.\nID: %s', strjoin(string(jj), ', '))
                else
                    AntennaMetaData = {app.AntennaList_Tree.Children.Text};
    
                    idx2 = contains(AntennaList, AntennaMetaData);
                    if ~all(idx2)
                        error('Não foram configurados os parâmetros de instalação da(s) antena(s) indicada(s) a seguir.\nAntenas: %s', strjoin(AntennaList(~idx2), ', '))
                    end
                end

            else
                if ~any(contains(app.AntennaName.Items, app.AntennaList_Tree.Children.Text))
                    error('Foram configurados os parâmetros de instalação de antena que não faz parte do rol de antenas possíveis, visto que foi desabilitado o comutador.')
                end
            end
        end


        %-----------------------------------------------------------------%
        function MainButtonPushed_ObservationSamples(app)
            idx1 = SelectedTaskIndex(app);

            for ii = 1:numel(app.taskList(idx1).Band)
                app.taskList(idx1).Band(ii).instrObservationSamples = -1;
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, editionType)
            
            app.mainApp = mainApp;

            app.infoEdition = editionType;
            switch app.infoEdition.type
                case 'new'
                    app.taskList   = mainApp.taskList;
                    app.okBtn.Text = 'Inclui tarefa';
                case 'edit'
                    app.taskList   = class.taskList.app2raw(mainApp.specObj(editionType.idx).Task.Script);
                    app.okBtn.Text = 'Edita tarefa';
            end
            
            if app.isDocked
                app.GridLayout.Padding(4)  = 30;
                app.dockModuleGrid.Visible = 1;
                app.jsBackDoor = mainApp.jsBackDoor;
                startup_Controller(app)
            else
                appUtil.winPosition(app.UIFigure)
                startup_timerCreation(app)
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'TASK:ADD')
            delete(app)
            
        end

        % Value changed function: TaskName
        function General_Task(app, event)

            % Aspectos a atualizar:
            % - PAINEL 1: Codificação e Período de observação;
            % - PAINEL 2: Árvore e metadados do fluxo selecionado; e
            % - PAINEL 3: Metadados do fluxo selecionado (peculiaridades receptor).

            idx1 = SelectedTaskIndex(app);

            app.BitsPerPoint.Value = sprintf('%d bits', app.taskList(idx1).BitsPerSample);

            switch app.taskList(idx1).Observation.Type
                case 'Duration'
                    app.ObservationType.Value = app.ObservationType.Items{1};

                    Duration_sec = app.taskList(idx1).Observation.Duration;
                    if Duration_sec >= 3600
                        app.Duration.Value     = Duration_sec ./ 3600;
                        app.DurationUnit.Value = 'hr';
                    else
                        app.Duration.Value     = Duration_sec ./ 60;
                        app.DurationUnit.Value = 'min';
                    end

                case 'Time'
                    app.ObservationType.Value = app.ObservationType.Items{2};
                    
                    BeginTime = datetime(app.taskList(idx1).Observation.BeginTime, "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");
                    EndTime   = datetime(app.taskList(idx1).Observation.EndTime,   "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");

                    app.SpecificTime_DatePicker1.Value = BeginTime;
                    app.SpecificTime_Spinner1.Value = hour(BeginTime);
                    app.SpecificTime_Spinner2.Value = minute(BeginTime);
                    
                    app.SpecificTime_DatePicker2.Value = EndTime;
                    app.SpecificTime_Spinner3.Value = hour(EndTime);
                    app.SpecificTime_Spinner4.Value = minute(EndTime);

                case 'Samples'
                    app.ObservationType.Value = app.ObservationType.Items{3};
            end
            General_ObservationType(app)
            
            BandView_TreeBuilding(app, idx1)
            Receiver_instrSelection(app)
            
            BandView_TreeSelectionChanged(app)

        end

        % Value changed function: TaskType
        function General_TaskType(app, event)

            switch app.TaskType.Value
                case 'Rompimento de Máscara Espectral'
                    app.Tab1_Panel.ColumnWidth(2:3) = {22, 22};
                    if ~isempty(app.MaskFile_Button.Tooltip{1})
                        app.MaskFile_Button.Enable     = 1;
                    end

                otherwise
                    app.Tab1_Panel.ColumnWidth(2:3) = {0, 0};
                    app.MaskFile_Button.Enable         = 0;
            end

            switch app.TaskType.Value
                case 'Drive-test (Level+Azimuth)'
                    set(findobj(app.Band_DFGrid.Children, '-not', 'Type', 'uilabel'), 'Enable', 1)

                otherwise
                    set(findobj(app.Band_DFGrid.Children, '-not', 'Type', 'uilabel'), 'Enable', 0)

            end

            idx1 = SelectedTaskIndex(app);
            BandView_TreeBuilding(app, idx1)

            % A alteração do tipo de tarefa - caso envolva a tarefa "Drive-test"
            % - tem impacto no tempo de revisita do GPS. Importante, portanto, 
            % atualizar o valor do campo.
            GPS_instrSelection(app)
            
        end

        % Button pushed function: AddMaskFile_Button
        function General_SpectralMask_Add(app, event)
            
            [Filename, Filepath] = uigetfile({'*.csv', '(*.csv)'}, ...
                                              'Selecione um arquivo de máscara espectral', 'MultiSelect', 'off');
            figure(app.UIFigure)
            
            if Filename
                try
                    set(app.MaskFile_Button, 'Enable', 1, 'Tooltip', {fullfile(Filepath, Filename)})
                catch ME
                    set(app.MaskFile_Button, 'Enable', 0, 'Tooltip', {''})
                    appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));                    
                end
            end

        end

        % Button pushed function: MaskFile_Button
        function General_SpectralMask_View(app, event)
            
            try
                msg = fileread(app.MaskFile_Button.Tooltip{1});
                appUtil.modalWindow(app.UIFigure, 'warning', msg);

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end

        end

        % Value changed function: ObservationType
        function General_ObservationType(app, event)
            
            switch app.ObservationType.Value
                case 'Duração'
                    app.ObservationPanel_Grid.RowHeight{3} = 22;
                    set(app.Duration_Grid.Children,     'Enable', 1, 'Visible', 1)
                    set(app.SpecificTime_Grid.Children, 'Enable', 0, 'Visible', 0)
                    app.Band_Samples.Enable = 0;

                case 'Período específico'
                    app.ObservationPanel_Grid.RowHeight{3} = 0;
                    set(app.Duration_Grid.Children,     'Enable', 0, 'Visible', 0)
                    set(app.SpecificTime_Grid.Children, 'Enable', 1, 'Visible', 1)
                    app.Band_Samples.Enable = 0;

                case 'Quantidade específica de amostras'
                    app.ObservationPanel_Grid.RowHeight{3} = 0;
                    set(app.Duration_Grid.Children,     'Enable', 0, 'Visible', 0)
                    set(app.SpecificTime_Grid.Children, 'Enable', 0, 'Visible', 0)
                    app.Band_Samples.Enable = 1;
            end
            
        end

        % Value changed function: Receiver_List
        function Receiver_instrSelection(app, event)
            
            idx1 = SelectedTaskIndex(app);
            idx2 = app.Band_Tree.SelectedNodes.NodeData;
            idx3 = SelectedReceiverIndex(app);
            
            % Manual GPS:
            app.GPS_List.Items = {'ID 0: Manual'};
            
            % Add Built-in GPS...
            if ~isempty(app.receiverObj.Config.scpiGPS{idx3})
                app.GPS_List.Items = [app.GPS_List.Items, app.Receiver_List.Value];
            end
            NN = numel(app.Receiver_List.Items);

            % Add External GPS...
            indGPSs = find(app.gpsObj.List.Enable);
            for ii = 1:numel(indGPSs)
                Parameters = jsondecode(app.gpsObj.List.Parameters{indGPSs(ii)});

                switch app.gpsObj.List.Type{indGPSs(ii)}
                    case 'Serial'
                        Socket = Parameters.Port;
                    case 'TCPIP Socket'
                        Socket = sprintf('%s:%s', Parameters.IP, Parameters.Port);
                end

                app.GPS_List.Items = [app.GPS_List.Items, sprintf('ID %d: %s - %s', NN+ii, app.gpsObj.List.Name{indGPSs(ii)}, Socket)];
            end           

            if ~isempty(app.receiverObj.Config.scpiGPS{idx3})
                if ~strcmp(app.taskList(idx1).GPS.Type, 'manual')
                    app.GPS_List.Value = app.Receiver_List.Value;
                end
            end
            GPS_instrSelection(app)

            
            % RECEIVER
            app.Receiver_SyncRef.Items = strsplit(app.receiverObj.Config.SyncOptions{idx3}, ',');

            if strcmp(app.infoEdition.type, 'new')
                for ii = 1:numel(app.taskList(idx1).Band)
                    BandView_EditablesParameters_SaveValues(app, idx1, ii)
                end
            end

            BandView_EditablesParameters_Visibility(app)
            BandView_EditablesParameters_ShowValues(app, idx1, idx2)


            % ANTENNA SWITCH
            set(app.AntennaSwitch_Mode, 'Enable', 0, 'Value', 0)
            set(app.AntennaSwitch_Name, 'Enable', 0, 'Value', '')            
            
            switchIndex = SwitchIndex(app, 'ReceiverChanged');            
            if ~isempty(switchIndex)
                set(app.AntennaSwitch_Mode, 'Enable', 1, 'Value', app.switchList.SwitchDefaultStatus(switchIndex))                
            end
            AntennaSwitch_ModeSelection(app)

        end

        % Button pushed function: Receiver_Connectivity
        function Receiver_ConnectivityTest(app, event)
            
            app.progressDialog.Visible = 'visible';
            ConnectivityTest_Receiver_Aux(app, 1);            
            app.progressDialog.Visible = 'hidden';

        end

        % Value changed function: GPS_List
        function GPS_instrSelection(app, event)

            switch app.GPS_List.Value
                case 'ID 0: Manual'  
                    set(app.GPS_Grid.Children, 'Enable', 1)                
                    app.GPS_RevisitTime.Enable          = 0;

                otherwise
                    set(app.GPS_Grid.Children, 'Enable', 0)
                    app.GPS_manualLatitudeLabel.Enable  = 1;
                    app.GPS_manualLongitudeLabel.Enable = 1;
                    app.GPS_RevisitTimeLabel.Enable     = 1;
                    app.GPS_RevisitTime.Enable          = 1;

                    switch app.TaskType.Value
                        case {'Drive-test', 'Drive-test (Level+Azimuth)'}
                            app.GPS_RevisitTime.Editable = 0;

                        otherwise
                            app.GPS_RevisitTime.Editable = 1;
                    end
                    GPSRevisitTime(app)
            end

        end

        % Button pushed function: GPS_Connectivity
        function GPS_ConnectivityTest(app, event)
            
            if strcmp(app.GPS_List.Value, 'ID 0: Manual') && (app.GPS_manualLatitude.Value == -1) && (app.GPS_manualLongitude.Value == -1)
                appUtil.modalWindow(app.UIFigure, 'warning', 'Coordenadas geográficas inválidas.');
                return
            end

            gps = struct('Status',     0, ...
                         'Latitude',  -1, ...
                         'Longitude', -1, ...
                         'TimeStamp', '');

            app.progressDialog.Visible = 'visible';

            try
                if strcmp(app.Receiver_List.Value, app.GPS_List.Value)
                    instrHandle = ConnectivityTest_Receiver_Aux(app, 0);
                    if ~isempty(instrHandle)
                        gps = fcn.gpsBuiltInReader(instrHandle);
                    end
    
                elseif strcmp(app.GPS_List.Value, 'ID 0: Manual')
                    gps = struct('Status',    1,                             ...
                                 'Latitude',  app.GPS_manualLatitude.Value,  ...
                                 'Longitude', app.GPS_manualLongitude.Value, ...
                                 'TimeStamp', '');
    
                else
                    instrHandle = ConnectivityTest_GPS_Aux(app, 0);
                    if ~isempty(instrHandle)
                        gps = fcn.gpsExternalReader(instrHandle, 1);
                    end
                end
    
                if gps.Status
                    [City, Distance] = fcn.geoFindCity(gps);

                    if isempty(gps.TimeStamp); gps.TimeStamp = 'NA';
                    end

                    msg = sprintf(['Status: %.0f\n'    ...
                                   'Latitude: %.6f\n'  ...
                                   'Longitude: %.6f\n' ...
                                   'Timestamp: %s\n\n' ...
                                   'Nota:\nCoordenadas geográficas distam <b>%.1f km</b> da sede do município <b>%s</b>.'], ...
                                   gps.Status, gps.Latitude, gps.Longitude, gps.TimeStamp, Distance, City);
                    
                    appUtil.modalWindow(app.UIFigure, 'warning', msg);
                    
                    app.GPS_manualLatitude.Value  = round(gps.Latitude,  6);
                    app.GPS_manualLongitude.Value = round(gps.Longitude, 6);
    
                else
                    error('<b>Não recebida informação válida do instrumento acerca das coordenadas geográficas do local de monitoração.</b>\n%s', jsonencode(gps))
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', getReport(ME));
            end

            app.progressDialog.Visible = 'hidden';

        end

        % Value changed function: AntennaSwitch_Mode
        function AntennaSwitch_ModeSelection(app, event)
            
            idx1 = SelectedTaskIndex(app);
            idx2 = app.Band_Tree.SelectedNodes.NodeData;

            switchIndex = SwitchIndex(app, 'default');

            if app.AntennaSwitch_Mode.Value
                set(app.AntennaSwitch_Name,        'Enable', 1, 'Value', app.switchList.Switch{switchIndex})                
                set(app.Band_AntennaGrid.Children, 'Enable', 1)
                
                switch app.AntennaSwitch_Name.Value                    
                    case 'EMSat'
                        set(app.AntennaName,     'Enable', 0, 'Items', app.switchList.Antennas{switchIndex})
                        set(app.Band_TargetList, 'Items', [{''}, app.targetList], 'Value', '')

                        if ismember(app.taskList(idx1).Band(idx2).instrTarget, app.Band_TargetList.Items)
                            app.Band_TargetList.Value = app.taskList(idx1).Band(idx2).instrTarget;
                        end
                        BandView_SatelliteList(app)

                    case 'ERMx'
                        set(app.AntennaName,     'Enable', 0, 'Items', app.switchList.Antennas{switchIndex})
                        set(app.Band_TargetList, 'Enable', 0, 'Items', {''})
                        app.Band_Antenna.Items = app.switchList.Antennas{switchIndex};
                        app.Band_TargetListRefresh.Enable = 0;
                end

                if ismember(app.taskList(idx1).Band(idx2).instrAntenna, app.Band_Antenna.Items)
                    app.Band_Antenna.Value = app.taskList(idx1).Band(idx2).instrAntenna;
                end

            else
                set(app.AntennaSwitch_Name, 'Enable', 0, 'Value', '')
                set(app.AntennaName,        'Enable', 1, 'Items', app.switchList.Antennas{switchIndex}, 'Value', '')

                set(app.Band_TargetList,    'Enable', 0, 'Items', {''})
                set(app.Band_Antenna,       'Enable', 0, 'Items', {''})
                app.Band_TargetListRefresh.Enable = 0;
            end

            AntennaConfig_Selection(app)
            
        end

        % Value changed function: AntennaName
        function AntennaConfig_Selection(app, event)

            if ~isempty(app.AntennaName.Value)
                switch app.AntennaSwitch_Name.Value
                    case 'EMSat'
                        if ~isempty(app.Band_TargetList.Value)
                            set(app.Antenna_TrackingMode, 'Items', {'Target', 'LookAngles', 'Manual'}, ...
                                                          'Value', 'Target')
                        else
                            initialSelection = app.Antenna_TrackingMode.Value;
                            if ~ismember(initialSelection, {'LookAngles', 'Manual'})
                                initialSelection = 'Manual';
                            end
                            set(app.Antenna_TrackingMode, 'Items', {'LookAngles', 'Manual'}, ...
                                                          'Value', initialSelection)
                        end
                    
                    otherwise
                        app.Antenna_TrackingMode.Items = {'Manual'};
                end    
                app.AddAntenna_Image.Enable = 1;

            else
                app.Antenna_TrackingMode.Items = {'Manual'};
                app.AddAntenna_Image.Enable = 0;
            end

            AntennaConfig_TrackingMode(app)

        end

        % Value changed function: Antenna_TrackingMode
        function AntennaConfig_TrackingMode(app, event)

            if ~isempty(app.AntennaName.Value)
                switch app.Antenna_TrackingMode.Value
                    case 'Target'
                        AntennaConfig_Layout(app, 'Disable')
                        app.Antenna_TrackingMode.Enable = 1;
                        BandView_SatelliteValues(app)
                    

                    case 'LookAngles'
                        AntennaConfig_Layout(app, 'Enable')
                        app.AntennaHeight.Enable = 0;
                        set(app.AntennaAzimuthRef, 'Enable', 0, 'Value', 'NV')
                        AntennaConfig_TrackingMode_Aux(app)
                        

                    case 'Manual'
                        switch app.AntennaSwitch_Name.Value
                            case 'EMSat'
                                AntennaConfig_Layout(app, 'Enable')
                                app.AntennaHeight.Enable = 0;
                                AntennaConfig_TrackingMode_Aux(app)

                            case 'ERMx'
                                AntennaConfig_Layout(app, 'Disable')
                                app.AntennaHeight.Enable = 1;

                            otherwise
                                if strcmp(app.AntennaName.Value, 'Unlisted (Directional)')
                                    AntennaConfig_Layout(app, 'Enable')
                                    app.Antenna_TrackingMode.Enable = 0;
                                else
                                    AntennaConfig_Layout(app, 'Disable')
                                    app.AntennaHeight.Enable = 1;
                                end
                        end
                end

            else
                AntennaConfig_Layout(app, 'Disable')
            end
            
        end

        % Image clicked function: AddAntenna_Image
        function AntennaConfig_Add(app, event)
            
            % antNode1
            antNode1 = app.Antenna_TrackingMode.Value;

            if ~isempty(app.Band_TargetList.Value)
                antNode1 = sprintf('%s; %s', antNode1, app.Band_TargetList.Value);
            else
                antNode1 = sprintf('%s; "NA"', antNode1);
            end

            % antNode2
            if app.AntennaHeight.Enable
                antNode2 = sprintf('%.0fm', app.AntennaHeight.Value);
            else
                antNode2 = '"NA"';
            end

            if app.AntennaAzimuth.Enable
                antNode2 = sprintf('%s; %.3fº %s; %.3fº; %.1fº', antNode2,                    ...
                                                                 app.AntennaAzimuth.Value,    ...
                                                                 app.AntennaAzimuthRef.Value, ...
                                                                 app.AntennaElevation.Value,  ...
                                                                 app.AntennaPolarization.Value);
            else
                antNode2 = sprintf('%s; "NA"; "NA"; "NA"', antNode2);
            end

            % old values
            AntennaList = {};
            if ~isempty(app.AntennaList_Tree.Children)
                AntennaList = {app.AntennaList_Tree.Children.Text};
            end

            % add new value
            switch app.AntennaSwitch_Name.Value
                case 'EMSat'; antennaName = extractBefore(app.AntennaName.Value, ' ');
                otherwise;    antennaName = app.AntennaName.Value;
            end
            
            idx = find(strcmp(AntennaList, antennaName), 1);
            if ~isempty(idx)
                app.AntennaList_Tree.Children(idx).Children(1).Text = antNode1;
                app.AntennaList_Tree.Children(idx).Children(2).Text = antNode2;
            else
                tempValue = numel(app.AntennaList_Tree.Children)+1;
                tempNode  = uitreenode(app.AntennaList_Tree, 'Text', antennaName,   ...
                                                             'NodeData', tempValue, ...
                                                             'ContextMenu', app.ContextMenu);

                uitreenode(tempNode, 'Text', antNode1, 'NodeData', tempValue, 'ContextMenu', app.ContextMenu);
                uitreenode(tempNode, 'Text', antNode2, 'NodeData', tempValue, 'ContextMenu', app.ContextMenu);
            end

        end

        % Menu selected function: delAntennaEntry
        function AntennaConfig_Delete(app, event)
            
            if ~isempty(app.AntennaList_Tree.SelectedNodes)
                delete(app.AntennaList_Tree.SelectedNodes)

                for ii = 1:numel(app.AntennaList_Tree.Children)
                    app.AntennaList_Tree.Children(ii).NodeData             = ii;
                    app.AntennaList_Tree.Children(ii).Children(1).NodeData = ii;
                    app.AntennaList_Tree.Children(ii).Children(2).NodeData = ii;
                end
            end

        end

        % Selection changed function: Band_Tree
        function BandView_TreeSelectionChanged(app, event)

            % Aspectos a atualizar:
            % - PAINEL 2: Metadados do fluxo selecionado; e
            % - PAINEL 3: Metadados do fluxo selecionado (peculiaridades receptor).

            idx1 = SelectedTaskIndex(app);
            idx2 = app.Band_Tree.SelectedNodes.NodeData;

            dataStruct    = struct('group', 'RECEPTOR',                                                                                     ...
                                   'value', struct('StepWidth',         sprintf('%.3f kHz', app.taskList(idx1).Band(idx2).StepWidth/1e+3),  ...
                                                   'Resolution',        sprintf('%.3f kHz', app.taskList(idx1).Band(idx2).Resolution/1e+3), ...
                                                   'VBW',               app.taskList(idx1).Band(idx2).VBW,                                  ...
                                                   'Detector',          app.taskList(idx1).Band(idx2).Detector,                             ...
                                                   'TraceMode',         app.taskList(idx1).Band(idx2).TraceMode,                            ...
                                                   'IntegrationFactor', app.taskList(idx1).Band(idx2).IntegrationFactor,                    ...
                                                   'RFMode',            app.taskList(idx1).Band(idx2).RFMode,                               ...
                                                   'LevelUnit',         app.taskList(idx1).Band(idx2).LevelUnit));            
            dataStruct(2) = struct('group', 'TEMPO DE REVISITA', ...
                                   'value', struct('Receiver', sprintf('%.3f seg', app.taskList(idx1).Band(idx2).RevisitTime)));        
            dataStruct(3) = struct('group', 'OUTROS ASPECTOS',                                                             ...
                                   'value', struct('Description',        app.taskList(idx1).Band(idx2).Description,        ...
                                                   'ObservationSamples', app.taskList(idx1).Band(idx2).ObservationSamples, ...
                                                   'MaskTrigger',        app.taskList(idx1).Band(idx2).MaskTrigger));

            app.MetaData.Text = textFormatGUI.struct2PrettyPrintList(dataStruct);

            BandView_EditablesParameters_ShowValues(app, idx1, idx2)

            if ~isempty(app.Band_Antenna.Value)
                BandView_EditedParameters(app, struct('Source', app.Band_Antenna))
            end

        end

        % Image clicked function: Band_Refresh
        function BandView_Refresh(app, event)

            idx1 = SelectedTaskIndex(app);
            idx2 = app.Band_Tree.SelectedNodes.NodeData;

            app.taskList(idx1).Band(idx2).EditedFlag = 0;
            BandView_EditablesParameters_ShowValues(app, idx1, idx2)

        end

        % Value changed function: Band_Antenna, Band_DFMeasTime, 
        % ...and 15 other components
        function BandView_EditedParameters(app, event)

            idx1 = SelectedTaskIndex(app);
            idx2 = app.Band_Tree.SelectedNodes.NodeData;

            switch event.Source
                % OPERATION COMPLEXITY: 1 OF 3
                case app.Band_Samples;         app.taskList(idx1).Band(idx2).instrObservationSamples = app.Band_Samples.Value;
                case app.Band_attValue;        app.taskList(idx1).Band(idx2).instrAttFactor          = app.Band_attValue.Value;
                case app.Band_Preamp;          app.taskList(idx1).Band(idx2).instrPreamp             = app.Band_Preamp.Value;
                case app.Band_IntegrationTime; app.taskList(idx1).Band(idx2).instrIntegrationTime    = app.Band_IntegrationTime.Value;
                case app.Band_Detector;        app.taskList(idx1).Band(idx2).instrDetector           = app.Band_Detector.Value;
                case app.Band_VBW;             app.taskList(idx1).Band(idx2).instrVBW                = app.Band_VBW.Value;
                case app.Band_DFSquelchMode;   app.taskList(idx1).Band(idx2).DF_SquelchMode          = app.Band_DFSquelchMode.Value;
                case app.Band_DFSquelchValue;  app.taskList(idx1).Band(idx2).DF_SquelchValue         = app.Band_DFSquelchValue.Value;
                case app.Band_DFMeasTime;      app.taskList(idx1).Band(idx2).DF_MeasTime             = app.Band_DFMeasTime.Value / 1000;
                
                % OPERATION COMPLEXITY: 2 OF 3
                case app.Band_Antenna
                    app.taskList(idx1).Band(idx2).instrAntenna = app.Band_Antenna.Value;
                    
                    if ismember(app.AntennaSwitch_Name.Value, {'EMSat', 'ERMx'})
                        app.AntennaName.Value = app.Band_Antenna.Value;
                        AntennaConfig_Selection(app)
                    end
                
                case app.Band_TargetList
                    app.taskList(idx1).Band(idx2).instrTarget = app.Band_TargetList.Value;

                    if ~isempty(app.Band_TargetList.Value); app.Antenna_TrackingMode.Items = {'Target', 'LookAngles', 'Manual'};
                    else;                               app.Antenna_TrackingMode.Items = {'LookAngles', 'Manual'};
                    end
                    
                    initialSatellite = app.Band_Antenna.Value;
                    BandView_SatelliteList(app)

                    if ~isempty(initialSatellite)
                        BandView_EditedParameters(app, struct('Source', app.Band_Antenna))
                    end

                case app.Band_DataPoints1
                    if ~fix(diff(app.Band_DataPoints1.Limits))
                        return
                    end        
                    span = app.taskList(idx1).Band(idx2).FreqStop - app.taskList(idx1).Band(idx2).FreqStart;
                    app.Band_StepWidth1.Value = (span/(app.Band_DataPoints1.Value-1)) / 1000;
        
                    app.taskList(idx1).Band(idx2).instrDataPoints = app.Band_DataPoints1.Value;
                    app.taskList(idx1).Band(idx2).instrStepWidth  = app.Band_StepWidth1.Value*1000;

                case app.Band_Selectivity
                    app.Band_Resolution.Value = sprintf('%.3f kHz', app.EB500Map{app.Band_StepWidth2.Value, app.Band_Selectivity.Value}/1000);
        
                    app.taskList(idx1).Band(idx2).instrSelectivity = app.Band_Selectivity.Value;
                    app.taskList(idx1).Band(idx2).instrResolution  = app.Band_Resolution.Value;

                case app.Band_Resolution
                    app.taskList(idx1).Band(idx2).instrResolution  = app.Band_Resolution.Value;
        
                    if contains(app.Receiver_List.Value, 'EB500')
                        if app.Band_Selectivity.Visible
                            ind3 = find(strcmp(app.Band_Resolution.Items, app.Band_Resolution.Value));
                            app.Band_Selectivity.Value = app.Band_Selectivity.Items{ind3};
                        end
                        app.taskList(idx1).Band(idx2).instrSelectivity = app.Band_Selectivity.Value;
                    end

                case app.Band_attMode
                    app.taskList(idx1).Band(idx2).instrAttMode = app.Band_attMode.Value;
        
                    if strcmp(app.Band_attMode.Value, 'Auto')
                        app.Band_attValueLabel.Visible = 0;
                        app.Band_attValue.Visible      = 0;
                    else
                        app.Band_attValueLabel.Visible = 1;
                        app.Band_attValue.Visible      = 1;
                    end


                % OPERATION COMPLEXITY: 3 OF 3
                case app.Band_StepWidth1
                    span = app.taskList(idx1).Band(idx2).FreqStop - app.taskList(idx1).Band(idx2).FreqStart;
                    DataPoints = round(span/(app.Band_StepWidth1.Value*1000) + 1);
                    if DataPoints < app.Band_DataPoints1.Limits(1)
                        app.Band_DataPoints1.Value = app.Band_DataPoints1.Limits(1);
                    elseif DataPoints > app.Band_DataPoints1.Limits(2)
                        app.Band_DataPoints1.Value = fix(app.Band_DataPoints1.Limits(2));
                    else
                        app.Band_DataPoints1.Value = DataPoints;
                    end        
                    app.Band_StepWidth1.Value = (span/(app.Band_DataPoints1.Value-1)) / 1000;
        
                    app.taskList(idx1).Band(idx2).instrStepWidth  = 1000*app.Band_StepWidth1.Value;
                    app.taskList(idx1).Band(idx2).instrDataPoints = app.Band_DataPoints1.Value;

                case app.Band_StepWidth2
                    span = app.taskList(idx1).Band(idx2).FreqStop - app.taskList(idx1).Band(idx2).FreqStart;
                    stepValue = extractBefore(app.Band_StepWidth2.Value, ' kHz');
        
                    app.Band_DataPoints2.Value = span/(1000*str2double(stepValue)) + 1;
        
                    rbwValues = [];
                    rbwItems  = {};
                    for ii = 1:3
                        rbwValues = [rbwValues, app.EB500Map{app.Band_StepWidth2.Value,ii}];
                        rbwItems  = [rbwItems,  sprintf('%.3f kHz', rbwValues(ii)/1000)];
                    end
                    app.Band_Resolution.Items = rbwItems;
        
                    rbwIndex = find(abs(rbwValues - app.taskList(idx1).Band(idx2).Resolution) == min(abs(rbwValues - app.taskList(idx1).Band(idx2).Resolution)));
                    app.Band_Resolution.Value = app.Band_Resolution.Items{rbwIndex};
                    app.Band_Selectivity.Value = app.Band_Selectivity.Items{rbwIndex};
        
                    app.taskList(idx1).Band(idx2).instrStepWidth   = app.Band_StepWidth2.Value;
                    app.taskList(idx1).Band(idx2).instrDataPoints  = app.Band_DataPoints2.Value;
                    app.taskList(idx1).Band(idx2).instrSelectivity = app.Band_Selectivity.Value;
        
                    app.taskList(idx1).Band(idx2).instrResolution_Items = app.Band_Resolution.Items;
                    app.taskList(idx1).Band(idx2).instrResolution       = app.Band_Resolution.Value;
            end

            app.taskList(idx1).Band(idx2).EditedFlag = 1;
            app.Band_Refresh.Visible                 = 1;
            
        end

        % Image clicked function: Band_TargetListRefresh
        function Band_TargetListRefreshImageClicked(app, event)
            
            app.progressDialog.Visible = 'visible';
            
            % Tentativa de atualizar lista de alvos (EMSat), montando, ao
            % final, uma tabela com todos os registros (tgtTable_new).
            FullFileName = fullfile(app.mainApp.General.userPath, 'EMSatLib.json');
            [antList, tgtList] = TargetListUpdate(app.EMSatObj, FullFileName);

            logSummary = {antList.LOG};
            logSummary(cellfun(@(x) isempty(x), logSummary)) = [];

            [tgtTable_new, tgtTableSummary_new] = TargetProperties(app.EMSatObj, tgtList);
            [~,            tgtTableSummary_old] = TargetProperties(app.EMSatObj);


            % Tela de confirmação:
            tgtListInfo     = struct('group', 'LISTA ATUAL DE ALVOS',                       'value', tgtTableSummary_old);
            tgtListInfo(2)  = struct('group', 'NOVA LISTA DE ALVOS',                        'value', tgtTableSummary_new);
            tgtListInfo(3)  = struct('group', 'MENSAGENS DE ERRO NA GERAÇÃO DA NOVA LISTA', 'value', struct('Message', deblank(strjoin(logSummary, '\n\n'))));

            tgtListInfoHTML = textFormatGUI.struct2PrettyPrintList(tgtListInfo);

            app.progressDialog.Visible = 'hidden';
            selection = uiconfirm(app.UIFigure, tgtListInfoHTML, 'appColeta', 'Interpreter', 'html', 'Options', {'Atualizar lista', 'Salvar planilha', 'Cancelar'}, 'DefaultOption', 3, 'CancelOption', 3, 'Icon', 'question');

            switch selection
                case 'Atualizar lista'; movefile(FullFileName, fullfile(app.mainApp.rootFolder, 'config', 'EMSatLib.json'));
                case 'Salvar planilha'; writetable(tgtTable_new, replace(FullFileName, '.json', '.xlsx'))
            end

        end

        % Button pushed function: okBtn
        function okBtnPushed(app, event)
            
            app.progressDialog.Visible = 'visible';

            % (A) VALIDATIONS
            try
                MainButtonPushed_Validations(app)
            catch ME
                appUtil.modalWindow(app.UIFigure, 'error', ME.message);
                app.progressDialog.Visible = 'hidden';
                return
            end

            % (B) GENERAL ASPECTS OF THE SELECTED TASK
            idx1 = SelectedTaskIndex(app);
            idx2 = SelectedReceiverIndex(app);

            % Type
            taskType     = app.TaskType.Value;
            if app.PreviewTaskCheckbox.Value
                taskType = [taskType ' (PRÉVIA)'];
            end
            
            % BitsPerSample
            app.taskList(idx1).BitsPerSample = str2double(extractBefore(app.BitsPerPoint.Value, 'bits'));

            % Observation
            switch app.ObservationType.Value
                case 'Duração'
                    if app.Duration.Value == inf
                        Duration_sec     = inf;
                        Duration_EndTime = '';
                    else
                        switch app.DurationUnit.Value
                            case 'min'; Duration_sec = app.Duration.Value * 60;
                            case 'hr';  Duration_sec = app.Duration.Value * 3600;
                        end
                        Duration_EndTime = datestr(now+seconds(Duration_sec), 'dd/mm/yyyy HH:MM:ss');
                    end

                    app.taskList(idx1).Observation = struct('Type',      'Duration',                          ...
                                                            'BeginTime', datestr(now, 'dd/mm/yyyy HH:MM:ss'), ...
                                                            'EndTime',   Duration_EndTime,                    ...
                                                            'Duration',  Duration_sec);
                    MainButtonPushed_ObservationSamples(app)

                case 'Período específico'
                    BeginTime = app.SpecificTime_DatePicker1.Value + hours(app.SpecificTime_Spinner1.Value) + minutes(app.SpecificTime_Spinner2.Value);
                    EndTime   = app.SpecificTime_DatePicker2.Value + hours(app.SpecificTime_Spinner3.Value) + minutes(app.SpecificTime_Spinner4.Value);

                    app.taskList(idx1).Observation = struct('Type',      'Time',                                    ...
                                                            'BeginTime', datestr(BeginTime, 'dd/mm/yyyy HH:MM:ss'), ...
                                                            'EndTime',   datestr(EndTime,   'dd/mm/yyyy HH:MM:ss'), ...
                                                            'Duration',  []);
                    MainButtonPushed_ObservationSamples(app)

                case 'Quantidade específica de amostras'
                    app.taskList(idx1).Observation = struct('Type',      'Samples',                           ...
                                                            'BeginTime', datestr(now, 'dd/mm/yyyy HH:MM:ss'), ...
                                                            'EndTime',   '',                                  ...
                                                            'Duration',  []);
            end

            % GPS
            switch app.GPS_List.Value
                case 'ID 0: Manual'
                    app.taskList(idx1).GPS = struct('Type',        'Manual',                      ...
                                                    'Latitude',    app.GPS_manualLatitude.Value,  ...
                                                    'Longitude',   app.GPS_manualLongitude.Value, ...
                                                    'RevisitTime', []);
                otherwise
                    if strcmp(app.Receiver_List.Value, app.GPS_List.Value); GPSType = 'Built-in';
                    else;                                                   GPSType = 'External';
                    end

                    app.taskList(idx1).GPS = struct('Type',        GPSType, ...
                                                    'Latitude',    [],      ...
                                                    'Longitude',   [],      ...
                                                    'RevisitTime', app.GPS_RevisitTime.Value);
            end

            % SCRIPT
            % Eliminar os valores dos metadados aplicáveis apenas a uma
            % tarefa do tipo "Drive-test (Level+Azimuth)", garantindo que
            % essa informação não seja inserida no arquivo binário.
            if ~contains(taskType, 'Drive-test (Level+Azimuth)')
                for ii = 1:numel(app.taskList(idx1).Band)
                    app.taskList(idx1).Band(ii).DF_SquelchMode  = '';
                    app.taskList(idx1).Band(ii).DF_SquelchValue = [];
                    app.taskList(idx1).Band(ii).DF_MeasTime     = [];
                end
            end


            % (C) FINAL OPERATIONS
            try
                % RECEIVER
                idx3 = str2double(char(extractBetween(app.Receiver_List.Value, 'ID', ':')));
                sReceiver = app.receiverObj.List(idx3,:);

                [hReceiver, errorMsg] = ConnectivityTest_Receiver_Aux(app, 0);
                if ~isempty(errorMsg)
                    error(errorMsg)
                end

                if hReceiver.UserData.nTasks > 0
                    if ~strcmp(hReceiver.UserData.SyncMode, app.Receiver_SyncRef.Value)
                        error('O receptor selecionado está envolvido em outra(s) tarefa(s), com modo de sincronismo diferente do selecionado, o que não é permitido.')
                    elseif strcmp(app.Receiver_RstCommand.Value, 'On')
                        error('Na atual tarefa foi definido que no seu início deve ser dado o comando de RESET no receptor, o que não é permitido quando este receptor já está envolvido em outra(s) tarefa(s).')
                    end
                end


                % STREAMING (UDP SOCKET)
                hStreaming = [];
                if ismember(app.receiverObj.Config.connectFlag(idx2), [2, 3])
                    [app.mainApp.udpPortArray, udpIndex] = fcn.udpSockets(app.mainApp.udpPortArray, app.mainApp.EB500Obj.udpPort);
                    if ~isempty(udpIndex)
                        hStreaming = app.mainApp.udpPortArray{udpIndex};
                    end
                end

                % GPS
                sGPS = [];
                hGPS = [];
                if ~ismember(app.GPS_List.Value, {'ID 0: Manual', app.Receiver_List.Value})
                    idx4 = str2double(char(extractBetween(app.GPS_List.Value, 'ID', ':'))) - numel(app.Receiver_List.Items);
                    sGPS = app.gpsObj.List(idx4,:);

                    [hGPS, ~, errorMsg] = ConnectivityTest_GPS_Aux(app, 0);
                    if ~isempty(errorMsg)
                        error(errorMsg)
                    end
                end

                % ANTENNA (MATRIX SWITCH & ANTENNA/LNB POSITION)
                switchIndex     = SwitchIndex(app, 'default');
                antennaList     = app.switchList.Antennas{switchIndex};
                antennaMetaData = struct('Name', {}, 'TrackingMode', {}, 'Target', {}, 'Height', {}, 'Azimuth', {}, 'Elevation', {}, 'Polarization', {});

                for kk = 1:numel(app.AntennaList_Tree.Children)
                    Parameters = replace(strsplit(strjoin({app.AntennaList_Tree.Children(kk).Children.Text}, '; '), '; '), '"', '');

                    if any(contains(antennaList, app.AntennaList_Tree.Children(kk).Text))
                        antennaMetaData(end+1,:) = struct('Name',         app.AntennaList_Tree.Children(kk).Text, ...
                                                          'TrackingMode', Parameters{1}, ...
                                                          'Target',       Parameters{2}, ...
                                                          'Height',       Parameters{3}, ...
                                                          'Azimuth',      Parameters{4}, ...
                                                          'Elevation',    Parameters{5}, ...
                                                          'Polarization', Parameters{6});
                    end
                end

                if strcmp(app.AntennaSwitch_Name.Value, 'EMSat')
                    fcn.antennaTracking(app, antennaMetaData, app.progressDialog);
                end

            catch ME
                appUtil.modalWindow(app.UIFigure, 'warning', ME.message);
                app.progressDialog.Visible = 'hidden';
                return
            end

            % newTask
            newTask                     = class.taskClass;
            newTask.Type                = taskType;
            newTask.Script              = app.taskList(idx1);
            newTask.MaskFile            = app.MaskFile_Button.Tooltip{1};            
            newTask.Receiver(1).Handle  = hReceiver;
            newTask.Receiver.Selection  = sReceiver;
            newTask.Receiver.Config     = app.receiverObj.Config(idx2,:);
            newTask.Receiver.Reset      = app.Receiver_RstCommand.Value;
            newTask.Receiver.Sync       = app.Receiver_SyncRef.Value;
            newTask.Streaming(1).Handle = hStreaming;
            newTask.GPS(1).Handle       = hGPS;
            newTask.GPS.Selection       = sGPS;
            newTask.Antenna(1).Switch   = struct('Name', app.AntennaSwitch_Name.Value, 'OutputPort', app.switchList.SwitchOutputPort(switchIndex));
            newTask.Antenna.MetaData    = antennaMetaData;
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'AddOrEditTask', 'TASK:ADD', app.infoEdition, newTask)

        end

        % Button pushed function: GPS_FixedStation
        function GPS_FixedStationButtonPushed(app, event)
            
            app.GPS_List.Value            = 'ID 0: Manual';
            app.GPS_manualLatitude.Value  = app.mainApp.General.stationInfo.Latitude;
            app.GPS_manualLongitude.Value = app.mainApp.General.stationInfo.Longitude;

            GPS_instrSelection(app)

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

        % Selection change function: TaskControl
        function TaskControlSelectionChanged(app, event)
            selectedTab = app.TaskControl.SelectedTab;
            
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
                app.UIFigure.Position = [300 180 1244 660];
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
            app.GridLayout.ColumnWidth = {10, 320, 10, 320, 10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TaskControl
            app.TaskControl = uitabgroup(app.GridLayout);
            app.TaskControl.AutoResizeChildren = 'off';
            app.TaskControl.SelectionChangedFcn = createCallbackFcn(app, @TaskControlSelectionChanged, true);
            app.TaskControl.Layout.Row = [3 4];
            app.TaskControl.Layout.Column = 2;

            % Create TAREFATab
            app.TAREFATab = uitab(app.TaskControl);
            app.TAREFATab.AutoResizeChildren = 'off';
            app.TAREFATab.Title = 'TAREFA';

            % Create Tab1_Panel
            app.Tab1_Panel = uigridlayout(app.TAREFATab);
            app.Tab1_Panel.ColumnWidth = {'1x', 0, 0};
            app.Tab1_Panel.RowHeight = {17, 22, 22, 22, 22, 22, 22, 22, '1x'};
            app.Tab1_Panel.ColumnSpacing = 5;
            app.Tab1_Panel.RowSpacing = 5;
            app.Tab1_Panel.BackgroundColor = [1 1 1];

            % Create BitsPerPoint
            app.BitsPerPoint = uidropdown(app.Tab1_Panel);
            app.BitsPerPoint.Items = {'8 bits', '16 bits', '32 bits'};
            app.BitsPerPoint.Tag = 'task_Editable';
            app.BitsPerPoint.FontSize = 11;
            app.BitsPerPoint.BackgroundColor = [1 1 1];
            app.BitsPerPoint.Layout.Row = 7;
            app.BitsPerPoint.Layout.Column = [1 3];
            app.BitsPerPoint.Value = '8 bits';

            % Create ObservationLabel
            app.ObservationLabel = uilabel(app.Tab1_Panel);
            app.ObservationLabel.VerticalAlignment = 'bottom';
            app.ObservationLabel.FontSize = 10;
            app.ObservationLabel.Layout.Row = 8;
            app.ObservationLabel.Layout.Column = 1;
            app.ObservationLabel.Text = 'PERÍODO DE OBSERVAÇÃO:';

            % Create ObservationPanel
            app.ObservationPanel = uipanel(app.Tab1_Panel);
            app.ObservationPanel.AutoResizeChildren = 'off';
            app.ObservationPanel.Layout.Row = 9;
            app.ObservationPanel.Layout.Column = [1 3];

            % Create ObservationPanel_Grid
            app.ObservationPanel_Grid = uigridlayout(app.ObservationPanel);
            app.ObservationPanel_Grid.ColumnWidth = {'1x'};
            app.ObservationPanel_Grid.RowHeight = {17, 22, 22, 49};
            app.ObservationPanel_Grid.ColumnSpacing = 11;
            app.ObservationPanel_Grid.RowSpacing = 5;
            app.ObservationPanel_Grid.Padding = [10 10 10 2];
            app.ObservationPanel_Grid.BackgroundColor = [1 1 1];

            % Create ObservationTypeLabel
            app.ObservationTypeLabel = uilabel(app.ObservationPanel_Grid);
            app.ObservationTypeLabel.VerticalAlignment = 'bottom';
            app.ObservationTypeLabel.FontSize = 10;
            app.ObservationTypeLabel.Layout.Row = 1;
            app.ObservationTypeLabel.Layout.Column = 1;
            app.ObservationTypeLabel.Text = 'Tipo:';

            % Create ObservationType
            app.ObservationType = uidropdown(app.ObservationPanel_Grid);
            app.ObservationType.Items = {'Duração', 'Período específico', 'Quantidade específica de amostras'};
            app.ObservationType.ValueChangedFcn = createCallbackFcn(app, @General_ObservationType, true);
            app.ObservationType.Tag = 'task_Editable';
            app.ObservationType.FontSize = 11;
            app.ObservationType.BackgroundColor = [1 1 1];
            app.ObservationType.Layout.Row = 2;
            app.ObservationType.Layout.Column = 1;
            app.ObservationType.Value = 'Duração';

            % Create Duration_Grid
            app.Duration_Grid = uigridlayout(app.ObservationPanel_Grid);
            app.Duration_Grid.RowHeight = {'1x'};
            app.Duration_Grid.RowSpacing = 5;
            app.Duration_Grid.Padding = [0 0 0 0];
            app.Duration_Grid.Layout.Row = 3;
            app.Duration_Grid.Layout.Column = 1;
            app.Duration_Grid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create Duration
            app.Duration = uieditfield(app.Duration_Grid, 'numeric');
            app.Duration.Limits = [1 Inf];
            app.Duration.ValueDisplayFormat = '%.3f';
            app.Duration.Tag = 'task_Editable';
            app.Duration.FontSize = 11;
            app.Duration.Layout.Row = 1;
            app.Duration.Layout.Column = 1;
            app.Duration.Value = 10;

            % Create DurationUnit
            app.DurationUnit = uidropdown(app.Duration_Grid);
            app.DurationUnit.Items = {'min', 'hr'};
            app.DurationUnit.Tag = 'task_Editable';
            app.DurationUnit.FontSize = 11;
            app.DurationUnit.BackgroundColor = [1 1 1];
            app.DurationUnit.Layout.Row = 1;
            app.DurationUnit.Layout.Column = 2;
            app.DurationUnit.Value = 'min';

            % Create SpecificTime_Grid
            app.SpecificTime_Grid = uigridlayout(app.ObservationPanel_Grid);
            app.SpecificTime_Grid.ColumnWidth = {'1x', 5, '1x', 10, '1x', 5, '1x'};
            app.SpecificTime_Grid.RowHeight = {22, 22};
            app.SpecificTime_Grid.ColumnSpacing = 0;
            app.SpecificTime_Grid.RowSpacing = 5;
            app.SpecificTime_Grid.Padding = [0 0 0 0];
            app.SpecificTime_Grid.Layout.Row = 4;
            app.SpecificTime_Grid.Layout.Column = 1;
            app.SpecificTime_Grid.BackgroundColor = [1 1 1];

            % Create SpecificTime_DatePicker1
            app.SpecificTime_DatePicker1 = uidatepicker(app.SpecificTime_Grid);
            app.SpecificTime_DatePicker1.DisplayFormat = 'dd/MM/uuuu';
            app.SpecificTime_DatePicker1.FontSize = 11;
            app.SpecificTime_DatePicker1.Enable = 'off';
            app.SpecificTime_DatePicker1.Visible = 'off';
            app.SpecificTime_DatePicker1.Layout.Row = 1;
            app.SpecificTime_DatePicker1.Layout.Column = [1 3];

            % Create SpecificTime_Spinner1
            app.SpecificTime_Spinner1 = uispinner(app.SpecificTime_Grid);
            app.SpecificTime_Spinner1.Limits = [0 23];
            app.SpecificTime_Spinner1.RoundFractionalValues = 'on';
            app.SpecificTime_Spinner1.ValueDisplayFormat = '%.0f';
            app.SpecificTime_Spinner1.HorizontalAlignment = 'center';
            app.SpecificTime_Spinner1.FontSize = 11;
            app.SpecificTime_Spinner1.Enable = 'off';
            app.SpecificTime_Spinner1.Visible = 'off';
            app.SpecificTime_Spinner1.Layout.Row = 2;
            app.SpecificTime_Spinner1.Layout.Column = 1;

            % Create SpecificTime_Spinner2
            app.SpecificTime_Spinner2 = uispinner(app.SpecificTime_Grid);
            app.SpecificTime_Spinner2.Step = 10;
            app.SpecificTime_Spinner2.Limits = [0 59];
            app.SpecificTime_Spinner2.RoundFractionalValues = 'on';
            app.SpecificTime_Spinner2.ValueDisplayFormat = '%.0f';
            app.SpecificTime_Spinner2.HorizontalAlignment = 'center';
            app.SpecificTime_Spinner2.FontSize = 11;
            app.SpecificTime_Spinner2.Enable = 'off';
            app.SpecificTime_Spinner2.Visible = 'off';
            app.SpecificTime_Spinner2.Layout.Row = 2;
            app.SpecificTime_Spinner2.Layout.Column = 3;

            % Create SpecificTime_DatePicker2
            app.SpecificTime_DatePicker2 = uidatepicker(app.SpecificTime_Grid);
            app.SpecificTime_DatePicker2.DisplayFormat = 'dd/MM/uuuu';
            app.SpecificTime_DatePicker2.FontSize = 11;
            app.SpecificTime_DatePicker2.Enable = 'off';
            app.SpecificTime_DatePicker2.Visible = 'off';
            app.SpecificTime_DatePicker2.Layout.Row = 1;
            app.SpecificTime_DatePicker2.Layout.Column = [5 7];

            % Create SpecificTime_Spinner3
            app.SpecificTime_Spinner3 = uispinner(app.SpecificTime_Grid);
            app.SpecificTime_Spinner3.Limits = [0 23];
            app.SpecificTime_Spinner3.RoundFractionalValues = 'on';
            app.SpecificTime_Spinner3.ValueDisplayFormat = '%.0f';
            app.SpecificTime_Spinner3.HorizontalAlignment = 'center';
            app.SpecificTime_Spinner3.FontSize = 11;
            app.SpecificTime_Spinner3.Enable = 'off';
            app.SpecificTime_Spinner3.Visible = 'off';
            app.SpecificTime_Spinner3.Layout.Row = 2;
            app.SpecificTime_Spinner3.Layout.Column = 5;
            app.SpecificTime_Spinner3.Value = 23;

            % Create SpecificTime_Spinner4
            app.SpecificTime_Spinner4 = uispinner(app.SpecificTime_Grid);
            app.SpecificTime_Spinner4.Step = 10;
            app.SpecificTime_Spinner4.Limits = [0 59];
            app.SpecificTime_Spinner4.RoundFractionalValues = 'on';
            app.SpecificTime_Spinner4.ValueDisplayFormat = '%.0f';
            app.SpecificTime_Spinner4.HorizontalAlignment = 'center';
            app.SpecificTime_Spinner4.FontSize = 11;
            app.SpecificTime_Spinner4.Enable = 'off';
            app.SpecificTime_Spinner4.Visible = 'off';
            app.SpecificTime_Spinner4.Layout.Row = 2;
            app.SpecificTime_Spinner4.Layout.Column = 7;
            app.SpecificTime_Spinner4.Value = 59;

            % Create SpecificTime_Mark1
            app.SpecificTime_Mark1 = uilabel(app.SpecificTime_Grid);
            app.SpecificTime_Mark1.FontSize = 10;
            app.SpecificTime_Mark1.Enable = 'off';
            app.SpecificTime_Mark1.Visible = 'off';
            app.SpecificTime_Mark1.Layout.Row = 2;
            app.SpecificTime_Mark1.Layout.Column = 2;
            app.SpecificTime_Mark1.Text = ':';

            % Create SpecificTime_Mark2
            app.SpecificTime_Mark2 = uilabel(app.SpecificTime_Grid);
            app.SpecificTime_Mark2.FontSize = 10;
            app.SpecificTime_Mark2.Enable = 'off';
            app.SpecificTime_Mark2.Visible = 'off';
            app.SpecificTime_Mark2.Layout.Row = 2;
            app.SpecificTime_Mark2.Layout.Column = 6;
            app.SpecificTime_Mark2.Text = ':';

            % Create BitsPerPointLabel
            app.BitsPerPointLabel = uilabel(app.Tab1_Panel);
            app.BitsPerPointLabel.VerticalAlignment = 'bottom';
            app.BitsPerPointLabel.FontSize = 10;
            app.BitsPerPointLabel.Layout.Row = 6;
            app.BitsPerPointLabel.Layout.Column = 1;
            app.BitsPerPointLabel.Text = 'CODIFICAÇÃO:';

            % Create TaskNameLabel
            app.TaskNameLabel = uilabel(app.Tab1_Panel);
            app.TaskNameLabel.VerticalAlignment = 'bottom';
            app.TaskNameLabel.FontSize = 10;
            app.TaskNameLabel.Layout.Row = 1;
            app.TaskNameLabel.Layout.Column = 1;
            app.TaskNameLabel.Text = 'NOME:';

            % Create TaskName
            app.TaskName = uidropdown(app.Tab1_Panel);
            app.TaskName.Items = {};
            app.TaskName.ValueChangedFcn = createCallbackFcn(app, @General_Task, true);
            app.TaskName.Tag = 'task_Editable';
            app.TaskName.FontSize = 11;
            app.TaskName.BackgroundColor = [1 1 1];
            app.TaskName.Layout.Row = 2;
            app.TaskName.Layout.Column = [1 3];
            app.TaskName.Value = {};

            % Create MaskFile_Button
            app.MaskFile_Button = uibutton(app.Tab1_Panel, 'push');
            app.MaskFile_Button.ButtonPushedFcn = createCallbackFcn(app, @General_SpectralMask_View, true);
            app.MaskFile_Button.Icon = 'Mask_32.png';
            app.MaskFile_Button.BackgroundColor = [0.9804 0.9804 0.9804];
            app.MaskFile_Button.Enable = 'off';
            app.MaskFile_Button.Tooltip = {''};
            app.MaskFile_Button.Layout.Row = 4;
            app.MaskFile_Button.Layout.Column = 3;
            app.MaskFile_Button.Text = '';

            % Create AddMaskFile_Button
            app.AddMaskFile_Button = uibutton(app.Tab1_Panel, 'push');
            app.AddMaskFile_Button.ButtonPushedFcn = createCallbackFcn(app, @General_SpectralMask_Add, true);
            app.AddMaskFile_Button.Tag = 'task_Editable';
            app.AddMaskFile_Button.Icon = 'OpenFile_36x36.png';
            app.AddMaskFile_Button.BackgroundColor = [0.9804 0.9804 0.9804];
            app.AddMaskFile_Button.Tooltip = {'Máscara espectral'};
            app.AddMaskFile_Button.Layout.Row = 4;
            app.AddMaskFile_Button.Layout.Column = 2;
            app.AddMaskFile_Button.Text = '';

            % Create PreviewTaskCheckbox
            app.PreviewTaskCheckbox = uicheckbox(app.Tab1_Panel);
            app.PreviewTaskCheckbox.Text = 'PRÉVIA (não registra monitoração em arquivo)';
            app.PreviewTaskCheckbox.FontSize = 10;
            app.PreviewTaskCheckbox.Layout.Row = 5;
            app.PreviewTaskCheckbox.Layout.Column = [1 3];

            % Create TaskTypeLabel
            app.TaskTypeLabel = uilabel(app.Tab1_Panel);
            app.TaskTypeLabel.VerticalAlignment = 'bottom';
            app.TaskTypeLabel.FontSize = 10;
            app.TaskTypeLabel.Layout.Row = 3;
            app.TaskTypeLabel.Layout.Column = 1;
            app.TaskTypeLabel.Text = 'TIPO:';

            % Create TaskType
            app.TaskType = uidropdown(app.Tab1_Panel);
            app.TaskType.Items = {'Monitoração regular', 'Drive-test', 'Drive-test (Level+Azimuth)', 'Rompimento de Máscara Espectral'};
            app.TaskType.ValueChangedFcn = createCallbackFcn(app, @General_TaskType, true);
            app.TaskType.Tag = 'task_Editable';
            app.TaskType.FontSize = 11;
            app.TaskType.BackgroundColor = [1 1 1];
            app.TaskType.Layout.Row = 4;
            app.TaskType.Layout.Column = 1;
            app.TaskType.Value = 'Monitoração regular';

            % Create INSTRUMENTOSTab
            app.INSTRUMENTOSTab = uitab(app.TaskControl);
            app.INSTRUMENTOSTab.AutoResizeChildren = 'off';
            app.INSTRUMENTOSTab.Title = 'INSTRUMENTOS';

            % Create Tab2_Panel
            app.Tab2_Panel = uigridlayout(app.INSTRUMENTOSTab);
            app.Tab2_Panel.ColumnWidth = {'1x', 22, 22};
            app.Tab2_Panel.RowHeight = {17, 22, 60, 22, 22, '1x'};
            app.Tab2_Panel.ColumnSpacing = 5;
            app.Tab2_Panel.RowSpacing = 5;
            app.Tab2_Panel.BackgroundColor = [1 1 1];

            % Create Receiver_Panel
            app.Receiver_Panel = uipanel(app.Tab2_Panel);
            app.Receiver_Panel.AutoResizeChildren = 'off';
            app.Receiver_Panel.Layout.Row = 3;
            app.Receiver_Panel.Layout.Column = [1 3];

            % Create Receiver_Grid
            app.Receiver_Grid = uigridlayout(app.Receiver_Panel);
            app.Receiver_Grid.RowHeight = {17, 22};
            app.Receiver_Grid.RowSpacing = 5;
            app.Receiver_Grid.Padding = [10 10 10 2];
            app.Receiver_Grid.BackgroundColor = [1 1 1];

            % Create Receiver_RstCommandLabel
            app.Receiver_RstCommandLabel = uilabel(app.Receiver_Grid);
            app.Receiver_RstCommandLabel.VerticalAlignment = 'bottom';
            app.Receiver_RstCommandLabel.FontSize = 10;
            app.Receiver_RstCommandLabel.Layout.Row = 1;
            app.Receiver_RstCommandLabel.Layout.Column = 1;
            app.Receiver_RstCommandLabel.Text = 'Reset:';

            % Create Receiver_RstCommand
            app.Receiver_RstCommand = uidropdown(app.Receiver_Grid);
            app.Receiver_RstCommand.Items = {'On', 'Off'};
            app.Receiver_RstCommand.Tag = 'task_Editable';
            app.Receiver_RstCommand.FontSize = 11;
            app.Receiver_RstCommand.BackgroundColor = [1 1 1];
            app.Receiver_RstCommand.Layout.Row = 2;
            app.Receiver_RstCommand.Layout.Column = 1;
            app.Receiver_RstCommand.Value = 'On';

            % Create Receiver_SyncRefLabel
            app.Receiver_SyncRefLabel = uilabel(app.Receiver_Grid);
            app.Receiver_SyncRefLabel.VerticalAlignment = 'bottom';
            app.Receiver_SyncRefLabel.FontSize = 10;
            app.Receiver_SyncRefLabel.Layout.Row = 1;
            app.Receiver_SyncRefLabel.Layout.Column = 2;
            app.Receiver_SyncRefLabel.Text = 'Sincronismo:';

            % Create Receiver_SyncRef
            app.Receiver_SyncRef = uidropdown(app.Receiver_Grid);
            app.Receiver_SyncRef.Items = {'Single Sweep', 'Continuous Sweep', 'Streaming'};
            app.Receiver_SyncRef.Tag = 'task_Editable';
            app.Receiver_SyncRef.FontSize = 11;
            app.Receiver_SyncRef.BackgroundColor = [1 1 1];
            app.Receiver_SyncRef.Layout.Row = 2;
            app.Receiver_SyncRef.Layout.Column = 2;
            app.Receiver_SyncRef.Value = 'Single Sweep';

            % Create GPS_Panel
            app.GPS_Panel = uipanel(app.Tab2_Panel);
            app.GPS_Panel.AutoResizeChildren = 'off';
            app.GPS_Panel.Layout.Row = 6;
            app.GPS_Panel.Layout.Column = [1 3];

            % Create GPS_Grid
            app.GPS_Grid = uigridlayout(app.GPS_Panel);
            app.GPS_Grid.RowHeight = {25, 22, 25, 22};
            app.GPS_Grid.RowSpacing = 5;
            app.GPS_Grid.BackgroundColor = [1 1 1];

            % Create GPS_manualLatitude
            app.GPS_manualLatitude = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_manualLatitude.ValueDisplayFormat = '%.6f';
            app.GPS_manualLatitude.Tag = 'task_Editable';
            app.GPS_manualLatitude.FontSize = 11;
            app.GPS_manualLatitude.Layout.Row = 2;
            app.GPS_manualLatitude.Layout.Column = 1;
            app.GPS_manualLatitude.Value = -1;

            % Create GPS_manualLongitude
            app.GPS_manualLongitude = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_manualLongitude.ValueDisplayFormat = '%.6f';
            app.GPS_manualLongitude.Tag = 'task_Editable';
            app.GPS_manualLongitude.FontSize = 11;
            app.GPS_manualLongitude.Layout.Row = 2;
            app.GPS_manualLongitude.Layout.Column = 2;
            app.GPS_manualLongitude.Value = -1;

            % Create GPS_RevisitTime
            app.GPS_RevisitTime = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_RevisitTime.Limits = [1 Inf];
            app.GPS_RevisitTime.ValueDisplayFormat = '%.3f';
            app.GPS_RevisitTime.Tag = 'task_Editable';
            app.GPS_RevisitTime.FontSize = 11;
            app.GPS_RevisitTime.Layout.Row = 4;
            app.GPS_RevisitTime.Layout.Column = 1;
            app.GPS_RevisitTime.Value = 60;

            % Create GPS_RevisitTimeLabel
            app.GPS_RevisitTimeLabel = uilabel(app.GPS_Grid);
            app.GPS_RevisitTimeLabel.VerticalAlignment = 'bottom';
            app.GPS_RevisitTimeLabel.FontSize = 10;
            app.GPS_RevisitTimeLabel.Layout.Row = 3;
            app.GPS_RevisitTimeLabel.Layout.Column = 1;
            app.GPS_RevisitTimeLabel.Text = {'Tempo revisita:'; '(segundos)'};

            % Create GPS_manualLatitudeLabel
            app.GPS_manualLatitudeLabel = uilabel(app.GPS_Grid);
            app.GPS_manualLatitudeLabel.VerticalAlignment = 'bottom';
            app.GPS_manualLatitudeLabel.FontSize = 10;
            app.GPS_manualLatitudeLabel.Layout.Row = 1;
            app.GPS_manualLatitudeLabel.Layout.Column = 1;
            app.GPS_manualLatitudeLabel.Text = {'Latitude:'; '(graus decimais)'};

            % Create GPS_manualLongitudeLabel
            app.GPS_manualLongitudeLabel = uilabel(app.GPS_Grid);
            app.GPS_manualLongitudeLabel.VerticalAlignment = 'bottom';
            app.GPS_manualLongitudeLabel.FontSize = 10;
            app.GPS_manualLongitudeLabel.Layout.Row = 1;
            app.GPS_manualLongitudeLabel.Layout.Column = 2;
            app.GPS_manualLongitudeLabel.Text = {'Longitude:'; '(graus decimais)'};

            % Create GPS_Connectivity
            app.GPS_Connectivity = uibutton(app.Tab2_Panel, 'push');
            app.GPS_Connectivity.ButtonPushedFcn = createCallbackFcn(app, @GPS_ConnectivityTest, true);
            app.GPS_Connectivity.Tag = 'task_Editable';
            app.GPS_Connectivity.Icon = 'Connectivity_32.png';
            app.GPS_Connectivity.BackgroundColor = [0.9804 0.9804 0.9804];
            app.GPS_Connectivity.Tooltip = {'Teste de conectividade'};
            app.GPS_Connectivity.Layout.Row = 5;
            app.GPS_Connectivity.Layout.Column = 3;
            app.GPS_Connectivity.Text = '';

            % Create Receiver_Connectivity
            app.Receiver_Connectivity = uibutton(app.Tab2_Panel, 'push');
            app.Receiver_Connectivity.ButtonPushedFcn = createCallbackFcn(app, @Receiver_ConnectivityTest, true);
            app.Receiver_Connectivity.Tag = 'task_Editable';
            app.Receiver_Connectivity.Icon = 'Connectivity_32.png';
            app.Receiver_Connectivity.BackgroundColor = [0.9804 0.9804 0.9804];
            app.Receiver_Connectivity.Tooltip = {'Teste de conectividade'};
            app.Receiver_Connectivity.Layout.Row = 2;
            app.Receiver_Connectivity.Layout.Column = 3;
            app.Receiver_Connectivity.Text = '';

            % Create Receiver_List
            app.Receiver_List = uidropdown(app.Tab2_Panel);
            app.Receiver_List.Items = {};
            app.Receiver_List.ValueChangedFcn = createCallbackFcn(app, @Receiver_instrSelection, true);
            app.Receiver_List.Tag = 'task_Editable';
            app.Receiver_List.FontSize = 11;
            app.Receiver_List.BackgroundColor = [1 1 1];
            app.Receiver_List.Layout.Row = 2;
            app.Receiver_List.Layout.Column = [1 2];
            app.Receiver_List.Value = {};

            % Create Receiver_ListLabel
            app.Receiver_ListLabel = uilabel(app.Tab2_Panel);
            app.Receiver_ListLabel.VerticalAlignment = 'bottom';
            app.Receiver_ListLabel.FontSize = 10;
            app.Receiver_ListLabel.Layout.Row = 1;
            app.Receiver_ListLabel.Layout.Column = 1;
            app.Receiver_ListLabel.Text = 'RECEPTOR:';

            % Create GPS_FixedStation
            app.GPS_FixedStation = uibutton(app.Tab2_Panel, 'push');
            app.GPS_FixedStation.ButtonPushedFcn = createCallbackFcn(app, @GPS_FixedStationButtonPushed, true);
            app.GPS_FixedStation.Tag = 'task_Editable';
            app.GPS_FixedStation.Icon = 'Pin_18.png';
            app.GPS_FixedStation.BackgroundColor = [0.9804 0.9804 0.9804];
            app.GPS_FixedStation.Tooltip = {'Importa coordenadas geográficas da estação'};
            app.GPS_FixedStation.Layout.Row = 5;
            app.GPS_FixedStation.Layout.Column = 2;
            app.GPS_FixedStation.Text = '';

            % Create GPS_ListLabel
            app.GPS_ListLabel = uilabel(app.Tab2_Panel);
            app.GPS_ListLabel.VerticalAlignment = 'bottom';
            app.GPS_ListLabel.FontSize = 10;
            app.GPS_ListLabel.Layout.Row = 4;
            app.GPS_ListLabel.Layout.Column = 1;
            app.GPS_ListLabel.Text = 'GPS:';

            % Create GPS_List
            app.GPS_List = uidropdown(app.Tab2_Panel);
            app.GPS_List.Items = {'ID 0: Manual'};
            app.GPS_List.ValueChangedFcn = createCallbackFcn(app, @GPS_instrSelection, true);
            app.GPS_List.Tag = 'task_Editable';
            app.GPS_List.FontSize = 11;
            app.GPS_List.BackgroundColor = [1 1 1];
            app.GPS_List.Layout.Row = 5;
            app.GPS_List.Layout.Column = 1;
            app.GPS_List.Value = 'ID 0: Manual';

            % Create ANTENASTab
            app.ANTENASTab = uitab(app.TaskControl);
            app.ANTENASTab.AutoResizeChildren = 'off';
            app.ANTENASTab.Title = 'ANTENAS';

            % Create Tab3_Panel
            app.Tab3_Panel = uigridlayout(app.ANTENASTab);
            app.Tab3_Panel.ColumnWidth = {'1x', 12};
            app.Tab3_Panel.RowHeight = {17, 22, 22, 22, 172, 10, '1x'};
            app.Tab3_Panel.RowSpacing = 5;
            app.Tab3_Panel.BackgroundColor = [1 1 1];

            % Create AntennaNameLabel
            app.AntennaNameLabel = uilabel(app.Tab3_Panel);
            app.AntennaNameLabel.VerticalAlignment = 'bottom';
            app.AntennaNameLabel.FontSize = 10;
            app.AntennaNameLabel.Layout.Row = 3;
            app.AntennaNameLabel.Layout.Column = 1;
            app.AntennaNameLabel.Text = 'ANTENA';

            % Create AntennaName
            app.AntennaName = uidropdown(app.Tab3_Panel);
            app.AntennaName.Items = {'', 'CRFS Low Band (10 MHz - 1.2 GHz)', 'CRFS High Band (750 MHz - 6 GHz)', 'Rohde & Schwarz ADDx07 (EB500 GUI Auto)', 'Rohde & Schwarz ADD107 (20 MHz - 1.3 GHz)', 'Rohde & Schwarz ADD207 (600 MHz - 6 GHz)', 'Rohde & Schwarz ADD295 (20 MHz - 3 GHz)', 'Telescopic', 'Unlisted (Omni)', 'Unlisted (Directional)'};
            app.AntennaName.ValueChangedFcn = createCallbackFcn(app, @AntennaConfig_Selection, true);
            app.AntennaName.Tag = 'task_Editable';
            app.AntennaName.FontSize = 11;
            app.AntennaName.BackgroundColor = [1 1 1];
            app.AntennaName.Layout.Row = 4;
            app.AntennaName.Layout.Column = [1 2];
            app.AntennaName.Value = '';

            % Create Antenna_Panel
            app.Antenna_Panel = uipanel(app.Tab3_Panel);
            app.Antenna_Panel.AutoResizeChildren = 'off';
            app.Antenna_Panel.Layout.Row = 5;
            app.Antenna_Panel.Layout.Column = [1 2];

            % Create Antenna_Grid
            app.Antenna_Grid = uigridlayout(app.Antenna_Panel);
            app.Antenna_Grid.RowHeight = {17, 22, 25, 22, 25, 22};
            app.Antenna_Grid.RowSpacing = 5;
            app.Antenna_Grid.Padding = [10 10 10 2];
            app.Antenna_Grid.BackgroundColor = [1 1 1];

            % Create Antenna_TrackingModeLabel
            app.Antenna_TrackingModeLabel = uilabel(app.Antenna_Grid);
            app.Antenna_TrackingModeLabel.VerticalAlignment = 'bottom';
            app.Antenna_TrackingModeLabel.FontSize = 10;
            app.Antenna_TrackingModeLabel.Layout.Row = 1;
            app.Antenna_TrackingModeLabel.Layout.Column = [1 2];
            app.Antenna_TrackingModeLabel.Text = 'Apontamento:';

            % Create Antenna_TrackingMode
            app.Antenna_TrackingMode = uidropdown(app.Antenna_Grid);
            app.Antenna_TrackingMode.Items = {'Target', 'LookAngles', 'Manual'};
            app.Antenna_TrackingMode.ValueChangedFcn = createCallbackFcn(app, @AntennaConfig_TrackingMode, true);
            app.Antenna_TrackingMode.FontSize = 11;
            app.Antenna_TrackingMode.BackgroundColor = [1 1 1];
            app.Antenna_TrackingMode.Layout.Row = 2;
            app.Antenna_TrackingMode.Layout.Column = [1 2];
            app.Antenna_TrackingMode.Value = 'Manual';

            % Create AntennaHeightLabel
            app.AntennaHeightLabel = uilabel(app.Antenna_Grid);
            app.AntennaHeightLabel.VerticalAlignment = 'bottom';
            app.AntennaHeightLabel.FontSize = 10;
            app.AntennaHeightLabel.Layout.Row = 3;
            app.AntennaHeightLabel.Layout.Column = 1;
            app.AntennaHeightLabel.Text = {'Altura de instalação:'; '(metros)'};

            % Create AntennaHeight
            app.AntennaHeight = uieditfield(app.Antenna_Grid, 'numeric');
            app.AntennaHeight.Limits = [0 127];
            app.AntennaHeight.RoundFractionalValues = 'on';
            app.AntennaHeight.ValueDisplayFormat = '%.0f';
            app.AntennaHeight.Tag = 'task_Editable';
            app.AntennaHeight.FontSize = 11;
            app.AntennaHeight.Enable = 'off';
            app.AntennaHeight.Layout.Row = 4;
            app.AntennaHeight.Layout.Column = 1;
            app.AntennaHeight.Value = 2;

            % Create AntennaAzimuth_Grid
            app.AntennaAzimuth_Grid = uigridlayout(app.Antenna_Grid);
            app.AntennaAzimuth_Grid.ColumnWidth = {'1x', 50};
            app.AntennaAzimuth_Grid.RowHeight = {25, 22};
            app.AntennaAzimuth_Grid.ColumnSpacing = 5;
            app.AntennaAzimuth_Grid.RowSpacing = 5;
            app.AntennaAzimuth_Grid.Padding = [0 0 0 0];
            app.AntennaAzimuth_Grid.Layout.Row = [3 4];
            app.AntennaAzimuth_Grid.Layout.Column = 2;
            app.AntennaAzimuth_Grid.BackgroundColor = [1 1 1];

            % Create AntennaAzimuthLabel
            app.AntennaAzimuthLabel = uilabel(app.AntennaAzimuth_Grid);
            app.AntennaAzimuthLabel.VerticalAlignment = 'bottom';
            app.AntennaAzimuthLabel.FontSize = 10;
            app.AntennaAzimuthLabel.Layout.Row = 1;
            app.AntennaAzimuthLabel.Layout.Column = 1;
            app.AntennaAzimuthLabel.Text = {'Azimute:'; '(graus)'};

            % Create AntennaAzimuth
            app.AntennaAzimuth = uieditfield(app.AntennaAzimuth_Grid, 'numeric');
            app.AntennaAzimuth.Limits = [0 360];
            app.AntennaAzimuth.ValueDisplayFormat = '%.3f';
            app.AntennaAzimuth.Tag = 'task_Editable';
            app.AntennaAzimuth.FontSize = 11;
            app.AntennaAzimuth.Enable = 'off';
            app.AntennaAzimuth.Layout.Row = 2;
            app.AntennaAzimuth.Layout.Column = 1;

            % Create AntennaAzimuthRef
            app.AntennaAzimuthRef = uidropdown(app.AntennaAzimuth_Grid);
            app.AntennaAzimuthRef.Items = {'NV'};
            app.AntennaAzimuthRef.Enable = 'off';
            app.AntennaAzimuthRef.FontSize = 11;
            app.AntennaAzimuthRef.BackgroundColor = [1 1 1];
            app.AntennaAzimuthRef.Layout.Row = 2;
            app.AntennaAzimuthRef.Layout.Column = 2;
            app.AntennaAzimuthRef.Value = 'NV';

            % Create AntennaElevationLabel
            app.AntennaElevationLabel = uilabel(app.Antenna_Grid);
            app.AntennaElevationLabel.VerticalAlignment = 'bottom';
            app.AntennaElevationLabel.FontSize = 10;
            app.AntennaElevationLabel.Layout.Row = 5;
            app.AntennaElevationLabel.Layout.Column = 1;
            app.AntennaElevationLabel.Text = {'Elevação:'; '(graus)'};

            % Create AntennaElevation
            app.AntennaElevation = uieditfield(app.Antenna_Grid, 'numeric');
            app.AntennaElevation.Limits = [0 90];
            app.AntennaElevation.ValueDisplayFormat = '%.3f';
            app.AntennaElevation.Tag = 'task_Editable';
            app.AntennaElevation.FontSize = 11;
            app.AntennaElevation.Enable = 'off';
            app.AntennaElevation.Layout.Row = 6;
            app.AntennaElevation.Layout.Column = 1;

            % Create AntennaPolarizationLabel
            app.AntennaPolarizationLabel = uilabel(app.Antenna_Grid);
            app.AntennaPolarizationLabel.VerticalAlignment = 'bottom';
            app.AntennaPolarizationLabel.FontSize = 10;
            app.AntennaPolarizationLabel.Layout.Row = 5;
            app.AntennaPolarizationLabel.Layout.Column = 2;
            app.AntennaPolarizationLabel.Text = {'Polarização:'; '(graus)'};

            % Create AntennaPolarization
            app.AntennaPolarization = uieditfield(app.Antenna_Grid, 'numeric');
            app.AntennaPolarization.Limits = [0 360];
            app.AntennaPolarization.ValueDisplayFormat = '%.1f';
            app.AntennaPolarization.Tag = 'task_Editable';
            app.AntennaPolarization.FontSize = 11;
            app.AntennaPolarization.Enable = 'off';
            app.AntennaPolarization.Layout.Row = 6;
            app.AntennaPolarization.Layout.Column = 2;

            % Create AddAntenna_Image
            app.AddAntenna_Image = uiimage(app.Tab3_Panel);
            app.AddAntenna_Image.ImageClickedFcn = createCallbackFcn(app, @AntennaConfig_Add, true);
            app.AddAntenna_Image.Layout.Row = 6;
            app.AddAntenna_Image.Layout.Column = 2;
            app.AddAntenna_Image.HorizontalAlignment = 'right';
            app.AddAntenna_Image.VerticalAlignment = 'bottom';
            app.AddAntenna_Image.ImageSource = 'addSymbol_32.png';

            % Create AntennaList_Tree
            app.AntennaList_Tree = uitree(app.Tab3_Panel);
            app.AntennaList_Tree.FontSize = 10.5;
            app.AntennaList_Tree.Layout.Row = 7;
            app.AntennaList_Tree.Layout.Column = [1 2];

            % Create AntennaSwitch_Mode
            app.AntennaSwitch_Mode = uicheckbox(app.Tab3_Panel);
            app.AntennaSwitch_Mode.ValueChangedFcn = createCallbackFcn(app, @AntennaSwitch_ModeSelection, true);
            app.AntennaSwitch_Mode.Text = 'Comutador de antenas:';
            app.AntennaSwitch_Mode.FontSize = 11;
            app.AntennaSwitch_Mode.Layout.Row = 1;
            app.AntennaSwitch_Mode.Layout.Column = 1;

            % Create AntennaSwitch_Name
            app.AntennaSwitch_Name = uieditfield(app.Tab3_Panel, 'text');
            app.AntennaSwitch_Name.Editable = 'off';
            app.AntennaSwitch_Name.FontSize = 11;
            app.AntennaSwitch_Name.Enable = 'off';
            app.AntennaSwitch_Name.Layout.Row = 2;
            app.AntennaSwitch_Name.Layout.Column = [1 2];

            % Create BandsInfo
            app.BandsInfo = uigridlayout(app.GridLayout);
            app.BandsInfo.ColumnWidth = {'1x'};
            app.BandsInfo.RowHeight = {17, 272, 22, '1x'};
            app.BandsInfo.RowSpacing = 5;
            app.BandsInfo.Padding = [0 0 0 0];
            app.BandsInfo.Layout.Row = [3 4];
            app.BandsInfo.Layout.Column = 4;
            app.BandsInfo.BackgroundColor = [1 1 1];

            % Create Band_TreeLabel
            app.Band_TreeLabel = uilabel(app.BandsInfo);
            app.Band_TreeLabel.VerticalAlignment = 'bottom';
            app.Band_TreeLabel.WordWrap = 'on';
            app.Band_TreeLabel.FontSize = 10;
            app.Band_TreeLabel.Layout.Row = 1;
            app.Band_TreeLabel.Layout.Column = 1;
            app.Band_TreeLabel.Text = 'FAIXA(S) DE FREQUÊNCIA RELACIONADA(S) À TAREFA:';

            % Create Band_Tree
            app.Band_Tree = uitree(app.BandsInfo);
            app.Band_Tree.SelectionChangedFcn = createCallbackFcn(app, @BandView_TreeSelectionChanged, true);
            app.Band_Tree.FontSize = 10;
            app.Band_Tree.Layout.Row = 2;
            app.Band_Tree.Layout.Column = 1;

            % Create MetaDataLabel
            app.MetaDataLabel = uilabel(app.BandsInfo);
            app.MetaDataLabel.VerticalAlignment = 'bottom';
            app.MetaDataLabel.WordWrap = 'on';
            app.MetaDataLabel.FontSize = 10;
            app.MetaDataLabel.FontColor = [0.149 0.149 0.149];
            app.MetaDataLabel.Layout.Row = 3;
            app.MetaDataLabel.Layout.Column = 1;
            app.MetaDataLabel.Text = 'PARÂMETROS DE CONFIGURAÇÃO:';

            % Create MetaData
            app.MetaData = uilabel(app.BandsInfo);
            app.MetaData.VerticalAlignment = 'top';
            app.MetaData.WordWrap = 'on';
            app.MetaData.FontSize = 11;
            app.MetaData.Layout.Row = 4;
            app.MetaData.Layout.Column = 1;
            app.MetaData.Interpreter = 'html';
            app.MetaData.Text = '';

            % Create BandCustomizable
            app.BandCustomizable = uigridlayout(app.GridLayout);
            app.BandCustomizable.ColumnWidth = {120, '1x', 16};
            app.BandCustomizable.RowHeight = {17, 22, 22, 218, 22, 68, 22, '1x'};
            app.BandCustomizable.RowSpacing = 5;
            app.BandCustomizable.Padding = [0 0 0 0];
            app.BandCustomizable.Layout.Row = [3 4];
            app.BandCustomizable.Layout.Column = [6 7];
            app.BandCustomizable.BackgroundColor = [1 1 1];

            % Create Band_SamplesLabel
            app.Band_SamplesLabel = uilabel(app.BandCustomizable);
            app.Band_SamplesLabel.VerticalAlignment = 'bottom';
            app.Band_SamplesLabel.FontSize = 10;
            app.Band_SamplesLabel.Layout.Row = 1;
            app.Band_SamplesLabel.Layout.Column = [1 2];
            app.Band_SamplesLabel.Text = 'AMOSTRAS A COLETAR:';

            % Create Band_Samples
            app.Band_Samples = uieditfield(app.BandCustomizable, 'numeric');
            app.Band_Samples.Limits = [-1 Inf];
            app.Band_Samples.RoundFractionalValues = 'on';
            app.Band_Samples.ValueDisplayFormat = '%.0f';
            app.Band_Samples.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_Samples.FontSize = 11;
            app.Band_Samples.Layout.Row = 2;
            app.Band_Samples.Layout.Column = 1;
            app.Band_Samples.Value = -1;

            % Create Band_ReceiverLabel
            app.Band_ReceiverLabel = uilabel(app.BandCustomizable);
            app.Band_ReceiverLabel.VerticalAlignment = 'bottom';
            app.Band_ReceiverLabel.FontSize = 10;
            app.Band_ReceiverLabel.Layout.Row = 3;
            app.Band_ReceiverLabel.Layout.Column = [1 2];
            app.Band_ReceiverLabel.Text = 'RECEPTOR';

            % Create Band_ReceiverPanel
            app.Band_ReceiverPanel = uipanel(app.BandCustomizable);
            app.Band_ReceiverPanel.AutoResizeChildren = 'off';
            app.Band_ReceiverPanel.Layout.Row = 4;
            app.Band_ReceiverPanel.Layout.Column = [1 3];

            % Create Band_ReceiverGrid
            app.Band_ReceiverGrid = uigridlayout(app.Band_ReceiverPanel);
            app.Band_ReceiverGrid.ColumnWidth = {110, 110, 110};
            app.Band_ReceiverGrid.RowHeight = {17, 22, 0, 22, 22, 17, 22, 22, 22};
            app.Band_ReceiverGrid.RowSpacing = 5;
            app.Band_ReceiverGrid.Padding = [10 10 10 5];
            app.Band_ReceiverGrid.BackgroundColor = [1 1 1];

            % Create Band_StepWidthLabel
            app.Band_StepWidthLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_StepWidthLabel.VerticalAlignment = 'bottom';
            app.Band_StepWidthLabel.FontSize = 10;
            app.Band_StepWidthLabel.Layout.Row = 1;
            app.Band_StepWidthLabel.Layout.Column = [1 2];
            app.Band_StepWidthLabel.Text = 'Passo varredura (kHz):';

            % Create Band_StepWidth1
            app.Band_StepWidth1 = uieditfield(app.Band_ReceiverGrid, 'numeric');
            app.Band_StepWidth1.Limits = [0 Inf];
            app.Band_StepWidth1.ValueDisplayFormat = '%.3f';
            app.Band_StepWidth1.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_StepWidth1.Tag = 'task_Set1';
            app.Band_StepWidth1.Editable = 'off';
            app.Band_StepWidth1.FontSize = 11;
            app.Band_StepWidth1.Layout.Row = 2;
            app.Band_StepWidth1.Layout.Column = 1;

            % Create Band_StepWidth2
            app.Band_StepWidth2 = uidropdown(app.Band_ReceiverGrid);
            app.Band_StepWidth2.Items = {};
            app.Band_StepWidth2.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_StepWidth2.Tag = 'task_Set2';
            app.Band_StepWidth2.Enable = 'off';
            app.Band_StepWidth2.FontSize = 11;
            app.Band_StepWidth2.BackgroundColor = [1 1 1];
            app.Band_StepWidth2.Layout.Row = 3;
            app.Band_StepWidth2.Layout.Column = 1;
            app.Band_StepWidth2.Value = {};

            % Create Band_DataPointsLabel
            app.Band_DataPointsLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_DataPointsLabel.VerticalAlignment = 'bottom';
            app.Band_DataPointsLabel.FontSize = 10;
            app.Band_DataPointsLabel.Layout.Row = 1;
            app.Band_DataPointsLabel.Layout.Column = 2;
            app.Band_DataPointsLabel.Text = 'Pontos por traço:';

            % Create Band_DataPoints1
            app.Band_DataPoints1 = uispinner(app.Band_ReceiverGrid);
            app.Band_DataPoints1.Step = 100;
            app.Band_DataPoints1.Limits = [101 32001];
            app.Band_DataPoints1.RoundFractionalValues = 'on';
            app.Band_DataPoints1.ValueDisplayFormat = '%.0f';
            app.Band_DataPoints1.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_DataPoints1.Tag = 'task_Set1';
            app.Band_DataPoints1.HorizontalAlignment = 'left';
            app.Band_DataPoints1.FontSize = 11;
            app.Band_DataPoints1.Layout.Row = 2;
            app.Band_DataPoints1.Layout.Column = 2;
            app.Band_DataPoints1.Value = 101;

            % Create Band_DataPoints2
            app.Band_DataPoints2 = uieditfield(app.Band_ReceiverGrid, 'numeric');
            app.Band_DataPoints2.ValueDisplayFormat = '%.0f';
            app.Band_DataPoints2.Tag = 'task_Set2';
            app.Band_DataPoints2.Editable = 'off';
            app.Band_DataPoints2.FontSize = 11;
            app.Band_DataPoints2.Enable = 'off';
            app.Band_DataPoints2.Layout.Row = 3;
            app.Band_DataPoints2.Layout.Column = 2;

            % Create Band_SelectivityLabel
            app.Band_SelectivityLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_SelectivityLabel.Tag = 'task_Set2';
            app.Band_SelectivityLabel.VerticalAlignment = 'bottom';
            app.Band_SelectivityLabel.FontSize = 10;
            app.Band_SelectivityLabel.Visible = 'off';
            app.Band_SelectivityLabel.Layout.Row = 4;
            app.Band_SelectivityLabel.Layout.Column = 1;
            app.Band_SelectivityLabel.Text = 'Seletividade FFT:';

            % Create Band_Selectivity
            app.Band_Selectivity = uidropdown(app.Band_ReceiverGrid);
            app.Band_Selectivity.Items = {'Normal', 'Narrow', 'Sharp'};
            app.Band_Selectivity.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_Selectivity.Tag = 'task_Set2';
            app.Band_Selectivity.Visible = 'off';
            app.Band_Selectivity.FontSize = 11;
            app.Band_Selectivity.BackgroundColor = [1 1 1];
            app.Band_Selectivity.Layout.Row = 5;
            app.Band_Selectivity.Layout.Column = 1;
            app.Band_Selectivity.Value = 'Normal';

            % Create Band_ResolutionLabel
            app.Band_ResolutionLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_ResolutionLabel.VerticalAlignment = 'bottom';
            app.Band_ResolutionLabel.FontSize = 10;
            app.Band_ResolutionLabel.Layout.Row = 4;
            app.Band_ResolutionLabel.Layout.Column = 1;
            app.Band_ResolutionLabel.Text = 'Resolução:';

            % Create Band_Resolution
            app.Band_Resolution = uidropdown(app.Band_ReceiverGrid);
            app.Band_Resolution.Items = {};
            app.Band_Resolution.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_Resolution.FontSize = 11;
            app.Band_Resolution.BackgroundColor = [1 1 1];
            app.Band_Resolution.Layout.Row = 5;
            app.Band_Resolution.Layout.Column = 1;
            app.Band_Resolution.Value = {};

            % Create Band_VBWLabel
            app.Band_VBWLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_VBWLabel.Tag = 'task_Set1';
            app.Band_VBWLabel.VerticalAlignment = 'bottom';
            app.Band_VBWLabel.FontSize = 10;
            app.Band_VBWLabel.Layout.Row = 4;
            app.Band_VBWLabel.Layout.Column = 2;
            app.Band_VBWLabel.Text = 'VBW:';

            % Create Band_VBW
            app.Band_VBW = uidropdown(app.Band_ReceiverGrid);
            app.Band_VBW.Items = {};
            app.Band_VBW.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_VBW.Tag = 'task_Set1';
            app.Band_VBW.FontSize = 11;
            app.Band_VBW.BackgroundColor = [1 1 1];
            app.Band_VBW.Layout.Row = 5;
            app.Band_VBW.Layout.Column = 2;
            app.Band_VBW.Value = {};

            % Create Band_PreampLabel
            app.Band_PreampLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_PreampLabel.VerticalAlignment = 'bottom';
            app.Band_PreampLabel.FontSize = 10;
            app.Band_PreampLabel.Layout.Row = 6;
            app.Band_PreampLabel.Layout.Column = 1;
            app.Band_PreampLabel.Text = 'Pré-amplificador:';

            % Create Band_Preamp
            app.Band_Preamp = uidropdown(app.Band_ReceiverGrid);
            app.Band_Preamp.Items = {'On', 'Off'};
            app.Band_Preamp.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_Preamp.FontSize = 11;
            app.Band_Preamp.BackgroundColor = [1 1 1];
            app.Band_Preamp.Layout.Row = 7;
            app.Band_Preamp.Layout.Column = 1;
            app.Band_Preamp.Value = 'Off';

            % Create Band_attModeLabel
            app.Band_attModeLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_attModeLabel.VerticalAlignment = 'bottom';
            app.Band_attModeLabel.FontSize = 10;
            app.Band_attModeLabel.Layout.Row = 6;
            app.Band_attModeLabel.Layout.Column = 2;
            app.Band_attModeLabel.Text = 'Modo do atenuador:';

            % Create Band_attMode
            app.Band_attMode = uidropdown(app.Band_ReceiverGrid);
            app.Band_attMode.Items = {'Manual', 'Auto'};
            app.Band_attMode.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_attMode.FontSize = 11;
            app.Band_attMode.BackgroundColor = [1 1 1];
            app.Band_attMode.Layout.Row = 7;
            app.Band_attMode.Layout.Column = 2;
            app.Band_attMode.Value = 'Manual';

            % Create Band_attValueLabel
            app.Band_attValueLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_attValueLabel.VerticalAlignment = 'bottom';
            app.Band_attValueLabel.FontSize = 10;
            app.Band_attValueLabel.Layout.Row = 6;
            app.Band_attValueLabel.Layout.Column = 3;
            app.Band_attValueLabel.Text = 'Atenuador:';

            % Create Band_attValue
            app.Band_attValue = uidropdown(app.Band_ReceiverGrid);
            app.Band_attValue.Items = {};
            app.Band_attValue.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_attValue.FontSize = 11;
            app.Band_attValue.BackgroundColor = [1 1 1];
            app.Band_attValue.Layout.Row = 7;
            app.Band_attValue.Layout.Column = 3;
            app.Band_attValue.Value = {};

            % Create Band_DetectorLabel
            app.Band_DetectorLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_DetectorLabel.VerticalAlignment = 'bottom';
            app.Band_DetectorLabel.FontSize = 10;
            app.Band_DetectorLabel.Layout.Row = 8;
            app.Band_DetectorLabel.Layout.Column = 1;
            app.Band_DetectorLabel.Text = 'Detector:';

            % Create Band_Detector
            app.Band_Detector = uidropdown(app.Band_ReceiverGrid);
            app.Band_Detector.Items = {'Auto Peak', 'Average', 'Negative Peak', 'Positive Peak', 'Quasi Peak', 'RMS', 'Sample'};
            app.Band_Detector.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_Detector.FontSize = 11;
            app.Band_Detector.BackgroundColor = [1 1 1];
            app.Band_Detector.Layout.Row = 9;
            app.Band_Detector.Layout.Column = [1 2];
            app.Band_Detector.Value = 'Positive Peak';

            % Create Band_IntegrationTimeLabel
            app.Band_IntegrationTimeLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_IntegrationTimeLabel.VerticalAlignment = 'bottom';
            app.Band_IntegrationTimeLabel.FontSize = 10;
            app.Band_IntegrationTimeLabel.Layout.Row = 8;
            app.Band_IntegrationTimeLabel.Layout.Column = 3;
            app.Band_IntegrationTimeLabel.Text = 'Integração (ms):';

            % Create Band_IntegrationTime
            app.Band_IntegrationTime = uieditfield(app.Band_ReceiverGrid, 'numeric');
            app.Band_IntegrationTime.Limits = [-1 10000];
            app.Band_IntegrationTime.RoundFractionalValues = 'on';
            app.Band_IntegrationTime.ValueDisplayFormat = '%.0f';
            app.Band_IntegrationTime.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_IntegrationTime.FontSize = 11;
            app.Band_IntegrationTime.Layout.Row = 9;
            app.Band_IntegrationTime.Layout.Column = 3;
            app.Band_IntegrationTime.Value = -1;

            % Create Band_DFLabel
            app.Band_DFLabel = uilabel(app.BandCustomizable);
            app.Band_DFLabel.VerticalAlignment = 'bottom';
            app.Band_DFLabel.FontSize = 10;
            app.Band_DFLabel.Layout.Row = 5;
            app.Band_DFLabel.Layout.Column = [1 2];
            app.Band_DFLabel.Text = 'DIRECTION FINDER (DF):';

            % Create Band_DFPanel
            app.Band_DFPanel = uipanel(app.BandCustomizable);
            app.Band_DFPanel.AutoResizeChildren = 'off';
            app.Band_DFPanel.Layout.Row = 6;
            app.Band_DFPanel.Layout.Column = [1 3];

            % Create Band_DFGrid
            app.Band_DFGrid = uigridlayout(app.Band_DFPanel);
            app.Band_DFGrid.ColumnWidth = {110, 110, 110};
            app.Band_DFGrid.RowHeight = {17, 22};
            app.Band_DFGrid.RowSpacing = 5;
            app.Band_DFGrid.Padding = [10 10 10 5];
            app.Band_DFGrid.BackgroundColor = [1 1 1];

            % Create Band_DFSquelchModeLabel
            app.Band_DFSquelchModeLabel = uilabel(app.Band_DFGrid);
            app.Band_DFSquelchModeLabel.VerticalAlignment = 'bottom';
            app.Band_DFSquelchModeLabel.FontSize = 10;
            app.Band_DFSquelchModeLabel.Layout.Row = 1;
            app.Band_DFSquelchModeLabel.Layout.Column = 1;
            app.Band_DFSquelchModeLabel.Text = 'SquelchMode:';

            % Create Band_DFSquelchMode
            app.Band_DFSquelchMode = uidropdown(app.Band_DFGrid);
            app.Band_DFSquelchMode.Items = {'OFF', 'NORM', 'GATE'};
            app.Band_DFSquelchMode.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_DFSquelchMode.Enable = 'off';
            app.Band_DFSquelchMode.FontSize = 10;
            app.Band_DFSquelchMode.BackgroundColor = [1 1 1];
            app.Band_DFSquelchMode.Layout.Row = 2;
            app.Band_DFSquelchMode.Layout.Column = 1;
            app.Band_DFSquelchMode.Value = 'OFF';

            % Create Band_DFSquelchValueLabel
            app.Band_DFSquelchValueLabel = uilabel(app.Band_DFGrid);
            app.Band_DFSquelchValueLabel.VerticalAlignment = 'bottom';
            app.Band_DFSquelchValueLabel.FontSize = 10;
            app.Band_DFSquelchValueLabel.Layout.Row = 1;
            app.Band_DFSquelchValueLabel.Layout.Column = 2;
            app.Band_DFSquelchValueLabel.Text = 'Squelch (dBµV):';

            % Create Band_DFSquelchValue
            app.Band_DFSquelchValue = uispinner(app.Band_DFGrid);
            app.Band_DFSquelchValue.Step = 10;
            app.Band_DFSquelchValue.Limits = [-50 130];
            app.Band_DFSquelchValue.RoundFractionalValues = 'on';
            app.Band_DFSquelchValue.ValueDisplayFormat = '%.0f';
            app.Band_DFSquelchValue.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_DFSquelchValue.Tag = 'task_Set1';
            app.Band_DFSquelchValue.HorizontalAlignment = 'left';
            app.Band_DFSquelchValue.FontSize = 10;
            app.Band_DFSquelchValue.Enable = 'off';
            app.Band_DFSquelchValue.Layout.Row = 2;
            app.Band_DFSquelchValue.Layout.Column = 2;
            app.Band_DFSquelchValue.Value = 10;

            % Create Band_DFMeasTimeLabel
            app.Band_DFMeasTimeLabel = uilabel(app.Band_DFGrid);
            app.Band_DFMeasTimeLabel.VerticalAlignment = 'bottom';
            app.Band_DFMeasTimeLabel.FontSize = 10;
            app.Band_DFMeasTimeLabel.Layout.Row = 1;
            app.Band_DFMeasTimeLabel.Layout.Column = 3;
            app.Band_DFMeasTimeLabel.Text = 'Integração (ms):';

            % Create Band_DFMeasTime
            app.Band_DFMeasTime = uispinner(app.Band_DFGrid);
            app.Band_DFMeasTime.Step = 100;
            app.Band_DFMeasTime.Limits = [100 10000];
            app.Band_DFMeasTime.RoundFractionalValues = 'on';
            app.Band_DFMeasTime.ValueDisplayFormat = '%.0f';
            app.Band_DFMeasTime.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_DFMeasTime.Tag = 'task_Set1';
            app.Band_DFMeasTime.HorizontalAlignment = 'left';
            app.Band_DFMeasTime.FontSize = 10;
            app.Band_DFMeasTime.Enable = 'off';
            app.Band_DFMeasTime.Layout.Row = 2;
            app.Band_DFMeasTime.Layout.Column = 3;
            app.Band_DFMeasTime.Value = 1000;

            % Create Band_AntenaLabel
            app.Band_AntenaLabel = uilabel(app.BandCustomizable);
            app.Band_AntenaLabel.VerticalAlignment = 'bottom';
            app.Band_AntenaLabel.FontSize = 10;
            app.Band_AntenaLabel.Layout.Row = 7;
            app.Band_AntenaLabel.Layout.Column = 1;
            app.Band_AntenaLabel.Text = 'ANTENA';

            % Create Band_AntennaPanel
            app.Band_AntennaPanel = uipanel(app.BandCustomizable);
            app.Band_AntennaPanel.AutoResizeChildren = 'off';
            app.Band_AntennaPanel.Layout.Row = 8;
            app.Band_AntennaPanel.Layout.Column = [1 3];

            % Create Band_AntennaGrid
            app.Band_AntennaGrid = uigridlayout(app.Band_AntennaPanel);
            app.Band_AntennaGrid.ColumnWidth = {200, 20, 230};
            app.Band_AntennaGrid.RowHeight = {17, 22};
            app.Band_AntennaGrid.RowSpacing = 5;
            app.Band_AntennaGrid.Padding = [10 10 10 5];
            app.Band_AntennaGrid.BackgroundColor = [1 1 1];

            % Create Band_TargetListLabel
            app.Band_TargetListLabel = uilabel(app.Band_AntennaGrid);
            app.Band_TargetListLabel.VerticalAlignment = 'bottom';
            app.Band_TargetListLabel.FontSize = 10;
            app.Band_TargetListLabel.Layout.Row = 1;
            app.Band_TargetListLabel.Layout.Column = 1;
            app.Band_TargetListLabel.Text = 'Estação alvo:';

            % Create Band_TargetList
            app.Band_TargetList = uidropdown(app.Band_AntennaGrid);
            app.Band_TargetList.Items = {};
            app.Band_TargetList.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_TargetList.Enable = 'off';
            app.Band_TargetList.FontSize = 11;
            app.Band_TargetList.BackgroundColor = [1 1 1];
            app.Band_TargetList.Layout.Row = 2;
            app.Band_TargetList.Layout.Column = [1 2];
            app.Band_TargetList.Value = {};

            % Create Band_AntennaLabel
            app.Band_AntennaLabel = uilabel(app.Band_AntennaGrid);
            app.Band_AntennaLabel.VerticalAlignment = 'bottom';
            app.Band_AntennaLabel.FontSize = 10;
            app.Band_AntennaLabel.Layout.Row = 1;
            app.Band_AntennaLabel.Layout.Column = 3;
            app.Band_AntennaLabel.Text = 'Antena/LNB:';

            % Create Band_Antenna
            app.Band_Antenna = uidropdown(app.Band_AntennaGrid);
            app.Band_Antenna.Items = {};
            app.Band_Antenna.ValueChangedFcn = createCallbackFcn(app, @BandView_EditedParameters, true);
            app.Band_Antenna.Enable = 'off';
            app.Band_Antenna.FontSize = 11;
            app.Band_Antenna.BackgroundColor = [1 1 1];
            app.Band_Antenna.Layout.Row = 2;
            app.Band_Antenna.Layout.Column = 3;
            app.Band_Antenna.Value = {};

            % Create Band_TargetListRefresh
            app.Band_TargetListRefresh = uiimage(app.Band_AntennaGrid);
            app.Band_TargetListRefresh.ScaleMethod = 'none';
            app.Band_TargetListRefresh.ImageClickedFcn = createCallbackFcn(app, @Band_TargetListRefreshImageClicked, true);
            app.Band_TargetListRefresh.Enable = 'off';
            app.Band_TargetListRefresh.Layout.Row = 1;
            app.Band_TargetListRefresh.Layout.Column = 2;
            app.Band_TargetListRefresh.HorizontalAlignment = 'right';
            app.Band_TargetListRefresh.VerticalAlignment = 'bottom';
            app.Band_TargetListRefresh.ImageSource = 'Refresh_18.png';

            % Create Band_Refresh
            app.Band_Refresh = uiimage(app.BandCustomizable);
            app.Band_Refresh.ScaleMethod = 'none';
            app.Band_Refresh.ImageClickedFcn = createCallbackFcn(app, @BandView_Refresh, true);
            app.Band_Refresh.Tooltip = {'Retorna às configurações iniciais'};
            app.Band_Refresh.Layout.Row = 3;
            app.Band_Refresh.Layout.Column = 3;
            app.Band_Refresh.HorizontalAlignment = 'right';
            app.Band_Refresh.VerticalAlignment = 'bottom';
            app.Band_Refresh.ImageSource = 'Refresh_18.png';

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {'1x', 110};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 9];

            % Create okBtn
            app.okBtn = uibutton(app.Toolbar, 'push');
            app.okBtn.ButtonPushedFcn = createCallbackFcn(app, @okBtnPushed, true);
            app.okBtn.Icon = 'Add_24.png';
            app.okBtn.IconAlignment = 'rightmargin';
            app.okBtn.BackgroundColor = [0.9412 0.9412 0.9412];
            app.okBtn.FontSize = 11;
            app.okBtn.Tooltip = {''};
            app.okBtn.Layout.Row = 1;
            app.okBtn.Layout.Column = 2;
            app.okBtn.Text = 'Inclui tarefa';

            % Create dockModuleGrid
            app.dockModuleGrid = uigridlayout(app.GridLayout);
            app.dockModuleGrid.RowHeight = {'1x'};
            app.dockModuleGrid.ColumnSpacing = 2;
            app.dockModuleGrid.Padding = [5 2 5 2];
            app.dockModuleGrid.Visible = 'off';
            app.dockModuleGrid.Layout.Row = [2 3];
            app.dockModuleGrid.Layout.Column = [7 8];
            app.dockModuleGrid.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.dockModuleGrid);
            app.dockModule_Close.ScaleMethod = 'none';
            app.dockModule_Close.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Close.Tag = 'DRIVETEST';
            app.dockModule_Close.Tooltip = {'Fecha módulo'};
            app.dockModule_Close.Layout.Row = 1;
            app.dockModule_Close.Layout.Column = 2;
            app.dockModule_Close.ImageSource = 'Delete_12SVG_white.svg';

            % Create dockModule_Undock
            app.dockModule_Undock = uiimage(app.dockModuleGrid);
            app.dockModule_Undock.ScaleMethod = 'none';
            app.dockModule_Undock.ImageClickedFcn = createCallbackFcn(app, @DockModuleGroup_ButtonPushed, true);
            app.dockModule_Undock.Tag = 'DRIVETEST';
            app.dockModule_Undock.Enable = 'off';
            app.dockModule_Undock.Tooltip = {'Reabre módulo em outra janela'};
            app.dockModule_Undock.Layout.Row = 1;
            app.dockModule_Undock.Layout.Column = 1;
            app.dockModule_Undock.ImageSource = 'Undock_18White.png';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winAddTask';

            % Create delAntennaEntry
            app.delAntennaEntry = uimenu(app.ContextMenu);
            app.delAntennaEntry.MenuSelectedFcn = createCallbackFcn(app, @AntennaConfig_Delete, true);
            app.delAntennaEntry.Text = '❌ Excluir';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = winAddTask_exported(Container, varargin)

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
