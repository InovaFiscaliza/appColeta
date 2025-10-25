function htmlCode = htmlCode_TaskMetaData(specObj, revisitObj, idxTask, idxBand)
    Task   = specObj(idxTask).Task;
    Script = Task.Script;

    [observationType, observationSamples, StepWidth, receiverRevisitTime, gpsRevisitTime, maskTrigger] = metadataPanel_ViewForm(specObj, revisitObj, idxTask, idxBand);
    
    dataStruct = struct('group', 'TAREFA',                                                         ...
                        'value', struct('Type',          Task.Type,                                ...
                                        'Observation',   observationType,                          ...
                                        'FileVersion',   class.Constants.fileVersion,              ...
                                        'BitsPerSample', sprintf('%d bits', Script.BitsPerSample), ...
                                        'Receiver',      specObj(idxTask).IDN,                      ...
                                        'gpsType',       Script.GPS.Type));
    
    dataStruct(2).group = 'RECEPTOR';
    dataStruct(2).value = struct('StepWidth',  StepWidth,                       ...
                                 'DataPoints', Script.Band(idxBand).instrDataPoints, ...
                                 'Resolution', Script.Band(idxBand).instrResolution);
    
    % VBW
    % instrVBW será igual a {} caso se trate do R&S EB500; em se tratando de
    % um analisador, o instrVBW será originalmente igual a "auto" (caso na
    % tarefa o seu valor seja igual a -1) ou o valor mais próximo da relação 
    % de VBWs disponíveis no analisador (atualmente incluído apenas R&S FSL, 
    % FSVR e FSW).
    if ~isempty(Script.Band(idxBand).instrVBW) && ~strcmp(Script.Band(idxBand).instrVBW, 'auto')
        dataStruct(2).value.VBW = Script.Band(idxBand).instrVBW;
    end

    dataStruct(2).value.Detector          = Script.Band(idxBand).instrDetector;
    dataStruct(2).value.TraceMode         = Script.Band(idxBand).TraceMode;
    dataStruct(2).value.IntegrationFactor = Script.Band(idxBand).IntegrationFactor;
    dataStruct(2).value.Reset             = Task.Receiver.Reset;
    dataStruct(2).value.Sync              = Task.Receiver.Sync;
    
    dataStruct(3).group = 'ANTENA';
    dataStruct(3).value = specObj(idxTask).Band(idxBand).Antenna;

    dataStruct(4).group = 'TEMPO DE REVISITA';
    dataStruct(4).value = struct('Receiver', receiverRevisitTime, ...
                                 'GPS',      gpsRevisitTime);

    dataStruct(5).group = 'OUTROS ASPECTOS';
    dataStruct(5).value = struct('Description',        Script.Band(idxBand).Description, ...
                                 'ObservationSamples', observationSamples,          ...
                                 'MaskTrigger',        maskTrigger);
    
    htmlCode = textFormatGUI.struct2PrettyPrintList(dataStruct);
end


%-------------------------------------------------------------------------%
function [observationType, observationSamples, StepWidth, receiverRevisitTime, gpsRevisitTime, maskTrigger] = metadataPanel_ViewForm(specObj, revisitObj, idxTask, idxBand)
    Task   = specObj(idxTask).Task;
    Script = Task.Script;

    % ObservationType
    switch Script.Observation.Type
        case "Duration"; observationType = "Duração específica";
        case "Samples";  observationType = "Quantidade específica de amostras";
        case "Time";     observationType = "Período específico";
    end

    % ObservationSamples
    if observationType == "Quantidade específica de amostras"
        observationSamples = Script.Band(idxBand).instrObservationSamples;
    else
        observationSamples = -1;
    end

    % StepWidth
    if isnumeric(Script.Band(idxBand).instrStepWidth)
        StepWidth = sprintf('%.3f kHz', Script.Band(idxBand).instrStepWidth/1e+3);
    else
        StepWidth = Script.Band(idxBand).instrStepWidth;
    end
    
    % Receiver RevisitTime
    receiverRevisitTime = sprintf('%.3f seg', Script.Band(idxBand).RevisitTime);
    try
        if revisitObj.Band(idxTask).RevisitFactors(idxBand+1) ~= -1
            receiverRevisitTime = sprintf('%.3f → %.3f seg (norm)', Script.Band(idxBand).RevisitTime, ...
                                                                    revisitObj.GlobalRevisitTime * revisitObj.Band(idxTask).RevisitFactors(idxBand+1));
        end
    catch
    end
       
    % GPS RevisitTime
    if ~isempty(Script.GPS.RevisitTime)
        gpsRevisitTime = sprintf('%.3f seg', Script.GPS.RevisitTime);

        try
            if revisitObj.Band(idxTask).RevisitFactors(1) ~= -1
                gpsRevisitTime = sprintf('%.3f → %.3f seg (norm)', Script.GPS.RevisitTime, ...
                                                                   revisitObj.GlobalRevisitTime * revisitObj.Band(idxTask).RevisitFactors(1));
            end
        catch
        end
    else
        gpsRevisitTime = 'NA';
    end

    % MaskTrigger
    if ~isempty(specObj(idxTask).Band(idxBand).Mask)
        maskTrigger = struct('Status',    Task.Script.Band(idxBand).MaskTrigger.Status, ...
                             'FindPeaks', specObj(idxTask).Band(idxBand).Mask.FindPeaks);
    else
        maskTrigger = 'NA';
    end
end