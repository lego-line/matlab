% 9/7/12 -- Script to operate the mainline speed control to save energy
% if the mainline section has identifid that it has pallets on it then
% it is to run- else the mainline will be unmoving when not in use. 
%Exit sensor is at transition between single and double belts
state=[];
disp('Running the mainline buffer 0/speed control case')
toc 
%entering_check
exiting_check
transfer_check
transferline_clear
% no longer on first run 
 Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
first_run = 0;  
Go = exist(path2go);

%running_1 flag detects whether the run command has been sent to the motor
%singlebelton keeps the data from the motor to show if the command has been
%initiated by the motor yet, the same is true of the double belt flags 
time_in_last = 0; % variable to keep track of time of last entering pallet
time_out_last =0; 
while Go ==2 && Failure_Flag == 0
    disp('the number of pallets on the mainline is ')
    disp(no_pallets_mainline)
    disp(No_pallets_mainline2)
    state=[no_pallets_mainline,No_pallets_mainline2];
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    toc
    %entering_check
    %% entering check replacement code
    disp('Running an Entering Check - networked')
        if exist(filepath_Mval_main)~= 0 
            fid=fopen(filepath_Mval_main,'r');
            out=textscan(fid,local_format);
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')
            else     
                val_entering=str2num(out{1,1}{1,1});
                mainlineclear_entry = str2num(out{1,2}{1,1});
                Ent_matrix = [Ent_matrix; toc, val_entering,mainlineclear_entry];
                save(filepath_entval, 'Ent_matrix')


                if val_entering>mainlineclear_entry
                        disp('A Package is Detected at entry')
                        toc 
                        entering_previous_pallet=1;
                        if entering_previous_pallet == 0
                            time_in_last = toc;
                        end 
                else
                            disp('The Mainline is Clear') 
                            toc
                        if entering_previous_pallet == 1; 
                            disp('A Pallet has Entered the Line')
                            toc
                            %increment number of pallets on mainline 
                            no_pallets_mainline = no_pallets_mainline +1; 
                            enteringflag=1; 
                        end 
                            % reset the previous pallet flag to show there was no pallet present at
                            % last check 
                            entering_previous_pallet=0; 
                            time_in_last = toc;
                end
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            enteringflag = 0; 
        end

%%
    exiting_check
    %transfer_check
%%  Section for running a Transferline check 
        if exist(filepath_Platformstatus_main)~= 0 
            fid=fopen(filepath_Platformstatus_main,'r');
            out=textscan(fid,'%s');
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')    
            else     
                transfer_input = str2num(out{1,1}{1,1});
                if transfer_input == 1
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
                
                
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            enteringflag = 0; 
        end
%% Section for running a networked downstream check    
transferline_clear
%%
    
    singlebelton = conveyor_1_GO.ReadFromNXT(Main);
    doublebelton = conveyor_2_GO.ReadFromNXT(Main);
    % check to see if any pallets have arrived
    
    
    % error case- if two pallet are back to back then the next section of
    % line will not start early enough to pull the first palelt on,
    % resulting in a jam- if the time the sensor ahs been blocked is too
    % long then start the line moving anyway to pull the double pallets on.
 if enteringflag == 1
        if (toc - time_in_last) > 5
            no_pallets_mainline = no_pallets_mainline +1;
            time_in_last = toc; 
            disp('Double Mainline Entry Detected')
        end
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
       No_pallets_mainline2 = No_pallets_mainline2 + 1;
       exitingflag2=0; 
       time_in =[time_in;toc,0];
   end
   
   
   if No_pallets_mainline2 > 0 && Running_2 ==0
       disp('Starting Double Belt')
       toc
       conveyor_2_GO.SendToNXT(Main); 
       time_on_2 = toc; 
       Running_2 =1; 
   end
   
   if Running_2 ==1 
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

    % Check Go Still Exists 
    Go = exist (path2go);
end 
disp('The total motor running time is (in seconds)')
time_running_total = time_running_1+time_running_2;
disp(time_running_total)

