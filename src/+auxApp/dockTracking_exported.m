classdef dockTracking_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        StatusLabel        matlab.ui.control.Label
        LogButton          matlab.ui.control.Button
        GaugePanel         matlab.ui.container.Panel
        GaugeGrid          matlab.ui.container.GridLayout
        PolarizationValue  matlab.ui.control.Label
        PolarizationGauge  matlab.ui.control.Gauge
        PolarizationLabel  matlab.ui.control.Label
        ElevationValue     matlab.ui.control.Label
        ElevationGrid      matlab.ui.container.GridLayout
        ElevationGauge     matlab.ui.control.NinetyDegreeGauge
        ElevationLabel     matlab.ui.control.Label
        AzimuthValue       matlab.ui.control.Label
        AzimuthGauge       matlab.ui.control.Gauge
        AzimuthLabel       matlab.ui.control.Label
        PositionGrid       matlab.ui.container.GridLayout
        TargetPosValue     matlab.ui.control.Label
        TargetPosLabel     matlab.ui.control.Label
        CurrentPosValue    matlab.ui.control.Label
        CurrentPosLabel    matlab.ui.control.Label
        InitialPosValue    matlab.ui.control.Label
        InitialPosLabel    matlab.ui.control.Label
        AntennaNameLabel   matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true        
        isUpdatable = true
        
        mainApp
        callingApp
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        TrackingActive = false
        TrackingTimer

        InitialPosition
        TargetPosition

        UpdateStatus = false
        RestartRequested = false
        PendingTargets = struct('antennaPos', {}, 'targetPos', {})
        LogEntries = struct('type', {}, 'time', {}, 'msg',  {})
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        function screenStartup(app, antennaPos, targetPos)
            app.AntennaNameLabel.Text = targetPos.Name;
            app.InitialPosValue.Text  = sprintf('(%.3fº, %.3fº, %.3fº)', antennaPos.Azimuth, antennaPos.Elevation, antennaPos.Polarization);
            app.TargetPosValue.Text   = sprintf('(%.3fº, %.3fº, %.3fº)', targetPos.Azimuth,  targetPos.Elevation,  targetPos.Polarization);
            screenUpdate(app, antennaPos)

            setCircularGaugeScale(app, app.AzimuthGauge, [antennaPos.Azimuth, targetPos.Azimuth])
            setCircularGaugeScale(app, app.PolarizationGauge, [antennaPos.Polarization, targetPos.Polarization])

            elevationRange = sort(min(max([antennaPos.Elevation, targetPos.Elevation], 0), 90));
            if diff(elevationRange) > 0
                set(app.ElevationGauge, 'ScaleColors', [1 1 0], 'ScaleColorLimits', elevationRange)
            end

            drawnow
        end

        %-----------------------------------------------------------------%
        function screenUpdate(app, antennaPos)
            app.CurrentPosValue.Text  = sprintf('(%.3fº, %.3fº, %.3fº)', antennaPos.Azimuth, antennaPos.Elevation, antennaPos.Polarization);

            app.AzimuthValue.Text = sprintf('%.3fº', antennaPos.Azimuth);
            app.ElevationValue.Text = sprintf('%.3fº', antennaPos.Elevation);
            app.PolarizationValue.Text = sprintf('%.3fº', antennaPos.Polarization);

            % O ACU pode reportar ângulos fora dos limites dos medidores.
            app.AzimuthGauge.Value      = mod(antennaPos.Azimuth, 360);
            app.ElevationGauge.Value    = min(max(antennaPos.Elevation, 0), 90);
            app.PolarizationGauge.Value = mod(antennaPos.Polarization, 360);
        end

        %-----------------------------------------------------------------%
        function setCircularGaugeScale(~, hGauge, values)
            [minValue, maxValue] = bounds(mod(values, 360));

            if maxValue > minValue
                scaleLimits = [0 minValue; minValue maxValue; maxValue 360];
                scaleColors = {[0 1 0] [1 1 0] [0 1 0]};
                isValid     = diff(scaleLimits, 1, 2) > 0;

                set(hGauge, 'ScaleColors', scaleColors(isValid), 'ScaleColorLimits', scaleLimits(isValid, :))
            end
        end

        %-----------------------------------------------------------------%
        function setNewPosition(app, antennaPos, targetPos)
            errorTol = class.Constants.errorPosTolerance;

            if ~isSamePosition(app, targetPos, antennaPos, errorTol)
                msgError = AntennaPositionSET(app.mainApp.EMSatObj, targetPos);

                if ~isempty(msgError)
                    error(msgError)
                end
            end
        end

        %-----------------------------------------------------------------%
        function updatePosition(app)
            STALL_TIME = 10;    % s
            TIMEOUT    = 600;   % s
            errorTol   = class.Constants.errorPosTolerance;

            while isvalid(app) && app.UpdateStatus
                % O reinício é aplicado aqui porque a requisição pode chegar durante o "pause" do laço.
                if app.RestartRequested
                    app.RestartRequested = false;

                    antennaPos  = app.InitialPosition;
                    targetPos   = app.TargetPosition;
                    refPos      = antennaPos;
                    stallWarned = false;
                    trackTic    = tic;
                    totalTic    = tic;

                    setNewPosition(app, antennaPos, targetPos)
                end

                if toc(totalTic) > TIMEOUT
                    error('A antena não atingiu a posição alvo após decorridos %d segundos.', TIMEOUT)
                end

                if toc(trackTic) > STALL_TIME
                    if isSamePosition(app, refPos, antennaPos, errorTol)
                        msgWarning = sprintf('Não alterado o apontamento da antena mesmo após decorridos %d segundos...', STALL_TIME);
                        app.LogEntries(end+1) = struct('type', 'warning', 'time', datestr(now, 'dd/mm/yyyy HH:MM:ss'), 'msg', msgWarning);

                        if ~stallWarned
                            ui.Dialog(app.UIFigure, 'warning', msgWarning);
                            stallWarned = true;
                        end
                    else
                        refPos = antennaPos;
                        stallWarned = false;
                    end
                    trackTic = tic;
                end

                [newAntennaPos, errorMsg] = AntennaPositionGET(app.mainApp.EMSatObj, targetPos.Name);
                if isempty(errorMsg) && isempty(newAntennaPos)
                    errorMsg = 'Resposta do ACU não reconhecida.';
                end
                timestamp = datestr(now, 'dd/mm/yyyy HH:MM:ss');

                if isempty(errorMsg)
                    antennaPos = newAntennaPos;
                    screenUpdate(app, antennaPos)

                    set(app.StatusLabel, 'FontColor', 'black', 'Text', sprintf('%s - Coleta da posição atual do conjunto antena/LNB realizada com sucesso', timestamp))

                    if isSamePosition(app, targetPos, antennaPos, errorTol)
                        if isempty(app.PendingTargets)
                            break
                        end

                        nextTarget = app.PendingTargets(1);
                        app.PendingTargets(1) = [];
                        startNextTarget(app, nextTarget.antennaPos, nextTarget.targetPos)
                    end

                else
                    app.LogEntries(end+1) = struct('type', 'error', 'time', timestamp, 'msg', errorMsg);
                    set(app.StatusLabel, 'FontColor', 'red', 'Text', sprintf('%s - Registro de erro na coleta da posição atual do conjunto antena/LNB', timestamp))
                end

                pause(.5)
            end
        end

        %-----------------------------------------------------------------%
        function status = isSamePosition(~, posA, posB, tolerance)
            status = abs(wrapTo180(posA.Azimuth      - posB.Azimuth))      < tolerance && ...
                     abs(posA.Elevation              - posB.Elevation)     < tolerance && ...
                     abs(wrapTo180(posA.Polarization - posB.Polarization)) < tolerance;
        end

        %-----------------------------------------------------------------%
        function startNextTarget(app, antennaPos, targetPos)
            app.InitialPosition  = antennaPos;
            app.TargetPosition   = targetPos;
            app.RestartRequested = true;

            screenStartup(app, antennaPos, targetPos)
        end

        %-----------------------------------------------------------------%
        function showError(app, ME)
            app.isUpdatable = false;
            ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
        end

        %-----------------------------------------------------------------%
        function startTracking(app)
            delete(app.TrackingTimer)

            app.TrackingActive   = true;
            app.UpdateStatus     = true;
            app.RestartRequested = true;

            try
                updatePosition(app)

            catch ME
                if isvalid(app)
                    app.TrackingActive = false;
                    showError(app, ME)
                end
                return
            end

            if isvalid(app)
                app.TrackingActive = false;
                closeFcn(app)
            end
        end
    end
    

    methods (Access = public)
        %-----------------------------------------------------------------%
        function updateState(app, antennaPos, targetPos)
            if strcmp(targetPos.Name, app.TargetPosition.Name)
                startNextTarget(app, antennaPos, targetPos)
                return
            end

            % Antena distinta da que está sendo apontada: aguarda na fila 
            % para não descartar o apontamento atual.
            pendingNames = arrayfun(@(x) x.targetPos.Name, app.PendingTargets, 'UniformOutput', false);
            idx = find(strcmp(pendingNames, targetPos.Name), 1);
            if isempty(idx)
                idx = numel(app.PendingTargets) + 1;
            end
            app.PendingTargets(idx) = struct('antennaPos', antennaPos, 'targetPos', targetPos);
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, callingApp, context, antennaPos, targetPos)
            
            try
                appEngine.boot(app, app.Role, mainApp, callingApp)

                app.InitialPosition = antennaPos;
                app.TargetPosition  = targetPos;

                screenStartup(app, antennaPos, targetPos)

                % O atraso permite que o popup seja exibido antes do laço bloqueante.
                app.TrackingTimer = timer( ...
                    'ExecutionMode', 'singleShot', ...
                    'StartDelay',    1, ...
                    'TimerFcn',      @(~,~)startTracking(app) ...
                );
                start(app.TrackingTimer)

            catch ME
                showError(app, ME)
            end

        end

        % Close request function: UIFigure
        function closeFcn(app, event)
            
            if app.TrackingActive
                app.UpdateStatus = false;
                return
            end
            app.isUpdatable = false;

            if app.isDocked && ~isempty(app.callingApp) && isvalid(app.callingApp) && isstruct(app.GridLayout.UserData) && isfield(app.GridLayout.UserData, 'id')
                sendEventToHTMLSource(app.callingApp.jsBackDoor, 'closePopupAppRequest', struct('dataTag', app.GridLayout.UserData.id));

                waitTic = tic;
                while isvalid(app) && toc(waitTic) < 1
                    pause(.1)
                end
            end

            if isvalid(app)
                delete(app)
            end
            
        end

        % Button pushed function: LogButton
        function onLogButtonClicked(app, event)
            
            if ~isempty(app.LogEntries)
                logTable = struct2table(app.LogEntries);
                logMsg   = strjoin("<b>" + logTable.time + " - " + upper(logTable.type) + "</b>" + newline + logTable.msg, '\n\n');
            else
                logMsg = 'Não há registro de erro.';
            end

            ui.Dialog(app.UIFigure, 'warning', logMsg);

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
                app.UIFigure.Position = [100 100 622 302];
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
            app.GridLayout.ColumnWidth = {22, 555};
            app.GridLayout.RowHeight = {17, 25, 183, 22};
            app.GridLayout.ColumnSpacing = 5;
            app.GridLayout.RowSpacing = 5;
            app.GridLayout.Padding = [20 20 20 20];
            app.GridLayout.BackgroundColor = [1 1 1];

            % Create AntennaNameLabel
            app.AntennaNameLabel = uilabel(app.GridLayout);
            app.AntennaNameLabel.VerticalAlignment = 'bottom';
            app.AntennaNameLabel.FontSize = 14;
            app.AntennaNameLabel.FontWeight = 'bold';
            app.AntennaNameLabel.Layout.Row = 1;
            app.AntennaNameLabel.Layout.Column = [1 2];
            app.AntennaNameLabel.Text = 'MCL-1';

            % Create PositionGrid
            app.PositionGrid = uigridlayout(app.GridLayout);
            app.PositionGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.PositionGrid.ColumnSpacing = 0;
            app.PositionGrid.RowSpacing = 0;
            app.PositionGrid.Padding = [0 0 0 0];
            app.PositionGrid.Layout.Row = 2;
            app.PositionGrid.Layout.Column = [1 2];
            app.PositionGrid.BackgroundColor = [1 1 1];

            % Create InitialPosLabel
            app.InitialPosLabel = uilabel(app.PositionGrid);
            app.InitialPosLabel.VerticalAlignment = 'bottom';
            app.InitialPosLabel.FontSize = 11;
            app.InitialPosLabel.FontColor = [0.502 0.502 0.502];
            app.InitialPosLabel.Layout.Row = 1;
            app.InitialPosLabel.Layout.Column = 1;
            app.InitialPosLabel.Text = 'Posição inicial:';

            % Create InitialPosValue
            app.InitialPosValue = uilabel(app.PositionGrid);
            app.InitialPosValue.FontSize = 11;
            app.InitialPosValue.FontColor = [0.502 0.502 0.502];
            app.InitialPosValue.Layout.Row = 2;
            app.InitialPosValue.Layout.Column = 1;
            app.InitialPosValue.Text = '(0.000º, 0.000º, 0.000º)';

            % Create CurrentPosLabel
            app.CurrentPosLabel = uilabel(app.PositionGrid);
            app.CurrentPosLabel.HorizontalAlignment = 'center';
            app.CurrentPosLabel.VerticalAlignment = 'bottom';
            app.CurrentPosLabel.FontSize = 11;
            app.CurrentPosLabel.FontColor = [1 0 0];
            app.CurrentPosLabel.Layout.Row = 1;
            app.CurrentPosLabel.Layout.Column = 2;
            app.CurrentPosLabel.Text = 'Posição atual:';

            % Create CurrentPosValue
            app.CurrentPosValue = uilabel(app.PositionGrid);
            app.CurrentPosValue.HorizontalAlignment = 'center';
            app.CurrentPosValue.FontSize = 11;
            app.CurrentPosValue.FontColor = [1 0 0];
            app.CurrentPosValue.Layout.Row = 2;
            app.CurrentPosValue.Layout.Column = 2;
            app.CurrentPosValue.Text = '(0.000º, 0.000º, 0.000º)';

            % Create TargetPosLabel
            app.TargetPosLabel = uilabel(app.PositionGrid);
            app.TargetPosLabel.HorizontalAlignment = 'right';
            app.TargetPosLabel.VerticalAlignment = 'bottom';
            app.TargetPosLabel.FontSize = 11;
            app.TargetPosLabel.FontColor = [0 0.4471 0.7412];
            app.TargetPosLabel.Layout.Row = 1;
            app.TargetPosLabel.Layout.Column = 3;
            app.TargetPosLabel.Text = 'Posição alvo:';

            % Create TargetPosValue
            app.TargetPosValue = uilabel(app.PositionGrid);
            app.TargetPosValue.HorizontalAlignment = 'right';
            app.TargetPosValue.FontSize = 11;
            app.TargetPosValue.FontColor = [0 0.4471 0.7412];
            app.TargetPosValue.Layout.Row = 2;
            app.TargetPosValue.Layout.Column = 3;
            app.TargetPosValue.Text = '(0.000º, 0.000º, 0.000º)';

            % Create GaugePanel
            app.GaugePanel = uipanel(app.GridLayout);
            app.GaugePanel.AutoResizeChildren = 'off';
            app.GaugePanel.BackgroundColor = [1 1 1];
            app.GaugePanel.Layout.Row = 3;
            app.GaugePanel.Layout.Column = [1 2];

            % Create GaugeGrid
            app.GaugeGrid = uigridlayout(app.GaugePanel);
            app.GaugeGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.GaugeGrid.RowHeight = {17, '1x', 17};
            app.GaugeGrid.RowSpacing = 5;
            app.GaugeGrid.BackgroundColor = [1 1 1];

            % Create AzimuthLabel
            app.AzimuthLabel = uilabel(app.GaugeGrid);
            app.AzimuthLabel.HorizontalAlignment = 'center';
            app.AzimuthLabel.FontWeight = 'bold';
            app.AzimuthLabel.Layout.Row = 1;
            app.AzimuthLabel.Layout.Column = 1;
            app.AzimuthLabel.Text = 'AZIMUTE';

            % Create AzimuthGauge
            app.AzimuthGauge = uigauge(app.GaugeGrid, 'circular');
            app.AzimuthGauge.Limits = [0 360];
            app.AzimuthGauge.MajorTicks = [0 45 90 135 180 225 270 315 360];
            app.AzimuthGauge.MajorTickLabels = {'0', '45', '90', '135', '180', '225', '270', '315', '360'};
            app.AzimuthGauge.FontSize = 10;
            app.AzimuthGauge.Layout.Row = 2;
            app.AzimuthGauge.Layout.Column = 1;

            % Create AzimuthValue
            app.AzimuthValue = uilabel(app.GaugeGrid);
            app.AzimuthValue.HorizontalAlignment = 'center';
            app.AzimuthValue.FontSize = 11;
            app.AzimuthValue.FontColor = [1 0 0];
            app.AzimuthValue.Layout.Row = 3;
            app.AzimuthValue.Layout.Column = 1;
            app.AzimuthValue.Text = '0.000º';

            % Create ElevationLabel
            app.ElevationLabel = uilabel(app.GaugeGrid);
            app.ElevationLabel.HorizontalAlignment = 'center';
            app.ElevationLabel.FontWeight = 'bold';
            app.ElevationLabel.Layout.Row = 1;
            app.ElevationLabel.Layout.Column = 2;
            app.ElevationLabel.Text = 'ELEVAÇÃO';

            % Create ElevationGrid
            app.ElevationGrid = uigridlayout(app.GaugeGrid);
            app.ElevationGrid.ColumnWidth = {'1x'};
            app.ElevationGrid.RowHeight = {'1x'};
            app.ElevationGrid.Padding = [20 10 20 10];
            app.ElevationGrid.Layout.Row = 2;
            app.ElevationGrid.Layout.Column = 2;
            app.ElevationGrid.BackgroundColor = [1 1 1];

            % Create ElevationGauge
            app.ElevationGauge = uigauge(app.ElevationGrid, 'ninetydegree');
            app.ElevationGauge.Limits = [0 90];
            app.ElevationGauge.MajorTicks = [0 22.5 45 67.5 90];
            app.ElevationGauge.MajorTickLabels = {'0', '22.5', '45', '67.5', '90'};
            app.ElevationGauge.MinorTicks = [0 3 6 9 12 15 18 27 30 33 36 39 42 45 48 51 54 57 60 63 72 75 78 81 84 87 90];
            app.ElevationGauge.FontSize = 10;
            app.ElevationGauge.Layout.Row = 1;
            app.ElevationGauge.Layout.Column = 1;

            % Create ElevationValue
            app.ElevationValue = uilabel(app.GaugeGrid);
            app.ElevationValue.HorizontalAlignment = 'center';
            app.ElevationValue.FontSize = 11;
            app.ElevationValue.FontColor = [1 0 0];
            app.ElevationValue.Layout.Row = 3;
            app.ElevationValue.Layout.Column = 2;
            app.ElevationValue.Text = '0.000º';

            % Create PolarizationLabel
            app.PolarizationLabel = uilabel(app.GaugeGrid);
            app.PolarizationLabel.HorizontalAlignment = 'center';
            app.PolarizationLabel.FontWeight = 'bold';
            app.PolarizationLabel.Layout.Row = 1;
            app.PolarizationLabel.Layout.Column = 3;
            app.PolarizationLabel.Text = 'POLARIZAÇÃO';

            % Create PolarizationGauge
            app.PolarizationGauge = uigauge(app.GaugeGrid, 'circular');
            app.PolarizationGauge.Limits = [0 360];
            app.PolarizationGauge.MajorTicks = [0 45 90 135 180 225 270 315 360];
            app.PolarizationGauge.MajorTickLabels = {'0', '45', '90', '135', '180', '225', '270', '315', '360'};
            app.PolarizationGauge.FontSize = 10;
            app.PolarizationGauge.Layout.Row = 2;
            app.PolarizationGauge.Layout.Column = 3;

            % Create PolarizationValue
            app.PolarizationValue = uilabel(app.GaugeGrid);
            app.PolarizationValue.HorizontalAlignment = 'center';
            app.PolarizationValue.FontSize = 11;
            app.PolarizationValue.FontColor = [1 0 0];
            app.PolarizationValue.Layout.Row = 3;
            app.PolarizationValue.Layout.Column = 3;
            app.PolarizationValue.Text = '0.000º';

            % Create LogButton
            app.LogButton = uibutton(app.GridLayout, 'push');
            app.LogButton.ButtonPushedFcn = createCallbackFcn(app, @onLogButtonClicked, true);
            app.LogButton.Icon = 'LOG_32.png';
            app.LogButton.BackgroundColor = [0.9804 0.9804 0.9804];
            app.LogButton.Layout.Row = 4;
            app.LogButton.Layout.Column = 1;
            app.LogButton.Text = '';

            % Create StatusLabel
            app.StatusLabel = uilabel(app.GridLayout);
            app.StatusLabel.FontSize = 11;
            app.StatusLabel.Layout.Row = 4;
            app.StatusLabel.Layout.Column = 2;
            app.StatusLabel.Text = '';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = dockTracking_exported(Container, varargin)

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
