% script file Kill_Line.m contains the code to shutdown the line when a
% unit fails. 
if CLOUD_FLAG == 0
    % if we are not cloud computing then we only need set GO.txt to
    % STOP.txt to shutodwn the whole line. 
    movefile(path2go,path2stop)
else
    % if we are cloud computing then we not only need set GO.txt to
    % STOP.txt to shutodwn the whole line but also do the same on any
    % secondary machines or processors. 
    movefile(path2go,path2stop)
end 