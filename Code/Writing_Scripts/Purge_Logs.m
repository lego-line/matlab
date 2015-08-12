% script to erase all of the log files associated with a run to allow new
% log files to be generated.

%% section to remove all log files
delete([path2eventlog '*.log'])
 
%% Section To Delete All Feed Logs 
delete([path2feedlog '*.txt'])

%% Section To Delete Light Histories
delete([path2sensordata '*.mat'])
delete([path2sensordata '*.txt'])

%% section to remove all startup scripts 
delete([path2feedstartup '*.m'])
delete([path2transferstartup '*.m'])
delete([path2splitterstartup '*.m'])
delete([path2mainstartup '*.m'])
delete([path2databus '*.txt'])

%% Section to clear all failure data 
delete([path2failuredata '*.mat'])