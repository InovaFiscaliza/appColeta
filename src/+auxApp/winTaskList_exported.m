classdef winTaskList_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        DockModuleGroup            matlab.ui.container.GridLayout
        dockModule_Undock          matlab.ui.control.Image
        dockModule_Close           matlab.ui.control.Image
        Panel                      matlab.ui.container.Panel
        GridLayout2                matlab.ui.container.GridLayout
        BandSpecificInfo_Grid      matlab.ui.container.GridLayout
        FindPeaks_Panel            matlab.ui.container.Panel
        FindPeaks_Grid             matlab.ui.container.GridLayout
        FindPeaks_BW               matlab.ui.control.Spinner
        FindPeaks_BWLabel          matlab.ui.control.Label
        FindPeaks_Distance         matlab.ui.control.Spinner
        FindPeaks_DistanceLabel    matlab.ui.control.Label
        FindPeaks_Prominence       matlab.ui.control.Spinner
        FindPeaks_ProminenceLabel  matlab.ui.control.Label
        FindPeaks_nSweeps          matlab.ui.control.Spinner
        FindPeaks_nSweepsLabel     matlab.ui.control.Label
        FindPeaks_Type             matlab.ui.control.DropDown
        FindPeaks_TypeLabel        matlab.ui.control.Label
        FindPeaks_PanelLabel       matlab.ui.control.Label
        RevisitTime                matlab.ui.control.NumericEditField
        RevisitTimeLabel           matlab.ui.control.Label
        LevelUnit                  matlab.ui.control.DropDown
        LevelUnitLabel             matlab.ui.control.Label
        Detector                   matlab.ui.control.DropDown
        DetectorLabel              matlab.ui.control.Label
        VBW                        matlab.ui.control.DropDown
        VBWLabel                   matlab.ui.control.Label
        RFMode                     matlab.ui.control.DropDown
        RFModeLabel                matlab.ui.control.Label
        IntegrationFactor          matlab.ui.control.NumericEditField
        IntegrationFactorLabel     matlab.ui.control.Label
        TraceMode                  matlab.ui.control.DropDown
        TraceModeLabel             matlab.ui.control.Label
        Resolution                 matlab.ui.control.NumericEditField
        ResolutionLabel            matlab.ui.control.Label
        StepWidth                  matlab.ui.control.NumericEditField
        StepWidthLabel             matlab.ui.control.Label
        FreqStop                   matlab.ui.control.NumericEditField
        FreqStopLabel              matlab.ui.control.Label
        FreqStart                  matlab.ui.control.NumericEditField
        FreqStartLabel             matlab.ui.control.Label
        ObservationSamples         matlab.ui.control.NumericEditField
        ObservationSamplesLabel    matlab.ui.control.Label
        Description                matlab.ui.control.EditField
        DescriptionLabel           matlab.ui.control.Label
        ID                         matlab.ui.control.NumericEditField
        IDLabel                    matlab.ui.control.Label
        MaskTrigger                matlab.ui.control.DropDown
        MaskTriggerLabel           matlab.ui.control.Label
        Status                     matlab.ui.control.DropDown
        StatusLabel                matlab.ui.control.Label
        Tab2_PanelGrid             matlab.ui.container.GridLayout
        GPS_Panel                  matlab.ui.container.Panel
        GPS_Grid                   matlab.ui.container.GridLayout
        GPS_RevisitTime            matlab.ui.control.NumericEditField
        GPS_RevisitTimeLabel       matlab.ui.control.Label
        GPS_manualLongitude        matlab.ui.control.NumericEditField
        GPS_manualLongitudeLabel   matlab.ui.control.Label
        GPS_manualLatitude         matlab.ui.control.NumericEditField
        GPS_manualLatitudeLabel    matlab.ui.control.Label
        gpsMode                    matlab.ui.control.DropDown
        gpsModeLabel               matlab.ui.control.Label
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
        BitsPerPointLabel          matlab.ui.control.Label
        Name                       matlab.ui.control.EditField
        NameLabel                  matlab.ui.control.Label
        PanelLabel                 matlab.ui.control.Label
        TreeGrid                   matlab.ui.container.GridLayout
        ButtonGroupPanel           matlab.ui.container.ButtonGroup
        ButtonGroup_Edit           matlab.ui.control.RadioButton
        ButtonGroup_View           matlab.ui.control.RadioButton
        Image_downArrow            matlab.ui.control.Image
        Image_upArrow              matlab.ui.control.Image
        Image_del                  matlab.ui.control.Image
        Image_addBand              matlab.ui.control.Image
        Image_addTask              matlab.ui.control.Image
        Tree                       matlab.ui.container.Tree
        TreeLabel                  matlab.ui.control.Label
        Toolbar                    matlab.ui.container.GridLayout
        toolButton_play            matlab.ui.control.Button
        toolExportFile             matlab.ui.control.Image
        toolOpenFile               matlab.ui.control.Image
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

        taskList
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
            elToModify = {app.ButtonGroupPanel};
            elDataTag  = ui.CustomizationBase.getElementsDataTag(elToModify);
            if ~isempty(elDataTag)
                sendEventToHTMLSource(app.jsBackDoor, 'initializeComponents', { ...
                    struct('appName', appName, 'dataTag', elDataTag{1}, 'style', struct('backgroundColor', 'transparent')) ...
                });
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

            % Leitura de "taskList.json" - não é "aproveitada" a versão do 
            % winAppColetaV2 porque ela não contém os fluxos desabilitados
            % e, também, porque pode ter ocorridos uma alteração em editor
            % externo ao app no "taskList.json".
            [app.taskList, msgError] = class.taskList.file2raw(fullfile(app.mainApp.rootFolder, 'config', 'taskList.json'), 'auxApp.winEditTaskList');
            if ~isempty(msgError)
                appUtil.modalWindow(app.UIFigure, "error", msgError);
            end
            app.editedList = app.taskList;
            
            % Organização da informação do arquivo em árvore...
            TreeBuilding(app, [])
            focus(app.Tree)
        end

        %-----------------------------------------------------------------%
        function TreeBuilding(app, SelectedNode)

            if ~isempty(app.Tree.Children)
                delete(app.Tree.Children)
            end

            % Tree creation
            for ii = 1:numel(app.editedList)
                taskNode = uitreenode(app.Tree, 'Text', app.editedList(ii).Name, 'NodeData', ii, 'UserData', 1:numel(app.editedList(ii).Band));

                for jj = 1:numel(app.editedList(ii).Band)
                    uitreenode(taskNode, 'Text', TreeBuilding_nodeText(app, ii, jj), 'NodeData', ii, 'UserData', jj);
                end
            end
            TreeBuilding_addStyle(app)

            % SelectedNode
            if ~isempty(app.Tree.Children)
                if ~isempty(SelectedNode)
                    idx1 = SelectedNode(1);
                    idx2 = SelectedNode(2);
                else
                    idx1 = 1;
                    idx2 = 1;
                end
                
                if idx2 == -1
                    app.Tree.SelectedNodes = app.Tree.Children(idx1);
                else
                    app.Tree.SelectedNodes = app.Tree.Children(idx1).Children(idx2);
                end

                TreeSelectionChanged(app)                                   % internal "Layout(app)" call
                expand(app.Tree.Children(idx1))
            else
                Layout(app)
            end
        end


        %-----------------------------------------------------------------%
        function nodeText = TreeBuilding_nodeText(app, idx1, idx2)

            nodeText = sprintf('ID %d: %.3f - %.3f MHz', app.editedList(idx1).Band(idx2).ID,                ...
                                                         app.editedList(idx1).Band(idx2).FreqStart ./ 1e+6, ...
                                                         app.editedList(idx1).Band(idx2).FreqStop  ./ 1e+6);
        end


        %-----------------------------------------------------------------%
        function TreeBuilding_addStyle(app)

            if ~isempty(app.Tree.StyleConfigurations)
                removeStyle(app.Tree)
            end

            DisableNodes = [];
            for ii = 1:numel(app.editedList)
                for jj = 1:numel(app.editedList(ii).Band)
                    if ~app.editedList(ii).Band(jj).Enable
                        DisableNodes = [DisableNodes, app.Tree.Children(ii).Children(jj)];
                    end
                end
            end

            if ~isempty(DisableNodes)
                s = uistyle('FontColor', [.5 .5 .5]);
                addStyle(app.Tree, s, 'node', DisableNodes)
            end
        end


        %-----------------------------------------------------------------%
        function Layout(app)

            if isempty(app.Tree.SelectedNodes)
                set(app.Tab2_PanelGrid.Children,        'Enable', 0)
                set(app.BandSpecificInfo_Grid.Children, 'Enable', 0)

            else
                set(app.Tab2_PanelGrid.Children,        'Enable', 1)

                if isscalar(app.Tree.SelectedNodes.UserData)
                    set(app.BandSpecificInfo_Grid.Children, 'Enable', 1)

                    switch app.ObservationType.Value
                        case 'Quantidade específica de amostras'
                            app.ObservationSamples.Enable = 'on';
                        otherwise
                            app.ObservationSamples.Enable = 'off';
                    end

                elseif numel(app.Tree.SelectedNodes.UserData) > 1
                    set(app.BandSpecificInfo_Grid.Children, 'Enable', 0)
                end
            end
        end


        %-----------------------------------------------------------------%
        function ObservationTimeLayout(app)
            switch app.ObservationType.Value
                case 'Duração'                                              % "Duration"
                    app.Tab2_PanelGrid.RowHeight{6}        = 90; 
                    app.ObservationPanel_Grid.RowHeight{3} = 22;
                    set(app.Duration_Grid.Children,     'Enable', 1, 'Visible', 1)
                    set(app.SpecificTime_Grid.Children, 'Enable', 0, 'Visible', 0)
                    app.ObservationSamples.Enable          = 0;

                %---------------------------------------------------------%
                case 'Período específico'                                   % "Time"
                    SpecificTimePanel_editable(app)

                    app.Tab2_PanelGrid.RowHeight{6}        = 116;
                    app.ObservationPanel_Grid.RowHeight{3} = 0;
                    set(app.Duration_Grid.Children,     'Enable', 0, 'Visible', 0)
                    app.ObservationSamples.Enable          = 0;

                %---------------------------------------------------------%
                case 'Quantidade específica de amostras'                    % "Samples"
                    app.Tab2_PanelGrid.RowHeight{6}        = 62; 
                    app.ObservationPanel_Grid.RowHeight{3} = 0;
                    set(app.Duration_Grid.Children,     'Enable', 0, 'Visible', 0)
                    set(app.SpecificTime_Grid.Children, 'Enable', 0, 'Visible', 0)
                    app.ObservationSamples.Enable          = 1;
            end
        end


        %-----------------------------------------------------------------%
        function updateDuration(app, idx1)

            Duration_sec = app.editedList(idx1).Observation.Duration;
            if isempty(Duration_sec)
                Duration_sec = 600;
            end

            if Duration_sec >= 3600
                app.Duration.Value = Duration_sec ./ 3600;
                set(app.DurationUnit, Items={'min', 'hr'}, Value='hr')
            else
                app.Duration.Value = Duration_sec ./ 60;
                set(app.DurationUnit, Items={'min', 'hr'}, Value='min')
            end

            if app.ButtonGroup_View.Value
                app.DurationUnit.Items = {app.DurationUnit.Value};
            end
        end


        %-----------------------------------------------------------------%
        function updateObservationTime(app, idx1)

            BeginTime = datetime(app.editedList(idx1).Observation.BeginTime, "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");
            EndTime   = datetime(app.editedList(idx1).Observation.EndTime,   "InputFormat", "dd/MM/yyyy HH:mm:ss", "Format", "dd/MM/yyyy HH:mm:ss");

            timeFlag  = 1;
            if isnat(BeginTime) && isnat(EndTime)
                BeginTime = datetime('now');
                EndTime   = BeginTime;
            elseif isnat(BeginTime)
                BeginTime = datetime('now');
            elseif isnat(EndTime)
                EndTime   = datetime('now');
            else
                timeFlag  = 0; 
            end

            app.SpecificTime_DatePicker1.Value = BeginTime;
            app.SpecificTime_DatePicker2.Value = EndTime;

            try
                if timeFlag
                    eror('timeFlag')
                end

                app.SpecificTime_Spinner1.Value = hour(BeginTime);
                app.SpecificTime_Spinner2.Value = minute(BeginTime);
                app.SpecificTime_Spinner3.Value = hour(EndTime);
                app.SpecificTime_Spinner4.Value = minute(EndTime);
            catch
                app.SpecificTime_Spinner1.Value = 0;
                app.SpecificTime_Spinner2.Value = 0;
                app.SpecificTime_Spinner3.Value = 23;
                app.SpecificTime_Spinner4.Value = 59;
            end
        end


        %-----------------------------------------------------------------%
        function SpecificTimePanel_editable(app)

            if app.ButtonGroup_View.Value
                set(app.SpecificTime_Grid.Children, Enable=0, Visible=1)
            else
                set(app.SpecificTime_Grid.Children, Enable=1, Visible=1)
            end
        end


        %-----------------------------------------------------------------%
        function FindPeaksPanel_editable(app)

            if app.ButtonGroup_View.Value
                set(findobj(app.FindPeaks_Grid, 'Type', 'uispinner'), Enable=0)
            else
                set(findobj(app.FindPeaks_Grid, 'Type', 'uispinner'), Enable=1)
            end
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
        function newID(app)

            idx1 = app.Tree.SelectedNodes.NodeData;

            for ii = 1:numel(app.editedList(idx1).Band)
                app.editedList(idx1).Band(ii).ID = ii;
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function update(app)
            saveNewFile(app, fullfile(app.mainApp.rootFolder, 'config'), false)

            % Atualiza a propriedade do app...
            app.mainApp.taskList = class.taskList.file2raw(fullfile(app.mainApp.rootFolder, 'config', 'taskList.json'), 'winAppColetaV2');

            % Fecha o módulo auxiliar "auxApp.winAddTask.mlapp", caso aberto.
            appBackDoor(app.mainApp, app, 'closeFcn', 'TASK:ADD')
        end

        %-----------------------------------------------------------------%
        function saveNewFile(app, Folder, ShowAlert)

            msgError = class.taskList.raw2file(Folder, app.taskList);

            if ShowAlert
                if isempty(msgError)
                    appUtil.modalWindow(app.UIFigure, "warning", sprintf('Arquivo <b>taskList.json</b> salvo na pasta "%s"', Folder));
                else
                    appUtil.modalWindow(app.UIFigure, "error", msgError);
                end
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
            
            appBackDoor(app.mainApp, app, 'closeFcn', 'TASK:EDIT')
            delete(app)
            
        end

        % Selection changed function: Tree
        function TreeSelectionChanged(app, event)
            
            idx1 = app.Tree.SelectedNodes.NodeData;
            
            collapse(app.Tree)
            expand(app.Tree.Children(idx1))


            % Painel "ASPECTOS GERAIS"
            app.Name.Value            = app.editedList(idx1).Name;
            app.BitsPerPoint.Items    = {sprintf('%d bits', app.editedList(idx1).BitsPerSample)};
            
            app.ObservationType.Items = {class.taskList.english2portuguese(app.editedList(idx1).Observation.Type)};
            ObservationTimeLayout(app)
            
            app.gpsMode.Items         = {app.editedList(idx1).GPS.Type};
            gpsModeValueChanged(app)


            % Painel "ESPECIFICIDADES DO FLUXO SELECIONADO"
            if isscalar(app.Tree.SelectedNodes.UserData)
                idx2 = app.Tree.SelectedNodes.UserData;

                % Ajuste dos itens que são listas suspensas (uidropdown)
                % porque no "MODO DE EDIÇÃO" todos os possíveis valores
                % estão disponíveis para escolha, enquanto que no "MODO DE
                % VISUALIZAÇÃO" ficará disponível apenas o valor indicado
                % no "taskList.json".

                %---------------------------------------------------------%
                % ## MODO DE VISUALIZAÇÃO ##
                %---------------------------------------------------------%
                if app.ButtonGroup_View.Value
                    if app.editedList(idx1).Band(idx2).Enable; app.Status.Items = {'ON'};
                    else;                                      app.Status.Items = {'OFF'};
                    end

                    switch app.editedList(idx1).Band(idx2).MaskTrigger.Status
                        case 0; app.MaskTrigger.Items = {'OFF'};
                        case 1; app.MaskTrigger.Items = {'ON - Apenas afere rompimento'};
                        case 2; app.MaskTrigger.Items = {'ON - Afere rompimento e salva em arquivo (caso rompida máscara)'};
                        case 3; app.MaskTrigger.Items = {'ON - Afere rompimento e salva em arquivo'};
                    end

                    app.TraceMode.Items = {app.editedList(idx1).Band(idx2).TraceMode};
                    app.VBW.Items       = {app.editedList(idx1).Band(idx2).VBW};
                    app.Detector.Items  = {app.editedList(idx1).Band(idx2).Detector};
                    app.RFMode.Items    = {app.editedList(idx1).Band(idx2).RFMode};
                    app.LevelUnit.Items = {app.editedList(idx1).Band(idx2).LevelUnit};

                    if isempty(app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks); app.FindPeaks_Type.Items = {'Valores padrão (appColeta)'};
                    else;                                                              app.FindPeaks_Type.Items = {'Valores customizados'};
                    end

                %---------------------------------------------------------%
                % ## MODO DE EDIÇÃO ##
                %---------------------------------------------------------%
                else
                    if app.editedList(idx1).Band(idx2).Enable; app.Status.Value = 'ON';
                    else;                                      app.Status.Value = 'OFF';
                    end

                    switch app.editedList(idx1).Band(idx2).MaskTrigger.Status
                        case 0; app.MaskTrigger.Value = 'OFF';
                        case 1; app.MaskTrigger.Value = 'ON - Apenas afere rompimento';
                        case 2; app.MaskTrigger.Value = 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)';
                        case 3; app.MaskTrigger.Value = 'ON - Afere rompimento e salva em arquivo';
                    end

                    app.TraceMode.Value = app.editedList(idx1).Band(idx2).TraceMode;
                    app.VBW.Value       = app.editedList(idx1).Band(idx2).VBW;
                    app.Detector.Value  = app.editedList(idx1).Band(idx2).Detector;
                    app.LevelUnit.Value = app.editedList(idx1).Band(idx2).LevelUnit;
                    app.RFMode.Value    = app.editedList(idx1).Band(idx2).RFMode;

                    if isempty(app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks); app.FindPeaks_Type.Value = 'Valores padrão (appColeta)';
                    else;                                                              app.FindPeaks_Type.Value = 'Valores customizados';
                    end
                end


                % Ajustes nos outros campos (que não são listas suspensas), 
                % além de especificidades do campo "Fator integração" e dos
                % parâmetros relacionados à busca de emissões.
    
                app.ObservationSamples.Value = app.editedList(idx1).Band(idx2).ObservationSamples;
                app.ID.Value                 = app.editedList(idx1).Band(idx2).ID;
                app.Description.Value        = app.editedList(idx1).Band(idx2).Description;
                app.RevisitTime.Value        = app.editedList(idx1).Band(idx2).RevisitTime;
                
                app.FreqStart.Value          = app.editedList(idx1).Band(idx2).FreqStart  / 1e+6;
                app.FreqStop.Value           = app.editedList(idx1).Band(idx2).FreqStop   / 1e+6;
                app.StepWidth.Value          = app.editedList(idx1).Band(idx2).StepWidth  / 1e+3;
                SpanCheck(app)

                app.Resolution.Value         = app.editedList(idx1).Band(idx2).Resolution / 1e+3;
                app.IntegrationFactor.Value  = app.editedList(idx1).Band(idx2).IntegrationFactor;

                IntegrationFactorCheck(app)
                FindPeaksDropDownValueChanged(app)
            end


            % LAYOUT
            Layout(app)

            if app.ButtonGroup_Edit.Value
                set(app.BitsPerPoint,    'Items', {'8 bits', '16 bits', '32 bits'})
                set(app.ObservationType, 'Items', {'Duração', 'Período específico', 'Quantidade específica de amostras'})
                set(app.DurationUnit,    'Items', {'min', 'hr'})
                set(app.gpsMode,         'Items', {'auto', 'manual'})
            end
            
        end

        % Value changed function: ObservationType
        function ObservationTimeValueChanged(app, event)
            
            ObservationTimeLayout(app)
            
            idx1 = app.Tree.SelectedNodes.NodeData;            
            switch app.ObservationType.Value
                case 'Duração'                                              % "Duration"
                    updateDuration(app, idx1)
                    TaskParameterChanged(app, struct('Source', app.Duration))

                case 'Período específico'                                   % "Time"
                    updateObservationTime(app, idx1)
                    TaskParameterChanged(app, struct('Source', app.SpecificTime_DatePicker1))

                case 'Quantidade específica de amostras'                    % "Samples"
                    TaskParameterChanged(app, struct('Source', app.ObservationSamples))
            end
            
        end

        % Value changed function: gpsMode
        function gpsModeValueChanged(app, event)
            
            app.GPS_manualLatitude.Value  = -1;
            app.GPS_manualLongitude.Value = -1;
            app.GPS_RevisitTime.Value     = 60;
            set(app.GPS_Grid.Children, Enable='on')

            % Após a leitura do arquivo "taskList.json", uma tarefa com GPS
            % automático tem informação vazia de coordenadas geográficas
            % (latitude, longitude). Ao editar o tipo de GPS, trocando de
            % automático para manual, os valores iniciais serão (-1,-1), os
            % quais foram definidos no topo da função. O bloco try/catch
            % evita o erro de preenchimento do componente numérico com um
            % valor vazio.

            idx1 = app.Tree.SelectedNodes.NodeData;

            switch app.gpsMode.Value
                case 'auto'
                    app.GPS_manualLatitude.Enable     = 'off';
                    app.GPS_manualLongitude.Enable    = 'off';
                    app.GPS_RevisitTime.Value         = app.editedList(idx1).GPS.RevisitTime;

                case 'manual'
                    try
                        app.GPS_manualLatitude.Value  = app.editedList(idx1).GPS.Latitude;
                        app.GPS_manualLongitude.Value = app.editedList(idx1).GPS.Longitude;
                    catch
                    end
                    app.GPS_RevisitTime.Enable        = 'off';
            end

            TaskParameterChanged(app, struct('Source', app.gpsMode))

        end

        % Value changed function: FindPeaks_Type
        function FindPeaksDropDownValueChanged(app, event)
            
            idx1 = app.Tree.SelectedNodes.NodeData;
            idx2 = app.Tree.SelectedNodes.UserData;

            switch app.FindPeaks_Type.Value
                case 'Valores padrão (appColeta)'
                    set(findobj(app.FindPeaks_Grid, 'Type', 'uispinner'), Enable=0)

                    app.FindPeaks_nSweeps.Value    = class.Constants.FindPeaks.nSweeps;
                    app.FindPeaks_Prominence.Value = class.Constants.FindPeaks.Prominence;
                    app.FindPeaks_Distance.Value   = class.Constants.FindPeaks.Distance;
                    app.FindPeaks_BW.Value         = class.Constants.FindPeaks.BW;

                    if app.ButtonGroup_Edit.Value
                        app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks = [];
                    end

                case 'Valores customizados'
                    FindPeaksPanel_editable(app)
                    if isempty(app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks)
                        app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks = struct('nSweeps',    class.Constants.FindPeaks.nSweeps,    ...
                                                                                       'Prominence', class.Constants.FindPeaks.Prominence, ...
                                                                                       'Distance',   class.Constants.FindPeaks.Distance,   ...
                                                                                       'BW',         class.Constants.FindPeaks.BW);
                    end

                    app.FindPeaks_nSweeps.Value    = app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.nSweeps;
                    app.FindPeaks_Prominence.Value = app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.Prominence;
                    app.FindPeaks_Distance.Value   = app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.Distance;
                    app.FindPeaks_BW.Value         = app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.BW;

                    if app.ButtonGroup_Edit.Value
                        app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks = struct('nSweeps',    app.FindPeaks_nSweeps.Value,    ...
                                                                                       'Prominence', app.FindPeaks_Prominence.Value, ...
                                                                                       'Distance',   app.FindPeaks_Distance.Value,   ...
                                                                                       'BW',         app.FindPeaks_BW.Value);
                    end
            end
            
        end

        % Selection changed function: ButtonGroupPanel
        function OperationModeValueChanged(app, event)
            
            %-------------------------------------------------------------%
            % ## MODO DE VISUALIZAÇÃO ##
            %-------------------------------------------------------------%
            if app.ButtonGroup_View.Value
                % Aspectos relacionados à indicação visual de que se trata 
                % do modo de visualização:
                set(findobj(app.TreeGrid, 'Type', 'uiimage'), 'Enable', 'off')
                app.TreeGrid.ColumnWidth{end} = 0;                
                app.toolButton_play.Visible  = 0;
                app.toolButton_open.Enable   = 'on';
                app.toolButton_export.Enable = 'on';

                % Desabilita edição do conteúdo dos campos...
                app.Name.Editable            = 'off';
                app.Duration.Editable        = 'off';
                set(findobj(app.GPS_Grid,              'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')
                set(findobj(app.BandSpecificInfo_Grid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='off')

                set(app.BitsPerPoint,    'Items', {app.BitsPerPoint.Value})
                set(app.ObservationType, 'Items', {app.ObservationType.Value})
                set(app.DurationUnit,    'Items', {app.DurationUnit.Value})
                set(app.gpsMode,         'Items', {app.gpsMode.Value})
                set(app.Status,          'Items', {app.Status.Value})
                set(app.MaskTrigger,     'Items', {app.MaskTrigger.Value})
                set(app.RFMode,          'Items', {app.RFMode.Value})
                set(app.TraceMode,       'Items', {app.TraceMode.Value})
                set(app.Detector,        'Items', {app.Detector.Value})
                set(app.LevelUnit,       'Items', {app.LevelUnit.Value})
                set(app.VBW,             'Items', {app.VBW.Value})
                set(app.FindPeaks_Type,  'Items', {app.FindPeaks_Type.Value})

                % Essa última validação é essencial para desfazer alterações 
                % que não foram salvas. Ou seja, o usuário fez alterações
                % em app.taskList (que estavam armazenadas na sua cópia -
                % app.editedList) e não clicou no botão "Confirma edição".
                if ~isequal(app.taskList, app.editedList)
                    app.editedList = app.taskList;
                    TreeBuilding(app, [])
                end

            %-------------------------------------------------------------%
            % ## MODO DE EDIÇÃO ##
            %-------------------------------------------------------------%
            else
                % Aspectos relacionados à indicação visual de que se trata 
                % do modo de edição:
                set(app.TreeGrid.Children, 'Enable', 'on')
                app.TreeGrid.ColumnWidth{end} = 16;                
                app.toolButton_play.Visible  = 1;
                app.toolButton_open.Enable   = 'off';
                app.toolButton_export.Enable = 'off';

                % Habilita edição do conteúdo dos campos...

                app.Name.Editable            = 'on';
                app.Duration.Editable        = 'on';
                set(findobj(app.GPS_Grid,              'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                set(findobj(app.BandSpecificInfo_Grid, 'Type', 'uinumericeditfield', '-or', 'Type', 'uieditfield'), Editable='on')
                app.ID.Editable              = 'off';

                set(app.BitsPerPoint,    'Items', {'8 bits', '16 bits', '32 bits'})
                set(app.ObservationType, 'Items', {'Duração', 'Período específico', 'Quantidade específica de amostras'})
                set(app.DurationUnit,    'Items', {'min', 'hr'})
                set(app.gpsMode,         'Items', {'auto', 'manual'})
                set(app.Status,          'Items', {'ON', 'OFF'})
                set(app.MaskTrigger,     'Items', {'OFF', 'ON - Apenas afere rompimento', 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)', 'ON - Afere rompimento e salva em arquivo'})
                set(app.RFMode,          'Items', {'High Sensitivity', 'Normal', 'Low Distortion'})
                set(app.TraceMode,       'Items', {'ClearWrite', 'Average', 'MaxHold', 'MinHold'})
                set(app.Detector,        'Items', {'Sample', 'Average/RMS', 'Positive Peak', 'Negative Peak'})
                set(app.LevelUnit,       'Items', {'dBm', 'dBµV'})
                set(app.VBW,             'Items', {'auto', 'RBW', 'RBW/10', 'RBW/100'})
                set(app.FindPeaks_Type,  'Items', {'Valores padrão (appColeta)', 'Valores customizados'})
            end


            if strcmp(app.ObservationType.Value, 'Período específico')
                SpecificTimePanel_editable(app)
            end


            if strcmp(app.FindPeaks_Type.Value, 'Valores customizados')
                FindPeaksPanel_editable(app)
            end

        end

        % Image clicked function: toolOpenFile
        function toolButton_openPushed(app, event)
            
            [File, Folder] = uigetfile({'*.json', '*.json'}, 'Selecione um arquivo', 'MultiSelect', 'off');
            figure(app.UIFigure)

            if File
            [tempList, msgError] =  class.taskList.file2raw(fullfile(Folder, File), 'auxApp.winEditTaskList');

                if isempty(msgError)
                    app.taskList   = [app.taskList; tempList];
                    app.editedList = app.taskList;
                    update(app)

                    TreeBuilding(app, [])
                else
                    appUtil.modalWindow(app.UIFigure, "error", msgError);
                end
            end

        end

        % Image clicked function: toolExportFile
        function toolButton_exportPushed(app, event)
            
            Folder = uigetdir(app.mainApp.General.fileFolder.userPath, 'Escolha o diretório em que será salva a lista de tarefas');
            figure(app.UIFigure)

            if Folder
                saveNewFile(app, Folder, true)
            end
atp
        end

        % Image clicked function: Image_addTask
        function Image_addTaskPushed(app, event)
            
            idx1_old = app.Tree.SelectedNodes.NodeData;
            idx1_new = numel(app.editedList) + 1;

            idx2 = 1;

            app.editedList(idx1_new) = app.editedList(idx1_old);
            app.editedList(idx1_new).Name = sprintf('%s (Cópia)', app.editedList(idx1_old).Name);
            
            TreeBuilding(app, [idx1_new, idx2])

        end

        % Image clicked function: Image_addBand
        function Image_addBandValueChanged(app, event)
            
            idx1 = app.Tree.SelectedNodes.NodeData;
            
            idx2_old = app.Tree.SelectedNodes.UserData;
            idx2_new = numel(app.editedList(idx1).Band) + 1;

            if app.Tree.SelectedNodes.Parent == app.Tree
                app.editedList(idx1).Band(idx2_new) = app.editedList(idx1).Band(1);
            else
                app.editedList(idx1).Band(idx2_new) = app.editedList(idx1).Band(idx2_old);
            end
             app.editedList(idx1).Band(idx2_new).ID = idx2_new;
            
            TreeBuilding(app, [idx1, idx2_new])

        end

        % Image clicked function: Image_del
        function Image_delPushed(app, event)
            
            idx1 = app.Tree.SelectedNodes.NodeData;
            idx2 = app.Tree.SelectedNodes.UserData;
            
            if app.Tree.SelectedNodes.Parent == app.Tree
                if numel(app.editedList) > 1
                    app.editedList(idx1) = [];
                    TreeBuilding(app, [1, -1])

                else
                    appUtil.modalWindow(app.UIFigure, "warning", 'Não é possível excluir a única tarefa.');
                    return
                end

            else
                if numel(app.editedList(idx1).Band) > 1
                    app.editedList(idx1).Band(idx2) = [];
                    newID(app)
                    TreeBuilding(app, [idx1, 1])

                else
                    appUtil.modalWindow(app.UIFigure, "warning", 'Não é possível excluir a única faixa de frequência da tarefa.');
                    return
                end
            end            

        end

        % Button pushed function: toolButton_play
        function toolButton_playPushed(app, event)
            
            % Finalizada a edição, avalia-se se algum parâmetro foi, de fato, 
            % alterado, salvando uma nova versão do arquivo "taskList.json",
            % caso necessário.

            if ~isequal(app.taskList, app.editedList)
                % Validaçao dos valores das faixas - os outros campos já são 
                % validados pelos próprios componentes da interface.                
                for ii = 1:numel(app.editedList)
                    for jj = 1:numel(app.editedList(ii).Band)
                        freqStart = app.editedList(ii).Band.FreqStart;
                        freqStop  = app.editedList(ii).Band.FreqStop;

                        if freqStart >= freqStop
                            appUtil.modalWindow(app.UIFigure, "warning", sprintf('A faixa <b>%.3f - %.3f MHz</b>, da tarefa "%s", é inválida. A frequência final de uma faixa deve ser superior à inicial.', freqStart/1e+6, freqStop/1e+6, app.editedList(ii).Name));
                            return
                        end
                    end
                end

                app.taskList = app.editedList;
                update(app)
            end
            
            app.ButtonGroup_View.Value = 1;
            OperationModeValueChanged(app)

        end

        % Value changed function: BitsPerPoint, Description, Detector, 
        % ...and 29 other components
        function TaskParameterChanged(app, event)
            
            idx1 = app.Tree.SelectedNodes.NodeData;
            idx2 = app.Tree.SelectedNodes.UserData;

            switch event.Source
                %---------------------------------------------------------%
                % Painel "ASPECTOS GERAIS"
                %---------------------------------------------------------%
                case app.Name
                    app.editedList(idx1).Name    = app.Name.Value;
                    app.Tree.Children(idx1).Text = app.Name.Value;

                case app.BitsPerPoint
                    app.editedList(idx1).BitsPerSample = str2double(extractBefore(app.BitsPerPoint.Value, 'bits'));
                
                case {app.Duration, app.DurationUnit}
                    app.editedList(idx1).Observation.Type = 'Duration';
                    switch app.DurationUnit.Value
                        case 'min'; app.editedList(idx1).Observation.Duration = app.Duration.Value * 60;
                        case 'hr';  app.editedList(idx1).Observation.Duration = app.Duration.Value * 3600;
                    end

                case {app.SpecificTime_DatePicker1, app.SpecificTime_Spinner1, app.SpecificTime_Spinner2, app.SpecificTime_DatePicker2, app.SpecificTime_Spinner3, app.SpecificTime_Spinner4}
                    app.editedList(idx1).Observation.Type = 'Time';

                    BeginTime = app.SpecificTime_DatePicker1.Value + hours(app.SpecificTime_Spinner1.Value) + minutes(app.SpecificTime_Spinner2.Value);
                    EndTime   = app.SpecificTime_DatePicker2.Value + hours(app.SpecificTime_Spinner3.Value) + minutes(app.SpecificTime_Spinner4.Value);

                    app.editedList(idx1).Observation.BeginTime = datestr(BeginTime, 'dd/mm/yyyy HH:MM:ss');
                    app.editedList(idx1).Observation.EndTime   = datestr(EndTime,   'dd/mm/yyyy HH:MM:ss');

                case {app.gpsMode, app.GPS_manualLatitude, app.GPS_manualLongitude, app.GPS_RevisitTime}
                    switch app.gpsMode.Value
                        case 'auto'
                            app.editedList(idx1).GPS = struct('Type',        'auto', ...
                                                              'Latitude',    [],     ...
                                                              'Longitude',   [],     ...
                                                              'RevisitTime', app.GPS_RevisitTime.Value);
                        case 'manual'
                            app.editedList(idx1).GPS = struct('Type',        'manual',                      ...
                                                              'Latitude',    app.GPS_manualLatitude.Value,  ...
                                                              'Longitude',   app.GPS_manualLongitude.Value, ...
                                                              'RevisitTime', app.GPS_RevisitTime.Value);
                    end

                %---------------------------------------------------------%                
                % Painel "ESPECIFICIDADES DO FLUXO SELECIONADO"
                %---------------------------------------------------------%
                case app.Status
                    if numel(app.editedList(idx1).Band) == 1
                        app.Status.Value = "ON";
                        appUtil.modalWindow(app.UIFigure, "warning", 'Tarefa com apenas uma única faixa de frequência não pode ter essa faixa com o estado "OFF".');
                        return

                    else
                        if app.Status.Value == "ON"; app.editedList(idx1).Band(idx2).Enable = 1;
                        else;                        app.editedList(idx1).Band(idx2).Enable = 0;
                        end

                        if all(~[app.editedList(idx1).Band.Enable])
                            app.editedList(idx1).Band(idx2).Enable = 1;

                            app.Status.Value = "ON";
                            appUtil.modalWindow(app.UIFigure, "warning", 'Toda tarefa deve possuir ao menos uma faixa de frequência com o estado "ON".');
                            return
                        end
    
                        TreeBuilding_addStyle(app)
                    end

                %---------------------------------------------------------%
                case app.MaskTrigger
                    switch app.MaskTrigger.Value
                        case 'OFF';                                                             app.editedList(idx1).Band(idx2).MaskTrigger.Status = 0;
                        case 'ON - Apenas afere rompimento';                                    app.editedList(idx1).Band(idx2).MaskTrigger.Status = 1;
                        case 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)'; app.editedList(idx1).Band(idx2).MaskTrigger.Status = 2;
                        case 'ON - Afere rompimento e salva em arquivo';                        app.editedList(idx1).Band(idx2).MaskTrigger.Status = 3;
                    end

                %---------------------------------------------------------%
                case app.Description
                    app.editedList(idx1).Band(idx2).Description = app.Description.Value;

                %---------------------------------------------------------%
                case app.ObservationSamples
                    app.editedList(idx1).Observation.Type = 'Samples';
                    if numel(idx2) == 1
                        app.editedList(idx1).Band(idx2).ObservationSamples = app.ObservationSamples.Value;
                    end

                %---------------------------------------------------------%
                case app.FreqStart
                    app.editedList(idx1).Band(idx2).FreqStart   = app.FreqStart.Value * 1e+6;
                    app.Tree.Children(idx1).Children(idx2).Text = TreeBuilding_nodeText(app, idx1, idx2);
                    SpanCheck(app)
                    
                %---------------------------------------------------------%
                case app.FreqStop
                    app.editedList(idx1).Band(idx2).FreqStop    = app.FreqStop.Value * 1e+6;
                    app.Tree.Children(idx1).Children(idx2).Text = TreeBuilding_nodeText(app, idx1, idx2);
                    SpanCheck(app)

                %---------------------------------------------------------%
                case app.StepWidth
                    app.editedList(idx1).Band(idx2).StepWidth = app.StepWidth.Value * 1e+3;

                %---------------------------------------------------------%
                case app.Resolution
                    app.editedList(idx1).Band(idx2).Resolution = app.Resolution.Value * 1e+3;

                %---------------------------------------------------------%
                case app.TraceMode
                    app.editedList(idx1).Band(idx2).TraceMode = app.TraceMode.Value;
                    IntegrationFactorCheck(app)
                    app.editedList(idx1).Band(idx2).IntegrationFactor = app.IntegrationFactor.Value;

                %---------------------------------------------------------%
                case app.IntegrationFactor
                    app.editedList(idx1).Band(idx2).IntegrationFactor = app.IntegrationFactor.Value;

                %---------------------------------------------------------%
                case app.RFMode
                    app.editedList(idx1).Band(idx2).RFMode = app.RFMode.Value;

                %---------------------------------------------------------%
                case app.VBW
                    app.editedList(idx1).Band(idx2).VBW = app.VBW.Value;

                %---------------------------------------------------------%
                case app.Detector
                    app.editedList(idx1).Band(idx2).Detector = app.Detector.Value;

                %---------------------------------------------------------%
                case app.LevelUnit
                    app.editedList(idx1).Band(idx2).LevelUnit = app.LevelUnit.Value;

                %---------------------------------------------------------%
                case app.RevisitTime
                    app.editedList(idx1).Band(idx2).RevisitTime = app.RevisitTime.Value;

                %---------------------------------------------------------%
                % Subpainel "FINDPEAKS"
                %---------------------------------------------------------%
                case app.FindPeaks_nSweeps
                    app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.nSweeps    = app.FindPeaks_nSweeps.Value;

                %---------------------------------------------------------%
                case app.FindPeaks_Prominence
                    app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.Prominence = app.FindPeaks_Prominence.Value;

                %---------------------------------------------------------%
                case app.FindPeaks_Distance
                    app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.Distance   = app.FindPeaks_Distance.Value;

                %---------------------------------------------------------%
                case app.FindPeaks_BW
                    app.editedList(idx1).Band(idx2).MaskTrigger.FindPeaks.BW         = app.FindPeaks_BW.Value;
            end
            
        end

        % Image clicked function: Image_downArrow, Image_upArrow
        function UpDownImageClicked(app, event)
            
            idx1 = app.Tree.SelectedNodes.NodeData;
            idx2 = app.Tree.SelectedNodes.UserData;

            Flag = 0;

            switch event.Source
                case app.Image_upArrow
                    if app.Tree.SelectedNodes.Parent == app.Tree
                        if idx1 > 1
                            app.editedList(idx1-1:idx1) = flip(app.editedList(idx1-1:idx1));

                            Flag = 1;
                            idx1 = idx1-1;
                        end
                    else
                        if idx2 > 1
                            app.editedList(idx1).Band(idx2-1:idx2) = flip(app.editedList(idx1).Band(idx2-1:idx2));
                            newID(app)

                            Flag = 1;
                            idx2 = idx2-1;
                        end
                    end

                case app.Image_downArrow
                    if app.Tree.SelectedNodes.Parent == app.Tree
                        if idx1 < numel(app.editedList)
                            app.editedList(idx1:idx1+1) = flip(app.editedList(idx1:idx1+1));

                            Flag = 1;
                            idx1 = idx1+1;
                        end
                    else
                        if idx2 < numel(app.editedList(idx1).Band)
                            app.editedList(idx1).Band(idx2:idx2+1) = flip(app.editedList(idx1).Band(idx2:idx2+1));
                            newID(app)

                            Flag = 1;
                            idx2 = idx2+1;
                        end
                    end
            end

            if Flag
                if app.Tree.SelectedNodes.Parent == app.Tree
                    TreeBuilding(app, [idx1, -1])
                else
                    TreeBuilding(app, [idx1, idx2])
                end
            end

        end

        % Image clicked function: dockModule_Undock
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
            app.GridLayout.ColumnWidth = {10, 320, 10, '1x', 48, 8, 2};
            app.GridLayout.RowHeight = {2, 8, 24, '1x', 10, 34};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create Toolbar
            app.Toolbar = uigridlayout(app.GridLayout);
            app.Toolbar.ColumnWidth = {22, 22, '1x', 110};
            app.Toolbar.RowHeight = {'1x'};
            app.Toolbar.ColumnSpacing = 5;
            app.Toolbar.Padding = [10 6 10 6];
            app.Toolbar.Layout.Row = 6;
            app.Toolbar.Layout.Column = [1 7];
            app.Toolbar.BackgroundColor = [0.9412 0.9412 0.9412];

            % Create toolOpenFile
            app.toolOpenFile = uiimage(app.Toolbar);
            app.toolOpenFile.ScaleMethod = 'none';
            app.toolOpenFile.ImageClickedFcn = createCallbackFcn(app, @toolButton_openPushed, true);
            app.toolOpenFile.Tooltip = {'Abre arquivo .json com lista de tarefas'};
            app.toolOpenFile.Layout.Row = 1;
            app.toolOpenFile.Layout.Column = 1;
            app.toolOpenFile.ImageSource = 'Import_16.png';

            % Create toolExportFile
            app.toolExportFile = uiimage(app.Toolbar);
            app.toolExportFile.ScaleMethod = 'none';
            app.toolExportFile.ImageClickedFcn = createCallbackFcn(app, @toolButton_exportPushed, true);
            app.toolExportFile.Tooltip = {'Exporta arquivo .json com lista de tarefas'};
            app.toolExportFile.Layout.Row = 1;
            app.toolExportFile.Layout.Column = 2;
            app.toolExportFile.ImageSource = 'Export_16.png';

            % Create toolButton_play
            app.toolButton_play = uibutton(app.Toolbar, 'push');
            app.toolButton_play.ButtonPushedFcn = createCallbackFcn(app, @toolButton_playPushed, true);
            app.toolButton_play.Icon = 'Edit_32White.png';
            app.toolButton_play.IconAlignment = 'right';
            app.toolButton_play.HorizontalAlignment = 'right';
            app.toolButton_play.BackgroundColor = [0.6392 0.0784 0.1804];
            app.toolButton_play.FontSize = 11;
            app.toolButton_play.FontColor = [1 1 1];
            app.toolButton_play.Visible = 'off';
            app.toolButton_play.Layout.Row = 1;
            app.toolButton_play.Layout.Column = 4;
            app.toolButton_play.Text = 'Confirma edição';

            % Create TreeLabel
            app.TreeLabel = uilabel(app.GridLayout);
            app.TreeLabel.FontSize = 10;
            app.TreeLabel.Layout.Row = 3;
            app.TreeLabel.Layout.Column = 2;
            app.TreeLabel.Text = 'TAREFAS';

            % Create TreeGrid
            app.TreeGrid = uigridlayout(app.GridLayout);
            app.TreeGrid.ColumnWidth = {2, 146, '1x', 0};
            app.TreeGrid.RowHeight = {16, 5, 16, 5, 16, '1x', 16, 16, 5, 16, 2};
            app.TreeGrid.ColumnSpacing = 5;
            app.TreeGrid.RowSpacing = 0;
            app.TreeGrid.Padding = [0 0 0 0];
            app.TreeGrid.Layout.Row = 4;
            app.TreeGrid.Layout.Column = 2;
            app.TreeGrid.BackgroundColor = [1 1 1];

            % Create Tree
            app.Tree = uitree(app.TreeGrid);
            app.Tree.SelectionChangedFcn = createCallbackFcn(app, @TreeSelectionChanged, true);
            app.Tree.FontSize = 10;
            app.Tree.Layout.Row = [1 11];
            app.Tree.Layout.Column = [1 3];

            % Create Image_addTask
            app.Image_addTask = uiimage(app.TreeGrid);
            app.Image_addTask.ImageClickedFcn = createCallbackFcn(app, @Image_addTaskPushed, true);
            app.Image_addTask.Enable = 'off';
            app.Image_addTask.Tooltip = {'Adiciona nova tarefa'};
            app.Image_addTask.Layout.Row = 1;
            app.Image_addTask.Layout.Column = 4;
            app.Image_addTask.ImageSource = 'addFileWithPlus_32.png';

            % Create Image_addBand
            app.Image_addBand = uiimage(app.TreeGrid);
            app.Image_addBand.ImageClickedFcn = createCallbackFcn(app, @Image_addBandValueChanged, true);
            app.Image_addBand.Enable = 'off';
            app.Image_addBand.Tooltip = {'Adiciona fluxo espectral à tarefa selecionada'};
            app.Image_addBand.Layout.Row = 3;
            app.Image_addBand.Layout.Column = 4;
            app.Image_addBand.ImageSource = 'EditWithPlus_32.png';

            % Create Image_del
            app.Image_del = uiimage(app.TreeGrid);
            app.Image_del.ImageClickedFcn = createCallbackFcn(app, @Image_delPushed, true);
            app.Image_del.Enable = 'off';
            app.Image_del.Tooltip = {'Exclui tarefa ou fluxo selecionado'};
            app.Image_del.Layout.Row = 5;
            app.Image_del.Layout.Column = 4;
            app.Image_del.ImageSource = 'Delete_32Red.png';

            % Create Image_upArrow
            app.Image_upArrow = uiimage(app.TreeGrid);
            app.Image_upArrow.ImageClickedFcn = createCallbackFcn(app, @UpDownImageClicked, true);
            app.Image_upArrow.Enable = 'off';
            app.Image_upArrow.Tooltip = {'Troca ordem de tarefa ou fluxo selecionado'};
            app.Image_upArrow.Layout.Row = 8;
            app.Image_upArrow.Layout.Column = 4;
            app.Image_upArrow.ImageSource = 'ArrowUp_32.png';

            % Create Image_downArrow
            app.Image_downArrow = uiimage(app.TreeGrid);
            app.Image_downArrow.ImageClickedFcn = createCallbackFcn(app, @UpDownImageClicked, true);
            app.Image_downArrow.Enable = 'off';
            app.Image_downArrow.Tooltip = {'Troca ordem de tarefa ou fluxo selecionado'};
            app.Image_downArrow.Layout.Row = 10;
            app.Image_downArrow.Layout.Column = 4;
            app.Image_downArrow.ImageSource = 'ArrowDown_32.png';

            % Create ButtonGroupPanel
            app.ButtonGroupPanel = uibuttongroup(app.TreeGrid);
            app.ButtonGroupPanel.AutoResizeChildren = 'off';
            app.ButtonGroupPanel.SelectionChangedFcn = createCallbackFcn(app, @OperationModeValueChanged, true);
            app.ButtonGroupPanel.BorderType = 'none';
            app.ButtonGroupPanel.BackgroundColor = [1 1 1];
            app.ButtonGroupPanel.Layout.Row = [7 10];
            app.ButtonGroupPanel.Layout.Column = 2;
            app.ButtonGroupPanel.FontSize = 10;

            % Create ButtonGroup_View
            app.ButtonGroup_View = uiradiobutton(app.ButtonGroupPanel);
            app.ButtonGroup_View.Text = '<font style="color:#0000ff;">VISUALIZAR</font> lista';
            app.ButtonGroup_View.FontSize = 11;
            app.ButtonGroup_View.Interpreter = 'html';
            app.ButtonGroup_View.Position = [6 25 117 22];
            app.ButtonGroup_View.Value = true;

            % Create ButtonGroup_Edit
            app.ButtonGroup_Edit = uiradiobutton(app.ButtonGroupPanel);
            app.ButtonGroup_Edit.Text = '<font style="color:#a2142f;"><b>EDITAR</b></font> lista';
            app.ButtonGroup_Edit.FontSize = 11;
            app.ButtonGroup_Edit.Interpreter = 'html';
            app.ButtonGroup_Edit.Position = [6 6 92 22];

            % Create PanelLabel
            app.PanelLabel = uilabel(app.GridLayout);
            app.PanelLabel.FontSize = 10;
            app.PanelLabel.Layout.Row = 3;
            app.PanelLabel.Layout.Column = 4;
            app.PanelLabel.Text = 'CARACTERÍSTICAS';

            % Create Panel
            app.Panel = uipanel(app.GridLayout);
            app.Panel.AutoResizeChildren = 'off';
            app.Panel.Layout.Row = 4;
            app.Panel.Layout.Column = [4 5];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel);
            app.GridLayout2.ColumnWidth = {320, '1x'};
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create Tab2_PanelGrid
            app.Tab2_PanelGrid = uigridlayout(app.GridLayout2);
            app.Tab2_PanelGrid.ColumnWidth = {'1x'};
            app.Tab2_PanelGrid.RowHeight = {17, 22, 22, 22, 22, 90, 22, 22, '1x'};
            app.Tab2_PanelGrid.ColumnSpacing = 20;
            app.Tab2_PanelGrid.RowSpacing = 5;
            app.Tab2_PanelGrid.Padding = [0 0 0 0];
            app.Tab2_PanelGrid.Layout.Row = 1;
            app.Tab2_PanelGrid.Layout.Column = 1;
            app.Tab2_PanelGrid.BackgroundColor = [1 1 1];

            % Create NameLabel
            app.NameLabel = uilabel(app.Tab2_PanelGrid);
            app.NameLabel.VerticalAlignment = 'bottom';
            app.NameLabel.FontSize = 10;
            app.NameLabel.Layout.Row = 1;
            app.NameLabel.Layout.Column = 1;
            app.NameLabel.Text = 'Nome:';

            % Create Name
            app.Name = uieditfield(app.Tab2_PanelGrid, 'text');
            app.Name.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.Name.Editable = 'off';
            app.Name.FontSize = 11;
            app.Name.Layout.Row = 2;
            app.Name.Layout.Column = 1;

            % Create BitsPerPointLabel
            app.BitsPerPointLabel = uilabel(app.Tab2_PanelGrid);
            app.BitsPerPointLabel.VerticalAlignment = 'bottom';
            app.BitsPerPointLabel.FontSize = 10;
            app.BitsPerPointLabel.Layout.Row = 3;
            app.BitsPerPointLabel.Layout.Column = 1;
            app.BitsPerPointLabel.Text = 'Codificação:';

            % Create BitsPerPoint
            app.BitsPerPoint = uidropdown(app.Tab2_PanelGrid);
            app.BitsPerPoint.Items = {'8 bits', '16 bits', '32 bits'};
            app.BitsPerPoint.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.BitsPerPoint.FontSize = 11;
            app.BitsPerPoint.BackgroundColor = [1 1 1];
            app.BitsPerPoint.Layout.Row = 4;
            app.BitsPerPoint.Layout.Column = 1;
            app.BitsPerPoint.Value = '8 bits';

            % Create ObservationLabel
            app.ObservationLabel = uilabel(app.Tab2_PanelGrid);
            app.ObservationLabel.VerticalAlignment = 'bottom';
            app.ObservationLabel.FontSize = 10;
            app.ObservationLabel.Layout.Row = 5;
            app.ObservationLabel.Layout.Column = 1;
            app.ObservationLabel.Text = 'Período de observação:';

            % Create ObservationPanel
            app.ObservationPanel = uipanel(app.Tab2_PanelGrid);
            app.ObservationPanel.AutoResizeChildren = 'off';
            app.ObservationPanel.Layout.Row = 6;
            app.ObservationPanel.Layout.Column = 1;

            % Create ObservationPanel_Grid
            app.ObservationPanel_Grid = uigridlayout(app.ObservationPanel);
            app.ObservationPanel_Grid.ColumnWidth = {'1x'};
            app.ObservationPanel_Grid.RowHeight = {17, 22, 22, 49};
            app.ObservationPanel_Grid.ColumnSpacing = 11;
            app.ObservationPanel_Grid.RowSpacing = 5;
            app.ObservationPanel_Grid.Padding = [10 10 10 5];
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
            app.ObservationType.ValueChangedFcn = createCallbackFcn(app, @ObservationTimeValueChanged, true);
            app.ObservationType.Tag = 'task_Editable';
            app.ObservationType.FontSize = 11;
            app.ObservationType.BackgroundColor = [1 1 1];
            app.ObservationType.Layout.Row = 2;
            app.ObservationType.Layout.Column = 1;
            app.ObservationType.Value = 'Duração';

            % Create Duration_Grid
            app.Duration_Grid = uigridlayout(app.ObservationPanel_Grid);
            app.Duration_Grid.ColumnWidth = {116, 116};
            app.Duration_Grid.RowHeight = {'1x'};
            app.Duration_Grid.RowSpacing = 5;
            app.Duration_Grid.Padding = [0 0 0 0];
            app.Duration_Grid.Layout.Row = 3;
            app.Duration_Grid.Layout.Column = 1;
            app.Duration_Grid.BackgroundColor = [1 1 1];

            % Create Duration
            app.Duration = uieditfield(app.Duration_Grid, 'numeric');
            app.Duration.Limits = [1 Inf];
            app.Duration.ValueDisplayFormat = '%.3f';
            app.Duration.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.Duration.Tag = 'task_Editable';
            app.Duration.Editable = 'off';
            app.Duration.FontSize = 11;
            app.Duration.Layout.Row = 1;
            app.Duration.Layout.Column = 1;
            app.Duration.Value = 10;

            % Create DurationUnit
            app.DurationUnit = uidropdown(app.Duration_Grid);
            app.DurationUnit.Items = {'min', 'hr'};
            app.DurationUnit.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.DurationUnit.Tag = 'task_Editable';
            app.DurationUnit.FontSize = 11;
            app.DurationUnit.BackgroundColor = [1 1 1];
            app.DurationUnit.Layout.Row = 1;
            app.DurationUnit.Layout.Column = 2;
            app.DurationUnit.Value = 'min';

            % Create SpecificTime_Grid
            app.SpecificTime_Grid = uigridlayout(app.ObservationPanel_Grid);
            app.SpecificTime_Grid.ColumnWidth = {55, 5, 56, 10, 55, 5, 56};
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
            app.SpecificTime_DatePicker1.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
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
            app.SpecificTime_Spinner1.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
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
            app.SpecificTime_Spinner2.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.SpecificTime_Spinner2.HorizontalAlignment = 'center';
            app.SpecificTime_Spinner2.FontSize = 11;
            app.SpecificTime_Spinner2.Enable = 'off';
            app.SpecificTime_Spinner2.Visible = 'off';
            app.SpecificTime_Spinner2.Layout.Row = 2;
            app.SpecificTime_Spinner2.Layout.Column = 3;

            % Create SpecificTime_DatePicker2
            app.SpecificTime_DatePicker2 = uidatepicker(app.SpecificTime_Grid);
            app.SpecificTime_DatePicker2.DisplayFormat = 'dd/MM/uuuu';
            app.SpecificTime_DatePicker2.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
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
            app.SpecificTime_Spinner3.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
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
            app.SpecificTime_Spinner4.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
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

            % Create gpsModeLabel
            app.gpsModeLabel = uilabel(app.Tab2_PanelGrid);
            app.gpsModeLabel.VerticalAlignment = 'bottom';
            app.gpsModeLabel.FontSize = 10;
            app.gpsModeLabel.Layout.Row = 7;
            app.gpsModeLabel.Layout.Column = 1;
            app.gpsModeLabel.Text = 'GPS:';

            % Create gpsMode
            app.gpsMode = uidropdown(app.Tab2_PanelGrid);
            app.gpsMode.Items = {'auto', 'manual'};
            app.gpsMode.ValueChangedFcn = createCallbackFcn(app, @gpsModeValueChanged, true);
            app.gpsMode.Tag = 'task_Editable';
            app.gpsMode.FontSize = 10;
            app.gpsMode.BackgroundColor = [1 1 1];
            app.gpsMode.Layout.Row = 8;
            app.gpsMode.Layout.Column = 1;
            app.gpsMode.Value = 'auto';

            % Create GPS_Panel
            app.GPS_Panel = uipanel(app.Tab2_PanelGrid);
            app.GPS_Panel.AutoResizeChildren = 'off';
            app.GPS_Panel.Layout.Row = 9;
            app.GPS_Panel.Layout.Column = 1;

            % Create GPS_Grid
            app.GPS_Grid = uigridlayout(app.GPS_Panel);
            app.GPS_Grid.ColumnWidth = {116, '1x'};
            app.GPS_Grid.RowHeight = {25, 22, 17, 22};
            app.GPS_Grid.RowSpacing = 5;
            app.GPS_Grid.BackgroundColor = [1 1 1];

            % Create GPS_manualLatitudeLabel
            app.GPS_manualLatitudeLabel = uilabel(app.GPS_Grid);
            app.GPS_manualLatitudeLabel.VerticalAlignment = 'bottom';
            app.GPS_manualLatitudeLabel.FontSize = 10;
            app.GPS_manualLatitudeLabel.Layout.Row = 1;
            app.GPS_manualLatitudeLabel.Layout.Column = 1;
            app.GPS_manualLatitudeLabel.Text = {'Latitude:'; '(graus decimais)'};

            % Create GPS_manualLatitude
            app.GPS_manualLatitude = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_manualLatitude.ValueDisplayFormat = '%.6f';
            app.GPS_manualLatitude.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.GPS_manualLatitude.Tag = 'task_Editable';
            app.GPS_manualLatitude.Editable = 'off';
            app.GPS_manualLatitude.FontSize = 11;
            app.GPS_manualLatitude.Enable = 'off';
            app.GPS_manualLatitude.Layout.Row = 2;
            app.GPS_manualLatitude.Layout.Column = 1;
            app.GPS_manualLatitude.Value = -1;

            % Create GPS_manualLongitudeLabel
            app.GPS_manualLongitudeLabel = uilabel(app.GPS_Grid);
            app.GPS_manualLongitudeLabel.VerticalAlignment = 'bottom';
            app.GPS_manualLongitudeLabel.FontSize = 10;
            app.GPS_manualLongitudeLabel.Layout.Row = 1;
            app.GPS_manualLongitudeLabel.Layout.Column = 2;
            app.GPS_manualLongitudeLabel.Text = {'Longitude:'; '(graus decimais)'};

            % Create GPS_manualLongitude
            app.GPS_manualLongitude = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_manualLongitude.ValueDisplayFormat = '%.6f';
            app.GPS_manualLongitude.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.GPS_manualLongitude.Tag = 'task_Editable';
            app.GPS_manualLongitude.Editable = 'off';
            app.GPS_manualLongitude.FontSize = 11;
            app.GPS_manualLongitude.Enable = 'off';
            app.GPS_manualLongitude.Layout.Row = 2;
            app.GPS_manualLongitude.Layout.Column = 2;
            app.GPS_manualLongitude.Value = -1;

            % Create GPS_RevisitTimeLabel
            app.GPS_RevisitTimeLabel = uilabel(app.GPS_Grid);
            app.GPS_RevisitTimeLabel.VerticalAlignment = 'bottom';
            app.GPS_RevisitTimeLabel.FontSize = 10;
            app.GPS_RevisitTimeLabel.Layout.Row = 3;
            app.GPS_RevisitTimeLabel.Layout.Column = 1;
            app.GPS_RevisitTimeLabel.Text = 'Tempo revisita (seg):';

            % Create GPS_RevisitTime
            app.GPS_RevisitTime = uieditfield(app.GPS_Grid, 'numeric');
            app.GPS_RevisitTime.Limits = [1 Inf];
            app.GPS_RevisitTime.RoundFractionalValues = 'on';
            app.GPS_RevisitTime.ValueDisplayFormat = '%.0f';
            app.GPS_RevisitTime.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.GPS_RevisitTime.Tag = 'task_Editable';
            app.GPS_RevisitTime.Editable = 'off';
            app.GPS_RevisitTime.FontSize = 11;
            app.GPS_RevisitTime.Layout.Row = 4;
            app.GPS_RevisitTime.Layout.Column = 1;
            app.GPS_RevisitTime.Value = 60;

            % Create BandSpecificInfo_Grid
            app.BandSpecificInfo_Grid = uigridlayout(app.GridLayout2);
            app.BandSpecificInfo_Grid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.BandSpecificInfo_Grid.RowHeight = {17, 22, 22, 22, 22, 22, 22, 22, 22, 22, 34, 22, '1x'};
            app.BandSpecificInfo_Grid.RowSpacing = 5;
            app.BandSpecificInfo_Grid.Padding = [0 0 0 0];
            app.BandSpecificInfo_Grid.Layout.Row = 1;
            app.BandSpecificInfo_Grid.Layout.Column = 2;
            app.BandSpecificInfo_Grid.BackgroundColor = [1 1 1];

            % Create StatusLabel
            app.StatusLabel = uilabel(app.BandSpecificInfo_Grid);
            app.StatusLabel.VerticalAlignment = 'bottom';
            app.StatusLabel.FontSize = 10;
            app.StatusLabel.FontColor = [0.149 0.149 0.149];
            app.StatusLabel.Layout.Row = 1;
            app.StatusLabel.Layout.Column = 1;
            app.StatusLabel.Text = 'Estado:';

            % Create Status
            app.Status = uidropdown(app.BandSpecificInfo_Grid);
            app.Status.Items = {'ON', 'OFF'};
            app.Status.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.Status.FontSize = 11;
            app.Status.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Status.Layout.Row = 2;
            app.Status.Layout.Column = 1;
            app.Status.Value = 'ON';

            % Create MaskTriggerLabel
            app.MaskTriggerLabel = uilabel(app.BandSpecificInfo_Grid);
            app.MaskTriggerLabel.VerticalAlignment = 'bottom';
            app.MaskTriggerLabel.FontSize = 10;
            app.MaskTriggerLabel.FontColor = [0.149 0.149 0.149];
            app.MaskTriggerLabel.Layout.Row = 1;
            app.MaskTriggerLabel.Layout.Column = [2 3];
            app.MaskTriggerLabel.Text = 'Máscara espectral:';

            % Create MaskTrigger
            app.MaskTrigger = uidropdown(app.BandSpecificInfo_Grid);
            app.MaskTrigger.Items = {'OFF', 'ON - Apenas afere rompimento', 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)', 'ON - Afere rompimento e salva em arquivo'};
            app.MaskTrigger.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.MaskTrigger.FontSize = 11;
            app.MaskTrigger.BackgroundColor = [0.9412 0.9412 0.9412];
            app.MaskTrigger.Layout.Row = 2;
            app.MaskTrigger.Layout.Column = [2 4];
            app.MaskTrigger.Value = 'ON - Afere rompimento e salva em arquivo (caso rompida máscara)';

            % Create IDLabel
            app.IDLabel = uilabel(app.BandSpecificInfo_Grid);
            app.IDLabel.VerticalAlignment = 'bottom';
            app.IDLabel.FontSize = 10;
            app.IDLabel.Layout.Row = 3;
            app.IDLabel.Layout.Column = 1;
            app.IDLabel.Text = 'ID';

            % Create ID
            app.ID = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.ID.Limits = [1 Inf];
            app.ID.RoundFractionalValues = 'on';
            app.ID.ValueDisplayFormat = '%.0f';
            app.ID.Editable = 'off';
            app.ID.FontSize = 11;
            app.ID.Layout.Row = 4;
            app.ID.Layout.Column = 1;
            app.ID.Value = 1;

            % Create DescriptionLabel
            app.DescriptionLabel = uilabel(app.BandSpecificInfo_Grid);
            app.DescriptionLabel.VerticalAlignment = 'bottom';
            app.DescriptionLabel.FontSize = 10;
            app.DescriptionLabel.Layout.Row = 3;
            app.DescriptionLabel.Layout.Column = [2 3];
            app.DescriptionLabel.Text = 'Descrição:';

            % Create Description
            app.Description = uieditfield(app.BandSpecificInfo_Grid, 'text');
            app.Description.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.Description.Editable = 'off';
            app.Description.FontSize = 11;
            app.Description.Layout.Row = 4;
            app.Description.Layout.Column = [2 3];

            % Create ObservationSamplesLabel
            app.ObservationSamplesLabel = uilabel(app.BandSpecificInfo_Grid);
            app.ObservationSamplesLabel.VerticalAlignment = 'bottom';
            app.ObservationSamplesLabel.FontSize = 10;
            app.ObservationSamplesLabel.Layout.Row = 3;
            app.ObservationSamplesLabel.Layout.Column = 4;
            app.ObservationSamplesLabel.Text = 'Amostras a coletar:';

            % Create ObservationSamples
            app.ObservationSamples = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.ObservationSamples.Limits = [-1 Inf];
            app.ObservationSamples.RoundFractionalValues = 'on';
            app.ObservationSamples.ValueDisplayFormat = '%.0f';
            app.ObservationSamples.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.ObservationSamples.Editable = 'off';
            app.ObservationSamples.FontSize = 11;
            app.ObservationSamples.Enable = 'off';
            app.ObservationSamples.Layout.Row = 4;
            app.ObservationSamples.Layout.Column = 4;
            app.ObservationSamples.Value = -1;

            % Create FreqStartLabel
            app.FreqStartLabel = uilabel(app.BandSpecificInfo_Grid);
            app.FreqStartLabel.VerticalAlignment = 'bottom';
            app.FreqStartLabel.FontSize = 10;
            app.FreqStartLabel.Layout.Row = 5;
            app.FreqStartLabel.Layout.Column = 1;
            app.FreqStartLabel.Text = {'Frequência inicial'; '(MHz):'};

            % Create FreqStart
            app.FreqStart = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.FreqStart.Limits = [0.1 100000];
            app.FreqStart.ValueDisplayFormat = '%.6f';
            app.FreqStart.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.FreqStart.Editable = 'off';
            app.FreqStart.HorizontalAlignment = 'left';
            app.FreqStart.FontSize = 11;
            app.FreqStart.Layout.Row = 6;
            app.FreqStart.Layout.Column = 1;
            app.FreqStart.Value = 108;

            % Create FreqStopLabel
            app.FreqStopLabel = uilabel(app.BandSpecificInfo_Grid);
            app.FreqStopLabel.VerticalAlignment = 'bottom';
            app.FreqStopLabel.FontSize = 10;
            app.FreqStopLabel.Layout.Row = 5;
            app.FreqStopLabel.Layout.Column = 2;
            app.FreqStopLabel.Text = {'Frequência final'; '(MHz):'};

            % Create FreqStop
            app.FreqStop = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.FreqStop.Limits = [0.1 100000];
            app.FreqStop.ValueDisplayFormat = '%.6f';
            app.FreqStop.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.FreqStop.Editable = 'off';
            app.FreqStop.HorizontalAlignment = 'left';
            app.FreqStop.FontSize = 11;
            app.FreqStop.Layout.Row = 6;
            app.FreqStop.Layout.Column = 2;
            app.FreqStop.Value = 108;

            % Create StepWidthLabel
            app.StepWidthLabel = uilabel(app.BandSpecificInfo_Grid);
            app.StepWidthLabel.VerticalAlignment = 'bottom';
            app.StepWidthLabel.FontSize = 10;
            app.StepWidthLabel.Layout.Row = 5;
            app.StepWidthLabel.Layout.Column = 3;
            app.StepWidthLabel.Text = {'Passo varredura'; '(kHz):'};

            % Create StepWidth
            app.StepWidth = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.StepWidth.Limits = [1 Inf];
            app.StepWidth.ValueDisplayFormat = '%.3f';
            app.StepWidth.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.StepWidth.Editable = 'off';
            app.StepWidth.FontSize = 11;
            app.StepWidth.Layout.Row = 6;
            app.StepWidth.Layout.Column = 3;
            app.StepWidth.Value = 1;

            % Create ResolutionLabel
            app.ResolutionLabel = uilabel(app.BandSpecificInfo_Grid);
            app.ResolutionLabel.VerticalAlignment = 'bottom';
            app.ResolutionLabel.FontSize = 10;
            app.ResolutionLabel.Layout.Row = 5;
            app.ResolutionLabel.Layout.Column = 4;
            app.ResolutionLabel.Text = {'Resolução'; '(kHz):'};

            % Create Resolution
            app.Resolution = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.Resolution.Limits = [1 Inf];
            app.Resolution.ValueDisplayFormat = '%.3f';
            app.Resolution.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.Resolution.Editable = 'off';
            app.Resolution.FontSize = 11;
            app.Resolution.Layout.Row = 6;
            app.Resolution.Layout.Column = 4;
            app.Resolution.Value = 1;

            % Create TraceModeLabel
            app.TraceModeLabel = uilabel(app.BandSpecificInfo_Grid);
            app.TraceModeLabel.VerticalAlignment = 'bottom';
            app.TraceModeLabel.FontSize = 10;
            app.TraceModeLabel.Layout.Row = 7;
            app.TraceModeLabel.Layout.Column = 1;
            app.TraceModeLabel.Text = 'Modo do traço:';

            % Create TraceMode
            app.TraceMode = uidropdown(app.BandSpecificInfo_Grid);
            app.TraceMode.Items = {'ClearWrite', 'Average', 'MaxHold', 'MinHold'};
            app.TraceMode.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.TraceMode.FontSize = 11;
            app.TraceMode.BackgroundColor = [1 1 1];
            app.TraceMode.Layout.Row = 8;
            app.TraceMode.Layout.Column = 1;
            app.TraceMode.Value = 'Average';

            % Create IntegrationFactorLabel
            app.IntegrationFactorLabel = uilabel(app.BandSpecificInfo_Grid);
            app.IntegrationFactorLabel.VerticalAlignment = 'bottom';
            app.IntegrationFactorLabel.FontSize = 10;
            app.IntegrationFactorLabel.Layout.Row = 7;
            app.IntegrationFactorLabel.Layout.Column = 2;
            app.IntegrationFactorLabel.Text = 'Fator integração:';

            % Create IntegrationFactor
            app.IntegrationFactor = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.IntegrationFactor.Limits = [1 Inf];
            app.IntegrationFactor.RoundFractionalValues = 'on';
            app.IntegrationFactor.ValueDisplayFormat = '%.0f';
            app.IntegrationFactor.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.IntegrationFactor.Editable = 'off';
            app.IntegrationFactor.FontSize = 11;
            app.IntegrationFactor.Layout.Row = 8;
            app.IntegrationFactor.Layout.Column = 2;
            app.IntegrationFactor.Value = 1;

            % Create RFModeLabel
            app.RFModeLabel = uilabel(app.BandSpecificInfo_Grid);
            app.RFModeLabel.VerticalAlignment = 'bottom';
            app.RFModeLabel.FontSize = 10;
            app.RFModeLabel.Layout.Row = 7;
            app.RFModeLabel.Layout.Column = 3;
            app.RFModeLabel.Text = 'Modo de RF:';

            % Create RFMode
            app.RFMode = uidropdown(app.BandSpecificInfo_Grid);
            app.RFMode.Items = {'High Sensitivity', 'Low Distortion', 'Normal'};
            app.RFMode.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.RFMode.FontSize = 11;
            app.RFMode.BackgroundColor = [1 1 1];
            app.RFMode.Layout.Row = 8;
            app.RFMode.Layout.Column = 3;
            app.RFMode.Value = 'High Sensitivity';

            % Create VBWLabel
            app.VBWLabel = uilabel(app.BandSpecificInfo_Grid);
            app.VBWLabel.VerticalAlignment = 'bottom';
            app.VBWLabel.FontSize = 10;
            app.VBWLabel.Layout.Row = 7;
            app.VBWLabel.Layout.Column = 4;
            app.VBWLabel.Text = 'VBW:';

            % Create VBW
            app.VBW = uidropdown(app.BandSpecificInfo_Grid);
            app.VBW.Items = {'auto', 'RBW', 'RBW/10', 'RBW/100'};
            app.VBW.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.VBW.FontSize = 11;
            app.VBW.BackgroundColor = [1 1 1];
            app.VBW.Layout.Row = 8;
            app.VBW.Layout.Column = 4;
            app.VBW.Value = 'auto';

            % Create DetectorLabel
            app.DetectorLabel = uilabel(app.BandSpecificInfo_Grid);
            app.DetectorLabel.VerticalAlignment = 'bottom';
            app.DetectorLabel.FontSize = 10;
            app.DetectorLabel.Layout.Row = 9;
            app.DetectorLabel.Layout.Column = 1;
            app.DetectorLabel.Text = 'Detector:';

            % Create Detector
            app.Detector = uidropdown(app.BandSpecificInfo_Grid);
            app.Detector.Items = {'Sample', 'Average/RMS', 'Positive Peak', 'Negative Peak'};
            app.Detector.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.Detector.FontSize = 11;
            app.Detector.BackgroundColor = [1 1 1];
            app.Detector.Layout.Row = 10;
            app.Detector.Layout.Column = [1 2];
            app.Detector.Value = 'Sample';

            % Create LevelUnitLabel
            app.LevelUnitLabel = uilabel(app.BandSpecificInfo_Grid);
            app.LevelUnitLabel.VerticalAlignment = 'bottom';
            app.LevelUnitLabel.FontSize = 10;
            app.LevelUnitLabel.Layout.Row = 9;
            app.LevelUnitLabel.Layout.Column = 3;
            app.LevelUnitLabel.Text = 'Unidade:';

            % Create LevelUnit
            app.LevelUnit = uidropdown(app.BandSpecificInfo_Grid);
            app.LevelUnit.Items = {'dBm', 'dBµV'};
            app.LevelUnit.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.LevelUnit.FontSize = 11;
            app.LevelUnit.BackgroundColor = [1 1 1];
            app.LevelUnit.Layout.Row = 10;
            app.LevelUnit.Layout.Column = 3;
            app.LevelUnit.Value = 'dBm';

            % Create RevisitTimeLabel
            app.RevisitTimeLabel = uilabel(app.BandSpecificInfo_Grid);
            app.RevisitTimeLabel.VerticalAlignment = 'bottom';
            app.RevisitTimeLabel.FontSize = 10;
            app.RevisitTimeLabel.Layout.Row = 9;
            app.RevisitTimeLabel.Layout.Column = 4;
            app.RevisitTimeLabel.Text = 'Tempo revisita (seg):';

            % Create RevisitTime
            app.RevisitTime = uieditfield(app.BandSpecificInfo_Grid, 'numeric');
            app.RevisitTime.Limits = [0.001 Inf];
            app.RevisitTime.ValueDisplayFormat = '%.3f';
            app.RevisitTime.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.RevisitTime.Editable = 'off';
            app.RevisitTime.FontSize = 11;
            app.RevisitTime.Layout.Row = 10;
            app.RevisitTime.Layout.Column = 4;
            app.RevisitTime.Value = 1;

            % Create FindPeaks_PanelLabel
            app.FindPeaks_PanelLabel = uilabel(app.BandSpecificInfo_Grid);
            app.FindPeaks_PanelLabel.VerticalAlignment = 'bottom';
            app.FindPeaks_PanelLabel.FontSize = 10;
            app.FindPeaks_PanelLabel.Layout.Row = 11;
            app.FindPeaks_PanelLabel.Layout.Column = [1 4];
            app.FindPeaks_PanelLabel.Text = {'Parâmetros relacionados à busca de emissões: '; '(caso evidenciado rompimento de máscara espectral)'};

            % Create FindPeaks_Panel
            app.FindPeaks_Panel = uipanel(app.BandSpecificInfo_Grid);
            app.FindPeaks_Panel.AutoResizeChildren = 'off';
            app.FindPeaks_Panel.Layout.Row = [12 13];
            app.FindPeaks_Panel.Layout.Column = [1 4];

            % Create FindPeaks_Grid
            app.FindPeaks_Grid = uigridlayout(app.FindPeaks_Panel);
            app.FindPeaks_Grid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.FindPeaks_Grid.RowHeight = {22, 34, 22};
            app.FindPeaks_Grid.RowSpacing = 5;
            app.FindPeaks_Grid.BackgroundColor = [1 1 1];

            % Create FindPeaks_TypeLabel
            app.FindPeaks_TypeLabel = uilabel(app.FindPeaks_Grid);
            app.FindPeaks_TypeLabel.FontSize = 10;
            app.FindPeaks_TypeLabel.Layout.Row = 1;
            app.FindPeaks_TypeLabel.Layout.Column = 1;
            app.FindPeaks_TypeLabel.Text = 'Parâmetros:';

            % Create FindPeaks_Type
            app.FindPeaks_Type = uidropdown(app.FindPeaks_Grid);
            app.FindPeaks_Type.Items = {'Valores padrão (appColeta)', 'Valores customizados'};
            app.FindPeaks_Type.ValueChangedFcn = createCallbackFcn(app, @FindPeaksDropDownValueChanged, true);
            app.FindPeaks_Type.FontSize = 11;
            app.FindPeaks_Type.BackgroundColor = [1 1 1];
            app.FindPeaks_Type.Layout.Row = 1;
            app.FindPeaks_Type.Layout.Column = [2 4];
            app.FindPeaks_Type.Value = 'Valores padrão (appColeta)';

            % Create FindPeaks_nSweepsLabel
            app.FindPeaks_nSweepsLabel = uilabel(app.FindPeaks_Grid);
            app.FindPeaks_nSweepsLabel.VerticalAlignment = 'bottom';
            app.FindPeaks_nSweepsLabel.FontSize = 10;
            app.FindPeaks_nSweepsLabel.Layout.Row = 2;
            app.FindPeaks_nSweepsLabel.Layout.Column = 1;
            app.FindPeaks_nSweepsLabel.Text = {'Quantidade de'; 'varreduras:'};

            % Create FindPeaks_nSweeps
            app.FindPeaks_nSweeps = uispinner(app.FindPeaks_Grid);
            app.FindPeaks_nSweeps.Limits = [1 100];
            app.FindPeaks_nSweeps.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.FindPeaks_nSweeps.FontSize = 11;
            app.FindPeaks_nSweeps.Layout.Row = 3;
            app.FindPeaks_nSweeps.Layout.Column = 1;
            app.FindPeaks_nSweeps.Value = 10;

            % Create FindPeaks_ProminenceLabel
            app.FindPeaks_ProminenceLabel = uilabel(app.FindPeaks_Grid);
            app.FindPeaks_ProminenceLabel.VerticalAlignment = 'bottom';
            app.FindPeaks_ProminenceLabel.WordWrap = 'on';
            app.FindPeaks_ProminenceLabel.FontSize = 10;
            app.FindPeaks_ProminenceLabel.Layout.Row = 2;
            app.FindPeaks_ProminenceLabel.Layout.Column = 2;
            app.FindPeaks_ProminenceLabel.Text = {'Proeminência '; 'mínima (dB):'};

            % Create FindPeaks_Prominence
            app.FindPeaks_Prominence = uispinner(app.FindPeaks_Grid);
            app.FindPeaks_Prominence.Step = 10;
            app.FindPeaks_Prominence.Limits = [3 50];
            app.FindPeaks_Prominence.RoundFractionalValues = 'on';
            app.FindPeaks_Prominence.ValueDisplayFormat = '%.0f';
            app.FindPeaks_Prominence.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.FindPeaks_Prominence.FontSize = 11;
            app.FindPeaks_Prominence.Layout.Row = 3;
            app.FindPeaks_Prominence.Layout.Column = 2;
            app.FindPeaks_Prominence.Value = 30;

            % Create FindPeaks_DistanceLabel
            app.FindPeaks_DistanceLabel = uilabel(app.FindPeaks_Grid);
            app.FindPeaks_DistanceLabel.VerticalAlignment = 'bottom';
            app.FindPeaks_DistanceLabel.WordWrap = 'on';
            app.FindPeaks_DistanceLabel.FontSize = 10;
            app.FindPeaks_DistanceLabel.Layout.Row = 2;
            app.FindPeaks_DistanceLabel.Layout.Column = 3;
            app.FindPeaks_DistanceLabel.Text = {'Distância mínima '; 'entre picos (kHz):'};

            % Create FindPeaks_Distance
            app.FindPeaks_Distance = uispinner(app.FindPeaks_Grid);
            app.FindPeaks_Distance.Step = 25;
            app.FindPeaks_Distance.Limits = [0 100000];
            app.FindPeaks_Distance.RoundFractionalValues = 'on';
            app.FindPeaks_Distance.ValueDisplayFormat = '%.0f';
            app.FindPeaks_Distance.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.FindPeaks_Distance.FontSize = 11;
            app.FindPeaks_Distance.Layout.Row = 3;
            app.FindPeaks_Distance.Layout.Column = 3;
            app.FindPeaks_Distance.Value = 25;

            % Create FindPeaks_BWLabel
            app.FindPeaks_BWLabel = uilabel(app.FindPeaks_Grid);
            app.FindPeaks_BWLabel.VerticalAlignment = 'bottom';
            app.FindPeaks_BWLabel.WordWrap = 'on';
            app.FindPeaks_BWLabel.FontSize = 10;
            app.FindPeaks_BWLabel.Layout.Row = 2;
            app.FindPeaks_BWLabel.Layout.Column = 4;
            app.FindPeaks_BWLabel.Text = {'Largura mínima'; 'ocupada (kHz):'};

            % Create FindPeaks_BW
            app.FindPeaks_BW = uispinner(app.FindPeaks_Grid);
            app.FindPeaks_BW.Step = 10;
            app.FindPeaks_BW.Limits = [0 100000];
            app.FindPeaks_BW.RoundFractionalValues = 'on';
            app.FindPeaks_BW.ValueDisplayFormat = '%.0f';
            app.FindPeaks_BW.ValueChangedFcn = createCallbackFcn(app, @TaskParameterChanged, true);
            app.FindPeaks_BW.FontSize = 11;
            app.FindPeaks_BW.Layout.Row = 3;
            app.FindPeaks_BW.Layout.Column = 4;
            app.FindPeaks_BW.Value = 10;

            % Create DockModuleGroup
            app.DockModuleGroup = uigridlayout(app.GridLayout);
            app.DockModuleGroup.RowHeight = {'1x'};
            app.DockModuleGroup.ColumnSpacing = 2;
            app.DockModuleGroup.Padding = [5 2 5 2];
            app.DockModuleGroup.Visible = 'off';
            app.DockModuleGroup.Layout.Row = [2 3];
            app.DockModuleGroup.Layout.Column = [5 6];
            app.DockModuleGroup.BackgroundColor = [0.2 0.2 0.2];

            % Create dockModule_Close
            app.dockModule_Close = uiimage(app.DockModuleGroup);
            app.dockModule_Close.ScaleMethod = 'none';
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
