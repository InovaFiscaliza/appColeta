classdef (Abstract) AntennaTracking

    % Essa classe abstrata reúne a interpretação dos metadados das antenas
    % de uma tarefa e a verificação do seu apontamento (EMSat).

    methods (Static = true)
        %-----------------------------------------------------------------%
        function antennaTarget = parseAntennaTarget(antennaMetaData, antennaName)
            % Retorna os metadados da antena "antennaName", sem os campos "NA"
            % e com azimute, elevação e polarização em formato numérico.

            antennaIdx    = find(strcmp({antennaMetaData.Name}, antennaName), 1);
            antennaTarget = antennaMetaData(antennaIdx);

            for fieldName = fieldnames(antennaMetaData)'
                if antennaTarget.(fieldName{1}) == "NA"
                    antennaTarget = rmfield(antennaTarget, fieldName{1});

                elseif ismember(fieldName{1}, {'Azimuth', 'Elevation', 'Polarization'})
                    antennaTarget.(fieldName{1}) = str2double(extractBefore(antennaTarget.(fieldName{1}), 'º'));
                end
            end
        end

        %-----------------------------------------------------------------%
        function verifyPointing(callingApp, context, antennaMetaData, progressDialog)
            arguments
                callingApp
                context {mustBeMember(context, {'mainApp', 'TASK_ADD'})}
                antennaMetaData
                progressDialog
            end

            toleranceDeg = class.Constants.errorPosTolerance;
            isMispointed = false;

            for ii = 1:numel(antennaMetaData)
                antennaTarget = util.AntennaTracking.parseAntennaTarget(antennaMetaData(ii), antennaMetaData(ii).Name);
                antennaName   = antennaTarget.Name;

                switch antennaTarget.TrackingMode
                    case {'Target', 'LookAngles'}
                        if isfield(antennaTarget, 'Target')
                            [resolvedTarget, errorMsg] = TargetPositionGET(callingApp.EMSatObj, antennaName, antennaTarget.Target);
                            if ~isempty(errorMsg)
                                error(errorMsg)
                            end

                            antennaTarget.Azimuth      = resolvedTarget.Azimuth;
                            antennaTarget.Elevation    = resolvedTarget.Elevation;
                            antennaTarget.Polarization = resolvedTarget.Polarization;
                        end

                        [currentPosition, errorMsg] = AntennaPositionGET(callingApp.EMSatObj, antennaName);
                        if ~isempty(errorMsg)
                            error(errorMsg)
                        end

                        if abs(antennaTarget.Azimuth      - currentPosition.Azimuth)      >= toleranceDeg || ...
                           abs(antennaTarget.Elevation    - currentPosition.Elevation)    >= toleranceDeg || ...
                           abs(antennaTarget.Polarization - currentPosition.Polarization) >= toleranceDeg
                            isMispointed = true;
                            message = sprintf([ ...
                                'O conjunto antena/LNB "%s" parece não estar ' ...
                                'apontado para a posição correta.' ...
                            ], antennaName);

                        else
                            message = sprintf([ ...
                                'O conjunto antena/LNB "%s" parece já estar ' ...
                                'apontado para a posição correta.' ...
                            ], antennaName);
                        end

                        if isMispointed
                            if strcmp(context, 'TASK_ADD')
                                message = sprintf([ ...
                                    '<font style="font-size:11;">%s\n\nPosição atual:'            ...
                                    '\n• <span style="color: #808080;">Azimute</span>: %.3fº'     ...
                                    '\n• <span style="color: #808080;">Elevação</span>: %.3fº'    ...
                                    '\n• <span style="color: #808080;">Polarização</span>: %.3fº' ...
                                    '\n\nPosição configurada:'                                    ...
                                    '\n• <span style="color: #808080;">Azimute</span>: %.3fº'     ...
                                    '\n• <span style="color: #808080;">Elevação</span>: %.3fº'    ...
                                    '\n• <span style="color: #808080;">Polarização</span>: %.3fº' ...
                                    '\n\nDeseja realizar o apontamento automático do conjunto antena/LNB agora?</font>' ...
                                ], message, currentPosition.Azimuth, currentPosition.Elevation, currentPosition.Polarization, antennaTarget.Azimuth, antennaTarget.Elevation, antennaTarget.Polarization);

                                progressDialog.Visible = 'hidden';
                                selection = uiconfirm(callingApp.UIFigure, message, '', 'Interpreter', 'html', 'Options', {'Sim', 'Não'}, 'DefaultOption', 1, 'CancelOption', 1, 'Icon', 'question');
                                if selection == "Não"
                                    continue
                                end
                            end

                            if isprop(callingApp, 'mainApp')
                                mainApp = callingApp.mainApp;
                            else
                                mainApp = callingApp;
                            end

                            ipcMainMatlabOpenPopupApp(mainApp, callingApp, 'Tracking', currentPosition, antennaTarget)
                        end

                    case 'Manual'
                        if strcmp(context, 'TASK_ADD')
                            message = sprintf([ ...
                                '<font style="font-size:11;">O apontamento do conjunto ' ...
                                'antena/LNB "%s" deverá ser realizado manualmente.\n\n' ...
                                'Deseja reconfigurar esse apontamento para automático ' ...
                                '("Target" ou "LookAngles")?</font>' ...
                            ], antennaName);

                            progressDialog.Visible = 'hidden';
                            selection = uiconfirm(callingApp.UIFigure, message, '', 'Interpreter', 'html', 'Options', {'Sim', 'Não'}, 'DefaultOption', 2, 'CancelOption', 2, 'Icon', 'question');
                            if selection == "Sim"
                                error('Operação cancelada para reconfiguração do tipo de apontamento do conjunto antena/LNB "%s".', antennaName)
                            end
                        end
                end
            end
        end
    end
end
