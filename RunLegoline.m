% Script to run the Legoline program - it generates the path data to the
% folder and updates the matlab path as well as installing the toolkit if
% required and opening the user interface.

% the path data is regenerated each time this is called and the legoline
% folder set as the current working directory.
cd(Rootpath);

if exist(path2config) ==2
    % delete any old operating config file in case we want to set up a new
    % experiment or wish to resume one ( not yet added (20/04/13)
    delete(path2config);
end

if exist(path2errorlog) ==  2
    % delete any old error logs such that they do not interfere with the
    % new run 
    delete(path2errorlog);
end

if user_interface_flag == 0;
    %opens the user interface if it is not already open 
    Legoline_User_Interface
    user_interface_flag=1;
else
    % else if the window is already open drag it to the top so that the
    % user can see it 
    figure(101)
end


