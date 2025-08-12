function folder = ProjectPath()
    folder = fileparts(fileparts(mfilename('fullpath')));
end