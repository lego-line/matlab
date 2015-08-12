% feed_2.m - a script file which contains the commands to run the feed unit
% with a buffer state of 2- it is called by feed_setup 
%%%%%%%%%%%%%%%%%%NETWORKED SENSOR VERSION%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisation Section 
%
disp(' Running Buffer=2 Feed Script')
toc


Go = exist (path2go);
status = [0 0]; %Status of pallet at end of feed
transfer_status;
status2 = status;
Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
first_run = 0; 

%% Operations Section 

while Go==2 && Failure_Flag == 0

    status2 = status;
    transfer_status; 
    feed_pallet;

while all(status == [0 0]) == 1 && Failure_Flag == 0 && Go == 2
    % whilst the state is zero continue to monitor the situation 
    transfer_status; 
    feed_pallet;
    disp('State Detected as 00');
    toc
    Go = exist (path2go); %check go still exists
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('----------------------------------------------------------------')
end % end of 00 case 

while all(status == [1 0]) == 1 && Failure_Flag == 0 && Go == 2
    disp('State Detected as 10')
    toc
    transfer_status; 
    feed_pallet;
    Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
        if status(1) == 1 && a==1;
            disp('Two pallets on feed unit, buffer is full!')
            toc
            feed_times = [feed_times; pallet_number toc t 0 ];
            output_logs
        end

        % 5/7/12 commented out handshake as later areas of code not yet
        % complete- may need revisiting in future 
        if pallet_clear == 1 %&& front_pause == 0 && toc - handshake_timer > 3 %18/10/11 Added handshake timer condition
            % wait for the load to be static 
            move.WaitFor(0,load)
            move.SendToNXT(load); 
            disp('moving pallet from point b to transfer unit');
            toc
            % update status to show that pallet has moved from b 
            status(1) = 0;
            %handshake_timer = toc; %18/10/11
            if a == 1  %18/10/11
                a = 0;
                status(1) = 1;
                disp('in moving from b to e, has also moved a to b')
                toc
            end

        end
        disp(' The new Status is')
        disp(status) 
        Go = exist (path2go); %check go still exists
        disp('----------------------------------------------------------------')
end % end of 10 case 

while all(status == [1 1]) == 1 && Failure_Flag == 0 && Go == 2
    disp('State Detecetd as 11') 
    toc
    transfer_status; 
    feed_pallet;
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
    disp('----------------------------------------------------------------')
end

while all(status == [0 1]) == 1 && Failure_Flag == 0 && Go == 2
    % whislt in 01 case just wiat until the transfer unit clears the pallet 
    transfer_status; feed_pallet;Network_Write;fault_matrix=[fault_matrix;toc,fault_flag];
    disp('state detecetd as 01') 
    toc
    Go = exist (path2go); %check go still exists
    disp('----------------------------------------------------------------')
end % end of 01 case 
    Go = exist (path2go); %check go still exists
end
output_logs;
