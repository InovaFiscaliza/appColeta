function tempList = instrumentListRead(FullFilePath)

    tempList = jsondecode(fileread(FullFilePath));

    for ii = numel(tempList):-1:1
        switch tempList(ii).Type
            case 'Serial';       essentialFields = {'Port', 'BaudRate'};
            case 'TCPIP Socket'; essentialFields = {'IP', 'Port'};
            otherwise;           essentialFields = {};
        end
    
        if ~all(ismember(essentialFields, fields(tempList(ii).Parameters)))
            tempList(ii) = [];
        else
            tempList(ii).Parameters = jsonencode(tempList(ii).Parameters);
        end                    
    end
    
    tempList = struct2table(tempList, 'AsArray', true);
end