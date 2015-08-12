% Keep_Feeding_Pallet.m  This file contains the code to: 
	% Move a newly fed pallet forward from 'a' to 'b'.
	% Proceed through the five stages of the feeding sequence. 
	% NB: Feeding a pallet leads to a = 1 in phase 4.  This is used to
	% trigger the conveyor to move the pallet forward from 'a' to 'b' and update the status.
    % without causing the line to fail when new palelts are added as the
    % upstream unit should not jam. 
%% NETWORKED UNITS CONTROL VERSION
    
disp('Running Keep Feeding Pallet Script')
toc
% (t1+t - toc); = time interval between pallets comparred to time now. 

% 05/10/11: Code for moving newly fed pallet forward from 'a' to 'b'.
% 05/10/11: First need to check whether conveyor and/or elevator motors are running.

motoron = move.ReadFromNXT(upstream); 		%Do not try to do this if move is already moving!! 
motoron2 = raise.ReadFromNXT(upstream); 		%a is 1, but raise motor is still spinning, must wait

if a == 1 && motoron.IsRunning == 0 && motoron2.IsRunning == 0 && feeding2 == 0 && trap == 0 && status(2) == 0 && feeding_3 == 0
	move.SendToNXT(upstream); 
    disp('start to move conveyor from point a to b'); 
	feeding2 = 1;	
    feeding_3 = 1;
    % 05/10/11: feeding2 used as a flag to indicate the conveyor motor is
    % driving.  Also indicates that the 'move' command was initiated from within feed_pallet rather than through feed_5.
    % the feeding 3 flag detects the movement process transferring a pallet
    % from the arrival point a to the point b underneath the light sensor 
end

%% Cell To Check If Successfully Moved pallet 

motoron = move.ReadFromNXT(upstream);  		%  05/10/11: Checks again whether conveyor motor is running.
disp('Checking if Successfuly Moved Pallet')
if 	feeding2 == 1 && motoron.IsRunning == 0 && feeding_3 == 1 % 05/10/11: Checks when have just finished moving pallet with conveyor from 'a' to 'b'.
    % 05/10/11: Update status to show something is at b  
	a = 0;					    % 05/10/11: Update 'a' as that pallet has moved. 
	feed_pause_time = toc;      % start the feed pause
	feed_pause = 1;             % shoiw that there is a feed pause. 
	feeding2 = 0;				% 05/10/11: Reset flag to indicate conveyor operation now finished.
	disp('Feed conveyor stopped,Pallet Transferred To Mainline')
    status(2) = 1;              % if the conveyor has stopepd and something is at b we must update the first element of the status vector. 
    toc
    feeding_3 =0;               % clear the relevant feeding flag to show that this process is completed. 
end

%%
% 05/10/11: Following five if statements contain the five stages of the
% feeding sequence.
% 05/10/11: Code to check whether it is time to feed, and if so, initialise feeding sequence. 
disp(' Checking If Time To Feed Next pallet') 
if 	(toc-t1)>=t && feeding == 0; 		%Push pallet into system after time t.  t1 is the time at which the previous feed sequence initialised.
    disp('Time to Feed Next Pallet and Equipment is prepared') 
	
	% 05/10/11: If there is a pallet at 'a' and conveyor is off.
	motoron2 = move.ReadFromNXT(upstream);  	% 05/10/11: Checks whether conveyor motor is running.
    disp('Checking if the line at a is blocked') 
	if 	a==1 && motoron2.IsRunning == 0; %if there is already a pallet at 'a' and conveyor is off. 
    disp('A Stationary Pallet was detected at a, Error State') 
	%  14/09/11: Error below commented out to allow students to continue
	%  with experiment.
	% 	However if the conveyor is spinning then the space is clearing for the pallet and its ok to start a feed!
        Kill_Line
        % Section to update the feed times log for control experiments 
		error_type = 'Pallet tried to feed while there was a stationary pallet in the way'; 
        Failure_Flag =1; 
		feed_times = [feed_times; pallet_number toc t 0]
		output_logs;
	else  	% Added  05/10/11
		% 05/10/11: If there is no pallet at 'a', it is now safe to feed.
		feeding = 1;   % 05/10/11: Set feeding as a flag to indicate in the process of feeding.
		t1=toc;
        % 05/10/11: Append feed time data for logs.
		feed_times = [feed_times;pallet_number toc t 1]
		pallet_number = pallet_number + 1;
		get_time
		disp('Time to feed next pallet, initialised feed sequence') 
	end

