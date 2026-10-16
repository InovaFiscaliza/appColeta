classdef RFlookBinLib

    % Trata-se de classe que centraliza as operações de escrita em arquivos
    % binários de varredura de espectro.
    %
    % Formatos:
    % • RFlookBin v.1 (v.1/1): arquivo com espaço pré-alocado para as 
    %   varreduras, escrito por mapeamento em memória (memmapfile). Ao 
    %   fechar, se o arquivo não foi totalmente preenchido, ele é truncado.
    %
    % • RFlookBin v.2: cabeçalho com metadados em JSON, seguido de blocos de 
    %   varredura delimitados por "StArT" e "StOp", anexados sequencialmente 
    %   e com o espectro compactado (GZIP). Os formatos 2/1 e 2/2 são muito 
    %   parecidos com os 2/3 e 2/4, diferindo apenas no que é compactado:
    %   ◦ 2/1 e 2/2: ByteStream (o vetor descompactado já tem o tipo do nível).
    %   ◦ 2/3 e 2/4: vetor em bytes (typecast para uint8).
    %   Os formatos 2/1 e 2/3 armazenam apenas o nível; 2/2 e 2/4 armazenam
    %   também azimute e nota de qualidade.
    %
    % Atualmente, o formato padrão do appColeta é 2/3 e 2/4. 
    % 
    % O leitor de todas essas versões do "RFlookBin" é conduzido pelos arquivos 
    % "RFlookBinV1.m" e "RFlookBinV2.m" (ambos do repositório "SupportPackages").

	methods(Static = true)
        %-----------------------------------------------------------------%
        function [fileCount, currentFile] = OpenFile(specObj, bandIdx, userPath)
            baseName = specObj.Bands(bandIdx).OutputFile.Basename;
            fileCount = specObj.Bands(bandIdx).OutputFile.Filecount+1;
            fileID = [];
            memoryMap = [];
            allocatedSamples = 0;

            switch specObj.Bands(bandIdx).OutputFile.Fileversion
                case 'RFlookBin v.1'
                    fileName = fullfile(userPath, sprintf('~%s_%.0f.bin', baseName, fileCount));
                    fileID   = fopen(fileName, 'w');

                    allocatedSamples    = class.RFlookBinLib.writeHeaderV1(fileID, specObj, bandIdx);
                    [metadataOffset, spectrumOffset] = class.RFlookBinLib.preallocateBodyV1(fileID, specObj, bandIdx, allocatedSamples);

                    fclose(fileID);
                    fileID = [];

                    memoryMap = class.RFlookBinLib.createMemoryMapV1(fileName, specObj, bandIdx, allocatedSamples, metadataOffset, spectrumOffset);
        
                case 'RFlookBin v.2'
                    fileName = fullfile(userPath, sprintf('%s_%.0f.bin', baseName, fileCount));
                    fileID   = fopen(fileName, 'w');
                    
                    class.RFlookBinLib.writeHeaderV2(fileID, specObj, bandIdx)
            end

            currentFile = struct('FullPath', fileName, 'AlocatedSamples', allocatedSamples, 'Handle', fileID, 'MemMap', {memoryMap});
        end

        %-----------------------------------------------------------------%
        function specObj = CloseFile(specObj, bandIdx)
            if isempty(specObj.Bands(bandIdx).OutputFile.CurrentFile)
                return
            end
            
            switch specObj.Bands(bandIdx).OutputFile.Fileversion
                case 'RFlookBin v.1'
                    allocatedSamples = specObj.Bands(bandIdx).OutputFile.CurrentFile.AlocatedSamples;
                    writtenSamples   = specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{1}.Data.Value;

                    if allocatedSamples == writtenSamples
                        class.RFlookBinLib.finalizeFileV1(specObj, bandIdx, 'FullFile');
                    else
                        class.RFlookBinLib.finalizeFileV1(specObj, bandIdx, 'ObservationTime');
                    end
        
                case 'RFlookBin v.2'
                    fileID = specObj.Bands(bandIdx).OutputFile.CurrentFile.Handle;
                    fclose(fileID);
            end

            specObj.Bands(bandIdx).OutputFile.CurrentFile = [];
        end

        %-----------------------------------------------------------------%
        function specObj = CheckFile(specObj, bandIdx, userPath)
            if isempty(specObj.Bands(bandIdx).OutputFile.CurrentFile)
                return
            end

            switch specObj.Bands(bandIdx).OutputFile.Fileversion
                case 'RFlookBin v.1'
                    allocatedSamples = specObj.Bands(bandIdx).OutputFile.CurrentFile.AlocatedSamples;
                    writtenSamples   = specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{1}.Data.Value;
        
                    if allocatedSamples == writtenSamples
                        class.RFlookBinLib.finalizeFileV1(specObj, bandIdx, 'FullFile');

                        [specObj.Bands(bandIdx).OutputFile.Filecount, ...
                            specObj.Bands(bandIdx).OutputFile.CurrentFile] = class.RFlookBinLib.OpenFile(specObj, bandIdx, userPath);
                    end
        
                case 'RFlookBin v.2'
                    fileID = specObj.Bands(bandIdx).OutputFile.CurrentFile.Handle;

                    if ftell(fileID) > class.Constants.fileMaxSize
                        fclose(fileID);

                        [specObj.Bands(bandIdx).OutputFile.Filecount, ...
                            specObj.Bands(bandIdx).OutputFile.CurrentFile] = class.RFlookBinLib.OpenFile(specObj, bandIdx, userPath);
                    end
            end
        end

        %-----------------------------------------------------------------%
        function EditFile(specObj, bandIdx, rawArray, attFactor, acquiredAt)
            if isempty(specObj.Bands(bandIdx).OutputFile.CurrentFile)
                return
            end

            gpsData = specObj.GPSLastFix;
            switch specObj.Bands(bandIdx).OutputFile.Fileversion
                case 'RFlookBin v.1'
                    class.RFlookBinLib.writeSampleV1(specObj, bandIdx, rawArray, attFactor, gpsData, acquiredAt)

                case 'RFlookBin v.2'
                    class.RFlookBinLib.writeSampleV2(specObj, bandIdx, rawArray, attFactor, gpsData, acquiredAt)
            end
        end
    end


    methods (Static = true, Access = private)
        %-----------------------------------------------------------------%
        % ## RFlookBin v.1 ##
        %-----------------------------------------------------------------%
        function allocatedSamples = writeHeaderV1(fileID, specObj, bandIdx)
            script = specObj.TaskSpec.Script;
            band = script.Band(bandIdx);
            bitsPerSample = script.BitsPerSample;
            dataPoints = band.instrDataPoints;

            if strcmp(script.Observation.Type, 'Samples')
                allocatedSamples = min([band.instrObservationSamples, ceil(class.Constants.fileMaxSize ./ (bitsPerSample * dataPoints))]);
            else
                allocatedSamples = ceil(class.Constants.fileMaxSize ./ (bitsPerSample * dataPoints));
            end
        
            fwrite(fileID, 'RFlookBin v.1/1', 'char*1');
            fwrite(fileID, bitsPerSample);
            fwrite(fileID, allocatedSamples, 'uint32');
            fwrite(fileID, 0, 'uint32');
        
            % RECEIVER
            resolutionHz = str2double(extractBefore(band.instrResolution, ' kHz')) * 1000;
            traceModeId  = class.RFlookBinLib.labelToId('TraceMode',   band.TraceMode);
            detectorId   = class.RFlookBinLib.labelToId('Detector',    band.instrDetector);
            levelUnitId  = class.RFlookBinLib.labelToId('LevelUnit',   band.instrLevelUnit);
            preampId     = class.RFlookBinLib.labelToId('Preamp',      band.instrPreamp);
            attModeId    = class.RFlookBinLib.labelToId('Attenuation', band.instrAttMode);
        
            fwrite(fileID, band.FreqStart, 'single');
            fwrite(fileID, band.FreqStop, 'single');
            fwrite(fileID, resolutionHz, 'single');
            fwrite(fileID, dataPoints, 'uint16'); % Sweep Points (0-65535 pontos)
            fwrite(fileID, traceModeId, 'int8');
            fwrite(fileID, detectorId, 'int8');
            fwrite(fileID, levelUnitId, 'int8');
            fwrite(fileID, preampId, 'int8');
            fwrite(fileID, attModeId, 'int8');
        
            if attModeId
                attFactor = -1;
            else
                attFactor = str2double(extractBefore(band.instrAttFactor, ' dB'));
            end
            fwrite(fileID, attFactor, 'int8');
        
            fwrite(fileID, -1, 'single'); % SampleTimeValue
            fwrite(fileID, zeros(1, 2)); % Alignment
        
            % GPS
            switch script.GPS.Type
                case 'Manual'
                    gpsInfo = struct('Type', 0, 'Status',  -1, 'Latitude', script.GPS.Latitude, 'Longitude', script.GPS.Longitude);
        
                otherwise
                    switch script.GPS.Type
                        case 'Built-in'
                            gpsType = 1;
                        case 'External'
                            gpsType = 2;
                    end
        
                    gpsInfo = struct('Type', gpsType, 'Status', 0, 'Latitude', -1, 'Longitude', -1);
            end
        
            fwrite(fileID, gpsInfo.Type);
            fwrite(fileID, gpsInfo.Status, 'int8');
            fwrite(fileID, gpsInfo.Latitude, 'single');
            fwrite(fileID, gpsInfo.Longitude, 'single');
            fwrite(fileID, -ones(1,6), 'int8');
            fwrite(fileID, -1, 'int16');        
        end

        %-----------------------------------------------------------------%
        function [metadataOffset, spectrumOffset] = preallocateBodyV1(fileID, specObj, bandIdx, allocatedSamples)        
            script = specObj.TaskSpec.Script;
            band = script.Band(bandIdx);
            bitsPerSample = script.BitsPerSample;
            dataPoints = band.instrDataPoints;
            receiverIdn = specObj.Connections.receiver.UserData.IDN;
            
            metadataOffset = ftell(fileID) + 12;
            spectrumOffset = metadataOffset + 20*allocatedSamples;
            trailerOffset  = spectrumOffset + bitsPerSample * dataPoints * allocatedSamples;
        
            fwrite(fileID, metadataOffset, 'uint32');
            fwrite(fileID, spectrumOffset, 'uint32');
            fwrite(fileID, trailerOffset,  'uint32');
        
            fwrite(fileID, zeros(1, (20 + bitsPerSample * dataPoints) * allocatedSamples, 'uint8'));
            fwrite(fileID, jsonencode(struct( ...
                'TaskName', replace(script.Name, {'"', ',', newline}, ''), ...
                'ThreadID', band.ID, ...
                'Description', replace(band.Description, {'"', ',', newline}, ''), ...
                'Node', receiverIdn, ...
                'Antenna', specObj.Bands(bandIdx).Antenna, ...
                'IntegrationFactor', band.IntegrationFactor, ...
                'RevisitTime', band.RevisitTime ...
            )), 'char*1');
        end
        
        %-----------------------------------------------------------------%
        function memoryMap = createMemoryMapV1(fileName, specObj, bandIdx, allocatedSamples, metadataOffset, spectrumOffset)        
            script = specObj.TaskSpec.Script;
            dataPoints = script.Band(bandIdx).instrDataPoints;
        
            switch script.BitsPerSample
                case  8
                    dataFormat = 'uint8';
                case 16
                    dataFormat = 'int16';
                case 32
                    dataFormat = 'single';
            end
        
            % writtenSamples
            memoryMap{1} = memmapfile(fileName, 'Writable', true, ...
                                                'Offset',   20, ...
                                                'Format',   {'uint32', 1, 'Value'}, ...
                                                'Repeat',   1);
            % GPS/TimeStamp Block
            memoryMap{2} = memmapfile(fileName, 'Writable', true, ...
                                                'Offset',   metadataOffset, ...
                                                'Format', {'int8',   [1  6], 'localTimeStamp'; ...
                                                           'int16',  [1  1], 'localTimeStamp_ms'; ...
                                                           'int16',  [1  1], 'RefLevel'; ...
                                                           'int8',   [1  1], 'attFactor'; ...
                                                           'uint8',  [1  1], 'gpsStatus'; ...
                                                           'single', [1  1], 'Latitude'; ...
                                                           'single', [1  1], 'Longitude'}, ...
                                                'Repeat',   allocatedSamples);
            % Spectral Block
            memoryMap{3} = memmapfile(fileName, 'Writable', true, ...
                                                'Offset',   spectrumOffset, ...
                                                'Format',   {dataFormat, [dataPoints, allocatedSamples], 'Array'}, ...
                                                'Repeat',   1);        
        end

        %-----------------------------------------------------------------%
        function writeSampleV1(specObj, bandIdx, rawArray, attFactor, gpsData, acquiredAt)
            [processedArray, refLevel] = class.RFlookBinLib.rawToProcessedArray(rawArray, specObj.TaskSpec.Script.BitsPerSample);

            sampleIdx = specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{1}.Data.Value + 1;

            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{1}.Data.Value = sampleIdx;

            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{2}.Data(sampleIdx).localTimeStamp    = int8([year(acquiredAt)-2000, month(acquiredAt), day(acquiredAt), hour(acquiredAt), minute(acquiredAt), fix(second(acquiredAt))]);
            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{2}.Data(sampleIdx).localTimeStamp_ms = int16((second(acquiredAt) - fix(second(acquiredAt))).*1000);

            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{2}.Data(sampleIdx).RefLevel  = int16(refLevel);
            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{2}.Data(sampleIdx).attFactor = int8(attFactor);

            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{2}.Data(sampleIdx).gpsStatus = uint8(gpsData.Status);
            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{2}.Data(sampleIdx).Latitude  = single(gpsData.Latitude);
            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{2}.Data(sampleIdx).Longitude = single(gpsData.Longitude);

            specObj.Bands(bandIdx).OutputFile.CurrentFile.MemMap{3}.Data.Array(:,sampleIdx)   = processedArray;        
        end

        %-----------------------------------------------------------------%
        function finalizeFileV1(specObj, bandIdx, finalizeMode)
            fileFullPath = specObj.Bands(bandIdx).OutputFile.CurrentFile.FullPath;

            [filePath, baseName, extension] = fileparts(fileFullPath);
            fileName = [baseName, extension];

            switch finalizeMode
                case 'FullFile'
                    system(sprintf('rename "%s" "%s"', fileFullPath, replace(fileName, '~', '')));

                case 'ObservationTime'
                    tempFileId = fopen(fileFullPath, 'r');
                    fileBytes  = fread(tempFileId, [1, inf], 'uint8=>uint8');
                    fclose(tempFileId);
    
                    bitsPerSample  = double(fileBytes(16));
                    writtenSamples = double(typecast(fileBytes(21:24), 'uint32'));
                    dataPoints     = double(typecast(fileBytes(37:38), 'uint16'));
    
                    oldSpectrumOffset = double(typecast(fileBytes(73:76), 'uint32'));
                    oldTrailerOffset  = double(typecast(fileBytes(77:80), 'uint32'));
    
                    spectrumOffset = 80 + 20*writtenSamples;
                    trailerOffset  = spectrumOffset + (bitsPerSample/8) * dataPoints * writtenSamples;
    
                    fileBytes(17:20) = typecast(uint32(writtenSamples), 'uint8');
                    fileBytes(73:76) = typecast(uint32(spectrumOffset), 'uint8');
                    fileBytes(77:80) = typecast(uint32(trailerOffset),  'uint8');
    
                    spectrumTrimStart = oldSpectrumOffset + (bitsPerSample/8) * dataPoints * writtenSamples + 1;
                    metadataTrimStart = spectrumOffset + 1;
                    
                    fileBytes(spectrumTrimStart:oldTrailerOffset)   = [];
                    fileBytes(metadataTrimStart:oldSpectrumOffset) = [];
    
                    finalFileId = fopen(fullfile(filePath, replace(fileName, '~', '')), 'w');
                    fwrite(finalFileId, fileBytes);
                    fclose(finalFileId);
    
                    system(sprintf('del "%s"', fileFullPath));
            end
        end

        %-----------------------------------------------------------------%
        % ## RFlookBin v.2/3 e RFlookBin v.2/4 ##
        %-----------------------------------------------------------------%
        function writeHeaderV2(fileID, specObj, bandIdx)
            script = specObj.TaskSpec.Script;
            band = script.Band(bandIdx);
            
            if ~isempty(band.instrVBW)
                vbw = band.instrVBW;
            else                           
                vbw = '';
            end
        
            meta = struct( ...
                'Task',             script.Name, ...
                'ID',               band.ID, ...
                'Description',      band.Description, ...
                'FreqStart',        band.FreqStart, ...
                'FreqStop',         band.FreqStop, ...
                'DataPoints',       band.instrDataPoints, ...
                'Resolution',       band.instrResolution, ...
                'VBW',              vbw, ...
                'Preamp',           band.instrPreamp, ...
                'AttMode',          band.instrAttMode, ...
                'AttFactor',        band.instrAttFactor, ...
                'Unit',             band.instrLevelUnit, ...
                'TraceMode',        band.TraceMode, ...
                'TraceIntegration', band.IntegrationFactor, ...
                'Detector',         band.instrDetector, ...
                'RevisitTime',      band.RevisitTime, ...
                'DF_SquelchMode',   band.DF_SquelchMode, ...
                'DF_SquelchValue',  band.DF_SquelchValue, ...
                'DF_MeasTime',      band.DF_MeasTime, ...
                'Receiver',         specObj.Connections.receiver.UserData.IDN, ...
                'AntennaInfo',      specObj.Bands(bandIdx).Antenna, ...
                'GpsType',          script.GPS.Type, ...
                'GpsRevisitTime',   script.GPS.RevisitTime, ...
                'Latitude',         script.GPS.Latitude, ...
                'Longitude',        script.GPS.Longitude ...
            );

            metaFields = fields(meta);
            for fieldIdx = 1:numel(metaFields)
                if isempty(meta.(metaFields{fieldIdx}))
                    meta = rmfield(meta, metaFields{fieldIdx});
                end
            end

            attModeId = class.RFlookBinLib.labelToId('Attenuation', band.instrAttMode);
            if attModeId && isfield(meta, 'AttFactor')
                meta = rmfield(meta, 'AttFactor');
            end
        
            gpsModeId = class.RFlookBinLib.labelToId('GPS', script.GPS.Type);
            if ~gpsModeId && isfield(meta, 'GpsRevisitTime')
                meta = rmfield(meta, 'GpsRevisitTime');
            end

            if ~isempty(specObj.Bands(bandIdx).Mask)
                meta.Mask = jsonencode(struct( ...
                    'status', band.MaskTrigger.Status, ...
                    'configuration', specObj.Bands(bandIdx).Mask.Configuration, ...
                    'table', specObj.Bands(bandIdx).Mask.Table ...
                ));
            end

            % Serializando... struct2json
            metaBytes = unicode2native(jsonencode(meta), 'UTF-8');
        
            if ~contains(specObj.TaskSpec.Type, 'Drive-test (Level+Azimuth)')
                formatName = 'RFlookBin v.2/3';
            else
                formatName = 'RFlookBin v.2/4';
            end

            fwrite(fileID, formatName, 'char*1');
            fwrite(fileID, script.BitsPerSample);
            fwrite(fileID, attModeId);
            fwrite(fileID, gpsModeId);
            fwrite(fileID, numel(metaBytes), 'uint32');
            fwrite(fileID, metaBytes);
        end

        %-----------------------------------------------------------------%
        function writeSampleV2(specObj, bandIdx, rawArray, attFactor, gpsData, acquiredAt)
            script = specObj.TaskSpec.Script;
            band = script.Band(bandIdx);
            bitsPerSample = script.BitsPerSample;

            fileID = specObj.Bands(bandIdx).OutputFile.CurrentFile.Handle;
            
            fwrite(fileID, 'StArT', 'char*1');
            fwrite(fileID, [year(acquiredAt)-2000, month(acquiredAt), day(acquiredAt), hour(acquiredAt), minute(acquiredAt), fix(second(acquiredAt))]);
            fwrite(fileID, (second(acquiredAt) - fix(second(acquiredAt))).*1000, 'uint16');

            if ismember(script.GPS.Type, {'Built-in', 'External'})
                fwrite(fileID, gpsData.Status);
                fwrite(fileID, [gpsData.Latitude, gpsData.Longitude], 'single');
            end
            
            if strcmp(band.instrAttMode, 'Auto')
                fwrite(fileID, attFactor, 'int8');
            end

            [processedArray, refLevel] = class.RFlookBinLib.rawToProcessedArray(rawArray(:,:,1), bitsPerSample);

            [~,~,numChannels] = size(rawArray);
            if numChannels == 3
                dataClass = class(processedArray);
                
                processedArray = { ...
                    processedArray, ... % LEVEL
                    typecast(class.RFlookBinLib.rawToProcessedArray(rawArray(:,:,2), -16), dataClass), ... % AZIMUTH (0-360)
                    typecast(class.RFlookBinLib.rawToProcessedArray(rawArray(:,:,3), -16), dataClass) ... % AZIMUTH QUALITY SCORE (0-100)
                };

                processedArray = horzcat(processedArray{:});
            end            
            
            if bitsPerSample == 8
                fwrite(fileID, refLevel, 'int16');
            end
        
            fwrite(fileID, matlabCommunity.CompressLib.compress(processedArray, false));
            fwrite(fileID, 'StOp', 'char*1');        
        end

        %-----------------------------------------------------------------%
        % ## Auxiliar functions ##
        %-----------------------------------------------------------------%
        function [processedArray, refLevel] = rawToProcessedArray(rawArray, bitsPerSample)
            refLevel = -1;

            switch bitsPerSample
                case  8
                    refLevel = max(rawArray);
                    offset   = -2*refLevel+255;
                    processedArray = uint8(2.*rawArray + offset);                
                case 16
                    processedArray = int16(100.*rawArray);
                case 32
                    processedArray = single(rawArray);
                case -16
                    processedArray = uint16(100.*rawArray);
            end
        end

        %-----------------------------------------------------------------%
        function id = labelToId(category, label)        
            switch category
                case 'TraceMode'
                    switch label
                        case 'ClearWrite'
                            id = 1;
                        case 'Average'
                            id = 2;
                        case 'MaxHold'
                            id = 3;
                        case 'MinHold'
                            id = 4;
                    end
        
                case 'Detector'
                    switch label
                        case 'Sample'
                            id = 1;
                        case 'Average/RMS'
                            id = 2;
                        case 'Positive Peak'
                            id = 3;
                        case 'Negative Peak'
                            id = 4;
                    end
        
                case 'LevelUnit'
                    switch label
                        case 'dBm'
                            id = 1;
                        case {'dBµV', 'dBμV'}
                            id = 2;
                        case {'dBµV/m', 'dBμV/m'}
                            id = 3;
                    end
        
                case 'Preamp'
                    switch label
                        case 'Off'
                            id = 0;
                        case 'On'
                            id = 1;
                    end
        
                case 'Attenuation'
                    switch label
                        case 'Manual'
                            id = 0;
                        case 'Auto'
                            id = 1;
                    end

                case 'GPS'
                    switch label
                        case 'Manual'
                            id = 0;
                        case 'Built-in'
                            id = 1;
                        case 'External'
                            id = 2;
                    end
            end        
        end
    end
end