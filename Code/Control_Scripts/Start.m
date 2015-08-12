% Start.m - script file to strat the legoline after initialisation has been
% completed. 

% read in the state of the start and stop files to see what exists 
Stop = exist (path2stop);
Go = exist (path2go);

% if statement to stop the user doing something that would cause unusual
% operations such as double selecting and option 
if Ready_Flag == 1
    % in this case the line is ready to start and so actions msut be taken
    % to start the line. 
    
    % if the stop file exists then change it to the go file to start the line
    % running 
    if Stop == 2
        movefile(path2stop,path2go);
    end
    disp('The Line Has Been Started')
    Ready_Flag = 2; 
    % set the ready flag to show the unit has been started 
elseif Ready_Flag == 2
    % in this case the start command has already been issued and so issuing
    % it again would be redundant and such the user must be notified 
    disp('The Line Has Already Been Started')
    warndlg('The Line has already been started, press Finish to end current run','Legoline Warning Dialogue')
elseif Ready_Flag == 0
    % in this case the line has not been initailised yet and so cannot
    % start, thus the user needs warning and no action taken 
    disp('The Line Cannot Be Started if Not Initialised')
    warndlg('The Line Cannot Be Started as it Has Not Been Initialised','Legoline Warning Dialogue')
end 