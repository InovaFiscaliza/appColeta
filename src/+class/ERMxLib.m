classdef ERMxLib < handle

    % Author.: Eric Magalhães Delgado
    % Date...: March 14, 2024
    % Version: 0.01

    properties
        %-----------------------------------------------------------------%
        Switch
        Antenna
    end


    methods
        %-----------------------------------------------------------------%
        function obj = ERMxLib(RootFolder)
            tempStruct  = jsondecode(fileread(fullfile(RootFolder, 'config', 'ERMxLib.json')));

            obj.Switch  = tempStruct.Switch;
            obj.Antenna = tempStruct.Antenna;
        end


        %-----------------------------------------------------------------%
        function msgError = MatrixSwitch(obj, InputPort, OutputPort)
            msgError = '';
            
            % SWITCH
            try
                hSwitch = tcpclient(obj.Switch.IP, obj.Switch.Port);
                [setCommand, getCommand] = MatrixControlMessages(obj, InputPort, OutputPort);

                for ii = 1:class.Constants.switchTimes
                    % Essencial a substituição do WRITEREAD pelo conjunto
                    % WRITELINE + PAUSE + READ.

                    writeline(hSwitch, setCommand);

                    pause(class.Constants.switchPause)
                    if strcmp(getCommand, read(hSwitch, hSwitch.NumBytesAvailable, 'char'))
                        break
                    else
                        if ii == class.Constants.switchTimes
                            error('Unexpected value (ERMxLib:MatrixSwitch)')
                        end
                    end
                end
                
            catch ME
                msgError = ME.message;
                return
            end
        end


        %-----------------------------------------------------------------%
        function [setCommand, getCommand] = MatrixControlMessages(obj, InputPort, OutputPort)
            setTerminator = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
            getTerminator = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'};

            idxTerminator = mod(InputPort+OutputPort-2, 9);

            % Exemplos:
            % - input 001, output 001: "{*zs,001,001}1" e "{zBs?001,001}a"
            % - input 002, output 001: "{*zs,001,002}2" e "{zBs?001,002}b"

            formattedInputPort  = FormatPort(obj, InputPort);
            formattedOutputPort = FormatPort(obj, OutputPort);

            setCommand = sprintf('{*zs,%s,%s}%s', formattedOutputPort, formattedInputPort, setTerminator{idxTerminator+1});
            getCommand = sprintf('{zBs?%s,%s}%s', formattedOutputPort, formattedInputPort, getTerminator{idxTerminator+1});
        end


        %-----------------------------------------------------------------%
        function formattedPort = FormatPort(obj, Port)
            formattedPort = num2str(Port);
            formattedPort = [repmat('0', 1, 3-numel(formattedPort)), formattedPort];
        end


        %-----------------------------------------------------------------%
        function controlMessageTable = ExportControlMessages(obj, FullFileName)
            controlMessageTable = table('Size', [32, 3],                             ...
                                        'VariableTypes', {'double', 'cell', 'cell'}, ...
                                        'VariableNames', {'inputPort', 'set', 'get'});
            for ii = 1:32
                [setCommand, getCommand]  = obj.MatrixControlMessages(ii, 1);
                controlMessageTable(ii,:) = {ii, setCommand, getCommand};
            end
            
            if nargin == 2
                writetable(controlMessageTable, FullFileName)
            end
        end
    end
end
        