function receivedMessage = WriteRead(hReceiver, requiredInfo)

    % O uso do WRITEREAD é perigoso (de forma geral!). Foi evidenciado erro 
    % na requisição do valor de atenuação programado no analisador de espectro
    % (R&S FSL). Por conta disso, substitui-se WRITEREAD por WRITELINE+PAUSE+READ.
    
    % O STRTRIM, ao final, apaga tanto espaços quanto quebras de linhas, funcionando
    % como um leitor de caracteres seguido de um FLUSH.

    % Posteriormente, migrar todas as chamadas do WRITEREAD (fcn.gpsBuiltInReader, 
    % por exemplo) para essa função.

    writeline(hReceiver, requiredInfo);
    pause(.001)
    receivedMessage = strtrim(read(hReceiver, hReceiver.NumBytesAvailable, 'char'));
end