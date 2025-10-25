classdef (Abstract) draw3D

    methods (Static = true)
        %-----------------------------------------------------------------%
        function hPlot = Waterfall(hAxes, specObj, kk, xArray)
            newArrayIndex = specObj.Band(kk).Waterfall.idx;
            hPlot = image(hAxes, xArray, 1:specObj.Band(kk).Waterfall.Depth, circshift(specObj.Band(kk).Waterfall.Matrix, -newArrayIndex), 'CDataMapping', 'scaled', 'Tag', 'Waterfall');
            
            levelUnit = specObj.Task.Script.Band(kk).instrLevelUnit;
            plot.datatipModel(hPlot, levelUnit)
        end
    end

end