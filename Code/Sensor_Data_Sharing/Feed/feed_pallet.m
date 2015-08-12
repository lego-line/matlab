% Feed_Pallet.m: This file contains the code to: 
	% Move a newly fed pallet forward from 'a' to 'b'.
	% Proceed through the five stages of the feeding sequence. 
	% NB: Feeding a pallet leads to a = 1 in phase 4.  This is used to
	% trigger the conveyor to move the pallet forward from 'a' to 'b' and update the status.
disp('Running Feed Pallet Script')
toc
(t1+t-toc);
disp('Initial Status is')
disp(status)
%%
% 05/10/11: Code for moving newly fed pallet forward from 'a' to 'b'.
% 05/10/11: First need to check whether conveyor and/or elevator motors are running.
if Failure_Flag ==0;
    motoron = move.ReadFromNXT(load); 		%Do not try to do this if move is already moving!! 
    motoron2 = raise.ReadFromNXT(load); 		%a is 1, but raise motor is still spinning, must wait
end

if a == 1 && status(1) == 0 && motoron.IsRunning == 0 && motoron2.IsRunning == 0 && feeding2 == 0 && trap == 0
	move.SendToNXT(load); 
    disp('start to move conveyor from point a to b'); 
    c = clock; 
    c(4:6); % 05/10/11: Drive conveyor motor to move pallet to light sensor at end of feed unit.
	feeding2 = 1;			
    time_entered_last_start = toc;
    % 05/10/11: feeding2 used as a flag to indicate the conveyor motor is
    % driving.  Also indicates that the 'move' command was initiated from within feed_pallet rather than through feed_5.
end

%% Cell To Check If Successfully Moved pallet 
if Failure_Flag == 0;
    motoron = move.ReadFromNXT(load); 
    motoron3= belt_error_run.ReadFromNXT(load);%  05/10/11: Checks again whether conveyor motor is running.
end

% section to perform a networked sensor check to see if the pallet has arrived at the tarnsfer point 
        disp('Running an Status Check on the Outgoing Pallet - networked')
        if exist(filepath_local_val)~= 0 
            fid=fopen( filepath_local_val,'r');
            out=textscan(fid,local_format);
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')
            else     
                val_entering=str2num(out{1,1}{1,1});
                mainlineclear_entry = str2num(out{1,2}{1,1});
                if val_entering>mainlineclear_entry
                        disp('A Package is Detected at Sensor')
                        toc 
                        if entering_previous_pallet == 0
                            disp('The Pallet has arrived at the Sensor point')
                            enteringflag = 1; 
                            
                        end
                        entering_previous_pallet=1;
                else
                        disp('The Sensor Point is Clear') 
                        toc
                        entering_previous_pallet=0; 
                        enteringflag = 0; 
                end
                sensor_data_read_amount = sensor_data_read_amount + 16;
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            enteringflag = 0; 
        end
        %%

if 	feeding2 == 1 
    disp('Checking if Successfuly Moved Pallet')
    if  motoron.IsRunning == 0 && enteringflag == 1 && motoron3.IsRunning == 0% 05/10/11: Checks when have just finished moving pallet with conveyor from 'a' to 'b'.     
        status(1)=1;				% 05/10/11: Update status to show soemthing is at b  
        a=0;					    % 05/10/11: Update 'a'. 
        feed_pause_time = toc;
        feed_pause = 1;
        feeding2 = 0;				% 05/10/11: Reset flag to indicate conveyor operation now finished. 
        disp('The Pallet has Successfully arrived at the sensor')
        enteringflag = 0; 
    elseif motoron.IsRunning == 0 && enteringflag == 0 && motoron3.IsRunning == 0
        % case where the line has stopped running and the pallet has not
        % arrived. 
        disp('FAULT: Pallet has not arrived. It is Likely further upstream.')
        time_started_error_correction = toc; 
        enteringflag = 0; 
        belt_error_run.SendToNXT(load); 
        Fault_correct = 1;
        fault_flag = 1; 
    elseif  Fault_correct == 1 && enteringflag == 0 && motoron3.IsRunning == 1
         disp('Continuing Fault Correction to recover pallet stuck at start of belt')
         if toc - time_started_error_correction > 3
                Failure_Flag = 1;
                error_type = ('ERROR: Pallet has Got Jammed At The Arrival Point and Has Not Arrived at the sensor');
                disp(error_type)
         elseif  enteringflag == 1 % else keep reading the sensor to see if the pallet has arrived - if arrived the stop the belt             
                belt_error_stop.SendToNXT(load); 
                status(1)=1;				% 05/10/11: Update status to show soemthing is at b  
                a=0;					    % 05/10/11: Update 'a'. 
                feed_pause_time = toc;
                feed_pause = 1;
                feeding2 = 0;				% 05/10/11: Reset flag to indicate conveyor operation now finished. 
                disp('The Pallet has Successfully arrived at the sensor')
                enteringflag = 0; 
                Fault_correct =0;
                fault_flag = 0; 
         end
    end
end
    
