function tcpSockets_PortRelease(Port)

    % Identifica conexões relacionados à porta "Port" que podem inviabilizar a
    % criação de um novo socket.

    [~, cmdout] = system(sprintf('netstat -ano | findstr "%d"', Port));
    pidList     = unique(regexp(cmdout, '\d+$', 'match', 'lineanchors'));

    % A seguir o padrão do Windows de resposta à requisição "netstat -ano".
    % A expressão regular busca identificar apenas os PIDs dos processos
    % relacionados à porta sob análise (última coluna).

    % TCP    10.0.0.85:49252        52.109.164.2:443       ESTABLISHED     17128
    % TCP    [::1]:49682            [::1]:49681            ESTABLISHED     7488
    % UDP    0.0.0.0:123            *:*                                    16344
    % UDP    0.0.0.0:3702           *:*                                    4160

    if ~isempty(pidList)
        pidList   = cellfun(@(x) str2double(x), pidList);
        pidMatlab = feature('getpid');

        % Exclui-se da lista de PIDs relacionados à porta sob análise o PID
        % da atual sessão do MATLAB. Caso contrário, o próprio MATLAB seria 
        % fechado.
        
        pidList(pidList == pidMatlab) = [];
        if ~isempty(pidList)
            for ii = 1:numel(pidList)
                system(sprintf('taskkill /F /PID %d', pidList(ii)));
            end
        end
    end
end