classdef (Abstract) SocketPorts

    % Essa classe abstrata organiza o controle das portas de rede usadas
    % pelo appColeta (TCP e UDP), liberando portas ocupadas por processos
    % externos e mantendo a lista de sockets UDP já criados.

    methods (Static = true)
        %-----------------------------------------------------------------%
        function releasePort(port)
            % Identifica conexões relacionadas à porta "port" que podem
            % inviabilizar a criação de um novo socket, encerrando os
            % processos que as mantêm.

            [~, commandOutput] = system(sprintf('netstat -ano | findstr "%d"', port));
            processIds         = unique(regexp(commandOutput, '\d+$', 'match', 'lineanchors'));

            % A seguir o padrão do Windows de resposta à requisição "netstat -ano".
            % A expressão regular busca identificar apenas os PIDs dos processos
            % relacionados à porta sob análise (última coluna).

            % TCP    10.0.0.85:49252        52.109.164.2:443       ESTABLISHED     17128
            % TCP    [::1]:49682            [::1]:49681            ESTABLISHED     7488
            % UDP    0.0.0.0:123            *:*                                    16344
            % UDP    0.0.0.0:3702           *:*                                    4160

            if isempty(processIds)
                return
            end

            processIds = cellfun(@(x) str2double(x), processIds);

            % Exclui-se da lista a atual sessão do MATLAB. Caso contrário, o
            % próprio MATLAB seria fechado.
            processIds(processIds == feature('getpid')) = [];

            for processId = processIds(:)'
                system(sprintf('taskkill /F /PID %d', processId));
            end
        end

        %-----------------------------------------------------------------%
        function [udpPorts, portIdx] = findOrCreateUdpPort(udpPorts, port)
            portIdx = [];

            for ii = 1:numel(udpPorts)
                if udpPorts{ii}.LocalPort == port
                    portIdx = ii;
                    break
                end
            end

            if ~isempty(portIdx)
                return
            end

            portIdx = numel(udpPorts)+1;

            % O try/catch prevê possível erro na criação do objeto decorrente
            % de um bloqueio externo ao MATLAB (do sistema operacional, talvez).
            try
                util.SocketPorts.releasePort(port)
                udpPorts(portIdx) = {udpport('datagram', 'IPV4', 'LocalPort', port, 'ByteOrder', 'big-endian', 'Timeout', class.Constants.udpTimeout)};
            catch
                portIdx = [];
            end
        end
    end
end
