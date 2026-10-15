classdef TaskBand

    %---------------------------------------------------------------------%
    % ## model.TaskBand ##
    %
    % Estado de execução de uma banda de uma tarefa (model.Task.Bands).
    % Substitui a antiga "class.bandClass". A especificação configurada da
    % banda fica em model.TaskSpec (Script.Band).
    %---------------------------------------------------------------------%

    properties
        ScpiCommands = struct('configSET', {}, 'attSET', {})
        ReceiverState
        DataPoints
        Datagrams
        SyncModeRef = ''
        FlipArray
        NumSweeps = 0
        LastTimestamp
        RevisitTime
        Waterfall
        AzimuthTrace
        Mask
        OutputFile
        Antenna
        IsActive = true
        Uuid = char(matlab.lang.internal.uuid())
    end

    % Propriedades:
    % (a) 'ScpiCommands'   - Estrutura com a frase SCPI de configuração de parâmetros do receptor 
    %                        (FreqStart, FreqStop, RBW, StepWidth etc), além de frase SCPI de 
    %                        configuração do atenuador do receptor.
    % (b) 'ReceiverState'  - Estado de parâmetros do receptor pós-configuração (JSON).
    % (c) 'DataPoints'     - Número de pontos por traço.
    % (d) 'Datagrams'      - Estimativa do número de datagramas que representa 
    %                        um único traço (aplicável apenas para o receptor R&S EB500)
    % (e) 'SyncModeRef'    - Hash do vetor de níveis, o que é usado como valor de referência 
    %                        quando o modo de sincronismo usa o "ContinuousSweep", identificando 
    %                        se o traço é idêntico ao anterior, o que possibilita o seu descarte 
    %                        (aplicável apenas para o receptor Tektronix SA2500).
    % (f) 'FlipArray'      - Flag que indica se o vetor de níveis entregue pelo receptor 
    %                        precisa ser rotacionado (aplicável apenas para o MSAT).
    % (g) 'NumSweeps'      - Número de varreduras realizadas.
    % (h) 'LastTimestamp'  - Timestamp do instante em que foi extraído o último vetor 
    %                        de níveis.
    % (i) 'RevisitTime'    - Estimativa do tempo de revisita (média online, usando 
    %                        fator de integração definido no arquivo "GeneralSettings.json").
    % (j) 'Waterfall'      - Estrutura que armazena informações da última linha preenchida
    %                        ('idx'), da quantidade de traços que será armazenada ('Depth') 
    %                        e da matriz de níveis ('Matrix').
    % (k) 'AzimuthTrace'   - Vetor de azimutes do último traço (aplicável apenas para tarefas 
    %                        de direction finding).
    % (l) 'Mask'           - Estrutura da máscara de monitoração (vazia se não houver máscara).
    % (m) 'OutputFile'     - Estrutura que armazena informações da versão do arquivo
    %                        ('Fileversion'), do nome base do arquivo a ser criado ('Basename'), 
    %                        do contador de arquivos ('Filecount'), do número de traços escritos 
    %                        em arquivos ('WritedSamples') e do atual arquivo('CurrentFile')
    % (n) 'Antenna'        - Estrutura com nome da antena e seus parâmetros de configuração 
    %                        (altura, azimute, elevação e polarização).
    % (o) 'IsActive'       - true | false
    % (p) 'Uuid'           - Identificador único.
end
