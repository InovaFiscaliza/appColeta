classdef TSMWServerManager

    %---------------------------------------------------------------------%
    % ## model.TSMWServerManager ##
    %
    % Gerencia o processo local EtherDLL usado como servidor pelo R&S TSMW.
    % O caminho do executável e o endpoint são informados pelo chamador para
    % que esta classe não dependa de uma instalação específica do appColeta.
    %---------------------------------------------------------------------%

    methods (Static)
        %-----------------------------------------------------------------%
        function ensureRunning(executablePath, host, port, startupTimeout, allowEstablished)
            arguments
                executablePath (1, :) char
                host (1, :) char
                port (1, 1) double {mustBeInteger, mustBePositive}
                startupTimeout (1, 1) double {mustBePositive} = 10
                allowEstablished (1, 1) logical = false
            end

            if ~ispc
                error('ReceiverLib:EtherDLLUnsupportedPlatform', ...
                    'A inicialização automática do EtherDLL está disponível somente no Windows.')
            end

            if isempty(executablePath) || exist(executablePath, 'file') ~= 2
                error('ReceiverLib:EtherDLLNotFound', ...
                    'Executável do EtherDLL não encontrado: "%s".', executablePath)
            end

            % Consulta o estado da porta sem abrir um socket cliente. O EtherDLL
            % aceita um cliente por vez: LISTENING permite uma nova conexão;
            % ESTABLISHED só é considerado pronto se o Receiver já possui o handle.
            [isListening, isEstablished] = model.TSMWServerManager.tcpPortState(port);
            if isListening || (allowEstablished && isEstablished)
                return
            end
            if isEstablished
                error('ReceiverLib:EtherDLLClientBusy', ...
                    'O EtherDLL já está conectado a outro cliente em %s:%d.', host, port)
            end

            [processRunning, processIds] = model.TSMWServerManager.findProcessIds();

            if processRunning
                managed = model.TSMWServerManager.managedProcessState('get');

                if isfinite(managed.processId) && ...
                        ismember(managed.processId, processIds) && ...
                        strcmpi(managed.executablePath, executablePath)
                    % O processo existe, mas não mantém a porta em escuta.
                    % Reinicia apenas o PID que esta instância iniciou.
                    model.TSMWServerManager.restartManaged(executablePath, host, port, startupTimeout)
                    return
                end
            end

            startedByManager = false;
            processObserved = false;

            if ~processRunning
                workingDirectory = fileparts(executablePath);
                command = sprintf('start "" /B /D "%s" "%s"', workingDirectory, executablePath);
                [status, commandOutput] = system(command);

                if status ~= 0
                    error('ReceiverLib:EtherDLLStartFailed', ...
                        'Não foi possível iniciar o EtherDLL: %s', strtrim(commandOutput))
                end

                startedByManager = true;
            end

            startupTic = tic;
            while toc(startupTic) < startupTimeout
                [processRunning, processIds] = model.TSMWServerManager.findProcessIds();

                if startedByManager && processRunning
                    processObserved = true;
                    model.TSMWServerManager.managedProcessState('set', processIds(1), executablePath);
                end

                [isListening, isEstablished] = model.TSMWServerManager.tcpPortState(port);
                if isListening || (allowEstablished && isEstablished)
                    return
                end
                if isEstablished
                    error('ReceiverLib:EtherDLLClientBusy', ...
                        'O EtherDLL já está conectado a outro cliente em %s:%d.', host, port)
                end

                if ~processRunning && (~startedByManager || processObserved)
                    error('ReceiverLib:EtherDLLExited', ...
                        'O processo etherdll.exe encerrou antes de disponibilizar o endpoint TCP.')
                end

                pause(0.1)
            end

            error('ReceiverLib:EtherDLLStartupTimeout', ...
                'O EtherDLL não disponibilizou %s:%d em até %.1f segundos.', ...
                host, port, startupTimeout)
        end

        %-----------------------------------------------------------------%
        function restartManaged(executablePath, host, port, startupTimeout)
            arguments
                executablePath (1, :) char
                host (1, :) char
                port (1, 1) double {mustBeInteger, mustBePositive}
                startupTimeout (1, 1) double {mustBePositive} = 10
            end

            if ~ispc
                error('ReceiverLib:EtherDLLUnsupportedPlatform', ...
                    'A inicialização automática do EtherDLL está disponível somente no Windows.')
            end

            if isempty(executablePath) || exist(executablePath, 'file') ~= 2
                error('ReceiverLib:EtherDLLNotFound', ...
                    'Executável do EtherDLL não encontrado: "%s".', executablePath)
            end

            managed = model.TSMWServerManager.managedProcessState('get');
            managedProcessId = managed.processId;
            managedPath = managed.executablePath;
            if ~isfinite(managedProcessId) || ~strcmpi(managedPath, executablePath)
                error('ReceiverLib:EtherDLLNotManaged', ...
                    ['O EtherDLL em execução não foi iniciado por esta instância do appColeta. ' ...
                     'Por segurança, o processo não será encerrado automaticamente.'])
            end

            [~, processIds] = model.TSMWServerManager.findProcessIds();
            if ismember(managedProcessId, processIds)
                command = sprintf('taskkill /F /PID %.0f', managedProcessId);
                [status, commandOutput] = system(command);

                [~, processIds] = model.TSMWServerManager.findProcessIds();
                if status ~= 0 && ismember(managedProcessId, processIds)
                    error('ReceiverLib:EtherDLLStopFailed', ...
                        'Não foi possível encerrar o EtherDLL gerenciado: %s', strtrim(commandOutput))
                end

                stopTic = tic;
                while toc(stopTic) < 5
                    [~, processIds] = model.TSMWServerManager.findProcessIds();
                    if ~ismember(managedProcessId, processIds)
                        break
                    end
                    pause(0.1)
                end

                if ismember(managedProcessId, processIds)
                    error('ReceiverLib:EtherDLLStopTimeout', ...
                        'O processo etherdll.exe não encerrou dentro do prazo esperado.')
                end
            end

            model.TSMWServerManager.managedProcessState('clear');

            % ensureRunning inicia novamente o executável e registra o novo PID.
            model.TSMWServerManager.ensureRunning(executablePath, host, port, startupTimeout)
        end
    end


    methods (Static, Access = private)
        %-----------------------------------------------------------------%
        function state = managedProcessState(action, processId, executablePath)
            persistent managedProcessId managedExecutablePath

            if isempty(managedProcessId)
                managedProcessId = NaN;
                managedExecutablePath = '';
            end

            switch action
                case 'get'
                    state = struct('processId', managedProcessId, 'executablePath', managedExecutablePath);

                case 'set'
                    managedProcessId = processId;
                    managedExecutablePath = executablePath;
                    state = struct('processId', managedProcessId, 'executablePath', managedExecutablePath);

                case 'clear'
                    managedProcessId = NaN;
                    managedExecutablePath = '';
                    state = struct('processId', managedProcessId, 'executablePath', managedExecutablePath);

                otherwise
                    error('ReceiverLib:EtherDLLInvalidStateAction', ...
                        'Ação de estado do EtherDLL desconhecida: %s.', action)
            end
        end

        %-----------------------------------------------------------------%
        function [value, processIds] = findProcessIds()
            [status, commandOutput] = system('tasklist /FO CSV /NH /FI "IMAGENAME eq etherdll.exe"');

            if status ~= 0
                error('ReceiverLib:EtherDLLProcessCheckFailed', ...
                    'Não foi possível verificar se etherdll.exe está em execução: %s', ...
                    strtrim(commandOutput))
            end

            tokens = regexp(commandOutput, '(?im)^"etherdll\.exe","(\d+)"', 'tokens');
            processIds = cellfun(@(item) str2double(item{1}), tokens);
            value = ~isempty(processIds);
        end

        %-----------------------------------------------------------------%
        function [isListening, isEstablished] = tcpPortState(port)
            [status, commandOutput] = system('netstat -ano -p tcp');

            if status ~= 0
                error('ReceiverLib:EtherDLLPortCheckFailed', ...
                    'Não foi possível verificar as portas TCP em escuta: %s', ...
                    strtrim(commandOutput))
            end

            % O EtherDLL deixa de aparecer como LISTENING enquanto atende um
            % cliente; nesse caso, a linha da porta local fica ESTABLISHED.
            tokens = regexp(commandOutput, ...
                '(?im)^\s*TCP\s+\S+:(\d+)\s+\S+\s+(LISTENING|ESTABLISHED)\s+\d+\s*$', 'tokens');
            localPorts = cellfun(@(item) str2double(item{1}), tokens);
            states = cellfun(@(item) item{2}, tokens, 'UniformOutput', false);

            isListening   = any((localPorts == port) & strcmp(states, 'LISTENING'));
            isEstablished = any((localPorts == port) & strcmp(states, 'ESTABLISHED'));
        end
    end
end
