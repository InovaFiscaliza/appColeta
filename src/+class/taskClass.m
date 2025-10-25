classdef taskClass

    % Author.: Eric Magalhães Delgado
    % Date...: July 15, 2023
    % Version: 1.00

    properties
        Type
        Script
        MaskFile
        Receiver  = struct('Handle', {}, 'Selection', {}, 'Config', {}, 'Reset', {}, 'Sync', {})
        Streaming = struct('Handle', {})
        GPS       = struct('Handle', {}, 'Selection', {})
        Antenna   = struct('Switch', {}, 'MetaData',  {})
    end

    % Propriedades:    
    % (a) 'Type'      - 'Monitoração regular' | 'Drive-test' | 'Rompimento de Máscara Espectral' 
    % (b) 'Script'    - registro de "taskList.json" possivelmente editado, uma vez que os campos
    %                   "BitsPerSamples", "Observation" e "GPS" são editáveis.
    % (c) 'MaskFile'  - aplicável apenas para uma monitoração do tipo "Rompimento 
    %                   de Máscara Espectral", registrando o fullpath do arquivo
    %                   de máscara no formato CSV (Logger).
    % (d) 'Receiver'  - handle para o objeto tcpclient criado, registro de "InstrumentList.json" 
    %                   selecionado, registro de "ReceiverLib.json" relacionado ao instrumento 
    %                   selecionado, e aspectos operacionais - envia comando de reset ("*RST")
    %                   antes do início da monitoração? instrumento operando no modo "SingleSweep" 
    %                   ou "ContinuousSweep"?
    % (e) 'Streaming' - handle para o objeto udpport criado (relacionado apenas à monitoração 
    %                   conduzida pelo R&S EB500.
    % (f) 'GPS'       - handle para o objeto serial ou tcpclient criado, além do registro de 
    %                   "InstrumentList.json" selecionado.
    % (g) 'Antenna'   - estrutura contendo informação de comutação de antenas ('' | 'EMSat' | 'ETM')
    %                   e dos metadados das antenas (altura, azimute, elevação, polarização).
end