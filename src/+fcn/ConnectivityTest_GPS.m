function [instrHandle, gpsData, msgError] = ConnectivityTest_GPS(app, instrSelected, MessageBoxFlag)

    % Essa função é chamada dos apps auxiliares "winAddTask" e "winEditInstrumentList.
    % - auxApp.winAddTask
    %   instrSelected é formada pelos valores constantes no objeto app.gpsObj (na sua propriedade "List").
    %
    % - auxApp.winEditInstrumentList
    %   instrSelected é formada pelos valores constantes na variável app.instrumentList.

    [idx, msgError] = app.gpsObj.Connect(instrSelected);

    if isempty(msgError)
        instrHandle = app.gpsObj.Table.Handle{idx};

        if MessageBoxFlag
            gpsData = fcn.gpsExternalReader(instrHandle, 1);

            if gpsData.Status
                [City, Distance] = fcn.geoFindCity(gpsData);
    
                if isempty(gpsData.TimeStamp)
                    gpsData.TimeStamp = 'NA';
                end
    
                msg = sprintf(['Status: %.0f\n'    ...
                               'Latitude: %.6f\n'  ...
                               'Longitude: %.6f\n' ...
                               'Timestamp: %s\n\n' ...
                               'Nota:\nCoordenadas geográficas distam <b>%.1f km</b> da sede do município <b>%s</b>.'], ...
                               gpsData.Status, gpsData.Latitude, gpsData.Longitude, gpsData.TimeStamp, Distance, City);
            else
                msg = sprintf('<b>Não recebida informação válida do instrumento acerca das coordenadas geográficas do local de monitoração.</b>\n%s', jsonencode(gpsData));
            end
    
            if MessageBoxFlag
                appUtil.modalWindow(app.UIFigure, 'warning', msg);
            end
        end

    else
        instrHandle = [];
        if MessageBoxFlag
            appUtil.modalWindow(app.UIFigure, 'error', msgError);
        end
    end

    if ~exist('gpsData', 'var')
        gpsData = [];
    end
end