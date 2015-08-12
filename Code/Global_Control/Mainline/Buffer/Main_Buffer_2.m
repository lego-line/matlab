% 13/8/12 -- Script to operate the mainline buffer case where a buffer of
% two pallets is to be buffered at the end of the mainline.
%%%%%%%%%%%%%%%%%%%%%%GLOBAL CONTROL VERSION%%%%%%%%%%%%%%%%%%%%%%%%
disp('Running the mainline buffer 2 pallet case')
toc 
state = [0 0 0];
blockage = 0; 
entering_check
exiting_check
transfer_check
transferline_clear
Global_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
% no longer on first run 
first_run = 0;  
Go = exist(path2go);


while Go == 2 && Failure_Flag == 0
    disp('Start of Loop')
    toc 
    disp('the number of pallets on the mainline is ')
    disp(no_pallets_mainline)
    disp(No_pallets_mainline2)
    toc
    %entering_check
    exiting_check
    %transfer_check
   % transferline_clear
    Global_Read; % finds all of the other values 
    Network_Write; % writes the data back so that the global controlelr can evaluate this untis performance.
    fault_matrix=[fault_matrix;toc,fault_flag]; % update the fault matrix so we can log the time in error. 
    Adjust_Belt_Speed; % we adjust the belt speed if required by calling this script. 
    singlebelton1 = conveyor_1_step.ReadFromNXT(Main);
    singlebelton2 = conveyor_1_step2.ReadFromNXT(Main);
    doublebelton = conveyor_2_step.ReadFromNXT(Main);
    
    %% State cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [0 0 0]
        %take no action unless a new pallet arrives in which case we move
        %into the next state to process it. 
        disp ('State detected as 000')
        toc
            if enteringflag == 1
                state = [1 0 0];
                disp('State is now 100')
                enteringflag =0; 
            end
    end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    if state == [1 0 0]
        %move to state [0 1 0] - run single conveyor belt
        disp('state detected as 100') 
        disp('The Transfer State of belt 1 is:')
        disp(transfer_state_belt1)
        
        if transfer_state_belt1 ==1
            if enteringflag == 1
                % if there is an entry we have two palelts trying to occupy
                % the same space and we cannot resolve it, thus we have to
                % shutdown as the buffer is exceeded. 
                Kill_Line;
                disp('Arrival space already occupied - state [1 0 0] + entry') 
                Failure_Flag = 1;
                error_type ='Pallet Collision- State 100 + entry'; 
                toc
                enteringflag=0;
            else
                % if the process ahsn't compelted we display a message for
                % it. 
                conveyor_1_GO.SendToNXT(Main);
                disp('Pallet moving from Arrival to y')
                transfer_state_belt1=2;
            end
        end
        
        if transfer_state_belt1 == 2
            if exitingflag2 ==1
                  % stop the single belt on the trailing edge of the pallet 
                  conveyor_1_STOP.SendToNXT(Main);   
                  transfer_state_belt1 = 1; 
                 if enteringflag ==1
                    state = [1 1 0];
                    disp('State is now 110')
                    enteringflag=0;
                 else
                    disp('The belt has reached position y')
                    state = [0 1 0];
                    disp('State is now 010')
                 end
            end
        end 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [0 1 0]
        %move to state [0 0 1] - run double conveyor belt
        disp('state detected as 010')
        disp('The Transfer State of belt 2 is:')
        disp(transfer_state_belt2)
             
        if exitingflag==1
            exitingflag=0;
        end
            if transfer_state_belt2 == 1
                if enteringflag == 1
                    % if we see an entry then we have moved into another
                    % state
                        state = [1 1 0];
                        disp('State is now 110')
                        enteringflag =0;
                end  
                if doublebelton.IsRunning == 0
                    % if the belt has finsihed running then we mvoe from
                    % one state to another. 
                        conveyor_2_step.SendToNXT(Main);
                        disp('Pallet moving from y to x');
                        toc
                        transfer_state_belt2=2;
                        conveyor_1_handover_stop.SendToNXT(Main); 
               end
            end
            
            if transfer_state_belt2 == 2
                motoron2 = conveyor_2_step.ReadFromNXT(Main);
                if motoron2.IsRunning == 0
                      disp('The belt has reached position x')
                      transfer_state_belt2 = 1; 
                      if enteringflag == 1
                          state = [1 0 1];
                          disp('State is now 101')
                          enteringflag=0;
                      else
                          state = [0 0 1];
                          disp('State is now 001')
                      end
                end
            end
            exitingflag2 = 0;
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [0 0 1]
        disp('State detected as 001')
        disp('Blockage is')
        disp(blockage)
        if blockage == 1
            % if there is a blockage we hold the pallet, and check for
            % arrivals. 
            if enteringflag == 1
                state = [1 0 1];
                disp('State is now 101')
                enteringflag = 0;
            end    
        elseif blockage == 0
            % else if tehre is no blockage then we attempt to unlaod the
            % system and move to a new state. 
            conveyor_2_unload.SendToNXT(Main);
            if enteringflag == 0
                state = [0 0 0];
                disp('State is now 000')
            elseif enteringflag == 1
                state = [1 0 0];
                disp('State is now 100')
                enteringflag = 0;
            end
        end
    end
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    if state == [1 1 0]
        disp('State detected as 110')
        disp('The Transfer State of the double belt is:')
        disp(transfer_state_belt2)
        if enteringflag == 1
            Kill_Line;
            disp('Mainline buffer exceeded - state [1 1 0] + entry')  
            error_type ='Buffer Exceeded - State 110 + entry';
            Failure_Flag = 1; 
            toc
            enteringflag=0;
        end
        %move to state [1 0 1] - run double belt
        if transfer_state_belt2 == 1
                    % on the rising edge start the double belt to move the
                    % pallet to the buffer station 
                   if doublebelton.IsRunning == 0
                       conveyor_2_step.SendToNXT(Main);
                       disp('Pallet moving from y to x');
                       toc
                       transfer_state_belt2=2;
                   end
                   exitingflag2 = 0;  
        end
        
        if transfer_state_belt2 == 2
               motoron2 = conveyor_2_step.ReadFromNXT(Main);
               if motoron2.IsRunning == 0
                      disp('The belt has reached position x')
                      transfer_state_belt2 = 1; 
                      state = [1 0 1];
                      disp('state is now 101')
               end
        end          
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [0 1 1]
        disp('State detected as 011')
        if enteringflag == 1
            % if we see an entry then we have exceeded our buffer size and
            % so we must shutdown the line. 
                Kill_Line;
                disp('Mainline buffer exceeded - state [0 1 1] + entry')
                Failure_Flag = 1;
                error_type = 'Buffer Exceeded - state [0 1 1] + entry';
                toc
                enteringflag=0;
        end
   
        %move to state [0 0 1] - unload then end up in state [0 1 0]
        if blockage == 0
            %unload
            conveyor_2_unload.SendToNXT(Main);
            state = [0 1 0];
            disp('State is now 010')
        end   
    end
    
    if state == [1 0 1]
        disp('State detected as 101')
        if enteringflag==1
            % if a pallet arrives before the move is completed then we have
            % pallets trying to occupy the same space again and so we must
            % shutdown the system. 
            Kill_Line;
            disp('Arrival space already occupied - state [1 0 1] + entry')
            Failure_Flag = 1;
            error_type = 'Pallet Collision- state 101 +entry';
            toc
            enteringflag=0;
        end
        %move to state [0 1 1] - move single belt
        disp('The Transfer State of belt 1 is:')
        disp(transfer_state_belt1)
        
        if transfer_state_belt1 == 1
            conveyor_1_GO.SendToNXT(Main);
            disp('Pallet moving from Arrival to y')
            transfer_state_belt1=2;
        end
        
        if transfer_state_belt1 == 2
            if exitingflag2 ==1
                  % stop the single belt on the trailing edge of the pallet 
                  conveyor_1_STOP.SendToNXT(Main);   
                  transfer_state_belt1 = 1; 
                  
                  if enteringflag == 1
                        Kill_Line;
                        disp('Mainline Buffer exceeded - state [0 1 1] + entry')  
                        error_type = 'Buffer Exceeded- state 011 + entry';
                        toc
                        enteringflag =0;
                  else 
                        disp('The belt has reached position y')
                        state = [0 1 1];
                        disp('State is now 011')
                  end
            exitingflag2=0; 
            end
        end 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if state == [1 1 1]
       % if in state 111 we have exceeded the buffer size and so we have
       % to shut down the line. 
       disp('state detected as 111') 
       Kill_Line;
       disp('Mainline buffer exceeded') 
       Failure_Flag = 1;
       error_type ='Buffer Exceeded:State = 111'; 
       toc
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Check if GO.txt exists, otherwise loop will end   
disp('End of loop')
toc 
disp('-------------------------------------------------------------------')
Go = exist (path2go); 
end