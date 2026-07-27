classdef (Abstract) draw3D

    methods (Static = true)
        %-----------------------------------------------------------------%
        function hPlot = Waterfall(hAxes, specObj, kk, xArray)
            newArrayIndex = specObj.Bands(kk).Waterfall.idx;
            hPlot = image(hAxes, xArray, 1:specObj.Bands(kk).Waterfall.Depth, circshift(specObj.Bands(kk).Waterfall.Matrix, -newArrayIndex), 'CDataMapping', 'scaled', 'Tag', 'Waterfall');
            
            levelUnit = specObj.TaskSpec.Script.Band(kk).instrLevelUnit;
            plot.datatipModel(hPlot, levelUnit)
        end
    end

end