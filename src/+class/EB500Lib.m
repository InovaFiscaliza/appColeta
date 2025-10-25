classdef EB500Lib < handle

    % Author.: Eric Magalhães Delgado & Michel Cerqueira Kulhavy
    % Date...: September 15, 2023
    % Version: 1.02

    properties
        SelectivityMap
        FFMSpanStepMap
        Firmware
        udpPort
        nDatagrams
    end


    methods
        %-----------------------------------------------------------------%
        function obj = EB500Lib(RootFolder)
            % Selectivity x Resolution Mapping
            SelectivityMap = table('Size', [15, 3],                                 ...
                                   'VariableTypes', {'double', 'double', 'double'}, ...
                                   'VariableNames', {'Normal', 'Narrow', 'Sharp'},  ...
                                   'RowNames', {'2.500 kHz', '3.125 kHz', '5.000 kHz', '6.250 kHz', '8.333 kHz', '10.000 kHz', '12.500 kHz', '20.000 kHz', '25.000 kHz', '50.000 kHz', '100.000 kHz', '200.000 kHz', '500.000 kHz', '1000.000 kHz', '2000.000 kHz'});

            SelectivityMap(1:15,:) = {   6000    3000    1500; ... %    2.500 kHz
                                         7500    3750    1875; ... %    3.125 kHz (valor mínimo para o modo FFM, caso span seja igual a 10 MHz)
                                        12000    6000    3000; ... %    5.000 kHz
                                        15000    7500    3750; ... %    6.250 kHz (valor mínimo para o modo FFM, caso span seja igual a 20 MHz)
                                        20000   10000    5000; ... %    8.333 kHz
                                        24000   12000    6000; ... %   10.000 kHz
                                        30000   15000    7500; ... %   12.500 kHz
                                        48000   24000   12000; ... %   20.000 kHz
                                        60000   30000   15000; ... %   25.000 kHz
                                       120000   60000   30000; ... %   50.000 kHz
                                       240000  120000   60000; ... %  100.000 kHz (valor máximo para o modo FFM, caso span seja igual a  1 MHz)
                                       480000  240000  120000; ... %  200.000 kHz (valor máximo para o modo FFM, caso span seja igual a  2 MHz)
                                      1200000  600000  300000; ... %  500.000 kHz (valor máximo para o modo FFM, caso span seja igual a  5 MHz)
                                      2400000 1200000  600000; ... % 1000.000 kHz (valor máximo para o modo FFM, caso span seja igual a 10 MHz)
                                      4800000 2400000 1200000};    % 2000.000 kHz (valor máximo para o modo FFM, caso span seja igual a 20 MHz)

            % Span x StepWidth Mapping (FFM mode)
            FFMSpanStepMap= table('Size', [5, 3],                                  ...
                              'VariableTypes', {'double', 'double', 'double'}, ...
                              'VariableNames', {'Span', 'minStepWidth', 'maxStepWidth'});

            FFMSpanStepMap(1:5,:)  = {1e+6,   312.5, 100e+3;   ... % 1 MHz
                                      2e+6,   625,   200e+3;   ... % 2 MHz
                                      5e+6,  2000,   500e+3;   ... % 5 MHz
                                      10e+6, 3125,  1000e+3;   ... % 10 MHz
                                      20e+6, 6250,  2000e+3};      % 20 MHz

            obj.SelectivityMap = SelectivityMap;
            obj.FFMSpanStepMap = FFMSpanStepMap;

            % Firmware version, udpPort & nDatagrams
            tempStruct = jsondecode(fileread(fullfile(RootFolder, 'config', 'EB500Lib.json')));

            obj.Firmware   = tempStruct.Firmware;
            obj.udpPort    = tempStruct.udpPort;
            obj.nDatagrams = tempStruct.nDatagrams;
        end
    end


    methods(Static = true)
        %-----------------------------------------------------------------%
        function OperationMode(hReceiver, ID)
            switch ID
                case 2 % PSCAN
                    writeline(hReceiver, 'stat:ext:data #2143L000006:0:0 3;:stat:ext:data #21525L000006:0:0 1')
                    pause(.001)
                case 3 % FFM DF
                    writeline(hReceiver, 'stat:ext:data #2143L000006:0:0 0')
                    writeline(hReceiver, 'stat:ext:data #216278L000006:0:0 1;:stat:ext:data #220103L000010:0:0 30721')
                    pause(.001)
            end
        end


        %-----------------------------------------------------------------%
        function specObj = DatagramRead_PSCAN_PreTask(EB500Obj, specObj, hReceiver, hStreaming)
            Timeout  = class.Constants.Timeout;
            udpPort  = hStreaming.LocalPort;

            for ii = 1:numel(specObj.Band)
                specDatagram = [];
                
                writeline(hReceiver, specObj.Band(ii).SpecificSCPI.configSET);

                flush(hStreaming)
                class.EB500Lib.DatagramRead_OnOff('PSCAN', 'Open', udpPort, hReceiver)

                udpTic = tic;
                t = toc(udpTic);
                while t < Timeout
                    specDatagram = [specDatagram, read(hStreaming, hStreaming.NumDatagramsAvailable)];

                    if numel(specDatagram) > EB500Obj.nDatagrams                        
                        break
                    end
                    t = toc(udpTic);
                end
                class.EB500Lib.DatagramRead_OnOff('PSCAN', 'Close', udpPort, hReceiver)

                if isempty(specDatagram)
                    error(['ERROR - Não identificada a estimativa do número de datagramas que representam um único traço do fluxo %d.\n' ...
                           'Possíveis causas:\n'                                                                     ...
                           '(a) Perda de conectividade com o EB500.\n'                                               ...
                           '(b) <i>Firewall</i> bloqueando fluxo UDP gerado pelo EB500.\n'                           ...
                           '(c) Não redirecionamento de porta do roteador (no caso de não ser uma conexão direta ao EB500).'], ii)
                end

                % Delete datagrams sent by an unexpected source
                idx0 = ([specDatagram.SenderAddress] ~= hReceiver.Address);
                if any(idx0)
                    specDatagram(idx0) = [];
                end

                nDatagrams  = 0;
                nTerminator = 0;
                for jj = 1:numel(specDatagram)
                    specDatagram(jj).Data = uint8(specDatagram(jj).Data);

                    MagicNumber = typecast(specDatagram(jj).Data( 4:-1: 1), 'uint32');
                    DataSize    = typecast(specDatagram(jj).Data(16:-1:13), 'uint32');

                    FreqStart   = double(typecast(specDatagram(jj).Data(32:-1:29), 'uint32')) + double(typecast(specDatagram(jj).Data(44:-1:41), 'uint32')) * 2^32;
                    FreqStop    = double(typecast(specDatagram(jj).Data(36:-1:33), 'uint32')) + double(typecast(specDatagram(jj).Data(48:-1:45), 'uint32')) * 2^32;
                    DataPoints  = (FreqStop - FreqStart)/double(typecast(specDatagram(jj).Data(40:-1:37), 'uint32')) + 1;

                    if (MagicNumber == 963072)                                     && ...
                            (DataSize   == numel(specDatagram(jj).Data))           && ...
                            (FreqStart  == specObj.Task.Script.Band(ii).FreqStart) && ...
                            (FreqStop   == specObj.Task.Script.Band(ii).FreqStop)  && ...
                            (DataPoints == specObj.Band(ii).DataPoints)
                        nDatagrams = nDatagrams + 1;
                        if typecast(specDatagram(jj).Data(end:-1:end-1), 'uint16') == 2000
                            nTerminator = nTerminator + 1;
                        end
                    end
                end
                
                if nTerminator
                    specObj.Band(ii).Datagrams = round(nDatagrams/nTerminator);
                else
                    error(['ERROR - Não identificada a estimativa do número de datagramas que representam um único traço do fluxo %d.\n' ...
                           'Possíveis causas:\n'                                                                     ...
                           '(a) Perda de conectividade com o EB500.\n'                                               ...
                           '(b) <i>Firewall</i> bloqueando fluxo UDP gerado pelo EB500.\n'                           ...
                           '(c) Não redirecionamento de porta do roteador (no caso de não ser uma conexão direta ao EB500).'], ii)
                end
            end
        end


        %-----------------------------------------------------------------%
        function [newArray, Flag_success] = DatagramRead_PSCAN(taskInfo, hReceiver, hStreaming)            
            Timeout = class.Constants.Timeout;
            udpPort = hStreaming.LocalPort;

            newArray     = zeros(1, taskInfo.DataPoints, 'single');
            Flag_success = false;
            specDatagram = [];

            flush(hStreaming)
            class.EB500Lib.DatagramRead_OnOff('PSCAN', 'Open', udpPort, hReceiver)
            
            udpTic = tic;
            t = toc(udpTic);
            while t < Timeout
                specDatagram = [specDatagram, read(hStreaming, 2*taskInfo.nDatagrams-1)];

                if ~isempty(specDatagram)
                    % Delete datagrams sent by an unexpected source
                    idx0 = ([specDatagram.SenderAddress] ~= hReceiver.Address);
                    if any(idx0)
                        specDatagram(idx0) = [];
                    end
        
                    % Sort datagrams
                    DatagramsID = zeros(numel(specDatagram), 1);        
                    for ii = 1:numel(specDatagram)
                        specDatagram(ii).Data = uint8(specDatagram(ii).Data);
        
                        DatagramID_low  = double(typecast(specDatagram(ii).Data(10:-1: 9), 'uint16'));
                        DatagramID_high = double(typecast(specDatagram(ii).Data(12:-1:11), 'uint16')).*2^16;
                        DatagramsID(ii) = DatagramID_low + DatagramID_high;
                    end
        
                    if ~issorted(DatagramsID)
                        [DatagramsID, idxSort] = sort(DatagramsID);
                        specDatagram = specDatagram(idxSort);
                    end
        
                    % Array
                    udpFlag  = 0;
                    Points   = 0;
        
                    for jj = 1:numel(specDatagram)
                        if udpFlag && (DatagramsID(jj) ~= DatagramsID(jj-1)+1)
                            udpFlag  = 0;
                            Points   = 0;
                            continue
                        end
        
                        MagicNumber = typecast(specDatagram(jj).Data( 4:-1: 1), 'uint32');
                        DataSize    = typecast(specDatagram(jj).Data(16:-1:13), 'uint32');
                        FreqStart  = double(typecast(specDatagram(jj).Data(32:-1:29), 'uint32')) + double(typecast(specDatagram(jj).Data(44:-1:41), 'uint32')) * 2^32;
                        FreqStop   = double(typecast(specDatagram(jj).Data(36:-1:33), 'uint32')) + double(typecast(specDatagram(jj).Data(48:-1:45), 'uint32')) * 2^32;
                        DataPoints = (FreqStop - FreqStart)/double(typecast(specDatagram(jj).Data(40:-1:37), 'uint32')) + 1;
        
                        if (MagicNumber == 963072)                           && ...
                                (DataSize   == numel(specDatagram(jj).Data)) && ...
                                (FreqStart  == taskInfo.FreqStart)           && ...
                                (FreqStop   == taskInfo.FreqStop)            && ...
                                (DataPoints == taskInfo.DataPoints)
                            idx1   = Points + 1;
                            Points = Points + typecast(specDatagram(jj).Data(22:-1:21), 'uint16');
                            idx2   = Points;
        
                            if typecast(specDatagram(jj).Data(end:-1:end-1), 'uint16') == 2000
                                if Points == DataPoints+1
                                    newArray(idx1:idx2-1) = single(flip(typecast(specDatagram(jj).Data((end-2):-1:(end-2*(idx2-idx1)-1)), 'int16')))./10;
                                    Flag_success = true;
                                    break
                                else
                                    udpFlag = 0;
                                    Points  = 0;
                                end
                            else
                                udpFlag = 1;
                                newArray(idx1:idx2) = single(flip(typecast(specDatagram(jj).Data(end:-1:(end-2*(idx2-idx1)-1)), 'int16')))./10;
                            end
                        end
                    end
        
                    if Flag_success
                        break
                    end
                end
                t = toc(udpTic);
            end

            class.EB500Lib.DatagramRead_OnOff('PSCAN', 'Close', udpPort, hReceiver)
        end


        %-----------------------------------------------------------------%
        function [newArray, gpsData, Flag_success] = DatagramRead_FFM(taskInfo, hReceiver, hStreaming)            
            Timeout = class.Constants.Timeout;
            udpPort = hStreaming.LocalPort;

            newArray     = zeros(1, taskInfo.DataPoints, 3, 'single');
            gpsData      = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '');
            Flag_success = false;
            
            specDatagram = [];           

            % O appColeta conseguia executar essa tarefa apenas com o EB500GUI 
            % aberto. Usado o Wireshark foi possível identificar alguns aspectos 
            % da comunicação entre o EB500GUI e o instrumento, os quais não
            % constam no manual à disposição da Agência.
            %
            % (a) Chavear para o modo PSCAN, iniciando uma varredura
            %     writeline(hReceiver, 'stat:ext:data #2143L000006:0:0 3;:stat:ext:data #21525L000006:0:0 1')
            %
            % (b) Chavear para o modo FFM, voltando ao estado pretérito:
            %     writeline(hReceiver, 'stat:ext:data #2143L000006:0:0 0')
            %
            % (c) Estando no modo FFM, chavear entre "Receiver" e "DF":
            %     writeline(i, 'stat:ext:data #216278L000006:0:0 0') % DF >> AF
            %     writeline(i, 'stat:ext:data #216278L000006:0:0 1') % AF >> DF

            flush(hStreaming)
            class.EB500Lib.DatagramRead_OnOff('FFM', 'Open', udpPort, hReceiver)
            
            udpTic = tic;
            t = toc(udpTic);
            while t < Timeout
                specDatagram = [specDatagram, read(hStreaming, hStreaming.NumDatagramsAvailable)];

                if ~isempty(specDatagram)
                    % Delete datagrams sent by an unexpected source
                    idx0 = ([specDatagram.SenderAddress] ~= hReceiver.Address);
                    if any(idx0)
                        specDatagram(idx0) = [];
                    end
        
                    % Array        
                    for ii = 1:numel(specDatagram)
                        specDatagram(ii).Data = uint8(specDatagram(ii).Data);
        
                        MagicNumber = typecast(specDatagram(ii).Data( 4:-1: 1), 'uint32');
                        DataSize    = typecast(specDatagram(ii).Data(16:-1:13), 'uint32');

                        DataPoints  = typecast(specDatagram(ii).Data(22:-1:21), 'uint16');
                        FreqCenter  = double(typecast(specDatagram(ii).Data(32:-1:29), 'uint32')) + double(typecast(specDatagram(ii).Data(36:-1:33), 'uint32')) * 2^32;
                        FreqSpan    = double(typecast(specDatagram(ii).Data(40:-1:37), 'uint32'));

                        gpsData.Status  = double(typecast(specDatagram(ii).Data(94:-1: 93), 'int16'));
                        if gpsData.Status
                            gpsData.Latitude = double(typecast(specDatagram(ii).Data(100:-1:99), 'int16')) + double(typecast(specDatagram(ii).Data(104:-1:101), 'single'))/60;
                            if strcmp(char(typecast(specDatagram(ii).Data( 98:-1:97),  'int16')), 'S'); gpsData.Latitude = -gpsData.Latitude;
                            end
                            
                            gpsData.Longitude = double(typecast(specDatagram(ii).Data(108:-1:107), 'int16')) + double(typecast(specDatagram(ii).Data(112:-1:109), 'single'))/60;
                            if strcmp(char(typecast(specDatagram(ii).Data(106:-1:105),  'int16')), 'W'); gpsData.Longitude = -gpsData.Longitude;
                            end
                        end

                        if (MagicNumber == 963072)                           && ...
                                (DataSize   == numel(specDatagram(ii).Data)) && ...
                                (FreqCenter == taskInfo.FreqCenter)          && ...
                                (FreqSpan   == taskInfo.FreqSpan)            && ...
                                (DataPoints == taskInfo.DataPoints)

                            % Limites "Level"
                            idx11 = 143;
                            idx12 = idx11 + DataPoints*2 - 1;
                        
                            % Limites "Azimuth"
                            idx21 = idx12 + 1;
                            idx22 = idx21 + DataPoints*2 - 1;
                        
                            % Limites "AzimuthQuality"
                            idx31 = idx22 + 1;
                            idx32 = idx31 + DataPoints*2 - 1;
                        
                            newArray(1,:,1) = single(flip(typecast(specDatagram(ii).Data(idx12:-1:idx11), 'int16'))) ./ 10;
                            newArray(1,:,2) = single(flip(typecast(specDatagram(ii).Data(idx22:-1:idx21), 'int16'))) ./ 10;
                            newArray(1,:,3) = single(flip(typecast(specDatagram(ii).Data(idx32:-1:idx31), 'int16'))) ./ 10;

                            % Caso não seja registrado o azimute de algum bin, 
                            % talvez por não ter atendida condição do SquelchValue, 
                            % o EB500 insere o valor 3276.6000976562 tanto
                            % no vetor do azimute quando no vetor de nota
                            % de qualidade do azimute.
                            idxNaN = newArray(1,:,2) > 3000;
                            if any(idxNaN)
                                newArray(1,idxNaN,2:3) = -1;
                            end

                            Flag_success = true;
                            break
                        end
                    end
        
                    if Flag_success
                        break
                    end
                end
                t = toc(udpTic);
            end

            class.EB500Lib.DatagramRead_OnOff('FFM', 'Close', udpPort, hReceiver)
        end


        %-----------------------------------------------------------------%
        function DatagramRead_OnOff(operationMode, operationType, udpPort, hReceiver)
            switch operationMode
                case 'PSCAN'
                    switch operationType
                        case 'Open'
                            writeline(hReceiver, sprintf('TRACE:UDP:TAG:ON "%s", %.0f, PSCAN',                                      hReceiver.UserData.ClientIP, udpPort))
                            writeline(hReceiver, sprintf('TRACE:UDP:FLAG:ON "%s", %.0f, "VOLTage:AC", "OPT"',                       hReceiver.UserData.ClientIP, udpPort))
        
                        case 'Close'
                            writeline(hReceiver, sprintf('TRACE:UDP:TAG:OFF "%s", %.0f, PSCAN',                                     hReceiver.UserData.ClientIP, udpPort))
                            writeline(hReceiver, sprintf('TRACE:UDP:FLAG:OFF "%s", %.0f, "VOLTage:AC", "OPT"',                      hReceiver.UserData.ClientIP, udpPort))
                            writeline(hReceiver, sprintf('TRACE:UDP:DEL "%s", %.0f',                                                hReceiver.UserData.ClientIP, udpPort))
                    end

                case 'FFM'
                    switch operationType
                        case 'Open'
                            writeline(hReceiver, sprintf('TRACE:UDP:TAG:ON "%s", %.0f, DFPan',                                     hReceiver.UserData.ClientIP, udpPort))
                            writeline(hReceiver, sprintf('TRACE:UDP:FLAG:ON "%s", %.0f, "DFLevel", "AZImuth", "DFQuality", "OPT"', hReceiver.UserData.ClientIP, udpPort))
        
                        case 'Close'
                            writeline(hReceiver, sprintf('TRACE:UDP:TAG:OFF "%s", %.0f, DFPan',                                     hReceiver.UserData.ClientIP, udpPort))
                            writeline(hReceiver, sprintf('TRACE:UDP:FLAG:OFF "%s", %.0f, "DFLevel", "AZImuth", "DFQuality", "OPT"', hReceiver.UserData.ClientIP, udpPort))                            
                            writeline(hReceiver, sprintf('TRACE:UDP:DEL "%s", %.0f',                                                hReceiver.UserData.ClientIP, udpPort))
                    end
            end
        end
    end
end