classdef winAddTask_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                    matlab.ui.Figure
        GridLayout                  matlab.ui.container.GridLayout
        DockModule                  matlab.ui.container.GridLayout
        DockCloseButton             matlab.ui.control.Image
        DockUndockButton            matlab.ui.control.Image
        ConfirmEditionButtonGrid    matlab.ui.container.GridLayout
        ConfirmEditionButton        matlab.ui.control.Button
        Toolbar                     matlab.ui.container.GridLayout
        BandParametersPanel         matlab.ui.container.Panel
        BandParametersGrid          matlab.ui.container.GridLayout
        BandAntennaPanel            matlab.ui.container.Panel
        BandAntennaGrid             matlab.ui.container.GridLayout
        BandAntenna                 matlab.ui.control.DropDown
        BandAntennaLabel            matlab.ui.control.Label
        BandTarget                  matlab.ui.control.DropDown
        BandTargetRefreshButton     matlab.ui.control.Image
        BandTargetLabel             matlab.ui.control.Label
        BandAntennaSectionLabel     matlab.ui.control.Label
        BandDFPanel                 matlab.ui.container.Panel
        BandDFGrid                  matlab.ui.container.GridLayout
        BandDFMeasTime              matlab.ui.control.Spinner
        BandDFMeasTimeLabel         matlab.ui.control.Label
        BandDFSquelchValue          matlab.ui.control.Spinner
        BandDFSquelchValueLabel     matlab.ui.control.Label
        BandDFSquelchMode           matlab.ui.control.DropDown
        BandDFSquelchModeLabel      matlab.ui.control.Label
        BandDFSectionLabel          matlab.ui.control.Label
        BandReceiverPanel           matlab.ui.container.Panel
        BandReceiverGrid            matlab.ui.container.GridLayout
        BandIntegrationTime         matlab.ui.control.NumericEditField
        BandIntegrationTimeLabel    matlab.ui.control.Label
        BandDetector                matlab.ui.control.DropDown
        BandDetectorLabel           matlab.ui.control.Label
        BandAttenuation             matlab.ui.control.DropDown
        BandAttenuationLabel        matlab.ui.control.Label
        BandAttenuationMode         matlab.ui.control.DropDown
        BandAttenuationModeLabel    matlab.ui.control.Label
        BandPreamp                  matlab.ui.control.DropDown
        BandPreampLabel             matlab.ui.control.Label
        BandVBW                     matlab.ui.control.DropDown
        BandVBWLabel                matlab.ui.control.Label
        BandResolution              matlab.ui.control.DropDown
        BandResolutionLabel         matlab.ui.control.Label
        BandSelectivity             matlab.ui.control.DropDown
        BandSelectivityLabel        matlab.ui.control.Label
        BandDataPoints2             matlab.ui.control.NumericEditField
        BandDataPoints1             matlab.ui.control.Spinner
        BandDataPointsLabel         matlab.ui.control.Label
        BandStepWidth2              matlab.ui.control.DropDown
        BandStepWidth1              matlab.ui.control.NumericEditField
        BandStepWidthLabel          matlab.ui.control.Label
        BandRefreshButton           matlab.ui.control.Image
        BandReceiverSectionLabel    matlab.ui.control.Label
        BandSamples                 matlab.ui.control.NumericEditField
        BandSamplesLabel            matlab.ui.control.Label
        BandParametersTitle         matlab.ui.control.Label
        BandTreePanel               matlab.ui.container.Panel
        BandTreeGrid                matlab.ui.container.GridLayout
        BandMetaData                matlab.ui.control.Label
        BandMetaDataLabel           matlab.ui.control.Label
        BandTree                    matlab.ui.container.Tree
        BandTreeLabel               matlab.ui.control.Label
        BandTreeTitle               matlab.ui.control.Label
        SubTabGroup                 matlab.ui.container.TabGroup
        TaskTab                     matlab.ui.container.Tab
        TaskTabGrid                 matlab.ui.container.GridLayout
        ObservationPanel            matlab.ui.container.Panel
        ObservationPanelGrid        matlab.ui.container.GridLayout
        SpecificTimeGrid            matlab.ui.container.GridLayout
        EndTimeMinuteSpinner        matlab.ui.control.Spinner
        EndTimeSeparator            matlab.ui.control.Label
        EndTimeHourSpinner          matlab.ui.control.Spinner
        EndDatePicker               matlab.ui.control.DatePicker
        StartTimeMinuteSpinner      matlab.ui.control.Spinner
        StartTimeSeparator          matlab.ui.control.Label
        StartTimeHourSpinner        matlab.ui.control.Spinner
        StartDatePicker             matlab.ui.control.DatePicker
        DurationGrid                matlab.ui.container.GridLayout
        DurationUnit                matlab.ui.control.DropDown
        Duration                    matlab.ui.control.NumericEditField
        ObservationType             matlab.ui.control.DropDown
        ObservationTypeLabel        matlab.ui.control.Label
        ObservationLabel            matlab.ui.control.Label
        BitsPerPoint                matlab.ui.control.DropDown
        BitsPerPointLabel           matlab.ui.control.Label
        PreviewTaskCheckbox         matlab.ui.control.CheckBox
        MaskFileViewButton          matlab.ui.control.Button
        MaskFileAddButton           matlab.ui.control.Button
        TaskType                    matlab.ui.control.DropDown
        TaskTypeLabel               matlab.ui.control.Label
        TaskName                    matlab.ui.control.DropDown
        TaskNameLabel               matlab.ui.control.Label
        InstrumentsTab              matlab.ui.container.Tab
        InstrumentsTabGrid          matlab.ui.container.GridLayout
        GpsParametersPanel          matlab.ui.container.Panel
        GpsParametersGrid           matlab.ui.container.GridLayout
        GpsRevisitTime              matlab.ui.control.NumericEditField
        GpsRevisitTimeLabel         matlab.ui.control.Label
        GpsLongitude                matlab.ui.control.NumericEditField
        GpsLongitudeLabel           matlab.ui.control.Label
        GpsLatitude                 matlab.ui.control.NumericEditField
        GpsLatitudeLabel            matlab.ui.control.Label
        GpsConnectivityButton       matlab.ui.control.Button
        GpsImportStationButton      matlab.ui.control.Button
        GPSList                     matlab.ui.control.DropDown
        GpsListLabel                matlab.ui.control.Label
        ReceiverOptionsPanel        matlab.ui.container.Panel
        ReceiverOptionsGrid         matlab.ui.container.GridLayout
        ReceiverSyncMode            matlab.ui.control.DropDown
        ReceiverSyncModeLabel       matlab.ui.control.Label
        ReceiverResetCommand        matlab.ui.control.DropDown
        ReceiverResetCommandLabel   matlab.ui.control.Label
        ReceiverConnectivityButton  matlab.ui.control.Button
        ReceiverList                matlab.ui.control.DropDown
        ReceiverListLabel           matlab.ui.control.Label
        AntennasTab                 matlab.ui.container.Tab
        AntennasTabGrid             matlab.ui.container.GridLayout
        AntennaTree                 matlab.ui.container.Tree
        AntennaAddButton            matlab.ui.control.Image
        AntennaParametersPanel      matlab.ui.container.Panel
        AntennaParametersGrid       matlab.ui.container.GridLayout
        AntennaPolarization         matlab.ui.control.NumericEditField
        AntennaPolarizationLabel    matlab.ui.control.Label
        AntennaElevation            matlab.ui.control.NumericEditField
        AntennaElevationLabel       matlab.ui.control.Label
        AntennaAzimuthGrid          matlab.ui.container.GridLayout
        AntennaAzimuthReference     matlab.ui.control.DropDown
        AntennaAzimuth              matlab.ui.control.NumericEditField
        AntennaAzimuthLabel         matlab.ui.control.Label
        AntennaHeight               matlab.ui.control.NumericEditField
        AntennaHeightLabel          matlab.ui.control.Label
        AntennaTrackingMode         matlab.ui.control.DropDown
        AntennaTrackingModeLabel    matlab.ui.control.Label
        AntennaName                 matlab.ui.control.DropDown
        AntennaNameLabel            matlab.ui.control.Label
        AntennaSwitchName           matlab.ui.control.EditField
        AntennaSwitchCheckBox       matlab.ui.control.CheckBox
        HeaderTitle                 matlab.ui.control.Label
        HeaderIcon                  matlab.ui.control.Image
        ContextMenu                 matlab.ui.container.ContextMenu
        AntennaDelMenu              matlab.ui.container.Menu
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'TASK_ADD'
        AntennaSwitchReceiver = ''
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false

        mainApp
        jsBackDoor
        progressDialog
        popupContainer

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
                        app.BandMetaData;
                        app.ConfirmEditionButtonGrid;
                        app.DockUndockButton;
                        app.DockCloseButton
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        ui.TextView.startup(app.jsBackDoor, app.BandMetaData, appName);
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
                    ui.CustomizationBase.getElementsDataTag({app.AntennaTree});
                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.AntennaTree.UserData.id, 'listener', struct('componentName', 'auxApp.winAddTask.AntennaTree', 'keyEvents', {{'Delete', 'Backspace'}})) ...
                        });
                    catch
                    end

                    addStyle(app.AntennaTree, uistyle('Interpreter', 'html'))
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

            app.BandTreePanel.BorderColor = [0.9412 0.9412 0.9412];
            app.BandParametersPanel.BorderColor = [0.9412 0.9412 0.9412];
        end

        %-----------------------------------------------------------------%
        function applyInitialLayout(app)
            initializeBandFields(app)

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
            app.ReceiverList.Items = receiverList;

            % Caso se trate da edição de uma tarefa, seleciona-se o receptor
            % em uso, caso ainda disponível.
            if strcmp(app.infoEdition.type, 'edit')    
                selectedReceiverSocket = getReceiverEndpoint(app, app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Receiver.Selection.Parameters{1});
                selectedReceiverName   = sprintf('%s - %s', app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Receiver.Selection.Name{1}, selectedReceiverSocket);
                selectedReceiverIndex  = find(contains(receiverList, selectedReceiverName), 1);

                if ~isempty(selectedReceiverIndex)
                    app.ReceiverList.Value = app.ReceiverList.Items{selectedReceiverIndex};
                end
            end

            % ## TAREFAS ##
            % A tarefa padrão é a primeira, com ressalva que no caso de uma
            % edição de uma tarefa, a lista terá uma única tarefa. app.taskList 
            % é criada no startupFcn desse app.
            app.TaskName.Items = {app.taskList.Name};

            if strcmp(app.infoEdition.type, 'edit')
                editedTaskSpec = app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec;

                app.TaskType.Value = replace(editedTaskSpec.Type, ' (PRÉVIA)', '');
                if strcmp(app.TaskType.Value, 'Rompimento de Máscara Espectral')
                    app.MaskFileViewButton.Tag = editedTaskSpec.MaskFile;
                end

                % Os parâmetros do receptor salvos na tarefa são mantidos enquanto o
                % receptor (ou o tipo de tarefa, no caso do EB500) não for alterado.
                receiverKey = buildReceiverKey(app, editedTaskSpec.Receiver.Selection.Name{1}, editedTaskSpec.Type);
                for taskIdx = 1:numel(app.taskList)
                    for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                        app.taskList(taskIdx).Band(bandIdx).instrReceiverKey = receiverKey;
                    end
                end

                hasSwitch = ~isempty(getAntennaSwitchIndex(app, 'ReceiverChanged'));
                app.AntennaSwitchCheckBox.Value = hasSwitch && ~isempty(editedTaskSpec.Antenna.Switch.Name);
                app.AntennaSwitchReceiver    = getSelectedReceiverName(app);

                if contains(app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Type, '(PRÉVIA)')                    
                    app.PreviewTaskCheckbox.Value = true;
                end                
                onTaskValueChanged(app)

                app.ReceiverResetCommand.Value = editedTaskSpec.Receiver.Reset;
                if ismember(editedTaskSpec.Receiver.Sync, app.ReceiverSyncMode.Items)
                    app.ReceiverSyncMode.Value = editedTaskSpec.Receiver.Sync;
                end

                % O GPS manual é restaurado a partir do Script da tarefa (vide updateTaskContent).
                if strcmp(editedTaskSpec.Script.GPS.Type, 'External') && ~isempty(editedTaskSpec.GPS.Selection)
                    gpsLabel = sprintf('%s - %s', editedTaskSpec.GPS.Selection.Name{1}, getReceiverEndpoint(app, editedTaskSpec.GPS.Selection.Parameters{1}));
                    gpsIndex = find(endsWith(app.GPSList.Items, gpsLabel), 1);

                    if ~isempty(gpsIndex)
                        app.GPSList.Value = app.GPSList.Items{gpsIndex};
                        updateGpsRevisitContent(app)
                        updateUIControlState(app)
                    end
                end

                % Os nós são restaurados diretamente dos metadados salvos, sem passar pelos controles da GUI.
                antennaList = app.mainApp.TaskController.Tasks(app.infoEdition.idx).TaskSpec.Antenna.MetaData;

                switch app.AntennaSwitchName.Value
                    case 'EMSat'
                        antennaNameList = extractBefore(app.AntennaName.Items, ' ');
                    otherwise
                        antennaNameList = app.AntennaName.Items;
                end

                for kk = 1:numel(antennaList)
                    if ismember(antennaList(kk).Name, antennaNameList)
                        upsertAntennaNode(app, antennaList(kk))
                    end
                end
                updateUIControlContent(app, 'band')
                updateUIControlState(app)

            else
                onTaskValueChanged(app)
            end

            % Visibilidade do botão "Pin", que possibilita importação das 
            % coordenadas geográficas da estação.
            if strcmp(app.mainApp.General.context.CONFIG.station.type, 'Fixed')  && ...
                    (app.mainApp.General.context.CONFIG.station.latitude  ~= -1) && ...
                    (app.mainApp.General.context.CONFIG.station.longitude ~= -1)
                app.GPSList.Layout.Column   = 1;
                app.GpsImportStationButton.Visible = true;
            else
                app.GPSList.Layout.Column   = [1,2];
                app.GpsImportStationButton.Visible = false;
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
        
                    idx1 = str2double(char(extractBetween(app.ReceiverList.Value, 'ID', ':')));
                    idx2 = find(strcmp(app.receiverObj.Config.Name, receiverName), 1);
        
                    receiverConfig = struct( ...
                        'Type', app.receiverObj.List.Type{idx1},  ...
                        'Tag', app.receiverObj.Config.Tag{idx2}, ...
                        'Parameters', jsondecode(app.receiverObj.List.Parameters{idx1}) ...
                    );
        
                    [receiverHandle, notification] = testConnectivity(app.receiverObj, receiverConfig, emitNotification);
                    varargout = {receiverHandle};

                case 'gps'
                    idx1 = str2double(char(extractBetween(app.GPSList.Value, 'ID', ':'))) - numel(app.ReceiverList.Items);
        
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
        function releaseAntennaTarget(app)
            app.AntennaTrackingMode.Items = {'LookAngles', 'Manual'};
            app.BandTarget.Value = '';
            
            initialAntenna = app.BandAntenna.Value;
            switchIndex    = getAntennaSwitchIndex(app, 'default');
            set(app.BandAntenna, 'Items', app.switchList.Antennas{switchIndex}, 'Value', initialAntenna)
        end

        %-----------------------------------------------------------------%
        function buildTreeBands(app, taskIdx, selectedBandIdx)
            delete(app.BandTree.Children);

            for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                bandNode = uitreenode(app.BandTree, 'Text', getFlowTag(app, taskIdx, bandIdx), 'NodeData', bandIdx, 'Icon', 'Playback_32.png');

                if strcmp(app.TaskType.Value, 'Rompimento de Máscara Espectral') && app.taskList(taskIdx).Band(bandIdx).MaskTrigger.Status
                    bandNode.Icon = "Occupancy_32.png";
                end
            end

            if (nargin < 3) || (selectedBandIdx > numel(app.BandTree.Children))
                selectedBandIdx = 1;
            end
            app.BandTree.SelectedNodes = app.BandTree.Children(selectedBandIdx);
            applyBandTreeStyle(app)
        end

        %-----------------------------------------------------------------%
        function applyBandTreeStyle(app)
            if ~isempty(app.BandTree.StyleConfigurations)
                removeStyle(app.BandTree)
            end

            addStyle(app.BandTree, uistyle('FontWeight', 'bold'), 'node', app.BandTree.SelectedNodes)
        end
        
        %-----------------------------------------------------------------%
        function tag = getFlowTag(app, taskIdx, bandIdx)
            tag = util.HtmlTextGenerator.createTag('Flow', app.taskList(taskIdx).Band(bandIdx).FreqStart, app.taskList(taskIdx).Band(bandIdx).FreqStop, app.taskList(taskIdx).Band(bandIdx).ID);
        end

        %-----------------------------------------------------------------%
        function updateBandAntennaItems(app)            
            if isempty(app.BandTarget.Value)
                switchIndex = getAntennaSwitchIndex(app, 'default');

                switch app.AntennaSwitchName.Value                    
                    case 'EMSat'
                        set(app.BandAntenna, 'Items', app.switchList.Antennas{switchIndex}, 'Value', '')

                    case 'ERMx'
                        app.BandAntenna.Items = app.switchList.Antennas{switchIndex};
                end
                
            else
                tgtList = app.EMSatObj.TargetList;
                lnbList = app.EMSatObj.LNB;

                filteredList = {};
                for ii = 1:numel(tgtList)
                    if ~isempty(tgtList(ii).Target)
                        idx1 = find(string({tgtList(ii).Target.Name}) == app.BandTarget.Value, 1);
                        if ~isempty(idx1)
                            idx2 = find(contains(lnbList.Name, tgtList(ii).Name));
                            filteredList = [filteredList; lnbList.Name(idx2)];
                        end
                    end
                end
                set(app.BandAntenna, 'Items', [{''}; filteredList], 'Value', '')
            end
        end

        %-----------------------------------------------------------------%
        function updateAntennaTargetValues(app)
            idx1 = find(strcmp({app.EMSatObj.Antenna.Name}, extractBefore(app.BandAntenna.Value, ' ')), 1);
            idx2 = find(strcmp({app.EMSatObj.TargetList(idx1).Target.Name}, app.BandTarget.Value), 1);

            app.AntennaAzimuth.Value      = app.EMSatObj.TargetList(idx1).Target(idx2).Azimuth;
            app.AntennaElevation.Value    = app.EMSatObj.TargetList(idx1).Target(idx2).Elevation;
            app.AntennaPolarization.Value = app.EMSatObj.TargetList(idx1).Target(idx2).Polarization;
        end

        %-----------------------------------------------------------------%
        function updateReceiverParametersState(app)
            receiverDriver = getSelectedReceiverDriver(app);

            switch receiverDriver.IsStreaming
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case false
                    app.BandReceiverGrid.RowHeight(2:3)   = {22,0};
                    set(findobj(groot, 'Parent', app.BandReceiverGrid, 'Tag', 'task_Set1'), 'Enable', 1)
                    set(findobj(groot, 'Parent', app.BandReceiverGrid, 'Tag', 'task_Set2'), 'Enable', 0)

                    app.BandPreamp.Enable                 = 1;                    
                    app.BandSelectivityLabel.Visible      = 0;
                    app.BandSelectivity.Visible           = 0;

                    if receiverDriver.HasVideoBandWidth
                        app.BandVBWLabel.Visible          = 1;
                        app.BandVBW.Visible               = 1;
                    else
                        app.BandVBWLabel.Visible          = 0;
                        app.BandVBW.Visible               = 0;
                    end
                    
                    app.BandResolutionLabel.Layout.Column = 1;
                    app.BandResolution.Layout.Column      = 1;
                    app.BandIntegrationTimeLabel.Visible  = 0;
                    app.BandIntegrationTime.Visible       = 0;

                % R&S EB500
                case true
                    app.BandReceiverGrid.RowHeight(2:3)   = {0,22};
                    set(findobj(groot, 'Parent', app.BandReceiverGrid, 'Tag', 'task_Set1'), 'Enable', 0)
                    set(findobj(groot, 'Parent', app.BandReceiverGrid, 'Tag', 'task_Set2'), 'Enable', 1)

                    app.BandPreamp.Enable                 = 0;
                    app.BandSelectivityLabel.Visible      = 1;
                    app.BandSelectivity.Visible           = 1;
                    app.BandVBWLabel.Visible              = 0;
                    app.BandVBW.Visible                   = 0;
                    app.BandResolutionLabel.Layout.Column = 2;
                    app.BandResolution.Layout.Column      = 2;
            end
        end

        %-----------------------------------------------------------------%
        function instrSettings = getReceiverDefaults(app, idx1, idx2)
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
                                   'Detector_Items',    [], 'IntegrationTime', []);

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
                    if contains(app.ReceiverList.Value, 'N9344C')
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
                    instrSettings.Selectivity = app.BandSelectivity.Items{rbwIndex};

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
        function saveReceiverDefaults(app, idx1, idx2)
            instrSettings = getReceiverDefaults(app, idx1, idx2);

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
            app.taskList(idx1).Band(idx2).instrReceiverKey        = getReceiverKey(app);
            app.taskList(idx1).Band(idx2).EditedFlag              = 0;
        end

        %-----------------------------------------------------------------%
        function updateBandContent(app)
            idx1 = getSelectedTaskIndex(app);
            idx2 = app.BandTree.SelectedNodes.NodeData;
            receiverDriver = getSelectedReceiverDriver(app);

            ensureReceiverDefaults(app, idx1, idx2)

            app.BandMetaData.Text = util.HtmlTextGenerator.AddTask_BandView(app.taskList, idx1, idx2);

            switch receiverDriver.IsStreaming
                % Anritsu MS2720T, Keysight N9344C, Keysight N9936B, R&S FSL, R&S FSVR, R&S FSW, and Tektronix SA2500
                case false
                    app.BandStepWidth1.Value = app.taskList(idx1).Band(idx2).instrStepWidth / 1000;

                    if fix(diff(receiverDriver.Definition.features.dataPoints))
                        dataPointsValue = app.taskList(idx1).Band(idx2).instrDataPoints;
                    else
                        dataPointsValue = receiverDriver.Definition.features.dataPoints(1);
                    end
                    set(app.BandDataPoints1, 'Limits', app.taskList(idx1).Band(idx2).instrDataPoints_Limits, 'Value', dataPointsValue)

                % R&S EB500
                case true
                    set(app.BandStepWidth2, 'Items', app.taskList(idx1).Band(idx2).instrStepWidth_Items, ...
                                             'Value', app.taskList(idx1).Band(idx2).instrStepWidth)
                    app.BandDataPoints2.Value = app.taskList(idx1).Band(idx2).instrDataPoints;
                    app.BandSelectivity.Value = app.taskList(idx1).Band(idx2).instrSelectivity;
                    app.BandVBW.Items         = {};

                    app.BandIntegrationTime.Value = app.taskList(idx1).Band(idx2).instrIntegrationTime;
            end

            set(app.BandResolution, 'Items', app.taskList(idx1).Band(idx2).instrResolution_Items, ...
                                     'Value', app.taskList(idx1).Band(idx2).instrResolution)

            set(app.BandVBW,        'Items', app.taskList(idx1).Band(idx2).instrVBW_Items,        ...
                                     'Value', app.taskList(idx1).Band(idx2).instrVBW)

            app.BandPreamp.Value  = app.taskList(idx1).Band(idx2).instrPreamp;
            app.BandAttenuationMode.Value = app.taskList(idx1).Band(idx2).instrAttMode;

            set(app.BandAttenuation,   'Items', app.taskList(idx1).Band(idx2).instrAttFactor_Items,  ...
                                     'Value', app.taskList(idx1).Band(idx2).instrAttFactor)

            set(app.BandDetector,   'Items', app.taskList(idx1).Band(idx2).instrDetector_Items,   ...
                                     'Value', app.taskList(idx1).Band(idx2).instrDetector)

            if ~isempty(app.taskList(idx1).Band(idx2).instrObservationSamples)
                app.BandSamples.Value = app.taskList(idx1).Band(idx2).instrObservationSamples;
            end

            % Parâmetros relacionados ao Direction Finder (DF):
            app.BandDFSquelchMode.Value  = app.taskList(idx1).Band(idx2).DF_SquelchMode;
            app.BandDFSquelchValue.Value = app.taskList(idx1).Band(idx2).DF_SquelchValue;
            app.BandDFMeasTime.Value     = app.taskList(idx1).Band(idx2).DF_MeasTime * 1000;

            % Alvo e antena da banda, limitados às listas vigentes (receptor/comutador).
            if ismember(app.taskList(idx1).Band(idx2).instrTarget, app.BandTarget.Items)
                app.BandTarget.Value = app.taskList(idx1).Band(idx2).instrTarget;
            else
                app.BandTarget.Value = app.BandTarget.Items{1};
            end
            updateBandAntennaItems(app)

            if ismember(app.taskList(idx1).Band(idx2).instrAntenna, app.BandAntenna.Items)
                app.BandAntenna.Value = app.taskList(idx1).Band(idx2).instrAntenna;
            else
                app.BandAntenna.Value = app.BandAntenna.Items{1};
            end

            updateAntennaPanelContent(app)
        end

        %-----------------------------------------------------------------%
        function updateUIControlContent(app, scope)
            arguments
                app
                scope {mustBeMember(scope, {'task', 'receiver', 'taskType', 'antennaSwitch', 'band'})}
            end

            % Cada escopo inclui os níveis abaixo dele: tarefa > receptor > banda.
            switch scope
                case 'task'
                    updateTaskContent(app)
                    updateReceiverContent(app, true)

                case 'receiver'
                    updateReceiverContent(app, true)

                case 'taskType'
                    updateReceiverContent(app, false)

                case 'antennaSwitch'
                    updateAntennaSwitchContent(app)
            end

            updateBandContent(app)
        end

        %-----------------------------------------------------------------%
        function updateUIControlState(app)
            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.BandTree.SelectedNodes.NodeData;
            receiverDriver = getSelectedReceiverDriver(app);
            band = app.taskList(taskIdx).Band(bandIdx);

            % Tipo de tarefa
            switch app.TaskType.Value
                case 'Rompimento de Máscara Espectral'
                    app.TaskType.Layout.Column = 1;
                    app.MaskFileAddButton.Visible = true;
                    set(app.MaskFileViewButton, 'Visible', true, 'Enable', isfile(app.MaskFileViewButton.Tag))

                otherwise
                    app.TaskType.Layout.Column = [1,3];
                    app.MaskFileAddButton.Visible = false;
                    set(app.MaskFileViewButton, 'Visible', false, 'Enable', false)
            end

            set(findobj(app.BandDFGrid.Children, '-not', 'Type', 'uilabel'), 'Enable', strcmp(app.TaskType.Value, 'Drive-test (Level+Azimuth)'))

            % Período de observação
            switch app.ObservationType.Value
                case 'Duração'
                    app.ObservationPanelGrid.RowHeight{3} = 22;
                    set(app.DurationGrid.Children,     'Enable', 1, 'Visible', 1)
                    set(app.SpecificTimeGrid.Children, 'Enable', 0, 'Visible', 0)

                case 'Período específico'
                    app.ObservationPanelGrid.RowHeight{3} = 0;
                    set(app.DurationGrid.Children,     'Enable', 0, 'Visible', 0)
                    set(app.SpecificTimeGrid.Children, 'Enable', 1, 'Visible', 1)

                case 'Quantidade específica de amostras'
                    app.ObservationPanelGrid.RowHeight{3} = 0;
                    set(app.DurationGrid.Children,     'Enable', 0, 'Visible', 0)
                    set(app.SpecificTimeGrid.Children, 'Enable', 0, 'Visible', 0)
            end

            app.BandSamples.Enable = strcmp(app.ObservationType.Value, 'Quantidade específica de amostras');

            % GPS
            switch app.GPSList.Value
                case 'ID 0: Manual'
                    set(app.GpsParametersGrid.Children,        'Enable', true)
                    set(app.GpsRevisitTime,          'Enable', false)

                otherwise
                    set(app.GpsParametersGrid.Children,        'Enable', false)
                    set(app.GpsLatitudeLabel,  'Enable', true)
                    set(app.GpsLongitudeLabel, 'Enable', true)
                    set(app.GpsRevisitTimeLabel,     'Enable', true)

                    gpsEditable = ~ismember(app.TaskType.Value, {'Drive-test', 'Drive-test (Level+Azimuth)'});
                    set(app.GpsRevisitTime, 'Enable', true, 'Editable', gpsEditable)
            end

            % Parâmetros da banda que dependem do receptor
            updateReceiverParametersState(app)

            if receiverDriver.IsStreaming
                app.BandIntegrationTime.Enable = ~strcmp(band.TraceMode, 'ClearWrite');
            else
                app.BandStepWidth1.Editable = any(fix(diff(receiverDriver.Definition.features.dataPoints)));
            end

            set([app.BandIntegrationTimeLabel, app.BandIntegrationTime], 'Visible', receiverDriver.IsStreaming)
            set([app.BandAttenuationLabel, app.BandAttenuation], 'Visible', ~strcmp(app.BandAttenuationMode.Value, 'Auto'))
            app.BandRefreshButton.Visible = logical(band.EditedFlag);

            updateAntennaPanelState(app)
        end

        %-----------------------------------------------------------------%
        function updateTaskContent(app)
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

                    if isnat(taskStartsAt)
                        taskStartsAt = datetime('now');
                    end

                    if isnat(taskStopsAt)
                        taskStopsAt = datetime('now');
                    end

                    app.StartDatePicker.Value = taskStartsAt;
                    app.StartTimeHourSpinner.Value    = hour(taskStartsAt);
                    app.StartTimeMinuteSpinner.Value    = minute(taskStartsAt);

                    app.EndDatePicker.Value = taskStopsAt;
                    app.EndTimeHourSpinner.Value    = hour(taskStopsAt);
                    app.EndTimeMinuteSpinner.Value    = minute(taskStopsAt);

                case 'Samples'
                    app.ObservationType.Value  = app.ObservationType.Items{3};
            end

            gpsMetaData = app.taskList(taskIdx).GPS;
            if strcmpi(gpsMetaData.Type, 'manual') && ~isempty(gpsMetaData.Latitude) && ~isempty(gpsMetaData.Longitude)
                app.GpsLatitude.Value  = gpsMetaData.Latitude;
                app.GpsLongitude.Value = gpsMetaData.Longitude;
            end
        end

        %-----------------------------------------------------------------%
        function updateReceiverContent(app, resetGpsSelection)
            taskIdx = getSelectedTaskIndex(app);
            receiverDriver = getSelectedReceiverDriver(app);

            % Os parâmetros customizados das bandas dependem do receptor. Isto
            % porque os parâmetros do R&S EB500, por exemplo, são diferentes do
            % Tek SA2500. Só são recalculados se o receptor mudou ou se não houve edição.
            ensureTaskReceiverDefaults(app, taskIdx)

            updateGpsListContent(app, resetGpsSelection)

            previousSync = app.ReceiverSyncMode.Value;
            app.ReceiverSyncMode.Items = strsplit(receiverDriver.Definition.features.sweepMode.items, ',');
            if ismember(previousSync, app.ReceiverSyncMode.Items)
                app.ReceiverSyncMode.Value = previousSync;
            end

            % O estado inicial do comutador é definido por receptor.
            receiverName = getSelectedReceiverName(app);
            if ~strcmp(app.AntennaSwitchReceiver, receiverName)
                app.AntennaSwitchReceiver = receiverName;

                idxSwitch = getAntennaSwitchIndex(app, 'ReceiverChanged');
                app.AntennaSwitchCheckBox.Value = ~isempty(idxSwitch) && app.switchList.SwitchDefaultStatus(idxSwitch);
            end

            updateAntennaSwitchContent(app)
        end

        %-----------------------------------------------------------------%
        function updateGpsListContent(app, resetSelection)
            taskIdx = getSelectedTaskIndex(app);
            receiverDriver = getSelectedReceiverDriver(app);
            previousValue = app.GPSList.Value;

            % A lista de GPS é formada pelo "ID 0: Manual", o GPS do receptor
            % selecionado, caso existe GPS embarcado nele, e os GPSs externos.
            % Os GPSs externos são representados por "IDs virtuais", que não
            % se confundem com os IDs de receptores.
            gpsList = {'ID 0: Manual'};
            if receiverDriver.HasGps
                gpsList{end+1} = app.ReceiverList.Value;
            end

            externalList = {};
            gpsIndexes = find(app.gpsObj.List.Enable);
            numReceivers = numel(app.ReceiverList.Items);
            for ii = 1:numel(gpsIndexes)
                gpsIndex = gpsIndexes(ii);
                gpsSocket = getReceiverEndpoint(app, app.gpsObj.List.Parameters{gpsIndex});
                externalList{end+1} = sprintf('ID %d: %s - %s', numReceivers+ii, app.gpsObj.List.Name{gpsIndex}, gpsSocket);
            end
            app.GPSList.Items = [gpsList, externalList];

            % GPS externo é mantido se ainda disponível. Caso contrário, e se o GPS não
            % foi editado, escolhe-se o do próprio receptor, caso este possua GPS embarcado.
            if ~resetSelection && ismember(previousValue, app.GPSList.Items)
                app.GPSList.Value = previousValue;

            elseif ismember(previousValue, externalList)
                app.GPSList.Value = previousValue;

            elseif strcmpi(app.taskList(taskIdx).GPS.Type, 'manual')
                app.GPSList.Value = 'ID 0: Manual';

            elseif receiverDriver.HasGps
                app.GPSList.Value = app.ReceiverList.Value;

            else
                app.GPSList.Value = 'ID 0: Manual';
            end

            updateGpsRevisitContent(app)
        end

        %-----------------------------------------------------------------%
        function updateGpsRevisitContent(app)
            if strcmp(app.GPSList.Value, 'ID 0: Manual')
                return
            end

            taskIdx = getSelectedTaskIndex(app);

            % O tipo de tarefa "Drive-test" tem impacto no tempo de revisita do GPS.
            switch app.TaskType.Value
                case {'Drive-test', 'Drive-test (Level+Azimuth)'}
                    gpsValue = max([min([app.taskList(taskIdx).Band.RevisitTime]), app.GpsRevisitTime.Limits(1)]);

                otherwise
                    if ~isempty(app.taskList(taskIdx).GPS.RevisitTime)
                        gpsValue = app.taskList(taskIdx).GPS.RevisitTime;
                    else
                        gpsValue = 60;
                    end
            end

            app.GpsRevisitTime.Value = gpsValue;
        end

        %-----------------------------------------------------------------%
        function updateAntennaSwitchContent(app)
            switchIdx = getAntennaSwitchIndex(app, 'default');
            antennaItems = app.switchList.Antennas{switchIdx};

            if app.AntennaSwitchCheckBox.Value
                app.AntennaSwitchName.Value = app.switchList.Switch{switchIdx};
                app.AntennaName.Items = antennaItems;

                switch app.AntennaSwitchName.Value
                    case 'EMSat'
                        app.BandTarget.Items = [{''}, app.targetList];

                    case 'ERMx'
                        app.BandTarget.Items = {''};
                        app.BandAntenna.Items = antennaItems;
                end

            else
                app.AntennaSwitchName.Value = '';
                set(app.AntennaName, 'Items', antennaItems, 'Value', '')
                app.BandTarget.Items = {''};
                app.BandAntenna.Items = {''};
            end
        end

        %-----------------------------------------------------------------%
        function updateAntennaPanelContent(app)
            % Com comutador, a antena de instalação é a antena da banda selecionada.
            if ismember(app.AntennaSwitchName.Value, {'EMSat', 'ERMx'})
                app.AntennaName.Value = app.BandAntenna.Value;
            end

            updateAntennaTrackingItems(app)
            updateAntennaTrackingValues(app)
        end

        %-----------------------------------------------------------------%
        function updateAntennaTrackingItems(app)
            if ~isempty(app.AntennaName.Value)
                switch app.AntennaSwitchName.Value
                    case 'EMSat'
                        if ~isempty(app.BandTarget.Value)
                            set(app.AntennaTrackingMode, 'Items', {'Target', 'LookAngles', 'Manual'}, 'Value', 'Target')
                        else
                            initialSelection = app.AntennaTrackingMode.Value;
                            if ~ismember(initialSelection, {'LookAngles', 'Manual'})
                                initialSelection = 'Manual';
                            end
                            set(app.AntennaTrackingMode, 'Items', {'LookAngles', 'Manual'}, 'Value', initialSelection)
                        end

                    otherwise
                        app.AntennaTrackingMode.Items = {'Manual'};
                end

            else
                app.AntennaTrackingMode.Items = {'Manual'};
            end
        end

        %-----------------------------------------------------------------%
        function updateAntennaTrackingValues(app)
            if isempty(app.AntennaName.Value)
                return
            end

            switch app.AntennaTrackingMode.Value
                case 'Target'
                    updateAntennaTargetValues(app)

                case 'LookAngles'
                    app.AntennaAzimuthReference.Value = 'NV';
            end
        end

        %-----------------------------------------------------------------%
        function updateAntennaPanelState(app)
            hasSwitch = ~isempty(getAntennaSwitchIndex(app, 'ReceiverChanged'));
            app.AntennaSwitchCheckBox.Enable = hasSwitch;
            app.AntennaSwitchName.Enable = app.AntennaSwitchCheckBox.Value;

            if app.AntennaSwitchCheckBox.Value
                set(app.BandAntennaGrid.Children, 'Enable', 1)
                app.AntennaName.Enable = 0;

                if strcmp(app.AntennaSwitchName.Value, 'ERMx')
                    set([app.BandTarget, app.BandTargetRefreshButton], 'Enable', 0)
                end

            else
                app.AntennaName.Enable = 1;
                set([app.BandTarget, app.BandAntenna, app.BandTargetRefreshButton], 'Enable', 0)
            end

            app.AntennaAddButton.Enable = ~isempty(app.AntennaName.Value);

            if isempty(app.AntennaName.Value)
                setAntennaFieldsState(false)
                return
            end

            switch app.AntennaTrackingMode.Value
                case 'Target'
                    setAntennaFieldsState(false)
                    app.AntennaTrackingMode.Enable = 1;

                case 'LookAngles'
                    setAntennaFieldsState(true)
                    app.AntennaHeight.Enable = 0;
                    app.AntennaAzimuthReference.Enable = 0;

                case 'Manual'
                    switch app.AntennaSwitchName.Value
                        case 'EMSat'
                            setAntennaFieldsState(true)
                            app.AntennaHeight.Enable = 0;

                        case 'ERMx'
                            setAntennaFieldsState(false)
                            app.AntennaHeight.Enable = 1;

                        otherwise
                            if strcmp(app.AntennaName.Value, 'Unlisted (Directional)')
                                setAntennaFieldsState(true)
                                app.AntennaTrackingMode.Enable = 0;
                            else
                                setAntennaFieldsState(false)
                                app.AntennaHeight.Enable = 1;
                            end
                    end
            end

            function setAntennaFieldsState(status)
                antennaFields = findobj(app.AntennaParametersGrid, '-not', {'Type', 'uigrid', '-or', 'Type', 'uilabel'});
                set(antennaFields, 'Enable', status)
            end
        end

        %-----------------------------------------------------------------%
        function antennaMetaData = getAntennaMetaDataFromUI(app)
            switch app.AntennaSwitchName.Value
                case 'EMSat'
                    antennaName = extractBefore(app.AntennaName.Value, ' ');
                otherwise
                    antennaName = app.AntennaName.Value;
            end

            target = 'NA';
            if ~isempty(app.BandTarget.Value)
                target = app.BandTarget.Value;
            end

            height = 'NA';
            if app.AntennaHeight.Enable
                height = sprintf('%.0fm', app.AntennaHeight.Value);
            end

            azimuth = 'NA';
            elevation = 'NA';
            polarization = 'NA';
            if app.AntennaAzimuth.Enable
                azimuth = sprintf('%.3fº %s', app.AntennaAzimuth.Value, app.AntennaAzimuthReference.Value);
                elevation = sprintf('%.3fº', app.AntennaElevation.Value);
                polarization = sprintf('%.1fº', app.AntennaPolarization.Value);
            end

            antennaMetaData = struct( ...
                'Name',         antennaName, ...
                'TrackingMode', app.AntennaTrackingMode.Value, ...
                'Target',       target, ...
                'Height',       height, ...
                'Azimuth',      azimuth, ...
                'Elevation',    elevation, ...
                'Polarization', polarization ...
            );
        end

        %-----------------------------------------------------------------%
        function upsertAntennaNode(app, antennaMetaData)
            % Os metadados ficam em "NodeData", sem necessidade de interpretar o texto do nó.
            nodeText = buildAntennaNodeText(app, antennaMetaData);

            [isFound, nodeIdx] = ismember(antennaMetaData.Name, getAntennaTreeNames(app));
            if isFound
                set(app.AntennaTree.Children(nodeIdx), 'Text', nodeText, 'NodeData', antennaMetaData)
            else
                uitreenode(app.AntennaTree, 'Text', nodeText, 'NodeData', antennaMetaData, 'ContextMenu', app.ContextMenu);
            end
        end

        %-----------------------------------------------------------------%
        function antennaNames = getAntennaTreeNames(app)
            antennaNames = {};
            if ~isempty(app.AntennaTree.Children)
                antennaNames = cellfun(@(nodeData) nodeData.Name, {app.AntennaTree.Children.NodeData}, 'UniformOutput', false);
            end
        end

        %-----------------------------------------------------------------%
        function nodeText = buildAntennaNodeText(~, antennaMetaData)
            separator = '&nbsp;&nbsp;•&nbsp;&nbsp;';

            details = {};
            if ~strcmp(antennaMetaData.Target, 'NA')
                details{end+1} = antennaMetaData.Target;
            end

            if ~strcmp(antennaMetaData.Height, 'NA')
                details{end+1} = sprintf('Alt. %s', antennaMetaData.Height);
            end

            if ~strcmp(antennaMetaData.Azimuth, 'NA')
                details{end+1} = sprintf('Az. %s', antennaMetaData.Azimuth);
                details{end+1} = sprintf('El. %s', antennaMetaData.Elevation);
                details{end+1} = sprintf('Pol. %s', antennaMetaData.Polarization);
            end

            nodeText = sprintf('<b>%s</b><br><font style="color: gray;">Apontamento "%s"<br>%s</font>', replace(antennaMetaData.Name, '&', '&amp;'), antennaMetaData.TrackingMode, strjoin(details, separator));
        end

        %-----------------------------------------------------------------%
        function receiverKey = buildReceiverKey(~, receiverName, taskType)
            receiverKey = sprintf('%s|%d', receiverName, contains(taskType, 'Drive-test (Level+Azimuth)'));
        end

        %-----------------------------------------------------------------%
        function receiverKey = getReceiverKey(app)
            receiverKey = buildReceiverKey(app, getSelectedReceiverName(app), app.TaskType.Value);
        end

        %-----------------------------------------------------------------%
        function initializeBandFields(app)
            % Campos de controle e parâmetros das bandas que independem do receptor.
            % Não existem originalmente no arquivo "TaskList.json", devendo ser criados.
            fieldDefaults = struct( ...
                'EditedFlag', 0, ...
                'instrReceiverKey', '', ...
                'instrTarget', '', ...
                'instrAntenna', '', ...
                'DF_SquelchMode', 'OFF', ...
                'DF_SquelchValue', 10, ...
                'DF_MeasTime', 1 ...
            );
            fieldNames = fieldnames(fieldDefaults);

            for taskIdx = 1:numel(app.taskList)
                bandIdxs = 1:numel(app.taskList(taskIdx).Band);

                for ii = 1:numel(fieldNames)
                    if ~isfield(app.taskList(taskIdx).Band, fieldNames{ii})
                        for bandIdx = bandIdxs
                            app.taskList(taskIdx).Band(bandIdx).(fieldNames{ii}) = fieldDefaults.(fieldNames{ii});
                        end
                    end
                end

                if ~isfield(app.taskList(taskIdx).Band, 'instrObservationSamples')
                    for bandIdx = bandIdxs
                        app.taskList(taskIdx).Band(bandIdx).instrObservationSamples = app.taskList(taskIdx).Band(bandIdx).ObservationSamples;
                    end
                end

                % Tarefas salvas sem o tipo "Drive-test (Level+Azimuth)" têm os campos de DF vazios.
                for bandIdx = bandIdxs
                    if isempty(app.taskList(taskIdx).Band(bandIdx).DF_SquelchMode)
                        app.taskList(taskIdx).Band(bandIdx).DF_SquelchMode = fieldDefaults.DF_SquelchMode;
                    end

                    if isempty(app.taskList(taskIdx).Band(bandIdx).DF_SquelchValue)
                        app.taskList(taskIdx).Band(bandIdx).DF_SquelchValue = fieldDefaults.DF_SquelchValue;
                    end

                    if isempty(app.taskList(taskIdx).Band(bandIdx).DF_MeasTime)
                        app.taskList(taskIdx).Band(bandIdx).DF_MeasTime = fieldDefaults.DF_MeasTime;
                    end
                end
            end
        end

        %-----------------------------------------------------------------%
        function ensureReceiverDefaults(app, taskIdx, bandIdx)
            % "EditedFlag" refere-se apenas aos parâmetros que dependem do receptor, os
            % quais são descartados quando o receptor ("instrReceiverKey") é alterado.
            band = app.taskList(taskIdx).Band(bandIdx);
            receiverChanged = ~strcmp(band.instrReceiverKey, getReceiverKey(app));

            if receiverChanged
                app.taskList(taskIdx).Band(bandIdx).instrTarget  = '';
                app.taskList(taskIdx).Band(bandIdx).instrAntenna = '';
            end

            if receiverChanged || ~band.EditedFlag
                saveReceiverDefaults(app, taskIdx, bandIdx)
            end
        end

        %-----------------------------------------------------------------%
        function ensureTaskReceiverDefaults(app, taskIdx)
            for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                ensureReceiverDefaults(app, taskIdx, bandIdx)
            end
        end

        %-----------------------------------------------------------------%
        function userAccepted = confirmDiscardReceiverEdits(app)
            % A troca de receptor (ou do tipo de tarefa, no caso do EB500) descarta
            % os parâmetros editados, assim como o alvo e a antena de cada faixa.
            userAccepted = true;
            receiverKey  = getReceiverKey(app);

            for taskIdx = 1:numel(app.taskList)
                for bandIdx = 1:numel(app.taskList(taskIdx).Band)
                    band = app.taskList(taskIdx).Band(bandIdx);

                    hasEdits = band.EditedFlag || ~isempty(band.instrTarget) || ~isempty(band.instrAntenna);
                    if hasEdits && ~strcmp(band.instrReceiverKey, receiverKey)
                        questionMsg = [ ...
                            'Foram alterados parâmetros do receptor, ou selecionados alvo ou antena, ' ...
                            'de ao menos uma das faixas de frequência. Essas alterações serão ' ...
                            'descartadas se confirmada a troca.<br><br>Deseja continuar?' ...
                        ];
                        userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 2, 2);
                        userAccepted  = userSelection == "Sim";
                        return
                    end
                end
            end
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
            receiverName = char(extractBetween(app.ReceiverList.Value, ': ', ' -'));
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

            if strcmp(sourceType, 'ReceiverChanged') || app.AntennaSwitchCheckBox.Value
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
                    if strcmp(app.GPSList.Value, 'ID 0: Manual')
                        error('Uma monitoração do tipo "%s" deve contemplar o uso de um GPS.', app.TaskType.Value)
                    end

                case 'Drive-test (Level+Azimuth)'
                    if strcmp(app.GPSList.Value, 'ID 0: Manual')
                        error('Uma monitoração do tipo "%s" deve contemplar o uso de um GPS.', app.TaskType.Value)

                    elseif ~contains(app.ReceiverList.Value, 'EB500')
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
                    if ~isfile(app.MaskFileViewButton.Tag)
                        error('Não selecionado o arquivo de máscara espectral.')
                    end
            end

            % (b) VALID OBSERVATION PERIOD
            switch app.ObservationType.Value
                case 'Período específico'
                    beginTime = app.StartDatePicker.Value + hours(app.StartTimeHourSpinner.Value) + minutes(app.StartTimeMinuteSpinner.Value);
                    endTime   = app.EndDatePicker.Value + hours(app.EndTimeHourSpinner.Value) + minutes(app.EndTimeMinuteSpinner.Value);
                    
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
            if strcmp(app.GPSList.Value, 'ID 0: Manual') && ~gpsLib.isRefPointInBrazil(struct('Latitude', app.GpsLatitude.Value, 'Longitude', app.GpsLongitude.Value))
                error('Coordenadas geográficas inválidas por remeter a local fora do país.')
            end

            % (d) REVISIT TIME (GPS x BANDS)
            if ~strcmp(app.GPSList.Value, 'ID 0: Manual')
                revisitTimeArray = [app.GpsRevisitTime.Value, [app.taskList(taskIdx).Band.RevisitTime]];
                if isequal(find(revisitTimeArray == min(revisitTimeArray)), 1)
                    error('O tempo de revisita do GPS não pode ser inferior ao mínimo tempo de revisita da(s) faixa(s) de frequência.')
                end
            end

            % (e) ADDED CONFIG PARAMETERS FOR EACH ANTENNA TO BE USED
            if isempty(app.AntennaTree.Children)
                error('Não configurados os parâmetros de instalação da(s) antena(s) em uso.')

            elseif ~app.AntennaSwitchCheckBox.Value && (numel(app.AntennaTree.Children) > 1)
                error('A configuração dos parâmetros de instalação de mais de uma antena é possível apenas quando habilitado o comutador.')
            end

            if app.AntennaSwitchCheckBox.Value
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
                    antennaTreeNames = getAntennaTreeNames(app);
    
                    antennaIdx = contains(antennaList, antennaTreeNames);
                    if ~all(antennaIdx)
                        error('Não foram configurados os parâmetros de instalação da(s) antena(s) indicada(s) a seguir.\nAntenas: %s', strjoin(antennaList(~antennaIdx), ', '))
                    end
                end

            else
                if ~any(contains(app.AntennaName.Items, getAntennaTreeNames(app)))
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
                        
                    case 'edit'
                        app.taskList = util.TaskScriptIO.toRawScript(mainApp.TaskController.Tasks(editionType.idx).TaskSpec.Script);
                        app.ConfirmEditionButton.Text = 'Editar tarefa';
                        app.HeaderTitle.Text = {'<b>Edita tarefa de monitoração</b>'; '<font style="color: gray; font-size: 11px;">Escolha os instrumentos que serão empregados (receptor, GPS, comutador de antena etc)</font>'};
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

            taskIdx = getSelectedTaskIndex(app);

            buildTreeBands(app, taskIdx)
            updateUIControlContent(app, 'task')
            updateUIControlState(app)

        end

        % Value changed function: TaskType
        function onTaskTypeValueChanged(app, event)

            if ~confirmDiscardReceiverEdits(app)
                app.TaskType.Value = event.PreviousValue;
                return
            end

            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.BandTree.SelectedNodes.NodeData;

            buildTreeBands(app, taskIdx, bandIdx)
            updateUIControlContent(app, 'taskType')
            updateUIControlState(app)

        end

        % Button pushed function: MaskFileAddButton, MaskFileViewButton
        function onMaskFileButtonPushed(app, event)
            
            switch event.Source
                case app.MaskFileAddButton
                    [fileName, fileFolder] = uigetfile({'*.csv', '(*.csv)'}, 'Selecione um arquivo de máscara espectral', 'MultiSelect', 'off');
                    figure(app.UIFigure)
                    
                    if fileName
                        set(app.MaskFileViewButton, 'Enable', true, 'Tag', fullfile(fileFolder, fileName))
                    end

                case app.MaskFileViewButton
                    try
                        msg = textFormatGUI.cellstr2TextField(splitlines(fileread(app.MaskFileViewButton.Tag)), '\n');
                        ui.Dialog(app.UIFigure, 'warning', msg);
        
                    catch ME
                        ui.Dialog(app.UIFigure, 'error', getReport(ME));
                    end
            end

        end

        % Value changed function: ObservationType
        function onObservationTypeValueChanged(app, event)

            updateUIControlState(app)

        end

        % Value changed function: ReceiverList
        function onReceiverValueChanged(app, event)

            if ~confirmDiscardReceiverEdits(app)
                app.ReceiverList.Value = event.PreviousValue;
                return
            end

            updateUIControlContent(app, 'receiver')
            updateUIControlState(app)

        end

        % Value changed function: GPSList
        function onGpsValueChanged(app, event)

            updateGpsRevisitContent(app)
            updateUIControlState(app)

        end

        % Button pushed function: GpsImportStationButton
        function onGpsImportStationButtonPushed(app, event)
            
            app.GPSList.Value = 'ID 0: Manual';
            app.GpsLatitude.Value  = app.mainApp.General.context.CONFIG.station.latitude;
            app.GpsLongitude.Value = app.mainApp.General.context.CONFIG.station.longitude;

            onGpsValueChanged(app)

        end

        % Button pushed function: GpsConnectivityButton, 
        % ...and 1 other component
        function onConnectivityTestButtonPushed(app, event)
            
            switch event.Source
                case app.ReceiverConnectivityButton
                    app.progressDialog.Visible = 'visible';
                    testInstrumentConnectivity(app, 'receiver', true);            
                    app.progressDialog.Visible = 'hidden';

                case app.GpsConnectivityButton
                    if strcmp(app.GPSList.Value, 'ID 0: Manual') && ~gpsLib.isRefPointInBrazil(struct('Latitude', app.GpsLatitude.Value, 'Longitude', app.GpsLongitude.Value))
                        ui.Dialog(app.UIFigure, 'warning', 'Coordenadas geográficas inválidas por remeter a local fora do país.');
                        return
                    end
        
                    app.progressDialog.Visible = 'visible';

                    gps = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '');
        
                    try
                        if strcmp(app.ReceiverList.Value, app.GPSList.Value)
                            receiverHandle = testInstrumentConnectivity(app, 'receiver');
                            if ~isempty(receiverHandle)
                                gps = model.GPS.fetchGPSCoordinates('Built-in', receiverHandle, receiverHandle.UserData.IDN);
                            end
            
                        elseif strcmp(app.GPSList.Value, 'ID 0: Manual')
                            gps.Status = 1;

                            % Inicialmente trunca os valores de lat e lng
                            % em seis casas decimais...
                            gps.Latitude = round(app.GpsLatitude.Value,  6);
                            gps.Longitude = round(app.GpsLongitude.Value, 6);
            
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

        % Value changed function: AntennaSwitchCheckBox
        function onAntennaSwitchModeValueChanged(app, event)

            updateUIControlContent(app, 'antennaSwitch')
            updateUIControlState(app)

        end

        % Value changed function: AntennaName
        function onAntennaNameValueChanged(app, event)

            updateAntennaTrackingItems(app)
            updateAntennaTrackingValues(app)
            updateUIControlState(app)

        end

        % Value changed function: AntennaTrackingMode
        function onAntennaTrackingModeValueChanged(app, event)

            % Fora do modo "Target", o alvo da banda deixa de ser considerado.
            trackingMode = app.AntennaTrackingMode.Value;
            releaseTarget = strcmp(trackingMode, 'LookAngles') || (strcmp(trackingMode, 'Manual') && strcmp(app.AntennaSwitchName.Value, 'EMSat'));

            if ~isempty(app.AntennaName.Value) && releaseTarget
                releaseAntennaTarget(app)
            end

            updateAntennaTrackingValues(app)
            updateUIControlState(app)

        end

        % Image clicked function: AntennaAddButton
        function onAntennaAddButtonClicked(app, event)
            
            upsertAntennaNode(app, getAntennaMetaDataFromUI(app))

        end

        % Menu selected function: AntennaDelMenu
        function onAntennaDelButtonClicked(app, event)
            
            if ~isempty(app.AntennaTree.SelectedNodes)
                delete(app.AntennaTree.SelectedNodes)
            end

        end

        % Selection changed function: BandTree
        function onBandTreeSelectionChanged(app, event)

            if exist('event', 'var')
                if isempty(event.SelectedNodes)
                    app.BandTree.SelectedNodes = event.PreviousSelectedNodes;
                    return
                end
            end

            applyBandTreeStyle(app)
            updateUIControlContent(app, 'band')
            updateUIControlState(app)

        end

        % Image clicked function: BandRefreshButton
        function onBandRefreshButtonClicked(app, event)

            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.BandTree.SelectedNodes.NodeData;

            app.taskList(taskIdx).Band(bandIdx).EditedFlag = 0;
            updateUIControlContent(app, 'band')
            updateUIControlState(app)

        end

        % Value changed function: BandAntenna, BandAttenuation, 
        % ...and 15 other components
        function onBandParameterValueChanged(app, event)

            taskIdx = getSelectedTaskIndex(app);
            bandIdx = app.BandTree.SelectedNodes.NodeData;

            switch event.Source
                % OPERATION COMPLEXITY: 1 OF 3
                case app.BandSamples
                    app.taskList(taskIdx).Band(bandIdx).instrObservationSamples = app.BandSamples.Value;

                case app.BandAttenuation
                    app.taskList(taskIdx).Band(bandIdx).instrAttFactor = app.BandAttenuation.Value;

                case app.BandPreamp
                    app.taskList(taskIdx).Band(bandIdx).instrPreamp = app.BandPreamp.Value;

                case app.BandIntegrationTime
                    app.taskList(taskIdx).Band(bandIdx).instrIntegrationTime = app.BandIntegrationTime.Value;

                case app.BandDetector
                    app.taskList(taskIdx).Band(bandIdx).instrDetector = app.BandDetector.Value;

                case app.BandVBW
                    app.taskList(taskIdx).Band(bandIdx).instrVBW = app.BandVBW.Value;

                case app.BandDFSquelchMode
                    app.taskList(taskIdx).Band(bandIdx).DF_SquelchMode = app.BandDFSquelchMode.Value;

                case app.BandDFSquelchValue
                    app.taskList(taskIdx).Band(bandIdx).DF_SquelchValue = app.BandDFSquelchValue.Value;

                case app.BandDFMeasTime
                    app.taskList(taskIdx).Band(bandIdx).DF_MeasTime = app.BandDFMeasTime.Value / 1000;
                
                % OPERATION COMPLEXITY: 2 OF 3
                case app.BandAntenna
                    app.taskList(taskIdx).Band(bandIdx).instrAntenna = app.BandAntenna.Value;
                    updateAntennaPanelContent(app)

                case app.BandTarget
                    app.taskList(taskIdx).Band(bandIdx).instrTarget = app.BandTarget.Value;

                    % A alteração do alvo restringe a lista de antenas, descartando a seleção anterior.
                    updateBandAntennaItems(app)
                    app.taskList(taskIdx).Band(bandIdx).instrAntenna = app.BandAntenna.Value;
                    updateAntennaPanelContent(app)

                case app.BandDataPoints1
                    if ~fix(diff(app.BandDataPoints1.Limits))
                        return
                    end        
                    span = app.taskList(taskIdx).Band(bandIdx).FreqStop - app.taskList(taskIdx).Band(bandIdx).FreqStart;
                    app.BandStepWidth1.Value = (span/(app.BandDataPoints1.Value-1)) / 1000;
        
                    app.taskList(taskIdx).Band(bandIdx).instrDataPoints  = app.BandDataPoints1.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrStepWidth   = app.BandStepWidth1.Value*1000;

                case app.BandSelectivity
                    app.BandResolution.Value = sprintf('%.3f kHz', app.EB500Map{app.BandStepWidth2.Value, app.BandSelectivity.Value}/1000);
        
                    app.taskList(taskIdx).Band(bandIdx).instrSelectivity = app.BandSelectivity.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrResolution  = app.BandResolution.Value;

                case app.BandResolution
                    app.taskList(taskIdx).Band(bandIdx).instrResolution  = app.BandResolution.Value;
        
                    if contains(app.ReceiverList.Value, 'EB500')
                        if getSelectedReceiverDriver(app).IsStreaming
                            idxSelectivity = find(strcmp(app.BandResolution.Items, app.BandResolution.Value), 1);
                            app.BandSelectivity.Value = app.BandSelectivity.Items{idxSelectivity};
                        end
                        app.taskList(taskIdx).Band(bandIdx).instrSelectivity = app.BandSelectivity.Value;
                    end

                case app.BandAttenuationMode
                    app.taskList(taskIdx).Band(bandIdx).instrAttMode = app.BandAttenuationMode.Value;

                % OPERATION COMPLEXITY: 3 OF 3
                case app.BandStepWidth1
                    span = app.taskList(taskIdx).Band(bandIdx).FreqStop - app.taskList(taskIdx).Band(bandIdx).FreqStart;
                    dataPoints = round(span/(app.BandStepWidth1.Value*1000) + 1);

                    if dataPoints < app.BandDataPoints1.Limits(1)
                        app.BandDataPoints1.Value = app.BandDataPoints1.Limits(1);
                    elseif dataPoints > app.BandDataPoints1.Limits(2)
                        app.BandDataPoints1.Value = fix(app.BandDataPoints1.Limits(2));
                    else
                        app.BandDataPoints1.Value = dataPoints;
                    end        
                    app.BandStepWidth1.Value = (span/(app.BandDataPoints1.Value-1)) / 1000;
        
                    app.taskList(taskIdx).Band(bandIdx).instrStepWidth  = 1000*app.BandStepWidth1.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrDataPoints = app.BandDataPoints1.Value;

                case app.BandStepWidth2
                    span = app.taskList(taskIdx).Band(bandIdx).FreqStop - app.taskList(taskIdx).Band(bandIdx).FreqStart;
                    stepValue = extractBefore(app.BandStepWidth2.Value, ' kHz');
        
                    app.BandDataPoints2.Value = span/(1000*str2double(stepValue)) + 1;
        
                    rbwValues = [];
                    rbwItems  = {};
                    for ii = 1:3
                        rbwValues = [rbwValues, app.EB500Map{app.BandStepWidth2.Value,ii}];
                        rbwItems  = [rbwItems,  sprintf('%.3f kHz', rbwValues(ii)/1000)];
                    end
                    app.BandResolution.Items = rbwItems;
        
                    rbwIndex = find(abs(rbwValues - app.taskList(taskIdx).Band(bandIdx).Resolution) == min(abs(rbwValues - app.taskList(taskIdx).Band(bandIdx).Resolution)));
                    app.BandResolution.Value = app.BandResolution.Items{rbwIndex};
                    app.BandSelectivity.Value = app.BandSelectivity.Items{rbwIndex};
        
                    app.taskList(taskIdx).Band(bandIdx).instrStepWidth        = app.BandStepWidth2.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrDataPoints       = app.BandDataPoints2.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrSelectivity      = app.BandSelectivity.Value;
                    app.taskList(taskIdx).Band(bandIdx).instrResolution_Items = app.BandResolution.Items;
                    app.taskList(taskIdx).Band(bandIdx).instrResolution       = app.BandResolution.Value;
            end

            % Alvo, antena, amostras e DF independem do receptor e não são recalculados por ele.
            independentControls = [app.BandSamples, app.BandAntenna, app.BandTarget, app.BandDFSquelchMode, app.BandDFSquelchValue, app.BandDFMeasTime];
            if ~any(event.Source == independentControls)
                app.taskList(taskIdx).Band(bandIdx).EditedFlag = 1;
            end

            updateUIControlState(app)
            
        end

        % Image clicked function: BandTargetRefreshButton
        function onBandTargetRefreshButtonClicked(app, event)
            
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
                    taskStartAt = app.StartDatePicker.Value + hours(app.StartTimeHourSpinner.Value) + minutes(app.StartTimeMinuteSpinner.Value);
                    taskStopsAt  = app.EndDatePicker.Value + hours(app.EndTimeHourSpinner.Value) + minutes(app.EndTimeMinuteSpinner.Value);

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
            switch app.GPSList.Value
                case 'ID 0: Manual'
                    app.taskList(taskIdx).GPS = struct( ...
                        'Type', 'Manual', ...
                        'Latitude', app.GpsLatitude.Value, ...
                        'Longitude', app.GpsLongitude.Value, ...
                        'RevisitTime', [] ...
                    );

                otherwise
                    if strcmp(app.ReceiverList.Value, app.GPSList.Value)
                        gpsType = 'Built-in';
                    else
                        gpsType = 'External';
                    end

                    app.taskList(taskIdx).GPS = struct( ...
                        'Type', gpsType, ...
                        'Latitude', [], ...
                        'Longitude', [], ...
                        'RevisitTime', app.GpsRevisitTime.Value ...
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
                idx3 = str2double(char(extractBetween(app.ReceiverList.Value, 'ID', ':')));
                sReceiver = app.receiverObj.List(idx3,:);

                receiverHandle = testInstrumentConnectivity(app, 'receiver');
                if ~isempty(receiverHandle)
                    runningSyncMode = getRunningReceiverSyncMode(app, receiverHandle);

                    if ~isempty(runningSyncMode) && strcmp(app.ReceiverResetCommand.Value, 'On')
                        error([ ...
                            'Na atual tarefa foi definido que no seu início ' ...
                            'deve ser dado o comando de RESET no receptor, o ' ...
                            'que não é permitido quando este receptor já está ' ...
                            'envolvido em tarefa(s) em andamento.' ...
                        ])
                    end

                    if ~isempty(runningSyncMode) && ~strcmp(runningSyncMode, app.ReceiverSyncMode.Value)
                        app.progressDialog.Visible = 'hidden';

                        questionMsg = sprintf([ ...
                            'O receptor selecionado está em uso por tarefa(s) ' ...
                            'em andamento com sincronismo "%s", diferente do ' ...
                            'selecionado ("%s").\n\nDeseja desconsiderar o sincronismo ' ...
                            'selecionado e adotar o das tarefas em andamento?' ...
                        ], runningSyncMode, app.ReceiverSyncMode.Value);
                        
                        userSelection = uiconfirm(app.UIFigure, questionMsg, 'appColeta', 'Options', {'Adotar sincronismo em andamento', 'Cancelar'}, 'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'warning');

                        if strcmp(userSelection, 'Cancelar')
                            return
                        end

                        app.progressDialog.Visible = 'visible';
                        app.ReceiverSyncMode.Value = runningSyncMode;
                    end
                end

                % STREAMING (UDP SOCKET)
                streamHandle = [];
                if receiverDriver.IsStreaming
                    [app.mainApp.TaskController.UDPPortArray, udpIndex] = util.SocketPorts.findOrCreateUdpPort(app.mainApp.TaskController.UDPPortArray, app.mainApp.EB500Obj.udpPort);
                    if ~isempty(udpIndex)
                        streamHandle = app.mainApp.TaskController.UDPPortArray{udpIndex};
                    end
                end

                % GPS
                sGPS = [];
                gpsHandle = [];
                if ~ismember(app.GPSList.Value, {'ID 0: Manual', app.ReceiverList.Value})
                    idx4 = str2double(char(extractBetween(app.GPSList.Value, 'ID', ':'))) - numel(app.ReceiverList.Items);
                    sGPS = app.gpsObj.List(idx4,:);

                    gpsHandle = testInstrumentConnectivity(app, 'gps');
                end

                % ANTENNA (MATRIX SWITCH & ANTENNA/LNB POSITION)
                switchIdx = getAntennaSwitchIndex(app, 'default');
                antennaList = app.switchList.Antennas{switchIdx};
                antennaMetaData = struct('Name', {}, 'TrackingMode', {}, 'Target', {}, 'Height', {}, 'Azimuth', {}, 'Elevation', {}, 'Polarization', {});

                for kk = 1:numel(app.AntennaTree.Children)
                    nodeData = app.AntennaTree.Children(kk).NodeData;

                    if any(contains(antennaList, nodeData.Name))
                        antennaMetaData(end+1,:) = nodeData;
                    end
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
                app.MaskFileViewButton.Tag, ...
                struct('Handle', receiverHandle, 'Selection', sReceiver, 'Config', receiverDriver.Definition, 'Reset', app.ReceiverResetCommand.Value, 'Sync', app.ReceiverSyncMode.Value), ...
                struct('Handle', streamHandle), ...
                struct('Handle', gpsHandle, 'Selection', sGPS), ...
                struct('Switch', struct('Name', app.AntennaSwitchName.Value, 'OutputPort', app.switchList.SwitchOutputPort(switchIdx)), 'MetaData', antennaMetaData) ...
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

            % Create HeaderIcon
            app.HeaderIcon = uiimage(app.GridLayout);
            app.HeaderIcon.ScaleMethod = 'none';
            app.HeaderIcon.Layout.Row = [4 5];
            app.HeaderIcon.Layout.Column = 2;
            app.HeaderIcon.VerticalAlignment = 'top';
            app.HeaderIcon.ImageSource = 'empty-window-blue.svg';

            % Create HeaderTitle
            app.HeaderTitle = uilabel(app.GridLayout);
            app.HeaderTitle.VerticalAlignment = 'top';
            app.HeaderTitle.WordWrap = 'on';
            app.HeaderTitle.FontSize = 15;
            app.HeaderTitle.FontColor = [0 0.4471 0.7412];
            app.HeaderTitle.Layout.Row = [4 6];
            app.HeaderTitle.Layout.Column = 4;
            app.HeaderTitle.Interpreter = 'html';
            app.HeaderTitle.Text = {'<b>Inclui nova tarefa de monitoração</b>'; '<font style="color: gray; font-size: 11px;">Escolha a tarefa e os instrumentos que serão empregados (receptor, GPS, comutador de antena etc)</font>'};

            % Create SubTabGroup
            app.SubTabGroup = uitabgroup(app.GridLayout);
            app.SubTabGroup.AutoResizeChildren = 'off';
            app.SubTabGroup.SelectionChangedFcn = createCallbackFcn(app, @onSubTabGroupSelectionChanged, true);
            app.SubTabGroup.Tag = '1';
            app.SubTabGroup.Layout.Row = 7;
            app.SubTabGroup.Layout.Column = [2 4];

            % Create TaskTab
            app.TaskTab = uitab(app.SubTabGroup);
            app.TaskTab.AutoResizeChildren = 'off';
            app.TaskTab.Title = 'TAREFA';

            % Create TaskTabGrid
            app.TaskTabGrid = uigridlayout(app.TaskTab);
            app.TaskTabGrid.ColumnWidth = {244, 22, 22};
            app.TaskTabGrid.RowHeight = {17, 22, 22, 22, 22, 22, 22, 22, '1x'};
            app.TaskTabGrid.ColumnSpacing = 5;
            app.TaskTabGrid.RowSpacing = 5;
            app.TaskTabGrid.BackgroundColor = [1 1 1];

            % Create TaskNameLabel
            app.TaskNameLabel = uilabel(app.TaskTabGrid);
            app.TaskNameLabel.VerticalAlignment = 'bottom';
            app.TaskNameLabel.FontSize = 10;
            app.TaskNameLabel.Layout.Row = 1;
            app.TaskNameLabel.Layout.Column = 1;
            app.TaskNameLabel.Text = 'NOME:';

            % Create TaskName
            app.TaskName = uidropdown(app.TaskTabGrid);
            app.TaskName.Items = {};
            app.TaskName.ValueChangedFcn = createCallbackFcn(app, @onTaskValueChanged, true);
            app.TaskName.FontSize = 11;
            app.TaskName.BackgroundColor = [1 1 1];
            app.TaskName.Layout.Row = 2;
            app.TaskName.Layout.Column = [1 3];
            app.TaskName.Value = {};

            % Create TaskTypeLabel
            app.TaskTypeLabel = uilabel(app.TaskTabGrid);
            app.TaskTypeLabel.VerticalAlignment = 'bottom';
            app.TaskTypeLabel.FontSize = 10;
            app.TaskTypeLabel.Layout.Row = 3;
            app.TaskTypeLabel.Layout.Column = 1;
            app.TaskTypeLabel.Text = 'TIPO:';

            % Create TaskType
            app.TaskType = uidropdown(app.TaskTabGrid);
            app.TaskType.Items = {'Monitoração regular', 'Drive-test', 'Drive-test (Level+Azimuth)', 'Rompimento de Máscara Espectral'};
            app.TaskType.ValueChangedFcn = createCallbackFcn(app, @onTaskTypeValueChanged, true);
            app.TaskType.FontSize = 11;
            app.TaskType.BackgroundColor = [1 1 1];
            app.TaskType.Layout.Row = 4;
            app.TaskType.Layout.Column = [1 3];
            app.TaskType.Value = 'Monitoração regular';

            % Create MaskFileAddButton
            app.MaskFileAddButton = uibutton(app.TaskTabGrid, 'push');
            app.MaskFileAddButton.ButtonPushedFcn = createCallbackFcn(app, @onMaskFileButtonPushed, true);
            app.MaskFileAddButton.Icon = 'folder-opened-16px.svg';
            app.MaskFileAddButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.MaskFileAddButton.Visible = 'off';
            app.MaskFileAddButton.Tooltip = {'Seleciona arquivo de máscara espectral'};
            app.MaskFileAddButton.Layout.Row = 4;
            app.MaskFileAddButton.Layout.Column = 2;
            app.MaskFileAddButton.Text = '';

            % Create MaskFileViewButton
            app.MaskFileViewButton = uibutton(app.TaskTabGrid, 'push');
            app.MaskFileViewButton.ButtonPushedFcn = createCallbackFcn(app, @onMaskFileButtonPushed, true);
            app.MaskFileViewButton.Icon = 'Mask_32.png';
            app.MaskFileViewButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.MaskFileViewButton.Enable = 'off';
            app.MaskFileViewButton.Visible = 'off';
            app.MaskFileViewButton.Tooltip = {'Visualiza conteúdo do arquivo'};
            app.MaskFileViewButton.Layout.Row = 4;
            app.MaskFileViewButton.Layout.Column = 3;
            app.MaskFileViewButton.Text = '';

            % Create PreviewTaskCheckbox
            app.PreviewTaskCheckbox = uicheckbox(app.TaskTabGrid);
            app.PreviewTaskCheckbox.Text = 'PRÉVIA (não registra monitoração em arquivo)';
            app.PreviewTaskCheckbox.FontSize = 10;
            app.PreviewTaskCheckbox.Layout.Row = 5;
            app.PreviewTaskCheckbox.Layout.Column = [1 3];

            % Create BitsPerPointLabel
            app.BitsPerPointLabel = uilabel(app.TaskTabGrid);
            app.BitsPerPointLabel.VerticalAlignment = 'bottom';
            app.BitsPerPointLabel.FontSize = 10;
            app.BitsPerPointLabel.Layout.Row = 6;
            app.BitsPerPointLabel.Layout.Column = 1;
            app.BitsPerPointLabel.Text = 'CODIFICAÇÃO:';

            % Create BitsPerPoint
            app.BitsPerPoint = uidropdown(app.TaskTabGrid);
            app.BitsPerPoint.Items = {'8 bits', '16 bits', '32 bits'};
            app.BitsPerPoint.FontSize = 11;
            app.BitsPerPoint.BackgroundColor = [1 1 1];
            app.BitsPerPoint.Layout.Row = 7;
            app.BitsPerPoint.Layout.Column = [1 3];
            app.BitsPerPoint.Value = '8 bits';

            % Create ObservationLabel
            app.ObservationLabel = uilabel(app.TaskTabGrid);
            app.ObservationLabel.VerticalAlignment = 'bottom';
            app.ObservationLabel.FontSize = 10;
            app.ObservationLabel.Layout.Row = 8;
            app.ObservationLabel.Layout.Column = 1;
            app.ObservationLabel.Text = 'PERÍODO DE OBSERVAÇÃO:';

            % Create ObservationPanel
            app.ObservationPanel = uipanel(app.TaskTabGrid);
            app.ObservationPanel.AutoResizeChildren = 'off';
            app.ObservationPanel.Layout.Row = 9;
            app.ObservationPanel.Layout.Column = [1 3];

            % Create ObservationPanelGrid
            app.ObservationPanelGrid = uigridlayout(app.ObservationPanel);
            app.ObservationPanelGrid.ColumnWidth = {'1x'};
            app.ObservationPanelGrid.RowHeight = {17, 22, 22, 49};
            app.ObservationPanelGrid.ColumnSpacing = 11;
            app.ObservationPanelGrid.RowSpacing = 5;
            app.ObservationPanelGrid.BackgroundColor = [1 1 1];

            % Create ObservationTypeLabel
            app.ObservationTypeLabel = uilabel(app.ObservationPanelGrid);
            app.ObservationTypeLabel.VerticalAlignment = 'bottom';
            app.ObservationTypeLabel.FontSize = 11;
            app.ObservationTypeLabel.Layout.Row = 1;
            app.ObservationTypeLabel.Layout.Column = 1;
            app.ObservationTypeLabel.Text = 'Critério de término:';

            % Create ObservationType
            app.ObservationType = uidropdown(app.ObservationPanelGrid);
            app.ObservationType.Items = {'Duração', 'Período específico', 'Quantidade específica de amostras'};
            app.ObservationType.ValueChangedFcn = createCallbackFcn(app, @onObservationTypeValueChanged, true);
            app.ObservationType.FontSize = 11;
            app.ObservationType.BackgroundColor = [1 1 1];
            app.ObservationType.Layout.Row = 2;
            app.ObservationType.Layout.Column = 1;
            app.ObservationType.Value = 'Duração';

            % Create DurationGrid
            app.DurationGrid = uigridlayout(app.ObservationPanelGrid);
            app.DurationGrid.RowHeight = {'1x'};
            app.DurationGrid.RowSpacing = 5;
            app.DurationGrid.Padding = [0 0 0 0];
            app.DurationGrid.Layout.Row = 3;
            app.DurationGrid.Layout.Column = 1;
            app.DurationGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create Duration
            app.Duration = uieditfield(app.DurationGrid, 'numeric');
            app.Duration.Limits = [1 Inf];
            app.Duration.ValueDisplayFormat = '%.3f';
            app.Duration.FontSize = 11;
            app.Duration.Layout.Row = 1;
            app.Duration.Layout.Column = 1;
            app.Duration.Value = 10;

            % Create DurationUnit
            app.DurationUnit = uidropdown(app.DurationGrid);
            app.DurationUnit.Items = {'min', 'hr'};
            app.DurationUnit.FontSize = 11;
            app.DurationUnit.BackgroundColor = [1 1 1];
            app.DurationUnit.Layout.Row = 1;
            app.DurationUnit.Layout.Column = 2;
            app.DurationUnit.Value = 'min';

            % Create SpecificTimeGrid
            app.SpecificTimeGrid = uigridlayout(app.ObservationPanelGrid);
            app.SpecificTimeGrid.ColumnWidth = {'1x', 5, '1x', 10, '1x', 5, '1x'};
            app.SpecificTimeGrid.RowHeight = {22, 22};
            app.SpecificTimeGrid.ColumnSpacing = 0;
            app.SpecificTimeGrid.RowSpacing = 5;
            app.SpecificTimeGrid.Padding = [0 0 0 0];
            app.SpecificTimeGrid.Layout.Row = 4;
            app.SpecificTimeGrid.Layout.Column = 1;
            app.SpecificTimeGrid.BackgroundColor = [1 1 1];

            % Create StartDatePicker
            app.StartDatePicker = uidatepicker(app.SpecificTimeGrid);
            app.StartDatePicker.DisplayFormat = 'dd/MM/uuuu';
            app.StartDatePicker.FontSize = 11;
            app.StartDatePicker.Enable = 'off';
            app.StartDatePicker.Visible = 'off';
            app.StartDatePicker.Layout.Row = 1;
            app.StartDatePicker.Layout.Column = [1 3];

            % Create StartTimeHourSpinner
            app.StartTimeHourSpinner = uispinner(app.SpecificTimeGrid);
            app.StartTimeHourSpinner.Limits = [0 23];
            app.StartTimeHourSpinner.RoundFractionalValues = 'on';
            app.StartTimeHourSpinner.ValueDisplayFormat = '%.0f';
            app.StartTimeHourSpinner.HorizontalAlignment = 'center';
            app.StartTimeHourSpinner.FontSize = 11;
            app.StartTimeHourSpinner.Enable = 'off';
            app.StartTimeHourSpinner.Visible = 'off';
            app.StartTimeHourSpinner.Layout.Row = 2;
            app.StartTimeHourSpinner.Layout.Column = 1;

            % Create StartTimeSeparator
            app.StartTimeSeparator = uilabel(app.SpecificTimeGrid);
            app.StartTimeSeparator.FontSize = 10;
            app.StartTimeSeparator.Enable = 'off';
            app.StartTimeSeparator.Visible = 'off';
            app.StartTimeSeparator.Layout.Row = 2;
            app.StartTimeSeparator.Layout.Column = 2;
            app.StartTimeSeparator.Text = ':';

            % Create StartTimeMinuteSpinner
            app.StartTimeMinuteSpinner = uispinner(app.SpecificTimeGrid);
            app.StartTimeMinuteSpinner.Step = 10;
            app.StartTimeMinuteSpinner.Limits = [0 59];
            app.StartTimeMinuteSpinner.RoundFractionalValues = 'on';
            app.StartTimeMinuteSpinner.ValueDisplayFormat = '%.0f';
            app.StartTimeMinuteSpinner.HorizontalAlignment = 'center';
            app.StartTimeMinuteSpinner.FontSize = 11;
            app.StartTimeMinuteSpinner.Enable = 'off';
            app.StartTimeMinuteSpinner.Visible = 'off';
            app.StartTimeMinuteSpinner.Layout.Row = 2;
            app.StartTimeMinuteSpinner.Layout.Column = 3;

            % Create EndDatePicker
            app.EndDatePicker = uidatepicker(app.SpecificTimeGrid);
            app.EndDatePicker.DisplayFormat = 'dd/MM/uuuu';
            app.EndDatePicker.FontSize = 11;
            app.EndDatePicker.Enable = 'off';
            app.EndDatePicker.Visible = 'off';
            app.EndDatePicker.Layout.Row = 1;
            app.EndDatePicker.Layout.Column = [5 7];

            % Create EndTimeHourSpinner
            app.EndTimeHourSpinner = uispinner(app.SpecificTimeGrid);
            app.EndTimeHourSpinner.Limits = [0 23];
            app.EndTimeHourSpinner.RoundFractionalValues = 'on';
            app.EndTimeHourSpinner.ValueDisplayFormat = '%.0f';
            app.EndTimeHourSpinner.HorizontalAlignment = 'center';
            app.EndTimeHourSpinner.FontSize = 11;
            app.EndTimeHourSpinner.Enable = 'off';
            app.EndTimeHourSpinner.Visible = 'off';
            app.EndTimeHourSpinner.Layout.Row = 2;
            app.EndTimeHourSpinner.Layout.Column = 5;
            app.EndTimeHourSpinner.Value = 23;

            % Create EndTimeSeparator
            app.EndTimeSeparator = uilabel(app.SpecificTimeGrid);
            app.EndTimeSeparator.FontSize = 10;
            app.EndTimeSeparator.Enable = 'off';
            app.EndTimeSeparator.Visible = 'off';
            app.EndTimeSeparator.Layout.Row = 2;
            app.EndTimeSeparator.Layout.Column = 6;
            app.EndTimeSeparator.Text = ':';

            % Create EndTimeMinuteSpinner
            app.EndTimeMinuteSpinner = uispinner(app.SpecificTimeGrid);
            app.EndTimeMinuteSpinner.Step = 10;
            app.EndTimeMinuteSpinner.Limits = [0 59];
            app.EndTimeMinuteSpinner.RoundFractionalValues = 'on';
            app.EndTimeMinuteSpinner.ValueDisplayFormat = '%.0f';
            app.EndTimeMinuteSpinner.HorizontalAlignment = 'center';
            app.EndTimeMinuteSpinner.FontSize = 11;
            app.EndTimeMinuteSpinner.Enable = 'off';
            app.EndTimeMinuteSpinner.Visible = 'off';
            app.EndTimeMinuteSpinner.Layout.Row = 2;
            app.EndTimeMinuteSpinner.Layout.Column = 7;
            app.EndTimeMinuteSpinner.Value = 59;

            % Create InstrumentsTab
            app.InstrumentsTab = uitab(app.SubTabGroup);
            app.InstrumentsTab.AutoResizeChildren = 'off';
            app.InstrumentsTab.Title = 'INSTRUMENTOS';

            % Create InstrumentsTabGrid
            app.InstrumentsTabGrid = uigridlayout(app.InstrumentsTab);
            app.InstrumentsTabGrid.ColumnWidth = {244, 22, 22};
            app.InstrumentsTabGrid.RowHeight = {17, 22, 70, 22, 22, '1x'};
            app.InstrumentsTabGrid.ColumnSpacing = 5;
            app.InstrumentsTabGrid.RowSpacing = 5;
            app.InstrumentsTabGrid.BackgroundColor = [1 1 1];

            % Create ReceiverListLabel
            app.ReceiverListLabel = uilabel(app.InstrumentsTabGrid);
            app.ReceiverListLabel.VerticalAlignment = 'bottom';
            app.ReceiverListLabel.FontSize = 10;
            app.ReceiverListLabel.Layout.Row = 1;
            app.ReceiverListLabel.Layout.Column = 1;
            app.ReceiverListLabel.Text = 'RECEPTOR:';

            % Create ReceiverList
            app.ReceiverList = uidropdown(app.InstrumentsTabGrid);
            app.ReceiverList.Items = {};
            app.ReceiverList.ValueChangedFcn = createCallbackFcn(app, @onReceiverValueChanged, true);
            app.ReceiverList.FontSize = 11;
            app.ReceiverList.BackgroundColor = [1 1 1];
            app.ReceiverList.Layout.Row = 2;
            app.ReceiverList.Layout.Column = [1 2];
            app.ReceiverList.Value = {};

            % Create ReceiverConnectivityButton
            app.ReceiverConnectivityButton = uibutton(app.InstrumentsTabGrid, 'push');
            app.ReceiverConnectivityButton.ButtonPushedFcn = createCallbackFcn(app, @onConnectivityTestButtonPushed, true);
            app.ReceiverConnectivityButton.Icon = 'Connectivity_32.png';
            app.ReceiverConnectivityButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.ReceiverConnectivityButton.Tooltip = {'Teste de conectividade'};
            app.ReceiverConnectivityButton.Layout.Row = 2;
            app.ReceiverConnectivityButton.Layout.Column = 3;
            app.ReceiverConnectivityButton.Text = '';

            % Create ReceiverOptionsPanel
            app.ReceiverOptionsPanel = uipanel(app.InstrumentsTabGrid);
            app.ReceiverOptionsPanel.AutoResizeChildren = 'off';
            app.ReceiverOptionsPanel.Layout.Row = 3;
            app.ReceiverOptionsPanel.Layout.Column = [1 3];

            % Create ReceiverOptionsGrid
            app.ReceiverOptionsGrid = uigridlayout(app.ReceiverOptionsPanel);
            app.ReceiverOptionsGrid.RowHeight = {17, 22};
            app.ReceiverOptionsGrid.RowSpacing = 5;
            app.ReceiverOptionsGrid.BackgroundColor = [1 1 1];

            % Create ReceiverResetCommandLabel
            app.ReceiverResetCommandLabel = uilabel(app.ReceiverOptionsGrid);
            app.ReceiverResetCommandLabel.VerticalAlignment = 'bottom';
            app.ReceiverResetCommandLabel.FontSize = 11;
            app.ReceiverResetCommandLabel.Layout.Row = 1;
            app.ReceiverResetCommandLabel.Layout.Column = 1;
            app.ReceiverResetCommandLabel.Text = 'Reset:';

            % Create ReceiverResetCommand
            app.ReceiverResetCommand = uidropdown(app.ReceiverOptionsGrid);
            app.ReceiverResetCommand.Items = {'On', 'Off'};
            app.ReceiverResetCommand.FontSize = 11;
            app.ReceiverResetCommand.BackgroundColor = [1 1 1];
            app.ReceiverResetCommand.Layout.Row = 2;
            app.ReceiverResetCommand.Layout.Column = 1;
            app.ReceiverResetCommand.Value = 'On';

            % Create ReceiverSyncModeLabel
            app.ReceiverSyncModeLabel = uilabel(app.ReceiverOptionsGrid);
            app.ReceiverSyncModeLabel.VerticalAlignment = 'bottom';
            app.ReceiverSyncModeLabel.FontSize = 11;
            app.ReceiverSyncModeLabel.Layout.Row = 1;
            app.ReceiverSyncModeLabel.Layout.Column = 2;
            app.ReceiverSyncModeLabel.Text = 'Sincronismo:';

            % Create ReceiverSyncMode
            app.ReceiverSyncMode = uidropdown(app.ReceiverOptionsGrid);
            app.ReceiverSyncMode.Items = {'Single Sweep', 'Continuous Sweep', 'Streaming'};
            app.ReceiverSyncMode.FontSize = 11;
            app.ReceiverSyncMode.BackgroundColor = [1 1 1];
            app.ReceiverSyncMode.Layout.Row = 2;
            app.ReceiverSyncMode.Layout.Column = 2;
            app.ReceiverSyncMode.Value = 'Single Sweep';

            % Create GpsListLabel
            app.GpsListLabel = uilabel(app.InstrumentsTabGrid);
            app.GpsListLabel.VerticalAlignment = 'bottom';
            app.GpsListLabel.FontSize = 10;
            app.GpsListLabel.Layout.Row = 4;
            app.GpsListLabel.Layout.Column = 1;
            app.GpsListLabel.Text = 'GPS:';

            % Create GPSList
            app.GPSList = uidropdown(app.InstrumentsTabGrid);
            app.GPSList.Items = {'ID 0: Manual'};
            app.GPSList.ValueChangedFcn = createCallbackFcn(app, @onGpsValueChanged, true);
            app.GPSList.FontSize = 11;
            app.GPSList.BackgroundColor = [1 1 1];
            app.GPSList.Layout.Row = 5;
            app.GPSList.Layout.Column = [1 2];
            app.GPSList.Value = 'ID 0: Manual';

            % Create GpsImportStationButton
            app.GpsImportStationButton = uibutton(app.InstrumentsTabGrid, 'push');
            app.GpsImportStationButton.ButtonPushedFcn = createCallbackFcn(app, @onGpsImportStationButtonPushed, true);
            app.GpsImportStationButton.Icon = 'Pin_18.png';
            app.GpsImportStationButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.GpsImportStationButton.Visible = 'off';
            app.GpsImportStationButton.Tooltip = {'Importa coordenadas geográficas da estação'};
            app.GpsImportStationButton.Layout.Row = 5;
            app.GpsImportStationButton.Layout.Column = 2;
            app.GpsImportStationButton.Text = '';

            % Create GpsConnectivityButton
            app.GpsConnectivityButton = uibutton(app.InstrumentsTabGrid, 'push');
            app.GpsConnectivityButton.ButtonPushedFcn = createCallbackFcn(app, @onConnectivityTestButtonPushed, true);
            app.GpsConnectivityButton.Icon = 'Connectivity_32.png';
            app.GpsConnectivityButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.GpsConnectivityButton.Tooltip = {'Teste de conectividade'};
            app.GpsConnectivityButton.Layout.Row = 5;
            app.GpsConnectivityButton.Layout.Column = 3;
            app.GpsConnectivityButton.Text = '';

            % Create GpsParametersPanel
            app.GpsParametersPanel = uipanel(app.InstrumentsTabGrid);
            app.GpsParametersPanel.AutoResizeChildren = 'off';
            app.GpsParametersPanel.Layout.Row = 6;
            app.GpsParametersPanel.Layout.Column = [1 3];

            % Create GpsParametersGrid
            app.GpsParametersGrid = uigridlayout(app.GpsParametersPanel);
            app.GpsParametersGrid.RowHeight = {17, 22, 22, 22};
            app.GpsParametersGrid.RowSpacing = 5;
            app.GpsParametersGrid.BackgroundColor = [1 1 1];

            % Create GpsLatitudeLabel
            app.GpsLatitudeLabel = uilabel(app.GpsParametersGrid);
            app.GpsLatitudeLabel.VerticalAlignment = 'bottom';
            app.GpsLatitudeLabel.FontSize = 11;
            app.GpsLatitudeLabel.Layout.Row = 1;
            app.GpsLatitudeLabel.Layout.Column = 1;
            app.GpsLatitudeLabel.Text = 'Latitude (°):';

            % Create GpsLatitude
            app.GpsLatitude = uieditfield(app.GpsParametersGrid, 'numeric');
            app.GpsLatitude.ValueDisplayFormat = '%.6f';
            app.GpsLatitude.FontSize = 11;
            app.GpsLatitude.Layout.Row = 2;
            app.GpsLatitude.Layout.Column = 1;
            app.GpsLatitude.Value = -1;

            % Create GpsLongitudeLabel
            app.GpsLongitudeLabel = uilabel(app.GpsParametersGrid);
            app.GpsLongitudeLabel.VerticalAlignment = 'bottom';
            app.GpsLongitudeLabel.FontSize = 11;
            app.GpsLongitudeLabel.Layout.Row = 1;
            app.GpsLongitudeLabel.Layout.Column = 2;
            app.GpsLongitudeLabel.Text = 'Longitude (º):';

            % Create GpsLongitude
            app.GpsLongitude = uieditfield(app.GpsParametersGrid, 'numeric');
            app.GpsLongitude.ValueDisplayFormat = '%.6f';
            app.GpsLongitude.FontSize = 11;
            app.GpsLongitude.Layout.Row = 2;
            app.GpsLongitude.Layout.Column = 2;
            app.GpsLongitude.Value = -1;

            % Create GpsRevisitTimeLabel
            app.GpsRevisitTimeLabel = uilabel(app.GpsParametersGrid);
            app.GpsRevisitTimeLabel.VerticalAlignment = 'bottom';
            app.GpsRevisitTimeLabel.FontSize = 11;
            app.GpsRevisitTimeLabel.Layout.Row = 3;
            app.GpsRevisitTimeLabel.Layout.Column = 1;
            app.GpsRevisitTimeLabel.Text = 'Tempo revisita (seg):';

            % Create GpsRevisitTime
            app.GpsRevisitTime = uieditfield(app.GpsParametersGrid, 'numeric');
            app.GpsRevisitTime.Limits = [1 Inf];
            app.GpsRevisitTime.ValueDisplayFormat = '%.3f';
            app.GpsRevisitTime.FontSize = 11;
            app.GpsRevisitTime.Layout.Row = 4;
            app.GpsRevisitTime.Layout.Column = 1;
            app.GpsRevisitTime.Value = 60;

            % Create AntennasTab
            app.AntennasTab = uitab(app.SubTabGroup);
            app.AntennasTab.AutoResizeChildren = 'off';
            app.AntennasTab.Title = 'ANTENAS';

            % Create AntennasTabGrid
            app.AntennasTabGrid = uigridlayout(app.AntennasTab);
            app.AntennasTabGrid.ColumnWidth = {270, 18};
            app.AntennasTabGrid.RowHeight = {17, 22, 22, 22, 178, 18, '1x'};
            app.AntennasTabGrid.RowSpacing = 5;
            app.AntennasTabGrid.BackgroundColor = [1 1 1];

            % Create AntennaSwitchCheckBox
            app.AntennaSwitchCheckBox = uicheckbox(app.AntennasTabGrid);
            app.AntennaSwitchCheckBox.ValueChangedFcn = createCallbackFcn(app, @onAntennaSwitchModeValueChanged, true);
            app.AntennaSwitchCheckBox.Text = 'Comutador de antenas:';
            app.AntennaSwitchCheckBox.FontSize = 11;
            app.AntennaSwitchCheckBox.Layout.Row = 1;
            app.AntennaSwitchCheckBox.Layout.Column = 1;

            % Create AntennaSwitchName
            app.AntennaSwitchName = uieditfield(app.AntennasTabGrid, 'text');
            app.AntennaSwitchName.Editable = 'off';
            app.AntennaSwitchName.FontSize = 11;
            app.AntennaSwitchName.Enable = 'off';
            app.AntennaSwitchName.Layout.Row = 2;
            app.AntennaSwitchName.Layout.Column = [1 2];

            % Create AntennaNameLabel
            app.AntennaNameLabel = uilabel(app.AntennasTabGrid);
            app.AntennaNameLabel.VerticalAlignment = 'bottom';
            app.AntennaNameLabel.FontSize = 10;
            app.AntennaNameLabel.Layout.Row = 3;
            app.AntennaNameLabel.Layout.Column = 1;
            app.AntennaNameLabel.Text = 'ANTENA';

            % Create AntennaName
            app.AntennaName = uidropdown(app.AntennasTabGrid);
            app.AntennaName.Items = {'', 'CRFS Low Band (10 MHz - 1.2 GHz)', 'CRFS High Band (750 MHz - 6 GHz)', 'Rohde & Schwarz ADDx07 (EB500 GUI Auto)', 'Rohde & Schwarz ADD107 (20 MHz - 1.3 GHz)', 'Rohde & Schwarz ADD207 (600 MHz - 6 GHz)', 'Rohde & Schwarz ADD295 (20 MHz - 3 GHz)', 'Telescopic', 'Unlisted (Omni)', 'Unlisted (Directional)'};
            app.AntennaName.ValueChangedFcn = createCallbackFcn(app, @onAntennaNameValueChanged, true);
            app.AntennaName.FontSize = 11;
            app.AntennaName.BackgroundColor = [1 1 1];
            app.AntennaName.Layout.Row = 4;
            app.AntennaName.Layout.Column = [1 2];
            app.AntennaName.Value = '';

            % Create AntennaParametersPanel
            app.AntennaParametersPanel = uipanel(app.AntennasTabGrid);
            app.AntennaParametersPanel.AutoResizeChildren = 'off';
            app.AntennaParametersPanel.Layout.Row = 5;
            app.AntennaParametersPanel.Layout.Column = [1 2];

            % Create AntennaParametersGrid
            app.AntennaParametersGrid = uigridlayout(app.AntennaParametersPanel);
            app.AntennaParametersGrid.RowHeight = {17, 22, 22, 22, 22, 22};
            app.AntennaParametersGrid.RowSpacing = 5;
            app.AntennaParametersGrid.BackgroundColor = [1 1 1];

            % Create AntennaTrackingModeLabel
            app.AntennaTrackingModeLabel = uilabel(app.AntennaParametersGrid);
            app.AntennaTrackingModeLabel.VerticalAlignment = 'bottom';
            app.AntennaTrackingModeLabel.FontSize = 11;
            app.AntennaTrackingModeLabel.Layout.Row = 1;
            app.AntennaTrackingModeLabel.Layout.Column = [1 2];
            app.AntennaTrackingModeLabel.Text = 'Apontamento:';

            % Create AntennaTrackingMode
            app.AntennaTrackingMode = uidropdown(app.AntennaParametersGrid);
            app.AntennaTrackingMode.Items = {'Target', 'LookAngles', 'Manual'};
            app.AntennaTrackingMode.ValueChangedFcn = createCallbackFcn(app, @onAntennaTrackingModeValueChanged, true);
            app.AntennaTrackingMode.FontSize = 11;
            app.AntennaTrackingMode.BackgroundColor = [1 1 1];
            app.AntennaTrackingMode.Layout.Row = 2;
            app.AntennaTrackingMode.Layout.Column = [1 2];
            app.AntennaTrackingMode.Value = 'Manual';

            % Create AntennaHeightLabel
            app.AntennaHeightLabel = uilabel(app.AntennaParametersGrid);
            app.AntennaHeightLabel.VerticalAlignment = 'bottom';
            app.AntennaHeightLabel.FontSize = 11;
            app.AntennaHeightLabel.Layout.Row = 3;
            app.AntennaHeightLabel.Layout.Column = 1;
            app.AntennaHeightLabel.Text = 'Altura de instalação (m):';

            % Create AntennaHeight
            app.AntennaHeight = uieditfield(app.AntennaParametersGrid, 'numeric');
            app.AntennaHeight.Limits = [0 127];
            app.AntennaHeight.RoundFractionalValues = 'on';
            app.AntennaHeight.ValueDisplayFormat = '%.0f';
            app.AntennaHeight.FontSize = 11;
            app.AntennaHeight.Enable = 'off';
            app.AntennaHeight.Layout.Row = 4;
            app.AntennaHeight.Layout.Column = 1;
            app.AntennaHeight.Value = 2;

            % Create AntennaAzimuthGrid
            app.AntennaAzimuthGrid = uigridlayout(app.AntennaParametersGrid);
            app.AntennaAzimuthGrid.ColumnWidth = {'1x', 50};
            app.AntennaAzimuthGrid.RowHeight = {22, 22};
            app.AntennaAzimuthGrid.ColumnSpacing = 5;
            app.AntennaAzimuthGrid.RowSpacing = 5;
            app.AntennaAzimuthGrid.Padding = [0 0 0 0];
            app.AntennaAzimuthGrid.Layout.Row = [3 4];
            app.AntennaAzimuthGrid.Layout.Column = 2;
            app.AntennaAzimuthGrid.BackgroundColor = [1 1 1];

            % Create AntennaAzimuthLabel
            app.AntennaAzimuthLabel = uilabel(app.AntennaAzimuthGrid);
            app.AntennaAzimuthLabel.VerticalAlignment = 'bottom';
            app.AntennaAzimuthLabel.FontSize = 11;
            app.AntennaAzimuthLabel.Layout.Row = 1;
            app.AntennaAzimuthLabel.Layout.Column = 1;
            app.AntennaAzimuthLabel.Text = 'Azimute (º):';

            % Create AntennaAzimuth
            app.AntennaAzimuth = uieditfield(app.AntennaAzimuthGrid, 'numeric');
            app.AntennaAzimuth.Limits = [0 360];
            app.AntennaAzimuth.ValueDisplayFormat = '%.3f';
            app.AntennaAzimuth.FontSize = 11;
            app.AntennaAzimuth.Enable = 'off';
            app.AntennaAzimuth.Layout.Row = 2;
            app.AntennaAzimuth.Layout.Column = 1;

            % Create AntennaAzimuthReference
            app.AntennaAzimuthReference = uidropdown(app.AntennaAzimuthGrid);
            app.AntennaAzimuthReference.Items = {'NV'};
            app.AntennaAzimuthReference.Enable = 'off';
            app.AntennaAzimuthReference.FontSize = 11;
            app.AntennaAzimuthReference.BackgroundColor = [1 1 1];
            app.AntennaAzimuthReference.Layout.Row = 2;
            app.AntennaAzimuthReference.Layout.Column = 2;
            app.AntennaAzimuthReference.Value = 'NV';

            % Create AntennaElevationLabel
            app.AntennaElevationLabel = uilabel(app.AntennaParametersGrid);
            app.AntennaElevationLabel.VerticalAlignment = 'bottom';
            app.AntennaElevationLabel.FontSize = 11;
            app.AntennaElevationLabel.Layout.Row = 5;
            app.AntennaElevationLabel.Layout.Column = 1;
            app.AntennaElevationLabel.Text = 'Elevação (º):';

            % Create AntennaElevation
            app.AntennaElevation = uieditfield(app.AntennaParametersGrid, 'numeric');
            app.AntennaElevation.Limits = [0 90];
            app.AntennaElevation.ValueDisplayFormat = '%.3f';
            app.AntennaElevation.FontSize = 11;
            app.AntennaElevation.Enable = 'off';
            app.AntennaElevation.Layout.Row = 6;
            app.AntennaElevation.Layout.Column = 1;

            % Create AntennaPolarizationLabel
            app.AntennaPolarizationLabel = uilabel(app.AntennaParametersGrid);
            app.AntennaPolarizationLabel.VerticalAlignment = 'bottom';
            app.AntennaPolarizationLabel.FontSize = 11;
            app.AntennaPolarizationLabel.Layout.Row = 5;
            app.AntennaPolarizationLabel.Layout.Column = 2;
            app.AntennaPolarizationLabel.Text = 'Polarização (º):';

            % Create AntennaPolarization
            app.AntennaPolarization = uieditfield(app.AntennaParametersGrid, 'numeric');
            app.AntennaPolarization.Limits = [0 360];
            app.AntennaPolarization.ValueDisplayFormat = '%.1f';
            app.AntennaPolarization.FontSize = 11;
            app.AntennaPolarization.Enable = 'off';
            app.AntennaPolarization.Layout.Row = 6;
            app.AntennaPolarization.Layout.Column = 2;

            % Create AntennaAddButton
            app.AntennaAddButton = uiimage(app.AntennasTabGrid);
            app.AntennaAddButton.ScaleMethod = 'none';
            app.AntennaAddButton.ImageClickedFcn = createCallbackFcn(app, @onAntennaAddButtonClicked, true);
            app.AntennaAddButton.Layout.Row = 6;
            app.AntennaAddButton.Layout.Column = 2;
            app.AntennaAddButton.ImageSource = 'Add_16.png';

            % Create AntennaTree
            app.AntennaTree = uitree(app.AntennasTabGrid);
            app.AntennaTree.FontSize = 10.5;
            app.AntennaTree.Layout.Row = 7;
            app.AntennaTree.Layout.Column = [1 2];

            % Create BandTreePanel
            app.BandTreePanel = uipanel(app.GridLayout);
            app.BandTreePanel.Layout.Row = [4 7];
            app.BandTreePanel.Layout.Column = 6;

            % Create BandTreeGrid
            app.BandTreeGrid = uigridlayout(app.BandTreePanel);
            app.BandTreeGrid.ColumnWidth = {'1x'};
            app.BandTreeGrid.RowHeight = {34, 17, 259, 19, '1x'};
            app.BandTreeGrid.RowSpacing = 5;
            app.BandTreeGrid.BackgroundColor = [1 1 1];

            % Create BandTreeTitle
            app.BandTreeTitle = uilabel(app.BandTreeGrid);
            app.BandTreeTitle.VerticalAlignment = 'top';
            app.BandTreeTitle.FontColor = [0 0.4471 0.7412];
            app.BandTreeTitle.Layout.Row = 1;
            app.BandTreeTitle.Layout.Column = 1;
            app.BandTreeTitle.Interpreter = 'html';
            app.BandTreeTitle.Text = {'<b>Faixas de frequência da tarefa selecionada</b>'; '<font style="color: gray; font-size: 10px;">Visualização das faixas e dos seus parâmetros de configuração</font>'};

            % Create BandTreeLabel
            app.BandTreeLabel = uilabel(app.BandTreeGrid);
            app.BandTreeLabel.VerticalAlignment = 'bottom';
            app.BandTreeLabel.WordWrap = 'on';
            app.BandTreeLabel.FontSize = 10;
            app.BandTreeLabel.Layout.Row = 2;
            app.BandTreeLabel.Layout.Column = 1;
            app.BandTreeLabel.Text = 'FAIXAS DE FREQUÊNCIA';

            % Create BandTree
            app.BandTree = uitree(app.BandTreeGrid);
            app.BandTree.SelectionChangedFcn = createCallbackFcn(app, @onBandTreeSelectionChanged, true);
            app.BandTree.FontSize = 11;
            app.BandTree.FontColor = [0.2 0.2 0.2];
            app.BandTree.Layout.Row = 3;
            app.BandTree.Layout.Column = 1;

            % Create BandMetaDataLabel
            app.BandMetaDataLabel = uilabel(app.BandTreeGrid);
            app.BandMetaDataLabel.VerticalAlignment = 'bottom';
            app.BandMetaDataLabel.WordWrap = 'on';
            app.BandMetaDataLabel.FontSize = 10;
            app.BandMetaDataLabel.FontColor = [0.149 0.149 0.149];
            app.BandMetaDataLabel.Layout.Row = 4;
            app.BandMetaDataLabel.Layout.Column = 1;
            app.BandMetaDataLabel.Text = 'PARÂMETROS DE CONFIGURAÇÃO';

            % Create BandMetaData
            app.BandMetaData = uilabel(app.BandTreeGrid);
            app.BandMetaData.VerticalAlignment = 'top';
            app.BandMetaData.WordWrap = 'on';
            app.BandMetaData.FontSize = 11;
            app.BandMetaData.Layout.Row = 5;
            app.BandMetaData.Layout.Column = 1;
            app.BandMetaData.Interpreter = 'html';
            app.BandMetaData.Text = '';

            % Create BandParametersPanel
            app.BandParametersPanel = uipanel(app.GridLayout);
            app.BandParametersPanel.AutoResizeChildren = 'off';
            app.BandParametersPanel.Layout.Row = [4 7];
            app.BandParametersPanel.Layout.Column = [8 12];

            % Create BandParametersGrid
            app.BandParametersGrid = uigridlayout(app.BandParametersPanel);
            app.BandParametersGrid.ColumnWidth = {120, '1x', 22};
            app.BandParametersGrid.RowHeight = {34, 17, 22, 19, 208, 19, 69, 19, 22, '1x'};
            app.BandParametersGrid.ColumnSpacing = 21;
            app.BandParametersGrid.RowSpacing = 5;
            app.BandParametersGrid.Tag = '4';
            app.BandParametersGrid.Scrollable = 'on';
            app.BandParametersGrid.BackgroundColor = [1 1 1];

            % Create BandParametersTitle
            app.BandParametersTitle = uilabel(app.BandParametersGrid);
            app.BandParametersTitle.VerticalAlignment = 'top';
            app.BandParametersTitle.FontColor = [0 0.4471 0.7412];
            app.BandParametersTitle.Layout.Row = 1;
            app.BandParametersTitle.Layout.Column = [1 3];
            app.BandParametersTitle.Interpreter = 'html';
            app.BandParametersTitle.Text = {'<b>Parâmetros configuráveis da faixa selecionada</b>'; '<font style="color: gray; font-size: 10px;">Parâmetros técnicos de aquisição e detecção</font>'};

            % Create BandSamplesLabel
            app.BandSamplesLabel = uilabel(app.BandParametersGrid);
            app.BandSamplesLabel.VerticalAlignment = 'bottom';
            app.BandSamplesLabel.FontSize = 10;
            app.BandSamplesLabel.Layout.Row = 2;
            app.BandSamplesLabel.Layout.Column = 1;
            app.BandSamplesLabel.Text = 'AMOSTRAS A COLETAR';

            % Create BandSamples
            app.BandSamples = uieditfield(app.BandParametersGrid, 'numeric');
            app.BandSamples.Limits = [-1 Inf];
            app.BandSamples.RoundFractionalValues = 'on';
            app.BandSamples.ValueDisplayFormat = '%.0f';
            app.BandSamples.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandSamples.FontSize = 11;
            app.BandSamples.Layout.Row = 3;
            app.BandSamples.Layout.Column = 1;
            app.BandSamples.Value = -1;

            % Create BandReceiverSectionLabel
            app.BandReceiverSectionLabel = uilabel(app.BandParametersGrid);
            app.BandReceiverSectionLabel.VerticalAlignment = 'bottom';
            app.BandReceiverSectionLabel.FontSize = 10;
            app.BandReceiverSectionLabel.Layout.Row = 4;
            app.BandReceiverSectionLabel.Layout.Column = [1 2];
            app.BandReceiverSectionLabel.Text = 'RECEPTOR';

            % Create BandRefreshButton
            app.BandRefreshButton = uiimage(app.BandParametersGrid);
            app.BandRefreshButton.ScaleMethod = 'none';
            app.BandRefreshButton.ImageClickedFcn = createCallbackFcn(app, @onBandRefreshButtonClicked, true);
            app.BandRefreshButton.Tooltip = {'Retorna às configurações iniciais'};
            app.BandRefreshButton.Layout.Row = 4;
            app.BandRefreshButton.Layout.Column = 3;
            app.BandRefreshButton.HorizontalAlignment = 'right';
            app.BandRefreshButton.VerticalAlignment = 'bottom';
            app.BandRefreshButton.ImageSource = 'Refresh_18.png';

            % Create BandReceiverPanel
            app.BandReceiverPanel = uipanel(app.BandParametersGrid);
            app.BandReceiverPanel.AutoResizeChildren = 'off';
            app.BandReceiverPanel.Layout.Row = 5;
            app.BandReceiverPanel.Layout.Column = [1 3];

            % Create BandReceiverGrid
            app.BandReceiverGrid = uigridlayout(app.BandReceiverPanel);
            app.BandReceiverGrid.ColumnWidth = {110, 110, 110};
            app.BandReceiverGrid.RowHeight = {17, 22, 0, 17, 22, 17, 22, 17, 22};
            app.BandReceiverGrid.RowSpacing = 5;
            app.BandReceiverGrid.Padding = [10 10 10 5];
            app.BandReceiverGrid.Scrollable = 'on';
            app.BandReceiverGrid.BackgroundColor = [1 1 1];

            % Create BandStepWidthLabel
            app.BandStepWidthLabel = uilabel(app.BandReceiverGrid);
            app.BandStepWidthLabel.VerticalAlignment = 'bottom';
            app.BandStepWidthLabel.FontSize = 11;
            app.BandStepWidthLabel.Layout.Row = 1;
            app.BandStepWidthLabel.Layout.Column = 1;
            app.BandStepWidthLabel.Text = 'Passo (kHz):';

            % Create BandStepWidth1
            app.BandStepWidth1 = uieditfield(app.BandReceiverGrid, 'numeric');
            app.BandStepWidth1.Limits = [0 Inf];
            app.BandStepWidth1.ValueDisplayFormat = '%.3f';
            app.BandStepWidth1.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandStepWidth1.Tag = 'task_Set1';
            app.BandStepWidth1.Editable = 'off';
            app.BandStepWidth1.FontSize = 11;
            app.BandStepWidth1.Layout.Row = 2;
            app.BandStepWidth1.Layout.Column = 1;

            % Create BandStepWidth2
            app.BandStepWidth2 = uidropdown(app.BandReceiverGrid);
            app.BandStepWidth2.Items = {};
            app.BandStepWidth2.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandStepWidth2.Tag = 'task_Set2';
            app.BandStepWidth2.Enable = 'off';
            app.BandStepWidth2.FontSize = 11;
            app.BandStepWidth2.BackgroundColor = [1 1 1];
            app.BandStepWidth2.Layout.Row = 3;
            app.BandStepWidth2.Layout.Column = 1;
            app.BandStepWidth2.Value = {};

            % Create BandDataPointsLabel
            app.BandDataPointsLabel = uilabel(app.BandReceiverGrid);
            app.BandDataPointsLabel.VerticalAlignment = 'bottom';
            app.BandDataPointsLabel.FontSize = 11;
            app.BandDataPointsLabel.Layout.Row = 1;
            app.BandDataPointsLabel.Layout.Column = 2;
            app.BandDataPointsLabel.Text = 'Pontos:';

            % Create BandDataPoints1
            app.BandDataPoints1 = uispinner(app.BandReceiverGrid);
            app.BandDataPoints1.Step = 100;
            app.BandDataPoints1.Limits = [101 32001];
            app.BandDataPoints1.RoundFractionalValues = 'on';
            app.BandDataPoints1.ValueDisplayFormat = '%.0f';
            app.BandDataPoints1.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandDataPoints1.Tag = 'task_Set1';
            app.BandDataPoints1.HorizontalAlignment = 'left';
            app.BandDataPoints1.FontSize = 11;
            app.BandDataPoints1.Layout.Row = 2;
            app.BandDataPoints1.Layout.Column = 2;
            app.BandDataPoints1.Value = 101;

            % Create BandDataPoints2
            app.BandDataPoints2 = uieditfield(app.BandReceiverGrid, 'numeric');
            app.BandDataPoints2.ValueDisplayFormat = '%.0f';
            app.BandDataPoints2.Tag = 'task_Set2';
            app.BandDataPoints2.Editable = 'off';
            app.BandDataPoints2.FontSize = 11;
            app.BandDataPoints2.Enable = 'off';
            app.BandDataPoints2.Layout.Row = 3;
            app.BandDataPoints2.Layout.Column = 2;

            % Create BandSelectivityLabel
            app.BandSelectivityLabel = uilabel(app.BandReceiverGrid);
            app.BandSelectivityLabel.Tag = 'task_Set2';
            app.BandSelectivityLabel.VerticalAlignment = 'bottom';
            app.BandSelectivityLabel.FontSize = 11;
            app.BandSelectivityLabel.Visible = 'off';
            app.BandSelectivityLabel.Layout.Row = 4;
            app.BandSelectivityLabel.Layout.Column = 1;
            app.BandSelectivityLabel.Text = 'Seletividade FFT:';

            % Create BandSelectivity
            app.BandSelectivity = uidropdown(app.BandReceiverGrid);
            app.BandSelectivity.Items = {'Normal', 'Narrow', 'Sharp'};
            app.BandSelectivity.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandSelectivity.Tag = 'task_Set2';
            app.BandSelectivity.Visible = 'off';
            app.BandSelectivity.FontSize = 11;
            app.BandSelectivity.BackgroundColor = [1 1 1];
            app.BandSelectivity.Layout.Row = 5;
            app.BandSelectivity.Layout.Column = 1;
            app.BandSelectivity.Value = 'Normal';

            % Create BandResolutionLabel
            app.BandResolutionLabel = uilabel(app.BandReceiverGrid);
            app.BandResolutionLabel.VerticalAlignment = 'bottom';
            app.BandResolutionLabel.FontSize = 11;
            app.BandResolutionLabel.Layout.Row = 4;
            app.BandResolutionLabel.Layout.Column = 1;
            app.BandResolutionLabel.Text = 'Resolução:';

            % Create BandResolution
            app.BandResolution = uidropdown(app.BandReceiverGrid);
            app.BandResolution.Items = {};
            app.BandResolution.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandResolution.FontSize = 11;
            app.BandResolution.BackgroundColor = [1 1 1];
            app.BandResolution.Layout.Row = 5;
            app.BandResolution.Layout.Column = 1;
            app.BandResolution.Value = {};

            % Create BandVBWLabel
            app.BandVBWLabel = uilabel(app.BandReceiverGrid);
            app.BandVBWLabel.Tag = 'task_Set1';
            app.BandVBWLabel.VerticalAlignment = 'bottom';
            app.BandVBWLabel.FontSize = 11;
            app.BandVBWLabel.Layout.Row = 4;
            app.BandVBWLabel.Layout.Column = 2;
            app.BandVBWLabel.Text = 'VBW:';

            % Create BandVBW
            app.BandVBW = uidropdown(app.BandReceiverGrid);
            app.BandVBW.Items = {};
            app.BandVBW.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandVBW.Tag = 'task_Set1';
            app.BandVBW.FontSize = 11;
            app.BandVBW.BackgroundColor = [1 1 1];
            app.BandVBW.Layout.Row = 5;
            app.BandVBW.Layout.Column = 2;
            app.BandVBW.Value = {};

            % Create BandPreampLabel
            app.BandPreampLabel = uilabel(app.BandReceiverGrid);
            app.BandPreampLabel.VerticalAlignment = 'bottom';
            app.BandPreampLabel.FontSize = 11;
            app.BandPreampLabel.Layout.Row = 6;
            app.BandPreampLabel.Layout.Column = 1;
            app.BandPreampLabel.Text = 'Pré-amplificador:';

            % Create BandPreamp
            app.BandPreamp = uidropdown(app.BandReceiverGrid);
            app.BandPreamp.Items = {'On', 'Off'};
            app.BandPreamp.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandPreamp.FontSize = 11;
            app.BandPreamp.BackgroundColor = [1 1 1];
            app.BandPreamp.Layout.Row = 7;
            app.BandPreamp.Layout.Column = 1;
            app.BandPreamp.Value = 'Off';

            % Create BandAttenuationModeLabel
            app.BandAttenuationModeLabel = uilabel(app.BandReceiverGrid);
            app.BandAttenuationModeLabel.VerticalAlignment = 'bottom';
            app.BandAttenuationModeLabel.FontSize = 11;
            app.BandAttenuationModeLabel.Layout.Row = 6;
            app.BandAttenuationModeLabel.Layout.Column = 2;
            app.BandAttenuationModeLabel.Text = 'Modo do atenuador:';

            % Create BandAttenuationMode
            app.BandAttenuationMode = uidropdown(app.BandReceiverGrid);
            app.BandAttenuationMode.Items = {'Manual', 'Auto'};
            app.BandAttenuationMode.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandAttenuationMode.FontSize = 11;
            app.BandAttenuationMode.BackgroundColor = [1 1 1];
            app.BandAttenuationMode.Layout.Row = 7;
            app.BandAttenuationMode.Layout.Column = 2;
            app.BandAttenuationMode.Value = 'Manual';

            % Create BandAttenuationLabel
            app.BandAttenuationLabel = uilabel(app.BandReceiverGrid);
            app.BandAttenuationLabel.VerticalAlignment = 'bottom';
            app.BandAttenuationLabel.FontSize = 11;
            app.BandAttenuationLabel.Layout.Row = 6;
            app.BandAttenuationLabel.Layout.Column = 3;
            app.BandAttenuationLabel.Text = 'Atenuador:';

            % Create BandAttenuation
            app.BandAttenuation = uidropdown(app.BandReceiverGrid);
            app.BandAttenuation.Items = {};
            app.BandAttenuation.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandAttenuation.FontSize = 11;
            app.BandAttenuation.BackgroundColor = [1 1 1];
            app.BandAttenuation.Layout.Row = 7;
            app.BandAttenuation.Layout.Column = 3;
            app.BandAttenuation.Value = {};

            % Create BandDetectorLabel
            app.BandDetectorLabel = uilabel(app.BandReceiverGrid);
            app.BandDetectorLabel.VerticalAlignment = 'bottom';
            app.BandDetectorLabel.FontSize = 11;
            app.BandDetectorLabel.Layout.Row = 8;
            app.BandDetectorLabel.Layout.Column = 1;
            app.BandDetectorLabel.Text = 'Detector:';

            % Create BandDetector
            app.BandDetector = uidropdown(app.BandReceiverGrid);
            app.BandDetector.Items = {'Auto Peak', 'Average', 'Negative Peak', 'Positive Peak', 'Quasi Peak', 'RMS', 'Sample'};
            app.BandDetector.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandDetector.FontSize = 11;
            app.BandDetector.BackgroundColor = [1 1 1];
            app.BandDetector.Layout.Row = 9;
            app.BandDetector.Layout.Column = [1 2];
            app.BandDetector.Value = 'Positive Peak';

            % Create BandIntegrationTimeLabel
            app.BandIntegrationTimeLabel = uilabel(app.BandReceiverGrid);
            app.BandIntegrationTimeLabel.VerticalAlignment = 'bottom';
            app.BandIntegrationTimeLabel.FontSize = 11;
            app.BandIntegrationTimeLabel.Layout.Row = 8;
            app.BandIntegrationTimeLabel.Layout.Column = 3;
            app.BandIntegrationTimeLabel.Text = 'Integração (ms):';

            % Create BandIntegrationTime
            app.BandIntegrationTime = uieditfield(app.BandReceiverGrid, 'numeric');
            app.BandIntegrationTime.Limits = [-1 10000];
            app.BandIntegrationTime.RoundFractionalValues = 'on';
            app.BandIntegrationTime.ValueDisplayFormat = '%.0f';
            app.BandIntegrationTime.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandIntegrationTime.FontSize = 11;
            app.BandIntegrationTime.Layout.Row = 9;
            app.BandIntegrationTime.Layout.Column = 3;
            app.BandIntegrationTime.Value = -1;

            % Create BandDFSectionLabel
            app.BandDFSectionLabel = uilabel(app.BandParametersGrid);
            app.BandDFSectionLabel.VerticalAlignment = 'bottom';
            app.BandDFSectionLabel.FontSize = 10;
            app.BandDFSectionLabel.Layout.Row = 6;
            app.BandDFSectionLabel.Layout.Column = [1 2];
            app.BandDFSectionLabel.Text = 'DIRECTION FINDER (DF)';

            % Create BandDFPanel
            app.BandDFPanel = uipanel(app.BandParametersGrid);
            app.BandDFPanel.AutoResizeChildren = 'off';
            app.BandDFPanel.Layout.Row = 7;
            app.BandDFPanel.Layout.Column = [1 3];

            % Create BandDFGrid
            app.BandDFGrid = uigridlayout(app.BandDFPanel);
            app.BandDFGrid.ColumnWidth = {110, 110, 110};
            app.BandDFGrid.RowHeight = {17, 22};
            app.BandDFGrid.RowSpacing = 5;
            app.BandDFGrid.Scrollable = 'on';
            app.BandDFGrid.BackgroundColor = [1 1 1];

            % Create BandDFSquelchModeLabel
            app.BandDFSquelchModeLabel = uilabel(app.BandDFGrid);
            app.BandDFSquelchModeLabel.VerticalAlignment = 'bottom';
            app.BandDFSquelchModeLabel.FontSize = 11;
            app.BandDFSquelchModeLabel.Layout.Row = 1;
            app.BandDFSquelchModeLabel.Layout.Column = 1;
            app.BandDFSquelchModeLabel.Text = 'SquelchMode:';

            % Create BandDFSquelchMode
            app.BandDFSquelchMode = uidropdown(app.BandDFGrid);
            app.BandDFSquelchMode.Items = {'OFF', 'NORM', 'GATE'};
            app.BandDFSquelchMode.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandDFSquelchMode.Enable = 'off';
            app.BandDFSquelchMode.FontSize = 10;
            app.BandDFSquelchMode.BackgroundColor = [1 1 1];
            app.BandDFSquelchMode.Layout.Row = 2;
            app.BandDFSquelchMode.Layout.Column = 1;
            app.BandDFSquelchMode.Value = 'OFF';

            % Create BandDFSquelchValueLabel
            app.BandDFSquelchValueLabel = uilabel(app.BandDFGrid);
            app.BandDFSquelchValueLabel.VerticalAlignment = 'bottom';
            app.BandDFSquelchValueLabel.FontSize = 11;
            app.BandDFSquelchValueLabel.Layout.Row = 1;
            app.BandDFSquelchValueLabel.Layout.Column = 2;
            app.BandDFSquelchValueLabel.Text = 'Squelch (dBµV):';

            % Create BandDFSquelchValue
            app.BandDFSquelchValue = uispinner(app.BandDFGrid);
            app.BandDFSquelchValue.Step = 10;
            app.BandDFSquelchValue.Limits = [-50 130];
            app.BandDFSquelchValue.RoundFractionalValues = 'on';
            app.BandDFSquelchValue.ValueDisplayFormat = '%.0f';
            app.BandDFSquelchValue.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandDFSquelchValue.Tag = 'task_Set1';
            app.BandDFSquelchValue.HorizontalAlignment = 'left';
            app.BandDFSquelchValue.FontSize = 10;
            app.BandDFSquelchValue.Enable = 'off';
            app.BandDFSquelchValue.Layout.Row = 2;
            app.BandDFSquelchValue.Layout.Column = 2;
            app.BandDFSquelchValue.Value = 10;

            % Create BandDFMeasTimeLabel
            app.BandDFMeasTimeLabel = uilabel(app.BandDFGrid);
            app.BandDFMeasTimeLabel.VerticalAlignment = 'bottom';
            app.BandDFMeasTimeLabel.FontSize = 11;
            app.BandDFMeasTimeLabel.Layout.Row = 1;
            app.BandDFMeasTimeLabel.Layout.Column = 3;
            app.BandDFMeasTimeLabel.Text = 'Integração (ms):';

            % Create BandDFMeasTime
            app.BandDFMeasTime = uispinner(app.BandDFGrid);
            app.BandDFMeasTime.Step = 100;
            app.BandDFMeasTime.Limits = [100 10000];
            app.BandDFMeasTime.RoundFractionalValues = 'on';
            app.BandDFMeasTime.ValueDisplayFormat = '%.0f';
            app.BandDFMeasTime.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandDFMeasTime.Tag = 'task_Set1';
            app.BandDFMeasTime.HorizontalAlignment = 'left';
            app.BandDFMeasTime.FontSize = 10;
            app.BandDFMeasTime.Enable = 'off';
            app.BandDFMeasTime.Layout.Row = 2;
            app.BandDFMeasTime.Layout.Column = 3;
            app.BandDFMeasTime.Value = 1000;

            % Create BandAntennaSectionLabel
            app.BandAntennaSectionLabel = uilabel(app.BandParametersGrid);
            app.BandAntennaSectionLabel.VerticalAlignment = 'bottom';
            app.BandAntennaSectionLabel.FontSize = 10;
            app.BandAntennaSectionLabel.Layout.Row = 8;
            app.BandAntennaSectionLabel.Layout.Column = 1;
            app.BandAntennaSectionLabel.Text = 'ANTENA';

            % Create BandAntennaPanel
            app.BandAntennaPanel = uipanel(app.BandParametersGrid);
            app.BandAntennaPanel.AutoResizeChildren = 'off';
            app.BandAntennaPanel.Layout.Row = [9 10];
            app.BandAntennaPanel.Layout.Column = [1 3];

            % Create BandAntennaGrid
            app.BandAntennaGrid = uigridlayout(app.BandAntennaPanel);
            app.BandAntennaGrid.ColumnWidth = {140, 20, 170};
            app.BandAntennaGrid.RowHeight = {17, 22};
            app.BandAntennaGrid.RowSpacing = 5;
            app.BandAntennaGrid.Scrollable = 'on';
            app.BandAntennaGrid.BackgroundColor = [1 1 1];

            % Create BandTargetLabel
            app.BandTargetLabel = uilabel(app.BandAntennaGrid);
            app.BandTargetLabel.VerticalAlignment = 'bottom';
            app.BandTargetLabel.FontSize = 11;
            app.BandTargetLabel.Layout.Row = 1;
            app.BandTargetLabel.Layout.Column = 1;
            app.BandTargetLabel.Text = 'Estação alvo:';

            % Create BandTargetRefreshButton
            app.BandTargetRefreshButton = uiimage(app.BandAntennaGrid);
            app.BandTargetRefreshButton.ScaleMethod = 'none';
            app.BandTargetRefreshButton.ImageClickedFcn = createCallbackFcn(app, @onBandTargetRefreshButtonClicked, true);
            app.BandTargetRefreshButton.Enable = 'off';
            app.BandTargetRefreshButton.Layout.Row = 1;
            app.BandTargetRefreshButton.Layout.Column = 2;
            app.BandTargetRefreshButton.HorizontalAlignment = 'right';
            app.BandTargetRefreshButton.VerticalAlignment = 'bottom';
            app.BandTargetRefreshButton.ImageSource = 'Refresh_18.png';

            % Create BandTarget
            app.BandTarget = uidropdown(app.BandAntennaGrid);
            app.BandTarget.Items = {};
            app.BandTarget.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandTarget.Enable = 'off';
            app.BandTarget.FontSize = 11;
            app.BandTarget.BackgroundColor = [1 1 1];
            app.BandTarget.Layout.Row = 2;
            app.BandTarget.Layout.Column = [1 2];
            app.BandTarget.Value = {};

            % Create BandAntennaLabel
            app.BandAntennaLabel = uilabel(app.BandAntennaGrid);
            app.BandAntennaLabel.VerticalAlignment = 'bottom';
            app.BandAntennaLabel.FontSize = 11;
            app.BandAntennaLabel.Layout.Row = 1;
            app.BandAntennaLabel.Layout.Column = 3;
            app.BandAntennaLabel.Text = 'Antena/LNB:';

            % Create BandAntenna
            app.BandAntenna = uidropdown(app.BandAntennaGrid);
            app.BandAntenna.Items = {};
            app.BandAntenna.ValueChangedFcn = createCallbackFcn(app, @onBandParameterValueChanged, true);
            app.BandAntenna.Enable = 'off';
            app.BandAntenna.FontSize = 11;
            app.BandAntenna.BackgroundColor = [1 1 1];
            app.BandAntenna.Layout.Row = 2;
            app.BandAntenna.Layout.Column = 3;
            app.BandAntenna.Value = {};

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
            app.ConfirmEditionButton.Text = 'Incluir tarefa';

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

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);
            app.ContextMenu.Tag = 'auxApp.winAddTask';

            % Create AntennaDelMenu
            app.AntennaDelMenu = uimenu(app.ContextMenu);
            app.AntennaDelMenu.MenuSelectedFcn = createCallbackFcn(app, @onAntennaDelButtonClicked, true);
            app.AntennaDelMenu.Text = '❌ Excluir';

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
