classdef winTaskList_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        DockModule                   matlab.ui.container.GridLayout
        DockCloseButton              matlab.ui.control.Image
        DockUndockButton             matlab.ui.control.Image
        ConfirmEditionButtonGrid     matlab.ui.container.GridLayout
        ConfirmEditionButton         matlab.ui.control.Button
        Toolbar                      matlab.ui.container.GridLayout
        ExportButton                 matlab.ui.control.Image
        ImportButton                 matlab.ui.control.Image
        BandPanel                    matlab.ui.container.Panel
        BandGrid                     matlab.ui.container.GridLayout
        FindPeaksPanel               matlab.ui.container.Panel
        FindPeaksGrid                matlab.ui.container.GridLayout
        FindPeaksMinBandWidth        matlab.ui.control.Spinner
        FindPeaksMinBandWidthLabel   matlab.ui.control.Label
        FindPeaksMinDistance         matlab.ui.control.Spinner
        FindPeaksMinDistanceLabel    matlab.ui.control.Label
        FindPeaksMinProminence       matlab.ui.control.Spinner
        FindPeaksMinProminenceLabel  matlab.ui.control.Label
        FindPeaksNumSweeps           matlab.ui.control.Spinner
        FindPeaksNumSweepsLabel      matlab.ui.control.Label
        FindPeaksType                matlab.ui.control.DropDown
        FindPeaksTypeLabel           matlab.ui.control.Label
        FindPeaks_PanelLabel         matlab.ui.control.Label
        RevisitTime                  matlab.ui.control.NumericEditField
        RevisitTimeLabel             matlab.ui.control.Label
        LevelUnit                    matlab.ui.control.DropDown
        LevelUnitLabel               matlab.ui.control.Label
        Detector                     matlab.ui.control.DropDown
        DetectorLabel                matlab.ui.control.Label
        VBW                          matlab.ui.control.DropDown
        VBWLabel                     matlab.ui.control.Label
        RFMode                       matlab.ui.control.DropDown
        RFModeLabel                  matlab.ui.control.Label
        IntegrationFactor            matlab.ui.control.NumericEditField
        IntegrationFactorLabel       matlab.ui.control.Label
        TraceMode                    matlab.ui.control.DropDown
        TraceModeLabel               matlab.ui.control.Label
        Resolution                   matlab.ui.control.NumericEditField
        ResolutionLabel              matlab.ui.control.Label
        StepWidth                    matlab.ui.control.NumericEditField
        StepWidthLabel               matlab.ui.control.Label
        FreqStop                     matlab.ui.control.NumericEditField
        FreqStopLabel                matlab.ui.control.Label
        FreqStart                    matlab.ui.control.NumericEditField
        FreqStartLabel               matlab.ui.control.Label
        ObservationSamples           matlab.ui.control.NumericEditField
        ObservationSamplesLabel      matlab.ui.control.Label
        Description                  matlab.ui.control.EditField
        DescriptionLabel             matlab.ui.control.Label
        ID                           matlab.ui.control.NumericEditField
        IDLabel                      matlab.ui.control.Label
        MaskTrigger                  matlab.ui.control.DropDown
        MaskTriggerLabel             matlab.ui.control.Label
        Status                       matlab.ui.control.DropDown
        StatusLabel                  matlab.ui.control.Label
        BandTitle                    matlab.ui.control.Label
        TaskPanel                    matlab.ui.container.Panel
        TaskGrid                     matlab.ui.container.GridLayout
        GpsPanel                     matlab.ui.container.Panel
        GpsGrid                      matlab.ui.container.GridLayout
        GpsRevisitTime               matlab.ui.control.NumericEditField
        GpsRevisitTimeLabel          matlab.ui.control.Label
        Longitude                    matlab.ui.control.NumericEditField
        LongitudeLabel               matlab.ui.control.Label
        Latitude                     matlab.ui.control.NumericEditField
        LatitudeLabel                matlab.ui.control.Label
        GpsMode                      matlab.ui.control.DropDown
        GpsModeLabel                 matlab.ui.control.Label
        ObservationPanel             matlab.ui.container.Panel
        ObservationGrid              matlab.ui.container.GridLayout
        SpecificTimeGrid             matlab.ui.container.GridLayout
        EndTimeMinuteSpinner         matlab.ui.control.Spinner
        EndTimeSeparator             matlab.ui.control.Label
        EndTimeHourSpinner           matlab.ui.control.Spinner
        EndDatePicker                matlab.ui.control.DatePicker
        StartTimeMinuteSpinner       matlab.ui.control.Spinner
        StartTimeSeparator           matlab.ui.control.Label
        StartTimeHourSpinner         matlab.ui.control.Spinner
        StartDatePicker              matlab.ui.control.DatePicker
        DurationGrid                 matlab.ui.container.GridLayout
        DurationUnit                 matlab.ui.control.DropDown
        Duration                     matlab.ui.control.NumericEditField
        ObservationType              matlab.ui.control.DropDown
        ObservationTypeLabel         matlab.ui.control.Label
        ObservationLabel             matlab.ui.control.Label
        BitsPerPoint                 matlab.ui.control.DropDown
        BitsPerPointLabel            matlab.ui.control.Label
        Name                         matlab.ui.control.EditField
        NameLabel                    matlab.ui.control.Label
        TaskTitle                    matlab.ui.control.Label
        EditStateButton              matlab.ui.control.StateButton
        ViewStateButton              matlab.ui.control.StateButton
        TreePanel                    matlab.ui.container.GridLayout
        TreeTitle                    matlab.ui.control.Label
        TreeMoveDown                 matlab.ui.control.Image
        TreeMoveUp                   matlab.ui.control.Image
        TreeDelNode                  matlab.ui.control.Image
        TreeAddBandNode              matlab.ui.control.Image
        TreeAddTaskNode              matlab.ui.control.Image
        Tree                         matlab.ui.container.Tree
        TreeIcon                     matlab.ui.control.Image
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryApp'
        Context = 'TASK_EDIT'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = false
        SubTabGroup = struct('Children', -1, 'UserData', [])
        
        mainApp
        jsBackDoor
        progressDialog

        ViewMode = true
        TaskList
        TaskListEdited
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
                        app.ViewStateButton;
                        app.EditStateButton;
                        app.ConfirmEditionButtonGrid;
                        app.ImportButton;
                        app.ExportButton;
                        app.DockUndockButton;
                        app.DockCloseButton
                    };
                    ui.CustomizationBase.getElementsDataTag(elToModify);

                    try
                        sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                            struct('appName', appName, 'dataTag', app.ViewStateButton.UserData.id, 'generation', 1, 'styleImportant', struct('borderRadius', '5px 0px 0px 5px')), ...
                            struct('appName', appName, 'dataTag', app.EditStateButton.UserData.id, 'generation', 1, 'styleImportant', struct('borderRadius', '0px 5px 5px 0px')), ...
                            struct('appName', appName, 'dataTag', app.ConfirmEditionButtonGrid.UserData.id, 'style', struct('background', 'none')), ...
                            struct('appName', appName, 'dataTag', app.ImportButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Importa lista de tarefas')), ...
                            struct('appName', appName, 'dataTag', app.ExportButton.UserData.id, 'tooltip', struct('defaultPosition', 'top', 'textContent', 'Exporta lista de tarefas')), ...
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
            app.TaskList = app.mainApp.taskList; % util.TaskScriptIO.loadScriptList(app.mainApp.rootFolder, 'auxApp.winTaskList');
            app.TaskListEdited = app.TaskList;
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
        function buildTaskTree(app, selectedNode)
            if ~isempty(app.Tree.Children)
                delete(app.Tree.Children)
            end

            for taskIdx = 1:numel(app.TaskListEdited)
                taskNode = uitreenode(app.Tree, 'Text', app.TaskListEdited(taskIdx).Name, 'NodeData', struct('taskIdx', taskIdx, 'bandIdx', 1:numel(app.TaskListEdited(taskIdx).Band)));

                for bandIdx = 1:numel(app.TaskListEdited(taskIdx).Band)
                    uitreenode(taskNode, 'Text', getFlowTag(app, taskIdx, bandIdx), 'NodeData', struct('taskIdx', taskIdx, 'bandIdx', bandIdx));
                end
            end

            if ~isempty(selectedNode)
                taskIdx = selectedNode(1);
                bandIdx = selectedNode(2);
            else
                taskIdx = 1;
                bandIdx = 1;
            end

            expand(app.Tree.Children(taskIdx))
            app.Tree.SelectedNodes = app.Tree.Children(taskIdx).Children(bandIdx);
            onTaskTreeSelectionChanged(app)
        end

        %-----------------------------------------------------------------%
        function tag = getFlowTag(app, taskIdx, bandIdx)
            tag = util.HtmlTextGenerator.createTag('Flow', app.TaskListEdited(taskIdx).Band(bandIdx).FreqStart, app.TaskListEdited(taskIdx).Band(bandIdx).FreqStop, app.TaskListEdited(taskIdx).Band(bandIdx).ID);
        end

        %-----------------------------------------------------------------%
        function applyTaskTreeStyle(app)
            if ~isempty(app.Tree.StyleConfigurations)
                removeStyle(app.Tree)
            end

            disableNodes = [];
            for taskIdx = 1:numel(app.TaskListEdited)
                for bandIdx = 1:numel(app.TaskListEdited(taskIdx).Band)
                    if ~app.TaskListEdited(taskIdx).Band(bandIdx).Enable
                        disableNodes = [disableNodes, app.Tree.Children(taskIdx).Children(bandIdx)];
                    end
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
            
            updateObservationPanelElementsState(app)
            updateGpsPanelElementsState(app)

            % Painéis do centro e à direita
            set([
                app.Name;
                app.Duration;
                findobj(app.GpsGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield');
                findobj(app.BandGrid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield')
            ], 'Editable', ~app.ViewMode)

            app.ID.Editable = false;
            updateFindPeaksPanelElementsState(app)

            % Toolbar
            app.ConfirmEditionButtonGrid.Visible = ~app.ViewMode;

            set([
                app.ImportButton;
                app.ExportButton
            ], 'Enable', app.ViewMode)
        end

        %-----------------------------------------------------------------%
        function updateObservationPanelElementsState(app)
            handleTimeElements = findobj(app.SpecificTimeGrid, '-not', {'Type', 'uilabel', '-or', 'Type', 'uigridlayout', '-or', 'Type', 'uipanel'});

            switch app.ObservationType.Value
                case 'Duração'
                    app.TaskGrid.RowHeight{5} = 94; 
                    app.ObservationGrid.RowHeight{3} = 22;

                    set([app.Duration, app.DurationUnit], 'Enable', true, 'Visible', true)
                    set(handleTimeElements, 'Enable', false, 'Visible', false)
                    app.ObservationSamples.Enable = false;

                case 'Período específico'
                    app.TaskGrid.RowHeight{5} = 122;
                    app.ObservationGrid.RowHeight{3} = 0;

                    set([app.Duration, app.DurationUnit], 'Enable', false, 'Visible', false)
                    set(handleTimeElements, 'Enable', ~app.ViewMode, 'Visible', app.ViewMode)
                    app.ObservationSamples.Enable = false;

                case 'Quantidade específica de amostras'
                    app.TaskGrid.RowHeight{5} = 66; 
                    app.ObservationGrid.RowHeight{3} = 0;

                    set([app.Duration, app.DurationUnit], 'Enable', false, 'Visible', false)
                    set(handleTimeElements, 'Enable', false, 'Visible', false)
                    app.ObservationSamples.Enable = true;
            end
        end

        %-----------------------------------------------------------------%
        function updateGpsPanelElementsState(app)
            switch app.GpsMode.Value
                case 'auto'
                    set([app.Latitude, app.Longitude], 'Enable', false)
                    app.GpsRevisitTime.Enable = true;

                case 'manual'
                    set([app.Latitude, app.Longitude], 'Enable', true)
                    app.GpsRevisitTime.Enable = false;
            end
        end

        %-----------------------------------------------------------------%
        function updateFindPeaksPanelElementsState(app)
            set(findobj(app.FindPeaksGrid, 'Type', 'uispinner'), 'Enable', ~app.ViewMode)
        end

        %-----------------------------------------------------------------%
        function updateUIControlContent(app)
            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
            bandIdx = app.Tree.SelectedNodes.NodeData.bandIdx;

            app.Name.Value = app.TaskListEdited(taskIdx).Name;

            app.ID.Value = app.TaskListEdited(taskIdx).Band(bandIdx).ID;
            app.Description.Value = app.TaskListEdited(taskIdx).Band(bandIdx).Description;
            app.ObservationSamples.Value = app.TaskListEdited(taskIdx).Band(bandIdx).ObservationSamples;
            
            app.FreqStart.Value = app.TaskListEdited(taskIdx).Band(bandIdx).FreqStart  / 1e+6;
            app.FreqStop.Value = app.TaskListEdited(taskIdx).Band(bandIdx).FreqStop   / 1e+6;
            app.StepWidth.Value = app.TaskListEdited(taskIdx).Band(bandIdx).StepWidth  / 1e+3;
            app.Resolution.Value = app.TaskListEdited(taskIdx).Band(bandIdx).Resolution / 1e+3;
            
            app.IntegrationFactor.Value = app.TaskListEdited(taskIdx).Band(bandIdx).IntegrationFactor;
            app.RevisitTime.Value = app.TaskListEdited(taskIdx).Band(bandIdx).RevisitTime;

            if app.ViewMode
                app.BitsPerPoint.Items = {sprintf('%d bits', app.TaskListEdited(taskIdx).BitsPerSample)};
                
                app.ObservationType.Items = {util.TaskScriptIO.observationTypeLabel(app.TaskListEdited(taskIdx).Observation.Type)};
                switch app.ObservationType.Value
                    case 'Duração'
                        updateDurationFields(app, taskIdx)

                    case 'Período específico'
                        updateObservationTime(app, taskIdx)
                end
                
                app.GpsMode.Items = {app.TaskListEdited(taskIdx).GPS.Type};
                switch app.GpsMode.Value
                    case 'auto'
                        set([app.Latitude, app.Longitude], 'Value', [])
                        app.GpsRevisitTime.Value = app.TaskListEdited(taskIdx).GPS.RevisitTime;
    
                    case 'manual'
                        app.Latitude.Value  = app.TaskListEdited(idx1).GPS.Latitude;
                        app.Longitude.Value = app.TaskListEdited(idx1).GPS.Longitude;
                        app.GpsRevisitTime.Value = inf;
                end
    
                if app.TaskListEdited(taskIdx).Band(bandIdx).Enable
                    app.Status.Items = {'ON'};
                else
                    app.Status.Items = {'OFF'};
                end

                switch app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Status
                    case 0
                        app.MaskTrigger.Items = {'OFF'};
                    case 1
                        app.MaskTrigger.Items = {'ON - Apenas afere rompimento'};
                    case 2
                        app.MaskTrigger.Items = {'ON - Afere rompimento e salva em arquivo (caso rompida máscara)'};
                    case 3
                        app.MaskTrigger.Items = {'ON - Afere rompimento e salva em arquivo'};
                end
                
                app.TraceMode.Items = {app.TaskListEdited(taskIdx).Band(bandIdx).TraceMode};
                app.RFMode.Items = {app.TaskListEdited(taskIdx).Band(bandIdx).RFMode};
                app.VBW.Items = {app.TaskListEdited(taskIdx).Band(bandIdx).VBW};
                app.Detector.Items = {app.TaskListEdited(taskIdx).Band(bandIdx).Detector};
                app.LevelUnit.Items = {app.TaskListEdited(taskIdx).Band(bandIdx).LevelUnit};

                if isempty(app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration)
                    findPeaksTypeItems = {'Valores padrão (appColeta)'};
                else
                    findPeaksTypeItems = {'Valores customizados'};
                end
                app.FindPeaksType.Items = findPeaksTypeItems;

            else
                app.BitsPerPoint.Items    = {'8 bits', '16 bits', '32 bits'};
                app.ObservationType.Items = {'Duração', 'Período específico', 'Quantidade específica de amostras'};
                app.DurationUnit.Items    = {'min', 'hr'};
                app.GpsMode.Items         = {'auto', 'manual'};
                app.Status.Items          = {'ON', 'OFF'};
                app.MaskTrigger.Items     = {'OFF', 'ON - Apenas afere rompimento', 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)', 'ON - Afere rompimento e salva em arquivo'};
                app.RFMode.Items          = {'High Sensitivity', 'Normal', 'Low Distortion'};
                app.TraceMode.Items       = {'ClearWrite', 'Average', 'MaxHold', 'MinHold'};
                app.Detector.Items        = {'Sample', 'Average/RMS', 'Positive Peak', 'Negative Peak'};
                app.LevelUnit.Items       = {'dBm', 'dBµV'};
                app.VBW.Items             = {'auto', 'RBW', 'RBW/10', 'RBW/100'};
                app.FindPeaksType.Items   = {'Valores padrão (appColeta)', 'Valores customizados'};
            end
        end

        %-----------------------------------------------------------------%
        function updateDurationFields(app, taskIdx)
            durationSeconds = app.TaskListEdited(taskIdx).Observation.Duration;
            if isempty(durationSeconds)
                durationSeconds = 600;
            end

            if durationSeconds >= 3600
                app.Duration.Value = durationSeconds / 3600;
                app.DurationUnit.Items = {'hr'};
            else
                app.Duration.Value = durationSeconds / 60;
                app.DurationUnit.Items = {'min'};
            end
        end

        %-----------------------------------------------------------------%
        function updateObservationTime(app, taskIdx)
            startTime = datetime(app.TaskListEdited(taskIdx).Observation.BeginTime, "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");
            if isnat(startTime)
                startTime = datetime('now');
            end

            endTime = datetime(app.TaskListEdited(taskIdx).Observation.EndTime,     "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");
            if isnat(endTime)
                endTime = datetime('now');
            end

            app.StartDatePicker.Value = startTime;
            app.StartTimeHourSpinner.Value = hour(startTime);
            app.StartTimeMinuteSpinner.Value = minute(startTime);

            app.EndDatePicker.Value = endTime;
            app.EndTimeHourSpinner.Value = hour(endTime);
            app.EndTimeMinuteSpinner.Value = minute(endTime);
        end

        %-----------------------------------------------------------------%
        function SpanCheck(app)
            span = (app.FreqStop.Value - app.FreqStart.Value)*1e+6;

            if span <= 0
                app.FreqStart.FontColor = [1 0 0];
                app.FreqStop.FontColor  = [1 0 0];
                app.StepWidth.Enable    = 0;
            else
                app.FreqStart.FontColor = [0 0 0];
                app.FreqStop.FontColor  = [0 0 0];
                app.StepWidth.Enable    = 1;
            end
        end

        %-----------------------------------------------------------------%
        function IntegrationFactorCheck(app)
            switch app.TraceMode.Value
                case 'ClearWrite'
                    set(app.IntegrationFactor, 'Enable', 0, 'Value', 1)

                otherwise
                    app.IntegrationFactor.Enable = 1;

                    if app.IntegrationFactor.Value == 1
                        app.IntegrationFactor.Value = 3;
                    end
            end
        end

        %-----------------------------------------------------------------%
        function updateBandIds(app)
            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;

            for bandIdx = 1:numel(app.TaskListEdited(taskIdx).Band)
                app.TaskListEdited(taskIdx).Band(bandIdx).ID = bandIdx;
            end
        end

        %-----------------------------------------------------------------%
        function updateTaskFile(app)
            appName = class.Constants.appName;
            [~, programDataFolder] = appEngine.util.Path(appName, app.mainApp.rootFolder);
            saveTaskFile(app, programDataFolder, false)

            % Atualiza a propriedade do app e força o fechamento do módulo
            % auxiliar auxApp.winAddTask, caso aberto.
            ipcMainMatlabCallsHandler(app.mainApp, app, 'onTaskListEdit')
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcn', 'TASK_ADD')
        end

        %-----------------------------------------------------------------%
        function saveTaskFile(app, folder, showAlert)
            msgError = util.TaskScriptIO.writeScriptFile(folder, app.TaskList);

            if showAlert
                if isempty(msgError)
                    ui.Dialog(app.UIFigure, "warning", sprintf('Arquivo <b>TaskList.json</b> salvo na pasta "%s"', folder));
                else
                    ui.Dialog(app.UIFigure, "error", msgError);
                end
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
        function onTaskTreeSelectionChanged(app, event)
            
            if exist('event', 'var')
                if isempty(event.SelectedNodes)
                    app.Tree.SelectedNodes = event.PreviousSelectedNodes;
                    return
                end
            end

            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
            bandIdx = app.Tree.SelectedNodes.NodeData.bandIdx;
            
            if app.Tree.SelectedNodes.Parent == app.Tree || ~isscalar(bandIdx)
                bandIdx = 1;
                app.Tree.SelectedNodes = app.Tree.Children(taskIdx).Children(bandIdx);
            end

            applyTaskTreeStyle(app)
            
            if exist('event', 'var') && ~isequal(taskIdx, event.PreviousSelectedNodes.NodeData.taskIdx)
                collapse(app.Tree)
                expand(app.Tree.Children(taskIdx))
            end

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
                    hasChanged = ~isequal(app.TaskList, app.TaskListEdited);

                    if hasChanged
                        questionMsg = [ ...
                            'Foi evidenciada alteração de ao menos uma das tarefas. ' ...
                            'Ao sair do modo de edição, sem salvar as alterações, ' ...
                            'elas serão perdidas.<br><br>Confirma sair do modo de edição?' ...
                        ];
                        userSelection = ui.Dialog(app.UIFigure, 'uiconfirm', questionMsg, {'Sim', 'Não'}, 1, 2);

                        if userSelection == "Não"
                            app.ViewStateButton.Value = false;
                            return
                        end
                    end

                    app.ViewMode = ~app.ViewMode;
                    
                    if hasChanged
                        app.TaskListEdited = app.TaskList;

                        taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
                        bandIdx = app.Tree.SelectedNodes.NodeData.bandIdx;
                        buildTaskTree(app, [taskIdx, bandIdx])
                        return
                    end

                case app.EditStateButton
                    app.ViewMode = ~app.ViewMode;
            end

            updateUIControlState(app)
            updateUIControlContent(app)
            
        end

        % Value changed function: ObservationType
        function onObservationTypeValueChanged(app, event)
            
            updateObservationPanelElementsState(app)
            
            taskIdx = app.Tree.SelectedNodes.NodeData;            
            switch app.ObservationType.Value
                case 'Duração'                                              % "Duration"
                    updateDuration(app, taskIdx)
                    onTaskParameterValueChanged(app, struct('Source', app.Duration))

                case 'Período específico'                                   % "Time"
                    updateObservationTime(app, taskIdx)
                    onTaskParameterValueChanged(app, struct('Source', app.StartDatePicker))

                case 'Quantidade específica de amostras'                    % "Samples"
                    onTaskParameterValueChanged(app, struct('Source', app.ObservationSamples))
            end
            
        end

        % Value changed function: GpsMode
        function onGpsModeValueChanged(app, event)
            
            app.Latitude.Value  = -1;
            app.Longitude.Value = -1;
            app.GpsRevisitTime.Value     = 60;
            set(app.GpsGrid.Children, Enable='on')

            % Após a leitura do arquivo "TaskList.json", uma tarefa com GPS
            % automático tem informação vazia de coordenadas geográficas
            % (latitude, longitude). Ao editar o tipo de GPS, trocando de
            % automático para manual, os valores iniciais serão (-1,-1), os
            % quais foram definidos no topo da função. O bloco try/catch
            % evita o erro de preenchimento do componente numérico com um
            % valor vazio.

            idx1 = app.Tree.SelectedNodes.NodeData.taskIdx;

            switch app.GpsMode.Value
                case 'auto'
                    app.Latitude.Enable     = 'off';
                    app.Longitude.Enable    = 'off';
                    app.GpsRevisitTime.Value         = app.TaskListEdited(idx1).GPS.RevisitTime;

                case 'manual'
                    try
                        app.Latitude.Value  = app.TaskListEdited(idx1).GPS.Latitude;
                        app.Longitude.Value = app.TaskListEdited(idx1).GPS.Longitude;
                    catch
                    end
                    app.GpsRevisitTime.Enable        = 'off';
            end

            onTaskParameterValueChanged(app, struct('Source', app.GpsMode))

        end

        % Value changed function: FindPeaksType
        function FindPeaksDropDownValueChanged(app, event)
            
            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
            bandIdx = app.Tree.SelectedNodes.NodeData.bandIdx;

            switch app.FindPeaksType.Value
                case 'Valores padrão (appColeta)'
                    set(findobj(app.FindPeaksGrid, 'Type', 'uispinner'), Enable=0)

                    defaultConfiguration = class.Constants.defaultMaskConfiguration;
                    app.FindPeaksNumSweeps.Value    = defaultConfiguration.sweepsPerValidation;
                    app.FindPeaksMinProminence.Value = defaultConfiguration.peakDetection.minimumProminence;
                    app.FindPeaksMinDistance.Value   = defaultConfiguration.peakDetection.minimumDistanceKHz;
                    app.FindPeaksMinBandWidth.Value         = defaultConfiguration.peakDetection.minimumWidthKHz;

                    if ~app.ViewMode
                        app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration = [];
                    end

                case 'Valores customizados'
                    updateFindPeaksPanelElementsState(app)
                    if isempty(app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration)
                        app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration = class.Constants.defaultMaskConfiguration;
                    end

                    customConfiguration = app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration;
                    app.FindPeaksNumSweeps.Value    = customConfiguration.sweepsPerValidation;
                    app.FindPeaksMinProminence.Value = customConfiguration.peakDetection.minimumProminence;
                    app.FindPeaksMinDistance.Value   = customConfiguration.peakDetection.minimumDistanceKHz;
                    app.FindPeaksMinBandWidth.Value         = customConfiguration.peakDetection.minimumWidthKHz;

                    if ~app.ViewMode
                        app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration = struct( ...
                            'sweepsPerValidation', app.FindPeaksNumSweeps.Value, ...
                            'peakDetection', struct( ...
                                'minimumProminence',  app.FindPeaksMinProminence.Value, ...
                                'minimumDistanceKHz', app.FindPeaksMinDistance.Value, ...
                                'minimumWidthKHz',    app.FindPeaksMinBandWidth.Value ...
                            ) ...
                        );
                    end
            end
            
        end

        % Image clicked function: ExportButton, ImportButton
        function onToolbarButtonClicked(app, event)
            
            switch event.Source
                case app.ImportButton
                    [selectedFile, selectedFolder] = uigetfile({'*.json', '*.json'}, 'Selecione um arquivo', 'MultiSelect', 'off');
                    figure(app.UIFigure)
        
                    if selectedFile
                    [tempList, msgError] =  util.TaskScriptIO.readScriptFile(fullfile(selectedFolder, selectedFile), 'auxApp.winEditTaskList');
        
                        if isempty(msgError)
                            app.TaskList   = [app.TaskList; tempList];
                            app.TaskListEdited = app.TaskList;
                            updateTaskFile(app)
        
                            buildTaskTree(app, [])
                        else
                            ui.Dialog(app.UIFigure, "error", msgError);
                        end
                    end

                case app.ExportButton
                    selectedFolder = uigetdir(app.mainApp.General.fileFolder.userPath, 'Escolha o diretório em que será salva a lista de tarefas');
                    figure(app.UIFigure)
        
                    if selectedFolder
                        saveTaskFile(app, selectedFolder, true)
                    end
            end

        end

        % Image clicked function: TreeAddTaskNode
        function TreeAddTaskNodePushed(app, event)
            
            taskIdxPrevious = app.Tree.SelectedNodes.NodeData.taskIdx;
            taskIdxCurrent = numel(app.TaskListEdited) + 1;
            bandIdx = 1;

            app.TaskListEdited(taskIdxCurrent) = app.TaskListEdited(taskIdxPrevious);
            app.TaskListEdited(taskIdxCurrent).Name = sprintf('%s (Cópia)', app.TaskListEdited(taskIdxPrevious).Name);
            
            buildTaskTree(app, [taskIdxCurrent, bandIdx])

        end

        % Image clicked function: TreeAddBandNode
        function TreeAddBandNodeValueChanged(app, event)
            
            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
            bandIdxPrevious = app.Tree.SelectedNodes.NodeData.bandIdx;
            bandIdxCurrent = numel(app.TaskListEdited(taskIdx).Band) + 1;

            if app.Tree.SelectedNodes.Parent == app.Tree
                app.TaskListEdited(taskIdx).Band(bandIdxCurrent) = app.TaskListEdited(taskIdx).Band(1);
            else
                app.TaskListEdited(taskIdx).Band(bandIdxCurrent) = app.TaskListEdited(taskIdx).Band(bandIdxPrevious);
            end
             app.TaskListEdited(taskIdx).Band(bandIdxCurrent).ID = bandIdxCurrent;
            
            buildTaskTree(app, [taskIdx, bandIdxCurrent])

        end

        % Image clicked function: TreeDelNode
        function TreeDelNodePushed(app, event)
            
            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
            bandIdx = app.Tree.SelectedNodes.NodeData.bandIdx;
            
            if app.Tree.SelectedNodes.Parent == app.Tree
                if numel(app.TaskListEdited) > 1
                    app.TaskListEdited(taskIdx) = [];
                    buildTaskTree(app, [1, -1])

                else
                    ui.Dialog(app.UIFigure, "warning", 'Não é possível excluir a única tarefa.');
                    return
                end

            else
                if numel(app.TaskListEdited(taskIdx).Band) > 1
                    app.TaskListEdited(taskIdx).Band(bandIdx) = [];
                    updateBandIds(app)
                    buildTaskTree(app, [taskIdx, 1])

                else
                    ui.Dialog(app.UIFigure, "warning", 'Não é possível excluir a única faixa de frequência da tarefa.');
                    return
                end
            end            

        end

        % Button pushed function: ConfirmEditionButton
        function ConfirmEditionButtonPushed(app, event)
            
            % Finalizada a edição, avalia-se se algum parâmetro foi, de fato, 
            % alterado, salvando uma nova versão do arquivo "TaskList.json",
            % caso necessário.

            if ~isequal(app.TaskList, app.TaskListEdited)
                % Validaçao dos valores das faixas - os outros campos já são 
                % validados pelos próprios componentes da interface.                
                for ii = 1:numel(app.TaskListEdited)
                    for jj = 1:numel(app.TaskListEdited(ii).Band)
                        freqStart = app.TaskListEdited(ii).Band.FreqStart;
                        freqStop  = app.TaskListEdited(ii).Band.FreqStop;

                        if freqStart >= freqStop
                            ui.Dialog(app.UIFigure, "warning", sprintf('A faixa <b>%.3f - %.3f MHz</b>, da tarefa "%s", é inválida. A frequência final de uma faixa deve ser superior à inicial.', freqStart/1e+6, freqStop/1e+6, app.TaskListEdited(ii).Name));
                            return
                        end
                    end
                end

                app.TaskList = app.TaskListEdited;
                updateTaskFile(app)
            end
            
            app.ViewMode = true;
            OperationModeValueChanged(app)

        end

        % Value changed function: BitsPerPoint, Description, Detector, 
        % ...and 29 other components
        function onTaskParameterValueChanged(app, event)
            
            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
            bandIdx = app.Tree.SelectedNodes.NodeData.bandIdx;

            switch event.Source
                %---------------------------------------------------------%
                % Painel "ASPECTOS GERAIS"
                %---------------------------------------------------------%
                case app.Name
                    app.TaskListEdited(taskIdx).Name    = app.Name.Value;
                    app.Tree.Children(taskIdx).Text = app.Name.Value;

                case app.BitsPerPoint
                    app.TaskListEdited(taskIdx).BitsPerSample = str2double(extractBefore(app.BitsPerPoint.Value, 'bits'));
                
                case {app.Duration, app.DurationUnit}
                    app.TaskListEdited(taskIdx).Observation.Type = 'Duration';
                    switch app.DurationUnit.Value
                        case 'min'
                            app.TaskListEdited(taskIdx).Observation.Duration = app.Duration.Value * 60;
                        case 'hr'
                            app.TaskListEdited(taskIdx).Observation.Duration = app.Duration.Value * 3600;
                    end

                case {app.StartDatePicker, app.StartTimeHourSpinner, app.StartTimeMinuteSpinner, app.EndDatePicker, app.EndTimeHourSpinner, app.EndTimeMinuteSpinner}
                    app.TaskListEdited(taskIdx).Observation.Type = 'Time';

                    BeginTime = app.StartDatePicker.Value + hours(app.StartTimeHourSpinner.Value) + minutes(app.StartTimeMinuteSpinner.Value);
                    EndTime   = app.EndDatePicker.Value + hours(app.EndTimeHourSpinner.Value) + minutes(app.EndTimeMinuteSpinner.Value);

                    app.TaskListEdited(taskIdx).Observation.BeginTime = datestr(BeginTime, 'dd/mm/yyyy HH:MM:ss');
                    app.TaskListEdited(taskIdx).Observation.EndTime   = datestr(EndTime,   'dd/mm/yyyy HH:MM:ss');

                case {app.GpsMode, app.Latitude, app.Longitude, app.GpsRevisitTime}
                    switch app.GpsMode.Value
                        case 'auto'
                            app.TaskListEdited(taskIdx).GPS = struct('Type',        'auto', ...
                                                              'Latitude',    [],     ...
                                                              'Longitude',   [],     ...
                                                              'RevisitTime', app.GpsRevisitTime.Value);
                        case 'manual'
                            app.TaskListEdited(taskIdx).GPS = struct('Type',        'manual',                      ...
                                                              'Latitude',    app.Latitude.Value,  ...
                                                              'Longitude',   app.Longitude.Value, ...
                                                              'RevisitTime', app.GpsRevisitTime.Value);
                    end

                %---------------------------------------------------------%                
                % Painel "ESPECIFICIDADES DO FLUXO SELECIONADO"
                %---------------------------------------------------------%
                case app.Status
                    if isscalar(app.TaskListEdited(taskIdx).Band)
                        app.Status.Value = "ON";
                        ui.Dialog(app.UIFigure, "warning", 'Tarefa com apenas uma única faixa de frequência não pode ter essa faixa com o estado "OFF".');
                        return

                    else
                        if app.Status.Value == "ON"
                            app.TaskListEdited(taskIdx).Band(bandIdx).Enable = 1;
                        else
                            app.TaskListEdited(taskIdx).Band(bandIdx).Enable = 0;
                        end

                        if all(~[app.TaskListEdited(taskIdx).Band.Enable])
                            app.TaskListEdited(taskIdx).Band(bandIdx).Enable = 1;

                            app.Status.Value = "ON";
                            ui.Dialog(app.UIFigure, "warning", 'Toda tarefa deve possuir ao menos uma faixa de frequência com o estado "ON".');
                            return
                        end
    
                        applyTaskTreeStyle(app)
                    end

                case app.MaskTrigger
                    switch app.MaskTrigger.Value
                        case 'OFF'
                            app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Status = 0;
                        case 'ON - Apenas afere rompimento'
                            app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Status = 1;
                        case 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)'
                            app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Status = 2;
                        case 'ON - Afere rompimento e salva em arquivo'
                            app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Status = 3;
                    end

                    app.FindPeaksType.Enable = ~strcmp(app.MaskTrigger.Value, 'OFF');

                case app.Description
                    app.TaskListEdited(taskIdx).Band(bandIdx).Description = app.Description.Value;

                case app.ObservationSamples
                    app.TaskListEdited(taskIdx).Observation.Type = 'Samples';
                    if isscalar(bandIdx)
                        app.TaskListEdited(taskIdx).Band(bandIdx).ObservationSamples = app.ObservationSamples.Value;
                    end

                case app.FreqStart
                    app.TaskListEdited(taskIdx).Band(bandIdx).FreqStart   = app.FreqStart.Value * 1e+6;
                    app.Tree.Children(taskIdx).Children(bandIdx).Text = getFlowTag(app, taskIdx, bandIdx);
                    SpanCheck(app)
                    
                case app.FreqStop
                    app.TaskListEdited(taskIdx).Band(bandIdx).FreqStop    = app.FreqStop.Value * 1e+6;
                    app.Tree.Children(taskIdx).Children(bandIdx).Text = getFlowTag(app, taskIdx, bandIdx);
                    SpanCheck(app)

                case app.StepWidth
                    app.TaskListEdited(taskIdx).Band(bandIdx).StepWidth = app.StepWidth.Value * 1e+3;

                case app.Resolution
                    app.TaskListEdited(taskIdx).Band(bandIdx).Resolution = app.Resolution.Value * 1e+3;

                case app.TraceMode
                    app.TaskListEdited(taskIdx).Band(bandIdx).TraceMode = app.TraceMode.Value;
                    IntegrationFactorCheck(app)
                    app.TaskListEdited(taskIdx).Band(bandIdx).IntegrationFactor = app.IntegrationFactor.Value;

                case app.IntegrationFactor
                    app.TaskListEdited(taskIdx).Band(bandIdx).IntegrationFactor = app.IntegrationFactor.Value;

                case app.RFMode
                    app.TaskListEdited(taskIdx).Band(bandIdx).RFMode = app.RFMode.Value;

                case app.VBW
                    app.TaskListEdited(taskIdx).Band(bandIdx).VBW = app.VBW.Value;

                case app.Detector
                    app.TaskListEdited(taskIdx).Band(bandIdx).Detector = app.Detector.Value;

                case app.LevelUnit
                    app.TaskListEdited(taskIdx).Band(bandIdx).LevelUnit = app.LevelUnit.Value;

                case app.RevisitTime
                    app.TaskListEdited(taskIdx).Band(bandIdx).RevisitTime = app.RevisitTime.Value;

                %---------------------------------------------------------%
                % Subpainel "FINDPEAKS"
                %---------------------------------------------------------%
                case app.FindPeaksNumSweeps
                    app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration.sweepsPerValidation = app.FindPeaksNumSweeps.Value;

                case app.FindPeaksMinProminence
                    app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration.minimumProminence = app.FindPeaksMinProminence.Value;

                case app.FindPeaksMinDistance
                    app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration.minimumDistanceKHz = app.FindPeaksMinDistance.Value;

                case app.FindPeaksMinBandWidth
                    app.TaskListEdited(taskIdx).Band(bandIdx).MaskTrigger.Configuration.minimumWidthKHz = app.FindPeaksMinBandWidth.Value;
            end
            
        end

        % Image clicked function: TreeMoveDown, TreeMoveUp
        function UpDownImageClicked(app, event)
            
            taskIdx = app.Tree.SelectedNodes.NodeData.taskIdx;
            bandIdx = app.Tree.SelectedNodes.NodeData.bandIdx;

            Flag = 0;

            switch event.Source
                case app.TreeMoveUp
                    if app.Tree.SelectedNodes.Parent == app.Tree
                        if taskIdx > 1
                            app.TaskListEdited(taskIdx-1:taskIdx) = flip(app.TaskListEdited(taskIdx-1:taskIdx));

                            Flag = 1;
                            taskIdx = taskIdx-1;
                        end
                    else
                        if bandIdx > 1
                            app.TaskListEdited(taskIdx).Band(bandIdx-1:bandIdx) = flip(app.TaskListEdited(taskIdx).Band(bandIdx-1:bandIdx));
                            updateBandIds(app)

                            Flag = 1;
                            bandIdx = bandIdx-1;
                        end
                    end

                case app.TreeMoveDown
                    if app.Tree.SelectedNodes.Parent == app.Tree
                        if taskIdx < numel(app.TaskListEdited)
                            app.TaskListEdited(taskIdx:taskIdx+1) = flip(app.TaskListEdited(taskIdx:taskIdx+1));

                            Flag = 1;
                            taskIdx = taskIdx+1;
                        end
                    else
                        if bandIdx < numel(app.TaskListEdited(taskIdx).Band)
                            app.TaskListEdited(taskIdx).Band(bandIdx:bandIdx+1) = flip(app.TaskListEdited(taskIdx).Band(bandIdx:bandIdx+1));
                            updateBandIds(app)

                            Flag = 1;
                            bandIdx = bandIdx+1;
                        end
                    end
            end

            if Flag
                if app.Tree.SelectedNodes.Parent == app.Tree
                    buildTaskTree(app, [taskIdx, -1])
                else
                    buildTaskTree(app, [taskIdx, bandIdx])
                end
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
            app.GridLayout.ColumnWidth = {20, 160, 160, 10, 320, 10, '1x', 122, 16, 22, 10, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 10, 14, '1x', 10, 34, 20, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create TreePanel
            app.TreePanel = uigridlayout(app.GridLayout);
            app.TreePanel.ColumnWidth = {24, '1x', 0};
            app.TreePanel.RowHeight = {36, 36, 16, 5, 16, 5, 16, '1x', 16, 16, 5, 16, 2};
            app.TreePanel.ColumnSpacing = 5;
            app.TreePanel.RowSpacing = 0;
            app.TreePanel.Padding = [0 0 0 0];
            app.TreePanel.Layout.Row = [4 5];
            app.TreePanel.Layout.Column = [2 3];
            app.TreePanel.BackgroundColor = [1 1 1];

            % Create TreeIcon
            app.TreeIcon = uiimage(app.TreePanel);
            app.TreeIcon.ScaleMethod = 'none';
            app.TreeIcon.Layout.Row = 1;
            app.TreeIcon.Layout.Column = 1;
            app.TreeIcon.VerticalAlignment = 'top';
            app.TreeIcon.ImageSource = 'server-process - blue.svg';

            % Create Tree
            app.Tree = uitree(app.TreePanel);
            app.Tree.SelectionChangedFcn = createCallbackFcn(app, @onTaskTreeSelectionChanged, true);
            app.Tree.FontSize = 11;
            app.Tree.FontColor = [0.2 0.2 0.2];
            app.Tree.Layout.Row = [3 13];
            app.Tree.Layout.Column = [1 2];

            % Create TreeAddTaskNode
            app.TreeAddTaskNode = uiimage(app.TreePanel);
            app.TreeAddTaskNode.ImageClickedFcn = createCallbackFcn(app, @TreeAddTaskNodePushed, true);
            app.TreeAddTaskNode.Enable = 'off';
            app.TreeAddTaskNode.Tooltip = {''};
            app.TreeAddTaskNode.Layout.Row = 3;
            app.TreeAddTaskNode.Layout.Column = 3;
            app.TreeAddTaskNode.ImageSource = 'addFileWithPlus_32.png';

            % Create TreeAddBandNode
            app.TreeAddBandNode = uiimage(app.TreePanel);
            app.TreeAddBandNode.ImageClickedFcn = createCallbackFcn(app, @TreeAddBandNodeValueChanged, true);
            app.TreeAddBandNode.Enable = 'off';
            app.TreeAddBandNode.Tooltip = {''};
            app.TreeAddBandNode.Layout.Row = 5;
            app.TreeAddBandNode.Layout.Column = 3;
            app.TreeAddBandNode.ImageSource = 'EditWithPlus_32.png';

            % Create TreeDelNode
            app.TreeDelNode = uiimage(app.TreePanel);
            app.TreeDelNode.ImageClickedFcn = createCallbackFcn(app, @TreeDelNodePushed, true);
            app.TreeDelNode.Enable = 'off';
            app.TreeDelNode.Tooltip = {''};
            app.TreeDelNode.Layout.Row = 7;
            app.TreeDelNode.Layout.Column = 3;
            app.TreeDelNode.ImageSource = 'Delete_32Red.png';

            % Create TreeMoveUp
            app.TreeMoveUp = uiimage(app.TreePanel);
            app.TreeMoveUp.ImageClickedFcn = createCallbackFcn(app, @UpDownImageClicked, true);
            app.TreeMoveUp.Enable = 'off';
            app.TreeMoveUp.Tooltip = {''};
            app.TreeMoveUp.Layout.Row = 10;
            app.TreeMoveUp.Layout.Column = 3;
            app.TreeMoveUp.ImageSource = 'ArrowUp_32.png';

            % Create TreeMoveDown
            app.TreeMoveDown = uiimage(app.TreePanel);
            app.TreeMoveDown.ImageClickedFcn = createCallbackFcn(app, @UpDownImageClicked, true);
            app.TreeMoveDown.Enable = 'off';
            app.TreeMoveDown.Tooltip = {''};
            app.TreeMoveDown.Layout.Row = 12;
            app.TreeMoveDown.Layout.Column = 3;
            app.TreeMoveDown.ImageSource = 'ArrowDown_32.png';

            % Create TreeTitle
            app.TreeTitle = uilabel(app.TreePanel);
            app.TreeTitle.VerticalAlignment = 'top';
            app.TreeTitle.WordWrap = 'on';
            app.TreeTitle.FontSize = 15;
            app.TreeTitle.FontColor = [0 0.4471 0.7412];
            app.TreeTitle.Layout.Row = [1 2];
            app.TreeTitle.Layout.Column = [2 3];
            app.TreeTitle.Interpreter = 'html';
            app.TreeTitle.Text = {'<b>Lista de tarefas de monitoração</b>'; '<font style="color: gray; font-size: 11px;">Selecione uma tarefa para visualizar seus detalhes, editar parâmetros e gerenciar as faixas de frequência</font>'};

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
            app.TaskPanel.AutoResizeChildren = 'off';
            app.TaskPanel.Layout.Row = [4 7];
            app.TaskPanel.Layout.Column = 5;

            % Create TaskGrid
            app.TaskGrid = uigridlayout(app.TaskPanel);
            app.TaskGrid.ColumnWidth = {'1x', 110};
            app.TaskGrid.RowHeight = {34, 17, 22, 22, 94, 22, 22, '1x'};
            app.TaskGrid.RowSpacing = 5;
            app.TaskGrid.BackgroundColor = [1 1 1];

            % Create TaskTitle
            app.TaskTitle = uilabel(app.TaskGrid);
            app.TaskTitle.VerticalAlignment = 'top';
            app.TaskTitle.WordWrap = 'on';
            app.TaskTitle.FontColor = [0 0.4471 0.7412];
            app.TaskTitle.Layout.Row = 1;
            app.TaskTitle.Layout.Column = [1 2];
            app.TaskTitle.Interpreter = 'html';
            app.TaskTitle.Text = {'<b>Tarefa selecionada</b>'; '<font style="color: gray; font-size: 10px;">Configurações gerais da tarefa de monitoração</font>'};

            % Create NameLabel
            app.NameLabel = uilabel(app.TaskGrid);
            app.NameLabel.VerticalAlignment = 'bottom';
            app.NameLabel.FontSize = 10;
            app.NameLabel.Layout.Row = 2;
            app.NameLabel.Layout.Column = 1;
            app.NameLabel.Text = 'NOME';

            % Create Name
            app.Name = uieditfield(app.TaskGrid, 'text');
            app.Name.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Name.Editable = 'off';
            app.Name.FontSize = 11;
            app.Name.Layout.Row = 3;
            app.Name.Layout.Column = 1;

            % Create BitsPerPointLabel
            app.BitsPerPointLabel = uilabel(app.TaskGrid);
            app.BitsPerPointLabel.VerticalAlignment = 'bottom';
            app.BitsPerPointLabel.FontSize = 10;
            app.BitsPerPointLabel.Layout.Row = 2;
            app.BitsPerPointLabel.Layout.Column = 2;
            app.BitsPerPointLabel.Text = 'CODIFICAÇÃO';

            % Create BitsPerPoint
            app.BitsPerPoint = uidropdown(app.TaskGrid);
            app.BitsPerPoint.Items = {'8 bits', '16 bits', '32 bits'};
            app.BitsPerPoint.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.BitsPerPoint.FontSize = 11;
            app.BitsPerPoint.BackgroundColor = [1 1 1];
            app.BitsPerPoint.Layout.Row = 3;
            app.BitsPerPoint.Layout.Column = 2;
            app.BitsPerPoint.Value = '8 bits';

            % Create ObservationLabel
            app.ObservationLabel = uilabel(app.TaskGrid);
            app.ObservationLabel.VerticalAlignment = 'bottom';
            app.ObservationLabel.FontSize = 10;
            app.ObservationLabel.Layout.Row = 4;
            app.ObservationLabel.Layout.Column = 1;
            app.ObservationLabel.Text = 'PERÍODO DE OBSERVAÇÃO';

            % Create ObservationPanel
            app.ObservationPanel = uipanel(app.TaskGrid);
            app.ObservationPanel.AutoResizeChildren = 'off';
            app.ObservationPanel.Layout.Row = 5;
            app.ObservationPanel.Layout.Column = [1 2];

            % Create ObservationGrid
            app.ObservationGrid = uigridlayout(app.ObservationPanel);
            app.ObservationGrid.ColumnWidth = {'1x'};
            app.ObservationGrid.RowHeight = {17, 22, 22, 49};
            app.ObservationGrid.ColumnSpacing = 11;
            app.ObservationGrid.RowSpacing = 5;
            app.ObservationGrid.BackgroundColor = [1 1 1];

            % Create ObservationTypeLabel
            app.ObservationTypeLabel = uilabel(app.ObservationGrid);
            app.ObservationTypeLabel.VerticalAlignment = 'bottom';
            app.ObservationTypeLabel.FontSize = 11;
            app.ObservationTypeLabel.Layout.Row = 1;
            app.ObservationTypeLabel.Layout.Column = 1;
            app.ObservationTypeLabel.Text = 'Critério de término:';

            % Create ObservationType
            app.ObservationType = uidropdown(app.ObservationGrid);
            app.ObservationType.Items = {'Duração', 'Período específico', 'Quantidade específica de amostras'};
            app.ObservationType.ValueChangedFcn = createCallbackFcn(app, @onObservationTypeValueChanged, true);
            app.ObservationType.Tag = 'task_Editable';
            app.ObservationType.FontSize = 11;
            app.ObservationType.BackgroundColor = [1 1 1];
            app.ObservationType.Layout.Row = 2;
            app.ObservationType.Layout.Column = 1;
            app.ObservationType.Value = 'Duração';

            % Create DurationGrid
            app.DurationGrid = uigridlayout(app.ObservationGrid);
            app.DurationGrid.ColumnWidth = {133, '100x'};
            app.DurationGrid.RowHeight = {'1x'};
            app.DurationGrid.RowSpacing = 5;
            app.DurationGrid.Padding = [0 0 0 0];
            app.DurationGrid.Layout.Row = 3;
            app.DurationGrid.Layout.Column = 1;
            app.DurationGrid.BackgroundColor = [1 1 1];

            % Create Duration
            app.Duration = uieditfield(app.DurationGrid, 'numeric');
            app.Duration.Limits = [1 Inf];
            app.Duration.ValueDisplayFormat = '%.3f';
            app.Duration.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Duration.Tag = 'task_Editable';
            app.Duration.Editable = 'off';
            app.Duration.FontSize = 11;
            app.Duration.Layout.Row = 1;
            app.Duration.Layout.Column = 1;
            app.Duration.Value = 10;

            % Create DurationUnit
            app.DurationUnit = uidropdown(app.DurationGrid);
            app.DurationUnit.Items = {'min', 'hr'};
            app.DurationUnit.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.DurationUnit.Tag = 'task_Editable';
            app.DurationUnit.FontSize = 11;
            app.DurationUnit.BackgroundColor = [1 1 1];
            app.DurationUnit.Layout.Row = 1;
            app.DurationUnit.Layout.Column = 2;
            app.DurationUnit.Value = 'min';

            % Create SpecificTimeGrid
            app.SpecificTimeGrid = uigridlayout(app.ObservationGrid);
            app.SpecificTimeGrid.ColumnWidth = {64, 5, 64, 10, 64, 5, 64};
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
            app.StartDatePicker.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
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
            app.StartTimeHourSpinner.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
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
            app.StartTimeMinuteSpinner.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.StartTimeMinuteSpinner.HorizontalAlignment = 'center';
            app.StartTimeMinuteSpinner.FontSize = 11;
            app.StartTimeMinuteSpinner.Enable = 'off';
            app.StartTimeMinuteSpinner.Visible = 'off';
            app.StartTimeMinuteSpinner.Layout.Row = 2;
            app.StartTimeMinuteSpinner.Layout.Column = 3;

            % Create EndDatePicker
            app.EndDatePicker = uidatepicker(app.SpecificTimeGrid);
            app.EndDatePicker.DisplayFormat = 'dd/MM/uuuu';
            app.EndDatePicker.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
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
            app.EndTimeHourSpinner.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
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
            app.EndTimeMinuteSpinner.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.EndTimeMinuteSpinner.HorizontalAlignment = 'center';
            app.EndTimeMinuteSpinner.FontSize = 11;
            app.EndTimeMinuteSpinner.Enable = 'off';
            app.EndTimeMinuteSpinner.Visible = 'off';
            app.EndTimeMinuteSpinner.Layout.Row = 2;
            app.EndTimeMinuteSpinner.Layout.Column = 7;
            app.EndTimeMinuteSpinner.Value = 59;

            % Create GpsModeLabel
            app.GpsModeLabel = uilabel(app.TaskGrid);
            app.GpsModeLabel.VerticalAlignment = 'bottom';
            app.GpsModeLabel.FontSize = 10;
            app.GpsModeLabel.Layout.Row = 6;
            app.GpsModeLabel.Layout.Column = 1;
            app.GpsModeLabel.Text = 'GPS';

            % Create GpsMode
            app.GpsMode = uidropdown(app.TaskGrid);
            app.GpsMode.Items = {'auto', 'manual'};
            app.GpsMode.ValueChangedFcn = createCallbackFcn(app, @onGpsModeValueChanged, true);
            app.GpsMode.Tag = 'task_Editable';
            app.GpsMode.FontSize = 11;
            app.GpsMode.BackgroundColor = [1 1 1];
            app.GpsMode.Layout.Row = 7;
            app.GpsMode.Layout.Column = [1 2];
            app.GpsMode.Value = 'auto';

            % Create GpsPanel
            app.GpsPanel = uipanel(app.TaskGrid);
            app.GpsPanel.AutoResizeChildren = 'off';
            app.GpsPanel.Layout.Row = 8;
            app.GpsPanel.Layout.Column = [1 2];

            % Create GpsGrid
            app.GpsGrid = uigridlayout(app.GpsPanel);
            app.GpsGrid.ColumnWidth = {133, 133};
            app.GpsGrid.RowHeight = {17, 22, 22, 22};
            app.GpsGrid.RowSpacing = 5;
            app.GpsGrid.BackgroundColor = [1 1 1];

            % Create LatitudeLabel
            app.LatitudeLabel = uilabel(app.GpsGrid);
            app.LatitudeLabel.VerticalAlignment = 'bottom';
            app.LatitudeLabel.FontSize = 11;
            app.LatitudeLabel.Layout.Row = 1;
            app.LatitudeLabel.Layout.Column = 1;
            app.LatitudeLabel.Text = 'Latitude (º):';

            % Create Latitude
            app.Latitude = uieditfield(app.GpsGrid, 'numeric');
            app.Latitude.ValueDisplayFormat = '%.6f';
            app.Latitude.AllowEmpty = 'on';
            app.Latitude.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Latitude.Tag = 'task_Editable';
            app.Latitude.Editable = 'off';
            app.Latitude.FontSize = 11;
            app.Latitude.Enable = 'off';
            app.Latitude.Layout.Row = 2;
            app.Latitude.Layout.Column = 1;
            app.Latitude.Value = [];

            % Create LongitudeLabel
            app.LongitudeLabel = uilabel(app.GpsGrid);
            app.LongitudeLabel.VerticalAlignment = 'bottom';
            app.LongitudeLabel.FontSize = 11;
            app.LongitudeLabel.Layout.Row = 1;
            app.LongitudeLabel.Layout.Column = 2;
            app.LongitudeLabel.Text = 'Longitude (º):';

            % Create Longitude
            app.Longitude = uieditfield(app.GpsGrid, 'numeric');
            app.Longitude.ValueDisplayFormat = '%.6f';
            app.Longitude.AllowEmpty = 'on';
            app.Longitude.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Longitude.Tag = 'task_Editable';
            app.Longitude.Editable = 'off';
            app.Longitude.FontSize = 11;
            app.Longitude.Enable = 'off';
            app.Longitude.Layout.Row = 2;
            app.Longitude.Layout.Column = 2;
            app.Longitude.Value = [];

            % Create GpsRevisitTimeLabel
            app.GpsRevisitTimeLabel = uilabel(app.GpsGrid);
            app.GpsRevisitTimeLabel.VerticalAlignment = 'bottom';
            app.GpsRevisitTimeLabel.FontSize = 11;
            app.GpsRevisitTimeLabel.Layout.Row = 3;
            app.GpsRevisitTimeLabel.Layout.Column = 1;
            app.GpsRevisitTimeLabel.Text = 'Revisita (seg):';

            % Create GpsRevisitTime
            app.GpsRevisitTime = uieditfield(app.GpsGrid, 'numeric');
            app.GpsRevisitTime.Limits = [1 Inf];
            app.GpsRevisitTime.RoundFractionalValues = 'on';
            app.GpsRevisitTime.ValueDisplayFormat = '%.0f';
            app.GpsRevisitTime.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.GpsRevisitTime.Tag = 'task_Editable';
            app.GpsRevisitTime.Editable = 'off';
            app.GpsRevisitTime.FontSize = 11;
            app.GpsRevisitTime.Layout.Row = 4;
            app.GpsRevisitTime.Layout.Column = 1;
            app.GpsRevisitTime.Value = 60;

            % Create BandPanel
            app.BandPanel = uipanel(app.GridLayout);
            app.BandPanel.AutoResizeChildren = 'off';
            app.BandPanel.Layout.Row = [4 7];
            app.BandPanel.Layout.Column = [7 10];

            % Create BandGrid
            app.BandGrid = uigridlayout(app.BandPanel);
            app.BandGrid.ColumnWidth = {110, 110, 110, 110, '1x'};
            app.BandGrid.RowHeight = {34, 17, 22, 22, 22, 22, 22, 22, 22, 22, 22, 36, 22, '1x'};
            app.BandGrid.RowSpacing = 5;
            app.BandGrid.Scrollable = 'on';
            app.BandGrid.BackgroundColor = [1 1 1];

            % Create BandTitle
            app.BandTitle = uilabel(app.BandGrid);
            app.BandTitle.VerticalAlignment = 'top';
            app.BandTitle.WordWrap = 'on';
            app.BandTitle.FontColor = [0 0.4471 0.7412];
            app.BandTitle.Layout.Row = 1;
            app.BandTitle.Layout.Column = [1 5];
            app.BandTitle.Interpreter = 'html';
            app.BandTitle.Text = {'<b>Faixa de frequência selecionada</b>'; '<font style="color: gray; font-size: 10px;">Parâmetros técnicos de aquisição e detecção</font>'};

            % Create StatusLabel
            app.StatusLabel = uilabel(app.BandGrid);
            app.StatusLabel.VerticalAlignment = 'bottom';
            app.StatusLabel.FontSize = 10;
            app.StatusLabel.FontColor = [0.149 0.149 0.149];
            app.StatusLabel.Layout.Row = 2;
            app.StatusLabel.Layout.Column = 1;
            app.StatusLabel.Text = 'ESTADO';

            % Create Status
            app.Status = uidropdown(app.BandGrid);
            app.Status.Items = {'ON', 'OFF'};
            app.Status.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Status.FontSize = 11;
            app.Status.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Status.Layout.Row = 3;
            app.Status.Layout.Column = 1;
            app.Status.Value = 'ON';

            % Create MaskTriggerLabel
            app.MaskTriggerLabel = uilabel(app.BandGrid);
            app.MaskTriggerLabel.VerticalAlignment = 'bottom';
            app.MaskTriggerLabel.FontSize = 10;
            app.MaskTriggerLabel.FontColor = [0.149 0.149 0.149];
            app.MaskTriggerLabel.Layout.Row = 2;
            app.MaskTriggerLabel.Layout.Column = [2 3];
            app.MaskTriggerLabel.Text = 'MÁSCARA ESPECTRAL';

            % Create MaskTrigger
            app.MaskTrigger = uidropdown(app.BandGrid);
            app.MaskTrigger.Items = {'OFF', 'ON - Apenas afere rompimento', 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)', 'ON - Afere rompimento e salva em arquivo'};
            app.MaskTrigger.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.MaskTrigger.FontSize = 11;
            app.MaskTrigger.BackgroundColor = [0.9412 0.9412 0.9412];
            app.MaskTrigger.Layout.Row = 3;
            app.MaskTrigger.Layout.Column = [2 4];
            app.MaskTrigger.Value = 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)';

            % Create IDLabel
            app.IDLabel = uilabel(app.BandGrid);
            app.IDLabel.VerticalAlignment = 'bottom';
            app.IDLabel.FontSize = 10;
            app.IDLabel.Layout.Row = 4;
            app.IDLabel.Layout.Column = 1;
            app.IDLabel.Text = 'ID';

            % Create ID
            app.ID = uieditfield(app.BandGrid, 'numeric');
            app.ID.Limits = [1 Inf];
            app.ID.RoundFractionalValues = 'on';
            app.ID.ValueDisplayFormat = '%.0f';
            app.ID.Editable = 'off';
            app.ID.FontSize = 11;
            app.ID.Layout.Row = 5;
            app.ID.Layout.Column = 1;
            app.ID.Value = 1;

            % Create DescriptionLabel
            app.DescriptionLabel = uilabel(app.BandGrid);
            app.DescriptionLabel.VerticalAlignment = 'bottom';
            app.DescriptionLabel.FontSize = 10;
            app.DescriptionLabel.Layout.Row = 4;
            app.DescriptionLabel.Layout.Column = [2 3];
            app.DescriptionLabel.Text = 'DESCRIÇÃO';

            % Create Description
            app.Description = uieditfield(app.BandGrid, 'text');
            app.Description.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Description.Editable = 'off';
            app.Description.FontSize = 11;
            app.Description.Layout.Row = 5;
            app.Description.Layout.Column = [2 3];

            % Create ObservationSamplesLabel
            app.ObservationSamplesLabel = uilabel(app.BandGrid);
            app.ObservationSamplesLabel.VerticalAlignment = 'bottom';
            app.ObservationSamplesLabel.FontSize = 10;
            app.ObservationSamplesLabel.Layout.Row = 4;
            app.ObservationSamplesLabel.Layout.Column = [4 5];
            app.ObservationSamplesLabel.Text = 'AMOSTRAS A COLETAR';

            % Create ObservationSamples
            app.ObservationSamples = uieditfield(app.BandGrid, 'numeric');
            app.ObservationSamples.Limits = [-1 Inf];
            app.ObservationSamples.RoundFractionalValues = 'on';
            app.ObservationSamples.ValueDisplayFormat = '%.0f';
            app.ObservationSamples.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.ObservationSamples.Editable = 'off';
            app.ObservationSamples.FontSize = 11;
            app.ObservationSamples.Layout.Row = 5;
            app.ObservationSamples.Layout.Column = 4;
            app.ObservationSamples.Value = -1;

            % Create FreqStartLabel
            app.FreqStartLabel = uilabel(app.BandGrid);
            app.FreqStartLabel.VerticalAlignment = 'bottom';
            app.FreqStartLabel.FontSize = 10;
            app.FreqStartLabel.Layout.Row = 6;
            app.FreqStartLabel.Layout.Column = 1;
            app.FreqStartLabel.Text = 'FREQ. INICIAL (MHz)';

            % Create FreqStart
            app.FreqStart = uieditfield(app.BandGrid, 'numeric');
            app.FreqStart.Limits = [0.1 100000];
            app.FreqStart.ValueDisplayFormat = '%.6f';
            app.FreqStart.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.FreqStart.Editable = 'off';
            app.FreqStart.HorizontalAlignment = 'left';
            app.FreqStart.FontSize = 11;
            app.FreqStart.Layout.Row = 7;
            app.FreqStart.Layout.Column = 1;
            app.FreqStart.Value = 108;

            % Create FreqStopLabel
            app.FreqStopLabel = uilabel(app.BandGrid);
            app.FreqStopLabel.VerticalAlignment = 'bottom';
            app.FreqStopLabel.FontSize = 10;
            app.FreqStopLabel.Layout.Row = 6;
            app.FreqStopLabel.Layout.Column = 2;
            app.FreqStopLabel.Text = 'FREQ. FINAL (MHz)';

            % Create FreqStop
            app.FreqStop = uieditfield(app.BandGrid, 'numeric');
            app.FreqStop.Limits = [0.1 100000];
            app.FreqStop.ValueDisplayFormat = '%.6f';
            app.FreqStop.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.FreqStop.Editable = 'off';
            app.FreqStop.HorizontalAlignment = 'left';
            app.FreqStop.FontSize = 11;
            app.FreqStop.Layout.Row = 7;
            app.FreqStop.Layout.Column = 2;
            app.FreqStop.Value = 108;

            % Create StepWidthLabel
            app.StepWidthLabel = uilabel(app.BandGrid);
            app.StepWidthLabel.VerticalAlignment = 'bottom';
            app.StepWidthLabel.FontSize = 10;
            app.StepWidthLabel.Layout.Row = 6;
            app.StepWidthLabel.Layout.Column = 3;
            app.StepWidthLabel.Text = 'PASSO (kHz)';

            % Create StepWidth
            app.StepWidth = uieditfield(app.BandGrid, 'numeric');
            app.StepWidth.Limits = [1 Inf];
            app.StepWidth.ValueDisplayFormat = '%.3f';
            app.StepWidth.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.StepWidth.Editable = 'off';
            app.StepWidth.FontSize = 11;
            app.StepWidth.Layout.Row = 7;
            app.StepWidth.Layout.Column = 3;
            app.StepWidth.Value = 1;

            % Create ResolutionLabel
            app.ResolutionLabel = uilabel(app.BandGrid);
            app.ResolutionLabel.VerticalAlignment = 'bottom';
            app.ResolutionLabel.FontSize = 10;
            app.ResolutionLabel.Layout.Row = 6;
            app.ResolutionLabel.Layout.Column = 4;
            app.ResolutionLabel.Text = 'RESOLUÇÃO (kHz)';

            % Create Resolution
            app.Resolution = uieditfield(app.BandGrid, 'numeric');
            app.Resolution.Limits = [1 Inf];
            app.Resolution.ValueDisplayFormat = '%.3f';
            app.Resolution.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Resolution.Editable = 'off';
            app.Resolution.FontSize = 11;
            app.Resolution.Layout.Row = 7;
            app.Resolution.Layout.Column = 4;
            app.Resolution.Value = 1;

            % Create TraceModeLabel
            app.TraceModeLabel = uilabel(app.BandGrid);
            app.TraceModeLabel.VerticalAlignment = 'bottom';
            app.TraceModeLabel.FontSize = 10;
            app.TraceModeLabel.Layout.Row = 8;
            app.TraceModeLabel.Layout.Column = 1;
            app.TraceModeLabel.Text = 'TRAÇO';

            % Create TraceMode
            app.TraceMode = uidropdown(app.BandGrid);
            app.TraceMode.Items = {'ClearWrite', 'Average', 'MaxHold', 'MinHold'};
            app.TraceMode.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.TraceMode.FontSize = 11;
            app.TraceMode.BackgroundColor = [1 1 1];
            app.TraceMode.Layout.Row = 9;
            app.TraceMode.Layout.Column = 1;
            app.TraceMode.Value = 'Average';

            % Create IntegrationFactorLabel
            app.IntegrationFactorLabel = uilabel(app.BandGrid);
            app.IntegrationFactorLabel.VerticalAlignment = 'bottom';
            app.IntegrationFactorLabel.FontSize = 10;
            app.IntegrationFactorLabel.Layout.Row = 8;
            app.IntegrationFactorLabel.Layout.Column = 2;
            app.IntegrationFactorLabel.Text = 'FATOR INTEGRAÇÃO';

            % Create IntegrationFactor
            app.IntegrationFactor = uieditfield(app.BandGrid, 'numeric');
            app.IntegrationFactor.Limits = [1 Inf];
            app.IntegrationFactor.RoundFractionalValues = 'on';
            app.IntegrationFactor.ValueDisplayFormat = '%.0f';
            app.IntegrationFactor.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.IntegrationFactor.Editable = 'off';
            app.IntegrationFactor.FontSize = 11;
            app.IntegrationFactor.Layout.Row = 9;
            app.IntegrationFactor.Layout.Column = 2;
            app.IntegrationFactor.Value = 1;

            % Create RFModeLabel
            app.RFModeLabel = uilabel(app.BandGrid);
            app.RFModeLabel.VerticalAlignment = 'bottom';
            app.RFModeLabel.FontSize = 10;
            app.RFModeLabel.Layout.Row = 8;
            app.RFModeLabel.Layout.Column = 3;
            app.RFModeLabel.Text = 'MODO DE RF';

            % Create RFMode
            app.RFMode = uidropdown(app.BandGrid);
            app.RFMode.Items = {'High Sensitivity', 'Low Distortion', 'Normal'};
            app.RFMode.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.RFMode.FontSize = 11;
            app.RFMode.BackgroundColor = [1 1 1];
            app.RFMode.Layout.Row = 9;
            app.RFMode.Layout.Column = 3;
            app.RFMode.Value = 'High Sensitivity';

            % Create VBWLabel
            app.VBWLabel = uilabel(app.BandGrid);
            app.VBWLabel.VerticalAlignment = 'bottom';
            app.VBWLabel.FontSize = 10;
            app.VBWLabel.Layout.Row = 8;
            app.VBWLabel.Layout.Column = 4;
            app.VBWLabel.Text = 'VBW';

            % Create VBW
            app.VBW = uidropdown(app.BandGrid);
            app.VBW.Items = {'auto', 'RBW', 'RBW/10', 'RBW/100'};
            app.VBW.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.VBW.FontSize = 11;
            app.VBW.BackgroundColor = [1 1 1];
            app.VBW.Layout.Row = 9;
            app.VBW.Layout.Column = 4;
            app.VBW.Value = 'auto';

            % Create DetectorLabel
            app.DetectorLabel = uilabel(app.BandGrid);
            app.DetectorLabel.VerticalAlignment = 'bottom';
            app.DetectorLabel.FontSize = 10;
            app.DetectorLabel.Layout.Row = 10;
            app.DetectorLabel.Layout.Column = 1;
            app.DetectorLabel.Text = 'DETECTOR';

            % Create Detector
            app.Detector = uidropdown(app.BandGrid);
            app.Detector.Items = {'Sample', 'Average/RMS', 'Positive Peak', 'Negative Peak'};
            app.Detector.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.Detector.FontSize = 11;
            app.Detector.BackgroundColor = [1 1 1];
            app.Detector.Layout.Row = 11;
            app.Detector.Layout.Column = [1 2];
            app.Detector.Value = 'Sample';

            % Create LevelUnitLabel
            app.LevelUnitLabel = uilabel(app.BandGrid);
            app.LevelUnitLabel.VerticalAlignment = 'bottom';
            app.LevelUnitLabel.FontSize = 10;
            app.LevelUnitLabel.Layout.Row = 10;
            app.LevelUnitLabel.Layout.Column = 3;
            app.LevelUnitLabel.Text = 'UNIDADE';

            % Create LevelUnit
            app.LevelUnit = uidropdown(app.BandGrid);
            app.LevelUnit.Items = {'dBm', 'dBµV'};
            app.LevelUnit.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.LevelUnit.FontSize = 11;
            app.LevelUnit.BackgroundColor = [1 1 1];
            app.LevelUnit.Layout.Row = 11;
            app.LevelUnit.Layout.Column = 3;
            app.LevelUnit.Value = 'dBm';

            % Create RevisitTimeLabel
            app.RevisitTimeLabel = uilabel(app.BandGrid);
            app.RevisitTimeLabel.VerticalAlignment = 'bottom';
            app.RevisitTimeLabel.FontSize = 10;
            app.RevisitTimeLabel.Layout.Row = 10;
            app.RevisitTimeLabel.Layout.Column = 4;
            app.RevisitTimeLabel.Text = 'REVISITA (seg)';

            % Create RevisitTime
            app.RevisitTime = uieditfield(app.BandGrid, 'numeric');
            app.RevisitTime.Limits = [0.001 Inf];
            app.RevisitTime.ValueDisplayFormat = '%.3f';
            app.RevisitTime.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.RevisitTime.Editable = 'off';
            app.RevisitTime.FontSize = 11;
            app.RevisitTime.Layout.Row = 11;
            app.RevisitTime.Layout.Column = 4;
            app.RevisitTime.Value = 1;

            % Create FindPeaks_PanelLabel
            app.FindPeaks_PanelLabel = uilabel(app.BandGrid);
            app.FindPeaks_PanelLabel.VerticalAlignment = 'bottom';
            app.FindPeaks_PanelLabel.FontSize = 10;
            app.FindPeaks_PanelLabel.Layout.Row = 12;
            app.FindPeaks_PanelLabel.Layout.Column = [1 4];
            app.FindPeaks_PanelLabel.Text = {'PARÂMETROS RELACIONADOS À BUSCA DE EMISSÕES'; '(caso evidenciado rompimento de máscara espectral)'};

            % Create FindPeaksPanel
            app.FindPeaksPanel = uipanel(app.BandGrid);
            app.FindPeaksPanel.AutoResizeChildren = 'off';
            app.FindPeaksPanel.Layout.Row = [13 14];
            app.FindPeaksPanel.Layout.Column = [1 5];

            % Create FindPeaksGrid
            app.FindPeaksGrid = uigridlayout(app.FindPeaksPanel);
            app.FindPeaksGrid.ColumnWidth = {100, 110, 110, 110};
            app.FindPeaksGrid.RowHeight = {17, 22, 34, 22};
            app.FindPeaksGrid.RowSpacing = 5;
            app.FindPeaksGrid.Scrollable = 'on';
            app.FindPeaksGrid.BackgroundColor = [1 1 1];

            % Create FindPeaksTypeLabel
            app.FindPeaksTypeLabel = uilabel(app.FindPeaksGrid);
            app.FindPeaksTypeLabel.VerticalAlignment = 'bottom';
            app.FindPeaksTypeLabel.FontSize = 11;
            app.FindPeaksTypeLabel.Layout.Row = 1;
            app.FindPeaksTypeLabel.Layout.Column = 1;
            app.FindPeaksTypeLabel.Text = 'Tipo:';

            % Create FindPeaksType
            app.FindPeaksType = uidropdown(app.FindPeaksGrid);
            app.FindPeaksType.Items = {'Valores padrão (appColeta)', 'Valores customizados'};
            app.FindPeaksType.ValueChangedFcn = createCallbackFcn(app, @FindPeaksDropDownValueChanged, true);
            app.FindPeaksType.Enable = 'off';
            app.FindPeaksType.FontSize = 11;
            app.FindPeaksType.BackgroundColor = [1 1 1];
            app.FindPeaksType.Layout.Row = 2;
            app.FindPeaksType.Layout.Column = [1 4];
            app.FindPeaksType.Value = 'Valores padrão (appColeta)';

            % Create FindPeaksNumSweepsLabel
            app.FindPeaksNumSweepsLabel = uilabel(app.FindPeaksGrid);
            app.FindPeaksNumSweepsLabel.VerticalAlignment = 'bottom';
            app.FindPeaksNumSweepsLabel.FontSize = 11;
            app.FindPeaksNumSweepsLabel.Layout.Row = 3;
            app.FindPeaksNumSweepsLabel.Layout.Column = 1;
            app.FindPeaksNumSweepsLabel.Text = {'Quantidade de'; 'varreduras:'};

            % Create FindPeaksNumSweeps
            app.FindPeaksNumSweeps = uispinner(app.FindPeaksGrid);
            app.FindPeaksNumSweeps.Limits = [1 100];
            app.FindPeaksNumSweeps.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.FindPeaksNumSweeps.FontSize = 11;
            app.FindPeaksNumSweeps.Enable = 'off';
            app.FindPeaksNumSweeps.Layout.Row = 4;
            app.FindPeaksNumSweeps.Layout.Column = 1;
            app.FindPeaksNumSweeps.Value = 10;

            % Create FindPeaksMinProminenceLabel
            app.FindPeaksMinProminenceLabel = uilabel(app.FindPeaksGrid);
            app.FindPeaksMinProminenceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksMinProminenceLabel.WordWrap = 'on';
            app.FindPeaksMinProminenceLabel.FontSize = 11;
            app.FindPeaksMinProminenceLabel.Layout.Row = 3;
            app.FindPeaksMinProminenceLabel.Layout.Column = 2;
            app.FindPeaksMinProminenceLabel.Text = {'Proeminência '; 'mínima (dB):'};

            % Create FindPeaksMinProminence
            app.FindPeaksMinProminence = uispinner(app.FindPeaksGrid);
            app.FindPeaksMinProminence.Step = 10;
            app.FindPeaksMinProminence.Limits = [3 50];
            app.FindPeaksMinProminence.RoundFractionalValues = 'on';
            app.FindPeaksMinProminence.ValueDisplayFormat = '%.0f';
            app.FindPeaksMinProminence.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.FindPeaksMinProminence.FontSize = 11;
            app.FindPeaksMinProminence.Enable = 'off';
            app.FindPeaksMinProminence.Layout.Row = 4;
            app.FindPeaksMinProminence.Layout.Column = 2;
            app.FindPeaksMinProminence.Value = 30;

            % Create FindPeaksMinDistanceLabel
            app.FindPeaksMinDistanceLabel = uilabel(app.FindPeaksGrid);
            app.FindPeaksMinDistanceLabel.VerticalAlignment = 'bottom';
            app.FindPeaksMinDistanceLabel.WordWrap = 'on';
            app.FindPeaksMinDistanceLabel.FontSize = 11;
            app.FindPeaksMinDistanceLabel.Layout.Row = 3;
            app.FindPeaksMinDistanceLabel.Layout.Column = 3;
            app.FindPeaksMinDistanceLabel.Text = {'Distância mínima '; 'entre picos (kHz):'};

            % Create FindPeaksMinDistance
            app.FindPeaksMinDistance = uispinner(app.FindPeaksGrid);
            app.FindPeaksMinDistance.Step = 25;
            app.FindPeaksMinDistance.Limits = [0 100000];
            app.FindPeaksMinDistance.RoundFractionalValues = 'on';
            app.FindPeaksMinDistance.ValueDisplayFormat = '%.0f';
            app.FindPeaksMinDistance.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.FindPeaksMinDistance.FontSize = 11;
            app.FindPeaksMinDistance.Enable = 'off';
            app.FindPeaksMinDistance.Layout.Row = 4;
            app.FindPeaksMinDistance.Layout.Column = 3;
            app.FindPeaksMinDistance.Value = 25;

            % Create FindPeaksMinBandWidthLabel
            app.FindPeaksMinBandWidthLabel = uilabel(app.FindPeaksGrid);
            app.FindPeaksMinBandWidthLabel.VerticalAlignment = 'bottom';
            app.FindPeaksMinBandWidthLabel.WordWrap = 'on';
            app.FindPeaksMinBandWidthLabel.FontSize = 11;
            app.FindPeaksMinBandWidthLabel.Layout.Row = 3;
            app.FindPeaksMinBandWidthLabel.Layout.Column = 4;
            app.FindPeaksMinBandWidthLabel.Text = {'Largura mínima'; 'ocupada (kHz):'};

            % Create FindPeaksMinBandWidth
            app.FindPeaksMinBandWidth = uispinner(app.FindPeaksGrid);
            app.FindPeaksMinBandWidth.Step = 10;
            app.FindPeaksMinBandWidth.Limits = [0 100000];
            app.FindPeaksMinBandWidth.RoundFractionalValues = 'on';
            app.FindPeaksMinBandWidth.ValueDisplayFormat = '%.0f';
            app.FindPeaksMinBandWidth.ValueChangedFcn = createCallbackFcn(app, @onTaskParameterValueChanged, true);
            app.FindPeaksMinBandWidth.FontSize = 11;
            app.FindPeaksMinBandWidth.Enable = 'off';
            app.FindPeaksMinBandWidth.Layout.Row = 4;
            app.FindPeaksMinBandWidth.Layout.Column = 4;
            app.FindPeaksMinBandWidth.Value = 10;

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, '1x', 116};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 9;
            app.Toolbar.Layout.Column = [1 13];
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

            % Create ConfirmEditionButtonGrid
            app.ConfirmEditionButtonGrid = uigridlayout(app.GridLayout);
            app.ConfirmEditionButtonGrid.ColumnWidth = {'1x'};
            app.ConfirmEditionButtonGrid.RowHeight = {'1x'};
            app.ConfirmEditionButtonGrid.Padding = [0 10 0 10];
            app.ConfirmEditionButtonGrid.Visible = 'off';
            app.ConfirmEditionButtonGrid.Layout.Row = [8 9];
            app.ConfirmEditionButtonGrid.Layout.Column = [8 10];
            app.ConfirmEditionButtonGrid.BackgroundColor = [1 1 1];

            % Create ConfirmEditionButton
            app.ConfirmEditionButton = uibutton(app.ConfirmEditionButtonGrid, 'push');
            app.ConfirmEditionButton.ButtonPushedFcn = createCallbackFcn(app, @ConfirmEditionButtonPushed, true);
            app.ConfirmEditionButton.Icon = 'save-16px-white.svg';
            app.ConfirmEditionButton.BackgroundColor = [0 0.451 0.7412];
            app.ConfirmEditionButton.FontSize = 11;
            app.ConfirmEditionButton.FontColor = [1 1 1];
            app.ConfirmEditionButton.Layout.Row = 1;
            app.ConfirmEditionButton.Layout.Column = 1;
            app.ConfirmEditionButton.Text = 'Salvar alterações';

            % Create DockModule
            app.DockModule = uigridlayout(app.GridLayout);
            app.DockModule.RowHeight = {'1x'};
            app.DockModule.ColumnSpacing = 2;
            app.DockModule.Padding = [5 2 5 2];
            app.DockModule.Visible = 'off';
            app.DockModule.Layout.Row = [2 4];
            app.DockModule.Layout.Column = [9 12];
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
        function app = winTaskList_exported(Container, varargin)

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
