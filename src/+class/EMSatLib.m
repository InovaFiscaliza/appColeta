classdef EMSatLib < handle

    % Author.: Eric Magalhães Delgado & Vinicius Puga
    % Date...: March 14, 2024
    % Version: 1.02

    properties
        %-----------------------------------------------------------------%
        Switch

        Antenna
        TargetList
        
        LNBCommand        
        LNB
        
        GeneratedDate
    end


    methods
        %-----------------------------------------------------------------%
        function obj = EMSatLib(RootFolder)
            % LNB commands
            lnbCommand = {'<0001/LBCHN=1', '>0001/LBCHN=1'; ...
                          '<0001/LBCHN=2', '>0001/LBCHN=2'; ...
                          '<0001/LBCHN=3', '>0001/LBCHN=3'; ...
                          '<0001/LBCHN=4', '>0001/LBCHN=4'};
            lnbCommand = table((1:4)', lnbCommand(:,1), lnbCommand(:,2), 'VariableNames', {'Port', 'set', 'get'});
            
            % Antenna/LNB list
            tempStruct = jsondecode(fileread(fullfile(RootFolder, 'config', 'EMSatLib.json')));

            tempStruct.LNB        = struct2table(tempStruct.LNB);
            tempStruct.LNB.Name   = string(tempStruct.LNB.Name);
            tempStruct.LNB.Offset = uint64(tempStruct.LNB.Offset);

            % Object
            obj.Switch        = tempStruct.Switch;
            obj.Antenna       = tempStruct.Antenna;
            obj.LNBCommand    = lnbCommand;
            obj.LNB           = tempStruct.LNB;
            obj.TargetList    = tempStruct.TargetList;
            obj.GeneratedDate = tempStruct.GeneratedDate;
        end


        %-----------------------------------------------------------------%
        function msgError = AntennaPositionSET(obj, targetPos)
            msgError = '';

            idx1 = find(strcmp({obj.Antenna.Name}, targetPos.Name), 1);
            IP   = obj.Antenna(idx1).ACU.IP;
            Port = obj.Antenna(idx1).ACU.Port;

            try
                hACU = SocketCreation(obj, IP, Port);

                switch obj.Antenna(idx1).ACU.Model
                    %-----------------------------------------------------%
                    case 'GD-7200'
                        switch targetPos.TrackingMode
                            case 'Target'
                                % Syntax: "TT 01 T"
        
                                idx2 = find(strcmp({obj.TargetList(idx1).Target.Name}, targetPos.Target), 1);
                                TargetID = obj.TargetList(idx1).Target(idx2).ID;
        
                                writeline(hACU, sprintf('TT %s T', TargetID));
        
                            case 'LookAngles'
                                % Syntax: "IA AAA.AAA EEE.EEE +-PPP.PPP"
                                % Range:
                                % - Azimuth:         0.00 to 360.00
                                % - Elevation:    -180.00 to 180.00
                                % - Polarization: -180.00 to 180.00
        
                                writeline(hACU, sprintf('IA %.3f %.3f %.3f', wrapTo360(targetPos.Azimuth), wrapTo180(targetPos.Elevation), wrapTo180(targetPos.Polarization)))
                        end

                    case 'GD-123T'
                        switch targetPos.TrackingMode
                            case 'Target'
                                % Syntax: "POS 1,0" | "POS 2,0" | ... | "POS 50,0"
        
                                idx2 = find(strcmp({obj.TargetList(idx1).Target.Name}, targetPos.Target), 1);
                                TargetID = obj.TargetList(idx1).Target(idx2).ID;
        
                                writeline(hACU, sprintf('POS %s,0', TargetID));
        
                            case 'LookAngles'
                                % Syntax: "TRACK 0,AAA.AAA,EEE.EEE,0.000"
                                % Range:
                                % - Azimuth:         0.00 to 360.00
                                % - Elevation:    -180.00 to 180.00
        
                                writeline(hACU, sprintf('TRACK 0,%.3f,%.3f,0.000', wrapTo360(targetPos.Azimuth), wrapTo180(targetPos.Elevation)))
                        end
                end

            catch  ME
                msgError = ME.message;
            end

            if exist('hACU', 'var'); clear hACU
            end
        end


        %-----------------------------------------------------------------%
        function [pos, msgError] = TargetPositionGET(obj, antennaName, targetName)
            pos = [];
            msgError = '';

            idx1 = find(strcmp({obj.Antenna.Name}, antennaName), 1);
            IP   = obj.Antenna(idx1).ACU.IP;
            Port = obj.Antenna(idx1).ACU.Port;

            try
                hACU = SocketCreation(obj, IP, Port);

                idx2 = find(strcmp({obj.TargetList(idx1).Target.Name}, targetName), 1);
                TargetID = obj.TargetList(idx1).Target(idx2).ID;

                regExp = RegularExpression(obj, 'TargetPosition', obj.Antenna(idx1).ACU.Model);

                switch obj.Antenna(idx1).ACU.Model
                    case 'GD-7200'
                        pos = WriteRead(obj, hACU, sprintf('TT %s', TargetID));
                        div = 1000;

                    case 'GD-123T'
                        pos = writeread(hACU, sprintf('SAT? %s', TargetID));
                        div = 1;
                end

                pos = regexp(pos, regExp, 'names');
                if ~isempty(pos)
                    pos = PositionParser(obj, pos, div);
                end

            catch  ME
                msgError = ME.message;
            end

            if exist('hACU', 'var'); clear hACU
            end
        end


        %-----------------------------------------------------------------%
        function [pos, msgError] = AntennaPositionGET(obj, antennaName)
            pos = [];
            msgError = '';

            idx1 = find(strcmp({obj.Antenna.Name}, antennaName), 1);
            IP   = obj.Antenna(idx1).ACU.IP;
            Port = obj.Antenna(idx1).ACU.Port;

            try
                hACU = SocketCreation(obj, IP, Port);

                switch obj.Antenna(idx1).ACU.Model
                    case 'GD-7200'
                        pos = WriteRead(obj, hACU, '/ CONFIGS ENCODERS CURRENT');

                    case 'GD-123T'
                        pos = writeread(hACU, 'STAT');
                end

                pos = regexp(pos, RegularExpression(obj, 'AntennaPosition', obj.Antenna(idx1).ACU.Model), 'names');
                if ~isempty(pos)
                    pos = PositionParser(obj, pos, 1);
                end

            catch  ME
                msgError = ME.message;
            end

            if exist('hACU', 'var'); clear hACU
            end
        end


        %-----------------------------------------------------------------%
        function msgError = MatrixSwitch(obj, InputPort, OutputPort, LNBChannel, LNBIndex)
            msgError = '';
            
            try
                % SWITCH
                hSwitch = tcpclient(obj.Switch.IP, obj.Switch.Port);
                [setMatrixCommand, ...
                 getMatrixCommand] = MatrixControlMessages(obj, InputPort, OutputPort);

                for ii = 1:class.Constants.switchTimes
                    % A matriz demora cerca de 40ms para comutação entre portas,
                    % apresentando resposta com a sua atual porta.
                    writeline(hSwitch, setMatrixCommand);
                    pause(class.Constants.switchPause)

                    if hSwitch.NumBytesAvailable && contains(read(hSwitch, hSwitch.NumBytesAvailable, 'char'), getMatrixCommand)
                        break
                    else
                        if ii == class.Constants.switchTimes
                            error('Unexpected value (EMSatLib:MatrixSwitch:Matrix)')
                        end
                    end
                end

                % LNB
                if LNBChannel ~= -1
                    IP   = obj.Antenna(LNBIndex(1)).LNB(LNBIndex(2)).IP;
                    Port = obj.Antenna(LNBIndex(1)).LNB(LNBIndex(2)).Port;    
                    hLNB = tcpclient(IP, Port);
                    configureTerminator(hLNB, "CR/LF")

                    setLNBCommand = obj.LNBCommand.set{LNBChannel};
                    getLNBCommand = obj.LNBCommand.get{LNBChannel};
    
                    for ii = 1:class.Constants.switchTimes
                        % O LNB demora entre 200 e 240ms para comutação entre
                        % portas, apresentando resposta com a sua atual porta.
                        writeline(hLNB, setLNBCommand);
                        pause(class.Constants.LNBPause)

                        if hLNB.NumBytesAvailable && contains(read(hLNB, hLNB.NumBytesAvailable, 'char'), getLNBCommand)
                            break
                        else
                            if ii == class.Constants.switchTimes
                                error('Unexpected value (EMSatLib:MatrixSwitch:LNB)')
                            end
                        end
                    end
                end

            catch ME
                msgError = ME.message;
                return
            end
        end


        %-----------------------------------------------------------------%
        function [setCommand, getCommand] = MatrixControlMessages(obj, InputPort, OutputPort)
            % O comutador, ao receber o comando "{*zs,012,001}0", comuta a matriz
            % de forma que a porta de entrada seja igual a "001" (caracteres 10 a 
            % 12 da string) e a de saída igual a "012" (caracteres 6 a 8 da string). 
            
            % O último caractere da string é um terminador cujo valor é função dos 
            % números das portas de entrada e saída, sendo orientado aos caracteres 
            % visíveis da tabela ASCII (de 32 a 126).

            % Abaixo um algoritmo que possibilita identificar esse terminador 
            % e que foi validado para os casos em que a porta de saída é 12
            % (R&S FSW) e 14 (R&S FSVR).           

            visibleASCII  = char(32:126); % ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

            setTerminator = num2cell(visibleASCII(OutputPort+5:OutputPort+13));
            getTerminator = num2cell(visibleASCII(OutputPort+48:OutputPort+56));

            idxTerminator = mod(InputPort-1, 9);

            % Caso porta de saída seja igual a 12:
            % - setTerminator = {'0', '1', '2', '3', '4', '5', '6', '7', '8'};
            % - getTerminator = {'[', '\', ']', '^', '_', '`', 'a', 'b', 'c'};
            %
            % Exemplos:
            % - input 001, output 012: "{*zs,012,001}0" e "{zBs?012,001}["
            % - input 002, output 012: "{*zs,012,002}1" e "{zBs?012,002}\"
            % - input 003, output 012: "{*zs,012,003}2" e "{zBs?012,003}]"
            % - (...)
            % - input 031, output 012: "{*zs,012,031}3" e "{zBs?012,031}^"
            % - input 032, output 012: "{*zs,012,032}4" e "{zBs?012,032}_"

            % Caso porta de saída seja igual a 14:
            % - setTerminator = {'2', '3', '4', '5', '6', '7', '8', '9', ':'};
            % - getTerminator = {']', '^', '_', '`', 'a', 'b', 'c', 'd', 'e'};
            %
            % Exemplos:
            % - input 001, output 014: "{*zs,014,001}2" e "{zBs?014,001}]"
            % - input 002, output 014: "{*zs,014,002}3" e "{zBs?014,002}^"
            % - input 003, output 014: "{*zs,014,003}4" e "{zBs?014,003}_"
            % - (...)
            % - input 031, output 014: "{*zs,014,031}5" e "{zBs?014,031}`"
            % - input 032, output 014: "{*zs,014,032}6" e "{zBs?014,032}a"

            formattedInputPort  = FormatPort(obj, InputPort);
            formattedOutputPort = FormatPort(obj, OutputPort);            

            setCommand = sprintf('{*zs,%s,%s}%s', formattedOutputPort, formattedInputPort, setTerminator{idxTerminator+1});
            getCommand = sprintf('{zBs?%s,%s}%s', formattedOutputPort, formattedInputPort, getTerminator{idxTerminator+1});

            % Nota:
            % - Em 15/03/2024, a matriz não comutou para as portas de entrada
            %   19, 28 e 29. O teste foi realizado, comutando essas entradas 
            %   para as saídas 12 (FSW) e 14 (FSVR).
        end


        %-----------------------------------------------------------------%
        function formattedPort = FormatPort(obj, Port)
            formattedPort = num2str(Port);
            formattedPort = [repmat('0', 1, 3-numel(formattedPort)), formattedPort];
        end


        %-----------------------------------------------------------------%
        function [antList, tgtList] = TargetListUpdate(obj, FullFileName)

            antList = obj.Antenna;
            tgtList = struct('Name', {obj.Antenna.Name}, 'Target', struct('ID', {}, 'Name', {}, 'Azimuth', {}, 'Elevation', {}, 'Polarization', {}));

            for ii = 1:numel(antList)
                IP   = antList(ii).ACU.IP;
                Port = antList(ii).ACU.Port;

                if isempty(IP)
                    continue
                end

                try
                    hACU = SocketCreation(obj, IP, Port);

                    regExp = RegularExpression(obj, 'TargetPosition', antList(ii).ACU.Model);
                    switch antList(ii).ACU.Model
                        case 'GD-7200'
                            % O WRITEREAD funciona aqui, mas é perigoso porque 
                            % a resposta da ACU possui um caractere "<" após 
                            % a quebra de linha. Consequentemente, esse caractere
                            % fica no buffer, podendo causar uma leitura equivocada 
                            % à frente, numa outra comunicação. Recomendável
                            % usar o WRITELINE seguido e um READ. O PAUSE é 
                            % essencial!

                            antennaName = WriteRead(obj, hACU, '/ CONFIGS SITE ANTENNA');
                            if ~contains(antennaName, antList(ii).Name)
                                error('Unexpected value (EMSatLib:TargetListUpdate)')
                            end

                            % O WRITEREAD não funciona aqui porque a resposta 
                            % da ACU possui diversas quebras de linha. Dessa forma, 
                            % o WRITEREAD, por ser uma concatenação dos métodos 
                            % WRITELINE e READLINE, não funciona...
                            % Deve-se usar um WRITELINE seguido de um PAUSE 
                            % e um READ (e não READLINE!). O PAUSE é essencial 
                            % pois a ACU demora alguns milisegundos para apresentar 
                            % a sua resposta completamente (cerca de 800 bytes).

                            tgtList2 = WriteRead(obj, hACU, '/ TRACKING TRACK LS');
                            tgtList2 = regexp(tgtList2, '\d{1,2} X T(?<ID>\d{2}) "(?<Name>.*)"', 'names', 'dotexceptnewline');
                            if ~isempty(tgtList2)
                                tgtList2(deblank({tgtList2.Name}) == "") = [];
                                
                                for jj = 1:numel(tgtList2)
                                    % Novamente...
                                    % O WRITEREAD funciona aqui, mas é perigoso porque 
                                    % a resposta da ACU possui um caractere "<" após 
                                    % a quebra de linha. O PAUSE aqui também é essencial.

                                    tgtInfo = WriteRead(obj, hACU, sprintf('TT %s', tgtList2(jj).ID));
                                    tgtInfo = regexp(tgtInfo, regExp, 'names');
                                    if ~isempty(tgtInfo)
                                        tgtInfo.ID   = tgtList2(jj).ID;
                                        tgtInfo.Name = tgtList2(jj).Name;

                                        tgtList(ii).Target(end+1) = PositionParser(obj, tgtInfo, 1000);
                                    end
                                end
                            end

                        case 'GD-123T'
                            for jj = 1:50
                                % Diferente do outro modelo de ACU (GD-7200), 
                                % a GD-123T apresenta respostas sem caracteres
                                % adicionais à quebra de linha. É possível,
                                % portanto, uso do WRITEREAD.

                                tgtName = replace(writeread(hACU, sprintf('SATDB? %d', jj)), '"', '');
                                if ismember(tgtName, {'', 'N BADD'})
                                    continue
                                end

                                tgtInfo = regexp(writeread(hACU, sprintf('SAT? %d', jj)), regExp, 'names');
                                if ~isempty(tgtInfo)
                                    tgtInfo.ID   = num2str(jj);
                                    tgtInfo.Name = tgtName;

                                    tgtList(ii).Target(end+1) = PositionParser(obj, tgtInfo, 1);
                                end
                            end
                    end
                    clear hACU

                catch ME
                    antList(ii).LOG = ME.message;

                    if exist('hACU', 'var'); clear hACU
                    end
                end                
            end

            % JSON file
            writematrix(jsonencode(struct('Switch',        obj.Switch, ...
                                          'Antenna',       antList,    ...
                                          'LNB',           obj.LNB,    ...
                                          'TargetList',    tgtList,    ...
                                          'GeneratedDate', datestr(now, 'dd/mm/yyyy HH:MM:SS')), 'PrettyPrint', true), FullFileName, "FileType", "text", "QuoteStrings", "none")
        end


        %-----------------------------------------------------------------%
        function [propTable, propSummary] = TargetProperties(obj, tgtList)

            % Em 07/09/2023 executei essa função, identificando os seguintes
            % limites:
            % (a) Azimuth:     0.118 a 356.297 graus (limites em auxApp.winAddTask: 0 a 360 graus)
            % (b) Elevation:  10.000 a  63.306 graus (limites em auxApp.winAddTask: 0 a  90 graus)
            % (c) Polarização: 0.000 a 355.700 graus (limites em auxApp.winAddTask: 0 a 360 graus)

            if nargin == 1
                tgtList = obj.TargetList;
            end

            propTable = table('Size', [0,6],                                                           ...
                              'VariableTypes', {'cell', 'cell', 'cell', 'double', 'double', 'double'}, ...
                              'VariableNames', {'Antenna', 'ID', 'Target', 'Azimuth', 'Elevation', 'Polarization'});
            
            for ii = 1:numel(tgtList)
                for jj = 1:numel(tgtList(ii).Target)
                    propTable(end+1,:) = {tgtList(ii).Name,                 ...
                                          tgtList(ii).Target(jj).ID,        ...
                                          tgtList(ii).Target(jj).Name,      ...
                                          tgtList(ii).Target(jj).Azimuth,   ...
                                          tgtList(ii).Target(jj).Elevation, ...
                                          tgtList(ii).Target(jj).Polarization};
                end
            end

            % Sumarização:
            if height(propTable)
                [antennaList, ~, antennaListIndex] = unique(propTable.Antenna);
    
                TargetPerAntenna = table(antennaList, accumarray(antennaListIndex, 1), 'VariableNames', {'Antenna', 'Count'});
                positionSummary  = struct('Azimuth',      struct('Min', min(propTable.Azimuth),      'Median', median(propTable.Azimuth),      'Max', max(propTable.Azimuth)),   ...
                                          'Elevation',    struct('Min', min(propTable.Elevation),    'Median', median(propTable.Elevation),    'Max', max(propTable.Elevation)), ...
                                          'Polarization', struct('Min', min(propTable.Polarization), 'Median', median(propTable.Polarization), 'Max', max(propTable.Polarization)));
    
                propSummary = struct('TargetCount',      height(propTable),         ...
                                     'TargetPerAntenna', TargetPerAntenna,          ...
                                     'Azimuth',          positionSummary.Azimuth,   ...
                                     'Elevation',        positionSummary.Elevation, ...
                                     'Polarization',     positionSummary.Polarization);
            else
                propSummary = struct('TargetCount',      0);
            end
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function hACU = SocketCreation(obj, IP, Port)
            hACU = tcpclient(IP, Port);
            configureTerminator(hACU, "CR/LF")

            pause(class.Constants.antACUPause)
            if hACU.NumBytesAvailable
                clear hACU
                error('The ACU appears to be controlled by the Compass, preventing the antenna from engaging in automatic tracking mode.')
            end
        end


        %-----------------------------------------------------------------%
        function receivedMessage = WriteRead(obj, hACU, requiredInfo)
            writeline(hACU, requiredInfo);
            pause(class.Constants.antACUPause)

            receivedMessage = read(hACU, hACU.NumBytesAvailable, 'char');
        end


        %-----------------------------------------------------------------%
        function regExp = RegularExpression(obj, srcFcn, ACUModel)

            switch srcFcn
                case 'TargetPosition'
                    switch ACUModel
                        case 'GD-7200'; regExp = '(?<Azimuth>\d{6}) (?<Elevation>\d{6}) (?<Polarization>\d{6})';
                        case 'GD-123T'; regExp = '(?<Azimuth>\d{1,3}[.]\d{1,3}),(?<Elevation>\d{1,3}[.]\d{1,3}),[-]?\d{1,3}[.]\d{1,3}';
                    end

                case 'AntennaPosition'
                    switch ACUModel
                        case 'GD-7200'; regExp = '(?<Azimuth>\d{1,3}[.]\d{1,3}) (?<Elevation>\d{1,3}[.]\d{1,3}) (?<Polarization>[-]?\d{1,3}[.]\d{1,3})';
                        case 'GD-123T'; regExp = '(?<Azimuth>\d{1,3}[.]\d+),(?<Elevation>\d{1,3}[.]\d+),\d+[.]\d+,\d+[.]?\d*,[-]?\d+.\d+';
                    end
            end
        end


        %-----------------------------------------------------------------%
        function tgtPos = PositionParser(obj, tgtPos, Divisor)

            % O tgtPos é uma estrutura gerada pela avaliação da expressão
            % regular, já possuindo os campos "Azimuth", "Elevation" e
            % "Polarization" (restrito à ACU GD-7200).

            tgtPos = tgtPos(end);

            tgtPos.Azimuth   = str2double(tgtPos.Azimuth)/Divisor;
            tgtPos.Elevation = str2double(tgtPos.Elevation)/Divisor;

            if isfield(tgtPos, 'Polarization')
                tgtPos.Polarization = wrapTo360(str2double(tgtPos.Polarization)/Divisor);
            else
                tgtPos.Polarization = 0;
            end
        end
    end
end
        