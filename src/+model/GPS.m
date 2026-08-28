classdef GPS < handle
    properties
        Config
        
        List = table( ...
            'Size', [0, 6], ...
            'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'cell', 'double'}, ...
            'VariableNames', {'Family', 'Name', 'Type', 'Parameters', 'Description', 'Enable'} ...
        )

        Table = table( ...
            'Size', [0, 4], ...
            'VariableTypes', {'string', 'string', 'cell', 'string'}, ...
            'VariableNames', {'Family', 'Socket', 'Handle', 'Status'} ...
        )
    end


    properties (Constant)
        DEFAULT = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '')
        TIMEOUT = 1
    end


    methods
        %-----------------------------------------------------------------%
        function obj = GPS(rootFolder)
            obj.Config = struct2table(jsondecode(fileread(fullfile(rootFolder, 'config', 'GPSLib.json'))));

            tempList = fileRead(obj, rootFolder);
            if ~isempty(tempList)
                obj.List = tempList;
            end
        end

        %-----------------------------------------------------------------%
        function [gpsHandleIdx, errorMsg] = connect(obj, gpsConfig)
            % Características do instrumento em que se deseja controlar:
            gpsType = gpsConfig.Type;
            [ip, port, baudRate, timeout] = missingParameters(obj, gpsConfig.Parameters);

            switch gpsType
                case 'Serial'
                    socketTag = port;
                
                    case 'TCPIP Socket'
                    socketTag = sprintf("%s:%s", ip, port);
            end

            % Consulta se já há objeto criado para o instrumento:
            errorMsg = '';
            gpsHandleIdx = find(strcmp(obj.Table.Socket, socketTag), 1);

            if ~isempty(gpsHandleIdx)
                gpsHandle = obj.Table.Handle{gpsHandleIdx};
                        
                warning('off', 'MATLAB:structOnObject')
                warning('off', 'transportlib:legacy:PropertyNotSupported')

                % Três tentativas para reestabelecer a comunicação, caso
                % esteja com falha.
                for kk = 1:3
                    try
                        switch gpsType
                            case 'Serial'
                                transportHandle = struct(gpsHandle).Transport;
                                
                            case 'TCPIP Socket'
                                transportHandle = struct(struct(gpsHandle).TCPCustomClient).Transport;
                        end

                        if ~transportHandle.Connected
                            transportHandle.connect
                        end

                        if connectionStatus(obj, gpsHandle)
                            break
                        end

                    catch ME
                        switch ME.identifier
                            case 'network:tcpclient:connectFailed'
                                errorMsg = ME.message;
                                obj.Table.Status(gpsHandleIdx) = 'Disconnected';
                                return

                            case {'MATLAB:class:InvalidHandle', 'testmeaslib:CustomDisplay:PropertyError'}
                                delete(obj.Table.Handle{gpsHandleIdx})
                                obj.Table(gpsHandleIdx, :) = [];
                                gpsHandleIdx = [];
                                break
                        end
                    end

                    pause(.100)
                end
            end

            try
                if isempty(gpsHandleIdx)
                    gpsHandleIdx = height(obj.Table)+1;
                    switch gpsType
                        case 'Serial'
                            gpsHandle = serialport(port, baudRate);

                        case 'TCPIP Socket'
                            gpsHandle = tcpclient(ip, str2double(port));
                    end
                    gpsHandle.Timeout = timeout;

                    if ~connectionStatus(obj, gpsHandle)
                        error('GPSLib:NoData', 'No data received from GPS')
                    end
                end

                obj.Table(gpsHandleIdx, :) = {"GPS", socketTag, gpsHandle, "Connected"};
      
            catch ME
                errorMsg = ME.message;
                if (gpsHandleIdx > height(obj.Table)) && exist('gpsHandle', 'var')
                    clear gpsHandle
                end

                gpsHandleIdx = [];
            end
        end

        %-----------------------------------------------------------------%
        function reconnectAttempt(obj, gpsConfig)
            connect(obj, gpsConfig);
        end

        %-----------------------------------------------------------------%
        function [gpsHandle, gps, notification] = testConnectivity(obj, gpsConfig, emitNotification)
            gps = [];
            notification = [];

            [gpsHandleIdx, errorMsg] = connect(obj, gpsConfig);

            if isempty(errorMsg)
                gpsHandle = obj.Table.Handle{gpsHandleIdx};

                if emitNotification
                    gps = model.GPS.fetchGPSCoordinates('External', gpsHandle);

                    if gps.Status
                        [cityName, cityDistance] = gpsLib.findNearestCity(gps);

                        if isempty(gps.TimeStamp)
                            gps.TimeStamp = 'NA';
                        end

                        msg = sprintf([ ...
                            'Status: %.0f\nLatitude: %.6f\nLongitude: %.6f\nTimestamp: %s\n\n' ...
                            'Nota:\nCoordenadas geográficas distam <b>%.1f km</b> da sede do município <b>%s</b>.' ...
                        ], gps.Status, gps.Latitude, gps.Longitude, gps.TimeStamp, cityDistance, cityName);
                    else
                        msg = sprintf('<b>Não recebida informação válida do instrumento acerca das coordenadas geográficas do local de monitoração.</b>\n%s', jsonencode(gps));
                    end

                    notification = struct('type', 'warning', 'message', msg);
                end

            else
                gpsHandle = [];
                if emitNotification
                    notification = struct('type', 'error', 'message', errorMsg);
                end
            end
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function tempList = fileRead(~, rootFolder)
            appName = class.Constants.appName;
            [projectFolder, programDataFolder] = appEngine.util.Path(appName, rootFolder);

            try
                tempList = fcn.instrumentListRead(fullfile(programDataFolder, 'instrumentList.json'));
            catch ME
                tempList = fcn.instrumentListRead(fullfile(projectFolder,     'instrumentList.json'));
            end

            tempList(~strcmp(tempList.Family, 'GPS'), :) = [];
        end

        %-----------------------------------------------------------------%
        function [ip, port, baudRate, timeout] = missingParameters(obj, Parameters)
            % IP
            if isfield(Parameters, 'IP')
                ip = Parameters.IP;
            else
                ip = '';
            end

            if strcmpi(ip, 'localhost')
                ip = '127.0.0.1';
            end
        
            % Port
            if isfield(Parameters, 'Port')
                port = Parameters.Port;
            else
                port = [];
            end

            % BaudRate
            if isfield(Parameters, 'BaudRate')
                baudRate = Parameters.BaudRate;
            else
                baudRate = 9600;
            end

            % Timeout
            if isfield(Parameters, 'Timeout')
                timeout = Parameters.Timeout;
            else
                timeout = obj.TIMEOUT;
            end
        end

        %-----------------------------------------------------------------%
        function status = connectionStatus(obj, gpsHandle)            
            status = false;
            flush(gpsHandle)

            statusTic = tic;
            t = toc(statusTic);

            while t < obj.TIMEOUT
                if gpsHandle.NumBytesAvailable
                    status = true;
                    break
                end

                t = toc(statusTic);
            end
        end
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function gps = fetchGPSCoordinates(gpsType, handle, varargin)
            arguments
                gpsType {mustBeMember(gpsType, {'Built-in', 'External'})}
                handle
            end

            arguments (Repeating)
                varargin
            end

            % Inicialmente, limpa o buffer do objeto socket.
            flush(handle)

            gps = model.GPS.DEFAULT;
            switch gpsType
                case 'Built-in'
                    receiverId = varargin{1};
                    gps = model.GPS.queryReceiverGPS(gps, handle, receiverId);

                case 'External'
                    gps = model.GPS.queryExternalGPS(gps, handle);
            end
        end
    end


    methods (Static = true, Access = private)
        %-----------------------------------------------------------------%
        function gps = queryReceiverGPS(gps, receiverHandle, receiverId)
            %-------------------------------------------------------------%
            % ## R&S EB500 ##
            % Requisição: ':SYSTem:GPS:DATA?'
            % Resposta  : string vazia '' (não há conectividade); ou string com o template 'GPS,1,1629933835,74,11,S,18,53,19.70,W,48,13,50.99,2021,8,25,23,23,55,0.00,0.00,338.50,940.00,1,-8.00'
            %-------------------------------------------------------------%
            if contains(receiverId, 'EB500')
                gpsStr = deblank(writeread(receiverHandle, ':SYSTem:GPS:DATA?'));

                if ~isempty(gpsStr) && contains(gpsStr, 'GPS')
                    gpsStr = strsplit(gpsStr, ',');

                    gps.Status = str2double(gpsStr{2});
                    if gps.Status
                        gps.Latitude = str2double(gpsStr{7}) + str2double(gpsStr{8})/60 + str2double(gpsStr{9})/3600;
                        if strcmp(gpsStr{6}, 'S'); gps.Latitude = -gps.Latitude;
                        end

                        gps.Longitude = str2double(gpsStr{11}) + str2double(gpsStr{12})/60 + str2double(gpsStr{13})/3600;
                        if strcmp(gpsStr{10}, 'W'); gps.Longitude = -gps.Longitude;
                        end

                        gps.TimeStamp = datestr(datetime([str2double(gpsStr{14}), str2double(gpsStr{15}), str2double(gpsStr{16}), ...
                                                          str2double(gpsStr{17}), str2double(gpsStr{18}), str2double(gpsStr{19})]), 'dd/mm/yyyy HH:MM:SS');
                    end
                end


            %-------------------------------------------------------------%
            % ## ANRITSU MS2720T ##
            % Requisição: ':FETCh:GPS?'
            % Reposta   : Uma string vazia '' (não há conectividade); string 'NO FIX' (informação inválida); ou string com o template 'GOOD FIX,WED AUG 25 23:10:29 2021,-0.2267732173,-0.6713082194' (informação válida)
            %-------------------------------------------------------------%
            elseif contains(receiverId, 'MS2720T')
                gpsStr = deblank(writeread(receiverHandle, ':FETCh:GPS?'));

                if ~isempty(gpsStr) && contains(gpsStr, 'GOOD FIX')
                    gpsStr = strsplit(gpsStr, ',');

                    gps.Status    = 1;
                    gps.Latitude  = str2double(gpsStr{3})*180/pi;
                    gps.Longitude = str2double(gpsStr{4})*180/pi;
                    gps.TimeStamp = datestr(datetime(gpsStr{2}, "InputFormat", "eee MMM dd HH:mm:ss yyyy"), 'dd/mm/yyyy HH:MM:SS');
                end


            %-------------------------------------------------------------%
            % ## KEYSIGHT N9344C ##
            % Requisição: ':SYSTem:GPSinfo?'
            % Resposta  : string vazia '' (não há conectividade); string com o template '-38.463093,-12.993198,40,08252021,21:11:50' (informação válida); ou string '0.000000,0.000000,0,02152009,00:12:19' (informação inválida)
            %-------------------------------------------------------------%
            elseif contains(receiverId, 'N9344C')
                gpsStr = deblank(writeread(receiverHandle, ':SYSTem:GPSinfo?'));

                if ~isempty(gpsStr) && ~contains(gpsStr, '0.000000')
                    gpsStr = strsplit(gpsStr, ',');

                    gps.Status    = 1;
                    gps.Latitude  = str2double(gpsStr{2});
                    gps.Longitude = str2double(gpsStr{1});
                    gps.TimeStamp = datestr(datetime(sprintf('%s %s', gpsStr{4}, gpsStr{5}), "InputFormat", "MMddyyyy HH:mm:ss"), 'dd/mm/yyyy HH:MM:SS');
                end


            %-------------------------------------------------------------%
            % ## KEYSIGHT N9936B ##
            % Requisição: ':SYSTem:GPS:DATA?'
            % Resposta  : string vazia '' (não há conectividade); string com o template '"12 51.63421 S,38 18.50857 W,26,2021-08-27 19:29:34Z"' (informação válida); ou string '"0,0,0,2021-08-27 19:33:18Z"' (informação inválida)
            %-------------------------------------------------------------%
            elseif contains(receiverId, 'N9936B')
                gpsStr = extractBetween(deblank(writeread(receiverHandle, ':SYSTem:GPS:DATA?')), '"', '"');

                if ~isempty(gpsStr) && ~contains(gpsStr{1}, '0,0,0')
                    gpsStr = strsplit(gpsStr{1}, ',');

                    gps.Status    = 1;

                    Latitude     = strsplit(gpsStr{1}, ' ');
                    gps.Latitude = str2double(Latitude{1}) + str2double(Latitude{2})/60;
                    if strcmp(Latitude{3}, 'S'); gps.Latitude = -gps.Latitude;
                    end

                    Longitude     = strsplit(gpsStr{2}, ' ');
                    gps.Longitude = str2double(Longitude{1}) + str2double(Longitude{2})/60;
                    if strcmp(Longitude{3}, 'W'); gps.Longitude = -gps.Longitude;
                    end

                    gps.TimeStamp = datestr(datetime(gpsStr{4}(1:end-1), "InputFormat", "yyyy-MM-dd HH:mm:ss"), 'dd/mm/yyyy HH:MM:SS');
                end


            %-------------------------------------------------------------%
            % ## TEKTRONIX SA2500 ##
            % Requisição: ':SYSTem:GPS:POSition?'
            % Resposta  : string vazia ''NAN,NAN" (não há conectividade); ou string com o template '45.4992483333333,-122.82315' (informação válida)
            %-------------------------------------------------------------%
            elseif contains(receiverId, 'SA2500')
                gpsStr = regexp(deblank(writeread(receiverHandle, ':SYSTem:GPS:STATus?;:SYSTem:GPS:POSition?')), '(?<status>\w+);(?<lat>[0-9.-]+),(?<lng>[0-9.-]+)', 'names');

                if ~isempty(gpsStr) && ismember(gpsStr.status, ["GOOD", "FAIR"])
                    gps.Status    = 1;
                    gps.Latitude  = str2double(gpsStr.lat);
                    gps.Longitude = str2double(gpsStr.lng);
                end
            end
        end

        %-----------------------------------------------------------------%
        function gps = queryExternalGPS(gps, gpsHandle)
            lastwarn('')

            gpsTic = tic;
            t = toc(gpsTic);

            while t < model.GPS.TIMEOUT
                data = char(deblank(readline(gpsHandle)));

                [warnMsg, warnId] = lastwarn;
                if isempty(data) && strcmp(warnId, 'serialport:serialport:ReadlineWarning')
                    error(warnId, warnMsg)
                end

                if ~isempty(data) && contains(data, 'RMC')
                    checksum = model.GPS.computeNMEAChecksum(data);
                    if ~strcmpi(data(end-1:end), checksum)
                        warning('CheckSum error')
                        continue
                    end
                    data = strsplit(data, ',', 'CollapseDelimiters', false);

                    if strcmp(data{3}, 'A')
                        gps.Status = 1;
                    else
                        gps.Status = 0; 
                        continue
                    end

                    lat = regexp(data{4}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');
                    lng = regexp(data{6}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');

                    if isempty(lat) || isempty(lng)
                        continue
                    end

                    gps.Latitude = str2double(lat.hours) + str2double(lat.minutes) / 60;
                    if strcmp(data{5}, 'S')
                        gps.Latitude = -gps.Latitude;
                    end

                    gps.Longitude = str2double(lng.hours) + str2double(lng.minutes) / 60;
                    if strcmp(data{7}, 'W')
                        gps.Longitude = -gps.Longitude;
                    end

                    if contains(data{2}, '.')
                        dataFormat = ['HHmmss.' repmat('S', 1, numel(extractAfter(data{2}, '.'))) ' ddMMyy'];
                    else
                        dataFormat = 'HHmmss ddMMyy';
                    end
                    gps.TimeStamp = datestr(datetime([data{2} ' ' data{10}], 'InputFormat', dataFormat), 'dd/mm/yyyy HH:MM:SS');

                    break

                elseif contains(data, 'GGA')
                    checksum = model.GPS.computeNMEAChecksum(data);
                    if ~strcmpi(data(end-1:end), checksum)
                        warning('CheckSum error')
                        continue
                    end
                    data = strsplit(data, ',', 'CollapseDelimiters', false);

                    if str2double(data{7})
                        gps.Status = 1;
                    else
                        gps.Status = 0; 
                        continue
                    end

                    lat = regexp(data{3}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');
                    lng = regexp(data{5}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');

                    if isempty(lat) || isempty(lng)
                        continue
                    end

                    gps.Latitude = str2double(lat.hours) + str2double(lat.minutes) / 60;
                    if strcmp(data{4}, 'S')
                        gps.Latitude = -gps.Latitude;
                    end

                    gps.Longitude = str2double(lng.hours) + str2double(lng.minutes) / 60;
                    if strcmp(data{6}, 'W')
                        gps.Longitude = -gps.Longitude;
                    end

                    break

                end
                t = toc(gpsTic);
            end
        end

        %-----------------------------------------------------------------%
        function checksum = computeNMEAChecksum(nmeaData)
            nmeaData = char(extractBetween(nmeaData, '$', '*'));

            checksum = uint8(0);
            for ii = 1:numel(nmeaData)
                checksum = bitxor(checksum, uint8(nmeaData(ii)));
            end

            checksum = dec2hex(checksum);
            if isscalar(checksum)
                checksum = ['0' checksum];
            end
        end
    end
end