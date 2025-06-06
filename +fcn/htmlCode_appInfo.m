function appInfo = htmlCode_appInfo(appGeneral, rootFolder, executionMode)

    appName       = class.Constants.appName;
    appVersion    = appGeneral.AppVersion;
    [~, appColetaLink] = fcn.PublicLinks(rootFolder);

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

    appInfo = sprintf(['<p style="font-size: 12px; text-align:justify;">O repositório das '   ...
                       'ferramentas desenvolvidas no Escritório de inovação da SFI pode ser ' ...
                       'acessado <a href="%s">aqui</a>.\n\n</p>%s'], appColetaLink.Sharepoint, textFormatGUI.struct2PrettyPrintList(dataStruct));   
end