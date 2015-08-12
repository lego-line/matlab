% Script to add the pathing data to each of the extra instances of matlab
% that are opened for each of the NXT's


% the order of inclusion matters, these add the folders in an order such
% that the top level folders are searched first, followed by lower level
% items, thus those items added first are searched after the others,
% allowing our toolkit to take precedence. 


    % add the RWTH Toolkit included in the Legoline folder to the MATLAb
    % path - this version must be included as it includes a few
    % modifications which shut down fialed instances of matlab
    % automatically such that no NXT links remain open as far aspossible
    % two harmless warnings are disabled for convenience
    addpath(genpath(path2toolkit),path)   
    warning off MATLAB:mir_warning_unrecognized_pragma
    warning off MATLAB:loadlibrary:TypeNotFoundForStructure
    % prepend all of the folders required for operation to the matlab path 
    addpath(path2databus,path)
    addpath(path2gui,path)
    addpath(path2userresults,path)
    addpath(genpath(path2experiments),path)
    addpath(path2feedlog,path)
    addpath(path2eventlog,path)
    addpath(genpath(path2common_scripts),path)
    addpath(genpath(path2startupscripts),path)
    
    % read in the control tyep required and decide which set of operating
    % files to allow the instance to see by adding the relevant sub folder
    % to the path 
    fid=fopen(path2controltype,'rt');
        out=textscan(fid,'%s');
    fclose(fid);
    
    control_type=out{1};
    if strcmp(control_type,'Local_Control') == 1
        addpath(genpath(path2localcontrol),path)
    elseif strcmp(control_type,'Global_Control') == 1
        addpath(genpath(path2globalcontrol),path)
    elseif strcmp(control_type,'Networked_Sensors') == 1
        addpath(genpath(path2networkedsensors),path)
    elseif strcmp(control_type,'Networked_Sensors_e') == 1
        addpath(genpath(path2networkedsensor_e),path)
    elseif strcmp(control_type,'Networked_Units') == 1
        addpath(genpath(path2networkedunits),path)
    elseif strcmp(control_type,'Networked_Units_e') == 1
        addpath(genpath(path2networkedunits_e),path)
    else
        disp('Invalid Control System')
        quit
    end
    % finally inser the top level folders required 

    addpath(path2code,path)
    addpath(path2control,path)
    addpath(Rootpath,path)

    Connection_Type = 'USB';
    CLOUD_FLAG = 0; 
    