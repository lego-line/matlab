% feed_4.m - a script file whcih is called by feed setup and contains the
% comamnds to run the feed unit with a buffer state of 4
%%%%%%%%%%%%%%%%%%NETWORKED SENSOR VERSION%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation Section 
%
disp('Running Buffer=4 Feed Script')
toc

status = [0 0 0]; 
%Status of 3 critical zones
%[pallet at b,pallet at c , pallet at e] 
status2 = status;
transfer_status;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
first_run = 0;

%%
Go = exist (path2go);

%%Operations Section 

while Go==2 && Failure_Flag == 0

    status2 = status;
    transfer_status;
    feed_pallet;
    trap=0;

while all(status == [0 1 0]) == 1 && Failure_Flag == 0 && Go == 2
    % partially unloaded state, the pallet at e has recently been
    % remvoed so move the pallet from c to e. 
    disp('state detected as 010')
    toc
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];

    if status(1) == 1 %Have to ensure that system stays in this loop even if pallet arrives at (b)
        status(1) = 0;
        trap = 1;
        trap_timer = toc;
    end

    if pallet == 1
        status = [0 0 pallet];

        if trap == 1
            status(1) = 1;
        end	

        trap = 0;
        front_pause_2 = [1 0];

    end


    if (toc - trap_timer) >= (2*TransientPause) && trap == 1; %if stuck in state [0 1 0] for too long, then move anyway,very unlikely situation to happen, but exact sequence of
        %events can lead to needing this statement to escape
        status = [1 1 0];
        disp('transient pause escape!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
        trap = 0;	
    end
    Go = exist (path2go);
    disp('----------------------------------------------------------------')
end



while all(status == [1 1 0]) == 1 && Failure_Flag == 0 && Go == 2
    disp('state detected as  110')
    toc
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];

        if pallet_clear == 1 %&& front_pause == 0
        move.SendToNXT(load); 
        disp('moving c to e and b to c');
        toc
        %assuming moving c to e
        status = [a 1 1];
        % if moving b to c then also move a to b
        a=0;            

            motoron = move.ReadFromNXT(load);
%  			while (pallet == 0 && escape == 0)|| motoron.IsRunning 
%             
% 			transfer_status; feed_pallet;
% 
% 				if pallet == 1;
% 					escape = 1;
% 				end
% 
% 			motoron = move.ReadFromNXT(load);
% 			end
         while motoron.IsRunning && Failure_Flag == 0 && Go == 2
         % whilst the motor is running do not proceed in program
            transfer_status;
            Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
            motoron = move.ReadFromNXT(load);
            Go = exist (path2go);
         end
        %escape = 0;
        end
    disp(' the new status is')
    disp(status) 
    Go = exist (path2go);
    disp('----------------------------------------------------------------')
end % end 110 case

while all(status == [1 0 1]) == 1 && Failure_Flag == 0 && Go == 2
    disp('state detcted as 101') 
    toc
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
            move.SendToNXT(load); 
            disp('move');
            toc

           status = [a 1 1];
           a=0;

    % 	motoron = move.ReadFromNXT(load);
    % 			while (pallet == 0 && escape == 0)|| motoron.IsRunning 
    % 
    % 			transfer_status; feed_pallet;
    % 
    % 				if pallet == 1;
    % 					escape = 1;
    % 				end
    % 
    % 			motoron = move.ReadFromNXT(load);
    % 			end
    % 		
    % 		escape = 0;
    % 
                 while motoron.IsRunning && Failure_Flag == 0 && Go == 2
                 % whilst the motor is running do not proceed in program
                    transfer_status;
                    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
                    motoron = move.ReadFromNXT(load);
                    Go = exist (path2go);
                 end
    disp('the new state is')
    disp(status)
    disp('----------------------------------------------------------------')
end

    
if all(status == [0 0 0]) == 1 && Failure_Flag == 0 && Go == 2
        disp('state detected as 000') 
        toc
        Go = exist (path2go);
        Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
        disp('----------------------------------------------------------------')
end

while all(status == [1 0 0]) == 1 && Failure_Flag == 0 && Go == 2
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('state detected as 100')
    toc
    % if there is space at e then move the pallet at b to e ready for
    % transfer 
        if pallet_clear == 1 && front_pause == 0
            disp('e is clear; moving pallet b to e')
            toc
            move.WaitFor(0,load)
            move.SendToNXT(load);
            % update status, in moving b to e also move a to b, and so
            % update a and b as well. 
            status = [a 0 1];
            a=0;
            move_once = 0;
            motoron = move.ReadFromNXT(load);

        end
    disp('The new state is')
    disp(status)
    disp('The new state of a is')
    disp(a)
    Go = exist (path2go);
    disp('----------------------------------------------------------------')
end % end of case 100 loop 
      
    

while all(status == [0 0 1]) ==1 && Failure_Flag == 0 && Go == 2
    % wait until the pallet at the end has cleared and check for arrivals 
    disp('state detected as 001')
    toc
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('the new state is')
    disp(status)
    Go = exist (path2go);
    disp('----------------------------------------------------------------')
end



while all(status == [0 1 1]) == 1 && Failure_Flag == 0 && Go == 2
    % wait for the pallets at the end to clear and check for arrivals 
    disp('state detected as 011')
    toc
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('the new state is')
    disp(status)
    Go = exist (path2go);
    disp('----------------------------------------------------------------')
end


while all(status == [1 1 1]) == 1 && Failure_Flag == 0 && Go == 2
    disp('state detected as 111')
    toc
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('the new state is')
    disp(status)
    Go = exist (path2go);
    disp('----------------------------------------------------------------')
end
Go = exist (path2go); %check go still exists
end
output_logs;