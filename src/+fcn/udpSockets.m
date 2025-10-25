function [udpPortArray, idx] = udpSockets(udpPortArray, Port)

    idx = [];   
    for ii = 1:numel(udpPortArray)
        if udpPortArray{ii}.LocalPort == Port
            idx = ii;
            break
        end
    end
    
    if isempty(idx)
        idx = numel(udpPortArray)+1;

        % Inserido bloco try/catch prevendo possível erro na criação desse
        % objeto decorrente de um bloqueio externo ao MATLAB (do sistema
        % operacional, talvez).

        try
            fcn.tcpSockets_PortRelease(Port)
            udpPortArray(idx) = {udpport('datagram', 'IPV4', 'LocalPort', Port, 'ByteOrder', 'big-endian', 'Timeout', class.Constants.udpTimeout)};
        catch
            idx = [];
        end
    end
end