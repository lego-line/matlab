% script file to run an experiment with a decreasing pallet buffer size. The initial
% conditions should be set up in the config file 
Read_Config;
Experiment_Type =2;
disp('Running The Buffer Size Experiment')
% Declaration of Variables
% Run Is a counter giving the experiment number
Run=4;
Failure=[0 0 0];
% Current size keeps track of the current buffer size of the units 
Current_Size = Maximum_Size;
%Time flag to store the start and end time of the current run 
Time_Started  = 0;
Time_Finished = 0; 
% Results_Table is a table which will be fileld in with experimental data
% as the line progresses 
Results_Table=[];
Comments_Table=[];
%array to track the current failure size
Failure_Size=[0 0 0];
tic; % START THE CLOCK
% section to find the three extreme points and the values obtained with
% them 
% Unit Keeps track of the current line being investigated
for unit = 1:3
  % sequentially decrease the buffer size until failure occurs 
    while Failure(unit) == 0 && Current_Size >= Min_Size
        disp('Please Reload The Unit Then Press Enter To Continue')
        pause();
        disp('The Current Run is  ')
        disp(Run)
        %generate the new config file 
        %convert the current run size to a string for insertion into the
        %table 
        insert=num2str(Current_Size);
        Relevant4{2,2}= '0';
        Relevant4{3,2}= '0';
        Relevant4{4,2}= '0';
        Relevant4{(unit+1),2}='1';
        Relevant4{(unit+1),3}=insert;
        Print_Config;
        initialise;
        disp('Press Enter When Initialisation Is Complete')
        pause();
        Start;
         Time_Started = toc;
         while toc - Time_Started <= Time_To_Pass
             % run the experiment aiming for the specified time, if the unit fails
             % before this and stops then raise the failure flag 
             Go= exist(path2go);
                 if Go == 0
                     Failure(unit) = 1;
                 end
            pause(0.5)
         end
        Time_Finished = toc - Time_Started;
        %Finish;
        Process_Results;
        Comments_Table = [Comments_Table;comments];
        Results_Table  = [Results_Table;current_line,Time_Finished,Failure(unit)];
        if Current_Size == Min_Size
            Failure_Size(unit) = Current_Size;
        end 
        if Failure(unit) == 1;
            Failure_Size(unit) = Current_Size;
        end
        Current_Size = Current_Size - 1 ;
        % increment the number of runs performed     
        Run=Run+1;           
    end
    % after the unit has ended its run setup the Current_Size for the enxt
    % run 
Current_Size = Maximum_Size;
end
CleanupVariables;
CleanupResults;