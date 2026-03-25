classdef TaskController < handle

    %---------------------------------------------------------------------% 
    % ## model.TaskController ##
    %
    % Esse objeto é responsável pelo controle da execução das tarefas do
    % appColeta, buscando garantir que os tempos de revisita sejam respeitados
    % e que sejam gerenciados os erros da execução, iniciando tentativas de
    % reconexão de instrumento, caso necessário.
    %
    % app.TaskController = model.TaskController(struct( ...
    %     'ReceiverObj', app.ReceiverObj, ...
    %     'GpsObj',      app.GpsObj, ...
    %     'UDPPortObj',  app.UDPPortObj, ...
    %     'EB500Obj',    app.EB500Obj, ...
    %     'EMSatObj',    app.EMSatObj, ...
    %     'ERMxObj',     app.ERMxObj ...
    % ));
    %---------------------------------------------------------------------% 

    properties
        %-----------------------------------------------------------------%
        ReceiverObj
        GpsObj
    end


    properties (Access = private)
        %-----------------------------------------------------------------%
        IsRunning = false
        IsChanging = false
        
        TaskList
        UDPPortObj
        EB500Obj
        EMSatObj
        ERMxObj
    end


    methods
        %-----------------------------------------------------------------%
        function obj = TaskController(relatedObjHandles)
            relatedObjFields = fieldnames(relatedObjHandles);

            for ii = 1:numel(relatedObjFields)
                field = relatedObjFields{ii};
                if isprop(obj, field)
                    obj.(field) = relatedObjHandles.(field);
                end
            end
        end

        %-----------------------------------------------------------------%
        function start(obj)
            obj.IsRunning = true;
            obj.runLoop();
        end

        %-----------------------------------------------------------------%
        function stop(obj)
            obj.IsRunning = false;
        end

        %-----------------------------------------------------------------%
        function updateTaskList(obj)
            obj.IsChanging = true;
        end
    end


    methods (Access = private)
        %-----------------------------------------------------------------%
        function runLoop(obj)
            while obj.IsRunning
                % ...
            end
        end
    end

end