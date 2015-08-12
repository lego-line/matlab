% Finish.m Script file to perform the following tasks at the end of the run
% 1) If line is till running to shut it down
% 2) to move the error logs from various folders into the logs folder
% 3) to check for any errors which caused premature shutdown and report them 

% read the state of the start and Go variable files 
Stop = exist (path2stop);
Go = exist (path2go);

% use an if sattement to stop the user doing anything that may cause upset
% like button bashing 
if Ready_Flag == 0
    % in this case the unit is not yet initialised and hence a warning
    % needs displaying to this effect wihtout taking any action
    disp('Cannot Finish as The Line has Not Been Initialised or Started')
    warndlg('The Line Cannot Finish Until it Has Initialised and Started Operations','Legoline Warning Dialogue')
elseif Ready_Flag == 1
    % in this case the unit has not been started and hence a warning needs
    % to be put up in order to tell teh suer this without actually doing
    % anything 
    disp('Cannot Finish as The Line has Not Been Started')
    warndlg('The Line Cannot Finish Operations until it has started','Legoline Warning Dialogue')
else
    % else reset the ready flag to show the finished operation has taken
    % place and the line is ready to be re-initialised 
    Ready_Flag = 0; 
    % if the plant is running then shut it down 
    if Go == 2
        movefile(path2go,path2stop);
        Go = exist (path2go);
        disp('the line was running')
    end
    disp('the line is shutdown')
    % provide the user with some feedback 
   
    % section to remove all unwanted control files such as the config and
    % the control type 
    if exist(path2config)
        delete(path2config);
    end
    if exist(path2controltype)
        delete (path2controltype)
    end 
    % section to create the error dialogues and add to the workspace comments
    % about the reason for failure.
    if exist(path2errorlog) == 2   
        % read the error file which was created in initialise and perhaps
        % modified by one on the other instances if a failure caused the
        % shutdown 
        errortext = fileread(path2errorlog);
        if strcmp(errortext,'There was no error') == 1
            % if it reads no error then display that no error occured in
            % the on-screen log but no warning dialogue
            disp(errortext)
        else
            % else display the message onscreen as well as created a popup
            % box with the failure message to alert the user 
            disp(errortext)
            h = msgbox(errortext,'Legoline Failure Diagnostic','warn');  
        end
        % delete the error log as it is no longer required. 
        delete(path2errorlog)
    else
        % else the file ahs gone missing and the user should be warned 
        disp('There was No ErrorText File')
    end
end