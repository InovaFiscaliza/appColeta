function receiverConfig_General(obj, idx)

    newTask   = obj(idx).TaskSpec;
    instrInfo = obj(idx).TaskSpec.Receiver.Config;
    hReceiver = obj(idx).Connections.receiver;

    ReceiverCommands = struct('reset',   '',                                 ...
                              'startup', instrInfo.StartUp{1},               ...
                              'sync',    '',                                 ...
                              'query',   instrInfo.scpiQuery_Attenuation{1}, ...
                              'data',    instrInfo.scpiTraceData{1});  

    if ~hReceiver.UserData.nTasks && strcmp(newTask.Receiver.Reset, 'On')
        ReceiverCommands.reset = instrInfo.scpiReset{1};
        writeline(hReceiver, instrInfo.scpiReset{1});

        pause(instrInfo.ResetPause)
    end
    
    writeline(hReceiver, instrInfo.StartUp{1});

    if ~hReceiver.UserData.nTasks
        switch newTask.Receiver.Sync
            case 'Single Sweep'; syncSET = 'INITiate:CONTinuous OFF';
            otherwise;           syncSET = 'INITiate:CONTinuous ON';       % 'Continuous Sweep' | 'Streaming'
        end
        ReceiverCommands.sync = syncSET;
        writeline(hReceiver, syncSET);
    end

    obj(idx).ReceiverCommands = ReceiverCommands;
end