% Script to run the Legoline program - it generates the path data to the
% folder and updates the matlab path as well as installing the toolkit if
% required and opening the user interface.

% the path data is regenerated each time this is called and the legoline
% folder set as the current working directory.
FindRootPath;
cd(Rootpath);
% if it has not already been done previously in the session the file
% structure is mapped;
if exist ('Feed_Rate_Experiment') == 0
    addpath(genpath(Rootpath),path)
end
% clears out any existing config file so that it does not interfere with
% oeprations 

initialise_flag =0; 
user_interface_flag=0;
Ready_Flag = 0; 
