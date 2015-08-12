% 13/8/12 -- Script to operate the mainline buffer case where a buffer of
% three pallets is to be buffered at the end of the mainline.
%%%%%%%%%%%%%%%%%%%%%%NETWORKED UNITS VERSION%%%%%%%%%%%%%%%%%%%%%%%%
disp('Running the mainline buffer 3 pallet case')
toc 
%entering_check
exiting_check
%transfer_check
%transferline_clear

Network_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
% no longer on first run 
state = [0 0 0 0];
% state is the three positions in order from the arrival point(1)tot the
% exit point(4)
first_run = 0;  
Go = exist(path2go);


while Go == 2 && Failure_Flag == 0
        disp('Start of loop')
    toc 
    % provide log feedback 
    disp('the number of pallets on the mainline is ')
    disp(no_pallets_mainline)
    disp(No_pallets_mainline2)
    toc
    % check the state of the sensors
    %entering_check
    exiting_check
    %transfer_check
    %transferline_clear
    Network_Read;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    % perform checks on the running state of the belts
    singlebelton1 = conveyor_1_step.ReadFromNXT(Main);
    singlebelton2 = conveyor_1_step2.ReadFromNXT(Main);
    doublebelton = conveyor_2_step.ReadFromNXT(Main);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [0 0 0 0]
        %take no action
        disp ('State detected as 0000')
        toc
            if enteringflag == 1
                state = [1 0 0 0];
                disp('State is now 1000')
                enteringflag =0; 
            end 
    end % end 0000 section 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 0 0 0]
        %move to state [0 1 0 0] - run single conveyor belt
        disp('state detected as 1000') 
        disp('The Transfer State of belt 1 is:')
        disp(transfer_state_belt1)
        
        if transfer_state_belt1 ==1
            if enteringflag == 1
                Kill_Line;
                disp('Arrival space already occupied - state [1 0 0 0] + entry')  
                Failure_Flag =1;
                error_type='Pallet Collision- state [1 0 0 0] + entry';
                toc
                enteringflag=0;
            else
                conveyor_1_step.WaitFor(0,Main)
                conveyor_1_handover_stop.WaitFor(0,Main)
                conveyor_1_step.SendToNXT(Main);
                disp('Pallet moving from Arrival to Z')
                transfer_state_belt1=2;
                time_on_single= toc; 
            end
        end % end of the belt running state 1 section
        motoron = conveyor_1_step.ReadFromNXT(Main);
        if transfer_state_belt1 == 2 && motoron.IsRunning == 0 && (toc-time_on_single) > delay_startup_time
            disp('The belt has reached position Z')
                 if enteringflag ==1
                    state = [1 1 0 0];
                    disp('State is now 1100')
                    enteringflag=0;
                 else
                    
                    state = [0 1 0 0];
                    disp('State is now 0100')
                 end
          transfer_state_belt1=1; 
        end% end of the belt running state 2 section 
    end % end 1000 section
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5 
    if state == [0 1 0 0]
        %move to state [0 0 1 0] - run single conveyor belt
        disp('state detected as 0100') 
        disp('The Transfer State of belt 1 is:')
        disp(transfer_state_belt1)
        if transfer_state_belt1 ==1 
            if enteringflag == 1
                state = [ 1 1 0 0];
                disp('The state is now 1100')
                enteringflag = 0; 
            else 
                conveyor_1_step.WaitFor(0,Main)
                conveyor_1_handover_stop.WaitFor(0,Main)
                conveyor_1_step.SendToNXT(Main);
                disp('Pallet moving from Z to Y')
                time_on_single = toc;
                transfer_state_belt1=2;    
            end 
        elseif transfer_state_belt1 == 2 && (toc-time_on_single) > delay_startup_time
            if exitingflag2 ==1
                  % stop the single belt on the trailing edge of the pallet   
                  transfer_state_belt1 = 1; 
                 if enteringflag ==1
                    state = [1 0 1 0];
                    disp('State is now 1010')
                    enteringflag=0;
                 else
                    disp('The belt has reached position Y')
                    state = [0 0 1 0];
                    disp('State is now 0010')
                 end
            end
        end % end of the belt running state section
    end % end 0100 section
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5 
    if state == [0 0 1 0]
        disp('state detected as 0010')
        disp('The Transfer State of belt 2 is:')
        disp(transfer_state_belt2)
             
        if exitingflag==1
            exitingflag=0;
        end
            if transfer_state_belt2 == 1
                if enteringflag == 1
                        state = [1 0 1 0];
                        disp('State is now 1010')
                        enteringflag =0;
                else
                        conveyor_1_step.WaitFor(0,Main);
                        conveyor_1_handover_stop.WaitFor(0,Main);
                        conveyor_2_unload.WaitFor(0,Main);
                        conveyor_2_step.SendToNXT(Main);
                        conveyor_1_handover_stop.SendToNXT(Main);
                        pause(0.1)
                        time_on_double = toc;
                        disp('Pallet moving from y to x');
                        toc
                        transfer_state_belt2=2;                                      
               end
            end % end of state = 1 section    
            if transfer_state_belt2 == 2
                motoron2 = conveyor_2_step.ReadFromNXT(Main);
                if motoron2.IsRunning == 0 && (toc - time_on_double) > delay_startup_time
                      disp('The belt has reached position x')
                      transfer_state_belt2 = 1; 
                      if enteringflag == 1
                          state = [1 0 0 1];
                          disp('State is now 1001')
                          enteringflag=0;
                      else
                          state = [0 0 0 1];
                          disp('State is now 0001')
                      end % end of checking if a pallet has arrived 
                end % end of checking if the saecond belt has compelted its move
            end % end of state 2 section 
            exitingflag2 = 0;
    end % end 0010 section
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5   
    if state == [0 0 0 1]
        disp('State detected as 0001')
        disp('Blockage is')
        disp(blockage)
        if blockage == 1
            if enteringflag == 1
                state = [1 0 0 1];
                disp('State is now 1001')
                enteringflag = 0;
            end    
        elseif blockage == 0
            conveyor_2_unload.WaitFor(0,Main);
            conveyor_2_step.WaitFor(0,Main);
            conveyor_2_unload.SendToNXT(Main);
            if enteringflag == 0
                state = [0 0 0 0];
                disp('State is now 0000')
            elseif enteringflag == 1
                state = [1 0 0 0];
                disp('State is now 1000')
                enteringflag = 0;
            end % end of checking entry
        end% end of checking blockage
    end % end 0001 state 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 1 0 0]
        % to move out of this state and free up the arrival space the first
        % belt must move- pushing both pallets towards the front of the
        % section
        disp('state detected as 1100')
        disp('The Transfer State of belt 1 is:')
        disp(transfer_state_belt1)
        if transfer_state_belt1 == 1
            if enteringflag == 1
                    Kill_Line;
                    disp('Arrival space already occupied - state [1 1 0 0] + entry')  
                    Failure_Flag = 1;
                    error_type = 'Pallet Collision- state [1 1 0 0] + entry';
                    toc
                    enteringflag=0;
            else
                conveyor_1_step.WaitFor(0,Main);
                conveyor_1_handover_stop.WaitFor(0,Main);
                conveyor_1_step.SendToNXT(Main);
                disp('Pallet moving from Z to Y and arrival to Z')
                transfer_state_belt1=2;  
                time_on_single = toc; 
            end
        elseif transfer_state_belt1 == 2
            motoron2 = conveyor_2_step.ReadFromNXT(Main);
                if motoron2.IsRunning == 0 && (toc - time_on_single) > delay_startup_time% if the movement is complete
                    if enteringflag == 1
                          state = [1 1 1 0];
                          disp('State is now 1110')
                          enteringflag=0;
                    else
                          state = [0 1 1 0];
                          disp('State is now 0110')
                    end % end of checking if a pallet has arrived 
                      transfer_state_belt1 = 1; 
                end% end of checking if the motor is running 
        end% end of transfer belt states 
    end% end state = 1100 section
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5  
    if state == [0 1 1 0]
        disp('state detected as 0110')
        disp('The Transfer State of belt 2 is:')
        disp(transfer_state_belt2)
        if transfer_state_belt1 == 1 && transfer_state_belt2 == 1 && enteringflag == 1
            % if the first belt is not moving and the second belt is alos
            % static then if a pallet arrives we end up in another state 
            state = [1 1 1 0];
            enteringflag=0;
        else
              if transfer_state_belt2 == 1
                        conveyor_2_unload.WaitFor(0,Main);
                        conveyor_2_step.WaitFor(0,Main);
                        conveyor_2_step.SendToNXT(Main);
                        disp('Pallet moving from y to x');
                        toc
                        transfer_state_belt2=2;
                        conveyor_1_step.WaitFor(0,Main);
                        conveyor_1_handover_stop.WaitFor(0,Main);
                        conveyor_1_step.SendToNXT(Main);
                        transfer_state_belt1=2;
                        time_on_single = toc;
                        time_on_double = toc; 
               end
         end % end of state = 1 section    
            if transfer_state_belt2 == 2
                motoron2 = conveyor_2_step.ReadFromNXT(Main);
                if motoron2.IsRunning == 0 && (toc - time_on_double) > delay_startup_time
                      disp('The belt has reached position x and position y')
                      transfer_state_belt2 = 1; 
                      exiting_check
                      % perform an exiting check to see if the second
                      % pallet has reached the handover stage if it has all
                      % is well, if is has not then run the belt until it
                      % arrives and then assess if an arrival has occured 
                      if exiting_previous_pallet == 0
                          conveyor_1_GO.SendToNXT(Main); 
                          while exiting_previous_pallet == 0
                            exiting_check
                          end
                          conveyor_1_STOP.SendToNXT(Main);
                      end
                      if enteringflag == 1
                              state = [1 0 1 1];
                              disp('State is now 1011')
                              enteringflag=0;
                      else
                              state = [0 0 1 1];
                              disp('State is now 0011')
                      end % end of checking if a pallet has arrived
                      transfer_state_belt1 = 1;
                end % end of checking if the saecond belt has compelted its move
            end % end of state 2 section        
    end % end of state = 0110 section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5    
    if state == [0 0 1 1]
        disp('State detected as 0011')
        disp('Blockage is')
        disp(blockage)
        if blockage == 1
            if enteringflag == 1
                state = [1 0 1 1];
                disp('State is now 1011')
                enteringflag = 0;
            end    
        elseif blockage == 0
            conveyor_2_unload.WaitFor(0,Main);
            conveyor_2_step.WaitFor(0,Main);
            conveyor_2_unload.SendToNXT(Main);
            if enteringflag == 0
                state = [0 0 1 0];
                disp('State is now 0010')
            elseif enteringflag == 1
                state = [1 0 1 0];
                disp('State is now 1010')
                enteringflag = 0;
            end % end of checking entry
        end% end of checking blockage
    end % end state = 0011 section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 0 1 0]
        % aim to get into state 0101 to take advantage of the movement of
        % the first belt to aid transition 
        disp('State detected as 1010')
        disp('The Transfer State of belt 1 is:')
        disp(transfer_state_belt1)
        disp('The Transfer State of belt 2 is:')
        disp(transfer_state_belt2)
        if transfer_state_belt1 == 1
            if enteringflag == 1
                Kill_Line;
                disp('Arrival space already occupied - state [1 0 1 0] + entry')
                Failure_Flag = 1;
                error_type = 'Pallet Collision - state [1 0 1 0] + entry';
                toc
                enteringflag=0;
            else 
                conveyor_1_step.WaitFor(0,Main);
                conveyor_1_handover_stop.WaitFor(0,Main);
                conveyor_1_step.SendToNXT(Main);
                conveyor_2_unload.WaitFor(0,Main);
                conveyor_2_step.WaitFor(0,Main);
                conveyor_2_step.SendToNXT(Main); 
                transfer_state_belt1 = 2; 
                transfer_state_belt2 = 2; 
                time_on_single = toc;
                time_on_double = toc; 
                disp('Transferring the state to 0101')
            end % end stage 1 loop 
        elseif transfer_state_belt1 == 2 && (toc - time_on_double) > delay_startup_time
                motoron2 = conveyor_2_step.ReadFromNXT(Main);  
                motoron1 = conveyor_1_step.ReadFromNXT(Main);
                if motoron2.IsRunning == 0 && motoron1.IsRunning == 0
                      disp('The belt has reached position X and position Z')
                      transfer_state_belt2 = 1; 
                      transfer_state_belt1 = 1;  
                      if enteringflag == 1
                              state = [1 1 0 1];
                              disp('State is now 1101')
                              enteringflag=0;
                      else
                              state = [0 1 0 1];
                              disp('State is now 0101')
                      end % end of checking if a pallet has arrived
                      
                end % end of checking if the saecond belt has compelted its move
          end % end of state 2 section        
    end % end of case 1010 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [0 1 0 1]
        disp('State detected as 0101')
        disp('Blockage is')
        disp(blockage)
        if blockage == 1 
            if transfer_state_belt1 == 1
                if enteringflag == 1
                    state = [1 1 0 1];
                    disp('State is now 1101')
                    enteringflag = 0;
                else
                    conveyor_1_step.WaitFor(0,Main);
                    conveyor_1_handover_stop.WaitFor(0,Main);
                    conveyor_1_step.SendToNXT(Main);
                    disp('Pallet moving from Z to Y')
                    transfer_state_belt1=2;    
                    time_on_single = toc;
                end % end of checking the entering flag 
            end % end of state 1 
            if transfer_state_belt1 == 2
                if exitingflag2 ==1
                  % stop the single belt on the trailing edge of the pallet 
                    transfer_state_belt1 = 1; 
                    if enteringflag ==1
                        state = [1 0 1 1];
                        disp('State is now 1011')
                        enteringflag=0;
                    else
                        disp('The belt has reached position Y')
                        state = [0 0 1 1];
                        disp('State is now 0011')
                    end
                    exitingflag2 =0; 
                end
            end% end of state 2 section
        elseif blockage == 0
            conveyor_2_unload.WaitFor(0,Main);
            conveyor_2_step.WaitFor(0,Main);
            conveyor_2_unload.SendToNXT(Main);
            if enteringflag == 0
                state = [0 1 0 0];
                disp('State is now 0100')
            elseif enteringflag == 1
                state = [1 1 0 0];
                disp('State is now 1100')
                enteringflag = 0;
            end % end of checking entry
        end% end of checking blockage
    end % end of state 0101 section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 0 0 1]
        disp('State detected as 1001')
        disp('Blockage is')
        disp(blockage)
        if enteringflag == 1
            Kill_Line;
            disp('Arrival space already occupied - state [1 0 0 1] + entry') 
            Failure_Flag =1;
            error_type = 'Pallet Collision -state [1 0 0 1] + entry';
            toc
            enteringflag=0;
        else
            if blockage == 0
                conveyor_2_unload.WaitFor(0,Main);
                conveyor_2_step.WaitFor(0,Main);
                conveyor_2_unload.SendToNXT(Main);
                state = [1 0 0 0];
                disp('State is now 1000')
            else 
                if transfer_state_belt1 == 1;           
                    conveyor_1_step.WaitFor(0,Main);
                    conveyor_1_handover_stop.WaitFor(0,Main);
                    conveyor_1_step.SendToNXT(Main); 
                    transfer_state_belt1 = 2; 
                    time_on_single = toc;
                    disp('Moving the pallet from arrival to Z')
                elseif transfer_state_belt1 == 2 && ( toc - time_on_double) > delay_startup_time
                    motoron = conveyor_1_step.ReadFromNXT(Main);
                    if  motoron.IsRunning == 0 
                      disp('The belt has reached position Z')
                            if enteringflag ==1
                                state = [1 1 0 1];
                                disp('State is now 1101')
                                enteringflag=0;
                            else
                                state = [0 1 0 1];
                                disp('State is now 0101')
                            end
                         transfer_state_belt1=1; 
                    end% end of the belt running state 2 section 
                end % end of checking exit
            end% end of checking blockage
        end % end of section dealing with the non crashing case 
    end % end of state 1001 section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 1 1 0]
        % need to move both belts and move the whole lot down 
        disp('state detected as 1110')
        disp('The Transfer State of belt 1 is:')
        disp(transfer_state_belt1)
        disp('The Transfer State of belt 2 is:')
        disp(transfer_state_belt2)
        if transfer_state_belt1 == 1 && transfer_state_belt2 == 1 && enteringflag == 1
            Kill_Line;
            disp('Arrival space already occupied - state [1 1 1 0] + entry') 
            Failure_Flag =1;
            error_type = ' Pallet Collision - state [1 1 1 0] + entry';
            toc
            enteringflag=0;    
        else
              if transfer_state_belt2 == 1
                        conveyor_2_unload.WaitFor(0,Main);
                        conveyor_2_step.WaitFor(0,Main);
                        conveyor_2_step.SendToNXT(Main);
                        disp('Pallet moving from y to x');
                        toc
                        transfer_state_belt2=2;
                        conveyor_1_step.WaitFor(0,Main);
                        conveyor_1_handover_stop.WaitFor(0,Main);
                        conveyor_1_step.SendToNXT(Main);
                        disp('moving arrival to z and z to y') 
                        transfer_state_belt1=2;
                        time_on_double = toc;
                        time_on_single = toc;   
               end
         end % end of state = 1 section    
         if transfer_state_belt2 == 2 && (toc - time_on_single) >delay_startup_time
                motoron1 = conveyor_1_step.ReadFromNXT(Main);
                motoron2 = conveyor_2_step.ReadFromNXT(Main);
                if motoron2.IsRunning == 0 && motoron1.IsRunning == 0
                      disp('The belt has reached position x and position y,z')
                      transfer_state_belt2 = 1;                       
                      transfer_state_belt1 = 1;
                      if enteringflag == 1
                              state = [1 1 1 1];
                              disp('State is now 1111')
                              enteringflag=0;
                      else
                              state = [0 1 1 1];
                              disp('State is now 0111')
                      end % end of checking if a pallet has arrived

                end % end of checking if the saecond belt has compelted its move
          end % end of state 2 section        
    end % end of state 1110 section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 1 0 1] 
        disp('State detected as 1101')
        disp('Blockage is')
        disp(blockage)
        if enteringflag ==1
            Kill_Line;
            disp('Arrival space already occupied - state [1 1 0 1] + entry')
            Failure_Flag =1;
            error_type = ' Pallet Collision - state [1 1 0 1] + entry';
            toc
            enteringflag=0;
        else
            if blockage==0  
                %unload and go to state 1100
                conveyor_2_unload.WaitFor(0,Main);
                conveyor_2_step.WaitFor(0,Main);
                conveyor_2_unload.SendToNXT(Main);
                state = [1 1 0 0];
                disp('State is now 1100')
            else 
                %if its blocked, go to 0111 - move single belt
                if transfer_state_belt1 == 1;
                    conveyor_1_step.WaitFor(0,Main);
                    conveyor_1_handover_stop.WaitFor(0,Main);
                    conveyor_1_step.SendToNXT(Main); 
                    transfer_state_belt1 = 2; 
                    time_on_single = toc;
                    disp('Moving the pallet from arrival to Z and from Z to Y')
                elseif transfer_state_belt1 == 2 && (toc - time_on_single) > delay_startup_time;
                    motoron = conveyor_1_step.ReadFromNXT(Main);
                    if  motoron.IsRunning == 0 
                      disp('The belt has reached position Y')
                            if enteringflag ==1
                                state = [1 1 1 1];
                                disp('State is now 1111')
                                enteringflag=0;
                            else
                                state = [0 1 1 1];
                                disp('State is now 0111')
                            end
                         transfer_state_belt1=1; 
                    end% end of the belt running state 2 section 
                end % end of checking exit
              
            end %end of blockage check
        end %end of entering flag check
    end %end of state 1101
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [0 1 1 1]
        disp('State detected as 0111')
        disp('Blockage is')
        disp(blockage)
        if blockage == 1
            if enteringflag == 1
                state = [1 1 1 1];
                disp('State is now 1111')
                enteringflag = 0;
            end    
        elseif blockage == 0
            conveyor_2_unload.WaitFor(0,Main);
            conveyor_2_step.WaitFor(0,Main);
            conveyor_2_unload.SendToNXT(Main);
            if enteringflag == 0
                state = [0 1 1 0];
                disp('State is now 0110')
            elseif enteringflag == 1
                state = [1 1 1 0];
                disp('State is now 1110')
                enteringflag = 0;
            end % end of checking entry
        end% end of checking blockage
    end %end of 0111 state
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 0 1 1]
        disp('State detected as 1011')
        disp('Blockage is')
        disp(blockage)
        if enteringflag ==1
            Kill_Line;
            disp('Arrival space already occupied - state [1 0 1 1] + entry')  
            Failure_Flag =1;
            error_type = ' Pallet Collision - state [1 0 1 1] + entry';
            toc
            enteringflag=0;
        else
            if blockage == 0
                %unload and go to state 1010      
                conveyor_2_unload.WaitFor(0,Main);
                conveyor_2_step.WaitFor(0,Main);
                conveyor_2_unload.SendToNXT(Main);
                state = [1 0 1 0];
                disp('State is now 1100')
            else
                %go to state 0111 - move single belt
                if transfer_state_belt1 == 1;
                    conveyor_1_step.WaitFor(0,Main);
                    conveyor_1_handover_stop.WaitFor(0,Main);
                    conveyor_1_step.SendToNXT(Main); 
                    transfer_state_belt1 = 2; 
                    time_on_single = toc;
                    disp('Moving the pallet from arrival to Z')
                elseif transfer_state_belt1 == 2 && (toc- time_on_single) > delay_startup_time
                    motoron = conveyor_1_step.ReadFromNXT(Main);
                    if  motoron.IsRunning == 0 
                      disp('The belt has reached position Z')
                            if enteringflag ==1
                                state = [1 1 1 1];
                                disp('State is now 1111')
                                enteringflag=0;
                            else
                                state = [0 1 1 1];
                                disp('State is now 0111')
                            end
                         transfer_state_belt1=1; 
                    end% end of the belt running state 2 section 
                end % end of checking exit
            end %end of blockage check
        end %end of entering flag check    
    end% end of state is 1011 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    if state == [1 1 1 1]
       disp('state detected as 1111') 
       Kill_Line;
       disp('Mainline buffer exceeded')
       Failure_Flag =1;
       error_type = 'Buffer Exceeded - state [1 1 1 1]';
       toc
    end % end state 1111 section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
disp('End of loop')
toc 
disp('-------------------------------------------------------------------')
% Check Go Still Exists 
Go = exist (path2go);
    
    
end
