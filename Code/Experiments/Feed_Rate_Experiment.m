% script file to run an experiment with a decreasing feed rate. The initial
% conditions should be set up in the config file 

Read_Config;
Experiment_Type =1;
disp('Running The Feed Rate Experiment')

% Declaration of Variables
% Run Is a counter giving the experiment number
Run = 4 ;
% failure is a flag which will be rasied if the run terminates early and
% marks the end of the experiment 
Failure =[0 0 0 0]; 
% Current rate keeps track of the current rate of the units 
Current_Rate= Initial_Rate;
%Time flag to store the start and end time of the current run 
Time_Started  = 0;
Time_Finished = 0; 
Results_Table=[];
Comments_Table=[];
%failure run gives the index of the runs which caused failures 
Failure_Run=[0 0 0 0];
% case 1 runs lines 1 and 2 only
% case 2 runs lines 2 and 3 only 
% case 3 runs lines 1 and 3 only
% case 4 runs all lines together
tic; %start the clock
selection_continue = questdlg('Continue the Feed Rate Experiment?','Legoline Experiment Confimation','Yes','No','Yes'); 
                switch selection_continue, 
                    case 'Yes'
                        
                    case 'No' 
                        
                end
for exptcase=1:4
    
    while Failure(exptcase) == 0 && Current_Rate >= Min_Rate
       
   
        disp('The Current Run is  ')
        disp(Run)
        %generate the new config file 
        % convert the curent size into a string for insertion into
        % the array
        Insert = num2str(Current_Rate);
        Insert0 = '0';
        Insert1 = '1';
        if exptcase == 1
            Relevant4{2,2} = Insert1;
            Relevant4{3,2} = Insert1;
            Relevant4{4,2} = Insert0;
        end
        if exptcase == 2
            Relevant4{2,2} = Insert0;
            Relevant4{3,2} = Insert1;
            Relevant4{4,2} = Insert1;   
        end
        if exptcase ==3
            Relevant4{2,2} = Insert1;
            Relevant4{3,2} = Insert0;
            Relevant4{4,2} = Insert1;
        end
        if exptcase == 4 
            Relevant4{2,2} = Insert1;
            Relevant4{3,2} = Insert1;
            Relevant4{4,2} = Insert1;               
        end
        Relevant5{1,3}=Insert;
        Relevant5{2,3}=Insert;
        Relevant5{3,3}=Insert;
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
                    Failure(exptcase) = 1;
                end
            pause(0.5)
        end

        Time_Finished = toc - Time_Started;
        Finish;
        
        Process_Results;
        Comments_Table = [Comments_Table;comments];
        
        if Current_Rate == Min_Rate
            Failure_Run(exptcase) = Run;
        end
        Results_Table  = [Results_Table;current_line,Failure(exptcase)];
        if Failure(exptcase) == 1; 
            Failure_Run(exptcase) = Run;
        end
        Current_Rate = Current_Rate - RateStep ;
        % increment the number of runs performed     
        Run=Run+1;           
    end
    
   Current_Rate = Initial_Rate;
   
end

CleanupVariables;
CleanupResults;