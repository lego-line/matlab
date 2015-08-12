% Upstream.m - this script file contains the code to operate the upstream
% feed unit. It initialises the unit and then operates it feeding
% accoriding to the feed schedule. 

%% NETWORKED UNITS CONCEPT 2 CONTROL VERSION

% setup the relevant failure flags as a matter of urgency 
tic; % start the clock such that we can see ayt what time the various processes were started and stopped during setup. 
Failure_Flag = 0; % flag to track local failure of the unit - this will halt the unit 
error_type = 'none';% variable to store the error type - over written if the unit fails in some manner
fault_flag = 0; % flag to show there is some error correction process being attempted which is not part of the main operating loop 
fault_matrix = []; % variable to store the time history of the fault flag such that we can later assess how loing the unit spent in a 

%% Section to Print The File Headers for the Event Log. 
diary([path2eventlog,'Upstream_Unit.log']) % create a log file for events 
disp('Running Upstream Unit') % print a header telling me what type of unit it is 
time=clock; % add solme date and time data to show when the run commenced such that we can know which run this log file was from 
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1))];
disp(date)
time=[num2str(time(4)),' : ',num2str(time(5)),' : ',num2str(time(6))];
disp(time) 
% clear some useless variables. 
clear time
clear date

%% Setup Code to Read The NXT Data and Initialise The System 

