% this script fiel is called from the main interface menu as a callback
% when the user requests to start the state draw function from the menu 

% check the existence of the state draw off file, replace it with the state
% draw yes file which is used to control the loop of the state draw script,
% if swapped from Yes to No then the state draw stops and the shuts down
% the instance
if exist(path2rundrawingN) ~= 0
    movefile(path2rundrawingN,path2rundrawingY);
end
% give the user some warning and start the insatcne of matlab which will
% house the scripts running the state draw system. 
disp('Starting to Monitor The State')
!matlab -nodesktop -minimize -nosplash -r FindRootPath;SetupLegoline;DrawStatus &