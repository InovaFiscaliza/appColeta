function peaksTable = FindPeaks(specObj, idx, smoothedArray, validationArray)

    peaksTable = [];

    Attributes = specObj.Band(idx).Mask.FindPeaks;
    FreqStart  = specObj.Task.Script.Band(idx).FreqStart;
    FreqStop   = specObj.Task.Script.Band(idx).FreqStop;
    DataPoints = numel(smoothedArray);

    % Frequency = aCoef * Index + bCoef
    aCoef = (FreqStop-FreqStart)/(DataPoints-1);
    bCoef = FreqStart-aCoef;

    % Findpeaks
    [pkIdxRange, pkProminence] = matlab.findpeaks(smoothedArray, 'MinPeakProminence', Attributes.Prominence,              ...
                                                                 'MinPeakDistance',   1000 * Attributes.Distance / aCoef, ...
                                                                 'MinPeakWidth',      1000 * Attributes.BW / aCoef,       ...
                                                                 'SortStr',           'descend');
    for ii = height(pkIdxRange):-1:1
        idxValidation = floor(pkIdxRange(ii,1)):ceil(pkIdxRange(ii,2));
        if all(~validationArray(idxValidation))
            pkIdxRange(ii,:) = [];
            pkProminence(ii) = [];
        end
    end

    if ~isempty(pkIdxRange)
        pkIdxFreq    = mean(pkIdxRange, 2);
        pkFreqCenter = (aCoef .* pkIdxFreq + bCoef) ./ 1e+6;                % Em MHz
        pkWidth      = (pkIdxRange(:,2)-pkIdxRange(:,1)) * aCoef / 1e+3;    % Em kHz

        peaksTable = table(round(pkIdxFreq), round(pkFreqCenter, 3), round(pkWidth, 1), round(pkProminence, 1), 'VariableNames', {'idx', 'FreqCenter', 'BW', 'Prominence'});
    end
end