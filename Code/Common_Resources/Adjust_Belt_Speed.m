% Adjust Belt Speed.m - a script file called by the global control unit_x
% operating files to check if the belt speed needs adjusting in order to
% move orders around the system faster or slower in pursuing a larger
% strategy. 
disp('Checking if Belt Speed Is Correct')
toc 
     if exist('feed_id','var')
            if feed_id > 0
                    % cases for the general feed units 
                if eval(['Belt_Speed_',num2str(feed_id)]) ~= Previous_Belt_Speed   
                    % create new instructions just like in the feed setup
                    % routine using the formula speed = base speed +
                    % (0.1*speed* mutliplier) - where the mutliplier is
                    % read in from the global instructions 
                    disp('The Belt Speed Is Incorrect- Creating New Instructions')
                    newspeed = (speed+(eval(['Belt_Speed_',num2str(feed_id)])*(speed/10)));
                    % place limits on the new speed such that it meets the
                    % specified range for the motors,speed is a magnitude
                    % only so limit it in the positive range
                    if newspeed > 100
                        newspeed = 100;
                    elseif newspeed < 0 
                        newspeed = 0; 
                    end 
                    % here the sign is applied dependant on the motor
                    % location and orientation and the action which is
                    % requried. 
                    move = NXTMotor('C','Power',(-1*newspeed),'TachoLimit', 2350 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward to light sensor at end of feed
                    move_full = NXTMotor('C','Power',(-1*newspeed),'TachoLimit', 3500 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward past light sensor and onto transfer unit (used when zero buffer)
                    move_correct = NXTMotor('C','Power',(-1*newspeed),'SmoothStart',true);
                    Previous_Belt_Speed  = eval(['Belt_Speed_',num2str(feed_id)]);
                else
                    disp('The Belt Speed Is Still Correct')
                end 
            elseif feed_id == 0
                % case for the upstream unit 
            end 
    elseif exist('Transfer_id','var')
        % create new instructions for the various transfer processes just
        % as in Transfer_Setup.
        if eval(['Belt_Speed_',num2str(Transfer_id)]) ~= Previous_Belt_Speed  
                    disp('The Belt Speed Is Incorrect- Creating New Instructions')
                    newspeed = (speed+(eval(['Belt_Speed_',num2str(Transfer_id)])*(speed/10)));
                    % create new instructions just like in the feed setup
                    % routine using the formula speed = base speed +
                    % (0.1*speed* mutliplier) - where the mutliplier is
                    % read in from the global instructions 
                    if newspeed > 100
                        newspeed = 100;
                    elseif newspeed < 0 
                        newspeed = 0; 
                    end 
                    % here the sign is applied dependant on the motor
                    % location and orientation and the action which is
                    % requried. 
                    step = NXTMotor('C','Power',(-1*newspeed),'TachoLimit', dist ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 1 step (newer alternative to move)
                    step2 = NXTMotor('C','Power',(-1*newspeed),'TachoLimit', (dist*2) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 2 step (newer alternative to move)
                    step3 = NXTMotor('C','Power',(-1*newspeed),'TachoLimit', (dist*3) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 3 step (newer alternative to move)
                    % correct the error cases also 
                    step_correction = NXTMotor('C','Power',(-1*newspeed),'TachoLimit',750,'ActionAtTachoLimit','Brake','SmoothStart',true);
                    step_correction_reverse= NXTMotor('C','Power',newspeed,'TachoLimit',750,'ActionAtTachoLimit','Brake','SmoothStart',true);
                    Previous_Belt_Speed  = eval(['Belt_Speed_',num2str(Transfer_id)]);
        else
                    disp('The Belt Speed Is Still Correct')
         end 
    elseif exist('Main_id','var')
        % create new mailine processes just as in Mainline setup 
        if eval(['Belt_Speed_',num2str(Main_id)]) ~= Previous_Belt_Speed 
            % if the belt speed is to be changed 
            disp('The Belt Speed Is Incorrect- Creating New Instructions')
                    newspeed = (speed+(eval(['Belt_Speed_',num2str(Main_id)])*(speed/10)));
                    % create new instructions just like in the feed setup
                    % routine using the formula speed = base speed +
                    % (0.1*speed* mutliplier) - where the mutliplier is
                    % read in from the global instructions 
                    if newspeed > 100
                        newspeed = 100;
                    elseif newspeed < 0 
                        newspeed = 0; 
                    end 
            % here the sign is applied dependant on the motor
            % location and orientation and the action which is
            % requried.                  
            conveyor_1_GO = NXTMotor('B','Power',(-1*newspeed));
            conveyor_2_GO = NXTMotor('A','Power',newspeed);

            conveyor_1_handover_stop = NXTMotor('B','Power',(-1*newspeed),'TachoLimit', 580 ,'ActionAtTachoLimit','Brake','SmoothStart',true);
            conveyor_1_step  = NXTMotor('B','Power',(-1*newspeed),'TachoLimit', dist ,'ActionAtTachoLimit','Brake','SmoothStart',true);%step crate forward 1 step (newer alternative to move)
            conveyor_1_step2 = NXTMotor('B','Power',(-1*newspeed),'TachoLimit', (dist*2) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 2 step (newer alternative to move) step (newer alternative to move)
            conveyor_2_step  = NXTMotor('A','Power',newspeed,'TachoLimit', dist2 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 1 step
            conveyor_2_unload =NXTMotor('A','Power',newspeed,'TachoLimit', 820 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %small step to push it off the edge
            Previous_Belt_Speed  = eval(['Belt_Speed_',num2str(Main_id)]);
        else
                disp('The Belt Speed Is Still Correct')
         end 
    end  

