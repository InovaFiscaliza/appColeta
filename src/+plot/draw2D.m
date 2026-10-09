classdef (Abstract) draw2D

    methods (Static = true)
        %-----------------------------------------------------------------%
        function update(hPlot, newArray, generalSettings)
            switch hPlot.Tag
                case {'ClrWrite', 'MaskPlot'}
                    hPlot.YData = newArray;
                case 'MinHold'
                    hPlot.YData = min(hPlot.YData, newArray);
                case 'Average'
                    hPlot.YData = ((generalSettings.context.TASK_VIEW.integration.traceMode-1)*hPlot.YData + newArray) / generalSettings.context.TASK_VIEW.integration.traceMode;
                case 'MaxHold'
                    hPlot.YData = max(hPlot.YData, newArray);
            end
        end

        %-----------------------------------------------------------------%
        function hPlot = clearWrite(hAxes, xArray, newArray, levelUnit, plotTag, generalSettings, varargin)
            hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.plot.clearWrite.Color, 'Tag', plotTag, varargin{:});
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPlot = minHold(hAxes, specObj, jj, xArray, newArray, levelUnit, generalSettings)        
            switch specObj.Status
                case 'Em andamento'
                    hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.plot.minHold.Color, 'Tag', 'MinHold');                    
                otherwise
                    idx = find(all(specObj.Bands(jj).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Bands(jj).Waterfall.Depth+1;
                    end
        
                    hPlot = plot(hAxes, xArray, min(specObj.Bands(jj).Waterfall.Matrix(1:idx-1,:), [], 1), 'Color', generalSettings.plot.minHold.Color, 'Tag', 'MinHold');
            end
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPlot = average(hAxes, specObj, kk, xArray, newArray, levelUnit, generalSettings)        
            switch specObj.Status
                case 'Em andamento'
                    hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.plot.average.Color, 'Tag', 'Average');                    
                otherwise
                    idx = find(all(specObj.Bands(kk).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Bands(kk).Waterfall.Depth+1;
                    end
        
                    hPlot = plot(hAxes, xArray, mean(specObj.Bands(kk).Waterfall.Matrix(1:idx-1,:), 1), 'Color', generalSettings.plot.average.Color, 'Tag', 'Average');
            end
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPlot = maxHold(hAxes, specObj, kk, xArray, newArray, levelUnit, generalSettings)        
            switch specObj.Status
                case 'Em andamento'
                    hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.plot.maxHold.Color, 'Tag', 'MaxHold');                    
                otherwise
                    idx = find(all(specObj.Bands(kk).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Bands(kk).Waterfall.Depth+1;
                    end
        
                    hPlot = plot(hAxes, xArray, max(specObj.Bands(kk).Waterfall.Matrix(1:idx-1,:), [], 1), 'Color', generalSettings.plot.maxHold.Color, 'Tag', 'MaxHold');
            end
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPeak = peakExcursion(hPeak, hClearWrite, specObj, kk, newArray)
            switch specObj.Status
                case 'Em andamento'
                    [~, peakIdx] = max(newArray);                    
                otherwise
                    idx = find(all(specObj.Bands(kk).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Bands(kk).Waterfall.Depth+1;
                    end
        
                    [~, peakIdx] = max(mean(specObj.Bands(kk).Waterfall.Matrix(1:idx-1,:), 1));
            end
        
            if isempty(hPeak) || ~isvalid(hPeak)
                hPeak = datatip(hClearWrite, 'DataIndex', peakIdx, 'Tag', 'PeakExcursion');
            else
                hPeak.DataIndex = peakIdx;
            end
        end

        %-----------------------------------------------------------------%
        function mask(hAxes, specObj, kk)
            maskTable = specObj.Bands(kk).Mask.Table;
            levelUnit = specObj.TaskSpec.Script.Band(kk).instrLevelUnit;

            for ii = 1:height(maskTable)
                newObj = plot(hAxes, [maskTable.startFrequencyMHz(ii), maskTable.stopFrequencyMHz(ii)], [maskTable.threshold(ii), maskTable.threshold(ii)], 'red', ...
                              'Marker', 'o', 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', 'MarkerSize', 4, 'Tag', 'Mask');
                plot.datatipModel(newObj, levelUnit)
            end
        end
    end

end