% 05/10/11: Following five if statements contain the five stages of the feeding sequence.
% 05/10/11: Code to check whether it is time to feed, and if so, initialise feeding sequence.

disp('Checking If Time To Feed Next pallet') 

if 	(toc-t1)>=t && feeding == 0; 		%Push pallet into system after time t.  t1 is the time at which the previous feed sequence initialised.
    disp('Time to Feed Next Pallet and Equipment is prepared') 
	
	% 05/10/11: If there is a pallet at 'a' and conveyor is off.
    if Failure_Flag ==0;
        motoron2 = move.ReadFromNXT(load);  	% 05/10/11: Checks whether conveyor motor is running.
    end
    disp('Checking if the line at a is blocked') 
	if 	a==1 && motoron2.IsRunning == 0; %if there is already a pallet at 'a' and conveyor is off. 
        disp('A Stationary Pallet was detected at a, Error State') 
        %  14/09/11: Error below commented out to allow students to continue
        %  with experiment.
        % 	However if the conveyor is spinning then the space is clearing for the pallet and its ok to start a feed!
        Kill_Line;
        Failure_Flag = 1;
        % Section to update the feed times log for control experiments 
        
        if all(status) == 1
            error_type = 'Buffer Error:Buffer Full and A New Pallet is Due to Arrive'; 
        else
            error_type = 'Feeding Error:Pallet tried to feed while there was a stationary pallet in the way,feed rate too high'; 
        end 
		feed_times = [feed_times; pallet_number toc t 0 ];
		output_logs;
	else  	% Added  05/10/11
		% 05/10/11: If there is no pallet at 'a', it is now safe to feed.
		feeding = 1;   % 05/10/11: Set feeding as a flag to indicate in the process of feeding.
		t1=toc;
        % 05/10/11: Append feed time data for logs.
		feed_times = [feed_times;pallet_number toc t 1];  
		pallet_number = pallet_number + 1;
		get_time
		disp('Time to feed next pallet, initialised feed sequence') 
    end
end

if Failure_Flag ==0;
    motoron = pushout.ReadFromNXT(load);
    motoron2 = move.ReadFromNXT(load); %Need this or else pallet might jam if feed starts just as a goes to 0 so pallet is still in the way
end 
% if the motor is not turning then start it turnign if it is time for
% feeding 
if 	feeding == 1 && motoron.IsRunning == 0 && motoron2.IsRunning == 0;  % 05/10/11: Checks whether it is time to feed and motors are off.
	feeding = 2;		% 05/10/11: Updates flag to indicate have initialised the second phase of the feeding sequence.
	lower.SendToNXT(load);  % 05/10/11: Lower the stack of pallets.
	disp('Lowering stack of pallets') 
end

if Failure_Flag ==0;
    motoron = lower.ReadFromNXT(load);  % 05/10/11: Check whether the unit is still lowering the stack.
end 
%Safe to commence stage 3 when the unit has finished lowering
% the stack. begin pushing pallet to a 
if 	feeding == 2 && motoron.IsRunning == 0  
	feeding = 3;		% 05/10/11: Updates flag to indicate have initialised the third phase of the feeding sequence.
	pushin.SendToNXT(load); % 05/10/11: Push feeding arm through to push pallet above 'a' on the line.
	disp('Pushing pallet onto point a') 
end

if Failure_Flag ==0;
    motoron = pushin.ReadFromNXT(load);	 % 05/10/11: Check whether the push-arm is still travelling.
    motoron2 = move.ReadFromNXT(load); 	 % 05/10/11: Check whether the conveyor is operating.
end 
% 05/10/11: Safe to commence stage 4 when both push-arm and conveyor are stationary.

if 	feeding == 3 && motoron.IsRunning == 0 && motoron2.IsRunning == 0   

	feeding = 4;  % 05/10/11: Updates flag to indicate have initialised the fourth phase of the feeding sequence.
	a = 1; 	%The moment pallet is being dropped onto the line a needs to be set to 1.
		% This ensures conveyor does not start moving while pallet is
		% falling
	raise.SendToNXT(load);  % 05/10/11: Raise the pallet stack, which retracts the platform under the pallet, thereby dropping it onto the conveyor.
	feed_times(size(feed_times,1),4) = toc;  % 05/10/11: Record the feed time in the log
	disp('Retracted plaform from beneath pallet at point a, pallet now stationary at a') 
end

if Failure_Flag ==0;
    motoron = raise.ReadFromNXT(load);  % 05/10/11: Check whether stack is still being raised.
end
% Only commence this stage of feeding sequence when the stack is fully raised.
% Withdraw the Pusher Arm 
if 	feeding == 4 && motoron.IsRunning == 0  
	feeding = 5;		  % Update the flag.
	pushout.SendToNXT(load);  % Withdraw the push-arm.
	disp('Begin Withdrawing push arm after feeding') 
end

if 	feeding == 5
	feeding = 0;  % Reset the flag, ready to start the feeding sequence again. 
	disp('Feed sequence completed, ready for next feed') 
end

disp('The Status at the End of Feed pallet is')
disp(status)
disp('The state of a at the end of feed pallet is')
disp(a)

