% Write_Splitter_Startup.m
% Given a value of Splitter_id to denote which line segment the unit corresponds
% to this script can autoamtically generate the appropriate start up file
% and place it as required. This allows modular operations; all resources
% in the code folder and its subdirectories are universal providing the
% Splitter id is known. This file will generate a script which can be run at
% the start of a matlab instance to set up that instance as tagged to a
% particualr unit with a unique feed line id it will generate the header
% script which can be called with the new instance to set up all of the
% relevant identity variables and start utilising the common resources. It
% is called as part of the initialise routine. 

% generate the file name and location and open the file for writing
filename=['Splitter_Unit_',num2str(Splitter_id),'.m'];
filepath=[path2splitterstartup,filename];
handle_temp = fopen(filepath,'w');
% this command prints a diary command, instructing matlab to record all
% output to the screen in a log file in the Control/Logs/Error_Logs folder
% with a name Splitter_X.log. 
fprintf(handle_temp,['diary([path2eventlog,''Splitter_unit'',''',num2str(Splitter_id),''',''.log''])','\n']);
% this prints a command which sets up a variable in the workspace called
% Splitter_id with a value corresponding to the number of the splitter
string = ['Splitter_id = ',num2str(Splitter_id),';'];
fprintf(handle_temp,[string,'\n']);
% some headers for the log file are printed in the form of disp commands 
% the first prints out the number of the type and number of the unit being
% run 
string = ['disp(''Running Splitter ',num2str(Splitter_id),''')'];
fprintf(handle_temp,[string,'\n']);
% these commands print matlab code into the new file which acquire the time
% and date and then print them to the screen via disp such that thye appear
% at the top of the log file such that the time and date of the run can be
% obtained by inspection if the files become confused 
fprintf(handle_temp,['time=clock;','\n']);
fprintf(handle_temp,['date = [num2str(time(3)),'' / '',num2str(time(2)),'' / '',num2str(time(1))];','\n']);
fprintf(handle_temp,['disp(date)','\n']);
fprintf(handle_temp,['time=[num2str(time(4)),'' : '',num2str(time(5)),'' : '',num2str(time(6))];','\n']);
fprintf(handle_temp,['disp(time)','\n']);
% these print commands into the file to cleanup vraibales which would no
% longer be needed 
fprintf(handle_temp,['clear time','\n']);
fprintf(handle_temp,['clear date','\n']);
fprintf(handle_temp,'Setup_Splitter;');
% close the file such that it may be used in matlab 
fclose(handle_temp);
% perform a little housekeeping to remove unwanted variables 
clear handle_temp
clear string
clear filename
clear filepath