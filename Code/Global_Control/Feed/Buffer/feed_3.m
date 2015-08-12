% feed_3.m - a script file called by the feed_setup script which conatins
% the commands requried to run teh feed unit with a buffer state of 3 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%GLOBAL CONTROL VERSION%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation Section 
disp('Running Buffer=3 Feed Script') 

status = [0 0]; %Status of 3 critical zones
status2 = status;
transfer_status; % updates the e element and checks the arm  
Global_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
first_run = 0;   % no longer on the first execution of these functions. 

Go = exist (path2go);

%% Operations Section 
while Go == 2 && Failure_Flag == 0
disp('Start of Loop')
toc 
status2 = status;
transfer_status; % updates the e element and checks the arm 
feed_pallet;     % feeds pallets and moves from a to b if b is clear and updates a and b apropriately.
Global_Read;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];

while all(status == [0 0]) == 1 && Failure_Flag == 0 && Go == 2
    % whislt in state 00 then monitor the situation
    disp('state detected as 00') 
    transfer_status; 
    feed_pallet;
    Global_Read;
    Network_Write;
    fault_matrix=[fault_matrix;toc,fault_flag];
    Adjust_Belt_Speed;
    Go = exist (path2go);
    disp('-------------------------------------------------------------')
end


while all(status == [1 0]) == 1 && Failure_Flag == 0 && Go == 2
       disp('state detected as 10') 
       transfer_status; % checks nothing at e
       feed_pallet;     % feeds in at a if required by schedule
       Global_Read;
       Network_Write;
       fault_matrix=[fault_matrix;toc,fault_flag];
       Adjust_Belt_Speed;
       if (pallet_clear == 1 || pallet_clear_flag_2 == 1) && Hold == 0 % if there is nothing at e ( ignore front pause as usd in unused timing function)
            move.WaitFor(0,load) %wait for the motors to be static 
            move.SendToNXT(load); 
            disp('moving crate b to e');	% move anything from a to b, move pallet at b onto the transfer belt for collection 
            %N.B experiment with feed_pallet in or not in the loop         
            motoron = move.ReadFromNXT(load);
            % keep taking status updates whilst the motor is running 
                while ((pallet == 0 && escape == 0)|| motoron.IsRunning ) && Failure_Flag == 0 && Go == 2
                    transfer_status; 
                    feed_pallet;
                    Global_Read;
                    Network_Write;
                    fault_matrix=[fault_matrix;toc,fault_flag];
                    Adjust_Belt_Speed;
                    if pallet == 1;
                            escape = 1;
                    %if pallet has arrived at e stop feeding the pallet or
                    %if escape is set by somethign else to initite
                    %shutdown. 
                    end
                    motoron = move.ReadFromNXT(load);
                    % to get out of this if pallet =1, i.e. the pallet has
                    % arrived at e or if the motor has stopped turning due to time exceeded 
                    Go = exist (path2go);
                end
            status = [a 1]; % hence update the status with the item moved b to e and the item moved a to b. 
            a=0;            % now know that a is availble for moving new pallets into.             
            %if escape has been set, then unset it for future use 
            escape = 0;
        elseif pallet_clear == 0
            disp('No Space to Move Pallet onto the Forward Conveyor')
        elseif eval(['Error_Correcting_Transfer_',num2str(feed_id)]) == 1
            disp('Tranfer Unit is fault Correcting - delaying arrival of pallet') 
        end
        Go = exist (path2go);
        pallet_clear_flag_2 =0; 
        disp('-------------------------------------------------------------')
end % end of 10 case



while all(status == [0 1]) == 1 && Failure_Flag == 0 && Go == 2
    % operate as if not pallets were at e with regards to a and b, so
    % standard oeprations only. 
    disp('state detected as 01') 
	transfer_status; 
    feed_pallet;
    Global_Read;
    Network_Write;
    fault_matrix=[fault_matrix;toc,fault_flag];
    Adjust_Belt_Speed;
    Go = exist (path2go);
    disp('-------------------------------------------------------------')
end


while all(status == [1 1]) == 1 && Failure_Flag == 0 && Go == 2
    % as long as the buffer is full then as long as a new pallet arrives it
    % does not matter- detection of two pallet arriving at a is handled by
    % the feeding script
    disp('state detected as 11') 
    feed_pallet;
	transfer_status; 
    Global_Read;
    Network_Write;
    fault_matrix=[fault_matrix;toc,fault_flag];
    Adjust_Belt_Speed;
    if all(status == [1 0]) == 1
        % if the status is 11 and then a pallet leaves the end then move
        % into state 
        pallet_clear_flag_2 = 1; 
    end     
    Go = exist (path2go);
    disp('-------------------------------------------------------------')
end % end of case 11
Go = exist (path2go); %check go still exists
end
output_logs;