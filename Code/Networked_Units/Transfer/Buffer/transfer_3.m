% tranfer_3.m - a script file to conating the oeprations for the tranfer
% unit with a buffer state of 5 

%% Initialisation Section 

disp(' Running Buffer=5 Transfer Script')
toc
pallet_move = 0;
%state =[feed, buffer 1,buffer 2,transfer] 
state= [0 0 0 0];
state2 = state;
% state_1100_flag = 0;
% state_0111_flag = 0;
% move_flag = 0;
% flag to show that in cases with two pallets if the feed unit belt has
% also moved, determined from pallet_move falhg changing to indicate feed
% belt has moved and therefore the pallet at b has also moved
pallet_status
mainline_clear
Network_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
first_run = 0; %No longer run through "first run" bits of code 

%% Operations Section 

while Go == 2 && Failure_Flag == 0
disp('Start of loop')
toc
pallet_status
mainline_clear
 %if line is clear take no action
Network_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];

if all(state == [0 0 0 0]) == 1 && Failure_Flag == 0 && Go == 2
    disp('state detcted as 0000')
    toc
end % end of state 0000 case 
 

%% Cases Where A Single pallet in Buffer


% if a pallet is fed into the system then move it along to the transfer end
% of the line and update status
while all(state == [1 0 0 0]) == 1 && Failure_Flag ==0 && Go == 2
    disp('state detected as 1000')
    toc
	pallet_status; 
    mainline_clear;
	if pallet_move == 1
        %MOVE along 3 places,move b to e
        disp('moving pallet from b to e')
        toc
        step3.SendToNXT(adder)
        motoron = step3.ReadFromNXT(adder);
        while motoron.IsRunning && Go == 2
            % wait for command to complete
            mainline_clear;
            pallet_status;
            motoron = step3.ReadFromNXT(adder);
            Go = exist (path2go);
        end
	state = [pallet 0 0 1];
	pallet_move = 0;
    end
    disp('the new state is')
    disp(state)
    Go = exist (path2go);
end % end of state 1000 


% whilst a single pallet is buffered then as long as transfer position is
% clear move the pallet to transfer and updatre status 
while all(state == [0 1 0 0]) == 1 && Failure_Flag == 0 && Go == 2
    disp('state detected as  0100')
    toc
	pallet_status; 
    mainline_clear;
    % automatically move to transfer end of line
	step2.SendToNXT(adder)
	motoron = step2.ReadFromNXT(adder);
    disp('Moving palletfrom c to e')
    toc
	while motoron.IsRunning && Go == 2 && Failure_Flag == 0
        % hold until command is finshed
        mainline_clear;
        pallet_status;
        motoron = step2.ReadFromNXT(adder);
        Go = exist (path2go);
    end
	state = [pallet 0 0 1];
    disp('the new state is')
    disp(state)
    Go = exist (path2go);
end % end of case 0100 


% corresponding approach if pallet is in buffer then move to transfer if
% clear. 
while all(state == [0 0 1 0]) == 1 && Go == 2 && Failure_Flag == 0
    disp('state detected as 0010')
    toc
    pallet_status; 
    mainline_clear;
    disp('move pallet from d to e')
    toc
    step.SendToNXT(adder)
    motoron = step.ReadFromNXT(adder);
	while motoron.IsRunning && Go == 2 && Failure_Flag == 0
    % hold whilst command is executed 
        mainline_clear;
        pallet_status;
        motoron = step.ReadFromNXT(adder);
        Go = exist (path2go);
    end
    state = [pallet 0 0 1];
    disp('the new state is')
    disp(state) 
    Go = exist (path2go);
end % end of case 0010

while all(state == [0 0 0 1]) == 1 && Go == 2 && Failure_Flag == 0
    disp('state detected as 0001')
    toc
    pallet_status; 
    mainline_clear;
	if blockage == 0 && unload_state==1
        disp('unloading pallet onto mainline')
        toc
		unload
        unload_iter=0;
		while unload_state ~= 1 && Go == 2 && Failure_Flag == 0
            pallet_status; mainline_clear;
            unload
            disp('The Unload Iteration is')
            unload_iter=unload_iter+1;
            disp(unload_iter) 
            unload_state 
            Go = exist (path2go);
        end
    end
    disp('the new state is')
    disp(state)
    Go = exist (path2go);
end

%% cases Where There are two pallets in the Buffer 

