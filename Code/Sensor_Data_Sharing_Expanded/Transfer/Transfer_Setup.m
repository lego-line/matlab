% Transfer_Setup.m- a file called by all of the transfer lines which
% performs the intialisation of the lines and then selects the appropriate
% transfer script to run. 
%%%%%%%%%%%%%%%%%%%%%NETWORKED SENSORS VERSION2 VERSION%%%%%%%%%%%%%%%%%%%%%%%%
%% Section of Code Detailing the Setup of the Transfer Unit from configuration
disp('Running Transfer Unit Setup')
% Files 
%Open config master to get NXT id
fid = fopen(path2master,'rt');
%Scan within file for text with certain formatting
out = textscan(fid, '%s	%s');
%Close file
fclose(fid);

Failure_Flag = 0; 
error_type = 'none';
tic;
fault_flag =0;
fault_matrix = []; 
%Finds correct label within read data from config file by matching string
%to identify NXT

ind = strmatch(strcat('Tran',num2str(Transfer_id)),out{1},'exact');
if length(ind) > 1
     ind=ind(1);
end 
%Reads corresponding NXT Mac address into variable Code
disp('Found Code')
Code = [out{2}(ind)]

% Establish connection with the NXT brick
OpenLink;

fid = fopen(path2master,'rt');
    out2 = textscan(fid,'%s %s %s');
fclose(fid);
speed_ind= strmatch('SPEED_T',out2{1});
speed = out2{3}(speed_ind);
disp(['The Speed is ' speed])
speed = str2num(speed{1});

% Read maximum buffer size from the config file

%Open config file
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s	%s	%s %s');
%Close file
fclose(fid);

%Search for 'LineN' and put values into array ind
ind = strmatch(strcat('Line', num2str(Transfer_id)), out{1});
if length(ind) > 1
     ind=ind(1);
end 
Buffer_num = out{4}(ind);
disp(['The Buffer Number is ' Buffer_num])
Buffer_num = str2num(Buffer_num{1});
%% Initialisation Section Of Code To Establish Initial Conditions and Then
%Wait Until GO File Exists Before Starting Operations 
disp('Setting Up Running Variables')
toc 
% Find number of pallets buffered in transfer, based on number of buffering
% stations being used. setup reference for switch 
if Buffer_num == 0
	num_b = 0;
elseif Buffer_num < 4
	num_b = 1; %number of pallets buffered in transfer
elseif Buffer_num == 4
	num_b = 2;
elseif Buffer_num == 5
	num_b = 3;
end

% Definition of relevant varibales 
% New section to track the amount of data read/written 2/11/12
sensor_data_read_amount =0;
sensor_data_write_amount =0;
messages_data_read_amount =0;
messages_data_write_amount =0;

tr_end=0; %no pallet at end of transfer buffer
krate=0;

first_run = 1;
t2=0;
t3=0;
a=0;
b=0;
c=0;
pallet = 0;

unload_state = 1;
unload_retry_flag =0; 
transfer_platform_sensor_data = []; 
% variables for storing the status of the transfer platform. 
platform_status =0;
platform_previous_status=0;
% Initialisation processes for each of the mechanical and sensor units
% attached to the transfer controller 

filename_local_tval = ['Tval_Current',num2str(Transfer_id),'.txt'];
filepath_local_tval = [path2databus, filename_local_tval]; 
pallet_present = 0; % flag to keep track of if the pallet is actually at the point to be transferred. 
error_loop_iteration = 0; 

pallet_move = 0;
transfer_flag =0; % flag to show when a transfer is in progress
belt_running_flag =0; % flag to show when the belt is moving 
both_belt_move_flag=0;

% Define distance according to buffer size based on switch variable 
if num_b == 1 || num_b == 0;
	dist = 5000;
end

if num_b == 2;
	dist = 2500;
end

if num_b == 3;
	dist = 1540;
end

disp('Finished Setting Up Running variables')
toc
%% Physical Initialisations')
disp('Beginning Physical Initialisations')
toc 
%reset motors
%Initialise touch and light sensors
disp('Initialising Sensors')
OpenSwitch(SENSOR_1, adder); 
OpenSwitch(SENSOR_2, adder); % sensor for the arm rotation 
OpenLight(SENSOR_3, 'ACTIVE', adder);
OpenLight(SENSOR_4, 'ACTIVE', adder);


