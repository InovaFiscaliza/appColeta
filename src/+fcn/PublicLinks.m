function [version, appColeta, RFDataHub] = PublicLinks(rootFolder)

    [projectFolder, ...
     programDataFolder] = appUtil.Path(class.Constants.appName, rootFolder);
    fileName            = 'PublicLinks.json';

    try
        fileParser = jsondecode(fileread(fullfile(programDataFolder, fileName)));
    catch
        fileParser = jsondecode(fileread(fullfile(projectFolder,     fileName)));
    end

    version   = fileParser.VersionFile;
    appColeta = fileParser.appColeta;
    RFDataHub = fileParser.RFDataHub;

end