% if two pallets are buffered and the transfer is clear then move both
% pallets along the line to the transfer end 
while all(state == [1 1 0 0]) == 1 && Go == 2 && Failure_Flag == 0
        disp('state detected as 1100')
        toc
        pallet_status; 
        mainline_clear;                                       
        disp('move pallet from c to e') 
        toc
        step2.SendToNXT(adder)
        motoron = step2.ReadFromNXT(adder);
        while motoron.IsRunning && Go == 2 && Failure_Flag == 0
            mainline_clear;
            pallet_status;
            if pallet_move ==1
                both_belt_move_flag=1;
                % back belt has moved, may be useful in error detection 
            end    
            past_pallet=pallet;
            pallet_status;
            if past_pallet==0 && pallet==1
                arrival_from_a_flag=1;
                % may be useful as an error flag 
            end    
            motoron = step2.ReadFromNXT(adder);
            Go = exist (path2go);
        end
        if both_belt_move_flag==0
            state=[1 0 0 1];
          % if the rear belt has not moved the the pallet at b remains static
          % but the c pallet has moved to e
        else
            % else if the belt has moved b has moved forward to position d, and
            % the pallet from a ( if any) would move to b, this is found by
            % checking the last status of the pallet variable. 
                state= [pallet 0 1 1];
                disp('something has gone wrong, rear belt has also moved state 1100 call') 
        end
    % reset flags for later
    both_belt_move_flag =0; 
    arrival_from_a_flag=0; 
    disp('new status is')
    disp(state)
    Go = exist (path2go);
end

while all(state == [1 0 0 1]) == 1 && Go == 2 && Failure_Flag == 0
    disp('State Detected as 1001')
    toc
    pallet_status; 
    mainline_clear;
        if pallet_move == 1
            disp('attempting to move pallet b to c')
            toc
            %move*1
            step.SendToNXT(adder)
            motoron = step.ReadFromNXT(adder);
            while motoron.IsRunning && Go == 2 && Failure_Flag == 0
                mainline_clear;
                pallet_status;
                motoron = step.ReadFromNXT(adder);
                Go = exist (path2go);
            end
            state = [pallet 1 0 1];
            pallet_move = 0;
        end
    disp('new status is')
    disp(state) 
    Go = exist (path2go);
end


if all(state == [0 1 0 1]) == 1 && Go == 2 && Failure_Flag == 0
    pallet_status; 
    mainline_clear;
    disp('State Detected as 0101')
    toc
    state=[pallet 1 0 1];
    %update state to incorporate arrival of pallet from the feed unit
	if blockage == 0 && unload_state==1
         % if can unload then do unload a pallet to the mainline
           disp('Attempting to unload a pallet to the mainline')
           toc
		unload
        unload_iter=0;
		while unload_state ~= 1 && Go == 2 && Failure_Flag == 0
            pallet_status; 
            mainline_clear;
            unload
            disp('The Unload Iteration is')
            unload_iter=unload_iter+1;
            disp(unload_iter)
            unload_state
            Go = exist (path2go);
        end
    % now unloading is complete update the status with unlaod and with the pallet arriving from feed    
    state= [pallet 1 0 0];       
    end    
    disp('the new state is')
    disp(state) 
end



while all(state == [1 0 1 0]) == 1 && Go == 2 && Failure_Flag == 0 
    disp('state detected as 1010')
    toc
	pallet_status; 
    mainline_clear;
	step.SendToNXT(adder)
	motoron = step.ReadFromNXT(adder);
	while motoron.IsRunning && Go == 2 && Failure_Flag == 0
        mainline_clear;
        pallet_status;
        if pallet_move ==1
            both_belt_move_flag=1;
            % back belt has moved, may be useful in error detection 
        end    
        past_pallet=pallet;
        pallet_status;
        if past_pallet==0 && pallet==1
            arrival_from_a_flag=1;
            % may be useful as an error flag 
        end    
	motoron = step.ReadFromNXT(adder);
    Go = exist (path2go);
    end
    if both_belt_move_flag==0
        state=[1 0 0 1];
      % if the rear belt has not moved the the pallet at b remains static
      % but the d pallet has moved to e
    else
        % else if the belt has moved b has moved forward to position d, and
        % the pallet from a ( if any) would move to b, this is found by
        % checking the last status of the pallet variable. 
            state= [pallet 1 0 1];
            disp('ERROR rear belt has also moved state 1010 call') 
            Failure_Flag = 1;
            error_type ='state is 1010 and the rear belt has also moved';
    end
    % reset flags for later
    both_belt_move_flag =0; 
    arrival_from_a_flag=0; 
    disp('new status is')
    disp(state) 
    Go = exist (path2go);
end


while all(state == [0 1 1 0]) == 1 && Go == 2 && Failure_Flag == 0
    disp('State Detected as 0110')
    toc
	mainline_clear;
	pallet_status;
    % execute a sinle step to advance the buffer such that pallet is ready
    % for transfer 
	step.SendToNXT(adder)
	motoron = step.ReadFromNXT(adder);
	while motoron.IsRunning && Go == 2 && Failure_Flag == 0
        mainline_clear;
        pallet_status;
        motoron = step.ReadFromNXT(adder);
        Go = exist (path2go);
	end
	state = [pallet 0 1 1];
    disp('the new state is')
    disp(state)
    Go = exist (path2go);
end % end of state 0110 case