% Purge conveyor
disp('Purging the Conveyor')
toc
conveyor_purge = NXTMotor('C','Power',100,'TachoLimit', (dist*3) ,'ActionAtTachoLimit','Brake','SmoothStart',true);
conveyor_purge.SendToNXT(adder);

%    Zero adder Motors
%Reset transfer unit "lift"
disp('Initialising the Mainline Platform Lift')
toc 
adderliftreset = NXTMotor('A','Power', -10); 
adderliftreset.SendToNXT(adder);
time_lift_start = toc; 
while GetSwitch(SENSOR_1, adder) == 0 && Failure_Flag == 0
    % section of code to cehck if the start command ahs been issued too
    % early 
    Go = exist (path2go);
    if Go ==2       
        
        disp('ERROR:The Start Command has been executed before the motors are zeroed (Platform Sensor) quitting matlab')
        error_type = 'The Start Command has been executed before the motors are zeroed (Platform Sensor)'; 
        delete(path2errorlog)
        ffeedid=fopen(path2errorlog,'w');
        fprintf(ffeedid,'The Error Occured on Transfer Unit ');
        fprintf(ffeedid,Transfer_id);
        fprintf(ffeedid,'\n');
        fprintf(ffeedid,'The Error Was: ');
        fprintf(ffeedid,error_type);
        fclose(ffeedid);
        COM_SetDefaultNXT(adder);
        StopMotor('all', false);
        disp('stopped motors')
        CloseSensor(SENSOR_1)
        CloseSensor(SENSOR_2)
        CloseSensor(SENSOR_3)
        CloseSensor(SENSOR_4)
        disp('Closed All Sensors')
        COM_CloseNXT('all') %Close connection to NXT
        if exist(path2go)
            Kill_Line;
        end
        quit
    end
     if (toc - time_lift_start) > 5
        % if the motor has been turnign for too long then is will cause
        % damage as the switch has not been pressed 
        disp('ERROR:The Lift Sensor Has Failed to Initialise Properly and May Cause Damage')
        error_type = 'The Lift Sensor has failed to initialise properly'; 
        Failure_Flag = 1
        COM_SetDefaultNXT(adder);
        StopMotor('all', false);
        while exist(path2stop) == 2
            pause(0.2)
        end
        pause(5.0)
        if exist(path2go)
            Kill_Line;
        end
    end
    pause(0.2); % pause to save processor power 
end

adderliftreset.Stop('brake', adder);
adderliftreset.Stop('off', adder);
disp('Finished Platform Setup')
toc 
%Reset transfer unit "arm"
disp('Initialising the Transfer Unit Arm')
toc
adderarmreset = NXTMotor('B','Power',5);
adderarmreset.SendToNXT(adder);
time_arm_start = toc; 
while GetSwitch(SENSOR_2, adder) == 0 && Failure_Flag == 0
    Go = exist (path2go);
    if Go ==2          
        disp('ERROR:The Start Command has been executed before the motors are zeroed (Arm Sensor) quitting matlab')
        error_type = 'The Start Command has been executed before the motors are zeroed (Arm Sensor)'; 
        delete(path2errorlog)
        ffeedid=fopen(path2errorlog,'w');
        fprintf(ffeedid,'The Error Occured on Transfer Unit ');
        fprintf(ffeedid,Transfer_id);
        fprintf(ffeedid,'\n');
        fprintf(ffeedid,'The Error Was: ');
        fprintf(ffeedid,error_type);
        fclose(ffeedid);
        COM_SetDefaultNXT(adder);
        StopMotor('all', false);
        disp('stopped motors')
        CloseSensor(SENSOR_1)
        CloseSensor(SENSOR_2)
        CloseSensor(SENSOR_3)
        CloseSensor(SENSOR_4)
        disp('Closed All Sensors')
        COM_CloseNXT('all') %Close connection to NXT
        if exist(path2go) == 2
            Kill_Line;
        end
        quit
    end
    if (toc - time_arm_start) > 7
        % if the motor ahs been turnign for too long then is will cause
        % damage as the switch has not been pressed 
        disp('ERROR:The Arm Sensor Has Failed to Initialise Properly and May Cause Damage')
        error_type = 'The Arm Sensor has failed to initialise properly'; 
        Failure_Flag = 1;
        COM_SetDefaultNXT(adder);
        StopMotor('all', false);
        while exist(path2stop) == 2
            pause(0.2)
        end
        pause(5.0)
        if exist(path2go) == 2
            Kill_Line;
        end
    end
    pause (0.2); % pause to save processor power 
