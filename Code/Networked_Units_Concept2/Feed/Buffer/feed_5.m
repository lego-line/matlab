% feed_5.m - a script file whcih contains the code to run the feed unit
% with a buffer state of 5- it is called by the feed_setup script. 

%% Initialisation Section 
%
disp('Running Buffer=5 Feeding Script')
toc
% 05/10/11: Timer variables.
t1=0; %toc-t1 = time since last pallet dispatched
t2=0; %toc-t2 = time since d=0
t3=0; %Debug timer
t4=0; %limit time between crate move forwards

front_pause = 0;
front_pause_timer = 0;
front_pause_2 = [0 0];
state_0111_flag = 0;
trap_timer = 0;
escape = 0;

status = [0 0 0 0]; 
%Status of 4 critical zones  [b c d e]

status2 = status;
transfer_status; 
Network_Write;
first_run = 0;

%% Operations Section 
trap=0;
Go = exist (path2go);

while Go==2 && Failure_Flag == 0
	
% While GO.txt exists, keep updating light sensor and move conveyor/feed pallets if appropriate.
    
	status2 = status;
	transfer_status; 
    feed_pallet;
    Network_Write;
    Network_Read;
    
      % match the state to that of the transfer unit to get better tracking
    % of the pallet through the system 
    if State_Read(2) ~= status(2)
        status(2) = State_Read(2);
    end 
      % match the state to that of the transfer unit to get better tracking
    % of the pallet through the system 
    if State_Read(3) ~= status(3)
        status(3) = State_Read(3);
    end 
    

	if 	all(status == [0 0 0 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('state detected as 0000')
        toc
	end
%% Cases Where thre is one pallet in the buffer 

while 	all(status == [1 0 0 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('state detected as 1000')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
        Network_Read;
		if 	pallet_clear == 1 
            disp('e is clear so move pallet b to e')
            toc
			move.WaitFor(0,load)
			move.SendToNXT(load);      
			motoron = move.ReadFromNXT(load);  % 05/10/11: Checks whether conveyor motor is on
                while motoron.IsRunning && Failure_Flag == 0 && Go == 2
					transfer_status; 
                    feed_pallet;
                    Network_Write;
                    Network_Read;
					motoron = move.ReadFromNXT(load); 
                    Go = exist (path2go);
                    % 05/10/11: Keeps checking whether conveyor motor is on
                end
                status = [a 0 0 pallet];
                a=0;
         end
    disp('the new status is')
    disp(status)
    disp('the new value of a is')
    disp(a)
    Go = exist (path2go);
end


while 	all(status == [0 1 0 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('State Detected as 0100')
        toc
		transfer_status;
        feed_pallet;
        Network_Write;
        Network_Read;
		if 	status(1) == 1 %Have to ensure that system stays in this loop even if pallet arrives at (1)
			status(1) = 0;  % 
			trap = 1;	% 05/10/11: Raise trap flag.
        end
		if 	pallet == 1
			status = [trap 0 0 pallet];
			trap = 0;	% 05/10/11: Reset trap flag.
        end
    disp('the new status is')
    disp(status)
    disp('the new value of a is')
    disp(a)
    disp('the trap flag is')
    disp(trap) 
    Go = exist (path2go);
end
    
    
while 	all(status == [0 0 1 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp(' the state is detecetd as 0010')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
        Network_Read;
		if 	status(1) == 1 %Have to ensure that system stays in this loop even if pallet arrives at (1)
			status(1) = 0;
			trap = 1;
        end
		if 	pallet == 1  % 05/10/11: If detect pallet at end of transfer unit...
			status = [trap 0 0 1];  %  ...then assume this means the transfer unit has pulled forwards the pallet that was at 'd'.
			trap = 0;
        end
        disp('the new status is')
        disp(status) 
        disp('the new value of a is')
        disp(a)
        disp('the trap flag is')
        disp(trap)  
        Go = exist (path2go);
end % end of case 0010 case
    
while 	all(status == [0 0 0 1]) == 1 && Failure_Flag == 0 && Go == 2
        % monitor the incoming traffic whislt waiting to unload 
        disp('state detected as 0001')
        toc
		transfer_status; 
        status = [0 0 0 pallet]; 
        Network_Write;
        feed_pallet;
        Network_Read;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)
        Go = exist (path2go);
end % end of state 0001 case
    

%% Section for Two pallets on Line 

while 	all(status == [1 1 0 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('Status Detected as 1100')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
        Network_Read;
        if 	pallet == 1  
            status = [1 0 0 1];
        end
        
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a) 
        Go = exist (path2go);
end % end of state 1100 loop


while all(status == [1 0 0 1]) == 1 && Failure_Flag == 0 && Go == 2
        disp('state detected as 1001')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
		move.WaitFor(0,load)
		move.SendToNXT(load); 
        disp('move to transfer');
		status = [a 1 0 pallet];
		a=0;
        Network_Write;
		motoron = move.ReadFromNXT(load); 
		while motoron.IsRunning  && Failure_Flag == 0 && Go == 2
				transfer_status; 
                feed_pallet;
                Network_Write;
				motoron = move.ReadFromNXT(load);  
                Go = exist (path2go);
		end
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)  
        Go = exist (path2go);
end % end of state 1001 loop 

    
    
    
while 	all(status == [1 0 1 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('Status Detected as 1010')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
		if 	pallet == 1   % 05/10/11: If detect pallet at end of transfer unit...
			status = [1 0 0 1];  %  ...then assume this means the transfer unit has pulled forwards the pallet that was at 'd'.
        end
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)   
        Go = exist (path2go);
end % end of state 1010 loop 



while all(status == [0 1 1 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('state detected as 0110')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
		if 	status(1) == 1 %Have to ensure that system stays in this loop even if pallet arrives at (1)
			status(1) = 0;
			trap = 1;
		end

		if 	pallet == 1  % 05/10/11: If detect pallet at end of transfer unit...
			status = [trap 0 1 pallet];  %  ...then assume this means the transfer unit has pulled forwards the pallets that were at 'c' and 'd'.
			trap = 0;	
        end
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a) 
        disp('the trap flag is')
        disp(trap)
        Go = exist (path2go);
end % end of state 0110 loop 


	

while all(status == [0 1 0 1]) == 1 && Failure_Flag == 0 && Go == 2
        % wait for the tarnsfer unit to move the extra pallet up in the
        % buffer- this can be hard to tell so act as if it has 
        disp('state detected as 0101')
        toc
        transfer_status; 
        status = [0 0 1 pallet]; %Added 5/10/11 to update status based on current light sensor value
        feed_pallet;
        Network_Write;
        disp(' the new status is')
        disp(status)
        disp('the new value of a is')
        disp(a)
        Go = exist (path2go);
end % end of state 

while 	all(status == [0 0 1 1]) == 1 && Failure_Flag == 0 && Go == 2
        % wait and monitor what comes in whislt wating for the transfer
        % unit to unload
        disp('State Detected as 0011')
        toc
		transfer_status;
        status = [0 0 1 pallet]; 
        feed_pallet;
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a) 
        Go = exist (path2go);
end % end of 0011 states 


%% Section With Three Pallets In Buffer 

while all(status == [1 1 1 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('State Detected as 1110')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
		move.WaitFor(0,load)
		move.SendToNXT(load); 
        disp('move to transfer'); % 05/10/11: Moves feed conveyor by one buffer position.
		% 05/10/11: By moving the conveyor here, we are moving from 'a' to 'b' and so should update status accordingly and reset 'a'.
			
		motoron = move.ReadFromNXT(load);
				while motoron.IsRunning && Failure_Flag == 0 && Go == 2
					transfer_status;
                    feed_pallet;  % ...Keep updating light sensor and feeding pallets as appropriate.
                    Network_Write;
					motoron = move.ReadFromNXT(load);
                    Go = exist (path2go);
                    % 05/10/11: Keep checking whether the conveyor is operating.
                end
        status = [a 1 1 1];  % transfer set to advance once it sees this belt is moving
		a=0;	      
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)
        Go = exist (path2go);
end % end of case 1110 loop 



while 	all(status == [1 0 1 1]) == 1 && Failure_Flag == 0 && Go == 2
        % wait and monitor the incoming pallet whislt waiting for the line
        % to unload
        disp(' State detected as 1011')
        toc
		transfer_status; 
        feed_pallet;
		status = [1 0 1 pallet]; 
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)
        Go = exist (path2go);
end % end of case 1011 loop 

while 	all(status == [0 1 1 1]) == 1 && Failure_Flag == 0 && Go == 2
        % wait and monitor the incoming pallet whislt waiting for the line
        % to unload 
        disp(' State detected as 0111')
        toc
		transfer_status; 
        feed_pallet;
		status = [0 1 1 pallet];
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)
        Go = exist (path2go);
end % end of case 0111 loop
    
while all(status == [1 1 0 1]) == 1 && Failure_Flag == 0 && Go == 2
        disp('status is 1101')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
        move.WaitFor(0,load)
        move.SendToNXT(load); 
        disp('move  b to transfer');  % 05/10/11: Moves feed conveyor by one buffer position.		
		% 05/10/11: By moving the conveyor here, we are moving from 'a' to 'b' and so should update status accordingly and reset 'a'.
			motoron = move.ReadFromNXT(load);  % 05/10/11: Check whether conveyor is running.
			while 	motoron.IsRunning && Failure_Flag == 0 && Go == 2 % 05/10/11: While conveyor is running, keep updating light sensor and feeding pallets as appropriate.
				transfer_status; 
                feed_pallet;
                Network_Write;
				motoron = move.ReadFromNXT(load);
                Go = exist (path2go);
                % 05/10/11:Keep checking whether conveyor is running.
            end
        status = [a 1 1 pallet];  % 05/10/11: Update status.
		a=0;   
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)
        Go = exist (path2go);
end


    %% Section with 4 pallets in Buffer 

while 	all(status == [1 1 1 1]) == 1 && Failure_Flag == 0 && Go == 2
        disp('state detected as 1111')
        toc
		transfer_status; 
        feed_pallet;
        Network_Write;
		status = [1 1 1 pallet]; 
        Network_Write;
        disp('the new state is')
        disp(status)
        disp('the new value of a is')
        disp(a)
        Go = exist (path2go);
end
    
Go = exist (path2go); %check go still exists

end
output_logs;