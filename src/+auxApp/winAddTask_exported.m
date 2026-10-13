classdef winAddTask_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        Panel_2                      matlab.ui.container.Panel
        GridLayout2                  matlab.ui.container.GridLayout
        MetaData                     matlab.ui.control.Label
        MetaDataLabel                matlab.ui.control.Label
        Band_TreeLabel               matlab.ui.control.Label
        Band_Tree                    matlab.ui.container.Tree
        TaskTitle                    matlab.ui.control.Label
        DockModule                   matlab.ui.container.GridLayout
        DockCloseButton              matlab.ui.control.Image
        DockUndockButton             matlab.ui.control.Image
        SubTabGroup                  matlab.ui.container.TabGroup
        SubTab3                      matlab.ui.container.Tab
        SubGrid3                     matlab.ui.container.GridLayout
        AntennaList_Tree             matlab.ui.container.Tree
        AddAntenna_Image             matlab.ui.control.Image
        Antenna_Panel                matlab.ui.container.Panel
        Antenna_Grid                 matlab.ui.container.GridLayout
        AntennaPolarization          matlab.ui.control.NumericEditField
        AntennaPolarizationLabel     matlab.ui.control.Label
        AntennaElevation             matlab.ui.control.NumericEditField
        AntennaElevationLabel        matlab.ui.control.Label
        AntennaAzimuth_Grid          matlab.ui.container.GridLayout
        AntennaAzimuthRef            matlab.ui.control.DropDown
        AntennaAzimuth               matlab.ui.control.NumericEditField
        AntennaAzimuthLabel          matlab.ui.control.Label
        AntennaHeight                matlab.ui.control.NumericEditField
        AntennaHeightLabel           matlab.ui.control.Label
        Antenna_TrackingMode         matlab.ui.control.DropDown
        Antenna_TrackingModeLabel    matlab.ui.control.Label
        AntennaName                  matlab.ui.control.DropDown
        AntennaNameLabel             matlab.ui.control.Label
        AntennaSwitch_Name           matlab.ui.control.EditField
        AntennaSwitch_Mode           matlab.ui.control.CheckBox
        SubTab2                      matlab.ui.container.Tab
        SubGrid2                     matlab.ui.container.GridLayout
        GPS_Panel                    matlab.ui.container.Panel
        GPS_Grid                     matlab.ui.container.GridLayout
        GPS_RevisitTime              matlab.ui.control.NumericEditField
        GPS_RevisitTimeLabel         matlab.ui.control.Label
        GPS_manualLongitude          matlab.ui.control.NumericEditField
        GPS_manualLongitudeLabel     matlab.ui.control.Label
        GPS_manualLatitude           matlab.ui.control.NumericEditField
        GPS_manualLatitudeLabel      matlab.ui.control.Label
        GPS_Connectivity             matlab.ui.control.Button
        GPS_FixedStation             matlab.ui.control.Button
        GPS_List                     matlab.ui.control.DropDown
        GPS_ListLabel                matlab.ui.control.Label
        Receiver_Panel               matlab.ui.container.Panel
        Receiver_Grid                matlab.ui.container.GridLayout
        Receiver_SyncRef             matlab.ui.control.DropDown
        Receiver_SyncRefLabel        matlab.ui.control.Label
        Receiver_RstCommand          matlab.ui.control.DropDown
        Receiver_RstCommandLabel     matlab.ui.control.Label
        Receiver_Connectivity        matlab.ui.control.Button
        Receiver_List                matlab.ui.control.DropDown
        Receiver_ListLabel           matlab.ui.control.Label
        SubTab1                      matlab.ui.container.Tab
        SubGrid1                     matlab.ui.container.GridLayout
        ObservationPanel             matlab.ui.container.Panel
        ObservationPanel_Grid        matlab.ui.container.GridLayout
        SpecificTime_Grid            matlab.ui.container.GridLayout
        SpecificTime_Mark2           matlab.ui.control.Label
        SpecificTime_Mark1           matlab.ui.control.Label
        SpecificTime_Spinner4        matlab.ui.control.Spinner
        SpecificTime_Spinner3        matlab.ui.control.Spinner
        SpecificTime_DatePicker2     matlab.ui.control.DatePicker
        SpecificTime_Spinner2        matlab.ui.control.Spinner
        SpecificTime_Spinner1        matlab.ui.control.Spinner
        SpecificTime_DatePicker1     matlab.ui.control.DatePicker
        Duration_Grid                matlab.ui.container.GridLayout
        DurationUnit                 matlab.ui.control.DropDown
        Duration                     matlab.ui.control.NumericEditField
        ObservationType              matlab.ui.control.DropDown
        ObservationTypeLabel         matlab.ui.control.Label
        ObservationLabel             matlab.ui.control.Label
        BitsPerPoint                 matlab.ui.control.DropDown
        BitsPerPointLabel            matlab.ui.control.Label
        PreviewTaskCheckbox          matlab.ui.control.CheckBox
        MaskFile_Button              matlab.ui.control.Button
        AddMaskFile_Button           matlab.ui.control.Button
        TaskType                     matlab.ui.control.DropDown
        TaskTypeLabel                matlab.ui.control.Label
        TaskName                     matlab.ui.control.DropDown
        TaskNameLabel                matlab.ui.control.Label
        TreeTitle                    matlab.ui.control.Label
        TreeIcon                     matlab.ui.control.Image
        Panel                        matlab.ui.container.Panel
        Document                     matlab.ui.container.GridLayout
        TaskTitle_2                  matlab.ui.control.Label
        Band_AntennaPanel            matlab.ui.container.Panel
        Band_AntennaGrid             matlab.ui.container.GridLayout
        Band_TargetListRefresh       matlab.ui.control.Image
        Band_Antenna                 matlab.ui.control.DropDown
        Band_AntennaLabel            matlab.ui.control.Label
        Band_TargetList              matlab.ui.control.DropDown
        Band_TargetListLabel         matlab.ui.control.Label
        Band_AntenaLabel             matlab.ui.control.Label
        Band_DFPanel                 matlab.ui.container.Panel
        Band_DFGrid                  matlab.ui.container.GridLayout
        Band_DFMeasTime              matlab.ui.control.Spinner
        Band_DFMeasTimeLabel         matlab.ui.control.Label
        Band_DFSquelchValue          matlab.ui.control.Spinner
        Band_DFSquelchValueLabel     matlab.ui.control.Label
        Band_DFSquelchMode           matlab.ui.control.DropDown
        Band_DFSquelchModeLabel      matlab.ui.control.Label
        Band_DFLabel                 matlab.ui.control.Label
        Band_ReceiverPanel           matlab.ui.container.Panel
        Band_ReceiverGrid            matlab.ui.container.GridLayout
        Band_IntegrationTime         matlab.ui.control.NumericEditField
        Band_IntegrationTimeLabel    matlab.ui.control.Label
        Band_Detector                matlab.ui.control.DropDown
        Band_DetectorLabel           matlab.ui.control.Label
        Band_attValue                matlab.ui.control.DropDown
        Band_attValueLabel           matlab.ui.control.Label
        Band_attMode                 matlab.ui.control.DropDown
        Band_attModeLabel            matlab.ui.control.Label
        Band_Preamp                  matlab.ui.control.DropDown
        Band_PreampLabel             matlab.ui.control.Label
        Band_VBW                     matlab.ui.control.DropDown
        Band_VBWLabel                matlab.ui.control.Label
        Band_Resolution              matlab.ui.control.DropDown
        Band_ResolutionLabel         matlab.ui.control.Label
        Band_Selectivity             matlab.ui.control.DropDown
        Band_SelectivityLabel        matlab.ui.control.Label
        Band_DataPoints2             matlab.ui.control.NumericEditField
        Band_DataPoints1             matlab.ui.control.Spinner
        Band_DataPointsLabel         matlab.ui.control.Label
        Band_StepWidth2              matlab.ui.control.DropDown
        Band_StepWidth1              matlab.ui.control.NumericEditField
        Band_StepWidthLabel          matlab.ui.control.Label
        Band_Refresh                 matlab.ui.control.Image
        Band_ReceiverLabel           matlab.ui.control.Label
        Band_Samples                 matlab.ui.control.NumericEditField
        Band_SamplesLabel            matlab.ui.control.Label
        ConfirmEditionButtonGrid     matlab.ui.container.GridLayout
        ConfirmEditionButton         matlab.ui.control.Button
        Toolbar                      matlab.ui.container.GridLayout
        ContextMenu                  matlab.ui.container.ContextMenu
        contextmenu_DelAntennaEntry  matlab.ui.container.Menu
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'TASK_ADD'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false

        mainApp
        jsBackDoor
        progressDialog

        taskList
        receiverObj
        gpsObj
        EMSatObj

        infoEdition
        EB500Map
        switchList
        targetList
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
        function ipcSecondaryMatlabCallsHandler(app, callingApp, operationType, varargin)
            try
                switch class(callingApp)
                    case {'winAppColeta', 'winAppColeta_exported'}
                        switch operationType
                            % auxApp.dockTracking >> winAppColeta >> auxApp.winAddTask
                            case 'closeFcnCallFromPopupApp'
                                app.popupContainer.Parent.Visible = 0;

                            case 'deleteAddedAntenna'
                                onAntennaDelButtonClicked(app)

                            otherwise
                                error('UnexpectedCall')
                        end
    
                    otherwise
                        error('UnexpectedCall')
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

            appName = class(app);
            switch tabIndex
                case 1
                    elToModify = {
                        app.MetaData;
                        app.ConfirmEditionButtonGrid;
                        app.DockUndockButton;
                        app.DockCloseButton
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.MetaData, appName);
                    catch
                    end

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.ConfirmEditionButtonGrid.UserData.id, 'style', struct('background', 'none')), ...
                            struct('appName', appName, 'dataTag', app.DockUndockButton.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Reabre módulo em outra janela')), ...
                            struct('appName', appName, 'dataTag', app.DockCloseButton.UserData.id, 'tooltip', struct('defaultPosition', 'bottom', 'textContent', 'Fecha módulo')) ...
                        });
                    catch
                    end

                case 2
                    % ...
                    
                case 3
                    ui.CustomizationBase.getElementsDataTag({app.AntennaList_Tree});
                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AntennaList_Tree.UserData.id, 'listener', struct('componentName', 'auxApp.winAddTask.AntennaList_Tree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end
            end
        end

        %-----------------------------------------------------------------%
        function initializeAppProperties(app)
            app.receiverObj = app.mainApp.receiverObj;
            app.gpsObj = app.mainApp.gpsObj;
            app.EB500Map = app.mainApp.EB500Obj.SelectivityMap;            
            app.EMSatObj = app.mainApp.EMSatObj;

            [projectFolder, programDataFolder] = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
            switchFile = fullfile(programDataFolder, 'SwitchList.json');
            if ~isfile(switchFile)
                switchFile = fullfile(projectFolder, 'SwitchList.json');
            end
            app.switchList = struct2table(jsondecode(fileread(switchFile)));

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
        function initializeUIComponents(app)
            if ~strcmp(app.mainApp.executionMode, 'webApp')
                app.DockUndockButton.Enable = 1;
            end

            app.Panel_2.BorderColor = [0.9412 0.9412 0.9412];
            app.Panel.BorderColor = [0.9412 0.9412 0.9412];
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            % ## RECEPTORES ##
            % Inicialmente, identifica-se a lista de RECEPTORES disponíveis
            % p/ realização de uma tarefa de monitoração. Isso precisa ser
            % feito inicialmente pois impacta na tela de especificidades do
            % receptor selecionado.
            receiverIndexes = find(app.receiverObj.List.Enable)';
            receiverList = {};
            for receiverIndex = receiverIndexes
                receiverSocket = getReceiverEndpoint(app, app.receiverObj.List.Parameters{receiverIndex});
                receiverList{end+1} = sprintf('ID %d: %s - %s', receiverIndex, app.receiverObj.List.Name{receiverIndex}, receiverSocket);
            end
            app.Receiver_List.Items = receiverList;

            % Caso se trate da edição de uma tarefa, seleciona-se o receptor
            % em uso, caso ainda disponível.
            if strcmp(app.infoEdition.type, 'edit')    
                selectedReceiverSocket = getReceiverEndpoint(app, app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Receiver.Selection.Parameters{1});
                selectedReceiverName   = sprintf('%s - %s', app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Receiver.Selection.Name{1}, selectedReceiverSocket);
                selectedReceiverIndex  = find(contains(receiverList, selectedReceiverName), 1);

                if ~isempty(selectedReceiverIndex)
                    app.Receiver_List.Value = app.Receiver_List.Items{selectedReceiverIndex};
                end
            end

            % ## TAREFAS ##
            % A tarefa padrão é a primeira, com ressalva que no caso de uma
            % edição de uma tarefa, a lista terá uma única tarefa. app.taskList 
            % é criada no startupFcn desse app.
            app.TaskName.Items = {app.taskList.Name};
            onTaskValueChanged(app)

            if strcmp(app.infoEdition.type, 'edit')
                app.TaskType.Value = replace(app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Type, ' (PRÉVIA)', '');
                if contains(app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Type, '(PRÉVIA)')                    
                    app.PreviewTaskCheckbox.Value = true;
                end                
                onTaskTypeValueChanged(app)

                if strcmp(app.TaskType.Value, 'Rompimento de Máscara Espectral')
                    set(app.MaskFile_Button, 'Enable', 1, 'Tag', app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.MaskFile)
                end

                app.Receiver_RstCommand.Value = app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Receiver.Reset;
                app.Receiver_SyncRef.Value    = app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Receiver.Sync;

                gpsMetaData = app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Script.GPS;
                if strcmp(gpsMetaData.Type, 'Manual')
                    app.GPS_List.Value            = 'ID 0: Manual';
                    app.GPS_manualLatitude.Value  = gpsMetaData.Latitude;
                    app.GPS_manualLongitude.Value = gpsMetaData.Longitude;
                    
                    onGPSValueChanged(app)
                end

                switchMetaData = app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Antenna.Switch;
                if ~isempty(switchMetaData.Name)
                    app.AntennaSwitch_Mode.Value = 1;
                    onAntennaSwitchModeValueChanged(app)
                end

                antennaList = app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Antenna.MetaData;
                for kk = 1:numel(antennaList)
                    antennaMetaData = antennaList(kk);

                    % add new value
                    switch app.AntennaSwitch_Name.Value
                        case 'EMSat'
                            antennaNameList = extractBefore(app.AntennaName.Items, ' ');
                        otherwise
                            antennaNameList = app.AntennaName.Items;
                    end

                    [~, antennaIndex] = ismember(antennaMetaData.Name, antennaNameList);

                    if antennaIndex
                        app.AntennaName.Value = app.AntennaName.Items{antennaIndex};
                        onAntennaNameValueChanged(app)

                        app.Antenna_TrackingMode.Value = antennaMetaData.TrackingMode;
                        onAntennaTrackingModeValueChanged(app)

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

                        onAntennaAddButtonClicked(app)
                    end
                end
                onBandViewTreeSelectionChanged(app)
                
            else
                % O campo "EditedFlag" não existe originalmente no arquivo 
                % "TaskList.json", devendo ser criado.
                for taskIdx = 1:numel(app.taskList)
                    for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                        app.taskList(taskIdx).Band(bandIdx).EditedFlag = 0;
                    end
                end
            end

            % Visibilidade do botão "Pin", que possibilita importação das 
            % coordenadas geográficas da estação.
            if strcmp(app.mainApp.General.context.CONFIG.station.type, 'Fixed')  && ...
                    (app.mainApp.General.context.CONFIG.station.latitude  ~= -1) && ...
                    (app.mainApp.General.context.CONFIG.station.longitude ~= -1)
                app.GPS_List.Layout.Column   = 1;
                app.GPS_FixedStation.Visible = true;
            else
                app.GPS_List.Layout.Column   = [1,2];
                app.GPS_FixedStation.Visible = false;
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function receiverEndPoint = getReceiverEndpoint(~, receiverParameters)
            parameters = jsondecode(receiverParameters);

            if isfield(parameters, 'IP') && isfield(parameters, 'Port')
                receiverEndPoint = sprintf('%s:%s', parameters.IP, parameters.Port);

            elseif isfield(parameters, 'IP')
                receiverEndPoint = parameters.IP;

            else
                receiverEndPoint = parameters.Port;
            end
        end

        %-----------------------------------------------------------------%
        function varargout = testInstrumentConnectivity(app, family, emitNotification)
            arguments
                app 
                family {mustBeMember(family, {'receiver', 'gps'})}
                emitNotification (1, 1) logical = false
            end

            switch family
                case 'receiver'
                    receiverName = getSelectedReceiverName(app);
        
                    idx1 = str2double(char(extractBetween(app.Receiver_List.Value, 'ID', ':')));
                    idx2 = find(strcmp(app.receiverObj.Config.Name, receiverName), 1);
        
                    receiverConfig = struct( ...
                        'Type', app.receiverObj.List.Type{idx1},  ...
                        'Tag', app.receiverObj.Config.Tag{idx2}, ...
                        'Parameters', jsondecode(app.receiverObj.List.Parameters{idx1}) ...
                    );
        
                    [receiverHandle, notification] = testConnectivity(app.receiverObj, receiverConfig, emitNotification);
                    varargout = {receiverHandle};

                case 'gps'
                    idx1 = str2double(char(extractBetween(app.GPS_List.Value, 'ID', ':'))) - numel(app.Receiver_List.Items);
        
                    gpsConfig = struct( ...
                        'Type', app.gpsObj.List.Type{idx1}, ...
                        'Parameters', jsondecode(app.gpsObj.List.Parameters{idx1}) ...
                    );
                    
                    [gpsHandle, gps, notification] = testConnectivity(app.gpsObj, gpsConfig, emitNotification);
                    varargout = {gpsHandle, gps};
            end

            if ~isempty(notification)
                ui.Dialog(app.UIFigure, notification.type, notification.message);
            end
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
            switchIndex    = getAntennaSwitchIndex(app, 'default');
            set(app.Band_Antenna, 'Items', app.switchList.Antennas{switchIndex}, 'Value', initialAntenna)
        end

        %-----------------------------------------------------------------%
        function buildTreeBands(app, taskIdx)
            delete(app.Band_Tree.Children);

            for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                bandNode = uitreenode(app.Band_Tree, 'Text', getFlowTag(app, taskIdx, bandIdx), 'NodeData', bandIdx, 'Icon', 'Playback_32.png');

                if strcmp(app.TaskType.Value, 'Rompimento de Máscara Espectral') && app.taskList(taskIdx).Band(bandIdx).MaskTrigger.Status
                    bandNode.Icon = "Occupancy_32.png";
                end
            end

            app.Band_Tree.SelectedNodes = app.Band_Tree.Children(1);
        end

        %-----------------------------------------------------------------%
        function tag = getFlowTag(app, taskIdx, bandIdx)
            tag = util.HtmlTextGenerator.createTag('Flow', app.taskList(taskIdx).Band(bandIdx).FreqStart, app.taskList(taskIdx).Band(bandIdx).FreqStop, app.taskList(taskIdx).Band(bandIdx).ID);
        end

        %-----------------------------------------------------------------%
        function BandView_SatelliteList(app)            
            if isempty(app.Band_TargetList.Value)
                switchIndex = getAntennaSwitchIndex(app, 'default');

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
            receiverDriver = getSelectedReceiverDriver(app);

            switch receiverDriver.IsStreaming
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case false
                    app.Band_ReceiverGrid.RowHeight(2:3)   = {22,0};
                    set(findobj(groot, 'Parent', app.Band_ReceiverGrid, 'Tag', 'task_Set1'), 'Enable', 1)
                    set(findobj(groot, 'Parent', app.Band_ReceiverGrid, 'Tag', 'task_Set2'), 'Enable', 0)

                    app.Band_Preamp.Enable                 = 1;                    
                    app.Band_SelectivityLabel.Visible      = 0;
                    app.Band_Selectivity.Visible           = 0;

                    if receiverDriver.HasVideoBandWidth
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
                case true
                    app.Band_ReceiverGrid.RowHeight(2:3)   = {0,22};
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
            receiverDriver = getSelectedReceiverDriver(app);
            features       = receiverDriver.Definition.features;

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
            instrSettings.AttFactor_Items = strsplit(features.attenuationValues, ',');
            instrSettings.AttFactor       = instrSettings.AttFactor_Items{1};
            instrSettings.Detector_Items  = strsplit(features.detector.items, ',');

            switch receiverDriver.IsStreaming
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case false
                    % RBW
                    instrSettings.Resolution_Items = strsplit(features.resolutions, ',');
                    rbwValues                      = str2double(extractBefore(instrSettings.Resolution_Items, 'kHz'))*1000;
                    [~, rbwIndex]                  = min(abs(rbwValues - app.taskList(idx1).Band(idx2).Resolution));
                    instrSettings.Resolution       = instrSettings.Resolution_Items{rbwIndex};

                    % VBW
                    if receiverDriver.HasVideoBandWidth
                        instrSettings.VBW_Items = strsplit(features.videoBandWidths, ',');

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
                    instrSettings.DataPoints_Limits = features.dataPoints;

                    DataPoints = round(span/app.taskList(idx1).Band(idx2).StepWidth + 1);
                    if     DataPoints < instrSettings.DataPoints_Limits(1)
                        instrSettings.DataPoints = instrSettings.DataPoints_Limits(1);
                    elseif DataPoints > instrSettings.DataPoints_Limits(2)
                        instrSettings.DataPoints = fix(instrSettings.DataPoints_Limits(2));
                    else
                        instrSettings.DataPoints = DataPoints;
                    end
                    instrSettings.StepWidth = span/(instrSettings.DataPoints - 1);

                    instrSettings.Selectivity = '';
                    instrSettings.SensitivityMode = '0';
                    instrSettings.Preamp = 'On';

                    instrSettings.LevelUnit = app.taskList(idx1).Band(idx2).LevelUnit;
                    if contains(app.Receiver_List.Value, 'N9344C')
                        instrSettings.LevelUnit = 'dBm';
                    end

                    switch app.taskList(idx1).Band(idx2).RFMode
                        case 'High Sensitivity'
                            instrSettings.AttMode = 'Manual';
                            instrSettings.SensitivityMode = '1';
                            
                        case 'Low Distortion'
                            instrSettings.Preamp = 'Off';
                    end

                % R&S EB500
                case true
                    instrSettings.StepWidth_Items   = strsplit(features.stepWidths, ',');
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
            receiverDriver = getSelectedReceiverDriver(app);
            
            if ~app.taskList(idx1).Band(idx2).EditedFlag
                BandView_EditablesParameters_SaveValues(app, idx1, idx2)
            else
                app.Band_Refresh.Visible = 1;
            end

            switch receiverDriver.IsStreaming
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case false
                    if fix(diff(receiverDriver.Definition.features.dataPoints))
                        set(app.Band_StepWidth1,  'Editable', 1, ...
                                                  'Value',  app.taskList(idx1).Band(idx2).instrStepWidth / 1000);
                        set(app.Band_DataPoints1, 'Limits', app.taskList(idx1).Band(idx2).instrDataPoints_Limits, ...
                                                  'Value',  app.taskList(idx1).Band(idx2).instrDataPoints)
                    else
                        set(app.Band_StepWidth1,  'Editable', 0, ...
                                                  'Value',  app.taskList(idx1).Band(idx2).instrStepWidth / 1000);
                        set(app.Band_DataPoints1, 'Limits', app.taskList(idx1).Band(idx2).instrDataPoints_Limits, ...
                                                  'Value',  receiverDriver.Definition.features.dataPoints(1))
                    end

                    app.Band_IntegrationTimeLabel.Visible = 0;
                    app.Band_IntegrationTime.Visible      = 0;

                % R&S EB500
                case true
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
        function taskIdx = getSelectedTaskIndex(app)
            [~, taskIdx] = ismember(app.TaskName.Value, app.TaskName.Items);
        end

        %-----------------------------------------------------------------%
        function receiverDriver = getSelectedReceiverDriver(app)
            receiverName   = getSelectedReceiverName(app);
            definition     = findDefinition(app.receiverObj, receiverName, app.TaskType.Value);
            receiverDriver = model.ReceiverDriver(definition);
        end

        %-----------------------------------------------------------------%
        function receiverName = getSelectedReceiverName(app)
            receiverName = char(extractBetween(app.Receiver_List.Value, ': ', ' -'));
        end

        %-----------------------------------------------------------------%
        function syncMode = getRunningReceiverSyncMode(app, receiverHandle)
            % Retorna o SyncMode do receptor caso haja tarefa em andamento
            % que o utilize (exceto a tarefa em edição). Caso contrário, ''.
            syncMode = '';

            tasks = app.mainApp.TaskController.Tasks;
            for taskIdx = 1:numel(tasks)
                if strcmp(app.infoEdition.type, 'edit') && (taskIdx == app.infoEdition.idx)
                    continue
                end

                if ~strcmp(tasks(taskIdx).Status, 'Em andamento')
                    continue
                end

                taskReceiver = tasks(taskIdx).Connections.receiver;
                if ~isempty(taskReceiver) && isvalid(taskReceiver) && isequal(taskReceiver, receiverHandle)
                    syncMode = receiverHandle.UserData.SyncMode;
                    break
                end
            end
        end

        %-----------------------------------------------------------------%
        function switchIdx = getAntennaSwitchIndex(app, sourceType)
            % Se o modo comutador está ativado, identifica-se o seu índice
            % na tabela app.switchList. Isso permite, por exemplo, identificar
            % lista de antenas controladas pelo comutador.
            %            
            % Caso contrário, identifica-se lista de "antenas avulsas" que
            % podem ser usadas numa monitoração.

            if strcmp(sourceType, 'ReceiverChanged') || app.AntennaSwitch_Mode.Value
                receiverName = getSelectedReceiverName(app);
                switchIdx = find(strcmp(app.switchList.Receiver, receiverName), 1);
            else
                switchIdx = find(strcmp(app.switchList.Switch, 'none'), 1);
            end
        end

        %-----------------------------------------------------------------%
        function validateTaskSpec(app)
            taskIdx = getSelectedTaskIndex(app);

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
                        bandsWithInvalidSpanIdxs = [];
                        
                        for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                            span = app.taskList(taskIdx).Band(bandIdx).FreqStop - app.taskList(taskIdx).Band(bandIdx).FreqStart;
                            step = class.Constants.FreqStr2NumConversion(app.taskList(taskIdx).Band(bandIdx).instrStepWidth);

                            % Retorna erro se escolhido um Span diferente de 1, 
                            % 2, 5, 10 ou 20 MHz. E retorna erro se for selecionado 
                            % um StepWidth não aceito pelo EB500.
                            %
                            % O mapeamento desses parâmetros, do EB500, consta 
                            % na classe EB500Lib e foram transcritos do manual 
                            % de operação do EB500, com a ressalva que alguns 
                            % valores foram ajustados diretamente no EB500 GUI 
                            % porque o manual parece estar desatualizado.

                            spanIdx = find(app.mainApp.EB500Obj.FFMSpanStepMap.Span == span, 1);
                            if isempty(spanIdx)
                                bandsWithInvalidSpanIdxs = [bandsWithInvalidSpanIdxs, bandIdx];

                            else
                                minStep = app.mainApp.EB500Obj.FFMSpanStepMap.minStepWidth(spanIdx);
                                maxStep = app.mainApp.EB500Obj.FFMSpanStepMap.maxStepWidth(spanIdx);

                                if (step < minStep) || (step > maxStep)
                                    bandsWithInvalidSpanIdxs = [bandsWithInvalidSpanIdxs, bandIdx];
                                end
                            end
                        end
    
                        if ~isempty(bandsWithInvalidSpanIdxs)
                            error('Inserido valores inválidos para ao menos um dos seguintes parâmetros: "Span" ou "StepWidth".\nID: %s\n\nOs valores permitidos de "Span" são 1, 2, 5, 10 ou 20 MHz. Já o <i>range</i> de valores permitidos de "StepWidth" dependem do valor do "Span".', strjoin(string(bandsWithInvalidSpanIdxs), ', '))
                        end
                    end
                
                case 'Rompimento de Máscara Espectral'
                    if ~isfile(app.MaskFile_Button.Tag)
                        error('Não selecionado o arquivo de máscara espectral.')
                    end
            end

            % (b) VALID OBSERVATION PERIOD
            switch app.ObservationType.Value
                case 'Período específico'
                    beginTime = app.SpecificTime_DatePicker1.Value + hours(app.SpecificTime_Spinner1.Value) + minutes(app.SpecificTime_Spinner2.Value);
                    endTime   = app.SpecificTime_DatePicker2.Value + hours(app.SpecificTime_Spinner3.Value) + minutes(app.SpecificTime_Spinner4.Value);
                    
                    if isnat(beginTime) || isnat(endTime) || (beginTime > endTime) || (endTime < datetime('now'))
                        error('Período de observação inválido.')
                    end

                case 'Quantidade específica de amostras'
                    bandsWithInvalidObservationSamplesIdxs = [];

                    for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                        if app.taskList(taskIdx).Band(bandIdx).instrObservationSamples <= 1
                            bandsWithInvalidObservationSamplesIdxs = [bandsWithInvalidObservationSamplesIdxs, bandIdx];
                        end
                    end

                    if ~isempty(bandsWithInvalidObservationSamplesIdxs)
                        error('Quantidade inválida de varreduras da(s) faixa(s) de frequência indicada(s) a seguir.\nID: %s\n\nO valor mínimo são duas varreduras.', strjoin(string(bandsWithInvalidObservationSamplesIdxs), ', '))
                    end
            end

            % (c) COORDINATES DIFFERENT FROM (-1,-1)
            if strcmp(app.GPS_List.Value, 'ID 0: Manual') && ~gpsLib.isRefPointInBrazil(struct('Latitude', app.GPS_manualLatitude.Value, 'Longitude', app.GPS_manualLongitude.Value))
                error('Coordenadas geográficas inválidas por remeter a local fora do país.')
            end

            % (d) REVISIT TIME (GPS x BANDS)
            if ~strcmp(app.GPS_List.Value, 'ID 0: Manual')
                revisitTimeArray = [app.GPS_RevisitTime.Value, [app.taskList(taskIdx).Band.RevisitTime]];
                if isequal(find(revisitTimeArray == min(revisitTimeArray)), 1)
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
                bandsWithoutAntennaIdxs = [];
                antennaList = {};

                for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                    if isempty(app.taskList(taskIdx).Band(bandIdx).instrAntenna)
                        bandsWithoutAntennaIdxs = [bandsWithoutAntennaIdxs, bandIdx];
                    else
                        antennaList{end+1} = app.taskList(taskIdx).Band(bandIdx).instrAntenna;
                    end
                end
                antennaList = unique(antennaList);

                if ~isempty(bandsWithoutAntennaIdxs)
                    error('Não selecionada a antena da(s) faixa(s) de frequência indicada(s) a seguir.\nID: %s', strjoin(string(bandsWithoutAntennaIdxs), ', '))
                else
                    antennaMetaData = {app.AntennaList_Tree.Children.Text};
    
                    antennaIdx = contains(antennaList, antennaMetaData);
                    if ~all(antennaIdx)
                        error('Não foram configurados os parâmetros de instalação da(s) antena(s) indicada(s) a seguir.\nAntenas: %s', strjoin(antennaList(~antennaIdx), ', '))
                    end
                end

            else
                if ~any(contains(app.AntennaName.Items, app.AntennaList_Tree.Children.Text))
                    error('Foram configurados os parâmetros de instalação de antena que não faz parte do rol de antenas possíveis, visto que foi desabilitado o comutador.')
                end
            end
        end

        %-----------------------------------------------------------------%
        function disableObservationSampleLimit(app)
            taskIdx = getSelectedTaskIndex(app);

            for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                app.taskList(taskIdx).Band(bandIdx).instrObservationSamples = -1;
            end
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, editionType)
            
            try
                if ~exist('editionType', 'var')
                    editionType = struct('type', 'new');
                end

                app.infoEdition = editionType;
                switch app.infoEdition.type
                    case 'new'
                        app.taskList = mainApp.taskList;
                        app.ConfirmEditionButton.Text = 'Inclui tarefa';
                        
                    case 'edit'
                        app.taskList = util.TaskScriptIO.toRawScript(mainApp.TaskController.Tasks(editionType.idx).TaskSpec.Script);
                        app.ConfirmEditionButton.Text = 'Edita tarefa';
                end

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

        % Selection change function: SubTabGroup
        function onSubTabGroupSelectionChanged(app, event)
            
            [~, tabIndex] = ismember(app.SubTabGroup.SelectedTab, app.SubTabGroup.Children);
            applyJSCustomizations(app, tabIndex)

        end

        % Value changed function: TaskName
        function onTaskValueChanged(app, event)

            % Aspectos a atualizar:
            % - TAB 1: Codificação e Período de observação;
            % - TAB 2: Árvore e metadados do fluxo selecionado; e
            % - TAB 3: Metadados do fluxo selecionado (peculiaridades receptor).
            
            taskIdx = getSelectedTaskIndex(app);

            app.BitsPerPoint.Value = sprintf('%d bits', app.taskList(taskIdx).BitsPerSample);

            switch app.taskList(taskIdx).Observation.Type
                case 'Duration'
                    app.ObservationType.Value  = app.ObservationType.Items{1};

                    durationSeconds = app.taskList(taskIdx).Observation.Duration;
                    if durationSeconds >= 3600
                        app.Duration.Value     = durationSeconds ./ 3600;
                        app.DurationUnit.Value = 'hr';
                    else
                        app.Duration.Value     = durationSeconds ./ 60;
                        app.DurationUnit.Value = 'min';
                    end

                case 'Time'
                    app.ObservationType.Value  = app.ObservationType.Items{2};
                    
                    taskStartsAt = datetime(app.taskList(taskIdx).Observation.BeginTime, "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");
                    taskStopsAt  = datetime(app.taskList(taskIdx).Observation.EndTime,   "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");

                    app.SpecificTime_DatePicker1.Value = taskStartsAt;
                    app.SpecificTime_Spinner1.Value    = hour(taskStartsAt);
                    app.SpecificTime_Spinner2.Value    = minute(taskStartsAt);
                    
                    app.SpecificTime_DatePicker2.Value = taskStopsAt;
                    app.SpecificTime_Spinner3.Value    = hour(taskStopsAt);
                    app.SpecificTime_Spinner4.Value    = minute(taskStopsAt);

                case 'Samples'
                    app.ObservationType.Value  = app.ObservationType.Items{3};
            end
            onObservationTypeValueChanged(app)
            
            buildTreeBands(app, taskIdx)
            onReceiverValueChanged(app)            
            onBandViewTreeSelectionChanged(app)

        end

        % Value changed function: TaskType
        function onTaskTypeValueChanged(app, event)

            switch app.TaskType.Value
                case 'Rompimento de Máscara Espectral'
                    app.TaskType.Layout.Column = 1;
                    app.AddMaskFile_Button.Visible = true;
                    set(app.MaskFile_Button, 'Visible', true, 'Enable', isfile(app.MaskFile_Button.Tag))

                otherwise
                    app.TaskType.Layout.Column = [1,3];
                    app.AddMaskFile_Button.Visible = false;
                    set(app.MaskFile_Button, 'Visible', false, 'Enable', false)
            end

            switch app.TaskType.Value
                case 'Drive-test (Level+Azimuth)'
                    set(findobj(app.Band_DFGrid.Children, '-not', 'Type', 'uilabel'), 'Enable', 1)

                otherwise
                    set(findobj(app.Band_DFGrid.Children, '-not', 'Type', 'uilabel'), 'Enable', 0)

            end

            taskIdx = getSelectedTaskIndex(app);
            buildTreeBands(app, taskIdx)

            % A alteração do tipo de tarefa - caso envolva a tarefa "Drive-test"
            % - tem impacto no tempo de revisita do GPS. Importante, portanto, 
            % atualizar o valor do campo.
            onGPSValueChanged(app)
            
        end

        % Button pushed function: AddMaskFile_Button, MaskFile_Button
        function onMaskFileButtonPushed(app, event)
            
            switch event.Source
                case app.AddMaskFile_Button
                    [fileName, fileFolder] = uigetfile({'*.csv', '(*.csv)'}, 'Selecione um arquivo de máscara espectral', 'MultiSelect', 'off');
                    figure(app.UIFigure)
                    
                    if fileName
                        set(app.MaskFile_Button, 'Enable', true, 'Tag', fullfile(fileFolder, fileName))
                    end

                case app.MaskFile_Button
                    try
                        msg = textFormatGUI.cellstr2TextField(splitlines(fileread(app.MaskFile_Button.Tag)), '\n');
                        ui.Dialog(app.UIFigure, 'warning', msg);
        
                    catch ME
                        ui.Dialog(app.UIFigure, 'error', getReport(ME));
                    end
            end

        end

        % Value changed function: ObservationType
        function onObservationTypeValueChanged(app, event)
            
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
        function onReceiverValueChanged(app, event)
            
            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.Band_Tree.SelectedNodes.NodeData;
            receiverDriver = getSelectedReceiverDriver(app);
            
            % ## GPS ##
            % A lista de GPS é formada pelo "ID 0: Manual", o GPS do receptor
            % selecionado, caso existe GPS embarcado nele, e os GPSs externos.
            % Os GPSs externos são representados por "IDs virtuais", que não 
            % se confundem com os IDs de receptores.
            gpsList     = {'ID 0: Manual'};
            if receiverDriver.HasGps
                gpsList{end+1} = app.Receiver_List.Value;
            end

            gpsIndexes = find(app.gpsObj.List.Enable);
            numReceivers = numel(app.Receiver_List.Items);
            for ii = 1:numel(gpsIndexes)
                gpsIndex = gpsIndexes(ii);
                gpsParameters = jsondecode(app.gpsObj.List.Parameters{gpsIndex});

                switch app.gpsObj.List.Type{gpsIndex}
                    case 'Serial'
                        gpsSocket = gpsParameters.Port;
                    case 'TCPIP Socket'
                        gpsSocket = sprintf('%s:%s', gpsParameters.IP, gpsParameters.Port);
                end

                gpsList{end+1} = sprintf('ID %d: %s - %s', numReceivers+ii, app.gpsObj.List.Name{gpsIndex}, gpsSocket);
            end
            app.GPS_List.Items = gpsList;

            % Se o GPS não foi editado, escolhe-se como valor inicial o do
            % próprio receptor selecionado, caso este possui um GPS embarcado.
            if receiverDriver.HasGps
                if ~strcmp(app.taskList(taskIdx).GPS.Type, 'manual')
                    app.GPS_List.Value = app.Receiver_List.Value;
                end
            end
            onGPSValueChanged(app)

            % ## ANTENNA SWITCH ##
            set(app.AntennaSwitch_Mode, 'Enable', 0, 'Value', 0)
            set(app.AntennaSwitch_Name, 'Enable', 0, 'Value', '')
            
            idxSwitch = getAntennaSwitchIndex(app, 'ReceiverChanged');            
            if ~isempty(idxSwitch)
                set(app.AntennaSwitch_Mode, 'Enable', 1, 'Value', app.switchList.SwitchDefaultStatus(idxSwitch))                
            end
            onAntennaSwitchModeValueChanged(app)
            
            % ## RECEIVER SYNC ##
            app.Receiver_SyncRef.Items = strsplit(receiverDriver.Definition.features.sweepMode.items, ',');

            % ## RECEIVER CUSTOM PARAMETERS ##
            % Caso se trate de uma nova tarefa, toda vez que for alterado o
            % receptor, deve-se atualizar os parâmetros customizados relacionados 
            % ao próprio receptor. Isto porque os parâmetros do R&S EB500, por 
            % exemplo, são diferentes do Tek SA2500.
            if strcmp(app.infoEdition.type, 'new')
                for kk = 1:numel(app.taskList(taskIdx).Band)
                    BandView_EditablesParameters_SaveValues(app, taskIdx, kk)
                end
            end

            % Atualiza-se a lista de parâmetros visíveis e os seus valores.
            BandView_EditablesParameters_Visibility(app)
            BandView_EditablesParameters_ShowValues(app, taskIdx, bandIdx)

        end

        % Value changed function: GPS_List
        function onGPSValueChanged(app, event)

            switch app.GPS_List.Value
                case 'ID 0: Manual'  
                    set(app.GPS_Grid.Children,        'Enable', true)
                    set(app.GPS_RevisitTime,          'Enable', false)

                otherwise
                    set(app.GPS_Grid.Children,        'Enable', false)
                    set(app.GPS_manualLatitudeLabel,  'Enable', true)
                    set(app.GPS_manualLongitudeLabel, 'Enable', true)
                    set(app.GPS_RevisitTimeLabel,     'Enable', true)

                    taskIdx = getSelectedTaskIndex(app);

                    switch app.TaskType.Value
                        case {'Drive-test', 'Drive-test (Level+Azimuth)'}
                            gpsEditable = false;
                            gpsValue = max([min([app.taskList(taskIdx).Band.RevisitTime]), app.GPS_RevisitTime.Limits(1)]);

                        otherwise
                            gpsEditable = true;
                            if ~isempty(app.taskList(taskIdx).GPS.RevisitTime)
                                gpsValue = app.taskList(taskIdx).GPS.RevisitTime;
                            else
                                gpsValue = 60;
                            end
                    end

                    set(app.GPS_RevisitTime, 'Enable', true, 'Editable', gpsEditable, 'Value', gpsValue)
            end

        end

        % Button pushed function: GPS_FixedStation
        function onGPSPinButtonPushed(app, event)
            
            app.GPS_List.Value = 'ID 0: Manual';
            app.GPS_manualLatitude.Value  = app.mainApp.General.context.CONFIG.station.latitude;
            app.GPS_manualLongitude.Value = app.mainApp.General.context.CONFIG.station.longitude;

            onGPSValueChanged(app)

        end

        % Button pushed function: GPS_Connectivity, Receiver_Connectivity
        function onConnectivityTestButtonPushed(app, event)
            
            switch event.Source
                case app.Receiver_Connectivity
                    app.progressDialog.Visible = 'visible';
                    testInstrumentConnectivity(app, 'receiver', true);            
                    app.progressDialog.Visible = 'hidden';

                case app.GPS_Connectivity
                    if strcmp(app.GPS_List.Value, 'ID 0: Manual') && ~gpsLib.isRefPointInBrazil(struct('Latitude', app.GPS_manualLatitude.Value, 'Longitude', app.GPS_manualLongitude.Value))
                        ui.Dialog(app.UIFigure, 'warning', 'Coordenadas geográficas inválidas por remeter a local fora do país.');
                        return
                    end
        
                    app.progressDialog.Visible = 'visible';

                    gps = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '');
        
                    try
                        if strcmp(app.Receiver_List.Value, app.GPS_List.Value)
                            receiverHandle = testInstrumentConnectivity(app, 'receiver');
                            if ~isempty(receiverHandle)
                                gps = model.GPS.fetchGPSCoordinates('Built-in', receiverHandle, receiverHandle.UserData.IDN);
                            end
            
                        elseif strcmp(app.GPS_List.Value, 'ID 0: Manual')
                            gps.Status = 1;

                            % Inicialmente trunca os valores de lat e lng
                            % em seis casas decimais...
                            gps.Latitude = round(app.GPS_manualLatitude.Value,  6);
                            gps.Longitude = round(app.GPS_manualLongitude.Value, 6);
            
                        else
                            [~, gps] = testInstrumentConnectivity(app, 'gps');
                        end
            
                        if gps.Status
                            [cityName, cityDistance] = gpsLib.findNearestCity(gps);

                            warningMsg = { ...
                                sprintf('Status: %d', gps.Status), ...
                                sprintf('Latitude: %.6fº', gps.Latitude), ...
                                sprintf('Longitude: %.6fº', gps.Longitude) ...
                            };

                            if ~isempty(gps.TimeStamp)
                                warningMsg{end+1} = sprintf('Timestamp: %s', gps.TimeStamp);
                            end

                            if ~isempty(cityName) && ~isempty(cityDistance)
                                warningMsg{end+1} = sprintf('Nota:\nCoordenadas geográficas distam <b>%.1f km</b> da sede do município <b>%s</b>.', cityDistance, cityName);
                            end
                            
                            ui.Dialog(app.UIFigure, 'warning', strjoin(warningMsg, '<br>'));
            
                        else
                            error('<b>Não recebida informação válida do instrumento acerca das coordenadas geográficas do local de monitoração.</b>\n%s', jsonencode(gps))
                        end
        
                    catch ME
                        ui.Dialog(app.UIFigure, 'error', ME.message);
                    end
        
                    app.progressDialog.Visible = 'hidden';
            end

        end

        % Value changed function: AntennaSwitch_Mode
        function onAntennaSwitchModeValueChanged(app, event)
            
            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.Band_Tree.SelectedNodes.NodeData;
            switchIdx = getAntennaSwitchIndex(app, 'default');

            if app.AntennaSwitch_Mode.Value
                set(app.AntennaSwitch_Name,        'Enable', 1, 'Value', app.switchList.Switch{switchIdx})                
                set(app.Band_AntennaGrid.Children, 'Enable', 1)
                
                switch app.AntennaSwitch_Name.Value                    
                    case 'EMSat'
                        set(app.AntennaName,     'Enable', 0, 'Items', app.switchList.Antennas{switchIdx})
                        set(app.Band_TargetList, 'Items', [{''}, app.targetList], 'Value', '')

                        if isfield(app.taskList(taskIdx).Band(bandIdx), 'instrTarget')
                            if ismember(app.taskList(taskIdx).Band(bandIdx).instrTarget, app.Band_TargetList.Items)
                                app.Band_TargetList.Value = app.taskList(taskIdx).Band(bandIdx).instrTarget;
                            end
                            BandView_SatelliteList(app)
                        end

                    case 'ERMx'
                        set(app.AntennaName,     'Enable', 0, 'Items', app.switchList.Antennas{switchIdx})
                        set(app.Band_TargetList, 'Enable', 0, 'Items', {''})
                        app.Band_Antenna.Items = app.switchList.Antennas{switchIdx};
                        app.Band_TargetListRefresh.Enable = 0;
                end

                if isfield(app.taskList(taskIdx).Band(bandIdx), 'instrAntenna') && ismember(app.taskList(taskIdx).Band(bandIdx).instrAntenna, app.Band_Antenna.Items)
                    app.Band_Antenna.Value = app.taskList(taskIdx).Band(bandIdx).instrAntenna;
                end

            else
                set(app.AntennaSwitch_Name, 'Enable', 0, 'Value', '')
                set(app.AntennaName,        'Enable', 1, 'Items', app.switchList.Antennas{switchIdx}, 'Value', '')

                set(app.Band_TargetList,    'Enable', 0, 'Items', {''})
                set(app.Band_Antenna,       'Enable', 0, 'Items', {''})
                app.Band_TargetListRefresh.Enable = 0;
            end

            onAntennaNameValueChanged(app)
            
        end

        % Value changed function: AntennaName
        function onAntennaNameValueChanged(app, event)

            if ~isempty(app.AntennaName.Value)
                switch app.AntennaSwitch_Name.Value
                    case 'EMSat'
                        if ~isempty(app.Band_TargetList.Value)
                            set(app.Antenna_TrackingMode, 'Items', {'Target', 'LookAngles', 'Manual'}, 'Value', 'Target')
                        else
                            initialSelection = app.Antenna_TrackingMode.Value;
                            if ~ismember(initialSelection, {'LookAngles', 'Manual'})
                                initialSelection = 'Manual';
                            end
                            set(app.Antenna_TrackingMode, 'Items', {'LookAngles', 'Manual'}, 'Value', initialSelection)
                        end
                    
                    otherwise
                        app.Antenna_TrackingMode.Items = {'Manual'};
                end    
                app.AddAntenna_Image.Enable = 1;

            else
                app.Antenna_TrackingMode.Items = {'Manual'};
                app.AddAntenna_Image.Enable = 0;
            end

            onAntennaTrackingModeValueChanged(app)

        end

        % Value changed function: Antenna_TrackingMode
        function onAntennaTrackingModeValueChanged(app, event)

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
        function onAntennaAddButtonClicked(app, event)
            
            % Características da antena selecionada:
            switch app.AntennaSwitch_Name.Value
                case 'EMSat'
                    newAntennaName = extractBefore(app.AntennaName.Value, ' ');
                otherwise
                    newAntennaName = app.AntennaName.Value;
            end

            newAntennaSpec1 = app.Antenna_TrackingMode.Value;
            if ~isempty(app.Band_TargetList.Value)
                newAntennaSpec1 = sprintf('%s; %s', newAntennaSpec1, app.Band_TargetList.Value);
            else
                newAntennaSpec1 = sprintf('%s; "NA"', newAntennaSpec1);
            end

            if app.AntennaHeight.Enable
                newAntennaSpec2 = sprintf('%.0fm', app.AntennaHeight.Value);
            else
                newAntennaSpec2 = '"NA"';
            end

            if app.AntennaAzimuth.Enable
                newAntennaSpec2 = sprintf('%s; %.3fº %s; %.3fº; %.1fº', newAntennaSpec2, app.AntennaAzimuth.Value, app.AntennaAzimuthRef.Value, app.AntennaElevation.Value, app.AntennaPolarization.Value);
            else
                newAntennaSpec2 = sprintf('%s; "NA"; "NA"; "NA"', newAntennaSpec2);
            end

            % Verifica se a antena seleciona já está na lista de antenas,
            % incluindo-a como nova ou editando-a, a depender do caso.
            antennaList = {};
            if ~isempty(app.AntennaList_Tree.Children)
                antennaList = {app.AntennaList_Tree.Children.Text};
            end
            
            [~, idx] = ismember(newAntennaName, antennaList);
            if idx
                app.AntennaList_Tree.Children(idx).Children(1).Text = newAntennaSpec1;
                app.AntennaList_Tree.Children(idx).Children(2).Text = newAntennaSpec2;

            else
                nodeData   = numel(app.AntennaList_Tree.Children)+1;                
                nodeHandle = uitreenode(app.AntennaList_Tree, 'Text', newAntennaName, 'NodeData', nodeData, 'ContextMenu', app.ContextMenu);

                uitreenode(nodeHandle, 'Text', newAntennaSpec1, 'NodeData', nodeData, 'ContextMenu', app.ContextMenu);
                uitreenode(nodeHandle, 'Text', newAntennaSpec2, 'NodeData', nodeData, 'ContextMenu', app.ContextMenu);
            end

        end

        % Menu selected function: contextmenu_DelAntennaEntry
        function onAntennaDelButtonClicked(app, event)
            
            if ~isempty(app.AntennaList_Tree.SelectedNodes)
                nodeData = app.AntennaList_Tree.SelectedNodes.NodeData;
                nodeHandles = findobj(app.AntennaList_Tree, 'NodeData', nodeData);

                if ~isempty(nodeHandles)
                    delete(nodeHandles)

                    for ii = 1:numel(app.AntennaList_Tree.Children)
                        app.AntennaList_Tree.Children(ii).NodeData             = ii;
                        app.AntennaList_Tree.Children(ii).Children(1).NodeData = ii;
                        app.AntennaList_Tree.Children(ii).Children(2).NodeData = ii;
                    end
                end
            end

        end

        % Selection changed function: Band_Tree
        function onBandViewTreeSelectionChanged(app, event)

            if exist('event', 'var')
                if isempty(event.SelectedNodes)
                    app.Band_Tree.SelectedNodes = event.PreviousSelectedNodes;
                    return
                end
            end

            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.Band_Tree.SelectedNodes.NodeData;

            app.MetaData.Text = util.HtmlTextGenerator.AddTask_BandView(app.taskList, taskIdx, bandIdx);
            BandView_EditablesParameters_ShowValues(app, taskIdx, bandIdx)

            if ~isempty(app.Band_Antenna.Value)
                onBandViewParameterValueChanged(app, struct('Source', app.Band_Antenna))
            end

        end

        % Image clicked function: Band_Refresh
        function onBandViewRefreshImageClicked(app, event)

            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.Band_Tree.SelectedNodes.NodeData;

            app.taskList(taskIdx).Band(bandIdx).EditedFlag = 0;
            BandView_EditablesParameters_ShowValues(app, taskIdx, bandIdx)

        end

        % Value changed function: Band_Antenna, Band_DFMeasTime, 
        % ...and 15 other components
        function onBandViewParameterValueChanged(app, event)

            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.Band_Tree.SelectedNodes.NodeData;

            switch event.Source
                % OPERATION COMPLEXITY: 1 OF 3
                case app.Band_Samples
                    app.taskList(taskIdx).Band(bandIdx).instrObservationSamples = app.Band_Samples.Value;

                case app.Band_attValue
                    app.taskList(taskIdx).Band(bandIdx).instrAttFactor = app.Band_attValue.Value;

                case app.Band_Preamp
                    app.taskList(taskIdx).Band(bandIdx).instrPreamp = app.Band_Preamp.Value;

                case app.Band_IntegrationTime
                    app.taskList(taskIdx).Band(bandIdx).instrIntegrationTime = app.Band_IntegrationTime.Value;

                case app.Band_Detector
                    app.taskList(taskIdx).Band(bandIdx).instrDetector = app.Band_Detector.Value;

                case app.Band_VBW
                    app.taskList(taskIdx).Band(bandIdx).instrVBW = app.Band_VBW.Value;

                case app.Band_DFSquelchMode
                    app.taskList(taskIdx).Band(bandIdx).DF_SquelchMode = app.Band_DFSquelchMode.Value;

                case app.Band_DFSquelchValue
                    app.taskList(taskIdx).Band(bandIdx).DF_SquelchValue = app.Band_DFSquelchValue.Value;

                case app.Band_DFMeasTime
                    app.taskList(taskIdx).Band(bandIdx).DF_MeasTime = app.Band_DFMeasTime.Value / 1000;
                
                % OPERATION COMPLEXITY: 2 OF 3
                case app.Band_Antenna
                    app.taskList(taskIdx).Band(bandIdx).instrAntenna = app.Band_Antenna.Value;
                    
                    if ismember(app.AntennaSwitch_Name.Value, {'EMSat', 'ERMx'})
                        app.AntennaName.Value = app.Band_Antenna.Value;
                        onAntennaNameValueChanged(app)
                    end
                
                case app.Band_TargetList
                    app.taskList(taskIdx).Band(bandIdx).instrTarget = app.Band_TargetList.Value;

                    if ~isempty(app.Band_TargetList.Value)
                        antennaTrackingModeItems = {'Target', 'LookAngles', 'Manual'};
                    else
                        antennaTrackingModeItems = {'LookAngles', 'Manual'};
                    end
                    app.Antenna_TrackingMode.Items = antennaTrackingModeItems;
                    
                    initialSatellite = app.Band_Antenna.Value;
                    BandView_SatelliteList(app)

                    if ~isempty(initialSatellite)
                        onBandViewParameterValueChanged(app, struct('Source', app.Band_Antenna))
                    end

                case app.Band_DataPoints1
                    if ~fix(diff(app.Band_DataPoints1.Limits))
                        return
                    end        
                    span = app.taskList(taskIdx).Band(bandIdx).FreqStop - app.taskList(taskIdx).Band(bandIdx).FreqStart;
                    app.Band_StepWidth1.Value = (span/(app.Band_DataPoints1.Value-1)) / 1000;
        
                    app.taskList(taskIdx).Band(bandIdx).instrDataPoints  = app.Band_DataPoints1.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrStepWidth   = app.Band_StepWidth1.Value*1000;

                case app.Band_Selectivity
                    app.Band_Resolution.Value = sprintf('%.3f kHz', app.EB500Map{app.Band_StepWidth2.Value, app.Band_Selectivity.Value}/1000);
        
                    app.taskList(taskIdx).Band(bandIdx).instrSelectivity = app.Band_Selectivity.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrResolution  = app.Band_Resolution.Value;

                case app.Band_Resolution
                    app.taskList(taskIdx).Band(bandIdx).instrResolution  = app.Band_Resolution.Value;
        
                    if contains(app.Receiver_List.Value, 'EB500')
                        if app.Band_Selectivity.Visible
                            idxSelectivity = find(strcmp(app.Band_Resolution.Items, app.Band_Resolution.Value), 1);
                            app.Band_Selectivity.Value = app.Band_Selectivity.Items{idxSelectivity};
                        end
                        app.taskList(taskIdx).Band(bandIdx).instrSelectivity = app.Band_Selectivity.Value;
                    end

                case app.Band_attMode
                    app.taskList(taskIdx).Band(bandIdx).instrAttMode = app.Band_attMode.Value;
        
                    if strcmp(app.Band_attMode.Value, 'Auto')
                        app.Band_attValueLabel.Visible = 0;
                        app.Band_attValue.Visible      = 0;
                    else
                        app.Band_attValueLabel.Visible = 1;
                        app.Band_attValue.Visible      = 1;
                    end

                % OPERATION COMPLEXITY: 3 OF 3
                case app.Band_StepWidth1
                    span = app.taskList(taskIdx).Band(bandIdx).FreqStop - app.taskList(taskIdx).Band(bandIdx).FreqStart;
                    dataPoints = round(span/(app.Band_StepWidth1.Value*1000) + 1);

                    if dataPoints < app.Band_DataPoints1.Limits(1)
                        app.Band_DataPoints1.Value = app.Band_DataPoints1.Limits(1);
                    elseif dataPoints > app.Band_DataPoints1.Limits(2)
                        app.Band_DataPoints1.Value = fix(app.Band_DataPoints1.Limits(2));
                    else
                        app.Band_DataPoints1.Value = dataPoints;
                    end        
                    app.Band_StepWidth1.Value = (span/(app.Band_DataPoints1.Value-1)) / 1000;
        
                    app.taskList(taskIdx).Band(bandIdx).instrStepWidth  = 1000*app.Band_StepWidth1.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrDataPoints = app.Band_DataPoints1.Value;

                case app.Band_StepWidth2
                    span = app.taskList(taskIdx).Band(bandIdx).FreqStop - app.taskList(taskIdx).Band(bandIdx).FreqStart;
                    stepValue = extractBefore(app.Band_StepWidth2.Value, ' kHz');
        
                    app.Band_DataPoints2.Value = span/(1000*str2double(stepValue)) + 1;
        
                    rbwValues = [];
                    rbwItems  = {};
                    for ii = 1:3
                        rbwValues = [rbwValues, app.EB500Map{app.Band_StepWidth2.Value,ii}];
                        rbwItems  = [rbwItems,  sprintf('%.3f kHz', rbwValues(ii)/1000)];
                    end
                    app.Band_Resolution.Items = rbwItems;
        
                    rbwIndex = find(abs(rbwValues - app.taskList(taskIdx).Band(bandIdx).Resolution) == min(abs(rbwValues - app.taskList(taskIdx).Band(bandIdx).Resolution)));
                    app.Band_Resolution.Value = app.Band_Resolution.Items{rbwIndex};
                    app.Band_Selectivity.Value = app.Band_Selectivity.Items{rbwIndex};
        
                    app.taskList(taskIdx).Band(bandIdx).instrStepWidth        = app.Band_StepWidth2.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrDataPoints       = app.Band_DataPoints2.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrSelectivity      = app.Band_Selectivity.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrResolution_Items = app.Band_Resolution.Items;
                    app.taskList(taskIdx).Band(bandIdx).instrResolution       = app.Band_Resolution.Value;
            end

            app.taskList(taskIdx).Band(bandIdx).EditedFlag = 1;
            app.Band_Refresh.Visible = 1;
            
        end

        % Image clicked function: Band_TargetListRefresh
        function onBandViewTargetListRefreshImageClicked(app, event)
            
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
                case 'Atualizar lista'
                    [~, programDataFolder] = appEngine.util.Path(class.Constants.appName, app.mainApp.rootFolder);
                    movefile(FullFileName, fullfile(programDataFolder, 'EMSatLib.json'));

                case 'Salvar planilha'
                    writetable(tgtTable_new, replace(FullFileName, '.json', '.xlsx'))
            end

        end

        % Button pushed function: ConfirmEditionButton
        function onConfirmEditionButtonClicked(app, event)
            
            app.progressDialog.Visible = 'visible';

            % (A) VALIDATIONS
            try
                validateTaskSpec(app)

            catch ME
                ui.Dialog(app.UIFigure, 'error', ME.message);
                app.progressDialog.Visible = 'hidden';
                return
            end

            % (B) GENERAL ASPECTS OF THE SELECTED TASK
            taskIdx = getSelectedTaskIndex(app);
            receiverDriver = getSelectedReceiverDriver(app);

            % Type
            taskType = app.TaskType.Value;
            if app.PreviewTaskCheckbox.Value
                taskType = [taskType ' (PRÉVIA)'];
            end
            
            % BitsPerSample
            app.taskList(taskIdx).BitsPerSample = str2double(extractBefore(app.BitsPerPoint.Value, 'bits'));

            % Observation
            switch app.ObservationType.Value
                case 'Duração'
                    if app.Duration.Value == inf
                        durationSeconds = inf;
                        taskStopsAt = '';
                    else
                        switch app.DurationUnit.Value
                            case 'min'
                                durationSeconds = app.Duration.Value * 60;
                            case 'hr'
                                durationSeconds = app.Duration.Value * 3600;
                        end
                        taskStopsAt = datestr(now+seconds(durationSeconds), 'dd/mm/yyyy HH:MM:ss');
                    end

                    app.taskList(taskIdx).Observation = struct( ...
                        'Type', 'Duration', ...
                        'BeginTime', datestr(now, 'dd/mm/yyyy HH:MM:ss'), ...
                        'EndTime', taskStopsAt, ...
                        'Duration', durationSeconds ...
                    );
                    disableObservationSampleLimit(app)

                case 'Período específico'
                    taskStartAt = app.SpecificTime_DatePicker1.Value + hours(app.SpecificTime_Spinner1.Value) + minutes(app.SpecificTime_Spinner2.Value);
                    taskStopsAt  = app.SpecificTime_DatePicker2.Value + hours(app.SpecificTime_Spinner3.Value) + minutes(app.SpecificTime_Spinner4.Value);

                    app.taskList(taskIdx).Observation = struct( ...
                        'Type', 'Time', ...
                        'BeginTime', datestr(taskStartAt, 'dd/mm/yyyy HH:MM:ss'), ...
                        'EndTime', datestr(taskStopsAt,   'dd/mm/yyyy HH:MM:ss'), ...
                        'Duration', [] ...
                    );
                    disableObservationSampleLimit(app)

                case 'Quantidade específica de amostras'
                    app.taskList(taskIdx).Observation = struct( ...
                        'Type', 'Samples', ...
                        'BeginTime', datestr(now, 'dd/mm/yyyy HH:MM:ss'), ...
                        'EndTime', '', ...
                        'Duration', [] ...
                    );
            end

            % GPS
            switch app.GPS_List.Value
                case 'ID 0: Manual'
                    app.taskList(taskIdx).GPS = struct( ...
                        'Type', 'Manual', ...
                        'Latitude', app.GPS_manualLatitude.Value, ...
                        'Longitude', app.GPS_manualLongitude.Value, ...
                        'RevisitTime', [] ...
                    );

                otherwise
                    if strcmp(app.Receiver_List.Value, app.GPS_List.Value)
                        gpsType = 'Built-in';
                    else
                        gpsType = 'External';
                    end

                    app.taskList(taskIdx).GPS = struct( ...
                        'Type', gpsType, ...
                        'Latitude', [], ...
                        'Longitude', [], ...
                        'RevisitTime', app.GPS_RevisitTime.Value ...
                    );
            end

            % SCRIPT
            % Eliminar os valores dos metadados aplicáveis apenas a uma
            % tarefa do tipo "Drive-test (Level+Azimuth)", garantindo que
            % essa informação não seja inserida no arquivo binário.
            if ~contains(taskType, 'Drive-test (Level+Azimuth)')
                for ii = 1:numel(app.taskList(taskIdx).Band)
                    app.taskList(taskIdx).Band(ii).DF_SquelchMode  = '';
                    app.taskList(taskIdx).Band(ii).DF_SquelchValue = [];
                    app.taskList(taskIdx).Band(ii).DF_MeasTime     = [];
                end
            end


            % (C) FINAL OPERATIONS
            try
                % RECEIVER
                idx3 = str2double(char(extractBetween(app.Receiver_List.Value, 'ID', ':')));
                sReceiver = app.receiverObj.List(idx3,:);

                receiverHandle = testInstrumentConnectivity(app, 'receiver');
                if ~isempty(receiverHandle)
                    runningSyncMode = getRunningReceiverSyncMode(app, receiverHandle);

                    if ~isempty(runningSyncMode) && strcmp(app.Receiver_RstCommand.Value, 'On')
                        error([ ...
                            'Na atual tarefa foi definido que no seu início ' ...
                            'deve ser dado o comando de RESET no receptor, o ' ...
                            'que não é permitido quando este receptor já está ' ...
                            'envolvido em tarefa(s) em andamento.' ...
                        ])
                    end

                    if ~isempty(runningSyncMode) && ~strcmp(runningSyncMode, app.Receiver_SyncRef.Value)
                        app.progressDialog.Visible = 'hidden';

                        questionMsg = sprintf([ ...
                            'O receptor selecionado está em uso por tarefa(s) ' ...
                            'em andamento com sincronismo "%s", diferente do ' ...
                            'selecionado ("%s").\n\nDeseja desconsiderar o sincronismo ' ...
                            'selecionado e adotar o das tarefas em andamento?' ...
                        ], runningSyncMode, app.Receiver_SyncRef.Value);
                        
                        userSelection = uiconfirm(app.UIFigure, questionMsg, 'appColeta', 'Options', {'Adotar sincronismo em andamento', 'Cancelar'}, 'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'warning');

                        if strcmp(userSelection, 'Cancelar')
                            return
                        end

                        app.progressDialog.Visible = 'visible';
                        app.Receiver_SyncRef.Value = runningSyncMode;
                    end
                end

                % STREAMING (UDP SOCKET)
                streamHandle = [];
                if receiverDriver.IsStreaming
                    [app.mainApp.udpPortArray, udpIndex] = util.SocketPorts.findOrCreateUdpPort(app.mainApp.udpPortArray, app.mainApp.EB500Obj.udpPort);
                    if ~isempty(udpIndex)
                        streamHandle = app.mainApp.udpPortArray{udpIndex};
                    end
                end

                % GPS
                sGPS = [];
                gpsHandle = [];
                if ~ismember(app.GPS_List.Value, {'ID 0: Manual', app.Receiver_List.Value})
                    idx4 = str2double(char(extractBetween(app.GPS_List.Value, 'ID', ':'))) - numel(app.Receiver_List.Items);
                    sGPS = app.gpsObj.List(idx4,:);

                    gpsHandle = testInstrumentConnectivity(app, 'gps');
                end

                % ANTENNA (MATRIX SWITCH & ANTENNA/LNB POSITION)
                switchIdx = getAntennaSwitchIndex(app, 'default');
                antennaList = app.switchList.Antennas{switchIdx};
                antennaMetaData = struct('Name', {}, 'TrackingMode', {}, 'Target', {}, 'Height', {}, 'Azimuth', {}, 'Elevation', {}, 'Polarization', {});

                for kk = 1:numel(app.AntennaList_Tree.Children)
                    antennaParameters = replace(strsplit(strjoin({app.AntennaList_Tree.Children(kk).Children.Text}, '; '), '; '), '"', '');

                    if any(contains(antennaList, app.AntennaList_Tree.Children(kk).Text))
                        antennaMetaData(end+1,:) = struct( ...
                            'Name',         app.AntennaList_Tree.Children(kk).Text, ...
                            'TrackingMode', antennaParameters{1}, ...
                            'Target',       antennaParameters{2}, ...
                            'Height',       antennaParameters{3}, ...
                            'Azimuth',      antennaParameters{4}, ...
                            'Elevation',    antennaParameters{5}, ...
                            'Polarization', antennaParameters{6} ...
                        );
                    end
                end

                if strcmp(app.AntennaSwitch_Name.Value, 'EMSat')
                    util.AntennaTracking.verifyPointing(app, app.Context, antennaMetaData, app.progressDialog);
                end

            catch ME
                ui.Dialog(app.UIFigure, 'warning', ME.message);
                app.progressDialog.Visible = 'hidden';
                return
            end

            % newTask
            newTask = model.TaskSpec( ...
                taskType, ...
                app.taskList(taskIdx), ...
                app.MaskFile_Button.Tag, ...
                struct('Handle', receiverHandle, 'Selection', sReceiver, 'Config', receiverDriver.Definition, 'Reset', app.Receiver_RstCommand.Value, 'Sync', app.Receiver_SyncRef.Value), ...
                struct('Handle', streamHandle), ...
                struct('Handle', gpsHandle, 'Selection', sGPS), ...
                struct('Switch', struct('Name', app.AntennaSwitch_Name.Value, 'OutputPort', app.switchList.SwitchOutputPort(switchIdx)), 'MetaData', antennaMetaData) ...
            );
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onTaskAddingOrEditing', app.Context, app.infoEdition, newTask)

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
            app.GridLayout.ColumnWidth = {20, 24, 5, 291, 10, 320, 10, '1x', 122, 22, 5, 11, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, 22, 36, '1x', 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {'1x', 110};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Tag = '2';
            app.Toolbar.Layout.Row = 9;
            app.Toolbar.Layout.Column = [1 15];

            % Create ConfirmEditionButtonGrid
            app.ConfirmEditionButtonGrid = uigridlayout(app.GridLayout);
            app.ConfirmEditionButtonGrid.ColumnWidth = {'1x'};
            app.ConfirmEditionButtonGrid.RowHeight = {'1x'};
            app.ConfirmEditionButtonGrid.Padding = [0 10 0 10];
            app.ConfirmEditionButtonGrid.Layout.Row = [8 9];
            app.ConfirmEditionButtonGrid.Layout.Column = [9 12];
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
            app.ConfirmEditionButton.Text = 'Inclui tarefa';

            % Create Panel
            app.Panel = uipanel(app.GridLayout);
            app.Panel.AutoResizeChildren = 'off';
            app.Panel.Layout.Row = [4 7];
            app.Panel.Layout.Column = [8 12];

            % Create Document
            app.Document = uigridlayout(app.Panel);
            app.Document.ColumnWidth = {120, '1x', 22};
            app.Document.RowHeight = {34, 17, 22, 19, 208, 19, 69, 19, 22, '1x'};
            app.Document.ColumnSpacing = 21;
            app.Document.RowSpacing = 5;
            app.Document.Tag = '4';
            app.Document.Scrollable = 'on';
            app.Document.BackgroundColor = [1 1 1];

            % Create Band_SamplesLabel
            app.Band_SamplesLabel = uilabel(app.Document);
            app.Band_SamplesLabel.VerticalAlignment = 'bottom';
            app.Band_SamplesLabel.FontSize = 10;
            app.Band_SamplesLabel.Layout.Row = 2;
            app.Band_SamplesLabel.Layout.Column = 1;
            app.Band_SamplesLabel.Text = 'AMOSTRAS A COLETAR';

            % Create Band_Samples
            app.Band_Samples = uieditfield(app.Document, 'numeric');
            app.Band_Samples.Limits = [-1 Inf];
            app.Band_Samples.RoundFractionalValues = 'on';
            app.Band_Samples.ValueDisplayFormat = '%.0f';
            app.Band_Samples.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_Samples.FontSize = 11;
            app.Band_Samples.Layout.Row = 3;
            app.Band_Samples.Layout.Column = 1;
            app.Band_Samples.Value = -1;

            % Create Band_ReceiverLabel
            app.Band_ReceiverLabel = uilabel(app.Document);
            app.Band_ReceiverLabel.VerticalAlignment = 'bottom';
            app.Band_ReceiverLabel.FontSize = 10;
            app.Band_ReceiverLabel.Layout.Row = 4;
            app.Band_ReceiverLabel.Layout.Column = [1 2];
            app.Band_ReceiverLabel.Text = 'RECEPTOR';

            % Create Band_Refresh
            app.Band_Refresh = uiimage(app.Document);
            app.Band_Refresh.ScaleMethod = 'none';
            app.Band_Refresh.ImageClickedFcn = createCallbackFcn(app, @onBandViewRefreshImageClicked, true);
            app.Band_Refresh.Tooltip = {'Retorna às configurações iniciais'};
            app.Band_Refresh.Layout.Row = 4;
            app.Band_Refresh.Layout.Column = 3;
            app.Band_Refresh.HorizontalAlignment = 'right';
            app.Band_Refresh.VerticalAlignment = 'bottom';
            app.Band_Refresh.ImageSource = 'Refresh_18.png';

            % Create Band_ReceiverPanel
            app.Band_ReceiverPanel = uipanel(app.Document);
            app.Band_ReceiverPanel.AutoResizeChildren = 'off';
            app.Band_ReceiverPanel.Layout.Row = 5;
            app.Band_ReceiverPanel.Layout.Column = [1 3];

            % Create Band_ReceiverGrid
            app.Band_ReceiverGrid = uigridlayout(app.Band_ReceiverPanel);
            app.Band_ReceiverGrid.ColumnWidth = {110, 110, 110};
            app.Band_ReceiverGrid.RowHeight = {17, 22, 0, 17, 22, 17, 22, 17, 22};
            app.Band_ReceiverGrid.RowSpacing = 5;
            app.Band_ReceiverGrid.Padding = [10 10 10 5];
            app.Band_ReceiverGrid.Scrollable = 'on';
            app.Band_ReceiverGrid.BackgroundColor = [1 1 1];

            % Create Band_StepWidthLabel
            app.Band_StepWidthLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_StepWidthLabel.VerticalAlignment = 'bottom';
            app.Band_StepWidthLabel.FontSize = 11;
            app.Band_StepWidthLabel.Layout.Row = 1;
            app.Band_StepWidthLabel.Layout.Column = 1;
            app.Band_StepWidthLabel.Text = 'Passo (kHz):';

            % Create Band_StepWidth1
            app.Band_StepWidth1 = uieditfield(app.Band_ReceiverGrid, 'numeric');
            app.Band_StepWidth1.Limits = [0 Inf];
            app.Band_StepWidth1.ValueDisplayFormat = '%.3f';
            app.Band_StepWidth1.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_StepWidth1.Tag = 'task_Set1';
            app.Band_StepWidth1.Editable = 'off';
            app.Band_StepWidth1.FontSize = 11;
            app.Band_StepWidth1.Layout.Row = 2;
            app.Band_StepWidth1.Layout.Column = 1;

            % Create Band_StepWidth2
            app.Band_StepWidth2 = uidropdown(app.Band_ReceiverGrid);
            app.Band_StepWidth2.Items = {};
            app.Band_StepWidth2.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
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
            app.Band_DataPointsLabel.FontSize = 11;
            app.Band_DataPointsLabel.Layout.Row = 1;
            app.Band_DataPointsLabel.Layout.Column = 2;
            app.Band_DataPointsLabel.Text = 'Pontos:';

            % Create Band_DataPoints1
            app.Band_DataPoints1 = uispinner(app.Band_ReceiverGrid);
            app.Band_DataPoints1.Step = 100;
            app.Band_DataPoints1.Limits = [101 32001];
            app.Band_DataPoints1.RoundFractionalValues = 'on';
            app.Band_DataPoints1.ValueDisplayFormat = '%.0f';
            app.Band_DataPoints1.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
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
            app.Band_SelectivityLabel.FontSize = 11;
            app.Band_SelectivityLabel.Visible = 'off';
            app.Band_SelectivityLabel.Layout.Row = 4;
            app.Band_SelectivityLabel.Layout.Column = 1;
            app.Band_SelectivityLabel.Text = 'Seletividade FFT:';

            % Create Band_Selectivity
            app.Band_Selectivity = uidropdown(app.Band_ReceiverGrid);
            app.Band_Selectivity.Items = {'Normal', 'Narrow', 'Sharp'};
            app.Band_Selectivity.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
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
            app.Band_ResolutionLabel.FontSize = 11;
            app.Band_ResolutionLabel.Layout.Row = 4;
            app.Band_ResolutionLabel.Layout.Column = 1;
            app.Band_ResolutionLabel.Text = 'Resolução:';

            % Create Band_Resolution
            app.Band_Resolution = uidropdown(app.Band_ReceiverGrid);
            app.Band_Resolution.Items = {};
            app.Band_Resolution.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_Resolution.FontSize = 11;
            app.Band_Resolution.BackgroundColor = [1 1 1];
            app.Band_Resolution.Layout.Row = 5;
            app.Band_Resolution.Layout.Column = 1;
            app.Band_Resolution.Value = {};

            % Create Band_VBWLabel
            app.Band_VBWLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_VBWLabel.Tag = 'task_Set1';
            app.Band_VBWLabel.VerticalAlignment = 'bottom';
            app.Band_VBWLabel.FontSize = 11;
            app.Band_VBWLabel.Layout.Row = 4;
            app.Band_VBWLabel.Layout.Column = 2;
            app.Band_VBWLabel.Text = 'VBW:';

            % Create Band_VBW
            app.Band_VBW = uidropdown(app.Band_ReceiverGrid);
            app.Band_VBW.Items = {};
            app.Band_VBW.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_VBW.Tag = 'task_Set1';
            app.Band_VBW.FontSize = 11;
            app.Band_VBW.BackgroundColor = [1 1 1];
            app.Band_VBW.Layout.Row = 5;
            app.Band_VBW.Layout.Column = 2;
            app.Band_VBW.Value = {};

            % Create Band_PreampLabel
            app.Band_PreampLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_PreampLabel.VerticalAlignment = 'bottom';
            app.Band_PreampLabel.FontSize = 11;
            app.Band_PreampLabel.Layout.Row = 6;
            app.Band_PreampLabel.Layout.Column = 1;
            app.Band_PreampLabel.Text = 'Pré-amplificador:';

            % Create Band_Preamp
            app.Band_Preamp = uidropdown(app.Band_ReceiverGrid);
            app.Band_Preamp.Items = {'On', 'Off'};
            app.Band_Preamp.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_Preamp.FontSize = 11;
            app.Band_Preamp.BackgroundColor = [1 1 1];
            app.Band_Preamp.Layout.Row = 7;
            app.Band_Preamp.Layout.Column = 1;
            app.Band_Preamp.Value = 'Off';

            % Create Band_attModeLabel
            app.Band_attModeLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_attModeLabel.VerticalAlignment = 'bottom';
            app.Band_attModeLabel.FontSize = 11;
            app.Band_attModeLabel.Layout.Row = 6;
            app.Band_attModeLabel.Layout.Column = 2;
            app.Band_attModeLabel.Text = 'Modo do atenuador:';

            % Create Band_attMode
            app.Band_attMode = uidropdown(app.Band_ReceiverGrid);
            app.Band_attMode.Items = {'Manual', 'Auto'};
            app.Band_attMode.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_attMode.FontSize = 11;
            app.Band_attMode.BackgroundColor = [1 1 1];
            app.Band_attMode.Layout.Row = 7;
            app.Band_attMode.Layout.Column = 2;
            app.Band_attMode.Value = 'Manual';

            % Create Band_attValueLabel
            app.Band_attValueLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_attValueLabel.VerticalAlignment = 'bottom';
            app.Band_attValueLabel.FontSize = 11;
            app.Band_attValueLabel.Layout.Row = 6;
            app.Band_attValueLabel.Layout.Column = 3;
            app.Band_attValueLabel.Text = 'Atenuador:';

            % Create Band_attValue
            app.Band_attValue = uidropdown(app.Band_ReceiverGrid);
            app.Band_attValue.Items = {};
            app.Band_attValue.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_attValue.FontSize = 11;
            app.Band_attValue.BackgroundColor = [1 1 1];
            app.Band_attValue.Layout.Row = 7;
            app.Band_attValue.Layout.Column = 3;
            app.Band_attValue.Value = {};

            % Create Band_DetectorLabel
            app.Band_DetectorLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_DetectorLabel.VerticalAlignment = 'bottom';
            app.Band_DetectorLabel.FontSize = 11;
            app.Band_DetectorLabel.Layout.Row = 8;
            app.Band_DetectorLabel.Layout.Column = 1;
            app.Band_DetectorLabel.Text = 'Detector:';

            % Create Band_Detector
            app.Band_Detector = uidropdown(app.Band_ReceiverGrid);
            app.Band_Detector.Items = {'Auto Peak', 'Average', 'Negative Peak', 'Positive Peak', 'Quasi Peak', 'RMS', 'Sample'};
            app.Band_Detector.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_Detector.FontSize = 11;
            app.Band_Detector.BackgroundColor = [1 1 1];
            app.Band_Detector.Layout.Row = 9;
            app.Band_Detector.Layout.Column = [1 2];
            app.Band_Detector.Value = 'Positive Peak';

            % Create Band_IntegrationTimeLabel
            app.Band_IntegrationTimeLabel = uilabel(app.Band_ReceiverGrid);
            app.Band_IntegrationTimeLabel.VerticalAlignment = 'bottom';
            app.Band_IntegrationTimeLabel.FontSize = 11;
            app.Band_IntegrationTimeLabel.Layout.Row = 8;
            app.Band_IntegrationTimeLabel.Layout.Column = 3;
            app.Band_IntegrationTimeLabel.Text = 'Integração (ms):';

            % Create Band_IntegrationTime
            app.Band_IntegrationTime = uieditfield(app.Band_ReceiverGrid, 'numeric');
            app.Band_IntegrationTime.Limits = [-1 10000];
            app.Band_IntegrationTime.RoundFractionalValues = 'on';
            app.Band_IntegrationTime.ValueDisplayFormat = '%.0f';
            app.Band_IntegrationTime.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_IntegrationTime.FontSize = 11;
            app.Band_IntegrationTime.Layout.Row = 9;
            app.Band_IntegrationTime.Layout.Column = 3;
            app.Band_IntegrationTime.Value = -1;

            % Create Band_DFLabel
            app.Band_DFLabel = uilabel(app.Document);
            app.Band_DFLabel.VerticalAlignment = 'bottom';
            app.Band_DFLabel.FontSize = 10;
            app.Band_DFLabel.Layout.Row = 6;
            app.Band_DFLabel.Layout.Column = [1 2];
            app.Band_DFLabel.Text = 'DIRECTION FINDER (DF)';

            % Create Band_DFPanel
            app.Band_DFPanel = uipanel(app.Document);
            app.Band_DFPanel.AutoResizeChildren = 'off';
            app.Band_DFPanel.Layout.Row = 7;
            app.Band_DFPanel.Layout.Column = [1 3];

            % Create Band_DFGrid
            app.Band_DFGrid = uigridlayout(app.Band_DFPanel);
            app.Band_DFGrid.ColumnWidth = {110, 110, 110};
            app.Band_DFGrid.RowHeight = {17, 22};
            app.Band_DFGrid.RowSpacing = 5;
            app.Band_DFGrid.Scrollable = 'on';
            app.Band_DFGrid.BackgroundColor = [1 1 1];

            % Create Band_DFSquelchModeLabel
            app.Band_DFSquelchModeLabel = uilabel(app.Band_DFGrid);
            app.Band_DFSquelchModeLabel.VerticalAlignment = 'bottom';
            app.Band_DFSquelchModeLabel.FontSize = 11;
            app.Band_DFSquelchModeLabel.Layout.Row = 1;
            app.Band_DFSquelchModeLabel.Layout.Column = 1;
            app.Band_DFSquelchModeLabel.Text = 'SquelchMode:';

            % Create Band_DFSquelchMode
            app.Band_DFSquelchMode = uidropdown(app.Band_DFGrid);
            app.Band_DFSquelchMode.Items = {'OFF', 'NORM', 'GATE'};
            app.Band_DFSquelchMode.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_DFSquelchMode.Enable = 'off';
            app.Band_DFSquelchMode.FontSize = 10;
            app.Band_DFSquelchMode.BackgroundColor = [1 1 1];
            app.Band_DFSquelchMode.Layout.Row = 2;
            app.Band_DFSquelchMode.Layout.Column = 1;
            app.Band_DFSquelchMode.Value = 'OFF';

            % Create Band_DFSquelchValueLabel
            app.Band_DFSquelchValueLabel = uilabel(app.Band_DFGrid);
            app.Band_DFSquelchValueLabel.VerticalAlignment = 'bottom';
            app.Band_DFSquelchValueLabel.FontSize = 11;
            app.Band_DFSquelchValueLabel.Layout.Row = 1;
            app.Band_DFSquelchValueLabel.Layout.Column = 2;
            app.Band_DFSquelchValueLabel.Text = 'Squelch (dBµV):';

            % Create Band_DFSquelchValue
            app.Band_DFSquelchValue = uispinner(app.Band_DFGrid);
            app.Band_DFSquelchValue.Step = 10;
            app.Band_DFSquelchValue.Limits = [-50 130];
            app.Band_DFSquelchValue.RoundFractionalValues = 'on';
            app.Band_DFSquelchValue.ValueDisplayFormat = '%.0f';
            app.Band_DFSquelchValue.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
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
            app.Band_DFMeasTimeLabel.FontSize = 11;
            app.Band_DFMeasTimeLabel.Layout.Row = 1;
            app.Band_DFMeasTimeLabel.Layout.Column = 3;
            app.Band_DFMeasTimeLabel.Text = 'Integração (ms):';

            % Create Band_DFMeasTime
            app.Band_DFMeasTime = uispinner(app.Band_DFGrid);
            app.Band_DFMeasTime.Step = 100;
            app.Band_DFMeasTime.Limits = [100 10000];
            app.Band_DFMeasTime.RoundFractionalValues = 'on';
            app.Band_DFMeasTime.ValueDisplayFormat = '%.0f';
            app.Band_DFMeasTime.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_DFMeasTime.Tag = 'task_Set1';
            app.Band_DFMeasTime.HorizontalAlignment = 'left';
            app.Band_DFMeasTime.FontSize = 10;
            app.Band_DFMeasTime.Enable = 'off';
            app.Band_DFMeasTime.Layout.Row = 2;
            app.Band_DFMeasTime.Layout.Column = 3;
            app.Band_DFMeasTime.Value = 1000;

            % Create Band_AntenaLabel
            app.Band_AntenaLabel = uilabel(app.Document);
            app.Band_AntenaLabel.VerticalAlignment = 'bottom';
            app.Band_AntenaLabel.FontSize = 10;
            app.Band_AntenaLabel.Layout.Row = 8;
            app.Band_AntenaLabel.Layout.Column = 1;
            app.Band_AntenaLabel.Text = 'ANTENA';

            % Create Band_AntennaPanel
            app.Band_AntennaPanel = uipanel(app.Document);
            app.Band_AntennaPanel.AutoResizeChildren = 'off';
            app.Band_AntennaPanel.Layout.Row = [9 10];
            app.Band_AntennaPanel.Layout.Column = [1 3];

            % Create Band_AntennaGrid
            app.Band_AntennaGrid = uigridlayout(app.Band_AntennaPanel);
            app.Band_AntennaGrid.ColumnWidth = {140, 20, 170};
            app.Band_AntennaGrid.RowHeight = {17, 22};
            app.Band_AntennaGrid.RowSpacing = 5;
            app.Band_AntennaGrid.Scrollable = 'on';
            app.Band_AntennaGrid.BackgroundColor = [1 1 1];

            % Create Band_TargetListLabel
            app.Band_TargetListLabel = uilabel(app.Band_AntennaGrid);
            app.Band_TargetListLabel.VerticalAlignment = 'bottom';
            app.Band_TargetListLabel.FontSize = 11;
            app.Band_TargetListLabel.Layout.Row = 1;
            app.Band_TargetListLabel.Layout.Column = 1;
            app.Band_TargetListLabel.Text = 'Estação alvo:';

            % Create Band_TargetList
            app.Band_TargetList = uidropdown(app.Band_AntennaGrid);
            app.Band_TargetList.Items = {};
            app.Band_TargetList.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_TargetList.Enable = 'off';
            app.Band_TargetList.FontSize = 11;
            app.Band_TargetList.BackgroundColor = [1 1 1];
            app.Band_TargetList.Layout.Row = 2;
            app.Band_TargetList.Layout.Column = [1 2];
            app.Band_TargetList.Value = {};

            % Create Band_AntennaLabel
            app.Band_AntennaLabel = uilabel(app.Band_AntennaGrid);
            app.Band_AntennaLabel.VerticalAlignment = 'bottom';
            app.Band_AntennaLabel.FontSize = 11;
            app.Band_AntennaLabel.Layout.Row = 1;
            app.Band_AntennaLabel.Layout.Column = 3;
            app.Band_AntennaLabel.Text = 'Antena/LNB:';

            % Create Band_Antenna
            app.Band_Antenna = uidropdown(app.Band_AntennaGrid);
            app.Band_Antenna.Items = {};
            app.Band_Antenna.ValueChangedFcn = createCallbackFcn(app, @onBandViewParameterValueChanged, true);
            app.Band_Antenna.Enable = 'off';
            app.Band_Antenna.FontSize = 11;
            app.Band_Antenna.BackgroundColor = [1 1 1];
            app.Band_Antenna.Layout.Row = 2;
            app.Band_Antenna.Layout.Column = 3;
            app.Band_Antenna.Value = {};

            % Create Band_TargetListRefresh
            app.Band_TargetListRefresh = uiimage(app.Band_AntennaGrid);
            app.Band_TargetListRefresh.ScaleMethod = 'none';
            app.Band_TargetListRefresh.ImageClickedFcn = createCallbackFcn(app, @onBandViewTargetListRefreshImageClicked, true);
            app.Band_TargetListRefresh.Enable = 'off';
            app.Band_TargetListRefresh.Layout.Row = 1;
            app.Band_TargetListRefresh.Layout.Column = 2;
            app.Band_TargetListRefresh.HorizontalAlignment = 'right';
            app.Band_TargetListRefresh.VerticalAlignment = 'bottom';
            app.Band_TargetListRefresh.ImageSource = 'Refresh_18.png';

            % Create TaskTitle_2
            app.TaskTitle_2 = uilabel(app.Document);
            app.TaskTitle_2.VerticalAlignment = 'top';
            app.TaskTitle_2.FontColor = [0 0.4471 0.7412];
            app.TaskTitle_2.Layout.Row = 1;
            app.TaskTitle_2.Layout.Column = [1 3];
            app.TaskTitle_2.Interpreter = 'html';
            app.TaskTitle_2.Text = {'<b>Parâmetros configuráveis da faixa selecionada</b>'; '<font style="color: gray; font-size: 10px;">Parâmetros técnicos de aquisição e detecção</font>'};

            % Create TreeIcon
            app.TreeIcon = uiimage(app.GridLayout);
            app.TreeIcon.ScaleMethod = 'none';
            app.TreeIcon.Layout.Row = [4 5];
            app.TreeIcon.Layout.Column = 2;
            app.TreeIcon.VerticalAlignment = 'top';
            app.TreeIcon.ImageSource = 'empty-window-blue.svg';

            % Create TreeTitle
            app.TreeTitle = uilabel(app.GridLayout);
            app.TreeTitle.VerticalAlignment = 'top';
            app.TreeTitle.WordWrap = 'on';
            app.TreeTitle.FontSize = 15;
            app.TreeTitle.FontColor = [0 0.4471 0.7412];
            app.TreeTitle.Layout.Row = [4 6];
            app.TreeTitle.Layout.Column = 4;
            app.TreeTitle.Interpreter = 'html';
            app.TreeTitle.Text = {'<b>Inclui nova tarefa de monitoração</b>'; '<font style="color: gray; font-size: 11px;">Escolha a tarefa e os instrumentos que serão empregados (receptor, GPS, comutador de antena etc)</font>'};

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @onSubTabGroupSelectionChanged, true);
            app.SubTabGroup.Tag = '1';
            app.SubTabGroup.Layout.Row = 7;
            app.SubTabGroup.Layout.Column = [2 4];

            % Create SubTab1
            app.SubTab1 = uitab(app.SubTabGroup);
            app.SubTab1.AutoResizeChildren = 'off';
            app.SubTab1.Title = 'TAREFA';

            % Create SubGrid1
            app.SubGrid1 = uigridlayout(app.SubTab1);
            app.SubGrid1.ColumnWidth = {244, 22, 22};
            app.SubGrid1.RowHeight = {17, 22, 22, 22, 22, 22, 22, 22, '1x'};
            app.SubGrid1.ColumnSpacing = 5;
            app.SubGrid1.RowSpacing = 5;
            app.SubGrid1.BackgroundColor = [1 1 1];

            % Create TaskNameLabel
            app.TaskNameLabel = uilabel(app.SubGrid1);
            app.TaskNameLabel.VerticalAlignment = 'bottom';
            app.TaskNameLabel.FontSize = 10;
            app.TaskNameLabel.Layout.Row = 1;
            app.TaskNameLabel.Layout.Column = 1;
            app.TaskNameLabel.Text = 'NOME:';

            % Create TaskName
            app.TaskName = uidropdown(app.SubGrid1);
            app.TaskName.Items = {};
            app.TaskName.ValueChangedFcn = createCallbackFcn(app, @onTaskValueChanged, true);
            app.TaskName.FontSize = 11;
            app.TaskName.BackgroundColor = [1 1 1];
            app.TaskName.Layout.Row = 2;
            app.TaskName.Layout.Column = [1 3];
            app.TaskName.Value = {};

            % Create TaskTypeLabel
            app.TaskTypeLabel = uilabel(app.SubGrid1);
            app.TaskTypeLabel.VerticalAlignment = 'bottom';
            app.TaskTypeLabel.FontSize = 10;
            app.TaskTypeLabel.Layout.Row = 3;
            app.TaskTypeLabel.Layout.Column = 1;
            app.TaskTypeLabel.Text = 'TIPO:';

            % Create TaskType
            app.TaskType = uidropdown(app.SubGrid1);
            app.TaskType.Items = {'Monitoração regular', 'Drive-test', 'Drive-test (Level+Azimuth)', 'Rompimento de Máscara Espectral'};
            app.TaskType.ValueChangedFcn = createCallbackFcn(app, @onTaskTypeValueChanged, true);
            app.TaskType.FontSize = 11;
            app.TaskType.BackgroundColor = [1 1 1];
            app.TaskType.Layout.Row = 4;
            app.TaskType.Layout.Column = [1 3];
            app.TaskType.Value = 'Monitoração regular';

            % Create AddMaskFile_Button
            app.AddMaskFile_Button = uibutton(app.SubGrid1, 'push');
            app.AddMaskFile_Button.ButtonPushedFcn = createCallbackFcn(app, @onMaskFileButtonPushed, true);
            app.AddMaskFile_Button.Icon = 'folder-opened-16px.svg';
            app.AddMaskFile_Button.BackgroundColor = [0.9804 0.9804 0.9804];
            app.AddMaskFile_Button.Visible = 'off';
            app.AddMaskFile_Button.Tooltip = {'Seleciona arquivo de máscara espectral'};
            app.AddMaskFile_Button.Layout.Row = 4;
            app.AddMaskFile_Button.Layout.Column = 2;
            app.AddMaskFile_Button.Text = '';

            % Create MaskFile_Button
            app.MaskFile_Button = uibutton(app.SubGrid1, 'push');
            app.MaskFile_Button.ButtonPushedFcn = createCallbackFcn(app, @onMaskFileButtonPushed, true);
            app.MaskFile_Button.Icon = 'Mask_32.png';
            app.MaskFile_Button.BackgroundColor = [0.9804 0.9804 0.9804];
            app.MaskFile_Button.Enable = 'off';
            app.MaskFile_Button.Visible = 'off';
            app.MaskFile_Button.Tooltip = {'Visualiza conteúdo do arquivo'};
            app.MaskFile_Button.Layout.Row = 4;
            app.MaskFile_Button.Layout.Column = 3;
            app.MaskFile_Button.Text = '';

            % Create PreviewTaskCheckbox
            app.PreviewTaskCheckbox = uicheckbox(app.SubGrid1);
            app.PreviewTaskCheckbox.Text = 'PRÉVIA (não registra monitoração em arquivo)';
            app.PreviewTaskCheckbox.FontSize = 10;
            app.PreviewTaskCheckbox.Layout.Row = 5;
            app.PreviewTaskCheckbox.Layout.Column = [1 3];

            % Create BitsPerPointLabel
            app.BitsPerPointLabel = uilabel(app.SubGrid1);
            app.BitsPerPointLabel.VerticalAlignment = 'bottom';
            app.BitsPerPointLabel.FontSize = 10;
            app.BitsPerPointLabel.Layout.Row = 6;
            app.BitsPerPointLabel.Layout.Column = 1;
            app.BitsPerPointLabel.Text = 'CODIFICAÇÃO:';

            % Create BitsPerPoint
            app.BitsPerPoint = uidropdown(app.SubGrid1);
            app.BitsPerPoint.Items = {'8 bits', '16 bits', '32 bits'};
            app.BitsPerPoint.FontSize = 11;
            app.BitsPerPoint.BackgroundColor = [1 1 1];
            app.BitsPerPoint.Layout.Row = 7;
            app.BitsPerPoint.Layout.Column = [1 3];
            app.BitsPerPoint.Value = '8 bits';

            % Create ObservationLabel
            app.ObservationLabel = uilabel(app.SubGrid1);
            app.ObservationLabel.VerticalAlignment = 'bottom';
            app.ObservationLabel.FontSize = 10;
            app.ObservationLabel.Layout.Row = 8;
            app.ObservationLabel.Layout.Column = 1;
            app.ObservationLabel.Text = 'PERÍODO DE OBSERVAÇÃO:';

            % Create ObservationPanel
            app.ObservationPanel = uipanel(app.SubGrid1);
            app.ObservationPanel.AutoResizeChildren = 'off';
            app.ObservationPanel.Layout.Row = 9;
            app.ObservationPanel.Layout.Column = [1 3];

            % Create ObservationPanel_Grid
            app.ObservationPanel_Grid = uigridlayout(app.ObservationPanel);
            app.ObservationPanel_Grid.ColumnWidth = {'1x'};
            app.ObservationPanel_Grid.RowHeight = {17, 22, 22, 49};
            app.ObservationPanel_Grid.ColumnSpacing = 11;
            app.ObservationPanel_Grid.RowSpacing = 5;
            app.ObservationPanel_Grid.BackgroundColor = [1 1 1];

            % Create ObservationTypeLabel
            app.ObservationTypeLabel = uilabel(app.ObservationPanel_Grid);
            app.ObservationTypeLabel.VerticalAlignment = 'bottom';
            app.ObservationTypeLabel.FontSize = 11;
            app.ObservationTypeLabel.Layout.Row = 1;
            app.ObservationTypeLabel.Layout.Column = 1;
            app.ObservationTypeLabel.Text = 'Critério de término:';

            % Create ObservationType
            app.ObservationType = uidropdown(app.ObservationPanel_Grid);
            app.ObservationType.Items = {'Duração', 'Período específico', 'Quantidade específica de amostras'};
            app.ObservationType.ValueChangedFcn = createCallbackFcn(app, @onObservationTypeValueChanged, true);
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
            app.Duration.FontSize = 11;
            app.Duration.Layout.Row = 1;
            app.Duration.Layout.Column = 1;
            app.Duration.Value = 10;

            % Create DurationUnit
            app.DurationUnit = uidropdown(app.Duration_Grid);
            app.DurationUnit.Items = {'min', 'hr'};
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

            % Create SubTab2
            app.SubTab2 = uitab(app.SubTabGroup);
            app.SubTab2.AutoResizeChildren = 'off';
            app.SubTab2.Title = 'INSTRUMENTOS';

            % Create SubGrid2
            app.SubGrid2 = uigridlayout(app.SubTab2);
            app.SubGrid2.ColumnWidth = {244, 22, 22};
            app.SubGrid2.RowHeight = {17, 22, 70, 22, 22, '1x'};
            app.SubGrid2.ColumnSpacing = 5;
            app.SubGrid2.RowSpacing = 5;
            app.SubGrid2.BackgroundColor = [1 1 1];

            % Create Receiver_ListLabel
            app.Receiver_ListLabel = uilabel(app.SubGrid2);
            app.Receiver_ListLabel.VerticalAlignment = 'bottom';
            app.Receiver_ListLabel.FontSize = 10;
            app.Receiver_ListLabel.Layout.Row = 1;
            app.Receiver_ListLabel.Layout.Column = 1;
            app.Receiver_ListLabel.Text = 'RECEPTOR:';

            % Create Receiver_List
            app.Receiver_List = uidropdown(app.SubGrid2);
            app.Receiver_List.Items = {};
            app.Receiver_List.ValueChangedFcn = createCallbackFcn(app, @onReceiverValueChanged, true);
            app.Receiver_List.FontSize = 11;
            app.Receiver_List.BackgroundColor = [1 1 1];
            app.Receiver_List.Layout.Row = 2;
            app.Receiver_List.Layout.Column = [1 2];
            app.Receiver_List.Value = {};

            % Create Receiver_Connectivity
            app.Receiver_Connectivity = uibutton(app.SubGrid2, 'push');
            app.Receiver_Connectivity.ButtonPushedFcn = createCallbackFcn(app, @onConnectivityTestButtonPushed, true);
            app.Receiver_Connectivity.Icon = 'Connectivity_32.png';
            app.Receiver_Connectivity.BackgroundColor = [0.9804 0.9804 0.9804];
            app.Receiver_Connectivity.Tooltip = {'Teste de conectividade'};
            app.Receiver_Connectivity.Layout.Row = 2;
            app.Receiver_Connectivity.Layout.Column = 3;
            app.Receiver_Connectivity.Text = '';

            % Create Receiver_Panel
            app.Receiver_Panel = uipanel(app.SubGrid2);
            app.Receiver_Panel.AutoResizeChildren = 'off';
            app.Receiver_Panel.Layout.Row = 3;
            app.Receiver_Panel.Layout.Column = [1 3];

            % Create Receiver_Grid
            app.Receiver_Grid = uigridlayout(app.Receiver_Panel);
            app.Receiver_Grid.RowHeight = {17, 22};
            app.Receiver_Grid.RowSpacing = 5;
            app.Receiver_Grid.BackgroundColor = [1 1 1];

            % Create Receiver_RstCommandLabel
            app.Receiver_RstCommandLabel = uilabel(app.Receiver_Grid);
            app.Receiver_RstCommandLabel.VerticalAlignment = 'bottom';
            app.Receiver_RstCommandLabel.FontSize = 11;
            app.Receiver_RstCommandLabel.Layout.Row = 1;
            app.Receiver_RstCommandLabel.Layout.Column = 1;
            app.Receiver_RstCommandLabel.Text = 'Reset:';

            % Create Receiver_RstCommand
            app.Receiver_RstCommand = uidropdown(app.Receiver_Grid);
            app.Receiver_RstCommand.Items = {'On', 'Off'};
            app.Receiver_RstCommand.FontSize = 11;
            app.Receiver_RstCommand.BackgroundColor = [1 1 1];
            app.Receiver_RstCommand.Layout.Row = 2;
            app.Receiver_RstCommand.Layout.Column = 1;
            app.Receiver_RstCommand.Value = 'On';

            % Create Receiver_SyncRefLabel
            app.Receiver_SyncRefLabel = uilabel(app.Receiver_Grid);
            app.Receiver_SyncRefLabel.VerticalAlignment = 'bottom';
            app.Receiver_SyncRefLabel.FontSize = 11;
            app.Receiver_SyncRefLabel.Layout.Row = 1;
            app.Receiver_SyncRefLabel.Layout.Column = 2;
            app.Receiver_SyncRefLabel.Text = 'Sincronismo:';

            % Create Receiver_SyncRef
            app.Receiver_SyncRef = uidropdown(app.Receiver_Grid);
            app.Receiver_SyncRef.Items = {'Single Sweep', 'Continuous Sweep', 'Streaming'};
            app.Receiver_SyncRef.FontSize = 11;
            app.Receiver_SyncRef.BackgroundColor = [1 1 1];
            app.Receiver_SyncRef.Layout.Row = 2;
            app.Receiver_SyncRef.Layout.Column = 2;
            app.Receiver_SyncRef.Value = 'Single Sweep';

            % Create GPS_ListLabel
            app.GPS_ListLabel = uilabel(app.SubGrid2);
            app.GPS_ListLabel.VerticalAlignment = 'bottom';
            app.GPS_ListLabel.FontSize = 10;
            app.GPS_ListLabel.Layout.Row = 4;
            app.GPS_ListLabel.Layout.Column = 1;
            app.GPS_ListLabel.Text = 'GPS:';

            % Create GPS_List
            app.GPS_List = uidropdown(app.SubGrid2);
            app.GPS_List.Items = {'ID 0: Manual'};
            app.GPS_List.ValueChangedFcn = createCallbackFcn(app, @onGPSValueChanged, true);
            app.GPS_List.FontSize = 11;
            app.GPS_List.BackgroundColor = [1 1 1];
            app.GPS_List.Layout.Row = 5;
            app.GPS_List.Layout.Column = [1 2];
            app.GPS_List.Value = 'ID 0: Manual';

            % Create GPS_FixedStation
            app.GPS_FixedStation = uibutton(app.SubGrid2, 'push');
            app.GPS_FixedStation.ButtonPushedFcn = createCallbackFcn(app, @onGPSPinButtonPushed, true);
            app.GPS_FixedStation.Icon = 'Pin_18.png';
            app.GPS_FixedStation.BackgroundColor = [0.9804 0.9804 0.9804];
            app.GPS_FixedStation.Visible = 'off';
            app.GPS_FixedStation.Tooltip = {'Importa coordenadas geográficas da estação'};
            app.GPS_FixedStation.Layout.Row = 5;
            app.GPS_FixedStation.Layout.Column = 2;
            app.GPS_FixedStation.Text = '';

            % Create GPS_Connectivity
            app.GPS_Connectivity = uibutton(app.SubGrid2, 'push');
            app.GPS_Connectivity.ButtonPushedFcn = createCallbackFcn(app, @onConnectivityTestButtonPushed, true);
            app.GPS_Connectivity.Icon = 'Connectivity_32.png';
            app.GPS_Connectivity.BackgroundColor = [0.9804 0.9804 0.9804];
            app.GPS_Connectivity.Tooltip = {'Teste de conectividade'};
            app.GPS_Connectivity.Layout.Row = 5;
            app.GPS_Connectivity.Layout.Column = 3;
            app.GPS_Connectivity.Text = '';

            % Create GPS_Panel
            app.GPS_Panel = uipanel(app.SubGrid2);
            app.GPS_Panel.AutoResizeChildren = 'off';
            app.GPS_Panel.Layout.Row = 6;
            app.GPS_Panel.Layout.Column = [1 3];

            % Create GPS_Grid
            app.GPS_Grid = uigridlayout(app.GPS_Panel);
            app.GPS_Grid.RowHeight = {17, 22, 22, 22};
            app.GPS_Grid.RowSpacing = 5;
            app.GPS_Grid.BackgroundColor = [1 1 1];

            % Create GPS_manualLatitudeLabel
            app.GPS_manualLatitudeLabel = uilabel(app.GPS_Grid);
            app.GPS_manualLatitudeLabel.VerticalAlignment = 'bottom';
            app.GPS_manualLatitudeLabel.FontSize = 11;
            app.GPS_manualLatitudeLabel.Layout.Row = 1;
            app.GPS_manualLatitudeLabel.Layout.Column = 1;
            app.GPS_manualLatitudeLabel.Text = 'Latitude (°):';

            % Create GPS_manualLatitude
            app.GPS_manualLatitude = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_manualLatitude.ValueDisplayFormat = '%.6f';
            app.GPS_manualLatitude.FontSize = 11;
            app.GPS_manualLatitude.Layout.Row = 2;
            app.GPS_manualLatitude.Layout.Column = 1;
            app.GPS_manualLatitude.Value = -1;

            % Create GPS_manualLongitudeLabel
            app.GPS_manualLongitudeLabel = uilabel(app.GPS_Grid);
            app.GPS_manualLongitudeLabel.VerticalAlignment = 'bottom';
            app.GPS_manualLongitudeLabel.FontSize = 11;
            app.GPS_manualLongitudeLabel.Layout.Row = 1;
            app.GPS_manualLongitudeLabel.Layout.Column = 2;
            app.GPS_manualLongitudeLabel.Text = 'Longitude (º):';

            % Create GPS_manualLongitude
            app.GPS_manualLongitude = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_manualLongitude.ValueDisplayFormat = '%.6f';
            app.GPS_manualLongitude.FontSize = 11;
            app.GPS_manualLongitude.Layout.Row = 2;
            app.GPS_manualLongitude.Layout.Column = 2;
            app.GPS_manualLongitude.Value = -1;

            % Create GPS_RevisitTimeLabel
            app.GPS_RevisitTimeLabel = uilabel(app.GPS_Grid);
            app.GPS_RevisitTimeLabel.VerticalAlignment = 'bottom';
            app.GPS_RevisitTimeLabel.FontSize = 11;
            app.GPS_RevisitTimeLabel.Layout.Row = 3;
            app.GPS_RevisitTimeLabel.Layout.Column = 1;
            app.GPS_RevisitTimeLabel.Text = 'Tempo revisita (seg):';

            % Create GPS_RevisitTime
            app.GPS_RevisitTime = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_RevisitTime.Limits = [1 Inf];
            app.GPS_RevisitTime.ValueDisplayFormat = '%.3f';
            app.GPS_RevisitTime.FontSize = 11;
            app.GPS_RevisitTime.Layout.Row = 4;
            app.GPS_RevisitTime.Layout.Column = 1;
            app.GPS_RevisitTime.Value = 60;

            % Create SubTab3
            app.SubTab3 = uitab(app.SubTabGroup);
            app.SubTab3.AutoResizeChildren = 'off';
            app.SubTab3.Title = 'ANTENAS';

            % Create SubGrid3
            app.SubGrid3 = uigridlayout(app.SubTab3);
            app.SubGrid3.ColumnWidth = {270, 18};
            app.SubGrid3.RowHeight = {17, 22, 22, 22, 178, 18, '1x'};
            app.SubGrid3.RowSpacing = 5;
            app.SubGrid3.BackgroundColor = [1 1 1];

            % Create AntennaSwitch_Mode
            app.AntennaSwitch_Mode = uicheckbox(app.SubGrid3);
            app.AntennaSwitch_Mode.ValueChangedFcn = createCallbackFcn(app, @onAntennaSwitchModeValueChanged, true);
            app.AntennaSwitch_Mode.Text = 'Comutador de antenas:';
            app.AntennaSwitch_Mode.FontSize = 11;
            app.AntennaSwitch_Mode.Layout.Row = 1;
            app.AntennaSwitch_Mode.Layout.Column = 1;

            % Create AntennaSwitch_Name
            app.AntennaSwitch_Name = uieditfield(app.SubGrid3, 'text');
            app.AntennaSwitch_Name.Editable = 'off';
            app.AntennaSwitch_Name.FontSize = 11;
            app.AntennaSwitch_Name.Enable = 'off';
            app.AntennaSwitch_Name.Layout.Row = 2;
            app.AntennaSwitch_Name.Layout.Column = [1 2];

            % Create AntennaNameLabel
            app.AntennaNameLabel = uilabel(app.SubGrid3);
            app.AntennaNameLabel.VerticalAlignment = 'bottom';
            app.AntennaNameLabel.FontSize = 10;
            app.AntennaNameLabel.Layout.Row = 3;
            app.AntennaNameLabel.Layout.Column = 1;
            app.AntennaNameLabel.Text = 'ANTENA';

            % Create AntennaName
            app.AntennaName = uidropdown(app.SubGrid3);
            app.AntennaName.Items = {'', 'CRFS Low Band (10 MHz - 1.2 GHz)', 'CRFS High Band (750 MHz - 6 GHz)', 'Rohde & Schwarz ADDx07 (EB500 GUI Auto)', 'Rohde & Schwarz ADD107 (20 MHz - 1.3 GHz)', 'Rohde & Schwarz ADD207 (600 MHz - 6 GHz)', 'Rohde & Schwarz ADD295 (20 MHz - 3 GHz)', 'Telescopic', 'Unlisted (Omni)', 'Unlisted (Directional)'};
            app.AntennaName.ValueChangedFcn = createCallbackFcn(app, @onAntennaNameValueChanged, true);
            app.AntennaName.FontSize = 11;
            app.AntennaName.BackgroundColor = [1 1 1];
            app.AntennaName.Layout.Row = 4;
            app.AntennaName.Layout.Column = [1 2];
            app.AntennaName.Value = '';

            % Create Antenna_Panel
            app.Antenna_Panel = uipanel(app.SubGrid3);
            app.Antenna_Panel.AutoResizeChildren = 'off';
            app.Antenna_Panel.Layout.Row = 5;
            app.Antenna_Panel.Layout.Column = [1 2];

            % Create Antenna_Grid
            app.Antenna_Grid = uigridlayout(app.Antenna_Panel);
            app.Antenna_Grid.RowHeight = {17, 22, 22, 22, 22, 22};
            app.Antenna_Grid.RowSpacing = 5;
            app.Antenna_Grid.BackgroundColor = [1 1 1];

            % Create Antenna_TrackingModeLabel
            app.Antenna_TrackingModeLabel = uilabel(app.Antenna_Grid);
            app.Antenna_TrackingModeLabel.VerticalAlignment = 'bottom';
            app.Antenna_TrackingModeLabel.FontSize = 11;
            app.Antenna_TrackingModeLabel.Layout.Row = 1;
            app.Antenna_TrackingModeLabel.Layout.Column = [1 2];
            app.Antenna_TrackingModeLabel.Text = 'Apontamento:';

            % Create Antenna_TrackingMode
            app.Antenna_TrackingMode = uidropdown(app.Antenna_Grid);
            app.Antenna_TrackingMode.Items = {'Target', 'LookAngles', 'Manual'};
            app.Antenna_TrackingMode.ValueChangedFcn = createCallbackFcn(app, @onAntennaTrackingModeValueChanged, true);
            app.Antenna_TrackingMode.FontSize = 11;
            app.Antenna_TrackingMode.BackgroundColor = [1 1 1];
            app.Antenna_TrackingMode.Layout.Row = 2;
            app.Antenna_TrackingMode.Layout.Column = [1 2];
            app.Antenna_TrackingMode.Value = 'Manual';

            % Create AntennaHeightLabel
            app.AntennaHeightLabel = uilabel(app.Antenna_Grid);
            app.AntennaHeightLabel.VerticalAlignment = 'bottom';
            app.AntennaHeightLabel.FontSize = 11;
            app.AntennaHeightLabel.Layout.Row = 3;
            app.AntennaHeightLabel.Layout.Column = 1;
            app.AntennaHeightLabel.Text = 'Altura de instalação (m):';

            % Create AntennaHeight
            app.AntennaHeight = uieditfield(app.Antenna_Grid, 'numeric');
            app.AntennaHeight.Limits = [0 127];
            app.AntennaHeight.RoundFractionalValues = 'on';
            app.AntennaHeight.ValueDisplayFormat = '%.0f';
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
            app.AntennaAzimuthLabel.FontSize = 11;
            app.AntennaAzimuthLabel.Layout.Row = 1;
            app.AntennaAzimuthLabel.Layout.Column = 1;
            app.AntennaAzimuthLabel.Text = 'Azimute (º):';

            % Create AntennaAzimuth
            app.AntennaAzimuth = uieditfield(app.AntennaAzimuth_Grid, 'numeric');
            app.AntennaAzimuth.Limits = [0 360];
            app.AntennaAzimuth.ValueDisplayFormat = '%.3f';
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
            app.AntennaElevationLabel.FontSize = 11;
            app.AntennaElevationLabel.Layout.Row = 5;
            app.AntennaElevationLabel.Layout.Column = 1;
            app.AntennaElevationLabel.Text = 'Elevação (º):';

            % Create AntennaElevation
            app.AntennaElevation = uieditfield(app.Antenna_Grid, 'numeric');
            app.AntennaElevation.Limits = [0 90];
            app.AntennaElevation.ValueDisplayFormat = '%.3f';
            app.AntennaElevation.FontSize = 11;
            app.AntennaElevation.Enable = 'off';
            app.AntennaElevation.Layout.Row = 6;
            app.AntennaElevation.Layout.Column = 1;

            % Create AntennaPolarizationLabel
            app.AntennaPolarizationLabel = uilabel(app.Antenna_Grid);
            app.AntennaPolarizationLabel.VerticalAlignment = 'bottom';
            app.AntennaPolarizationLabel.FontSize = 11;
            app.AntennaPolarizationLabel.Layout.Row = 5;
            app.AntennaPolarizationLabel.Layout.Column = 2;
            app.AntennaPolarizationLabel.Text = 'Polarização (º):';

            % Create AntennaPolarization
            app.AntennaPolarization = uieditfield(app.Antenna_Grid, 'numeric');
            app.AntennaPolarization.Limits = [0 360];
            app.AntennaPolarization.ValueDisplayFormat = '%.1f';
            app.AntennaPolarization.FontSize = 11;
            app.AntennaPolarization.Enable = 'off';
            app.AntennaPolarization.Layout.Row = 6;
            app.AntennaPolarization.Layout.Column = 2;

            % Create AddAntenna_Image
            app.AddAntenna_Image = uiimage(app.SubGrid3);
            app.AddAntenna_Image.ScaleMethod = 'none';
            app.AddAntenna_Image.ImageClickedFcn = createCallbackFcn(app, @onAntennaAddButtonClicked, true);
            app.AddAntenna_Image.Layout.Row = 6;
            app.AddAntenna_Image.Layout.Column = 2;
            app.AddAntenna_Image.ImageSource = 'Add_16.png';

            % Create AntennaList_Tree
            app.AntennaList_Tree = uitree(app.SubGrid3);
            app.AntennaList_Tree.FontSize = 10.5;
            app.AntennaList_Tree.Layout.Row = 7;
            app.AntennaList_Tree.Layout.Column = [1 2];

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Tag = '5';
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [10 14];
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

            % Create Panel_2
            app.Panel_2 = uipanel(app.GridLayout);
            app.Panel_2.BorderColor = [0.9412 0.9412 0.9412];
            app.Panel_2.Layout.Row = [4 7];
            app.Panel_2.Layout.Column = 6;

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel_2);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {34, 17, 259, 19, '1x'};
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create TaskTitle
            app.TaskTitle = uilabel(app.GridLayout2);
            app.TaskTitle.VerticalAlignment = 'top';
            app.TaskTitle.FontColor = [0 0.4471 0.7412];
            app.TaskTitle.Layout.Row = 1;
            app.TaskTitle.Layout.Column = 1;
            app.TaskTitle.Interpreter = 'html';
            app.TaskTitle.Text = {'<b>Faixas de frequência da tarefa selecionada</b>'; '<font style="color: gray; font-size: 10px;">Visualização das faixas e dos seus parâmetros de configuração</font>'};

            % Create Band_Tree
            app.Band_Tree = uitree(app.GridLayout2);
            app.Band_Tree.SelectionChangedFcn = createCallbackFcn(app, @onBandViewTreeSelectionChanged, true);
            app.Band_Tree.FontSize = 11;
            app.Band_Tree.FontColor = [0.2 0.2 0.2];
            app.Band_Tree.Layout.Row = 3;
            app.Band_Tree.Layout.Column = 1;

            % Create Band_TreeLabel
            app.Band_TreeLabel = uilabel(app.GridLayout2);
            app.Band_TreeLabel.VerticalAlignment = 'bottom';
            app.Band_TreeLabel.WordWrap = 'on';
            app.Band_TreeLabel.FontSize = 10;
            app.Band_TreeLabel.Layout.Row = 2;
            app.Band_TreeLabel.Layout.Column = 1;
            app.Band_TreeLabel.Text = 'FAIXAS DE FREQUÊNCIA';

            % Create MetaDataLabel
            app.MetaDataLabel = uilabel(app.GridLayout2);
            app.MetaDataLabel.VerticalAlignment = 'bottom';
            app.MetaDataLabel.WordWrap = 'on';
            app.MetaDataLabel.FontSize = 10;
            app.MetaDataLabel.FontColor = [0.149 0.149 0.149];
            app.MetaDataLabel.Layout.Row = 4;
            app.MetaDataLabel.Layout.Column = 1;
            app.MetaDataLabel.Text = 'PARÂMETROS DE CONFIGURAÇÃO';

            % Create MetaData
            app.MetaData = uilabel(app.GridLayout2);
            app.MetaData.VerticalAlignment = 'top';
            app.MetaData.WordWrap = 'on';
            app.MetaData.FontSize = 11;
            app.MetaData.Layout.Row = 5;
            app.MetaData.Layout.Column = 1;
            app.MetaData.Interpreter = 'html';
            app.MetaData.Text = '';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winAddTask';

            % Create contextmenu_DelAntennaEntry
            app.contextmenu_DelAntennaEntry = uimenu(app.ContextMenu);
            app.contextmenu_DelAntennaEntry.MenuSelectedFcn = createCallbackFcn(app, @onAntennaDelButtonClicked, true);
            app.contextmenu_DelAntennaEntry.Text = '❌ Excluir';

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
