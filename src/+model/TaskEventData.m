classdef TaskEventData < event.EventData

    %---------------------------------------------------------------------%
    % ## model.TaskEventData ##
    %
    % Estrutura de dados usada nos eventos disparados por model.TaskController
    % para notificar a UI (winAppColeta_exported.m) sobre mudanças ocorridas
    % durante a execução do loop de monitoração (model.TaskController.runLoop),
    % sem que o controller precise conhecer ou manipular diretamente os
    % componentes gráficos.
    %---------------------------------------------------------------------%

    properties
        TaskId
        BandId
        Payload
    end

    methods
        %-----------------------------------------------------------------%
        function obj = TaskEventData(taskIdx, bandIdx, payload)
            obj.TaskId = taskIdx;

            if nargin > 1
                obj.BandId = bandIdx;
            else
                obj.BandId = [];
            end

            if nargin > 2
                obj.Payload = payload;
            else
                obj.Payload = [];
            end
        end
    end

end
