classdef TSMW < handle

    properties
        %-----------------------------------------------------------------%
        Socket
        Config
    end


    methods
        %-----------------------------------------------------------------%
        function obj = TSMW(ip, port)
            try
                obj.Config = jsondecode(fileread('...'));
                obj.Socket = tcpclient(ip, port);
            catch ME
                ME
            end
        end

        %-----------------------------------------------------------------%
        function idn = queryIdentification(obj)
            idn = strtrim(writeread(obj.Socket, '*IDN?'));
        end

        %-----------------------------------------------------------------%
        function cfg = queryConfiguration(obj)
            % ...
        end

        %-----------------------------------------------------------------%
        function setConfiguration(obj)
            writeline(obj.Socket, '*CLS;:DISPlay:GENeral:MEASview:SELect SPEC;:FORMat:DATA BIN;:SYSTem:GPS INT')
        end

        %-----------------------------------------------------------------%
        function trace = getTrace(obj)
            % ...
        end

        %-----------------------------------------------------------------%
        function gps = getGps(obj)
            % ...
        end

        %-----------------------------------------------------------------%
        function delete(obj)
            % Manda informação p/ etherDLL p/ liberar porta antes de
            % excluir o socket...
            delete(obj.Socket)
        end

        %-----------------------------------------------------------------%
        function test(obj, numSweeps)
            arguments
                obj
                numSweeps = 100
            end

            f = uifigure;
            ax = uiaxes(f);
            
            % Duas configurações de faixas de frequência...
            bandConfig    = struct('FreqStart', 88e+6, 'FreqStop',  108e+6, 'NumPoints', 1024);
            bandConfig(2) = struct('FreqStart', 108e+6, 'FreqStop', 137e+6, 'NumPoints', 1024);

            for ii = 1:numSweeps
                for jj = 1:numel(bandConfig)
                    % Configura a faixa...
                    % Pedir o traço...
                    % Plotar...
                    xArray = linspace(bandConfig(jj).FreqStart, bandConfig(jj).FreqStop, bandConfig(jj).NumPoints);
                    yArray = randn(1001, 1);
                    
                    plot(ax, xArray, yArray)
                    drawnow

                    pause(.300)
                end
            end
        end
    end
end