% set feed id for use in keep_feeding and get time scripts
feed_id =0; % feed_id is set to zero to denote an upstream unit 
%Get NXT id from file
fid = fopen(path2master,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s');
%Close file
fclose(fid);
%Search for Main1 and find NXT identifier, put values into array ind

ind = strmatch('Upstr',out{1});
%Place values from array ind into Matrix LineA
Code = out{2}(ind);
OpenLink %connect to NXT

% section of code for extracting the belt running speed from the
% master_config file 
fid = fopen(path2master,'rt');
    out2 = textscan(fid,'%s %s %s');
fclose(fid);

% setup the speed variable for when we need it to assemble commands tfor
% the conveyor motors such that we can change the speeds of all line motors
% at the same time. 
speed_ind= strmatch('SPEED_U',out2{1});
speed = out2{3}(speed_ind);
speed = str2num(speed{1});

% open the master again and look for different tabular data 
fid = fopen(path2master,'rt');
out = textscan(fid,'%s	%s	%s	%s');
fclose(fid);

% find the number of feed lines
ind=strmatch('No_of_Feedlines',out{1},'exact');
Number_of_Feedlines = out{2}(ind);
disp(['The number of feed lines is ',Number_of_Feedlines{1}])
Number_of_Feedlines=str2num(Number_of_Feedlines{1});

% find the number of splitters
ind=strmatch('No_of_Splitters',out{1},'exact');
Number_of_Splitters = out{2}(ind);
disp(['The number of splitters is ',Number_of_Splitters{1}])
Number_of_Splitters=str2num(Number_of_Splitters{1});
    
% Read modules present
%Open config file
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s %s');
%Close file
fclose(fid);

% check which set of lines has priority 
ind=strmatch('Upstream',out{1});
UpstreamMode= out{3}(ind);


% setup error and feed log data 
feed_times = []; % matrix into which pallet details may be recorded on feeding. 
pallet_number = 1; % start counting pallets from 1 to n 
armcheck=0; % this variable is used to count the number of detection events at the sensor - one sighting could be an arm retracting whereas two or more adjacent detections is a pallet. 
first_run = 1; %Tells functions that this is the first run

t=0;  %time between pallet feeds, set by "get_time" - feedrate
t1=0; %toc-t1 = time since last pallet dispatched
t2=0; %toc-t2 = time since d=0
t3=0; %Debug timer
t4=0; %limit time between crate move forwards

a=0; % arrival point status variable. 
status = [0 0]; % the status of the pallets, once the pallet is no longer held 
% up it moves from a to the first status element, the second is the hold position at the end of the belt prior to transferring to the mainline. 
trap = 0; % flag to cehck if pallets get trapped on the belt
escape = 0; % flag to show that the pallet has escaped the trap 
delay =0; 
% flags to show various parts of the unloading process are ongoing. 
feeding =0;
feeding2 =0; 
feeding_3 =0; 
pallet =0; 
flag_unloading =0;

% New section to track the amount of data read/written 2/11/12
sensor_data_read_amount =0;
sensor_data_write_amount =0;
messages_data_read_amount =0;
messages_data_write_amount =0;

% variables to keep track of feeding
feeding = 0; % check if the feeding process is ongoing 
feeding2 = 0; % flag to check if transfer process is ongoing from one source
blockage=0; % flag to see if there is a downstream blockage which prevents transfer onto the mainline. 
time_of_blockage_end =0; % variable to keep track of the time of the end of the blockage 
%- since the blockage is technically the time the flag enters the mainline we delay arrivals past the point of the end of the 
% we delay allowing pallets out for a fixed time period until the pallet
% can be assumed to have passed. 
exception = 0; % flag to catch exceptions whic may not be dealt with. 
N=0; %N= Number of pallets in buffer
N_tr=0; %Number of pallets sent to transfer
N_tr_out=0; %Number of pallets counted out of transfer

time_last_edge = 0; % set this flag to show that the last pallet was at the origin such that we can alwys feed the first pallet.

OpenSwitch(SENSOR_1, upstream) %Open touch sensors
OpenSwitch(SENSOR_2, upstream)
OpenLight(SENSOR_4,'ACTIVE',upstream) % open the light sensor which dangles onto the next unit to chek the state of the belt when we are using a mainlkine buffering simualtion on the upstream. 

%   Zero loader Motors commands to move the motors back slowly which are
%   used to pull the motors back until a the relevant touch sensor is depressed thus confirming they are at a known position.  
loadA = NXTMotor('A','Power',30); %Pusher motor
loadB = NXTMotor('B','Power',15); %Lifter Motor



%% Physical Initialisations 

% This section initialises the lifter motor - if the motor does not hit the
% sensor in a given time we fail the run and issue a global shutdown,
% whislt preventing the unit doing anything else to prevent damage - else
% if the whole unit is started before initialsiation is competle then we
% likewise fail the run. 
loadB.SendToNXT(upstream); %Tell lifter to move upwards
time_start_lift = toc; 
while GetSwitch(SENSOR_2, upstream) == false  && Failure_Flag == 0 %keep spinning motor while touch sensor isn't pressed
    Go = exist (path2go);
    if Go ==2
        if exist(path2go) == 2
             
            Kill_Line
        end
        disp('ERROR:The Start Command has been executed before the motors are zeroed (Lift Sensor) quitting matlab')
        error_type = 'The Start Command has been executed before the motors are zeroed (Lift Sensor)'; 
        delete(path2errorlog)
        ffeedid=fopen(path2errorlog,'w');
        fprintf(ffeedid,'The Error Occured on the Upstream feed unit');
        fprintf(ffeedid,'\n');
        fprintf(ffeedid,'The Error Was: ');
        fprintf(ffeedid,error_type);
        fclose(ffeedid);
        COM_SetDefaultNXT(upstream);
        StopMotor('all', false);
        disp('stopped motors')
        CloseSensor(SENSOR_1)
        CloseSensor(SENSOR_2)
        CloseSensor(SENSOR_3)
        CloseSensor(SENSOR_4)
        disp('Closed All Sensors')
        COM_CloseNXT('all') %Close connection to NXT
        quit
    end
    % section to check if the motor has turned too far and is causing
    % damage to the structure 
    if (toc - time_start_lift) > 1.5
        % if the motor ahs been turnign for too long then is will cause
        % damage as the switch has not been pressed

        disp('ERROR:The Lift Sensor Has Failed to Initialise Properly and May Cause Damage')
        error_type = 'The Lift Sensor has failed to initialise properly'; 
        Failure_Flag = 1;
        COM_SetDefaultNXT(upstream);
        StopMotor('all', false);
        while exist(path2stop) == 2
            pause(0.2)
        end
        pause(5.0)
        if exist(path2go) == 2
             
            Kill_Line
        end
    end
    pause(0.2)
end

loadB.Stop('brake',upstream); %Turn off motor and brake
pause(0.5); %Allow transients to die away
loadB.Stop('off',upstream); %Turn off motor

% This section initialises the pallet pusher motor - if the motor does not hit the
% sensor in a given time we fail the run and issue a global shutdown,
% whislt preventing the unit doing anything else to prevent damage - else
% if the whole unit is started before initialsiation is competle then we
% likewise fail the run. 
loadA.SendToNXT(upstream); %Start moving pusher inwards
time_start_push = toc; 
while GetSwitch(SENSOR_1, upstream) == false  && Failure_Flag == 0 %keep spinning motor while touch sensor isn't pressed
    Go = exist (path2go);
    if Go ==2       
        if exist(path2go) == 2
             
            Kill_Line
        end
        disp('ERROR:The Start Command has been executed before the motors are zeroed (Pusher Sensor) quitting matlab')
        error_type = 'The Start Command has been executed before the motors are zeroed (Pusher Sensor)'; 
        delete(path2errorlog)
        ffeedid=fopen(path2errorlog,'w');
        fprintf(ffeedid,'The Error Occured on the Upstream feed unit');
        fprintf(ffeedid,'The Error Was: ');
        fprintf(ffeedid,error_type);
        fclose(ffeedid);
        COM_SetDefaultNXT(upstream);
        StopMotor('all', false);
        disp('stopped motors')
        CloseSensor(SENSOR_1)
        CloseSensor(SENSOR_2)
        CloseSensor(SENSOR_3)
        CloseSensor(SENSOR_4)
        disp('Closed All Sensors')
        COM_CloseNXT('all') %Close connection to NXT
        quit
    end
    % section to check if the motor has turned too far and is causing
   % damage to the structure  
   if (toc - time_start_push) > 3.0
        % if the motor ahs been turnign for too long then is will cause
        % damage as the switch has not been pressed 
        disp('ERROR:The Pusher Sensor Has Failed to Initialise Properly and May Cause Damage')
        error_type = 'The Pusher Sensor has failed to initialise properly'; 
        Failure_Flag = 1; 
        COM_SetDefaultNXT(upstream);
        StopMotor('all', false);
        while exist(path2stop) == 2
            pause(0.2)
        end
        pause(5.0)
        if exist(path2go) == 2
             
            Kill_Line
        end
   end 
   pause(0.2)
end
loadA.Stop('brake',upstream); %Brake motor
pause(0.5); %Allow transients to die away

% an old version of the code to allow the motor to hit a desired start
% state - this is left over by Konrad and seems to be good, so we don't
% bother changing it. 
reset = NXTMotor('A','Power',8,'SpeedRegulation',false); %speed regulation off so that when pusher stops moving due to reaching end of travel, motor power does not ramp up!
pos=0;
pos2=1;
reset.SendToNXT(upstream); %Tell motor to start to gently retract
motoron = reset.ReadFromNXT(upstream); %Read motor state
while (pos2 - pos) ~= 0 && Failure_Flag == 0 %read position of motor, (pos) then a small time later read position again 	(pos2) if motor is spinning pos2-pos will not equal 0. If motor has stopped, while loop will 	end since pos2-pos=0

	motoron = reset.ReadFromNXT(upstream);
	pos=motoron.Position;
	pause(0.2) %small pause before next reading since matlab can read position so fast that a slow spinning motor will appear stopped!
	motoron = reset.ReadFromNXT(upstream);
	pos2=motoron.Position;
end
reset.Stop('off',upstream);


%Purge Conveyor, move it backwards to make sure there are no pallets about to cause jam
Purge = NXTMotor('C','Power',-100,'TachoLimit', 9000,'ActionAtTachoLimit','Brake','SmoothStart',true);
Purge.SendToNXT(upstream);
Purge.WaitFor(0,upstream);

% Set up routines for feed unit. 
pushin = NXTMotor('A','Power', 100,'TachoLimit', 650,'ActionAtTachoLimit','Brake'); %Move pusher in
pushout = NXTMotor('A','Power', -100,'TachoLimit', 650,'ActionAtTachoLimit','Brake'); %Move pusher out

raise = NXTMotor('B','Power',100, 'TachoLimit', 200,'ActionAtTachoLimit','Brake'); %Lift pallets up
lower = NXTMotor('B','Power',-50,'TachoLimit', 200,'ActionAtTachoLimit','Brake'); %Drop pallets down

move = NXTMotor('C','Power',(-1*(speed+10)),'TachoLimit', 2350 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward to light sensor at end of feed
move_full = NXTMotor('C','Power',(-1*(speed+10)),'TachoLimit', 3500 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward past light sensor and onto transfer unit (used when zero buffer)
move_unload = NXTMotor('C','Power',(-1*(speed+10)),'TachoLimit', 1800 ,'ActionAtTachoLimit','Brake','SmoothStart',true);

% 05/10/11: Withdraw push-arm on feed unit.
pushout.SendToNXT(upstream);
pushout.WaitFor(0,upstream);
%% Operations Section
%% Waiting to go section - wait until stop changes to go and then start operations 
Go = exist (path2go); %delay program until GO exists
while Go == 0 && Failure_Flag ==0
	Go = exist (path2go);
	pause (0.2); %slow down check so the loop isn't just wasting processor
end
% Reset the Clock such that all times in the log are synced for the
% different units. 
tic;
fault_matrix = [fault_matrix;toc,fault_flag];
Go = exist (path2go);
% run the get time script for the first time to read in data.
get_time;
% record the time the program started 
Time_started_Program = toc; 

if strcmp(UpstreamMode,'Feed') == 1
    % in this case the upstream unit is set to operate on feed line
    % priority - if a pallet is coming down the feed line then the mainline
    % must hold until it arrives on the mainline, unless the mainline
    % pallet will not impede the pallet from the feed line sprocess. Hence
    % the unsptream unti must buffer a single pallet if it arrives
    % coincidentally with one from the first feed unit determined byc
    % checking the light sensor it has palced on that transfer line. 
    while Go==2 && Failure_Flag == 0
        %Whislt go is set and there is no local failure
        disp('Start of Loop')
        toc

                % Use The Network to check for a blockage
        Network_Read; % read from the network. 
        if (size(State_Read,2)) ~= 0 % look for he state vector from the upstream line 
            if State_Read(size(State_Read,2)) ==  0
                % case where the e buffer position is empty
                % if there was a pallet in the e position then we record
                % the position of the edge as there is no pallet present
                % now. 
                if previous_state_pallet == 1
                    time_last_edge = toc; 
                end 
                if (toc - time_last_edge) > 3 
                    % we wait a little while for the edge of the pallet to
                    % pass if 
                    blockage = 0;
                end 
                % show that the last reading recorded there was no pallet
                % presen. 
                previous_state_pallet=0;
            else 
                % else tehre is a pallet present and therefore the line is
                % blocked and so we cannot feed. 
                previous_state_pallet=1;
                blockage = 1; 
            end
        else 
            % else if tehre is no file then the transfer unit is not
            % feeding and hence we know that we can never get a blockage.,
            % this allows us to create a very large upstream buffer by
            % having mainline buffer sections following this upstream. 
            blockage = 0;
        end 
        Keep_Feeding_Pallet; % run the keep feeding pallet script to check if it is time to feed the next pallet. 
        status =[a status(2)];% update the status based on the result of the above to show that pallets may have moved on or not. 

        if all(status == [0 0]) == 1
            % if the ststaus is 00 then we don't need to takje any action as
            % there are no pallets to worry about.
            disp('Status is 00')
            toc
        end

        if all(status == [1 0]) == 1
            % if the status is 10 then the pallet that has jsut arrived should
            % be moved to the holding point by the keep feeding script. 
            disp('Status is 10, pallet should move to end of belt')
            toc
        end

        if all(status ==[0 1]) == 1
            % if the status is 01 then we check if there is a blockage
            % caused by the feed line transferring a pallet in, if tehre is
            % a blockage we hold,else we transferr the palelt to the
            % mainline belt.
            disp('Status is 01')
            toc
            % if can unload safely onto the mainline then do so immediately 
            if feeding2 == 0 && blockage == 0 && flag_unloading == 0
                % if the belt is not already running and there is no
                % blockage 
                move_unload.SendToNXT(upstream)% transfer the pallet to the mainline 
                disp('Unloading the pallet onto the Mainline')
                toc
                feeding2 = 1; % set the feeding 2 flag to show the pallet is exiting the section and that the belt is moving to accoutn for the small delay it takes to send the command to the motor 
                flag_unloading =1; % this shows a pallet is exiting 
            end
            % read the state of the motor
            motoron=move_unload.ReadFromNXT(upstream);
            % if the unloading is in process already(from a previous
            % iteration, we check if is its completed.
            if motoron.IsRunning == 0 && feeding2 == 1 && flag_unloading == 1
                % if the belt was moving and has now stopped then th
                % etransfer is complete
                disp('The Pallet has been ejected onto the mainline')
                toc
                % reset the feed2 flag to show the belt is not moving 
                feeding2=0; 
                % update the status in case a palelt has arrived in the
                % meantime and to show that al pallets on the belt have
                % moved. 
                status =[a 0];
                flag_unloading =0;
            end 
        end

        if all(status == [1 1]) == 1
            % if the status is 11 then we check if there is a blockage
            % caused by the feed line transferring a pallet in, if tehre is
            % a blockage we hold,else we transferr the palelt to the
            % mainline belt.
            
            disp('status is 11')
            toc
            % if can unload safely onto the mainline then do so immediately 
            if feeding2 == 0 && blockage == 0 && flag_unloading == 0
                % if the belt is not already running and there is no
                % blockage 
                move.SendToNXT(upstream)
                disp('Unloading the pallet onto the mainline')
                feeding2 = 1;
                flag_unloading =1;
            end 
            % check the state of the motor 
            motoron= move.ReadFromNXT(upstream);
            % if the unloading is in process already(from a previous
            % iteration, we check if is its completed.
            if motoron.IsRunning == 0 && feeding2 == 1 && flag_unloading == 1
                % if the belt was moving and has now stopped then the
                % transfer is complete
                disp('The Pallet has been ejected onto the mainline')
                toc
                feeding2=0; 
                flag_unloading =0;  
                % update the status in case a palelt has arrived in the
                % meantime and to show that al pallets on the belt have
                % moved. 
                status =[0 1];
                a = 0; 
            end 
        end 

        % this is the end of the cases, if this is the first time through
        % the loop then we put down the first_run flag to show we are on a
        % later iteration and any setup of local variables done in the
        % script files does not need to happen again. 
        if first_run ==1
                first_run = 0; %15/11/11 line moved from bottom of code to avoid overwriting sensor data 
        end
        % update the status of go to check if we should continue running 
        Go = exist (path2go); %check go still exists
        
        % update the fault matrix which can be logged out 
        fault_matrix = [fault_matrix;toc,fault_flag];
        disp('End of Loop')
        toc
    end
elseif strcmp(UpstreamMode,'Main') == 1
    % in this case the upstream unit is set to operate on main line
    % priority - if a pallet is coming down the feed line then it must wait until the  mainline
    % is clear before it arrives on the mainline, unless the mainline
    % pallet will not impede the pallet from the feed lines process.hence
    % the upstream unit will never buffer pallets and will simply transfer
    % them to the mainline as soon as it is able to do so. 
    while Go==2 && Failure_Flag == 0;
        disp('Start of loop')    
        toc

        % update the status
        Keep_Feeding_Pallet; % run the keep feeding pallet script to check if it is time to feed the next pallet. 
        status =[a status(2)];% update the status based on the result of the above to show that pallets may have moved on or not. 

       if all(status == [0 0]) == 1
            % if the ststaus is 00 then we don't need to takje any action as
            % there are no pallets to worry about.
            disp('Status is 00')
            toc
       end

        if all(status == [1 0]) == 1
            % if the status is 10 then the pallet that has jsut arrived should
            % be moved to the holding point by the keep feeding script. 
            disp('Status is 10, pallet should move to end of belt')
            toc
        end

        if all(status ==[0 1]) == 1
            % if the status is 01 then we transfer the pallet to the
            % mainline belt.
            disp('Status is 01')
            toc
            % if can unload safely onto the mainline then do so immediately 
            if feeding2 == 0 && flag_unloading == 0
                % if the belt is not already running we start it running 
                move_unload.SendToNXT(upstream)
                disp('Unloading the pallet onto the Mainline')
                toc
                feeding2 = 1;
                flag_unloading =1;
            end
            motoron=move_unload.ReadFromNXT(upstream);
            % if the unloading is in process already(from a previous
            % iteration, we check if is its completed.
            if motoron.IsRunning == 0 && feeding2 == 1 && flag_unloading == 1
                % if the belt was moving and has now stopped then the
                % transfer is complete
                disp('The Pallet has been ejected onto the mainline')
                toc
                % update the status in case a palelt has arrived in the
                % meantime and to show that al pallets on the belt have
                % moved. 
                feeding2=0; 
                status =[a 0];
                flag_unloading =0;
            end 
        end

        if all(status == [1 1]) == 1
            % if the status is 11 then we transfer the pallet to the
            % mainline belt.
            disp('status is 11')
            toc
            if feeding2 == 0 && flag_unloading == 0
                % if the belt is not already running we
                % start it up 
                move.SendToNXT(upstream)
                disp('Unloading the pallet onto the mainline')
                toc
                feeding2 = 1;
                flag_unloading =1;
            end 
            motoron= move.ReadFromNXT(upstream);
            % if the unloading is in process already(from a previous
            % iteration, we check if is its completed.
            if motoron.IsRunning == 0 && feeding2 == 1 && flag_unloading == 1
                % if the belt was moving and has now stopped then the
                % transfer is complete
                disp('The Pallet has been ejected onto the mainline')
                toc
                % update the status in case a palelt has arrived in the
                % meantime and to show that al pallets on the belt have
                % moved. 
                feeding2=0; 
                status =[0 1];
                flag_unloading =0;
                a = 0; 
            end 
        end 

        % this is the end of the cases, if this is the first time through
        % the loop then we put down the first_run flag to show we are on a
        % later iteration and any setup of local variables done in the
        % script files does not need to happen again. 
        if first_run ==1
                first_run = 0; %15/11/11 line moved from bottom of code to avoid overwriting sensor data 
        end
        % update the status of go to check if we should continue running 
        Go = exist (path2go); %check go still exists
        % update the fault matrix which can be logged out 
        fault_matrix = [fault_matrix;toc,fault_flag];
        disp('End of Loop')
        toc
    end
end
% write the arrival data to its file for evaluation
output_logs;
% record the time the loop was broken. 
Time_Finished_Program = toc; 
%% shutdown routine to stop all motors, turn off all sensors and shutdown
 
% save the fault matrix at the end of the run for later evaluation. 
path2faultmatrix = [path2failuredata,'Upstream_Failure_Matrix.mat'];
save(path2faultmatrix,'fault_matrix')

% if this unit failed then we have to change the error file to show which
% unit caused the failure and its cause. 
if Failure_Flag == 1
    delete(path2errorlog)
    ffeedid=fopen(path2errorlog,'w');
    fprintf(ffeedid,'The Error Occured on the Upstream Feed Unit');
    fprintf(ffeedid,'\n');
    fprintf(ffeedid,'The Error Was: ');
    fprintf(ffeedid,error_type);
    fclose(ffeedid);
end

% since this was a local run then no sensor data was read or written,
% however some messages may have been given via the data bus, for example
% if the statedraw was running, and hence we discrad these. 
sensor_data_read_amount =0;
sensor_data_write_amount =0;
messages_data_read_amount=0;
messages_data_write_amount=0;

% print some data rate statistics to the log file for analyis
disp(['The Total Sensor data Read was ',num2str(sensor_data_read_amount),' bytes'])
disp(['The Total Sensor data Written was ',num2str(sensor_data_write_amount),' bytes'])
disp(['The Total Message data Read was ',num2str(messages_data_read_amount),' bytes'])
disp(['The Total Message data Written was ',num2str(messages_data_write_amount),' bytes'])
disp(['In ',num2str((Time_Finished_Program-Time_started_Program)),' seconds'])

% close the line/conenction to NXT.
COM_SetDefaultNXT(upstream);
% stop all motors and close all sensors 
StopMotor('all', false);
disp('stopped motors')
CloseSensor(SENSOR_1)
CloseSensor(SENSOR_2)
CloseSensor(SENSOR_3)
CloseSensor(SENSOR_4)
disp('Closed All Sensors')
COM_CloseNXT('all') %Close connection to NXT
quit % exit this instance of matlab