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
                    hPlot.YData = ((generalSettings.Integration.Trace-1)*hPlot.YData + newArray) / generalSettings.Integration.Trace;
                case 'MaxHold'
                    hPlot.YData = max(hPlot.YData, newArray);
            end
        end

        %-----------------------------------------------------------------%
        function hPlot = clearWrite(hAxes, xArray, newArray, levelUnit, plotTag, generalSettings)
            hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.Plot.ClearWrite.Color, 'Tag', plotTag);
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPlot = minHold(hAxes, specObj, jj, xArray, newArray, levelUnit, generalSettings)        
            switch specObj.Status
                case 'Em andamento'
                    hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.Plot.MinHold.Color, 'Tag', 'MinHold');                    
                otherwise
                    idx = find(all(specObj.Band(jj).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Band(jj).Waterfall.Depth+1;
                    end
        
                    hPlot = plot(hAxes, xArray, min(specObj.Band(jj).Waterfall.Matrix(1:idx-1,:), [], 1), 'Color', generalSettings.Plot.MinHold.Color, 'Tag', 'MinHold');
            end
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPlot = Average(hAxes, specObj, kk, xArray, newArray, levelUnit, generalSettings)        
            switch specObj.Status
                case 'Em andamento'
                    hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.Plot.Average.Color, 'Tag', 'Average');                    
                otherwise
                    idx = find(all(specObj.Band(kk).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Band(kk).Waterfall.Depth+1;
                    end
        
                    hPlot = plot(hAxes, xArray, mean(specObj.Band(kk).Waterfall.Matrix(1:idx-1,:), 1), 'Color', generalSettings.Plot.Average.Color, 'Tag', 'Average');
            end
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPlot = maxHold(hAxes, specObj, kk, xArray, newArray, levelUnit, generalSettings)        
            switch specObj.Status
                case 'Em andamento'
                    hPlot = plot(hAxes, xArray, newArray, 'Color', generalSettings.Plot.MaxHold.Color, 'Tag', 'MaxHold');                    
                otherwise
                    idx = find(all(specObj.Band(kk).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Band(kk).Waterfall.Depth+1;
                    end
        
                    hPlot = plot(hAxes, xArray, max(specObj.Band(kk).Waterfall.Matrix(1:idx-1,:), [], 1), 'Color', generalSettings.Plot.MaxHold.Color, 'Tag', 'MaxHold');
            end
            plot.datatipModel(hPlot, levelUnit)
        end

        %-----------------------------------------------------------------%
        function hPeak = peakExcursion(hPeak, hClearWrite, specObj, kk, newArray)
            switch specObj.Status
                case 'Em andamento'
                    [~, peakIdx] = max(newArray);                    
                otherwise
                    idx = find(all(specObj.Band(kk).Waterfall.Matrix == -1000, 2), 1);
                    if isempty(idx)
                        idx = specObj.Band(kk).Waterfall.Depth+1;
                    end
        
                    [~, peakIdx] = max(mean(specObj.Band(kk).Waterfall.Matrix(1:idx-1,:), 1));
            end
        
            if isempty(hPeak) || ~isvalid(hPeak)
                hPeak = datatip(hClearWrite, 'DataIndex', peakIdx, 'Tag', 'PeakExcursion');
            else
                hPeak.DataIndex = peakIdx;
            end
        end

        %-----------------------------------------------------------------%
        function mask(hAxes, specObj, kk)
            maskTable = specObj.Band(kk).Mask.Table;
            levelUnit = specObj.Task.Script.Band(kk).instrLevelUnit;

            for ii = 1:height(maskTable)
                newObj = plot(hAxes, [maskTable.FreqStart(ii), maskTable.FreqStop(ii)], [maskTable.THR(ii), maskTable.THR(ii)], 'red', ...
                              'Marker', 'o', 'MarkerEdgeColor', 'red', 'MarkerFaceColor', 'red', 'MarkerSize', 4, 'Tag', 'Mask');
                plot.datatipModel(newObj, levelUnit)
            end
        end
    end

end