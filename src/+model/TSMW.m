% TSMW  Interface de comunicação com o receptor Rohde & Schwarz TSMW.
%
%   Implementa os métodos necessários para inicializar a conexão TCP/IP com o
%   instrumento, configurar e executar varredura
%   e obter dados GPS. A comunicação é baseada em mensagens JSON trocadas via
%   socket TCP/IP com o EtherDLL.
% 
%   Dependências:
%     - Arquivo de configuração: config/TSMWLib.json
%
%   Exemplo de uso:
%     rx = model.TSMW('localhost', 5555);
%     idn = rx.queryIdentification();
%     trace = rx.getTrace();
%     delete(rx);

classdef TSMW < handle

    properties
        %-----------------------------------------------------------------%
        % Socket  Objeto tcpclient usado para a comunicação TCP/IP com o instrumento.
        Socket

        % Config  Estrutura com os comandos SCPI/JSON carregados do arquivo TSMWLib.json.
        Config
    end


    methods
        function obj = TSMW(ip, port)
            % TSMW  Construtor — conecta ao instrumento via TCP/IP.
            %
            %   obj = TSMW(ip, port) carrega as configurações do arquivo
            %   TSMWLib.json, abre uma conexão TCP/IP com o endereço ip:port
            %   e define LF como terminador de linha.
            %
            %   Parâmetros:
            %     ip   - Endereço IP do instrumento (string), ex: '192.168.0.1'
            %     port - Porta TCP do instrumento (inteiro), ex: 5025
            
            %-----------------------------------------------------------------%
            % Carrega configuração do instrumento a partir de arquivo ..\config\TSMWLib.json
            try
                configFile  = fullfile(fileparts(mfilename('fullpath')), '..', 'config', 'TSMWLib.json');
                obj.Config = jsondecode(fileread(configFile));

                % Cria socket TCP/IP para comunicação com o instrumento
                obj.Socket = tcpclient(ip, port);
                configureTerminator(obj.Socket, 'LF');

            catch ME
                rethrow(ME);

            end
        end

        %-----------------------------------------------------------------%
        function idn = queryIdentification(obj)
            % queryIdentification  Consulta a identificação do instrumento:
            % modelo, número de série, versão de firmware e versão de hardware.
            %
            %   idn = queryIdentification(obj) envia o comando de identificação
            %   definido em Config.scpiIDN e retorna a string de resposta.
            %
            %   Saída:
            %     idn - String de identificação do instrumento.
            idn = obj.writeAndRead(obj.Config.scpiIDN, "message");
        end

        %-----------------------------------------------------------------%
        function cfg = queryConfiguration(obj)
            % queryConfiguration  Lê os parâmetros atuais de varredura do instrumento.
            %
            %   cfg = queryConfiguration(obj) envia o comando de consulta definido
            %   em Config.scpiQuery e retorna a estrutura com os parâmetros de
            %   varredura correntes (sweepSettings).
            %
            %   Saída:
            %     cfg - Estrutura com os parâmetros de varredura do instrumento.
            cfg = obj.writeAndRead(obj.Config.scpiQuery, "sweepSettings" );
        end

        %-----------------------------------------------------------------%
        function setConfiguration(obj, cfg)
            % setConfiguration  Envia uma configuração de varredura ao instrumento.
            %
            %   setConfiguration(obj, cfg) substitui os marcadores de campo
            %   presentes no template Config.scpiGeneral pelos valores de cfg
            %   e transmite a mensagem resultante ao instrumento.
            %
            %   Parâmetros:
            %     cfg - Estrutura com os campos de configuração a serem aplicados.
            %           Os campos devem corresponder aos marcadores do template SCPI.
            setupMessage = replace(obj.Config.scpiGeneral, "%" + string(fieldnames(cfg)) + "%", string(struct2cell(cfg)));
            writeline(obj.Socket, setupMessage);
        end

        %-----------------------------------------------------------------%
        function trace = getTrace(obj)
            % getTrace  Requisita a varredura espectral ao instrumento.
            %
            %   trace = getTrace(obj) solicita o traço espectral via
            %   Config.scpiTraceData. A resposta é recebida como uma string
            %   Base64 que é decodificada e convertida para um vetor de floats
            %   de precisão simples (single) em dBm.
            %
            %   Saída:
            %     trace - Vetor single com os valores de potência em dBm,
            %             ou [] caso nenhum dado esteja disponível.
            sweepResult = obj.writeAndRead(obj.Config.scpiTraceData, "spectrumDbmBase64");
            
            %-----------------------------------------------------------------%
            % Decodifica Base64 e converte os bytes para floats single (IEEE 754)
            if ~isempty(sweepResult)
                spectrumRaw = matlab.net.base64decode(sweepResult);
                trace = typecast(uint8(spectrumRaw), 'single');
            else
                trace = [];
            end

        end

        %-----------------------------------------------------------------%
        function gps = getGps(obj)
            % getGps  Obtém a posição GPS reportada pelo instrumento.
            %
            %   gps = getGps(obj) envia o comando Config.scpiGPS e retorna
            %   uma estrutura com os campos Latitude, Longitude e Altitude.
            %
            %   Saída:
            %     gps - Estrutura com campos:
            %             .Latitude  (graus decimais)
            %             .Longitude (graus decimais)
            %             .Altitude  (metros)
            gpsData = obj.writeAndRead(obj.Config.scpiGPS);
            gps = struct('Latitude', gpsData.latitude, 'Longitude', gpsData.longitude, 'Altitude', gpsData.altitude);
        end

        %-----------------------------------------------------------------%
        function delete(obj)
            % delete  Destrutor — libera o socket TCP/IP ao excluir o objeto.
            %
            %   Garante o fechamento ordenado da conexão de rede antes que o
            %   objeto seja removido da memória.

            % Manda informação p/ etherDLL p/ liberar porta antes de
            % excluir o socket.
            delete(obj.Socket)
        end

        %-----------------------------------------------------------------%
        function test(obj, numSweeps)
            % test  Executa um teste de varredura iterativo com visualização em tempo real.
            %
            %   test(obj) realiza 100 varreduras (padrão) alternando entre duas
            %   faixas de frequência pré-definidas e plota os traços espectrais
            %   em uma janela de figura. Ao final exibe os dados GPS no console.
            %
            %   test(obj, numSweeps) permite especificar o número de varreduras.
            %
            %   Parâmetros:
            %     numSweeps - (opcional) Número de ciclos de varredura. Padrão: 100.
            arguments
                obj
                numSweeps = 100
            end

            % Cria uma figura e um eixo para plotar os traços espectrais
            f = uifigure;
            ax = uiaxes(f);
            ax.Position = [50 50 f.Position(3)-100 f.Position(4)-100];
            ax.XLabel.String = 'Frequency (Hz)';
            ax.XGrid = "on";
            ax.YGrid = "on";
            ax.YLabel.String = 'Power (dBm)';
            ax.Title.String = 'TSMW Spectrum Trace';


            % Duas configurações de varredura com faixas de frequência distintas.
            bandConfig    =  struct(...
                'FrontEndMask',       1, ...
                'FreqStart',         60e6, ...
                'FreqStop',          80e6, ...
                'requireRawData',    false, ...
                'MaxReportingRate',  10, ...
                'AcquisitionRate',   30, ...
                'windowType',        1, ...
                'FftSize',           1024, ...
                'AutoBandwith',      true, ...
                'Bandwidth',         2.0E+7, ...
                'SensitivityMode',   false, ...
                'Threshold',         -100, ...
                'Preamp',            true, ...
                'AttenuationMode',   true, ...
                'AttenuationValue',  0, ...
                'SampleTimeValue',   1.0E+6, ...
                'measurementDetectorType',  1, ...
                'DataPoints',        1024, ...
                'Detector',          1, ...
                'timeDetectorType',  1, ...
                'timeDetectorIntervalType', 1, ...
                'timeParameter',     1000, ...
                'useMarker',         false, ...
                'returnPowerValues', false, ...
                'SyncOptions',       true ...
                );
            bandConfig(2) = struct(...
                'FrontEndMask',       1, ...
                'FreqStart',         108e6, ...
                'FreqStop',          137e6, ...
                'requireRawData',    false, ...
                'MaxReportingRate',  10, ...
                'AcquisitionRate',   30, ...
                'windowType',        1, ...
                'FftSize',           1024, ...
                'AutoBandwith',      true, ...
                'Bandwidth',         2.0E+7, ...
                'SensitivityMode',   false, ...
                'Threshold',         -100, ...
                'Preamp',            true, ...
                'AttenuationMode',   true, ...
                'AttenuationValue',  0, ...
                'SampleTimeValue',   1.0E+6, ...
                'measurementDetectorType',  1, ...
                'DataPoints',        1024, ...
                'Detector',          1, ...
                'timeDetectorType',  1, ...
                'timeDetectorIntervalType', 1, ...
                'timeParameter',     1000, ...
                'useMarker',         false, ...
                'returnPowerValues', false, ...
                'SyncOptions',       true ...
                );



            %-----------------------------------------------------------------%
            % Itera numSweeps ciclos, varrendo cada faixa em sequência
            for ii = 1:numSweeps
            
                %-----------------------------------------------------------------%
                for jj = 1:numel(bandConfig)
                    % Configura o instrumento para a faixa bandConfig(jj) e aguarda estabilização
                    obj.setConfiguration(bandConfig(jj))
                    pause(.050)

                    % Solicita o traço espectral da faixa configurada
                    trace = obj.getTrace();
                    if isempty(trace)
                        continue
                    else
                        % Gera o eixo de frequências e plota a varredura
                        xArray = linspace(bandConfig(jj).FreqStart, bandConfig(jj).FreqStop, bandConfig(jj).DataPoints);
                        yArray = trace;

                        plot(ax, xArray, yArray, 'k')
                        drawnow
                    end

                    % Configura o instrumento para a segunda faixa (bandConfig(2)) e aguarda estabilização
                    obj.setConfiguration(bandConfig(2))
                    pause(.050)

                    % Solicita o traço espectral da segunda faixa
                    trace = obj.getTrace();
                    if isempty(trace)
                        continue
                    else
                        % Gera o eixo de frequências e plota a varredura
                        xArray = linspace(bandConfig(2).FreqStart, bandConfig(2).FreqStop, bandConfig(2).DataPoints);
                        yArray = trace;
                        plot(ax, xArray, yArray, 'k')
                        drawnow
                    end

                end
            end

            % Exibe a posição GPS final reportada pelo instrumento
            gpsData = obj.getGps();
            fprintf('GPS Data: Latitude: %.6f, Longitude: %.6f, Altitude: %.2f m\n', gpsData.Latitude, gpsData.Longitude, gpsData.Altitude);
        end
    end

    methods (Access = private)
        %-----------------------------------------------------------------%
        function textualData = writeAndRead(obj, payload, jsonKey)
            % writeAndRead  Envia um comando JSON ao instrumento e retorna a resposta.
            %
            %   textualData = writeAndRead(obj, payload) envia a string payload
            %   via socket, aguarda a resposta e retorna a estrutura MATLAB
            %   obtida pelo jsondecode da primeira linha que NÃO seja um ACK.
            %
            %   textualData = writeAndRead(obj, payload, jsonKey) adicionalmente
            %   extrai apenas o campo jsonKey da estrutura decodificada.
            %
            %   Parâmetros:
            %     payload - String JSON com o comando a ser enviado.
            %     jsonKey - (opcional) Nome do campo a extrair da resposta JSON.
            %
            %   Saída:
            %     textualData - Estrutura ou valor extraído da resposta JSON,
            %                   ou '' em caso de erro ou ausência de dados.
            %
            %   Nota: comandos GPS (CODE == 2) aguardam 5 s; demais aguardam 1 s.

            % Limpa o buffer de entrada antes de enviar o novo comando
            flush(obj.Socket)
            writeline(obj.Socket, payload)

            %-----------------------------------------------------------------%
            % Se o comando for para obter dados GPS, aguarda um pouco mais para garantir que os dados estejam disponíveis
            if nargin == 2 && jsondecode(payload).CODE == 2
                pause(5)
            else
                pause(1)
            end

            try
                %-----------------------------------------------------------------%
                % Lê os dados linha a linha até que o buffer esteja vazio,
                % descartando as linhas cujo JSON contenha a chave "ACK"
                while obj.Socket.NumBytesAvailable > 0
                    line = strtrim(readline(obj.Socket));
                    if ~contains(line, '"ACK"')
                        textualData = line;
                        break
                    end
                end
                textualData = jsondecode(textualData);

                %-----------------------------------------------------------------%
                % se o jsonKey for fornecido, extrai o valor correspondente a essa chave
                if nargin > 2
                    if isfield(textualData, jsonKey)
                        textualData = textualData.(jsonKey);
                    else
                        textualData = '';
                    end
                end

            catch ME
                textualData = '';
            end

        end
    end
end