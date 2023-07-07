classdef specClass

    % Author.: Eric Magalhães Delgado
    % Date...: July 5, 2023
    % Version: 1.00

    properties
        ID
        taskObj     = []
        Observation = struct('Created',    '', ...                          % Datestring data type - Format: '24/02/2023 14:00:00'
                             'BeginTime',  [], ...                          % Datetime data type
                             'EndTime',    [], ...                          % Datetime data type
                             'StartUp',    NaT)                             % Datetime data type
    
        hReceiver                                                           % Handle to Receiver
        hStreaming                                                          % Handle to UDP socket (generated by R&S EB500)
        hGPS                                                                % Handle to GPS

        lastGPS     = struct('Status', 0, 'Latitude', -1, 'Longitude', -1, 'TimeStamp', '')
        SCPI        = []                                                    % See "connect_Receiver_WriteReadTest.m"
        Band        = []                                                    % See "connect_Receiver_WriteReadTest.m"
        Status      = ''                                                    % 'Na fila' | 'Em andamento' | 'Concluída' | 'Cancelada' | 'Erro'
        LOG         = struct('type', {}, 'time', {}, 'msg',  {})
    end


    % Propriedade "Band" criada em "connect_Receiver_WriteReadTest.m".
    % Trata-se de uma estruta com os campos:
    
    % (a) 'scpiSet_Config' - Frase SCPI de configuração de parâmetros do receptor 
    %                        (FreqStart, FreqStop, RBW, StepWidth etc).
    % (b) 'scpiSet_Att'    - Frase SCPI de condifuração do atenuador do receptor.
    % (c) 'scpiSet_Answer' - Estado de parâmetros do receptor pós-configuração.
    % (d) 'Datagrams'      - Estimativa do número de datagramas que representa 
    %                        um único traço (aplicável apenas para o receptor R&S EB500)
    % (e) 'DataPoints'     - Número de pontos por traço.
    % (f) 'SyncModeRef'    - Soma do vetor de níveis, o que é usado como valor de referência 
    %                        quando o modo de sincronismo usa o "ContinuousSweep", identificando 
    %                        se o traço é idêntico ao anterior, o que possibilita o seu descarte 
    %                        (aplicável apenas para o receptor Tektronix SA2500).
    % (g) 'FlipArray'      - Flag que indica se o vetor de níveis entregue pelo receptor 
    %                        precisa ser rotacionado (aplicável apenas para o MSAT).
    % (h) 'nSweeps'        - Número de varreduras realizadas.
    % (i) 'LastTimeStamp'  - Timestamp do instante em que foi extraído o último vetor 
    %                        de níveis.
    % (j) 'RevisitTime'    - Estimativa do tempo de revisita (média online, usando 
    %                        fator de integração definido no arquivo "GeneralSettings.json").
    % (k) 'Waterfall'      - Estrutura que armazena informações da última linha preenchida
    %                        ('idx'), da quantidade de traços que será armazenada ('Depth') 
    %                        e da matriz de níveis ('Matrix').
    % (l) 'Mask'           - Estrutura que armazena informações da máscara ('Table', 'Array'), 
    %                        do contador de validações ('Validations'), do contador violações 
    %                        por bin ('BrokenArray'), do contador de vezes em que a máscara 
    %                        foi violada ('BrokenCount'), das principais emissões ('MainPeaks') 
    %                        e do instante em que foi registrada a última violação de máscara 
    %                       ('TimeStamp')
    % (m) 'File'           - Estrutura que armazena informações da versão do arquivo
    %                        ('Fileversion'), do nome base do arquivo a ser criado ('Basename'), 
    %                        do contador de arquivos ('Filecount'), do número de traços escritos 
    %                        em arquivos ('WritedSamples') e do atual arquivo('CurrentFile')
    % (n) 'Antenna'        - JSON com nome da antena e seus parâmetros de configuração 
    %                        (altura, azimute, elevação e polarização).
    % (o) 'Status'         - true | false


    methods
        %-----------------------------------------------------------------%
        function [obj, idx] = AddOrEditTask(obj, taskObj, infoEdition)
            switch infoEdition.type
                case 'new'
                    idx = numel(obj)+1;
                    obj(idx).ID = idx;
                    obj(idx).Observation.Created = datestr(now, 'dd/mm/yyyy HH:MM:SS');

                case 'edit'
                    idx = infoEdition.idx;
            end
            
            obj(idx).taskObj    = taskObj;
            
            obj(idx).hReceiver  = taskObj.Receiver.Handle;
            obj(idx).hStreaming = taskObj.Streaming.Handle;
            obj(idx).hGPS       = taskObj.GPS.Handle;

            obj(idx).Observation.BeginTime = datetime(taskObj.General.Task.Observation.BeginTime, 'InputFormat', 'dd/MM/yyyy HH:mm:ss', 'Format', 'dd/MM/yyyy HH:mm:ss');
            obj(idx).Observation.EndTime   = datetime(taskObj.General.Task.Observation.EndTime,   'InputFormat', 'dd/MM/yyyy HH:mm:ss', 'Format', 'dd/MM/yyyy HH:mm:ss');

            obj = obj.startup_lastGPS(idx, taskObj.General.Task.GPS);
            obj = obj.startup_ReceiverTest(idx);
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function obj = startup_lastGPS(obj, idx, GPS)
            if strcmp(GPS.Type, 'Manual')
                obj(idx).lastGPS.Status    = -1;
                obj(idx).lastGPS.Latitude  = GPS.Latitude;
                obj(idx).lastGPS.Longitude = GPS.Longitude;
            end
            obj(idx).lastGPS.TimeStamp = obj(idx).Observation.Created;
        end


        %-----------------------------------------------------------------%
        function obj = startup_ReceiverTest(obj, idx)
            warnMsg  = {};
            errorMsg = '';
            try
                [obj(idx).SCPI, obj(idx).Band, warnMsg] = connect_ReceiverTest(obj(idx).taskObj);
            catch ME
                errorMsg = ME.message;
            end
            
            % STATUS/LOG
            if isempty(errorMsg)
                obj(idx).Status = 'Na fila';
                obj(idx).LOG(end+1) = struct('type', 'task',    'time', obj(idx).Observation.Created, 'msg', 'Incluída na fila a tarefa.');
            else
                obj(idx).Status = 'Erro';
                obj(idx).LOG(end+1) = struct('type', 'error',   'time', obj(idx).Observation.Created, 'msg', errorMsg);
            end
            
            if ~isempty(warnMsg)
                obj(idx).LOG(end+1) = struct('type', 'warning', 'time', obj(idx).Observation.Created, 'msg', warnMsg);
            end
        end
    end
end