if all(state == [0 0 1 1]) == 1 && Go == 2 && Failure_Flag == 0
    disp('State Detected 0011')
    toc
    pallet_status; 
    mainline_clear;
    state = [pallet 0 1 1];
        if blockage == 0 && unload_state==1
            disp('Unloading pallet to the mainline')
            toc
            unload
            unload_iter=0;
            while unload_state ~= 1 && Go == 2 && Failure_Flag == 0
                pallet_status; 
                mainline_clear;
                unload
                disp('The Unload Iteration is')
                unload_iter=unload_iter+1;
                disp(unload_iter)
                unload_state
                Go = exist (path2go);
            end
            state= [pallet 0 1 0];
        end
    disp('the new state is')
    disp(state)
end % end of state 0011 case 

%% Cases with three pallets on the transfer line 


while all(state == [1 1 1 0]) == 1 && Go == 2 && Failure_Flag == 0
    % in this case the aim is to move the pallets to the end of the feed
    % line so that one is prepared for transfer when the mainline is clear 
    disp('state detected as 1110')
    toc
    pallet_status; 
    mainline_clear;	
        if pallet_move == 0; 
            disp('feed unit is not moving, hold in this state until it does move') 
            toc
            state = [1 1 1 0];
        end
        if pallet_move == 1 
            disp('Detected that the feed unit has advanced pallet, therefore move own pallets forward')
            toc
            step.SendToNXT(adder)
            motoron = step.ReadFromNXT(adder);
            while motoron.IsRunning && Go == 2 && Failure_Flag == 0
                mainline_clear;
                pallet_status;
                motoron = step.ReadFromNXT(adder);
                Go = exist (path2go);
            end
            state= [pallet 1 1 1];
            pallet_move = 0;
        end
    disp('the new state is')
    disp(state) 
    Go = exist (path2go);
end % end of 1110 case

while all(state == [1 1 0 1]) == 1 && Go == 2 && Failure_Flag == 0
    disp('state detected at 1101')
    toc
    pallet_status; 
    mainline_clear; 
        if pallet_move == 1	
            disp('feed unit is moving, so advancing pallets by 1 buffer position')
            toc
            step.SendToNXT(adder)
            motoron = step.ReadFromNXT(adder);
                while motoron.IsRunning && Go == 2 && Failure_Flag == 0
                    mainline_clear;
                    pallet_status;
                    motoron = step.ReadFromNXT(adder);
                    Go = exist (path2go);
                end
            state = [pallet 1 1 1];
            pallet_move = 0;
        end
    disp('the new state is')
    disp(state)   
    Go = exist (path2go);
end % end of 1101 case 

if all(state == [1 0 1 1]) == 1 && Go == 2 && Failure_Flag == 0
    % if the line is in this state then clear the palelt from the edn of the
    % line 
    disp(' state detected as 1011')
    toc
    pallet_status; 
    mainline_clear;
        if blockage == 0 && unload_state==1
            disp('unloading a pallet to the mainline')
            toc
            unload
            unload_iter=0;
            while unload_state ~= 1 && Go == 2 && Failure_Flag == 0
                pallet_status; 
                mainline_clear;
                unload
                disp('The Unload Iteration is')
                unload_iter=unload_iter+1;
                disp(unload_iter)
                unload_state
                Go = exist (path2go);
            end
            state= [1 0 1 0];
        end
    disp('the new state is')
    disp(state)
end


if all(state == [0 1 1 1]) == 1 && Go == 2 && Failure_Flag == 0
    disp('state detected as 0111')
    toc
    pallet_status; 
    mainline_clear;
    state = [pallet 1 1 1];    
        if blockage == 0 && unload_state==1
            disp('Unloading pallet to the mainline')
            toc
            unload
            unload_iter=0;
            while unload_state ~= 1 && Go == 2 && Failure_Flag == 0
                pallet_status; 
                mainline_clear;
                unload
                disp('The Unload Iteration is')
                unload_iter=unload_iter+1;
                disp(unload_iter)
                unload_state
                Go = exist (path2go);
            end
            state= [pallet 1 1 0];
        end
    disp('the new state is')
    disp(state)   
    Go = exist (path2go);
end 


%% case where the buffer is almost full 
% if the buffer is full and transfer can be made then move the pallet to
% the mainline 
if all(state == [1 1 1 1]) == 1 && Go == 2 && Failure_Flag == 0
    disp('state detected as 1111')
    toc
    pallet_status; 
    mainline_clear;   
	if blockage == 0 && unload_state==1
        disp('Unloading pallet to the mainline')
        toc
		unload
        unload_iter=0;
		while unload_state ~= 1 && Go == 2 && Failure_Flag == 0
            pallet_status; 
            mainline_clear;
            unload
            disp('The Unload Iteration is')
            unload_iter=unload_iter+1;
            disp(unload_iter)
            unload_state
            Go = exist (path2go);
        end
        state= [1 1 1 0];
    end
    disp('the new state is')
    disp(state)  
end
disp('End of loop')
toc 
disp('------------------------------------------------------------------')
Go = exist (path2go); %Check if GO.txt exists, otherwise loop will end
end