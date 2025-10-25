classdef RFlookBinLib

    % Author.: Eric Magalhães Delgado
    % Date...: March 21, 2024
    % Version: 1.01

	methods(Static = true)
        %-----------------------------------------------------------------%
        function [fileCount, CurrentFile] = OpenFile(specObj, idx, userPath)
            baseName   = specObj.Band(idx).File.Basename;
            fileCount  = specObj.Band(idx).File.Filecount+1;
            fileID     = [];
            fileMemMap = [];
            AlocatedSamples = 0;

            switch specObj.Band(idx).File.Fileversion
                case 'RFlookBin v.1'
                    fileName = fullfile(userPath, sprintf('~%s_%.0f.bin', baseName, fileCount));
                    fileID   = fopen(fileName, 'w');

                    AlocatedSamples    = class.RFlookBinLib.v1_WriteHeader(fileID, specObj, idx);
                    [Offset1, Offset2] = class.RFlookBinLib.v1_WriteBody(fileID, specObj, idx, AlocatedSamples);

                    fclose(fileID);
                    fileID = [];

                    fileMemMap = class.RFlookBinLib.v1_MemoryMap(fileName, specObj, idx, AlocatedSamples, Offset1, Offset2);
        
                case 'RFlookBin v.2'
                    fileName = fullfile(userPath, sprintf('%s_%.0f.bin', baseName, fileCount));
                    fileID   = fopen(fileName, 'w');
                    
                    class.RFlookBinLib.v2_WriteHeader(fileID, specObj, idx)
            end

            CurrentFile = struct('FullPath',        fileName,        ...
                                 'AlocatedSamples', AlocatedSamples, ...
                                 'Handle',          fileID,          ...
                                 'MemMap',          {fileMemMap});
        end


        %-----------------------------------------------------------------%
        function specObj = CloseFile(specObj, idx)
            switch specObj.Band(idx).File.Fileversion
                case 'RFlookBin v.1'
                    AlocatedSamples = specObj.Band(idx).File.CurrentFile.AlocatedSamples;
                    WritedSamples   = specObj.Band(idx).File.CurrentFile.MemMap{1}.Data.Value;

                    if AlocatedSamples == WritedSamples
                        class.RFlookBinLib.v1_PostProcessing(specObj, idx, 'FullFile');
                    else
                        class.RFlookBinLib.v1_PostProcessing(specObj, idx, 'ObservationTime');
                    end
        
                case 'RFlookBin v.2'
                    fileID = specObj.Band(idx).File.CurrentFile.Handle;
                    fclose(fileID);
            end

            specObj.Band(idx).File.CurrentFile = [];
        end


        %-----------------------------------------------------------------%
        function specObj = CheckFile(specObj, idx, userPath)
            if isempty(specObj.Band(idx).File.CurrentFile)
                return
            end

            switch specObj.Band(idx).File.Fileversion
                case 'RFlookBin v.1'
                    AlocatedSamples = specObj.Band(idx).File.CurrentFile.AlocatedSamples;
                    WritedSamples   = specObj.Band(idx).File.CurrentFile.MemMap{1}.Data.Value;
        
                    if AlocatedSamples == WritedSamples
                        class.RFlookBinLib.v1_PostProcessing(specObj, idx, 'FullFile');

                        [specObj.Band(idx).File.Filecount, ...
                            specObj.Band(idx).File.CurrentFile] = class.RFlookBinLib.OpenFile(specObj, idx, userPath);
                    end
        
                case 'RFlookBin v.2'
                    fileID = specObj.Band(idx).File.CurrentFile.Handle;

                    if ftell(fileID) > class.Constants.fileMaxSize
                        fclose(fileID);

                        [specObj.Band(idx).File.Filecount, ...
                            specObj.Band(idx).File.CurrentFile] = class.RFlookBinLib.OpenFile(specObj, idx, userPath);
                    end
            end
        end


        %-----------------------------------------------------------------%
        function EditFile(specObj, idx, rawArray, attFactor, TimeStamp)
            if isempty(specObj.Band(idx).File.CurrentFile)
                return
            end

            gpsData = specObj.lastGPS;
            switch specObj.Band(idx).File.Fileversion
                case 'RFlookBin v.1'
                    class.RFlookBinLib.v1_MemoryEdit(specObj, idx, rawArray, attFactor, gpsData, TimeStamp)

                case 'RFlookBin v.2'
                    class.RFlookBinLib.v2_WriteBody(specObj,  idx, rawArray, attFactor, gpsData, TimeStamp)
            end
        end
    end


    methods (Static = true, Access = private)
        %-----------------------------------------------------------------%
        % ## RFlookBin v.1 ##
        %-----------------------------------------------------------------%
        function AlocatedSamples = v1_WriteHeader(fileID, specObj, idx)
            Script          = specObj.Task.Script;
            MetaData        = Script.Band(idx);
            BitsPerSample   = Script.BitsPerSample;
            DataPoints      = MetaData.instrDataPoints;

            if strcmp(specObj.Task.Script.Observation.Type, 'Samples')
                AlocatedSamples = min([specObj.Task.Script.Band(idx).instrObservationSamples, ceil(class.Constants.fileMaxSize ./ (BitsPerSample * DataPoints))]);
            else
                AlocatedSamples = ceil(class.Constants.fileMaxSize ./ (BitsPerSample * DataPoints));
            end
        
            fwrite(fileID, 'RFlookBin v.1/1', 'char*1');
            fwrite(fileID, BitsPerSample);
            fwrite(fileID, AlocatedSamples, 'uint32');
            fwrite(fileID, 0, 'uint32');
        
            % RECEIVER
            Resolution   = str2double(extractBefore(MetaData.instrResolution, ' kHz')) * 1000;
            Trace_ID     = class.RFlookBinLib.str2id('TraceMode',      MetaData.TraceMode);
            Detector_ID  = class.RFlookBinLib.str2id('Detector',       MetaData.instrDetector);
            LevelUnit_ID = class.RFlookBinLib.str2id('LevelUnit',      MetaData.instrLevelUnit);
            Preamp_ID    = class.RFlookBinLib.str2id('Preamp',         MetaData.instrPreamp);
            AttMode_ID   = class.RFlookBinLib.str2id('Attenuation',    MetaData.instrAttMode);
        
            fwrite(fileID, MetaData.FreqStart, 'single');
            fwrite(fileID, MetaData.FreqStop,  'single');
            fwrite(fileID, Resolution,         'single');
            fwrite(fileID, DataPoints, 'uint16');                           % Sweep Points (0-65535 pontos)
            fwrite(fileID, Trace_ID,     'int8');
            fwrite(fileID, Detector_ID,  'int8');
            fwrite(fileID, LevelUnit_ID, 'int8');
            fwrite(fileID, Preamp_ID,    'int8');
            fwrite(fileID, AttMode_ID,   'int8');
        
            if AttMode_ID; attFactor = -1;
            else;          attFactor = str2double(extractBefore(MetaData.instrAttFactor, ' dB'));
            end
            fwrite(fileID, attFactor, 'int8');
        
            fwrite(fileID, -1, 'single');                                   % SampleTimeValue
            fwrite(fileID, zeros(1, 2));                                    % Alignment
        
            % GPS
            switch Script.GPS.Type
                case 'Manual'
                    gpsInfo = struct('Type',       0,                  ...
                                     'Status',    -1,                  ...
                                     'Latitude',  Script.GPS.Latitude, ...
                                     'Longitude', Script.GPS.Longitude);
        
                otherwise
                    switch Script.GPS.Type
                        case 'Built-in'; gpsType = 1;
                        case 'External'; gpsType = 2;
                    end
        
                    gpsInfo = struct('Type',      gpsType, ...
                                     'Status',     0,      ...
                                     'Latitude',  -1,      ...
                                     'Longitude', -1);
            end
        
            fwrite(fileID, gpsInfo.Type);
            fwrite(fileID, gpsInfo.Status,    'int8');
            fwrite(fileID, gpsInfo.Latitude,  'single');
            fwrite(fileID, gpsInfo.Longitude, 'single');
            fwrite(fileID, -ones(1,6),        'int8');
            fwrite(fileID, -1,                'int16');        
        end


        %-----------------------------------------------------------------%
        function [Offset1, Offset2] = v1_WriteBody(fileID, specObj, idx, AlocatedSamples)        
            Script          = specObj.Task.Script;
            MetaData        = Script.Band(idx);
            BitsPerSample   = Script.BitsPerSample;
            DataPoints      = Script.Band(idx).instrDataPoints;
            Node            = specObj.hReceiver.UserData.IDN;
            
            Offset1 = ftell(fileID) + 12;
            Offset2 = Offset1 + 20*AlocatedSamples;
            Offset3 = Offset2 + BitsPerSample * DataPoints * AlocatedSamples;
        
            fwrite(fileID, Offset1, 'uint32');
            fwrite(fileID, Offset2, 'uint32');
            fwrite(fileID, Offset3, 'uint32');
        
            fwrite(fileID, zeros(1, (20 + BitsPerSample * DataPoints) * AlocatedSamples, 'uint8'));
            fwrite(fileID, jsonencode(struct('TaskName',          replace(Script.Name, {'"', ',', newline}, ''),          ...
                                             'ThreadID',          MetaData.ID,                                            ...
                                             'Description',       replace(MetaData.Description, {'"', ',', newline}, ''), ...
                                             'Node',              Node,                                                   ...
                                             'Antenna',           specObj.Band(idx).Antenna,                              ...
                                             'IntegrationFactor', MetaData.IntegrationFactor,                             ...
                                             'RevisitTime',       MetaData.RevisitTime)), 'char*1');        
        end
        
        
        %-----------------------------------------------------------------%
        function fileMemMap = v1_MemoryMap(fileName, specObj, idx, AlocatedSamples, Offset1, Offset2)        
            Script     = specObj.Task.Script;
            DataPoints = Script.Band(idx).instrDataPoints;
        
            switch Script.BitsPerSample
                case  8; dataFormat = 'uint8';
                case 16; dataFormat = 'int16';
                case 32; dataFormat = 'single';
            end
        
            % WritedSamples
            fileMemMap{1} = memmapfile(fileName, 'Writable', true,                   ...
                                                 'Offset',   20,                     ...
                                                 'Format',   {'uint32', 1, 'Value'}, ...
                                                 'Repeat',   1);
            % GPS/TimeStamp Block
            fileMemMap{2} = memmapfile(fileName, 'Writable', true,                                 ...
                                                 'Offset',   Offset1,                              ...
                                                 'Format', {'int8',   [1  6], 'localTimeStamp';    ...
                                                            'int16',  [1  1], 'localTimeStamp_ms'; ...
                                                            'int16',  [1  1], 'RefLevel';          ...
                                                            'int8',   [1  1], 'attFactor';         ...
                                                            'uint8',  [1  1], 'gpsStatus';         ...
                                                            'single', [1  1], 'Latitude';          ...
                                                            'single', [1  1], 'Longitude'},        ...
                                                 'Repeat',   AlocatedSamples);
            % Spectral Block
            fileMemMap{3} = memmapfile(fileName, 'Writable', true,                                                 ...
                                                 'Offset',   Offset2,                                              ...
                                                 'Format',   {dataFormat, [DataPoints, AlocatedSamples], 'Array'}, ...
                                                 'Repeat',   1);        
        end


        %-----------------------------------------------------------------%
        function v1_MemoryEdit(specObj, idx1, rawArray, attFactor, gpsData, TimeStamp)
            [processedArray, RefLevel] = class.RFlookBinLib.raw2processedArray(rawArray, specObj.Task.Script.BitsPerSample);

            idx2 = specObj.Band(idx1).File.CurrentFile.MemMap{1}.Data.Value + 1;

            specObj.Band(idx1).File.CurrentFile.MemMap{1}.Data.Value = idx2;

            specObj.Band(idx1).File.CurrentFile.MemMap{2}.Data(idx2).localTimeStamp    = int8([year(TimeStamp)-2000, month(TimeStamp), day(TimeStamp), hour(TimeStamp), minute(TimeStamp), fix(second(TimeStamp))]);
            specObj.Band(idx1).File.CurrentFile.MemMap{2}.Data(idx2).localTimeStamp_ms = int16((second(TimeStamp) - fix(second(TimeStamp))).*1000);

            specObj.Band(idx1).File.CurrentFile.MemMap{2}.Data(idx2).RefLevel  = int16(RefLevel);
            specObj.Band(idx1).File.CurrentFile.MemMap{2}.Data(idx2).attFactor = int8(attFactor);

            specObj.Band(idx1).File.CurrentFile.MemMap{2}.Data(idx2).gpsStatus = uint8(gpsData.Status);
            specObj.Band(idx1).File.CurrentFile.MemMap{2}.Data(idx2).Latitude  = single(gpsData.Latitude);
            specObj.Band(idx1).File.CurrentFile.MemMap{2}.Data(idx2).Longitude = single(gpsData.Longitude);

            specObj.Band(idx1).File.CurrentFile.MemMap{3}.Data.Array(:,idx2)   = processedArray;        
        end


        %-----------------------------------------------------------------%
        function v1_PostProcessing(specObj, idx, Type)
            fileFullPath = specObj.Band(idx).File.CurrentFile.FullPath;

            [filePath, name, ext] = fileparts(fileFullPath);
            fileName = [name, ext];

            switch Type
                case 'FullFile'
                    system(sprintf('rename "%s" "%s"', fileFullPath, replace(fileName, '~', '')));

                case 'ObservationTime'
                    fileID_temp = fopen(fileFullPath, 'r');
                    tempData    = fread(fileID_temp, [1, inf], 'uint8=>uint8');
                    fclose(fileID_temp);
    
                    BitsPerPoint  = double(tempData(16));
                    WritedSamples = double(typecast(tempData(21:24), 'uint32'));
                    DataPoints    = double(typecast(tempData(37:38), 'uint16'));
    
                    Offset2_old   = double(typecast(tempData(73:76), 'uint32'));
                    Offset3_old   = double(typecast(tempData(77:80), 'uint32'));
    
                    Offset2 = 80 + 20*WritedSamples;
                    Offset3 = Offset2 + (BitsPerPoint/8) * DataPoints * WritedSamples;
    
                    tempData(17:20) = typecast(uint32(WritedSamples), 'uint8');
                    tempData(73:76) = typecast(uint32(Offset2), 'uint8');
                    tempData(77:80) = typecast(uint32(Offset3), 'uint8');
    
                    trimIdx1 = Offset2_old + (BitsPerPoint/8) * DataPoints * WritedSamples + 1;
                    trimIdx2 = Offset2 + 1;
                    
                    tempData(trimIdx1:Offset3_old) = [];
                    tempData(trimIdx2:Offset2_old) = [];
    
                    fileID_new = fopen(fullfile(filePath, replace(fileName, '~', '')), 'w');
                    fwrite(fileID_new, tempData);
                    fclose(fileID_new);
    
                    system(sprintf('del "%s"', fileFullPath));
            end
        end


        %-----------------------------------------------------------------%
        % ## RFlookBin v.2/3 e RFlookBin v.2/4 ##
        %-----------------------------------------------------------------%
        function v2_WriteHeader(fileID, specObj, idx)
            Script        = specObj.Task.Script;
            MetaData      = Script.Band(idx);
            BitsPerSample = Script.BitsPerSample;
            Node          = specObj.hReceiver.UserData.IDN;

            if ~isempty(MetaData.instrVBW)
                instrVBW  = MetaData.instrVBW;
            else                           
                instrVBW  = '';
            end
        
            meta2File     = struct('Receiver',         Node,                       ...
                                   'AntennaInfo',      specObj.Band(idx).Antenna,  ...
                                   'gpsType',          Script.GPS.Type,            ...
                                   'Task',             Script.Name,                ...
                                   'ID',               MetaData.ID,                ...
                                   'Description',      MetaData.Description,       ...
                                   'FreqStart',        MetaData.FreqStart,         ...
                                   'FreqStop',         MetaData.FreqStop,          ...
                                   'DataPoints',       MetaData.instrDataPoints,   ...
                                   'Resolution',       MetaData.instrResolution,   ...
                                   'VBW',              instrVBW,                   ...
                                   'Preamp',           MetaData.instrPreamp,       ...
                                   'AttMode',          MetaData.instrAttMode,      ...
                                   'AttFactor',        MetaData.instrAttFactor,    ...
                                   'Unit',             MetaData.instrLevelUnit,    ...
                                   'TraceMode',        MetaData.TraceMode,         ...
                                   'TraceIntegration', MetaData.IntegrationFactor, ...
                                   'Detector',         MetaData.instrDetector,     ...
                                   'RevisitTime',      MetaData.RevisitTime,       ...
                                   'DF_SquelchMode',   MetaData.DF_SquelchMode,    ...
                                   'DF_SquelchValue',  MetaData.DF_SquelchValue,   ...
                                   'DF_MeasTime',      MetaData.DF_MeasTime);

            metaFields = fields(meta2File);
            for ii = 1:numel(metaFields)
                if isempty(meta2File.(metaFields{ii}))
                    meta2File = rmfield(meta2File, metaFields{ii});
                end
            end

            AttMode_ID = class.RFlookBinLib.str2id('Attenuation', MetaData.instrAttMode);
            if AttMode_ID
                meta2File = rmfield(meta2File, 'AttFactor');
            end
        
            gpsMode_ID = class.RFlookBinLib.str2id('GPS',         Script.GPS.Type);
            if gpsMode_ID
                meta2File.gpsRevisitTime = Script.GPS.RevisitTime;
            else
                meta2File.Latitude  = Script.GPS.Latitude;
                meta2File.Longitude = Script.GPS.Longitude;
            end

            if ~isempty(specObj.Band(idx).Mask)
                meta2File.Mask = jsonencode(struct('Status',    MetaData.MaskTrigger.Status,      ...
                                                   'FindPeaks', specObj.Band(idx).Mask.FindPeaks, ...
                                                   'Table',     specObj.Band(idx).Mask.Table));
            end

            % Serializando... struct2json
            meta2File = unicode2native(jsonencode(meta2File), 'UTF-8');
        
            if ~contains(specObj.Task.Type, 'Drive-test (Level+Azimuth)')
                formatName = 'RFlookBin v.2/3';
            else
                formatName = 'RFlookBin v.2/4';
            end

            fwrite(fileID, formatName, 'char*1');
            fwrite(fileID, BitsPerSample);
            fwrite(fileID, AttMode_ID);
            fwrite(fileID, gpsMode_ID);
            fwrite(fileID, numel(meta2File), 'uint32');
            fwrite(fileID, meta2File);
        end


        %-----------------------------------------------------------------%
        function v2_WriteBody(specObj, idx, rawArray, attFactor, gpsData, TimeStamp)
            Script        = specObj.Task.Script;
            MetaData      = Script.Band(idx);
            BitsPerSample = Script.BitsPerSample;

            fileID        = specObj.Band(idx).File.CurrentFile.Handle;
            
            fwrite(fileID, 'StArT', 'char*1');
            fwrite(fileID, [year(TimeStamp)-2000, month(TimeStamp), day(TimeStamp), hour(TimeStamp), minute(TimeStamp), fix(second(TimeStamp))]);
            fwrite(fileID, (second(TimeStamp) - fix(second(TimeStamp))).*1000, 'uint16');

            if ismember(Script.GPS.Type, {'Built-in', 'External'})
                fwrite(fileID, gpsData.Status);
                fwrite(fileID, [gpsData.Latitude, gpsData.Longitude], 'single');
            end
            
            if strcmp(MetaData.instrAttMode, 'Auto')
                fwrite(fileID, attFactor, 'int8');
            end

            [processedArray, RefLevel] = class.RFlookBinLib.raw2processedArray(rawArray(:,:,1), BitsPerSample);

            [~,~,DD] = size(rawArray);
            if DD == 3
                dataClass         = class(processedArray);
                
                processedArray    = {processedArray};                                                                 % LEVEL
                processedArray{2} = typecast(class.RFlookBinLib.raw2processedArray(rawArray(:,:,2), -16), dataClass); % AZIMUTH (0-360)
                processedArray{3} = typecast(class.RFlookBinLib.raw2processedArray(rawArray(:,:,3), -16), dataClass); % AZIMUTH QUALITY SCORE (0-100)

                processedArray    = horzcat(processedArray{:});
            end            
            
            if BitsPerSample == 8
                fwrite(fileID, RefLevel, 'int16');
            end
        
            fwrite(fileID, matlabCommunity.CompressLib.compress(processedArray, false));            
            fwrite(fileID, 'StOp', 'char*1');        
        end


        %-----------------------------------------------------------------%
        % ## Auxiliar functions ##
        %-----------------------------------------------------------------%
        function [processedArray, RefLevel] = raw2processedArray(rawArray, BitsPerSample)
            switch BitsPerSample
                case  8
                    RefLevel       = max(rawArray);
                    Offset         = -2*RefLevel+255;
                    processedArray = uint8(2.*rawArray + Offset);                
                case 16
                    RefLevel       = -1;
                    processedArray = int16(100.*rawArray);
                case 32
                    RefLevel       = -1;
                    processedArray = single(rawArray);
                case -16
                    RefLevel       = -1;
                    processedArray = uint16(100.*rawArray);
            end
        end


        %-----------------------------------------------------------------%
        function ID = str2id(Type, Value)        
            switch Type
                case 'TraceMode'
                    switch Value
                        case 'ClearWrite'; ID = 1;
                        case 'Average';    ID = 2;
                        case 'MaxHold';    ID = 3;
                        case 'MinHold';    ID = 4;
                    end
        
                case 'Detector'
                    switch Value
                        case 'Sample';        ID = 1;
                        case 'Average/RMS';   ID = 2;
                        case 'Positive Peak'; ID = 3;
                        case 'Negative Peak'; ID = 4;
                    end
        
                case 'LevelUnit'
                    switch Value
                        case 'dBm';                ID = 1;
                        case {'dBµV', 'dBμV'};     ID = 2;
                        case {'dBµV/m', 'dBμV/m'}; ID = 3;
                    end
        
                case 'Preamp'
                    switch Value
                        case 'Off'; ID = 0;
                        case 'On';  ID = 1;
                    end
        
                case 'Attenuation'
                    switch Value
                        case 'Manual'; ID = 0;
                        case 'Auto';   ID = 1;
                    end

                case 'GPS'
                    switch Value
                        case 'Manual';   ID = 0;
                        case 'Built-in'; ID = 1;
                        case 'External'; ID = 2;
                    end
            end        
        end
    end
end