function gps = gpsExternalReader(hGPS, Timeout)

    arguments
        hGPS
        Timeout = class.Constants.gpsTimeout
    end
    
    gps  = struct('Status',     0, ...
                  'Latitude',  -1, ...
                  'Longitude', -1, ...
                  'TimeStamp', '');

    flush(hGPS)
    lastwarn('')
    
    gpsTic = tic;
    t = toc(gpsTic);
    
    while t < Timeout
        receivedData = char(deblank(readline(hGPS)));
        
        [warnMsg, warnID] = lastwarn;
        if isempty(receivedData) && strcmp(warnID, 'serialport:serialport:ReadlineWarning')
            error(warnID, warnMsg)
        end
        
        if ~isempty(receivedData) && contains(receivedData, 'RMC')
            checksum = Fcn_gpsReader_CheckSum(receivedData);
            if ~strcmpi(receivedData(end-1:end), checksum)
                warning('CheckSum error')
                continue
            end
            receivedData = strsplit(receivedData, ',', 'CollapseDelimiters', false);
            
            if strcmp(receivedData{3}, 'A'); gps.Status = 1;
            else                           ; gps.Status = 0; continue
            end

            lat  = regexp(receivedData{4}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');
            long = regexp(receivedData{6}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');
            
            if isempty(lat) || isempty(long)
                continue
            end

            gps.Latitude = str2double(lat.hours) + str2double(lat.minutes) / 60;
            if strcmp(receivedData{5}, 'S')
                gps.Latitude = -gps.Latitude;
            end
            
            gps.Longitude = str2double(long.hours) + str2double(long.minutes) / 60;
            if strcmp(receivedData{7}, 'W')
                gps.Longitude = -gps.Longitude;
            end
            
            if contains(receivedData{2}, '.')
                dataFormat = ['HHmmss.' repmat('S', 1, numel(extractAfter(receivedData{2}, '.'))) ' ddMMyy'];
            else
                dataFormat = 'HHmmss ddMMyy';
            end
            gps.TimeStamp = datestr(datetime([receivedData{2} ' ' receivedData{10}], 'InputFormat', dataFormat), 'dd/mm/yyyy HH:MM:SS');
            
            break
            
        elseif contains(receivedData, 'GGA')
            checksum = Fcn_gpsReader_CheckSum(receivedData);
            if ~strcmpi(receivedData(end-1:end), checksum)
                warning('CheckSum error')
                continue
            end
            receivedData = strsplit(receivedData, ',', 'CollapseDelimiters', false);
            
            if str2double(receivedData{7}); gps.Status = 1;
            else                          ; gps.Status = 0; continue
            end

            lat  = regexp(receivedData{3}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');
            long = regexp(receivedData{5}, '(?<hours>\d{2,3})(?<minutes>\d{2}.\d+)', 'names');
            
            if isempty(lat) || isempty(long)
                continue
            end

            gps.Latitude = str2double(lat.hours) + str2double(lat.minutes) / 60;
            if strcmp(receivedData{4}, 'S')
                gps.Latitude = -gps.Latitude;
            end
            
            gps.Longitude = str2double(long.hours) + str2double(long.minutes) / 60;
            if strcmp(receivedData{6}, 'W')
                gps.Longitude = -gps.Longitude;
            end

            break
            
        end
        t = toc(gpsTic);
    end    
end


%-------------------------------------------------------------------------%
function checksum = Fcn_gpsReader_CheckSum(nmeaData)
    
    nmeaData = char(extractBetween(nmeaData, '$', '*'));
    
    checksum = uint8(0);
    for ii = 1:numel(nmeaData)
        checksum = bitxor(checksum, uint8(nmeaData(ii)));
    end
    
    checksum = dec2hex(checksum);
    if numel(checksum) == 1
        checksum = ['0' checksum];
    end    
end