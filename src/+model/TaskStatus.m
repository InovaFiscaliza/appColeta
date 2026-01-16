classdef TaskStatus

    enumeration
        %-----------------------------------------------------------------%
        Pending
        Running
        Completed
        Cancelled
        Error
    end

    methods
        %-----------------------------------------------------------------%
        function str = displayName(obj)
            switch obj
                case model.TaskStatus.Pending
                    str = 'Na fila';
                case model.TaskStatus.Running
                    str = 'Em andamento';
                case model.TaskStatus.Completed
                    str = 'Concluída';
                case model.TaskStatus.Cancelled
                    str = 'Cancelada';
                case model.TaskStatus.Error
                    str = 'Erro';
            end
        end
    end

end