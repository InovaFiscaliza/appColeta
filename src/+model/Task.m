classdef Task < handle

    %---------------------------------------------------------------------%
    % ## model.Task ##
    %
    % Esse objeto representa a lista de tarefas do appColeta, incluindo 
    % especificações, referências a instrumentos e controle de erros. Na
    % inicialização do app, cria-se uma instância vazia apenas para servir
    % como contêiner. As tarefas são adicionadas, editadas ou removidas
    % dessa instância.
    %
    % app.TaskList = model.Task.empty;
    %---------------------------------------------------------------------%

    properties
        TaskId (1,1) uint32
        Status (1,1) model.TaskStatus = model.TaskStatus.Pending
        Enable (1,1) logical = true
    
        Bands
        Timing = struct( ...
            'createdAt', '', ...
            'startedAt', NaT, ...
            'endedAt',   NaT, ...
            'startupAt', NaT ...
        )
    
        Connections = struct( ...
            'receiver', [], ...
            'stream',   [], ...
            'gps',      [] ...
        )
    
        ReceiverID
        ReceiverCommands = struct( ...
            'reset',   '', ...
            'startup', '', ...
            'sync',    '', ...
            'query',   '', ...
            'data',    '' ...
        )
    
        GpsLastFix = struct( ...
            'fixStatus', 0, ...
            'latitude',  NaN, ...
            'longitude', NaN, ...
            'timestamp', NaT ...
        )
    
        RetryPolicy = struct( ...
            'receiver', struct( ...
                'failureCount',   0, ...
                'firstFailureAt', NaT, ...
                'lastFailureAt',  NaT ...
            ), ...
            'gps', struct( ...
                'failureCount',   0, ...
                'firstFailureAt', NaT, ...
                'lastFailureAt',  NaT ...
            ) ...
        )
    
        LogEntries = struct( ...
            'level', {}, ...
            'timestamp', {}, ...
            'message',  {} ...
        )
    end


    methods
        %-----------------------------------------------------------------%
        function [obj, msg] = addTask(obj, taskController, taskSpecification, connectionHandles)
            msg = '';
            try
                idx = getNextTaskId(obj);

                obj(idx).TaskId = idx;
                obj(idx).Timing.createdAt = datestr(now, 'dd/mm/yyyy HH:MM:SS');
    
                obj(idx).Bands = taskSpecification.Bands;            
                obj(idx).Connections = connectionHandles;
                initializeInstruments(obj, idx, taskController, taskSpecification)

            catch ME
                msg = ME.message;
            end
        end

        %-----------------------------------------------------------------%
        function [obj, msg] = deleteTask(obj, idx, taskController)
            msg = '';
            try
                if obj(idx).Status == model.Task.Running
                    error('Task:UnexpectedStatus', 'Tarefa está em execução e precisa ser parada antes de ser excluída.')
                end
    
                updateTaskList(taskController, 'deleteTask', idx);
                delete(obj(idx))
                obj(idx) = [];
                
            catch ME
                msg = ME.message;
            end
        end

        %-----------------------------------------------------------------%
        function [obj, msg] = editTask(obj, idx, taskController, taskSpecification)
            msg = '';
            try
                if obj(idx).Status == model.Task.Running
                    error('Task:UnexpectedStatus', 'Tarefa está em execução e precisa ser parada antes de ser editada.')
                end

                obj(idx).Bands = taskSpecification.Bands;
                initializeInstruments(obj, idx, taskController, taskSpecification)

            catch ME
                msg = ME.message;
            end
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function taskId = getNextTaskId(obj)
            if isempty(obj)
                taskId = 1;
            else
                allIds = [obj.TaskId];
                taskId = max(allIds) + 1;
            end
        end

        %-----------------------------------------------------------------%
        function initializeInstruments(obj, idx, taskController, taskSpecification)
            [obj(idx).ReceiverID, obj(idx).ReceiverCommands] = initialization( ...
                taskController.ReceiverObj, ...
                obj(idx).Connections.receiver, ...
                taskSpecification ...
            );
            
            obj(idx).GPSLastFix = initialization( ...
                taskController.GPSObj, ...
                obj(idx).Connections.gps, ...
                taskSpecification ...
            );
        end
    end

end