% transfer_2a.m - a script file which conatisn the appropriate code to
% operate the transfer unit for a buffer state of 3

%Initialisation Section 
%state= [feed,middle,transfer]
disp('Running Buffer = 4 Transfer Script') 
toc
state= [0 0 0];
prev_state = [0 0 0];
pallet_status;
mainline_clear;
Check_Platform_Sensor
first_run = 0; %No longer run through "first run" bits of code 


while Go == 2 && Failure_Flag == 0
    disp('Start of loop')
toc 
pallet_status
mainline_clear
Check_Platform_Sensor
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if there are no pallets no action need be taken. 
if all(state == [0 0 0]) == 1
    disp('state detected as 000')
    toc
    if pallet == 1
        state(1) = 1;
    end
    % if the state is changing write this state as the previous state 
    if all(state == [0 0 0]) == 0
        prev_state = [0 0 0];  
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if all(state == [1 0 0]) == 1 
    disp('state detected as 100')
    toc
    if pallet_move == 1 && belt_running_flag ==0; 
        disp('moving pallet from b to c')
        toc
        step.SendToNXT(adder)
        motoron = step.ReadFromNXT(adder);
        pallet_move = 0;
        belt_running_flag = 1;
    end
    if belt_running_flag == 1
          motoron = step.ReadFromNXT(adder);
          if motoron.IsRunning == 0
             belt_running_flag = 0;
             state =[pallet 1 0];
             %update status, and include the pallet_move =0 flag.
          end
    end
    % if the state ahs changed then write the previous state       
    if all(state == [1 0 0]) == 0
        prev_state = [1 0 0]; 
    end
end% end of state 100 section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if all(state == [0 1 0]) == 1
    disp('state detected as 010')
    toc
    % update the first bit if a palelt arrives at b 
    if  belt_running_flag ==0; 
        disp('moving pallet from c to e')
        toc
        step.SendToNXT(adder)
        motoron = step.ReadFromNXT(adder);
        belt_running_flag = 1;
    end
    if belt_running_flag == 1
          motoron = step.ReadFromNXT(adder);
          if motoron.IsRunning == 0
             belt_running_flag = 0;
                state =[pallet 0 1];
                %update status, and include the pallet_move =0 flag.
          end
           % if the pallet has moed from b then      
    end   
    if all(state == [0 1 0]) == 0
        prev_state = [0 1 0]; 
    end
end % end of state 010 section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if all(state == [0 0 1]) == 1
    disp('state detected as 001')
    toc 
    if pallet == 1
        state(1) =1;
    end
    if blockage == 0 || transfer_flag == 1
       disp('Transferring Pallet on to Mainline')
       toc
       transfer_flag = 1; 
        if unload_state == 1
            unload
            unload_iter=0;
        end
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
    if all(state == [0 0 1]) == 0
        prev_state = [0 0 1];
    end
    
end% end of state = 001 case
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if all(state ==[1 0 1]) == 1
    disp('state detected as 101')
    toc 
    % if the pallet at b moves forward then continue to move it forward
    % into the middle position
    if pallet_move == 1 && belt_running_flag ==0; 
        disp('moving pallet from b to c')
        toc
        step.SendToNXT(adder)
        motoron = step.ReadFromNXT(adder);
        pallet_move = 0;
        belt_running_flag = 1;
    end
    if belt_running_flag == 1
          motoron = step.ReadFromNXT(adder);
          if motoron.IsRunning == 0
             belt_running_flag = 0;
                state =[pallet 1 1];
                %update status, and include the pallet_move =0 flag.
          end
    end
    if blockage == 0 || transfer_flag == 1
       disp('Transferring Pallet on to Mainline')
       toc
       transfer_flag = 1; 
        if unload_state == 1
            unload
            unload_iter=0;
        end
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
    if all(state ==[1 0 1]) == 0
        prev_state =[1 0 1]; 
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if all(state == [1 1 0]) == 1
    disp('state detected as 110')
    toc
    if pallet_move == 1 && belt_running_flag ==0; 
        disp('moving pallet from b to c and c to e')
        toc
        step.SendToNXT(adder)
        motoron = step.ReadFromNXT(adder);
        pallet_move = 0;
        belt_running_flag = 1;
    end
    if belt_running_flag == 1
          motoron = step.ReadFromNXT(adder);
          if motoron.IsRunning == 0
             belt_running_flag = 0; 
             % if arrived here from 0 1 0 then the stopping of this belt
             % means that we need to take into account 
             if all(prev_state == [0 1 0]) == 1
                 if pallet_move == 1
                     state =[0 1 1];
                     pallet_move =0;
                 else
                    state =[pallet 0 1];
                 end
             else 
                state =[pallet 1 1];
             end
             %update status, and include the pallet_move =0 flag.
          end
    end    
    if all(state == [1 1 0]) == 1
        prev_state = [1 1 0];
    end
end% end of state = 110 section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if all(state == [0 1 1]) == 1
    disp('state detected as 011')
    toc
    % in this state two checks must be performed, 1) the arrival must be
    % checked to see if a new palelt has arrived and is being held at b,
    % and secondly the unloading must continue
    % first check the state of the arrivals
    if pallet == 1
        state(1) =1;
    end 
    % then check the unlaoding can continue 
    if blockage == 0 || transfer_flag == 1
       disp('Transferring Pallet on to Mainline')
       toc
       transfer_flag = 1; 
       % initialise unload section
        if unload_state == 1
            unload
            unload_iter=0;
        end
        % continue the unloading section 
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
    if all(state == [0 1 1]) == 1
        prev_state = [0 1 1]; 
    end
end% end of state 011 section 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if all(state==[1 1 1]) == 1
    disp('state detected as 111')
    toc
    % if the pallet is clear to be unloaded then unload it 
    if blockage == 0 || transfer_flag == 1
       disp('Transferring Pallet on to Mainline')
       toc
       transfer_flag = 1; 
       % initialise unload section
        if unload_state == 1
            unload
            unload_iter=0;
        end
        % continue the unloading section 
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
    if all(state ==[1 1 1]) == 0
        prev_state =[1 1 1]; 
    end
end % end of state 111 section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('End of loop')
toc 
disp('------------------------------------------------------------------')

Go = exist (path2go); %Check if GO.txt exists, otherwise loop will end
end