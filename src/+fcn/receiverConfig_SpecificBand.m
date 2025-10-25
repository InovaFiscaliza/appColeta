function warnMsg = receiverConfig_SpecificBand(obj, idx, EMSatObj, ERMxObj)
    
    newTask   = obj(idx).Task;
    instrInfo = obj(idx).Task.Receiver.Config;
    hReceiver = obj(idx).hReceiver;
     
    rawBand   = obj(idx).Task.Script.Band;
    taskBand  = class.bandClass.empty;

    warnMsg    = {};

    % Peculiaridades do receptor sob análise:
    TraceMode_Values   = strsplit(instrInfo.Trace_Values{1},     ',');
    AverageMode_Values = instrInfo.AverageMode_Values{1};
    Detector_Values    = strsplit(instrInfo.Detector_Values{1},  ',');
    LevelUnit_Values   = strsplit(instrInfo.LevelUnit_Values{1}, ',');
    scpiVBW_Options    = strsplit(instrInfo.scpiVBW_Options{1},  ',');

    rawFields = {'TraceMode',        'AverageMode',     'AveragCount',     ... %  1 a  3
                 'Detector',         'LevelUnit',       'FreqStart',       ... %  4 a  6
                 'FreqStop',         'DataPoints',      'StepWidth',       ... %  7 a  9
                 'ResolutionMode',   'ResolutionValue', 'Selectivity',     ... % 10 a 12
                 'SensitivityMode',  'Preamp',          'AttenuationMode', ... % 13 a 15
                 'AttenuationValue', 'SampleTimeMode',  'SampleTimeValue', ... % 16 a 18
                 'minFreqRange',     'maxFreqRange',    'VideoBandwidth',  ... % 19 a 21
                 'FreqCenter',       'FreqSpan',        'DF_SquelchMode',  ... % 22 a 24
                 'DF_SquelchValue',  'DF_MeasTime'};                           % 25 a 26
    rawFields = rawFields(instrInfo.scpiQuery_IDs{1});

    % Teste de configuração para cada uma das bandas - em resumo, configura-se 
    % os parâmetros (FreqStart, FreqStop, Resolution etc) e, posteriormente, 
    % confirma-se que os parâmetros foram devidamente configurados.
    if ismember(obj(idx).Task.Receiver.Config.connectFlag, [2, 3])
        class.EB500Lib.OperationMode(hReceiver, obj(idx).Task.Receiver.Config.connectFlag)
    end

    for ii = 1:numel(rawBand)
        ResolutionMode  = 0;
        SampleTimeMode  = 1;
        SampleTimeValue = 0;

        % TraceMode
        switch rawBand(ii).TraceMode
            case 'ClearWrite'; TraceModeID = 1;
            case 'Average';    TraceModeID = 2;
            case 'MaxHold';    TraceModeID = 3;
            case 'MinHold';    TraceModeID = 4;
        end
        TraceMode = TraceMode_Values{TraceModeID};
        
        AverageMode = [];
        if ~isempty(AverageMode_Values); AverageMode = AverageMode_Values(TraceModeID);
        end

        % Average count
        AverageCount = rawBand(ii).IntegrationFactor;
        
        % Detector
        switch rawBand(ii).instrDetector
            case 'Sample';        Detector = Detector_Values{1};
            case 'Average/RMS';   Detector = Detector_Values{2};
            case 'Positive Peak'; Detector = Detector_Values{3};
            case 'Negative Peak'; Detector = Detector_Values{4};
        end
        
        % LevelUnit
        switch rawBand(ii).instrLevelUnit
            case 'dBm';            LevelUnit = LevelUnit_Values{1};
            case {'dBµV', 'dBμV'}; LevelUnit = LevelUnit_Values{2};
        end                
        
        % FreqStart/FreqStop
        switch newTask.Antenna.Switch.Name
            case 'EMSat'
                antennaLNBName = rawBand(ii).instrAntenna;
                antennaName    = extractBefore(rawBand(ii).instrAntenna, ' ');
                antIndex       = find(strcmp(EMSatObj.LNB.Name, antennaLNBName), 1);
    
                freqBand       = abs([rawBand(ii).FreqStart, rawBand(ii).FreqStop] - double(EMSatObj.LNB.Offset(antIndex)));
                FreqStart      = min(freqBand);
                FreqStop       = max(freqBand);
                
                FlipArray      = EMSatObj.LNB.Inverted(antIndex);
                SwitchPort     = EMSatObj.LNB.SwitchPort(antIndex);
                LNBChannel     = EMSatObj.LNB.LNBChannel(antIndex);
    
                idx1 = find(strcmp({EMSatObj.Antenna.Name}, extractBefore(rawBand(ii).instrAntenna, ' ')), 1);
                idx2 = -1;
                for kk = 1:numel(EMSatObj.Antenna(idx1).LNB)
                    if ismember(antennaLNBName, EMSatObj.Antenna(idx1).LNB(kk).Name)
                        idx2 = kk;
                        break
                    end
                end
                LNBIndex       = [idx1, idx2];

            case 'ERMx'
                FreqStart      = rawBand(ii).FreqStart;
                FreqStop       = rawBand(ii).FreqStop;

                antennaName    = rawBand(ii).instrAntenna;
                antIndex       = find(strcmp({ERMxObj.Antenna.Name}, antennaName), 1);
                SwitchPort     = ERMxObj.Antenna(antIndex).SwitchPort;
                FlipArray      = [];

            otherwise
                FreqStart      = rawBand(ii).FreqStart;
                FreqStop       = rawBand(ii).FreqStop;
                
                antennaName    = newTask.Antenna.MetaData.Name;    
                FlipArray      = [];
        end

        % DataPoints, StepWidth, Resolution, Selectivity
        DataPoints      = rawBand(ii).instrDataPoints;
        StepWidth       = (rawBand(ii).FreqStop - rawBand(ii).FreqStart) ./ (rawBand(ii).instrDataPoints - 1);
        ResolutionValue = str2double(extractBefore(rawBand(ii).instrResolution, ' kHz')) .* 1e+3;
        Selectivity     = rawBand(ii).instrSelectivity;

        % VBW
        scpiVBW_Value   = '';
        if ~isempty(scpiVBW_Options{1})
            switch rawBand(ii).instrVBW
                case 'auto'; scpiVBW_Value = scpiVBW_Options{1};
                otherwise;   scpiVBW_Value = replace(scpiVBW_Options{2}, '%VBWValue%', rawBand(ii).instrVBW);
            end
        end
        
        % SensitivityMode, Preamp, AttenuationMode, AttenuationValue
        if ~isempty(rawBand(ii).instrSensitivityMode)
            SensitivityMode = rawBand(ii).instrSensitivityMode;
        end
        
        switch rawBand(ii).instrPreamp
            case 'On'; Preamp = 1;
            otherwise; Preamp = 0;
        end
        
        AutoLevel = '';
        switch rawBand(ii).instrAttMode
            case 'Auto'
                AttenuationMode  = 1;
                AttenuationValue = 0;

                if strcmp(obj(idx).Task.Receiver.Selection.Name, 'Tektronix SA2500')
                    AutoLevel = ';:INPut:ALEVel';
                end

            otherwise
                AttenuationMode  = 0;
                AttenuationValue = str2double(extractBefore(rawBand(ii).instrAttFactor, ' dB'));
        end
        
        % SCPI main string
        replaceCell = {'%Trace%',              TraceMode;                 ... 
                       '%AverageMode%',        num2str(AverageMode);      ...
                       '%AverageCount%',       num2str(AverageCount);      ...
                       '%Detector%',           Detector;                  ...
                       '%LevelUnit%',          LevelUnit;                 ...
                       '%FreqStart%',          num2str(FreqStart);        ...
                       '%FreqStop%',           num2str(FreqStop);         ...
                       '%DataPoints%',         num2str(DataPoints);       ...
                       '%StepWidth%',          num2str(StepWidth);        ...
                       '%ResolutionMode%',     num2str(ResolutionMode);   ...
                       '%ResolutionValue%',    num2str(ResolutionValue);  ...
                       '%VBWOption%',          scpiVBW_Value;             ...
                       '%Selectivity%',        Selectivity;               ...
                       '%SensitivityMode%',    SensitivityMode;           ...
                       '%Preamp%',             num2str(Preamp);           ...
                       '%AttenuationMode%',    num2str(AttenuationMode);  ...
                       '%AutoLevel%',          AutoLevel;                 ...
                       '%AttenuationValue%',   num2str(AttenuationValue); ...
                       '%SampleTimeMode%',     num2str(SampleTimeMode);   ...
                       '%SampleTimeValue%',    num2str(SampleTimeValue);  ...
                       '%FreqCenter%',         num2str((FreqStart + FreqStop)/2);    ...
                       '%FreqSpan%',           num2str(FreqStop - FreqStart);        ...
                       '%DF_SquelchMode%',     rawBand(ii).DF_SquelchMode;           ...
                       '%DF_SquelchValue%',    num2str(rawBand(ii).DF_SquelchValue); ...
                       '%DF_MeasTime%',        num2str(rawBand(ii).DF_MeasTime)};
        
        scpiSet_Config = replace(instrInfo.scpiGeneral{1}, replaceCell(:,1), replaceCell(:,2));
        scpiSet_Att    = '';
        
        % Tenta programar valores...
        writeline(hReceiver, scpiSet_Config);
        pause(instrInfo.BandPause)
        
        if ~AttenuationMode && ~isempty(instrInfo.scpiAttenuation{1})
            scpiSet_Att = replace(char(instrInfo.scpiAttenuation{1}), '%AttenuationValue%', num2str(AttenuationValue));
            writeline(hReceiver, scpiSet_Att);
        end
        
        % Confirma que foram programados corretamente os valores no sensor...
        flush(hReceiver)
        writeline(hReceiver, instrInfo.scpiQuery{1});

        rawAnswer = '';

        statusTic = tic;
        t = toc(statusTic);
        while t < class.Constants.Timeout
            if hReceiver.NumBytesAvailable
                rawAnswer = readline(hReceiver);
                if ~isempty(rawAnswer)
                    rawAnswer = strtrim(rawAnswer);
                    break
                end
            end
            t = toc(statusTic);
        end

        if isempty(rawAnswer)
            error(msgConstructor(1, 'Empty string', scpiSet_Config, ''))
        end

        splitAnswer    = strsplit(rawAnswer, ';');
        scpiSet_Answer = [];

        for jj = 1:numel(rawFields)
            scpiSet_Answer.(rawFields{jj}) = splitAnswer{jj};
        end
        scpiSet_Answer = jsonencode(scpiSet_Answer);

        for jj = 1:numel(instrInfo.scpiQuery_IDs{1})
            Trigger = rawFields{jj};

            % Restringido a mensagem de erro às principais variáveis a configurar: 
            % "FreqStart", "FreqStop", "ResolutionValue" (RBW), "TraceMode", 
            % "Detector" etc.
            switch instrInfo.scpiQuery_IDs{1}(jj)
                case  1; if ~strcmp(splitAnswer{jj}, TraceMode);            error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                case  4; if ~strcmp(splitAnswer{jj}, Detector);             error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                case  5; if ~strcmp(splitAnswer{jj}, LevelUnit);            error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                case  6; if str2double(splitAnswer{jj}) ~= FreqStart;       error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                case  7; if str2double(splitAnswer{jj}) ~= FreqStop;        error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                case  8; if str2double(splitAnswer{jj}) ~= DataPoints;      error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                case  9; if str2double(splitAnswer{jj}) ~= StepWidth;       error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
                case 11; if str2double(splitAnswer{jj}) ~= ResolutionValue; error(msgConstructor(2, Trigger, scpiSet_Config, scpiSet_Answer)); end
            end
        end

        taskBand(ii).SpecificSCPI = struct('configSET', scpiSet_Config, 'attSET', scpiSet_Att);
        taskBand(ii).rawMetaData  = scpiSet_Answer;
        taskBand(ii).DataPoints   = DataPoints;
        taskBand(ii).FlipArray    = FlipArray;
        taskBand(ii).Antenna      = fcn.antennaParser(newTask.Antenna.MetaData, antennaName);

        switch newTask.Antenna.Switch.Name
            case 'EMSat'
                taskBand(ii).Antenna.SwitchPort = SwitchPort;
                taskBand(ii).Antenna.LNBChannel = LNBChannel;
                taskBand(ii).Antenna.LNBIndex   = LNBIndex;

            case 'ERMx'
                taskBand(ii).Antenna.SwitchPort = SwitchPort;
        end
    end

    obj(idx).Band = taskBand;
end


%-------------------------------------------------------------------------%
function msg = msgConstructor(Type, Trigger, scpiSet_Config, scpiSet_Answer)
    switch Type
        case 1
            msg = sprintf(['Triggered parameter: "%s\n"' ...
                           'scpiSet_Config: %s'], Trigger, scpiSet_Config);
        case 2                                                              % 'error' | 'warning'
            msg = sprintf(['Triggered parameter: "%s"\n' ...
                           'scpiSet_Config: %s\n'        ...
                           'scpiSet_Answer: %s'], Trigger, scpiSet_Config, scpiSet_Answer);
    end
end