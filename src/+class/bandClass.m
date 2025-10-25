classdef bandClass

    % Author.: Eric Magalhães Delgado
    % Date...: July 15, 2023
    % Version: 1.00

    properties
        SpecificSCPI  = struct('configSET', {}, 'attSET', {})
        rawMetaData
        DataPoints
        Datagrams
        SyncModeRef   = -1
        FlipArray
        nSweeps       = 0
        LastTimeStamp
        RevisitTime
        Waterfall
        Mask
        File
        Antenna
        Status        = true
        uuid          = char(matlab.lang.internal.uuid())
    end

    % Propriedades:
    % (a) 'SpecificSCPI'   - Estrutura com a frase SCPI de configuração de parâmetros do receptor 
    %                        (FreqStart, FreqStop, RBW, StepWidth etc), além de frase SCPI de 
    %                        condifuração do atenuador do receptor.
    % (b) 'rawMetaData'    - Estado de parâmetros do receptor pós-configuração (JSON).
    % (c) 'FreqStart'      - Frequência a ser programada no receptor - trata-se de campo 
    %                        que possibilita a execução de tarefa em que há translação de 
    %                        frequência, como no caso do EMSat, o qual usa um LNB, translatando 
    %                        a faixa monitorada para a Banda L (1 a 2 GHz).
    % (d) 'FreqStop'       - Frequência a ser programada no receptor.
    % (e) 'Datagrams'      - Estimativa do número de datagramas que representa 
    %                        um único traço (aplicável apenas para o receptor R&S EB500)
    % (f) 'DataPoints'     - Número de pontos por traço.
    % (g) 'SyncModeRef'    - Soma do vetor de níveis, o que é usado como valor de referência 
    %                        quando o modo de sincronismo usa o "ContinuousSweep", identificando 
    %                        se o traço é idêntico ao anterior, o que possibilita o seu descarte 
    %                        (aplicável apenas para o receptor Tektronix SA2500).
    % (h) 'FlipArray'      - Flag que indica se o vetor de níveis entregue pelo receptor 
    %                        precisa ser rotacionado (aplicável apenas para o MSAT).
    % (i) 'nSweeps'        - Número de varreduras realizadas.
    % (j) 'LastTimeStamp'  - Timestamp do instante em que foi extraído o último vetor 
    %                        de níveis.
    % (k) 'RevisitTime'    - Estimativa do tempo de revisita (média online, usando 
    %                        fator de integração definido no arquivo "GeneralSettings.json").
    % (l) 'Waterfall'      - Estrutura que armazena informações da última linha preenchida
    %                        ('idx'), da quantidade de traços que será armazenada ('Depth') 
    %                        e da matriz de níveis ('Matrix').
    % (m) 'Mask'           - Estrutura que armazena informações da máscara ('Table', 'Array'), 
    %                        do contador de validações ('Validations'), do contador violações 
    %                        por bin ('BrokenArray'), do contador de vezes em que a máscara 
    %                        foi violada ('BrokenCount'), das principais emissões ('MainPeaks') 
    %                        e do instante em que foi registrada a última violação de máscara 
    %                       ('TimeStamp')
    % (n) 'File'           - Estrutura que armazena informações da versão do arquivo
    %                        ('Fileversion'), do nome base do arquivo a ser criado ('Basename'), 
    %                        do contador de arquivos ('Filecount'), do número de traços escritos 
    %                        em arquivos ('WritedSamples') e do atual arquivo('CurrentFile')
    % (o) 'Antenna'        - Estrutura com nome da antena e seus parâmetros de configuração 
    %                        (altura, azimute, elevação e polarização).
    % (p) 'Status'         - true | false
    % (q) 'uuid'           - Identificador único.
end