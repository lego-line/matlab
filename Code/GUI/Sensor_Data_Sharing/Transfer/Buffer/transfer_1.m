% transfer_1.m - a script containing the code to operate the transfer unit
% with a buffer case of 1,2,3

% Initialisation Section 
disp('Running Transfer Script Buffer =1,2,3')
toc
state= [0 0];
pallet_move = 0;



pallet_status
mainline_clear
Check_Platform_Sensor
 Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
first_run = 0; %No longer run through "first run" bits of code 
prev_state = [0 0];
transfer_flag =0; % flag to show when a transfer is in progress
belt_running_flag =0; % flag to show when the belt is moving 
%% Operations Section 

while Go == 2 && Failure_Flag == 0

pallet_status
mainline_clear
Check_Platform_Sensor
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
%if the state is both empty take no action 
if all(state == [0 0]) == 1
    disp('state detected as 00')
    toc
    if pallet == 1
        state(1) = 1;
    end
    % if the state is changing write this state as the previous state 
    if all(state == [0 0]) == 0
        prev_state = [0 0];  
    end
end

% If the state is such that a pallet has just been added then move it along
% the line to the transfer unit 
if all(state==[1 0]) == 1
    disp('state detected as 10')
    toc
    if  belt_running_flag == 0 && pallet_move == 1
        disp('moving pallet from b to e')
        toc
        step.SendToNXT(adder)
        belt_running_flag = 1;
        pallet_move = 0;
    end
    if belt_running_flag == 1
          motoron = step.ReadFromNXT(adder);
          if motoron.IsRunning == 0
             belt_running_flag = 0;
             state =[pallet 1];
             %update status, and include the pallet_move =0 flag.
          end 
    end   
    % if the state has changed then update the state 
    if all(state == [1 0]) == 0
        prev_state = [1 0];  
    end
end % end of state 10 case

if all(state==[0 1]) == 1
    % in state 01 check first to see if there is an arriving palelt which
    % breaks the buffer conditions
    disp('state detected as 01')
    toc
    if pallet == 1
        state(1) = 1;
    end 
    % next check to see if the line can be unloaded if the mainline is
    % clear  
    if blockage == 0 || transfer_flag == 1
       disp('Transferring Pallet on to Mainline')
       toc
       transfer_flag = 1; 
       % start the unloading 
        if unload_state == 1
            unload
            unload_iter=0;
        end
        % proceed with the unloading 
		if unload_state ~= 1 && Go == 2 && Failure_Flag == 0 
            % if there is a state change and a pallet arrives we need to
            % break out of this loop 
            unload
            disp('The Unload Iteration is')
            unload_iter=unload_iter+1;
            disp(unload_iter)
            unload_state 
        end
    end
    % update the previous state if the state changes 
    if all(state == [0 1]) == 0
        prev_state = [0 1];  
    end
end% end of state 01 case

if all(state==[1 1]) == 1
    disp('state detected as 11') 
    toc
    if blockage == 0 || transfer_flag == 1
       disp('Transferring Pallet on to Mainline')
       toc
       transfer_flag = 1; 
       % start the unloading 
        if unload_state == 1
            unload
            unload_iter=0;
        end
        % proceed with the unloading 
		if unload_state ~= 1 && Go == 2 && Failure_Flag == 0 
            % if there is a state change and a pallet arrives we need to
            % break out of this loop 
            unload
            disp('The Unload Iteration is')
            unload_iter=unload_iter+1;
            disp(unload_iter)
            unload_state 
        end
    end
    % update the previous state if the state changes 
    if all(state == [1 1]) == 0
        prev_state = [1 1];  
    end
end % end of state 11 case 
Go = exist (path2go); 
%Check if GO.txt exists, otherwise loop will end
end