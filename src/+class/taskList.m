classdef taskList

    % Campo "Observation" do arquivo "taskList.json" possui a seguinte estrutura:
    % (a) 'Type'        - 'Duration' | 'Time' | 'Samples'
    % (b) 'BeginTime'   - 'dd/mm/yyyy HH:MM:SS'
    % (c) 'EndTime'     - 'dd/mm/yyyy HH:MM:SS'
    % (d) 'Duration'    - 'inf' | 'infinite' | '\d+\s*(seconds|second|sec|minutes|min|hours|hr)
    %
    % De forma geral,
    % - 'Duration': demanda apenas informação constante no campo 'Duration';
    % - 'Time'....: demanda apenas informações constantes nos campos 'BeginTime' e 'EndTime'; 
    % - 'Samples'.: demanda apenas informações constantes nos campos 'ObservationSamples' de cada uma das faixas - vide campo 'Band' do arquivo "taskList.json".
    %
    % Ao ler o arquivo taskList.json, o campo 'Duration' é editado para computar a duração da tarefa em segundos (valor numérico), o que somente é aplicável quando o tipo de observação for 'Duration'

    % Campo "GPS" do arquivo "taskList.json" possui a seguinte estrutura:
    % (a) 'Type'        - 'auto' | 'manual'
    % (b) 'Latitude'    - valor numérico, aplicável apenas quando 'Type' igual a 'manual'
    % (c) 'Longitude'   - valor numérico, aplicável apenas quando 'Type' igual a 'manual'
    % (d) 'RevisitTime' - valor numérico, representando o tempo de revisita em segundos e aplicável apenas quando 'Type' igual a 'auto'
    %
    % Ao incluir uma tarefa, o campo 'Type', caso seja igual a 'auto', será alterado por 'Built-in' (GPS embarcado no receptor) ou 'External'.

    % Campo "Band" do arquivo "taskList.json" possui estrutura com informações sobre a programação do receptor e lógica da tarefa. Em destaque:
    % (a) 'RFMode'      - 'High Sensitivity' | 'Normal' | 'Low Distortion'
    % (b) 'TraceMode'   - 'ClearWrite' | 'Average' | 'MaxHold' | 'MinHold'
    % (c) 'Detector'    - 'Sample' | 'Average/RMS' | 'Positive Peak' | 'Negative Peak'
    % (d) 'LevelUnit'   - 'dBm' | 'dBµV'
    % (e) 'MaskTrigger' - Estrutura com os campos "Status" (que podem assumir os valores 0 | 1 | 2 | 3) e "FindPeaks".
    %     Se o tipo de tarefa for "Rompimento de máscara espectral":
    %     - 0: a informação coletada será escrita em arquivo, não sendo avaliado rompimento da máscara;
    %     - 1: será apenas avaliado rompimento da máscara;
    %     - 2: será avaliado rompimento da máscara e realizada escrita em arquivo apenas se evidenciado rompimento;
    %     - 3: será avaliado rompimento da máscara e realizada escrita em arquivo.
    %     Para os outros tipos de tarefa - "Monitoração ordinária" e "Drive-test", o valor desse parâmetro não terá nenhum efeito.
    % (f) 'Enable'      - 0 | 1

    methods (Static)
        %-----------------------------------------------------------------%
        function [List, msgError] = file2raw(FileFullPath, srcFcn)
            try
                List = jsondecode(fileread(FileFullPath));
                msgError = '';

                % O trecho de código a seguir busca identificar a versão do 
                % "taskList.json". No arquivo não há um campo indicando a
                % sua versão, mas ao deserializar o arquivo da release R2022a,
                % a estrutura resultante terá quatro campos: "Name", "BitsPerSample", 
                % "Duration" e "Band". Por outro lado, o arquivo da release R2023a 
                % terá cinco campos: "Name", "BitsPerSample", "Observation", "GPS" 
                % e "Band".

                if isequal(fields(List), {'Name';'BitsPerSample';'Duration';'Band'})
                    List = class.taskList.v1Parser(List);
                else
                    List = class.taskList.v2Parser(List, srcFcn);
                end

            catch ME
                List = class.taskList.DefaultTask();
                msgError = ME.message;
            end
        end


        %-----------------------------------------------------------------%
        function msgError = raw2file(FullFolder, List)
            try
                msgError = '';
                
                for ii = 1:numel(List)
                    switch List(ii).Observation.Type
                        case 'Duration'
                            Duration_sec = List(ii).Observation.Duration;
                            if isinf(Duration_sec)
                                List(ii).Observation.Duration = 'inf';
                            elseif Duration_sec >= 3600
                                List(ii).Observation.Duration = sprintf('%d hr',  Duration_sec / 3600);
                            else
                                List(ii).Observation.Duration = sprintf('%d min', Duration_sec / 60);
                            end

                            List(ii).Observation.BeginTime = 'not applicable';
                            List(ii).Observation.EndTime   = 'not applicable';
    
                        case 'Time'
                            List(ii).Observation.Duration  = 'not applicable';
    
                        case 'Samples'
                            List(ii).Observation.BeginTime = 'not applicable';
                            List(ii).Observation.EndTime   = 'not applicable';
                            List(ii).Observation.Duration  = 'not applicable';
                    end
                end

                % Salva arquivo.
                fileID = fopen(fullfile(FullFolder, 'taskList.json'), 'wt');
                fwrite(fileID, jsonencode(List, 'PrettyPrint', true));
                fclose(fileID);

            catch ME
                msgError = ME.message;
            end
        end

        
        %-----------------------------------------------------------------%
        function List = DefaultTask()
            List = struct('Name', 'Tarefa 1',                                                                         ...
                          'BitsPerSample', 8,                                                                         ...
                          'Observation', struct('Type', 'Duration', 'BeginTime', '', 'EndTime', '', 'Duration', 600), ...
                          'GPS',         struct('Type', 'auto', 'Latitude', [], 'Longitude', [], 'RevisitTime', 10),  ...
                          'Band',        struct('ID',                 1,              ...
                                                'Description',        'Faixa 1 de 1', ...
                                                'ObservationSamples', -1,             ...
                                                'FreqStart',          76000000,       ...
                                                'FreqStop',           108000000,      ...                                              
                                                'StepWidth',          5000,           ...
                                                'Resolution',         30000,          ...
                                                'VBW',                'auto',         ...
                                                'RFMode',             'Normal',       ...
                                                'TraceMode',          'ClearWrite',   ...
                                                'Detector',           'Sample',       ...
                                                'LevelUnit',          'dBm',          ...
                                                'RevisitTime',         0.1,           ...
                                                'IntegrationFactor',   1,             ...
                                                'MaskTrigger',         struct('Status',     0,  ...
                                                                              'FindPeaks', []), ...
                                                'Enable',              1));
        end


        %-----------------------------------------------------------------%
        function List = v1Parser(oldList)
            for ii = 1:numel(oldList)
                List(ii,1).Name        = oldList(ii).Name;
                List(ii).BitsPerSample = oldList(ii).BitsPerSample;
                List(ii).Observation   = struct('Type', 'Duration', 'BeginTime', '', 'EndTime', '', 'Duration', oldList(ii).Duration);
                List(ii).GPS           = struct('Type', 'auto', 'Latitude', [], 'Longitude', [], 'RevisitTime', 10);

                for jj = 1:numel(oldList(ii).Band)
                    if oldList(ii).Band(jj).Trigger
                        maskTrigger = 2;
                    else
                        maskTrigger = 0;
                    end

                    List(ii).Band(jj) = struct('ID',                 oldList(ii).Band(jj).ThreadID,          ...
                                               'Description',        oldList(ii).Band(jj).Description,       ...
                                               'ObservationSamples', -1,                                     ...
                                               'FreqStart',          oldList(ii).Band(jj).FreqStart,         ...
                                               'FreqStop',           oldList(ii).Band(jj).FreqStop,          ...
                                               'StepWidth',          oldList(ii).Band(jj).StepWidth,         ...
                                               'Resolution',         oldList(ii).Band(jj).Resolution,        ...
                                               'VBW',                'auto',                                 ...
                                               'RFMode',             oldList(ii).Band(jj).RFMode,            ...
                                               'TraceMode',          oldList(ii).Band(jj).TraceMode,         ...
                                               'Detector',           oldList(ii).Band(jj).Detector,          ...
                                               'LevelUnit',          oldList(ii).Band(jj).LevelUnit,         ...
                                               'RevisitTime',        oldList(ii).Band(jj).RevisitTime,       ...
                                               'IntegrationFactor',  oldList(ii).Band(jj).IntegrationFactor, ...
                                               'MaskTrigger',        struct('Status', maskTrigger, 'FindPeaks', []), ...
                                               'Enable',             oldList(ii).Band(jj).Enable);
                end

                % Validações finais.
                List = class.taskList.ParserValidation(List, ii);
            end
        end


        %-----------------------------------------------------------------%
        function List = v2Parser(List, srcFcn)
            for ii = 1:numel(List)
                switch List(ii).Observation.Type
                    case 'Duration'
                        List(ii).Observation.Duration = lower(List(ii).Observation.Duration);
                        if ismember(List(ii).Observation.Duration, {'inf', 'infinite'})
                            List(ii).Observation.Duration = inf;
                        else
                            durationStr = regexpi(List(ii).Observation.Duration, '(?<value>\d+)\s*(?<unit>(seconds|second|sec|minutes|minute|min|hours|hour|hr))', 'names');
                            if ~isempty(durationStr)
                                switch durationStr.unit
                                    case {'seconds', 'second', 'sec'}; List(ii).Observation.Duration = str2double(durationStr.value);
                                    case {'minutes', 'minute', 'min'}; List(ii).Observation.Duration = str2double(durationStr.value)*60;
                                    case {'hours', 'hour', 'hr'};      List(ii).Observation.Duration = str2double(durationStr.value)*3600;
                                end
                            else
                                List(ii).Observation.Duration = 600;
                            end
                        end
                        List(ii).Observation.BeginTime = '';
                        List(ii).Observation.EndTime   = '';

                    case 'Time'
                        List(ii).Observation.Duration = [];

                    case 'Samples'
                        List(ii).Observation = struct('Type', 'Samples', 'BeginTime', '', 'EndTime', '', 'Duration', []);
                end

                % Elimina fluxos não ativos, caso leitura seja acionada do winAppColetaV2.
                if strcmp(srcFcn, 'winAppColetaV2')
                    nBands = numel(List(ii).Band);
                    for jj = nBands:-1:1
                        if ~List(ii).Band(jj).Enable
                            List(ii).Band(jj) = [];
                        end
                    end
                end

                % Validações finais.
                List = class.taskList.ParserValidation(List, ii);
            end
        end


        %-----------------------------------------------------------------%
        function List = ParserValidation(List, ii)
            % Garante que ao menos um fluxo esteja ativo.
            if ~any([List(ii).Band.Enable])
                List(ii).Band(1).Enable = 1;
            end

            % Ordena números dos IDs de cada fluxo, caso tenha sido objeto de alguma edição manual equivocada,
            % além de garantir que será usado a representação esperada pelo app do símbolo "micro".
            for jj = 1:numel(List(ii).Band)
                List(ii).Band(jj).ID = jj;
                List(ii).Band(jj).LevelUnit = class.taskList.str2str(List(ii).Band(jj).LevelUnit);
            end
        end


        %-----------------------------------------------------------------%
        function Value = str2str(Value)
            Value = replace(Value, 'μ', 'µ');
        end


        %-----------------------------------------------------------------%
        function Task = app2raw(Task)
            if ismember(Task.Observation.Type, {'Duration', 'Samples'})
                Task.Observation.BeginTime = '';
                Task.Observation.EndTime   = '';
            end

            if ismember(Task.GPS.Type, {'Built-in', 'External'})
                Task.GPS.Type = 'auto';
            end
        end


        %-----------------------------------------------------------------%
        function d = english2portuguese(varargin)
            names  = ["Duration", ...
                      "Samples", ...
                      "Time"];
            values = ["Duração", ...
                      "Quantidade específica de amostras", ...
                      "Período específico"];
        
            d = dictionary(names, values);


            if nargin
                d = char(d(varargin{1}));
            end
        end
    end
end