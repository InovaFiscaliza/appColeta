function targetPos = antennaTracking(app, antennaMetaData, progressDialog)

    errorTol  = class.Constants.errorPosTolerance;
    errorFlag = false;
    
    for ii = 1:numel(antennaMetaData)
        targetPos   = fcn.antennaParser(antennaMetaData(ii), antennaMetaData(ii).Name);
        antennaName = targetPos.Name;
    
        switch targetPos.TrackingMode
            case {'Target', 'LookAngles'}
                if isfield(targetPos, 'Target')
                    [tempTargetPos,  errorMsg] = app.EMSatObj.TargetPositionGET(antennaName, targetPos.Target);
                    if ~isempty(errorMsg)
                        error(errorMsg)
                    end
    
                    targetPos.Azimuth      = tempTargetPos.Azimuth;
                    targetPos.Elevation    = tempTargetPos.Elevation;
                    targetPos.Polarization = tempTargetPos.Polarization;
                end
    
                [antennaPos, errorMsg] = app.EMSatObj.AntennaPositionGET(antennaName);
                if ~isempty(errorMsg)
                    error(errorMsg)
                end
    
                if abs(targetPos.Azimuth      - antennaPos.Azimuth)      >= errorTol || ...
                        abs(targetPos.Elevation    - antennaPos.Elevation)    >= errorTol || ...
                        abs(targetPos.Polarization - antennaPos.Polarization) >= errorTol
                    errorFlag = true;
                    msg = sprintf('O conjunto antena/LNB "%s" parece não estar apontado para a posição correta.', antennaName);
                else
                    msg = sprintf('O conjunto antena/LNB "%s" parece já estar apontado para a posição correta.',  antennaName);
                end
    
                if errorFlag
                    switch class(app)
                        case {'auxApp.winAddTask', 'auxApp.winAddTask_exported'}
                            msg = sprintf(['<font style="font-size:11;">%s\n\nPosição atual:'            ...
                                '\n• <span style="color: #808080;">Azimute</span>: %.3fº'     ...
                                '\n• <span style="color: #808080;">Elevação</span>: %.3fº'    ...
                                '\n• <span style="color: #808080;">Polarização</span>: %.3fº' ...
                                '\n\nPosição configurada:'                                    ...
                                '\n• <span style="color: #808080;">Azimute</span>: %.3fº'     ...
                                '\n• <span style="color: #808080;">Elevação</span>: %.3fº'    ...
                                '\n• <span style="color: #808080;">Polarização</span>: %.3fº' ...
                                '\n\nDeseja realizar o apontamento automático do conjunto antena/LNB agora?</font>'], ...
                                msg, antennaPos.Azimuth, antennaPos.Elevation, antennaPos.Polarization,    ...
                                targetPos.Azimuth, targetPos.Elevation, targetPos.Polarization);
    
                            progressDialog.Visible = 'hidden';
                            selection = uiconfirm(app.UIFigure, msg, '', 'Interpreter', 'html', 'Options', {'Sim', 'Não'}, 'DefaultOption', 1, 'CancelOption', 1, 'Icon', 'question');
                            if selection == "Não"
                                continue
                            end
    
                            refApp = app.CallingApp;
    
                        otherwise % winAppColeta | winAppColeta_exported
                            refApp = app;
                    end
    
                    appOpenPopUpSecundaryApp(refApp, 'Tracking', antennaPos, targetPos)
                end
    
            case 'Manual'
                switch class(app)
                    case {'auxApp.winAddTask', 'auxApp.winAddTask_exported'}
                        msg = sprintf(['<font style="font-size:11;">O apontamento do conjunto antena/LNB "%s" deverá ser realizado manualmente.'                                    ...
                            '\n\nDeseja reconfigurar esse apontamento para automático ("Target" ou "LookAngles")?</font>'], ...
                            antennaName);
    
                        progressDialog.Visible = 'hidden';
                        selection = uiconfirm(app.UIFigure, msg, '', 'Interpreter', 'html', 'Options', {'Sim', 'Não'}, 'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'question');
                        if selection == "Sim"
                            error('Operação cancelada para reconfiguração do tipo de apontamento do conjunto antena/LNB "%s".', antennaName)
                        end
    
                    otherwise
                        % ...
                end
        end
    end
end