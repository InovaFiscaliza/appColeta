classdef dockTracking_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure           matlab.ui.Figure
        GridLayout         matlab.ui.container.GridLayout
        btnClose           matlab.ui.control.Image
        DocumentGrid       matlab.ui.container.GridLayout
        ErrorLabel         matlab.ui.control.Label
        LOGButton          matlab.ui.control.Button
        Panel              matlab.ui.container.Panel
        GridLayout2        matlab.ui.container.GridLayout
        Polarization       matlab.ui.control.Label
        PolarizationGauge  matlab.ui.control.Gauge
        PolarizationLabel  matlab.ui.control.Label
        Elevation          matlab.ui.control.Label
        ElevationGrid      matlab.ui.container.GridLayout
        ElevationGauge     matlab.ui.control.NinetyDegreeGauge
        ElevationLabel     matlab.ui.control.Label
        Azimuth            matlab.ui.control.Label
        AzimuthGauge       matlab.ui.control.Gauge
        AzimuthLabel       matlab.ui.control.Label
        PositionGrid       matlab.ui.container.GridLayout
        finalPosValue      matlab.ui.control.Label
        finalPosLabel      matlab.ui.control.Label
        actualPosValue     matlab.ui.control.Label
        actualPosLabel     matlab.ui.control.Label
        initialPosValue    matlab.ui.control.Label
        initialPosLabel    matlab.ui.control.Label
        antennaNameLabel   matlab.ui.control.Label
    end

    
    properties (Access = private)
        %-----------------------------------------------------------------%
        Role = 'secondaryDockApp'
    end


    properties (Access = public)
        %-----------------------------------------------------------------%
        Container
        isDocked = true        
        mainApp
        callingApp
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        EMSatObj
        antennaName
        LOG = struct('type', {}, 'time', {}, 'msg',  {})
        UpdateStatus = true
    end
    

    methods (Access = private)
        %-----------------------------------------------------------------%
        function screenStartup(app, antennaPos, targetPos)
            app.antennaNameLabel.Text = targetPos.Name;
            app.initialPosValue.Text  = sprintf('(%.3fº, %.3fº, %.3fº)', antennaPos.Azimuth, antennaPos.Elevation, antennaPos.Polarization);
            app.finalPosValue.Text    = sprintf('(%.3fº, %.3fº, %.3fº)', targetPos.Azimuth,  targetPos.Elevation,  targetPos.Polarization);
            screenUpdate(app, antennaPos)

            app.AzimuthGauge.Value = antennaPos.Azimuth;
            if targetPos.Azimuth ~= antennaPos.Azimuth
                [minAz, maxAz] = bounds([antennaPos.Azimuth, targetPos.Azimuth]);
                set(app.AzimuthGauge, 'ScaleColors', {[0 1 0] [1 1 0] [0 1 0]}, ...
                                      'ScaleColorLimits', [0 minAz; minAz maxAz; maxAz 360])
            end

            app.ElevationGauge.Value = antennaPos.Elevation;
            if targetPos.Elevation ~= antennaPos.Elevation
                set(app.ElevationGauge, 'ScaleColors', [1 1 0], ...
                                        'ScaleColorLimits', sort([antennaPos.Elevation, targetPos.Elevation]))
            end

            app.PolarizationGauge.Value = antennaPos.Polarization;
            if targetPos.Polarization ~= antennaPos.Polarization
                [minPol, maxPol] = bounds([antennaPos.Polarization, targetPos.Polarization]);
                set(app.PolarizationGauge, 'ScaleColors', {[0 1 0] [1 1 0] [0 1 0]}, ...
                                           'ScaleColorLimits', [0 minPol; minPol maxPol; maxPol 360])
            end

            drawnow
        end

        %-----------------------------------------------------------------%
        function screenUpdate(app, antennaPos)
            app.actualPosValue.Text  = sprintf('(%.3fº, %.3fº, %.3fº)', antennaPos.Azimuth, antennaPos.Elevation, antennaPos.Polarization);

            app.Azimuth.Text      = sprintf('%.3fº', antennaPos.Azimuth);
            app.Elevation.Text    = sprintf('%.3fº', antennaPos.Elevation);
            app.Polarization.Text = sprintf('%.3fº', antennaPos.Polarization);
        end

        %-----------------------------------------------------------------%
        function setNewPosition(app, antennaPos, targetPos)
            errorTol = class.Constants.errorPosTolerance;

            if abs(targetPos.Azimuth      - antennaPos.Azimuth)      >= errorTol || ...
               abs(targetPos.Elevation    - antennaPos.Elevation)    >= errorTol || ...
               abs(targetPos.Polarization - antennaPos.Polarization) >= errorTol
                msgError = app.EMSatObj.AntennaPositionSET(targetPos);

                if ~isempty(msgError)
                    error(msgError)
                    closeFcn(app)
                end
            end
        end

        %-----------------------------------------------------------------%
        function updatePosition(app, antennaPos, targetPos)
            errorTol = class.Constants.errorPosTolerance;

            % Posição de referência
            refPos   = struct('Azimuth', [], 'Elevation', [], 'Polarization', []);
            refPos   = updateReference(app, refPos, antennaPos);

            trackTic = tic;
            while app.UpdateStatus
                if toc(trackTic) > 10
                    if isequal(refPos, antennaPos)
                        ui.Dialog(app.UIFigure, 'warning', 'Não alterado o apontamento da antena mesmo após decorridos 10 segundos...');
                    else
                        refPos = updateReference(app, refPos, antennaPos);
                    end
                    trackTic = tic;
                end

                [newAntennaPos, errorMsg] = app.EMSatObj.AntennaPositionGET(targetPos.Name);
                Timestamp = datestr(now, 'dd/mm/yyyy HH:MM:ss');

                if isempty(errorMsg)
                    antennaPos = newAntennaPos;
    
                    app.AzimuthGauge.Value      = antennaPos.Azimuth;
                    app.ElevationGauge.Value    = antennaPos.Elevation;
                    app.PolarizationGauge.Value = antennaPos.Polarization;
                    screenUpdate(app, antennaPos)
    
                    set(app.ErrorLabel, FontColor = 'black', ...
                                        Text = sprintf('%s - Coleta da posição atual do conjunto antena/LNB realizada com sucesso', Timestamp))
    
                    if abs(targetPos.Azimuth      - antennaPos.Azimuth)      < errorTol && ...
                       abs(targetPos.Elevation    - antennaPos.Elevation)    < errorTol && ...
                       abs(targetPos.Polarization - antennaPos.Polarization) < errorTol
                        break
                    end

                else
                    app.LOG(end+1) = struct('type', 'error', 'time', Timestamp, 'msg', errorMsg);
                    set(app.ErrorLabel, FontColor = 'red', ...
                                        Text = sprintf('%s - Registro de erro na coleta da posição atual do conjunto antena/LNB', Timestamp))
                end
                drawnow
            end

            closeFcn(app)
        end

        %-----------------------------------------------------------------%
        function refAntennaPos = updateReference(app, refAntennaPos, antennaPos)
            refAntennaPos.Azimuth      = antennaPos.Azimuth;
            refAntennaPos.Elevation    = antennaPos.Elevation;
            refAntennaPos.Polarization = antennaPos.Polarization;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app, mainApp, antennaPos, targetPos)
            
            try
                appEngine.boot(app, app.Role, mainApp, [])

                app.EMSatObj = mainApp.EMSatObj;
                screenStartup(app,  antennaPos, targetPos)
                setNewPosition(app, antennaPos, targetPos)
                updatePosition(app, antennaPos, targetPos)
                
            catch ME
                ui.Dialog(app.UIFigure, 'error', getReport(ME), 'CloseFcn', @(~,~)closeFcn(app));
            end

        end

        % Callback function: UIFigure, btnClose
        function closeFcn(app, event)
            
            ipcMainMatlabCallsHandler(app.mainApp, app, 'closeFcnCallFromPopupApp')
            delete(app)
            
        end

        % Button pushed function: LOGButton
        function LOGButtonPushed(app, event)
            
            if ~isempty(app.LOG)
                logTable = struct2table(app.LOG);
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
            app.GridLayout.ColumnWidth = {'1x', 30};
            app.GridLayout.RowHeight = {30, '1x'};
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.BackgroundColor = [0.902 0.902 0.902];

            % Create DocumentGrid
            app.DocumentGrid = uigridlayout(app.GridLayout);
            app.DocumentGrid.ColumnWidth = {22, 272, '1x'};
            app.DocumentGrid.RowHeight = {17, 25, '1x', 22};
            app.DocumentGrid.ColumnSpacing = 5;
            app.DocumentGrid.RowSpacing = 5;
            app.DocumentGrid.Layout.Row = 2;
            app.DocumentGrid.Layout.Column = [1 2];
            app.DocumentGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create antennaNameLabel
            app.antennaNameLabel = uilabel(app.DocumentGrid);
            app.antennaNameLabel.VerticalAlignment = 'bottom';
            app.antennaNameLabel.FontSize = 14;
            app.antennaNameLabel.FontWeight = 'bold';
            app.antennaNameLabel.Layout.Row = 1;
            app.antennaNameLabel.Layout.Column = [1 2];
            app.antennaNameLabel.Text = 'MCL-1';

            % Create PositionGrid
            app.PositionGrid = uigridlayout(app.DocumentGrid);
            app.PositionGrid.ColumnWidth = {'1x', '1x', '1x'};
            app.PositionGrid.ColumnSpacing = 0;
            app.PositionGrid.RowSpacing = 0;
            app.PositionGrid.Padding = [0 0 0 0];
            app.PositionGrid.Layout.Row = 2;
            app.PositionGrid.Layout.Column = [1 3];
            app.PositionGrid.BackgroundColor = [0.9804 0.9804 0.9804];

            % Create initialPosLabel
            app.initialPosLabel = uilabel(app.PositionGrid);
            app.initialPosLabel.VerticalAlignment = 'bottom';
            app.initialPosLabel.FontSize = 11;
            app.initialPosLabel.FontColor = [0.502 0.502 0.502];
            app.initialPosLabel.Layout.Row = 1;
            app.initialPosLabel.Layout.Column = 1;
            app.initialPosLabel.Text = 'Posição inicial:';

            % Create initialPosValue
            app.initialPosValue = uilabel(app.PositionGrid);
            app.initialPosValue.FontSize = 11;
            app.initialPosValue.FontColor = [0.502 0.502 0.502];
            app.initialPosValue.Layout.Row = 2;
            app.initialPosValue.Layout.Column = 1;
            app.initialPosValue.Text = '(0.000º, 0.000º, 0.000º)';

            % Create actualPosLabel
            app.actualPosLabel = uilabel(app.PositionGrid);
            app.actualPosLabel.HorizontalAlignment = 'center';
            app.actualPosLabel.VerticalAlignment = 'bottom';
            app.actualPosLabel.FontSize = 11;
            app.actualPosLabel.FontColor = [1 0 0];
            app.actualPosLabel.Layout.Row = 1;
            app.actualPosLabel.Layout.Column = 2;
            app.actualPosLabel.Text = 'Posição atual:';

            % Create actualPosValue
            app.actualPosValue = uilabel(app.PositionGrid);
            app.actualPosValue.HorizontalAlignment = 'center';
            app.actualPosValue.FontSize = 11;
            app.actualPosValue.FontColor = [1 0 0];
            app.actualPosValue.Layout.Row = 2;
            app.actualPosValue.Layout.Column = 2;
            app.actualPosValue.Text = '(0.000º, 0.000º, 0.000º)';

            % Create finalPosLabel
            app.finalPosLabel = uilabel(app.PositionGrid);
            app.finalPosLabel.HorizontalAlignment = 'right';
            app.finalPosLabel.VerticalAlignment = 'bottom';
            app.finalPosLabel.FontSize = 11;
            app.finalPosLabel.FontColor = [0 0.4471 0.7412];
            app.finalPosLabel.Layout.Row = 1;
            app.finalPosLabel.Layout.Column = 3;
            app.finalPosLabel.Text = 'Posição alvo:';

            % Create finalPosValue
            app.finalPosValue = uilabel(app.PositionGrid);
            app.finalPosValue.HorizontalAlignment = 'right';
            app.finalPosValue.FontSize = 11;
            app.finalPosValue.FontColor = [0 0.4471 0.7412];
            app.finalPosValue.Layout.Row = 2;
            app.finalPosValue.Layout.Column = 3;
            app.finalPosValue.Text = '(0.000º, 0.000º, 0.000º)';

            % Create Panel
            app.Panel = uipanel(app.DocumentGrid);
            app.Panel.AutoResizeChildren = 'off';
            app.Panel.BackgroundColor = [1 1 1];
            app.Panel.Layout.Row = 3;
            app.Panel.Layout.Column = [1 3];

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.Panel);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {17, '1x', 17};
            app.GridLayout2.RowSpacing = 5;
            app.GridLayout2.BackgroundColor = [1 1 1];

            % Create AzimuthLabel
            app.AzimuthLabel = uilabel(app.GridLayout2);
            app.AzimuthLabel.HorizontalAlignment = 'center';
            app.AzimuthLabel.FontWeight = 'bold';
            app.AzimuthLabel.Layout.Row = 1;
            app.AzimuthLabel.Layout.Column = 1;
            app.AzimuthLabel.Text = 'AZIMUTE';

            % Create AzimuthGauge
            app.AzimuthGauge = uigauge(app.GridLayout2, 'circular');
            app.AzimuthGauge.Limits = [0 360];
            app.AzimuthGauge.MajorTicks = [0 45 90 135 180 225 270 315 360];
            app.AzimuthGauge.MajorTickLabels = {'0', '45', '90', '135', '180', '225', '270', '315', '360'};
            app.AzimuthGauge.FontSize = 10;
            app.AzimuthGauge.Layout.Row = 2;
            app.AzimuthGauge.Layout.Column = 1;

            % Create Azimuth
            app.Azimuth = uilabel(app.GridLayout2);
            app.Azimuth.HorizontalAlignment = 'center';
            app.Azimuth.FontSize = 11;
            app.Azimuth.FontColor = [1 0 0];
            app.Azimuth.Layout.Row = 3;
            app.Azimuth.Layout.Column = 1;
            app.Azimuth.Text = '0.000º';

            % Create ElevationLabel
            app.ElevationLabel = uilabel(app.GridLayout2);
            app.ElevationLabel.HorizontalAlignment = 'center';
            app.ElevationLabel.FontWeight = 'bold';
            app.ElevationLabel.Layout.Row = 1;
            app.ElevationLabel.Layout.Column = 2;
            app.ElevationLabel.Text = 'ELEVAÇÃO';

            % Create ElevationGrid
            app.ElevationGrid = uigridlayout(app.GridLayout2);
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

            % Create Elevation
            app.Elevation = uilabel(app.GridLayout2);
            app.Elevation.HorizontalAlignment = 'center';
            app.Elevation.FontSize = 11;
            app.Elevation.FontColor = [1 0 0];
            app.Elevation.Layout.Row = 3;
            app.Elevation.Layout.Column = 2;
            app.Elevation.Text = '0.000º';

            % Create PolarizationLabel
            app.PolarizationLabel = uilabel(app.GridLayout2);
            app.PolarizationLabel.HorizontalAlignment = 'center';
            app.PolarizationLabel.FontWeight = 'bold';
            app.PolarizationLabel.Layout.Row = 1;
            app.PolarizationLabel.Layout.Column = 3;
            app.PolarizationLabel.Text = 'POLARIZAÇÃO';

            % Create PolarizationGauge
            app.PolarizationGauge = uigauge(app.GridLayout2, 'circular');
            app.PolarizationGauge.Limits = [0 360];
            app.PolarizationGauge.MajorTicks = [0 45 90 135 180 225 270 315 360];
            app.PolarizationGauge.MajorTickLabels = {'0', '45', '90', '135', '180', '225', '270', '315', '360'};
            app.PolarizationGauge.FontSize = 10;
            app.PolarizationGauge.Layout.Row = 2;
            app.PolarizationGauge.Layout.Column = 3;

            % Create Polarization
            app.Polarization = uilabel(app.GridLayout2);
            app.Polarization.HorizontalAlignment = 'center';
            app.Polarization.FontSize = 11;
            app.Polarization.FontColor = [1 0 0];
            app.Polarization.Layout.Row = 3;
            app.Polarization.Layout.Column = 3;
            app.Polarization.Text = '0.000º';

            % Create LOGButton
            app.LOGButton = uibutton(app.DocumentGrid, 'push');
            app.LOGButton.ButtonPushedFcn = createCallbackFcn(app, @LOGButtonPushed, true);
            app.LOGButton.Icon = 'LOG_32.png';
            app.LOGButton.BackgroundColor = [1 1 1];
            app.LOGButton.Tooltip = {'Apresenta LOG do processo de apontamento da antena'};
            app.LOGButton.Layout.Row = 4;
            app.LOGButton.Layout.Column = 1;
            app.LOGButton.Text = '';

            % Create ErrorLabel
            app.ErrorLabel = uilabel(app.DocumentGrid);
            app.ErrorLabel.FontSize = 11;
            app.ErrorLabel.Layout.Row = 4;
            app.ErrorLabel.Layout.Column = [2 3];
            app.ErrorLabel.Text = '';

            % Create btnClose
            app.btnClose = uiimage(app.GridLayout);
            app.btnClose.ScaleMethod = 'none';
            app.btnClose.ImageClickedFcn = createCallbackFcn(app, @closeFcn, true);
            app.btnClose.Tag = 'Close';
            app.btnClose.Layout.Row = 1;
            app.btnClose.Layout.Column = 2;
            app.btnClose.ImageSource = 'Delete_12SVG.svg';

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
