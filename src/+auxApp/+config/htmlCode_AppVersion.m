function htmlContent = htmlCode_AppVersion(appGeneral, executionMode)

    appName    = class.Constants.appName;
    appVersion = appGeneral.AppVersion;

    switch executionMode
        case {'MATLABEnvironment', 'desktopStandaloneApp'}                  % MATLAB | MATLAB RUNTIME
            appMode = 'desktopApp';

        case 'webApp'                                                       % MATLAB WEBSERVER + RUNTIME
            computerName = ccTools.fcn.OperationSystem('computerName');
            if strcmpi(computerName, appGeneral.computerName.webServer)
                appMode = 'webServer';
            else
                appMode = 'deployServer';                    
            end
    end

    dataStruct    = struct('group', 'COMPUTADOR',   'value', struct('Machine', appVersion.Machine, 'Mode', sprintf('%s - %s', executionMode, appMode)));
    dataStruct(2) = struct('group', appName,        'value', appVersion.(appName));
    dataStruct(3) = struct('group', 'MATLAB',       'value', appVersion.Matlab);

    htmlContent   = textFormatGUI.struct2PrettyPrintList(dataStruct);
end