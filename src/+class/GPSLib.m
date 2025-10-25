classdef GPSLib < handle

    properties
        Config
        List   = table('Size', [0, 6],                                                      ...
                       'VariableTypes', {'cell', 'cell', 'cell', 'cell', 'cell', 'double'}, ...
                       'VariableNames', {'Family', 'Name', 'Type', 'Parameters', 'Description', 'Enable'})
        Table  = table('Size', [0, 4],                                          ...
                       'VariableTypes', {'string', 'string', 'cell', 'string'}, ...
                       'VariableNames', {'Family', 'Socket', 'Handle', 'Status'})
    end


    methods
        %-----------------------------------------------------------------%
        function obj = GPSLib(RootFolder)
            obj.Config = struct2table(jsondecode(fileread(fullfile(RootFolder, 'config', 'GPSLib.json'))));

            tempList = obj.FileRead(RootFolder);
            if ~isempty(tempList)
                obj.List = tempList;
            end
        end


        %-----------------------------------------------------------------%
        function [idx, msgError] = Connect(obj, instrSelected)
            % Características do instrumento em que se deseja controlar:
            Type = instrSelected.Type;
            [IP, Port, BaudRate, Timeout] = obj.MissingParameters(instrSelected.Parameters);

            switch Type
                case 'Serial';       Socket = Port;
                case 'TCPIP Socket'; Socket = sprintf("%s:%s", IP, Port);
            end

            % Consulta se já há objeto criado para o instrumento:
            msgError = '';
            idx = find(strcmp(obj.Table.Socket, Socket), 1);

            if ~isempty(idx)
                hGPS = obj.Table.Handle{idx};
                        
                warning('off', 'MATLAB:structOnObject')
                warning('off', 'transportlib:legacy:PropertyNotSupported')

                % Três tentativas para reestabelecer a comunicação, caso
                % esteja com falha.
                for kk = 1:3
                    try
                        switch Type
                            case 'Serial';       hTransport = struct(hGPS).Transport;
                            case 'TCPIP Socket'; hTransport = struct(struct(hGPS).TCPCustomClient).Transport;
                        end

                        if ~hTransport.Connected
                            hTransport.connect
                        end

                        if obj.ConnectionStatus(hGPS)
                            break
                        end

                    catch ME
                        switch ME.identifier
                            case 'network:tcpclient:connectFailed'
                                msgError = ME.message;
                                obj.Table.Status(idx) = 'Disconnected';
                                return
                            case {'MATLAB:class:InvalidHandle', 'testmeaslib:CustomDisplay:PropertyError'}
                                delete(obj.Table.Handle{idx})
                                obj.Table(idx,:) = [];
                                idx = [];
                                break
                        end
                    end
                    pause(.100)
                end
            end

            try
                if isempty(idx)
                    idx = height(obj.Table)+1;
                    switch Type
                        case 'Serial';       hGPS = serialport(Port, BaudRate);
                        case 'TCPIP Socket'; hGPS = tcpclient(IP, str2double(Port));
                    end
                    hGPS.Timeout = Timeout;

                    if ~ConnectionStatus(obj, hGPS)
                        error('GPSLib:NoData', 'No data received from GPS')
                    end
                end

                hGPS.UserData = struct('instrSelected', instrSelected);
                obj.Table{idx,:}   = {"GPS", Socket, hGPS, "Connected"};
      
            catch ME
                msgError = ME.message;
                if (idx > height(obj.Table)) & exist('hGPS', 'var')
                    clear hGPS
                end
                idx = [];
            end
        end


        %-----------------------------------------------------------------%
        function ReconnectAttempt(obj, instrSelected)
            Connect(obj, instrSelected);
        end


        %-----------------------------------------------------------------%
        function [tempList, msgError] = FileRead(obj, RootFolder)

            try
                tempList = fcn.instrumentListRead(fullfile(RootFolder, 'config', 'instrumentList.json'));
                tempList(~strcmp(tempList.Family, 'GPS'),:) = [];

                msgError = '';

            catch ME
                tempList = [];
                msgError = ME.message;
            end
        end
    end


    methods (Access = protected)
        %-----------------------------------------------------------------%
        function [IP, Port, BaudRate, Timeout] = MissingParameters(obj, Parameters)
            % IP
            if isfield(Parameters, 'IP');       IP = Parameters.IP;
            else;                               IP = '';
            end

            if strcmpi(IP, 'localhost');        IP = '127.0.0.1';
            end
        
            % Port
            if isfield(Parameters, 'Port');     Port = Parameters.Port;
            else;                               Port = [];
            end

            % BaudRate
            if isfield(Parameters, 'BaudRate'); BaudRate = Parameters.BaudRate;
            else;                               BaudRate = 9600;
            end

            % Timeout
            if isfield(Parameters, 'Timeout');  Timeout = Parameters.Timeout;
            else;                               Timeout = class.Constants.Timeout;
            end
        end


        %-----------------------------------------------------------------%
        function Status = ConnectionStatus(obj, hGPS)
            
            Status = false;
            flush(hGPS)

            statusTic = tic;
            t = toc(statusTic);
            while t < class.Constants.gpsTimeout
                if hGPS.NumBytesAvailable
                    Status = true;
                    break
                end
                t = toc(statusTic);
            end
        end
    end
end