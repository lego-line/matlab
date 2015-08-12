% Seperate pallet.m A script for use with the Legoline splitter unit which
% operates the pushing of a pallet from the mainline into the siding by the
% splitter arm
   
% seperator states
% 0 - do not push the pallet- inactive
% 1 - arm is moving out 
% 2 arm is extending
% 3 arm is retracting 

if (toc - output_table(line_pointer,1)) > time_to_pusher && seperator_state == 0; 
    seperator_state = 1;
    if sizeofoutput(1)>line_pointer && (output_table(line_pointer+1,1)-output_table(line_pointer,1)) < 3.5
        % if the pallet is being held up by the pusher add some extra time
        % to its counter so the pusher does not move it too soon. 
            output_table(line_pointer+1,1) = output_table(line_pointer+1,1)+0.75;
    end
end

if  seperator_state == 1 
    push_retract.WaitFor(0,splitter); %Just in case motor is still spinning from previous pallet, wait
    disp('Initiating Arm Extension')
    push_out.SendToNXT(splitter); %Pusher out
    seperator_state =2;
end 

motoron= push_out.ReadFromNXT(splitter);
if seperator_state == 2 && motoron.IsRunning == 0
    disp('Arm is Extended')
    push_out.WaitFor(0,splitter);
    push_retract.SendToNXT(splitter); %Retract splitter
    seperator_state =3;
    disp('Initiating Arm Retract')
end

if seperator_state == 3 && GetSwitch(SENSOR_1,splitter) == 1
    push_retract.Stop('brake', splitter);
    push_retract.Stop('off', splitter);
    disp('Finished Pusing the Pallet')
    line_pointer = line_pointer+1;
    seperator_state = 0; 
end