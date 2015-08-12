% feed_1.m - a script fiel caleld by feed_setup which conatins the commands
% to run the feed unit in a buffer state of 1 or 0. 
%%%%%%%%%%%%%%%%%%%%%%NETWORKED UNITS 2 VERSION%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation Section 
disp('Running Buffer = 1 or 0 Feed Script') 
toc

Go = exist(path2go);
status = [0 0]; %Status of pallet at end of feed
status2 = status;
transfer_status; 
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];Network_Read;
first_run = 0; %15/11/11 line moved from bottom of code to avoid overwriting sensor data 

%% Operations Section 

while Go==2 && Failure_Flag == 0

status2 = status;
transfer_status; 
feed_pallet;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
Network_Read;

while all(status == [0 0]) == 1 && Failure_Flag == 0 && Go == 2
    %there's no pallet    
    disp('state detected as 00')
    toc
    transfer_status;
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];Network_Read;
    Go = exist (path2go); %check go still exists
    disp('-----------------------------------------------------------')
end

while all(status == [1 0]) == 1 && Failure_Flag == 0 && Go == 2
    %pallet has been fed in to b 
    disp('state detected as 10')
    toc
    transfer_status; 
    feed_pallet;%moves pallet from a to b
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];Network_Read;

        if pallet_clear == 1 && eval(['Error_Correcting_Transfer_',num2str(feed_id)]) == 0%if a pallet has just been cleared
          disp('Detected that the pallet has just been cleared at e, space is availble')
          toc
          move.WaitFor(0,load) %check that belt is not moving before sending command
          move.SendToNXT(load); 
          disp('move pallet from feed to transfer');  
          % 05/10/11: Moves feed conveyor (b) by one buffer position, to front of feed conveyor belt
          status(1) = 0;  % Set 'b' position to zero because the pallet has now been moved on.
          trap = 1; % raise the trap flag to show the pallet is in transit 
          motoron = move.ReadFromNXT(load);			% 15/11/11 Checks whether conveyor motor is on
                %Error section to find out if there is pallet stuck in
                %the buffer.  If transfer belt is not moving, this
                %section becomes relevant
                while ((pallet == 0 && escape == 0)|| motoron.IsRunning) && Failure_Flag == 0 && Go == 2 % 05/10/11: While conveyor motor running OR...
                    % ...(pallet not yet detected at end of transfer unit AND escape flag hasn't yet been raised)...
                    % ...keep updating light sensor and feeding pallets as appropriate.
                    transfer_status; 
                    feed_pallet;
                    if pallet == 1;  % 05/10/11: When pallet reaches end of transfer unit and is detected...
                        escape = 1;   % ...Raise escape flag so as to exit while loop.
                        disp('Escaped from status 10 while loop- pallet has arrived at the end')
                    end
                    if a==1;		% 15/11/11 Checks whether 'feed_pallet' has fed a pallet in which case error.
                        Kill_Line
                        Failure_Flag = 1;
                        error_type = 'Buffer Exceeded:State 10 with single pallet being moved from 10 to 01 and a new pallet has been added';
                        feed_times = [feed_times; pallet_number toc t 0 ];
                    end   
                    motoron = move.ReadFromNXT(load);  % 05/10/11: Keeps checking whether conveyor motor is on
                    Go = exist (path2go);
                end

                transfer_status; 
                feed_pallet;
                disp('the new status is')
                disp(status)		
        end        
    if a==1;%status was [1 0] so there is already a pallet in the system.  a==1 means new one is being fed in.  Hence excedded buffer.
        trap =0; 
        movefile(path2go,path2stop)
        Failure_Flag = 1;
        error_type = 'Buffer Exceeded:State 10 with single pallet being moved from 10 to 01 and a new pallet has been added';
        feed_times = [feed_times; pallet_number toc t 0 ];
        disp('exceeded buffer state 10')
        toc
        
    end
    Go = exist (path2go); %check go still exists
    disp('-----------------------------------------------------------')
end % end of state 10 case 

while all(status == [1 1]) == 1 && Failure_Flag == 0 && Go == 2
    %buffer is exceeded
        disp('ERROR: State Detecetd as 11 and buffer size is 1')
        trap =0; 
        toc
	    transfer_status; 
        feed_pallet;
        Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];Network_Read;
	    
        Kill_Line
        Failure_Flag = 1;
        error_type = 'Buffer Exceeded: State 11 achieved';
		feed_times = [feed_times; pallet_number toc t 0 ];
        disp('-----------------------------------------------------------')
end

while all(status == [0 1]) == 1 && Failure_Flag == 0 && Go == 2
    %buffer is exceeded only if new pallet is being pushed in (a==1)
    transfer_status; 
    feed_pallet;	
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];Network_Read;
    disp('State Detected as 01')    
    toc
        if a == 1 || status(1)==1;
             
            Kill_Line
            Failure_Flag = 1; 
            error_type = 'Buffer Exceeded: State 01 and a new crate is presented at feed unit';
            toc
            feed_times = [feed_times; pallet_number toc t 0 ];
        end
    trap =0;%lower the trap flag as a pallet cannot be intransit if there is already one at the front and no error has been raised 
    Go = exist (path2go); %check go still exists
    disp('-----------------------------------------------------------')
end
Go = exist (path2go); %check go still exists
end
output_logs;