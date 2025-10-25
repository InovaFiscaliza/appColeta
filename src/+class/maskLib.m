classdef (Abstract) maskLib

    methods (Static = true)
        function maskInfo = FileRead(maskFile)
            maskText = fileread(maskFile);
                
            maskInfo.Table           = struct2table(regexp(maskText, '(?<FreqStart>\d*),(?<FreqStop>\d*),(?<THR>[-]{0,1}\d*)', 'names'));
            maskInfo.Table.FreqStart = str2double(maskInfo.Table.FreqStart) / 1e+3;
            maskInfo.Table.FreqStop  = str2double(maskInfo.Table.FreqStop)  / 1e+3;
            maskInfo.Table.THR       = str2double(maskInfo.Table.THR);
        
            maskInfo.THR       = maskInfo.Table.THR;
            maskInfo.FreqStart = maskInfo.Table.FreqStart(1);
            maskInfo.FreqStop  = maskInfo.Table.FreqStop(end);
        
            maskInfo.unmasked  = table('Size', [height(maskInfo.Table)-1, 3],         ...
                                       'VariableTypes', {'double', 'double', 'cell'}, ...
                                       'VariableNames', {'Frequency', 'BW', 'Source'});
        
            maskInfo.unmasked.BW(:)        = maskInfo.Table.FreqStart(2:end)  - maskInfo.Table.FreqStop(1:end-1);
            maskInfo.unmasked.Frequency(:) = maskInfo.Table.FreqStop(1:end-1) + maskInfo.unmasked.BW/2;
            maskInfo.unmasked.Source(:)    = {'refMask'};        
        end


        %-----------------------------------------------------------------%
        function maskArray = ArrayConstructor(maskInfo, Band)
            maskArray = ones(1, Band.instrDataPoints) * 1e+3;
            freqArray = linspace(Band.FreqStart /1e+6, Band.FreqStop / 1e+6, Band.instrDataPoints);
            maskTable = class.maskLib.TableConstructor(maskInfo);
            
            for ii = 1:height(maskTable)
                maskArray(freqArray >= maskTable(ii,1) & freqArray <= maskTable(ii,2)) = maskTable(ii,3);
            end             
        end
        

        %-----------------------------------------------------------------%
        function maskTable = TableConstructor(maskInfo)            
            if isempty(maskInfo.unmasked)
                if isempty(maskInfo.THR)
                    maskTable = [];
                else
                    maskTable = [maskInfo.FreqStart, maskInfo.FreqStop, maskInfo.THR];
                end                
            else
                FreqStart = [maskInfo.FreqStart; maskInfo.unmasked.Frequency + ceil(maskInfo.unmasked.BW/2)];
                FreqStop  = [maskInfo.unmasked.Frequency - ceil(maskInfo.unmasked.BW/2); maskInfo.FreqStop];
                maskTable = [FreqStart, FreqStop, maskInfo.THR];
            end            
        end
    end

end