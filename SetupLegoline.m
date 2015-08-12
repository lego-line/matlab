% Script to run the Legoline program - it generates the path data to the
%folder and updates the matlab path as well as installing the toolkit if
%required and opening the user interface.

% the path data is regenerated each time this is called and the legoline
% folder set as the current working directory.
if ispc == 1 || isunix == 1
    % find the root path mapping out all of the file structure and the
    % ensure end up in the root directory for operations 
    FindRootPath;
    cd(Rootpath);
    
    % if it has not already been done previously in the session the file
    % structure is mapped;
    if exist ('Feed_Rate_Experiment') == 0
        addpath(genpath(Rootpath),path)
    end
    
    % replace any config file with the default config file stored in the
    % GUi folder to allow the suer to edit by hand if required. 
    if ispc == 1
        copyfile(path2masterconfig,path2writableconfig);
    elseif isunix == 1
        command = ['yes| cp -r -f ' path2masterconfig '*' ' ' path2writableconfig];
        system(command);
    end 
    % set an intialise flag - this show the line in ready to be initialised
    % before oeprations start, used by the command files start initialise
    % finish to prevent the user from button bashing and confusing the line
    initialise_flag =0; 
    % user interface flag shows that the GUi is not yet open 
    user_interface_flag=0;
    % shows the line is not yet ready to run 
    Ready_Flag = 0; 
else
    disp('The operating system you are running is not supported; please use either a Linux Distribution or Windwos OS to run Legoline')
end 


