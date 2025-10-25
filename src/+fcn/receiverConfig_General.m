function receiverConfig_General(obj, idx)

    newTask   = obj(idx).Task;
    instrInfo = obj(idx).Task.Receiver.Config;
    hReceiver = obj(idx).hReceiver;

    GeneralSCPI = struct('resetSET',   '',                                 ...
                         'startupSET', instrInfo.StartUp{1},               ...
                         'syncSET',    '',                                 ...
                         'attGET',     instrInfo.scpiQuery_Attenuation{1}, ...
                         'dataGET',    instrInfo.scpiTraceData{1});  

    if ~hReceiver.UserData.nTasks && strcmp(newTask.Receiver.Reset, 'On')
        GeneralSCPI.resetSET = instrInfo.scpiReset{1};
        writeline(hReceiver, instrInfo.scpiReset{1});

        pause(instrInfo.ResetPause)
    end
    
    writeline(hReceiver, instrInfo.StartUp{1});

    if ~hReceiver.UserData.nTasks
        switch newTask.Receiver.Sync
            case 'Single Sweep'; syncSET = 'INITiate:CONTinuous OFF';
            otherwise;           syncSET = 'INITiate:CONTinuous ON';       % 'Continuous Sweep' | 'Streaming'
        end
        GeneralSCPI.syncSET = syncSET;
        writeline(hReceiver, syncSET);
    end

    obj(idx).GeneralSCPI = GeneralSCPI;
end