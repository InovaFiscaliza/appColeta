function [instrHandle, msgError] = ConnectivityTest_Receiver(app, instrSelected, MessageBoxFlag)

    % Essa função é chamada dos apps auxiliares "winAddTask" e "winEditInstrumentList.
    % - auxApp.winAddTask
    %   instrSelected é formada pelos valores constantes no objeto app.receiverObj (na sua propriedade "List").
    %
    % - auxApp.winEditInstrumentList
    %   instrSelected é formada pelos valores constantes na variável app.instrumentList.

    [idx, msgError] = app.receiverObj.Connect(instrSelected);

    if isempty(msgError)
        instrHandle = app.receiverObj.Table.Handle{idx};
        if MessageBoxFlag
            appUtil.modalWindow(app.UIFigure, 'warning', sprintf('Conectado ao %s', instrHandle.UserData.IDN));
        end

    else
        instrHandle = [];
        if MessageBoxFlag
            appUtil.modalWindow(app.UIFigure, 'error', msgError);
        end
    end
end