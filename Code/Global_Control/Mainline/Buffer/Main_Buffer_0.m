% 9/7/12 -- Script to operate the mainline speed control to save energy
% if the mainline section has identifid that it has pallets on it then
% it is to run- else the mainline will be unmoving when not in use. 
%Exit sensor is at transition between single and double belts
%%%%%%%%%%%%%%%%%%%%%%GLOBAL CONTROL VERSION%%%%%%%%%%%%%%%%%%%%%%%%
disp('Running the mainline buffer 0/speed control case')
toc 
% defien the intial state, and then run each sensor script once in first
% run mode to set up the required variables. 
state = [0 0];
entering_check
exiting_check
transfer_check
transferline_clear
Global_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
% no longer on first run 
first_run = 0;  
Go = exist(path2go);
%running_1 flag detects whether the run command has been sent to the motor
%singlebelton keeps the data from the motor to show if the command has been
%initiated by the motor yet, the same is true of the double belt flags 
while Go ==2 && Failure_Flag == 0
    disp('Start of Loop')
    toc
    disp('The number of pallets on the mainline is ')
    disp(no_pallets_mainline)
    disp(No_pallets_mainline2)
    % update the state by calculating the number of pallets on each
    % section. 
    state = [no_pallets_mainline,No_pallets_mainline2];
    exiting_check
    Global_Read; % finds all of the other values 
    Network_Write; % writes the data back so that the global controlelr can evaluate this untis performance.
    fault_matrix=[fault_matrix;toc,fault_flag]; % update the fault matrix so we can log the time in error. 
    Adjust_Belt_Speed; % we adjust the belt speed if required by calling this script. 
    %% New section to make decisions about arrivals from upstream using data communicated from the transfer unit sensor and 
    % to decide if the transfer unit has palced a pallet on the line 
    
    %% New section to gather data from downstream tarnsfer line to check if the end position is clear. 
    if size(State_Read,2) ~= 0 
        if State_Read(size(State_Read,2)) == 1
        % set the flag to show the previous state 
            transfer_previous_pallet=1; 
            disp('A Transfer is In Progress')
        else
            if transfer_previous_pallet == 1 
                disp('A Transfer has Just Been Completed')
                no_pallets_mainline=no_pallets_mainline+1;
                enteringflag = 1; 
            else
                disp('The Transfer Line In is Clear')
            end
            transfer_previous_pallet=0;
        end
    else 
        transfer_previous_pallet=0;
    end 
    % we check tos ee if any pallets have arrived since last we checked. 
    if eval(['Mainline_Clear_',num2str(Main_id)]) == 1
    % set the flag to show the previous state 
        if entering_previous_pallet == 0
            time_in_last = toc;
            disp('A Pallet has Entered the Line')
            toc
            %increment number of pallets on mainline 
            no_pallets_mainline = no_pallets_mainline +1; 
            enteringflag=1; 
        end 
    
        entering_previous_pallet=1;  
        disp('A Pallet Is Arriving')
    else
        disp('The Upstream Line In is Clear')
        entering_previous_pallet=0; 
    end
    
    
    % check to see if the belt is currently running or not 
    singlebelton = conveyor_1_GO.ReadFromNXT(Main);
    doublebelton = conveyor_2_GO.ReadFromNXT(Main);
    % check to see if any pallets have arrived
    
    
    % error case- if two pallet are back to back then the next section of
    % line will not start early enough to pull the first palelt on,
    % resulting in a jam- if the time the sensor ahs been blocked is too
    % long then start the line moving anyway to pull the double pallets on.
    
    
    % we check if the mainline was clear and if it is clear to check 
    % if any new pallets have arrived, with a section if a large block is
    % seen then we have two pallets arriving back to back. 
    if eval(['Mainline_Clear_',num2str(Main_id)]) == 1
       if eval(['Mainline_Clear_',num2str(Main_id),'_Prev']) == 0
           time_in_last = toc; 
       end 
       eval(['Mainline_Clear_',num2str(Main_id),'_Prev = 1;'])
       if (toc - time_in_last) > 5
            no_pallets_mainline = no_pallets_mainline + 2;
            time_in_last = toc; 
       end
    else 
        eval(['Mainline_Clear_',num2str(Main_id),'_Prev = 0;'])
    end 
        

    if no_pallets_mainline > 0 && Running_1 == 0
    % if the number of pallets on the mainline is greater than 0, start the
    % single belt of the mainline running if it isn't already 
        disp('Starting Single Belt')
        toc 
        if Running_1 == 0
            conveyor_1_GO.SendToNXT(Main);
        end
        time_on_1 = toc ; 
        Running_1 = 1 ;
    end 
    
   if (toc-time_out_last) > 10
       % in this error case the handover has not gone smoothly and so the
       % pallet has got stuck under the light sensor at the junction
       % between the single and double belts. To solve this case the
       % following must be used to help transfer the pallet. 
       conveyor_1_handover_stop.SendToNXT(Main);  
       size_index =size(time_in,1);
       time_in(size_index,1) = toc;
       time_out_last = toc;
       % change the time in to be the new time at which the handover had to
       % be made. 
   end 
    
   if no_pallets_mainline == 0 && Running_1 == 1
    % if the mainline is running and the number of pallets has
    % fallen to zero stop the mainline 
            disp('Stopping Single Belt')
            toc 
            conveyor_1_STOP.SendToNXT(Main);
            %StopMotor(MOTOR_B, 'off');
            time_off_1= toc;
            time_running_1 = time_running_1 + (time_off_1 - time_on_1);
            Running_1 = 0 ;
   end
    
   if exitingflag2 == 1 
       % if we see the exiting flag go high we see a pallet leaving the
       % single line and the double line needs to pick up the pallet. 
       No_pallets_mainline2 = No_pallets_mainline2 + 1;
       exitingflag2=0; 
       time_in =[time_in;toc,0];
   end
   
   
   if No_pallets_mainline2 > 0 && Running_2 ==0
       % if the double belt is not running and pallets are present then we
       % start it 
       disp('Starting Double Belt')
       toc
       conveyor_2_GO.SendToNXT(Main); 
       time_on_2 = toc; 
       Running_2 =1; 
   end
   
   if Running_2 ==1 
       % if the double belt is running we check to see if we can stop it. 
       size_timingmatrix =size(time_in);
       for index = 1:size_timingmatrix(1);
           if time_in(index,2) ==0 && toc - time_in(index,1) >= 20 % if the pallet has not emerged and the time is greater than 30 assume the pallet has left so update the leaving flag part of the array
               time_in(index,2) = 1; % update the out flag to be a 1 to prevent further reductions in no of pallets
               No_pallets_mainline2=No_pallets_mainline2 - 1; %note that the pallet has left the line 
           end
       end
   
       if No_pallets_mainline2 ==0 
           disp('The Double Belt Has Stopped')
            % change the flag to show that the belt has stopped 
            conveyor_2_STOP.SendToNXT(Main);
            Running_2 = 0 ; 
            % update the running time
            time_off_2 = toc;
            time_running_2 = time_running_2 + (time_off_2 - time_on_2);      
       end
   end 
disp('End of loop')
toc 
disp('-------------------------------------------------------------------')
% Check Go Still Exists 
Go = exist (path2go);
end 
% print the motor running time for the logs so we can compare the
% efficiency of various schemes. 
disp('The total motor running time is (in seconds)')
time_running_total = time_running_1+time_running_2;
disp(time_running_total)