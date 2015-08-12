% feed_1.m - a script fiel caleld by feed_setup which conatins the commands
% to run the feed unit in a buffer state of 1 or 0. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%GLOBAL CONTROL VERSION%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation Section 
disp('Running Buffer = 1 or 0 Feed Script') 
toc
transfer_status; 
Global_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
Go = exist(path2go);
first_run = 0; %15/11/11 line moved from bottom of code to avoid overwriting sensor data 

%% Operations Section 

while Go==2 && Failure_Flag == 0
disp('Start of Loop')
toc 
status2 = status;
transfer_status;
feed_pallet;
Global_Read;
Network_Write;
fault_matrix=[fault_matrix;toc,fault_flag];

while all(status == [0 0]) == 1 && Failure_Flag == 0 && Go == 2
    %there's no pallet    
    disp('state detected as 00')
    transfer_status;
    feed_pallet;
    Global_Read;
    Network_Write;
    fault_matrix=[fault_matrix;toc,fault_flag];
    Adjust_Belt_Speed;
    toc
    Go = exist (path2go); %check go still exists
    disp('-------------------------------------------------------------')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while all(status == [1 0]) == 1 && Failure_Flag == 0 && Go == 2
    %pallet has been fed in to b 
    disp('state detected as 10')
    toc
    transfer_status; 
    feed_pallet;%moves pallet from a to b
    Global_Read;
    Network_Write;
    Adjust_Belt_Speed;
    fault_matrix=[fault_matrix;toc,fault_flag];

        if pallet_clear == 1 && Hold == 0 %if a pallet has just been cleared
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
                    Global_Read;
                    Network_Write;
                    fault_matrix=[fault_matrix;toc,fault_flag];
                    Adjust_Belt_Speed;
                    % error case showing that the pallet has got stuck in
                    % the loop - raise error alarm 
                    if State_Read(2) == 1 && pallet == 0 
                            fault_flag = 1; 
                            Network_Write;
                            fault_matrix=[fault_matrix;toc,fault_flag];
                            Adjust_Belt_Speed;
                            disp('FAULT- Pallet Is Stuck In The Section Between Transfer and Feed Belts')
%                             cd (path2control); 
%                             movefile(path2go,path2stop);
%                             Failure_Flag = 1 
%                             error_type = 'Fault - Pallet has Got Jammed at the midpoint';
%                             feed_times = [feed_times; pallet_number toc t 0 ];
                    end 
                    if pallet == 1;  % 05/10/11: When pallet reaches end of transfer unit and is detected...
                        escape = 1;   % ...Raise escape flag so as to exit while loop.
                        disp('Escaped from status 10 while loop- pallet is trapped ')
                    end

                    if a==1;		% 15/11/11 Checks whether 'feed_pallet' has fed a pallet in which case error.
                        Kill_Line;
                        Failure_Flag = 1 
                        error_type = 'Buffer Exceeded:State 10 with single pallet being moved from 10 to 01 and a new pallet has been added';
                        feed_times = [feed_times; pallet_number toc t 0 ];
                    end   
                    motoron = move.ReadFromNXT(load);  % 05/10/11: Keeps checking whether conveyor motor is on
                    Go = exist (path2go);
                end

                transfer_status; 
                feed_pallet;
                Global_Read;
                Network_Write;
                fault_matrix=[fault_matrix;toc,fault_flag];
                Adjust_Belt_Speed;
                disp(' the new status is')
                disp(status )
        elseif pallet_clear == 0
            disp('No Space to Move Pallet onto the Forward Conveyor')
        elseif eval(['Error_Correcting_Transfer_',num2str(feed_id)]) == 1
            disp('Tranfer Unit is fault Correcting - delaying arrival of pallet') 
        end        
    if a==1;%status was [1 0] so there is already a pallet in the system.  a==1 means new one is being fed in.  Hence excedded buffer.
        trap =0; 
        Kill_Line;
        Failure_Flag = 1
        error_type = 'Buffer Exceeded:State 10 with single pallet being moved from 10 to 01 and a new pallet has been added';
        feed_times = [feed_times; pallet_number toc t 0 ];
        disp('exceeded buffer state 10')
        toc
        
    end
    Go = exist (path2go); %check go still exists
    disp('-------------------------------------------------------------')
end % end of state 10 case 

while all(status == [1 1]) == 1 && Failure_Flag == 0 && Go == 2
    %buffer is exceeded
        disp('ERROR: State Detecetd as 11 and buffer size is 1')
        trap =0; 
        toc
	    transfer_status;
        feed_pallet;
        Global_Read;
        Network_Write;
        fault_matrix=[fault_matrix;toc,fault_flag];
        Adjust_Belt_Speed;
        Kill_Line;
        Failure_Flag = 1
        error_type = 'Buffer Exceeded: State 11 achieved';
		feed_times = [feed_times; pallet_number toc t 0 ];
        disp('-------------------------------------------------------------')
end

while all(status == [0 1]) == 1 && Failure_Flag == 0 && Go == 2
    %buffer is exceeded only if new pallet is being pushed in (a==1)
    transfer_status; 
    feed_pallet;	
    Global_Read;
    Network_Write;
    fault_matrix=[fault_matrix;toc,fault_flag];
    Adjust_Belt_Speed;
    disp('State Detected as 01')    
    toc
        if a == 1 || status(1)==1;
            Kill_Line;
            Failure_Flag = 1 
            error_type = 'Buffer Exceeded: State 01 and a new crate is presented at feed unit';
            toc
            feed_times = [feed_times; pallet_number toc t 0 ];
        end
    trap =0;%lower the trap flag as a pallet cannot be intransit if there is already one at the front and no error has been raised 
    Go = exist (path2go); %check go still exists
    disp('-------------------------------------------------------------')
end
Go = exist (path2go); %check go still exists
end
output_logs;