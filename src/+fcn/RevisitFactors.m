function timeObj = RevisitFactors(specObj)

    timeObj = struct('GlobalRevisitTime', [],             ...
                     'Band', struct('RevisitTimes',   [], ...
                                    'RevisitFactors', []));

    RevisitTimeArray = [];
    for ii = 1:numel(specObj)
        if specObj(ii).Status == "Em andamento"
            gpsRevisitTime = -1;
            if ~isempty(specObj(ii).Task.Script.GPS.RevisitTime)
                gpsRevisitTime = specObj(ii).Task.Script.GPS.RevisitTime;
            end

            tempArray = [specObj(ii).Task.Script.Band.RevisitTime];
            tempArray(~[specObj(ii).Band.Status]) = -1;

            timeObj.Band(ii) = struct('RevisitTimes',   [gpsRevisitTime, tempArray], ...
                                      'RevisitFactors', []);
            
            RevisitTimeArray = [RevisitTimeArray, tempArray];
        else
            timeObj.Band(ii) = struct('RevisitTimes',   [], ...
                                      'RevisitFactors', []);
        end
    end

    timeObj.GlobalRevisitTime = min(RevisitTimeArray(RevisitTimeArray ~= -1));

    for ii = 1:numel(specObj)
        if ~isempty(timeObj.Band(ii).RevisitTimes)
            timeObj.Band(ii).RevisitFactors = timeObj.Band(ii).RevisitTimes;

            idx = (timeObj.Band(ii).RevisitTimes ~= -1);
            timeObj.Band(ii).RevisitFactors(idx) = fix(timeObj.Band(ii).RevisitTimes(idx) ./ timeObj.GlobalRevisitTime);
        end
    end
    
end