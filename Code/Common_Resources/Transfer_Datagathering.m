% Transfer_Datagathering.m - a script common to alltransfer units which will run an
% initialisation of the unit  and then set the unit in data harvesting
% mode. In this mode no belt operations or feeding will occur but all
% sensors will be polled and data provided onto the data bus. This allows
% the unit to remain in palce as part of a networked system such that all
% sensors are always avaialble to all units 


%% Section of Code Detailing the Setup of the Transfer Unit from configuration
% print some headers for the log file 
disp('Running Transfer Unit Setup')
disp(['Transfer_ID = ',num2str(Transfer_id)])
disp('Running Data Gathering Mode')

%% Read In Data From Master Config and Config Files 


%Open config master to get NXT id
fid = fopen(path2master,'rt');
%Scan within file for text with certain formatting
out = textscan(fid, '%s	%s');
%Close file
fclose(fid);


% sets up some failure flag variables 
fault_flag = 0; % a temporary fault has occured 
Failure_Flag =0;% a critical error necessitating shutdown has occured 
tic;
error_type = 'none';


ind = strmatch(strcat('Tran',num2str(Transfer_id)), out{1});
if length(ind) > 1
     ind=ind(1);
end 

%Reads corresponding NXT Mac address into variable Code
disp('Found Code')
Code = [out{2}(ind)]
% Establish connection with the NXT brick
OpenLink;

% read some data such as speed and initial sensor thresholds from the
% master config file 
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

% Find number of pallets buffered in transfer, based on number of buffering
% stations being used. setup reference for switch hwhich will call the
% appropriate case. 
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
tr_end=0; %no pallet at end of transfer buffer
krate=0;
first_run = 1;
t2=0;
t3=0;
% state of the various buffer positions 
a=0;
b=0;
c=0;
pallet = 0; % flag indicating the rpesecne of a palelt at the entry point 
transfer_flag =0; % flag to show when a transfer is in progress
belt_running_flag =0; % flag to show when the belt is moving 
unload_state = 1; % show the state of the unlaod process
unload_retry_flag =0; % shows if we are trying the process for a second time on the same pallet
transfer_platform_sensor_data = []; % sensor data 
% variables for storing the status of the transfer platform. 
platform_status =0; % status of the paltform sensor 
platform_previous_status=0;% previous state of the platform sensor 
pallet_move = 0; % flag to track if a pallet is being moved. 
pallet_present = 0; % flag to keep track of if the pallet is actually at the point to be transferred. 
error_loop_iteration = 0; % loop iteration counter for an error loop which can only be repeated finite times before it creates a alrger error. 

filename_local_tval = ['Tval_Current',num2str(Transfer_id),'.txt']; % palce to write the sensor data to for the
% netowrked sensors approach 
filepath_local_tval = [path2sensordata, filename_local_tval];
state= [0 0]; % set the state to be a vector of 2 as it really deosn't matter as long as it exists so set it to the minimum size. 
prev_state = [0 0];
% New section to track the amount of data read/written by sensor type for
% control system comparisons. 
sensor_data_read_amount =0;
sensor_data_write_amount =0;
messages_data_read_amount =0;
messages_data_write_amount =0;

% Define distance the belt should move according to buffer size based on switch variable 
% this essentially defines the distance between the buffer positions by
% breaking down the length of the belt into a number of sections with a
% fixed move distance between them. 
if num_b == 1 || num_b == 0;
	dist = 5000;
end

if num_b == 2;
	dist = 2500;
end

if num_b == 3;
	dist = 1540;
end


%% Equipment Setup 

%Initialise touch and light sensors
disp('Initialising Sensors')
OpenSwitch(SENSOR_1, adder); 
OpenSwitch(SENSOR_2, adder); % sensor for the arm rotation 
OpenLight(SENSOR_3, 'ACTIVE', adder);
OpenLight(SENSOR_4, 'ACTIVE', adder);

% Purge conveyor
disp('Purging the Conveyor')
conveyor_purge = NXTMotor('C','Power',100,'TachoLimit', (dist*3) ,'ActionAtTachoLimit','Brake','SmoothStart',true);
conveyor_purge.SendToNXT(adder);

