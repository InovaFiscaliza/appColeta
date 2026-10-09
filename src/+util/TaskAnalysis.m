classdef (Abstract) TaskAnalysis

    % Essa classe abstrata reúne cálculos aplicados às tarefas de monitoração
    % (model.Task) executadas pelo model.TaskController.

    methods (Static = true)
        %-----------------------------------------------------------------%
        function revisitInfo = computeRevisitFactors(tasks)
            % Estima, para as tarefas em andamento, o tempo global de revisita
            % (menor tempo entre as bandas) e o fator de revisita de cada banda,
            % sendo o GPS o primeiro elemento de cada lista. O valor -1 sinaliza
            % banda ou GPS sem revisita.

            revisitInfo = struct('GlobalRevisitTime', [],         ...
                                 'Band', struct('RevisitTimes',   [], ...
                                                'RevisitFactors', []));

            allBandTimes = [];
            for taskIdx = 1:numel(tasks)
                if tasks(taskIdx).Status == "Em andamento"
                    gpsRevisitTime = -1;
                    if ~isempty(tasks(taskIdx).TaskSpec.Script.GPS.RevisitTime)
                        gpsRevisitTime = tasks(taskIdx).TaskSpec.Script.GPS.RevisitTime;
                    end

                    bandTimes = [tasks(taskIdx).TaskSpec.Script.Band.RevisitTime];
                    bandTimes(~[tasks(taskIdx).Bands.IsActive]) = -1;

                    revisitInfo.Band(taskIdx) = struct('RevisitTimes',   [gpsRevisitTime, bandTimes], ...
                                                       'RevisitFactors', []);

                    allBandTimes = [allBandTimes, bandTimes]; %#ok<AGROW>
                else
                    revisitInfo.Band(taskIdx) = struct('RevisitTimes',   [], ...
                                                       'RevisitFactors', []);
                end
            end

            revisitInfo.GlobalRevisitTime = min(allBandTimes(allBandTimes ~= -1));

            for taskIdx = 1:numel(tasks)
                if ~isempty(revisitInfo.Band(taskIdx).RevisitTimes)
                    revisitInfo.Band(taskIdx).RevisitFactors = revisitInfo.Band(taskIdx).RevisitTimes;

                    hasRevisit = (revisitInfo.Band(taskIdx).RevisitTimes ~= -1);
                    revisitInfo.Band(taskIdx).RevisitFactors(hasRevisit) = fix(revisitInfo.Band(taskIdx).RevisitTimes(hasRevisit) ./ revisitInfo.GlobalRevisitTime);
                end
            end
        end

        %-----------------------------------------------------------------%
        function peaksTable = findMaskPeaks(task, bandIdx, smoothedTrace, exceedanceMask)
            % Identifica os picos do traço que romperam a máscara espectral
            % ("exceedanceMask"), conforme "Mask.Configuration.peakDetection" da banda.

            peaksTable = [];

            peakAttributes = task.Bands(bandIdx).Mask.Configuration.peakDetection;
            freqStart = task.TaskSpec.Script.Band(bandIdx).FreqStart;
            freqStop  = task.TaskSpec.Script.Band(bandIdx).FreqStop;
            numPoints = numel(smoothedTrace);

            % Frequency = freqStep * Index + freqOffset
            freqStep = (freqStop-freqStart)/(numPoints-1);
            freqOffset = freqStart-freqStep;

            [peakIdxRanges, peakProminences] = matlab.findpeaks(smoothedTrace, 'MinPeakProminence', peakAttributes.minimumProminence, ...
                                                                               'MinPeakDistance',   1000 * peakAttributes.minimumDistanceKHz / freqStep, ...
                                                                               'MinPeakWidth',      1000 * peakAttributes.minimumWidthKHz / freqStep, ...
                                                                               'SortStr',           'descend');

            for peakIdx = height(peakIdxRanges):-1:1
                rangeIdxs = floor(peakIdxRanges(peakIdx,1)):ceil(peakIdxRanges(peakIdx,2));
                if all(~exceedanceMask(rangeIdxs))
                    peakIdxRanges(peakIdx,:) = [];
                    peakProminences(peakIdx) = [];
                end
            end

            if ~isempty(peakIdxRanges)
                peakCenterIdxs = mean(peakIdxRanges, 2);
                peakFreqCenter = (freqStep .* peakCenterIdxs + freqOffset) ./ 1e+6; % Em MHz
                peakWidth = (peakIdxRanges(:,2)-peakIdxRanges(:,1)) * freqStep / 1e+3; % Em kHz

                peaksTable = table( ...
                    round(peakCenterIdxs), round(peakFreqCenter, 3), round(peakWidth, 1), round(peakProminences, 1), ...
                    'VariableNames', {'frequencyBinIndex', 'centerFrequencyMHz', 'bandwidthKHz', 'prominence'} ...
                );
            end
        end
    end
end