end



motoron = pushout.ReadFromNXT(upstream);
motoron2 = move.ReadFromNXT(upstream); %Need this or else pallet might jam if feed starts just as a goes to 0 so pallet is still in the way
% if the motor is not turning then start it turnign if it is time for
% feeding 
if 	feeding == 1 && motoron.IsRunning == 0 && motoron2.IsRunning == 0;  % 05/10/11: Checks whether it is time to feed and motors are off.
	feeding = 2;		% 05/10/11: Updates flag to indicate have initialised the second phase of the feeding sequence.
	lower.SendToNXT(upstream);  % 05/10/11: Lower the stack of pallets.
	disp('Lowering stack of pallets') 
end


motoron = lower.ReadFromNXT(upstream);  % 05/10/11: Check whether the unit is still lowering the stack.
%Safe to commence stage 3 when the unit has finished lowering
% the stack. begin pushing pallet to a however the platform is in the way
% to prevent the pallet falling directly onto the bands and moving them off
% their bearings. 
if 	feeding == 2 && motoron.IsRunning == 0  
	feeding = 3;		% 05/10/11: Updates flag to indicate have initialised the third phase of the feeding sequence.
	pushin.SendToNXT(upstream); % 05/10/11: Push feeding arm through to push pallet above 'a' on the line.
	disp('Pushing pallet onto point a') 
end

% this stage of the feeding sequence raises the stack and deposits the
% pallet onto the line (as all connected to one motor), thus we prevent the
% pallets falling down and getting jammed as the push arm retracts and
% prevent the pallet tipping onto the line. 
motoron = pushin.ReadFromNXT(upstream);	 % 05/10/11: Check whether the push-arm is still travelling.
motoron2 = move.ReadFromNXT(upstream); 	 % 05/10/11: Check whether the conveyor is operating.
% 05/10/11: Safe to commence stage 4 when both push-arm and conveyor are stationary.
if 	feeding == 3 && motoron.IsRunning == 0 && motoron2.IsRunning == 0   
	feeding = 4;  % 05/10/11: Updates flag to indicate have initialised the fourth phase of the feeding sequence.
	a = 1; 	%The moment pallet is being dropped onto the line a needs to be set to 1.
		% This ensures conveyor does not start moving while pallet is
		% falling
	raise.SendToNXT(upstream);  % 05/10/11: Raise the pallet stack, which retracts the platform under the pallet, thereby dropping it onto the conveyor.
	feed_times(size(feed_times,1),4) = toc;  % 05/10/11: Record the feed time in the log
	disp('Retracted plaform from beneath pallet at point a, pallet now stationary at a') 
    toc
end

motoron = raise.ReadFromNXT(upstream);  % 05/10/11: Check whether stack is still being raised.
% Only commence this stage of feeding sequence when the stack is fully raised.
% Withdraw the Pusher Arm from the base of the stack such that it is ready
% to pus again. 
if 	feeding == 4 && motoron.IsRunning == 0  
	feeding = 5;		  % Update the flag to show where we are in the sequence.
	pushout.SendToNXT(upstream);  % Withdraw the push-arm.
	disp('Begin Withdrawing push arm after feeding') 
    toc
end

motoron = pushout.ReadFromNXT(upstream);  % 05/10/11: Check whether stack is still being raised.
% once the pusher arm is retracting then we can state that the feed
% sequence is compelted and thus we reset the local flag to show that we
% are ready for the next pallet. 
if 	feeding == 5 && motoron.IsRunning == 0  
	feeding = 0;  % Reset the flag, ready to start the feeding sequence again. 
	disp('Feed sequence completed, ready for next feed') 
    toc
end

% Display some comments for the log file. 
disp('The state of a at the end of feed pallet is')
disp(a)
toc 