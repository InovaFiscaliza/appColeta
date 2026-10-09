%-----------------------------------------------------------------%
function responses = testTcpServer()
    projectFolder = fileparts(fileparts(mfilename("fullpath")));
    settingsPath = fullfile(projectFolder, "src", "config", "GeneralSettings.json");
    generalSettings = jsondecode(fileread(settingsPath));
    serverSettings = generalSettings.context.SERVER;

    serverAddress = serverSettings.ip;
    if isempty(serverAddress)
        serverAddress = "127.0.0.1";
    end

    tcpClient = tcpclient(serverAddress, serverSettings.port, "Timeout", 10);
    configureTerminator(tcpClient, "CR/LF")

    requests = ["StationInfo", "Diagnostic", "Summary", "PositionList", "TaskList"];
    responses = struct();

    for requestIdx = 1:numel(requests)
        requestName = requests(requestIdx);
        request = struct( ...
            "Key", serverSettings.key, ...
            "ClientName", "MATLAB", ...
            "Request", requestName ...
        );

        try
            writeline(tcpClient, jsonencode(request))
            rawResponse = readline(tcpClient);
    
            prefix = "<JSON>";
            suffix = "</JSON>";
            if ~startsWith(rawResponse, prefix) || ~endsWith(rawResponse, suffix)
                error("testTcpServer:InvalidResponse", "Resposta inválida para a requisição %s: %s", requestName, rawResponse)
            end
    
            decodedResponse = jsondecode(extractBetween(rawResponse, prefix, suffix));
            if ~strcmp(decodedResponse.Request, requestName)
                error("testTcpServer:UnexpectedRequest", "Resposta recebida não corresponde à requisição %s.", requestName)
            end
    
            responses.(requestName) = decodedResponse.Answer;
        
        catch ME            
            display(ME.message)
        end
    end
end