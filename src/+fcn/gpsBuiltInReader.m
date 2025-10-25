function gps = gpsBuiltInReader(hReceiver)

    gps  = struct('Status',     0, ...
                  'Latitude',  -1, ...
                  'Longitude', -1, ...
                  'TimeStamp', '');

    Node = hReceiver.UserData.IDN;
    flush(hReceiver)

    %---------------------------------------------------------------------%
    % R&S EB500
    %---------------------------------------------------------------------%
    % Requisição: ':SYSTem:GPS:DATA?'
    % Resposta  : string vazia '' (não há conectividade); ou string com o template 'GPS,1,1629933835,74,11,S,18,53,19.70,W,48,13,50.99,2021,8,25,23,23,55,0.00,0.00,338.50,940.00,1,-8.00'
    if contains(Node, 'EB500')
        gpsStr = deblank(writeread(hReceiver, ':SYSTem:GPS:DATA?'));
        
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


    %---------------------------------------------------------------------%
    % ANRITSU MS2720T
    %---------------------------------------------------------------------%
    % Requisição: ':FETCh:GPS?'
    % Reposta   : Uma string vazia '' (não há conectividade); string 'NO FIX' (informação inválida); ou string com o template 'GOOD FIX,WED AUG 25 23:10:29 2021,-0.2267732173,-0.6713082194' (informação válida)
    elseif contains(Node, 'MS2720T')
        gpsStr = deblank(writeread(hReceiver, ':FETCh:GPS?'));
        
        if ~isempty(gpsStr) && contains(gpsStr, 'GOOD FIX')
            gpsStr = strsplit(gpsStr, ',');
            
            gps.Status    = 1;
            gps.Latitude  = str2double(gpsStr{3})*180/pi;
            gps.Longitude = str2double(gpsStr{4})*180/pi;            
            gps.TimeStamp = datestr(datetime(gpsStr{2}, "InputFormat", "eee MMM dd HH:mm:ss yyyy"), 'dd/mm/yyyy HH:MM:SS');
        end  


    %---------------------------------------------------------------------%
    % KEYSIGHT N9344C
    %---------------------------------------------------------------------%
    % Requisição: ':SYSTem:GPSinfo?'
    % Resposta  : string vazia '' (não há conectividade); string com o template '-38.463093,-12.993198,40,08252021,21:11:50' (informação válida); ou string '0.000000,0.000000,0,02152009,00:12:19' (informação inválida)
    elseif contains(Node, 'N9344C')
        gpsStr = deblank(writeread(hReceiver, ':SYSTem:GPSinfo?'));
        
        if ~isempty(gpsStr) && ~contains(gpsStr, '0.000000')
            gpsStr = strsplit(gpsStr, ',');
            
            gps.Status    = 1;
            gps.Latitude  = str2double(gpsStr{2});
            gps.Longitude = str2double(gpsStr{1});            
            gps.TimeStamp = datestr(datetime(sprintf('%s %s', gpsStr{4}, gpsStr{5}), "InputFormat", "MMddyyyy HH:mm:ss"), 'dd/mm/yyyy HH:MM:SS');
        end


    %---------------------------------------------------------------------%
    % KEYSIGHT N9936B
    %---------------------------------------------------------------------%
    % Requisição: ':SYSTem:GPS:DATA?'
    % Resposta  : string vazia '' (não há conectividade); string com o template '"12 51.63421 S,38 18.50857 W,26,2021-08-27 19:29:34Z"' (informação válida); ou string '"0,0,0,2021-08-27 19:33:18Z"' (informação inválida)
    elseif contains(Node, 'N9936B')
        gpsStr = extractBetween(deblank(writeread(hReceiver, ':SYSTem:GPS:DATA?')), '"', '"');
        
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


    %---------------------------------------------------------------------%
    % TEKTRONIX SA2500
    %---------------------------------------------------------------------%
    % Requisição: ':SYSTem:GPS:POSition?'
    % Resposta  : string vazia ''NAN,NAN" (não há conectividade); ou string com o template '45.4992483333333,-122.82315' (informação válida)
    elseif contains(Node, 'SA2500')
        gpsStr = regexp(deblank(writeread(hReceiver, ':SYSTem:GPS:STATus?;:SYSTem:GPS:POSition?')), '(?<status>\w+);(?<lat>[0-9.-]+),(?<long>[0-9.-]+)', 'names');
        
        if ~isempty(gpsStr) && ismember(gpsStr.status, ["GOOD", "FAIR"])
            gps.Status    = 1;
            gps.Latitude  = str2double(gpsStr.lat);
            gps.Longitude = str2double(gpsStr.long);
        end
    end
end