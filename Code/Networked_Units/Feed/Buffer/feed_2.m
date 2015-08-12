% feed_2.m - a script file which contains the commands to run the feed unit
% with a buffer state of 2- it is called by feed_setup 

%% Initialisation Section 
%
disp(' Running Buffer=2 Feed Script')
toc



Go = exist (path2go);
status = [0 0]; %Status of pallet at end of feed
transfer_status;
status2 = status;
Network_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
first_run = 0; 

%% Operations Section 

while Go==2 && Failure_Flag == 0

    status2 = status;
    transfer_status; 
    feed_pallet;
    Network_Read;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];

while all(status == [0 0]) == 1 && Failure_Flag == 0 && Go == 2
    % whilst the state is zero continue to monitor the situation 
    transfer_status; 
    feed_pallet;
    Network_Read;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('State Detected as 00');
    toc
    Go = exist (path2go); %check go still exists
    disp('-----------------------------------------------------------')
end % end of 00 case 

while all(status == [1 0]) == 1 && Failure_Flag == 0 && Go == 2
    disp('State Detected as 10')
    toc
    transfer_status; 
    feed_pallet;
    Network_Read;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    if  a==1;
            disp('Two pallets on feed unit, buffer is full!')
            toc
            feed_times = [feed_times; pallet_number toc t 0 ];
    end
    % section copied from transfer case 1 to move the pallet and detect if
    % there is an erro moving it into the first position 
    if pallet_clear == 1 && eval(['Error_Correcting_Transfer_',num2str(feed_id)]) == 0%if a pallet has just been cleared
          disp('Detected that the pallet has just been cleared at e, space is availble')
          toc
          move.WaitFor(0,load) %check that belt is not moving before sending command
          move.SendToNXT(load); disp('move from feed to transfer');   % 05/10/11: Moves feed conveyor (b) by one buffer position, to front of feed conveyor belt
          status(1) = 0;  % Set 'b' position to zero because the pallet has now been moved on.
          
          trap =1; % raise the trap flag to show the pallet is in transit 
          motoron = move.ReadFromNXT(load);			% 15/11/11 Checks whether conveyor motor is on

                %Error section to find out if there is pallet stuck in
                %the buffer.  If transfer belt is not moving, this
                %section becomes relevant
                while ((pallet == 0 && escape == 0)|| motoron.IsRunning) && Failure_Flag == 0 && Go == 2 % 05/10/11: While conveyor motor running OR...
                    % ...(pallet not yet detected at end of transfer unit AND escape flag hasn't yet been raised)...
                    % ...keep updating light sensor and feeding pallets as appropriate.
                    transfer_status; 
                    feed_pallet;
                    Network_Read;
                    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
                    % error case showing that the pallet has got stuck in
                    % the loop - raise error alarm 
                    if State_Read(2) == 1 && pallet == 0 
                            fault_flag = 1; 
                            Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
                            disp('FAULT- Pallet Is Stuck In The Section Between Transfer and Feed Belts')
%                              
%                             Kill_Line
%                             Failure_Flag = 1 
%                             error_type = 'Fault - Pallet has Got Jammed at the midpoint';
%                             feed_times = [feed_times; pallet_number toc t 0 ];
                    end 
                    
                    if pallet == 1;  % 05/10/11: When pallet reaches end of transfer unit and is detected...
                        escape = 1;   % ...Raise escape flag so as to exit while loop.
                        disp('Escaped from status 10 while loop- pallet is trapped ')
                    end
                    if a==1;		% 15/11/11 Checks whether 'feed_pallet' has fed a pallet in which case error.
                         
                        Kill_Line
                        Failure_Flag = 1 
                        error_type = 'Buffer Exceeded:State 10 with single pallet being moved from 10 to 01 and a new pallet has been added';
                        feed_times = [feed_times; pallet_number toc t 0 ];
                    end   
                    motoron = move.ReadFromNXT(load);  % 05/10/11: Keeps checking whether conveyor motor is on
                    Go = exist (path2go);
                end
                transfer_status; 
                feed_pallet;
                Network_Read;
                Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
                disp(' the new status is')
                disp(status )
        elseif pallet_clear == 0
            disp('No Space to Move Pallet onto the Forward Conveyor')
        elseif eval(['Error_Correcting_Transfer_',num2str(feed_id)]) == 1
            disp('Tranfer Unit is fault Correcting - delaying arrival of pallet') 
      end        
%         % 5/7/12 commented out handshake as later areas of code not yet
%         % complete- may need revisiting in future 
%         if pallet_clear == 1 && eval(['Error_Correcting_Transfer_',num2str(feed_id)]) == 0%&& front_pause == 0 && toc - handshake_timer > 3 %18/10/11 Added handshake timer condition
%             % wait for the load to be static 
%             move.WaitFor(0,load)
%             move.SendToNXT(load); 
%             disp('moving pallet from point b to transfer unit');
%             toc
%             % update status to show that pallet has moved from b 
%             
%             
%             
%             if State_Read(2) == 1 && pallet == 0 
%                     fault_flag = 1; 
%                     Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
%                     disp('FAULT- Pallet Is Stuck In The Section Between Transfer and Feed Belts')
%                      
%                     Kill_Line
%                     Failure_Flag = 1 
%                     error_type = 'Fault - Pallet has Got Jammed at the midpoint';
%                     feed_times = [feed_times; pallet_number toc t 0 ];
%             end 
%             
%             
%             
%             status(1) = 0;
%             %handshake_timer = toc; %18/10/11
%             if a == 1  %18/10/11
%                 a = 0;
%                 status(1) = 1;
%                 disp('in moving from b to e, has also moved a to b')
%                 toc
%             end
%         elseif pallet_clear == 0
%             disp('No Space to Move Pallet onto the Forward Conveyor')
%         elseif eval(['Error_Correcting_Transfer_',num2str(feed_id)]) == 1
%             disp('Tranfer Unit is fault Correcting - delaying arrival of pallet') 
%         end
        disp(' The new Status is')
        disp(status) 
        Go = exist (path2go); %check go still exists
        disp('-----------------------------------------------------------')
end % end of 10 case 

while all(status == [1 1]) == 1 && Failure_Flag == 0 && Go == 2
    disp('State Detecetd as 11') 
    toc
    transfer_status; 
    feed_pallet;
    Network_Read;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    if status(1) == 1 && a==1;
             
            Kill_Line
            Failure_Flag = 1
            error_type = 'Buffer Exceeded:State is 11 and a Pallet is being fed'; 
            feed_times = [feed_times; pallet_number toc t 0 ];
    end
    disp(' the new status is')
    disp(status)
    Go = exist (path2go); %check go still exists
    disp('-----------------------------------------------------------')
end

while all(status == [0 1]) == 1 && Failure_Flag == 0 && Go == 2
    % whislt in 01 case just wiat until the transfer unit clears the pallet 
    transfer_status; 
    feed_pallet;
    Network_Read;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('state Detected as 01') 
    toc
    Go = exist (path2go); %check go still exists
    disp('-----------------------------------------------------------')
end % end of 01 case 
    Go = exist (path2go); %check go still exists
end
output_logs;
