% 13/8/12 -- Script to operate the mainline buffer case where a single
% pallet is to be buffered t the end of the mainline.
%%%%%%%%%%%%%%%%%%%%%%GLOBAL CONTROL VERSION%%%%%%%%%%%%%%%%%%%%%%%%
disp('Running the mainline buffer 1 pallet case')
toc 
blockage = 0; 
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
transfer_state =1; 

while Go == 2 && Failure_Flag == 0
    disp('Start of Loop')
    toc 
    disp('the number of pallets on the mainline is ')
    disp(no_pallets_mainline)
    disp(No_pallets_mainline2)
    toc
    exiting_check
    %transfer_check
    %transferline_clear % check if the transfer line is clear 
    Global_Read; % finds all of the other values 
    Network_Write; % writes the data back so that the global controlelr can evaluate this untis performance.
    fault_matrix=[fault_matrix;toc,fault_flag]; % update the fault matrix so we can log the time in error. 
    Adjust_Belt_Speed; % we adjust the belt speed if required by calling this script.  
%     if enteringflag == 1
%         state = [1,state(2)];
%         % put down the entering flag
%     end
    % We Check that the belts are on so we can determine if oeprations are
    % ongoing. 
    singlebelton1 = conveyor_1_step.ReadFromNXT(Main);
    singlebelton2 = conveyor_1_step2.ReadFromNXT(Main);
   
    doublebelton = conveyor_2_step.ReadFromNXT(Main);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if all(state == [0 0]) == 1
            disp('state detected as 00')
            toc
            if enteringflag == 1
                state = [1 0];
                enteringflag =0; 
            end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [1 0]
       disp('state detected as 10') 
       disp('The Transfer State is:')
       disp(transfer_state)
       if enteringflag == 1
                    Kill_Line;
                    disp('ERROR: Mainline buffer exceeded - state [1 0] + entry')  
                    error_type='Buffer Exceeded- - state [1 0] + entry';
                    toc
                    Failure_Flag = 1;
       end
            %move state from 10 to 01
            %if single belt is not moving yet, send command to start moving
            if transfer_state == 1
                conveyor_1_GO.SendToNXT(Main);
                disp('Pallet moving from Arrival to y')
                transfer_state=2;
            end
            
            if transfer_state == 2
                if exitingflag2 == 1
                    % on the rising edge start the double belt to move the
                    % pallet to the buffer station 
                   if doublebelton.IsRunning == 0
                       conveyor_2_step.SendToNXT(Main);
                       disp('Pallet moving from y to x');
                       toc
                       transfer_state=3;
                   end
                   exitingflag2 = 0;  
                end         
            end
            
            if transfer_state == 3
                if exitingflag ==1
                    % stop the single belt on the trailing edge of the pallet 
                    conveyor_1_STOP.SendToNXT(Main);   
                    transfer_state = 4; 
                end
                exitingflag=0;     
            end 

            if transfer_state == 4
                   motoron2 = conveyor_2_step.ReadFromNXT(Main);
                   if motoron2.IsRunning == 0
                        disp('The belt has reached position x')
                        transfer_state = 1; 
                        state = [0 1];
                        disp('state is now 01')
                   end
            end

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [0 1]
       disp('state detected as 01') 
       toc 
       if enteringflag == 1
           % if we are in state 01 and a pallet arrives we have 2 pallets
           % on the line and so we have exceeded out buffer size causing a
           % shutdown. 
            Kill_Line; 
            disp('ERROR: Mainline buffer exceeded - state [0 1] + entry') 
            Failure_Flag = 1;
            error_type = 'Buffer Exceeded- state [0 1] + entry';
            toc
       elseif blockage == 0
           %push the pallet off the edge if we are able to do so thus
           %freeing up the unit. 
           conveyor_2_unload.SendToNXT(Main);
           state = [0 0];
           disp('state is now 00')   
       end   
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [1 1]
        % if we are in state 1 1 then we have already exceeded our buffer
        % state and so we shut down. 
       disp('state detected as 11') 
       Kill_Line; 
       disp('ERROR: Mainline buffer exceeded State 11 achieved') 
       toc  
       Failure_Flag = 1;
       error_type ='Buffer Exceeded- State 11';
    end
disp('End of loop')
toc 
disp('-------------------------------------------------------------------')
Go = exist (path2go); 
%Check if GO.txt exists, otherwise loop will end   
end