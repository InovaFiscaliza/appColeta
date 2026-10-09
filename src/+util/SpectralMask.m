classdef (Abstract) SpectralMask

    % Essa classe abstrata reúne a leitura de arquivos de máscara espectral
    % e a construção da máscara (vetor de limiares) usada pelo
    % model.TaskController. Substitui a antiga "class.maskLib".

    methods (Static = true)
        %-----------------------------------------------------------------%
        function maskInfo = readMaskFile(maskFile)
            maskText = fileread(maskFile);
                
            maskInfo.Table                   = struct2table(regexp(maskText, '(?<startFrequencyMHz>\d*),(?<stopFrequencyMHz>\d*),(?<threshold>[-]{0,1}\d*)', 'names'));
            maskInfo.Table.startFrequencyMHz = str2double(maskInfo.Table.startFrequencyMHz) / 1e+3;
            maskInfo.Table.stopFrequencyMHz  = str2double(maskInfo.Table.stopFrequencyMHz)  / 1e+3;
            maskInfo.Table.threshold         = str2double(maskInfo.Table.threshold);
        
            maskInfo.THR       = maskInfo.Table.threshold;
            maskInfo.FreqStart = maskInfo.Table.startFrequencyMHz(1);
            maskInfo.FreqStop  = maskInfo.Table.stopFrequencyMHz(end);
        
            maskInfo.unmasked  = table('Size', [height(maskInfo.Table)-1, 3],         ...
                                       'VariableTypes', {'double', 'double', 'cell'}, ...
                                       'VariableNames', {'Frequency', 'BW', 'Source'});
        
            maskInfo.unmasked.BW(:)        = maskInfo.Table.startFrequencyMHz(2:end)  - maskInfo.Table.stopFrequencyMHz(1:end-1);
            maskInfo.unmasked.Frequency(:) = maskInfo.Table.stopFrequencyMHz(1:end-1) + maskInfo.unmasked.BW/2;
            maskInfo.unmasked.Source(:)    = {'refMask'};        
        end

        %-----------------------------------------------------------------%
        function maskArray = buildMaskArray(maskInfo, Band)
            maskArray = ones(1, Band.instrDataPoints) * 1e+3;
            freqArray = linspace(Band.FreqStart /1e+6, Band.FreqStop / 1e+6, Band.instrDataPoints);
            maskTable = util.SpectralMask.buildMaskTable(maskInfo);
            
            for ii = 1:height(maskTable)
                maskArray(freqArray >= maskTable(ii,1) & freqArray <= maskTable(ii,2)) = maskTable(ii,3);
            end             
        end

        %-----------------------------------------------------------------%
        function maskTable = buildMaskTable(maskInfo)            
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
