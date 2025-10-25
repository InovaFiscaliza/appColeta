function GeneralSettings(appGeneral, rootFolder)

    appGeneral = rmfield(appGeneral, 'version');
    
    appGeneral.stationInfo.Computer = '';
    if ismember(appGeneral.fileFolder.userPath, class.Constants.userPaths)
        appGeneral.fileFolder.userPath = '';
    end

    try
        fileID = fopen(fullfile(rootFolder, 'Settings', 'GeneralSettings.json'), 'wt');
        fwrite(fileID, jsonencode(appGeneral, 'PrettyPrint', true));
        fclose(fileID);
    catch
    end
end