end
pause(0.05)
adderarmreset.Stop('brake', adder);
disp('Finished Arm reset')
toc 

disp('Finished Physical Initialisations')
toc 

%% Motor Commands


% timing pause to allow arm to move
% while toc < 2 && Failure_Flag == 0
% end
% adderarmreset.Stop('off', adder);
% changed to active braking in order to better determine position and
% prevent errors 17/01/13
disp('Started Setting Up Motor Commands')
toc 

% Setup Commands or running the motor 
up = NXTMotor('A','Power', -100,'TachoLimit', 270); %Raise conveyor platform
down = NXTMotor('A','Power', 100,'TachoLimit', 270); %Lower conveyor platform

add = NXTMotor('B','Power', -10, 'TachoLimit',125); %Load block
retract = NXTMotor('B','Power', 25); %Retract arm

step = NXTMotor('C','Power',(-1*speed),'TachoLimit', dist ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 1 step (newer alternative to move)
step2 = NXTMotor('C','Power',(-1*speed),'TachoLimit', (dist*2) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 2 step (newer alternative to move)
step3 = NXTMotor('C','Power',(-1*speed),'TachoLimit', (dist*3) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 3 step (newer alternative to move)
down.SendToNXT(adder);
step_correction = NXTMotor('C','Power',(-1*speed),'TachoLimit',750,'ActionAtTachoLimit','Brake','SmoothStart',true);
step_correction_reverse= NXTMotor('C','Power',speed,'TachoLimit',750,'ActionAtTachoLimit','Brake','SmoothStart',true);

disp('Finished Setting Up Motor Commands')
toc 

disp('Waiting to Start')
toc 
disp('--------------------------------------------------------------')
%While GO.txt doesn't exist keep looping through while loop
Go = exist (path2go);
while Go == 0 && Failure_Flag == 0
	Go = exist (path2go);
	pause (0.2);
end
%% Section of Code To Specify The Operation of the Transfer Section By
% Calling a Set of Routines Dependant on the Buffer State 
disp('started running')
tic;
Time_started_Program = toc; 
if num_b == 0;
	transfer_0
elseif num_b == 1;
	transfer_1
elseif num_b == 2;
	transfer_2
elseif num_b == 3;
	for tone_loop = 1:3
		for tone = 200:400
			NXT_PlayTone(tone, 2, adder)
		end
	end
	transfer_3
end

Time_Finished_Program = toc; 
messages_data_read_amount =0;
messages_data_write_amount =0;
%% Shutdown Section 
%Setup a filepath to save thre results for the experiment scripts.')
filename_experidata=['transfer_',num2str(Transfer_id),'_results.mat'];
filepath_experidata=[path2experimentresults filename_experidata];
save(filepath_experidata,'state');
% now we log the amount of sensor and state data transferrred using the
% data busses. 
disp(['The Total Sensor data Read was ',num2str(sensor_data_read_amount),' bytes'])
disp(['The Total Sensor data Written was ',num2str(sensor_data_write_amount),' bytes'])
disp(['The Total Message data Read was ',num2str(messages_data_read_amount),' bytes'])
disp(['The Total Message data Written was ',num2str(messages_data_write_amount),' bytes'])
disp(['In ',num2str((Time_Finished_Program-Time_started_Program)),' seconds'])
% save the fault matrix to a log file for later review and graphing if
% required. 
path2faultmatrix = [path2failuredata,['Transfer_',num2str(Transfer_id),'_Failure_Matrix.mat']];
save(path2faultmatrix,'fault_matrix')
% if this unit was the one that failed then we delete the error lo and
% replace it with a statement of what went wrong. 
if Failure_Flag == 1
    delete(path2errorlog)
    ffeedid=fopen(path2errorlog,'w');
    fprintf(ffeedid,'The Error Occured on Transfer Unit ');
    fprintf(ffeedid,num2str(Transfer_id));
    fprintf(ffeedid,'\n');
    fprintf(ffeedid,'The Error Was: ');
    fprintf(ffeedid,error_type);
    fclose(ffeedid);
end
% shutdown routine to stop all motors, turn off all sensors and shutdown
% the line/conenction to NXT.
COM_SetDefaultNXT(adder);
StopMotor('all', false);
disp('stopped motors')
CloseSensor(SENSOR_1)
CloseSensor(SENSOR_2)
CloseSensor(SENSOR_3)
CloseSensor(SENSOR_4)
disp('Closed All Sensors')
COM_CloseNXT('all') %Close connection to NXT
quit % exit this instance of matlab 