%    Zero adder Motors
%Reset transfer unit "lift"
disp('Initialising the Mainline Platform Lift')
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

%Reset transfer unit "arm"
disp('Initialising the Transfer Unit Arm')
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

adderarmreset.Stop('brake', adder);
% timing pause to allow arm to move
while toc < 2 && Failure_Flag == 0
end
adderarmreset.Stop('off', adder);


%% Setup Commands for running the motor 
up = NXTMotor('A','Power', -100,'TachoLimit', 270); %Raise conveyor platform
down = NXTMotor('A','Power', 100,'TachoLimit', 270); %Lower conveyor platform

add = NXTMotor('B','Power', -10, 'TachoLimit',125); %Load block
retract = NXTMotor('B','Power', 25,'TachoLimit', 125); %Retract arm

step = NXTMotor('C','Power',(-1*speed),'TachoLimit', dist ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 1 step (newer alternative to move)
step2 = NXTMotor('C','Power',(-1*speed),'TachoLimit', (dist*2) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 2 step (newer alternative to move)
step3 = NXTMotor('C','Power',(-1*speed),'TachoLimit', (dist*3) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 3 step (newer alternative to move)
down.SendToNXT(adder);
step_correction = NXTMotor('C','Power',(-1*speed),'TachoLimit',750,'ActionAtTachoLimit','Brake','SmoothStart',true);
step_correction_reverse= NXTMotor('C','Power',speed,'TachoLimit',750,'ActionAtTachoLimit','Brake','SmoothStart',true);


%% Operatiuons Section
disp('Waiting to Start')
toc
%While GO.txt doesn't exist keep looping through while loop
Go = exist (path2go);
while Go == 0 && Failure_Flag == 0
	Go = exist (path2go);
	pause (0.2);
end
tic
disp('-------------------------------------------------------------------')
Go = exist (path2go); % check existence of GO file 
disp('Started Operations')
toc 
% get the pallet status and check the mainline is clear by calling scripts
% to check appropriate sensors 
pallet_status
mainline_clear
Check_Platform_Sensor
Network_Write
first_run = 0; %No longer run through "first run" bits of code
% this short opertaing loop simply polls the sensors over and over and
% records the data onto the data bus. This data is alos palced on the
% inter- unit netowkr such that all other units reliant on this data can
% function correctly even when this unit is not feeding. This takes some of
% the load off the processor by reducing the num,ber of heavy proicesses
% required. 
Time_started_Program = toc;
while Go == 2 && Failure_Flag == 0
    disp('Start of Loop')
    toc 
% check the status of the pallets and the status of the mainline 
    pallet_status
    mainline_clear
    Check_Platform_Sensor
    Network_Write;
    Go = exist (path2go);
    disp('End of Loop')
    toc 
    disp('---------------------------------------------------------------')
end
Time_Finished_Program = toc; 

%% Shutdown Section 

% this section records a number of pieces of operating data into a results file from the run
% it is used in experiment mode to assess if the point l;ies on the failure
% surface in questiona nd also to plot the results table. 
filename_experidata=['transfer_',num2str(Transfer_id),'_results.mat'];
filepath_experidata=[path2experimentresults filename_experidata];
save(filepath_experidata,'state');

% this section is for the log files and displays the amount of network
% capacity the unit requires and of what type. 
disp(['The Total Sensor data Read was ',num2str(sensor_data_read_amount),' bytes'])
disp(['The Total Sensor data Written was ',num2str(sensor_data_write_amount),' bytes'])
disp(['The Total Message data Read was ',num2str(messages_data_read_amount),' bytes'])
disp(['The Total Message data Written was ',num2str(messages_data_write_amount),' bytes'])
disp(['In ',num2str((Time_Finished_Program-Time_started_Program)),' seconds'])


% If this unit hit a critical error and caused a system shutdown this
% section takes the error file created in the overall initialise process
% and replaces it with one which identifies this feed as the source of the
% error as well as detailing the type of error that occured such that the finish routine
% can report it to the user. 
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