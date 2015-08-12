% Seperate pallet.m A script for use with the Legoline splitter unit which
% operates the pushing of a pallet from the mainline into the siding by the
% splitter arm
   
% seperator states
% 0 - do not push the pallet- inactive - wait until a pallet is ready to be
%pushed then initiate arm. 
% 1 - start of process, initiate arm extension if arm is inactive. 
% 2 - wait for arm to finish extending, then initite the retraction
% 3 - wait for arm to fully retract then reset the process. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if seperator_state == 0;
    if (toc - output_table(line_pointer,1)) > time_to_pusher % check that the currently inicatedted pallet in the push list is not yet at the pusher point
        % if the time elapsed is greater than the time taken for the pallet
        % to travel from the sensors to the push point them we need to
        % initiate the pusher to remove it from the line. 
        disp('A Pallet is to be pushed, intiating pusher process')
        toc 
        seperator_state = 1; % move into the next state to initaite the push process 
        if sizeofoutput(1)>line_pointer && (output_table(line_pointer+1,1)-output_table(line_pointer,1)) < 3.5
            % if the pallet is being held up by the pusher add some extra time
            % to its counter so the pusher does not move it too soon. 
            % I.E. we add some time to accoutn for the pushing action, thus
            % allowing the palelt to prgress from the edge of the pusher
            % until it is better aligned before we reactivate the arm. 
           output_table(line_pointer+1,1) = output_table(line_pointer+1,1)+0.75;
        end
    else
        % else if there is no new pallet in the push lsit then we do now
        % need to do anything. 
        disp('Waiting for a Pallet To Push')
        toc
    end
end % END OF CASE 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if  seperator_state == 1 
    push_retract.WaitFor(0,splitter); %Just in case motor is still spinning from previous pallet, wait
    disp('Initiating Arm Extension') % for the error log
    toc
    push_out.SendToNXT(splitter); %Pusher out command initiated
    seperator_state =2; % show that the pusher is to be moving out. 
end  % END OF CASE 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if seperator_state == 2 
    motoron= push_out.ReadFromNXT(splitter); % read the state of the last process to cehck if it is finished
    if motoron.IsRunning == 0
        % if the arm push out is compelte them we can retract the arm as
        % the pallet is pushed. 
        disp('Arm Extension Complete, Initiating Arm Retract')
        toc
        push_out.WaitFor(0,splitter); % a little redundancy just for safety. 
        push_retract.SendToNXT(splitter); %Retract splitter arm 
        seperator_state =3; % update the state 
    else
        % else we wait for the arm to finish extending. 
        disp('Arm Extension is On going')
        toc 
    end % end of if the action is completed
end % END OF CASE 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if seperator_state == 3
    if GetSwitch(SENSOR_1,splitter) == 1
        pause(0.1) % a short pause to allow the arm to fully press the sensor 
        push_retract.Stop('brake', splitter);% then stop the arm and brake so that it cannot be pushed back into the track by the switch 
        disp('Retraction Complete, Pushing Action Complete')
        toc 
        line_pointer = line_pointer+1; % increment line pointer such that we are now looking at the enxt pallet in the push table to see what time the next push should be at
        seperator_state = 0; % reset the satte to idle once the whole oepration is completed. 
    else % else we wait for the arm to finish retracting 
        disp('Arm Retraction is On Going')
        toc 
    end 
end % END OF CASE 3