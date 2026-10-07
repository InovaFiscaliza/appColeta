classdef (Abstract) InstrumentIO

    % Essa classe abstrata reúne a leitura da lista de instrumentos
    % ("InstrumentList.json") e a comunicação pontual com um instrumento
    % por meio de socket.

    methods (Static = true)
        %-----------------------------------------------------------------%
        function instrumentList = readInstrumentList(filePath)
            % Descarta os registros sem os parâmetros essenciais ao tipo de
            % conexão e converte "Parameters" em texto JSON, formato em que é
            % armazenado na tabela.

            instrumentList = jsondecode(fileread(filePath));

            for instrumentIdx = numel(instrumentList):-1:1
                switch instrumentList(instrumentIdx).Type
                    case 'Serial';       requiredParameters = {'Port', 'BaudRate'};
                    case 'TCPIP Socket'; requiredParameters = {'IP', 'Port'};
                    otherwise;           requiredParameters = {};
                end

                if ~all(ismember(requiredParameters, fieldnames(instrumentList(instrumentIdx).Parameters)))
                    instrumentList(instrumentIdx) = [];
                else
                    instrumentList(instrumentIdx).Parameters = jsonencode(instrumentList(instrumentIdx).Parameters);
                end
            end

            instrumentList = struct2table(instrumentList, 'AsArray', true);
        end

        %-----------------------------------------------------------------%
        function reply = queryInstrument(instrumentHandle, command)
            % O uso do WRITEREAD é perigoso (de forma geral!). Foi evidenciado erro
            % na requisição do valor de atenuação programado no analisador de espectro
            % (R&S FSL). Por conta disso, substitui-se WRITEREAD por WRITELINE+PAUSE+READ.
            %
            % O STRTRIM, ao final, apaga tanto espaços quanto quebras de linhas,
            % funcionando como um leitor de caracteres seguido de um FLUSH.
            %
            % Posteriormente, migrar para esse método as chamadas ao WRITEREAD em
            % model.GPS.queryReceiverGPS.

            writeline(instrumentHandle, command);
            pause(.001)
            reply = strtrim(read(instrumentHandle, instrumentHandle.NumBytesAvailable, 'char'));
        end
    end
end
