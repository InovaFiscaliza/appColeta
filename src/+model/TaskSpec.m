classdef TaskSpec

    properties
        %-----------------------------------------------------------------%
        % Define o tipo de monitoração, atualmente restrito a "Monitoração regular",
        % "Drive-test" ou "Rompimento de Máscara Espectral"
        Type

        % Registro de "taskList.json", possivelmente editado, uma vez que os campos
        % "BitsPerSamples", "Observation" e "GPS" são editáveis.
        Script

        % Aplicável apenas para uma monitoração do tipo "Rompimento de Máscara Espectral", 
        % registrando o fullpath do arquivo e máscara no formato CSV (Logger).
        MaskFile

        % Handle para o objeto tcpclient criado, registro de "InstrumentList.json" 
        % selecionado, registro de "ReceiverLib.json" relacionado ao instrumento 
        % selecionado, e aspectos operacionais - envia comando de reset ("*RST")
        % antes do início da monitoração? instrumento operando no modo "SingleSweep" 
        % ou "ContinuousSweep"?
        Receiver  = struct('Handle', {}, 'Selection', {}, 'Config', {}, 'Reset', {}, 'Sync', {})
        
        % Handle para o objeto udpport criado (relacionado apenas à monitoração 
        % conduzida pelo R&S EB500.
        Streaming = struct('Handle', {})
        
        % Handle para o objeto serial ou tcpclient criado, além do registro de 
        % "InstrumentList.json" selecionado.
        GPS = struct('Handle', {}, 'Selection', {})
        
        % Eestrutura contendo informação de comutação de antenas ('' | 'EMSat' | 'ETM')
        %e dos metadados das antenas (altura, azimute, elevação, polarização).
        Antenna = struct('Switch', {}, 'MetaData',  {})
    end


    methods
        %-----------------------------------------------------------------%
        function obj = TaskSpec(type, script, maskFile, receiver, streaming, gps, antenna)
            obj.Type = type;
            obj.Script = script;
            obj.MaskFile = maskFile;
            obj.Receiver = receiver;
            obj.Streaming = streaming;
            obj.GPS = gps;
            obj.Antenna = antenna;
        end
    end

end