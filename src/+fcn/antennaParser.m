function targetPos = antennaParser(antennaMetaData, antennaName)

    idx = find(strcmp({antennaMetaData.Name}, antennaName), 1);
    
    targetPos     = antennaMetaData(idx);
    antennaFields = fieldnames(antennaMetaData);

    for ii = 1:numel(antennaFields)
        if targetPos.(antennaFields{ii}) == "NA"
            targetPos = rmfield(targetPos, antennaFields{ii});
        else
            if ismember(antennaFields{ii}, {'Azimuth', 'Elevation', 'Polarization'})
                targetPos.(antennaFields{ii}) = str2double(extractBefore(targetPos.(antennaFields{ii}), 'º'));
            end
        end
    end
end