classdef (Abstract) Constants

    properties (Constant)
        %-----------------------------------------------------------------%
        appName         = 'appColetaV2'

        windowSize      = [1244, 660]
        windowMinSize   = [ 750, 660]

        debugKey        = '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f'
        debugCode       = '925b2f9f1e97bfca8d20e8262ad330a9'

        gps2locAPI      = 'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=<Latitude>&longitude=<Longitude>&localityLanguage=pt'
        gps2loc_City    = 'city'
        gps2loc_Unit    = 'principalSubdivisionCode'

        userPaths       = {fullfile(getenv('USERPROFILE'), 'Documents'); fullfile(getenv('USERPROFILE'), 'Downloads')}
        Interactions    = {'datacursor', 'zoomin', 'restoreview'}

        yMinLimRange    = 80                                                % Minimum y-Axis limit range
        yMaxLimRange    = 100                                               % Maximum y-Axis limit range

        switchTimes     = 3                                                 % Maximum attempts to switch the antenna
        switchPause     = 0.050                                             % Pause in seconds to ask antenna's name after its switch attempt (must be greater than 40ms)
        antACUPause     = 1                                                 % Pause in seconds to wait for ACU messages (ACU could be locked by Compass!)

        Timeout         = 10                                                % Maximum time in seconds to extract valid info from receiver
        udpTimeout      = 3                                                 % Maximum time in seconds to receive a specific number of datagrams 
        idnTimeout      = 1                                                 % Maximum time in seconds to extract IDN info from receiver
        gpsTimeout      = 1                                                 % Maximum time in seconds to receive bytes from GPS

        fileVersion     = 'RFlookBin v.2/1'                                 % 'RFlookBin v.1/1' | 'RFlookBin v.2/1'
        fileMaxSize     = 100e+6                                            % 100 MB

        checkIP         = 'http://checkip.dyndns.org'

        FindPeaks       = struct('nSweeps',     10, ...
                                 'Proeminence', 30, ...
                                 'Distance',    25, ...
                                 'BW',          10)

        errorTimeTrigger     = 60                                           % Minimum time in seconds to change the status of the task ("In progress" to "Error") in case of a persistent error
        errorCountTrigger    = 10                                           % ~mod(errorCount, errorCountTrigger) defines instants in which app will try to reconnect to the receiver
        errorGPSCountTrigger = 100                                          % ~mod(errorCount, errorCountTrigger) defines instants in which app will try to reconnect to the GPS
        errorPosTolerance    = .2                                           % Acceptable error in antenna position setup (azimuth, elevation and polarization)
    end


    methods (Static = true)
        %-----------------------------------------------------------------%
        function [upYLim, strUnit] = yAxisUpLimit(Unit)
            switch lower(Unit)
                case 'dbm';                    upYLim = -20; strUnit = 'dBm';
                case {'dbµv', 'dbμv', 'dbuv'}; upYLim =  87; strUnit = 'dBµV';
                case {'dbµv/m', 'dbμv/m'};     upYLim = 100; strUnit = 'dBµV/m';
            end
        end


        %-----------------------------------------------------------------%
        function d = english2portuguese()
            names  = ["Azimuth", ...
                      "Band", ...
                      "BitsPerSample", ...
                      "DataPoints", ...
                      "Description", ...
                      "Distance", ...
                      "Elevation", ...
                      "Family", ...
                      "FileVersion", ...
                      "gpsType", ...
                      "Height", ...
                      "Installation", ...
                      "IntegrationFactor", ...
                      "LevelUnit", ...
                      "Name", ...
                      "nSweeps", ...
                      "Observation", ...
                      "ObservationSamples", ...
                      "ObservationType", ...
                      "Polarization", ...
                      "Position", ...
                      "Proeminence", ...
                      "Receiver", ...
                      "Resolution", ...
                      "RevisitTime", ...
                      "RFMode", ...
                      "Sync", ...
                      "StepWidth", ...
                      "switchPort", ...
                      "Target", ...
                      "taskType", ...
                      "Type", ...
                      "TraceMode", ...
                      "TrackingMode"];
            values = ["Azimute", ...
                      "Banda", ...
                      "Codificação", ...
                      "Pontos por varredura", ...
                      "Descrição", ...
                      "Distância", ...
                      "Elevação", ...
                      "Família", ...
                      "Arquivo", ...
                      "GPS", ...
                      "Altura", ...
                      "Instalação", ...
                      "Integração", ...
                      "Unidade", ...
                      "Nome", ...
                      "Qtd. varreduras", ...
                      "Observação", ...
                      "Amostras a coletar", ...
                      "Tipo de observação", ...
                      "Polarização", ...
                      "Posição", ...
                      "Proeminência", ...
                      "Receptor", ...
                      "Resolução", ...
                      "Tempo de revisita", ...
                      "Modo RF", ...
                      "Sincronismo", ...
                      "Passo da varredura", ...
                      "Porta da matriz", ...
                      "Alvo", ...
                      "Tipo de tarefa", ...
                      "Tipo", ...
                      "Traço", ...
                      "Modo de apontamento"];
        
            d = dictionary(names, values);
        end
    end
end