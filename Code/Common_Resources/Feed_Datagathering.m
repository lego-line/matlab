% Feed_Datagathering.m - a script common to all feed units which will run an
% initialisation of the unit  and then set the unit in data harvesting
% mode. In this mode no belt operations or feeding will occur but all
% sensors will be polled and data provided onto the data bus. This allows
% the unit to remain in palce as part of a networked system such that all
% sensors are always avaialble to all units 


%% Initialisation section
% provide some header data for the operating logs 
disp('Running Feed Setup') 
disp(['Feed_ID = ',num2str(feed_id)])
disp('Mode is Data Gathering Only');
% set up some failure flags whichg are requried to assess the health of the
% unit 
fault_flag = 0; % a temporary fault has occured 
Failure_Flag =0;% a critical error necessitating shutdown has occured 
tic;

%%  Get NXT id and other salient data such as initial snesor thresholds and belt speeds from master config file
disp('Beginnign toe Read Key Data From File')
toc 

fid = fopen(path2master,'rt');
% Scan within file for text with certain formatting
out = textscan(fid,'%s	%s');
% Close file
fclose(fid);
% Search for NXT identifier, put values into array ind
ind= strmatch(['Feed',num2str(feed_id)],out{1});
if length(ind) > 1
     ind=ind(1);
end 
%Place values from array ind into a variable called code and establish a
%connection 
disp('Found Code:')
Code = [out{2}(ind)]
Open_Link; 
%connect to NXT
 % this NXT will be designated as load, as such all instructions shoudl be sent to laod 
% section of code for extracting the belt running speed from the

% open master_config file again to get the sensor and belt speed data 
fid = fopen(path2master,'rt');
    out2 = textscan(fid,'%s %s %s');
fclose(fid);
speed_ind= strmatch('SPEED_F',out2{1});
speed = out2{3}(speed_ind);
disp(['The Speed is' speed])
speed = str2num(speed{1});

%% Read The Operating Parameters from the config file 
%Open config file
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s %s %s	%s');
out2 = textscan(fid,'%s	%s');
%Close file
fclose(fid);

disp('Retrieving Feed Schedule Data')
%Search for 'Line1' and put values into array ind

ind=strmatch(['Line',num2str(feed_id)],out{1});
if length(ind) > 1
     ind=ind(1);
end 
Line([1,2,3]) = [out{3}(ind),out{4}(ind),out{5}(ind)];
Buffer_num = out{4}(ind);
disp(['The Buffer Number is ' Buffer_num])
Buffer_num = str2num(Buffer_num{1});


disp('Completed Reading Data From File')
toc 

%% Equipment Setup         
        
% setup all of the required sensors to ensure correct operations 
disp('Initialising Sensors')
OpenLight(SENSOR_3, 'ACTIVE', load); %Open light sensor
OpenSwitch(SENSOR_1, load); %Open touch sensors
OpenSwitch(SENSOR_2, load);

%   Zero loader Motors:
loadA = NXTMotor('A','Power',30); %Pusher motor
loadB = NXTMotor('B','Power',15); %Lifter Motor
disp('Starting Physical Initialisations') 

% Initialise the Lifter Motor
disp('Beginning to Initialise Motor B (Lifter Motor)')
toc 
loadB.SendToNXT(load); %Tell lifter to move upwards
time_start_lift = toc;
while GetSwitch(SENSOR_2, load) == false && Failure_Flag == 0%keep spinning motor while touch sensor isn't pressed
    Go = exist (path2go);
    if Go ==2
             % if the start command has been issued before the
            % initialisation can compelte then the unit will not perform
            % correctly. In which case fial the run and issue a global stop
            % command. The comments for this process would be the same as
            % those found in the finishing section of this script.
        disp('ERROR:The Start Command has been executed before the motors are zeroed (Lift Sensor) quitting matlab')
        error_type = 'The Start Command has been executed before the motors are zeroed (Lift Sensor)';
        COM_SetDefaultNXT(load);
        StopMotor('all', false);
        disp('stopped motors')
        CloseSensor(SENSOR_1)
        CloseSensor(SENSOR_2)
        CloseSensor(SENSOR_3)
        CloseSensor(SENSOR_4)
        disp('Closed All Sensors')
        COM_CloseNXT('all') %Close connection to NXT 
        delete(path2errorlog)
        ffeedid=fopen(path2errorlog,'w');
        fprintf(ffeedid,'The Error Occured on Feed Unit ');
        fprintf(ffeedid,feed_id);
        fprintf(ffeedid,'\n');
        fprintf(ffeedid,'The Error Was: ');
        fprintf(ffeedid,error_type);
        fclose(ffeedid);
        pause(0.1)
        if exist(path2go) == 2
            Kill_Line;
        end 
        quit
    end
    % section to check if the motor has turned too far and is causing
    % damage to the structure 
    if (toc - time_start_lift) > 1.5
        % if the motor ahs been turnign for too long then is will cause
        % damage as the switch has not been pressed 
            % if the motor has been turning for too long then is will cause
            % damage as the switch has not been pressed, in which case stop
            % everything and issue a fail order
        disp('ERROR:The Lift Sensor Has Failed to Initialise Properly and May Cause Damage')
        error_type = 'The Lift Sensor has failed to initialise properly'; 
        Failure_Flag = 1;
        COM_SetDefaultNXT(load);
        StopMotor('all', false);
        % wait until the start command has been isssued and then issue
        % a global shutdown command 
        while exist(path2stop) == 2
            pause(0.2)
        end
        pause(5.0)
        if exist(path2go) == 2
            Kill_Line;
        end
    end
    pause(0.2)
end

loadB.Stop('brake',load); %Turn off motor and brake
pause(0.5); %Allow transients to die away
loadB.Stop('off',load); %Turn off motor to save power 

disp('Completed Lifter Motor Initialisation')
toc 


%Purge Conveyor, move it backwards to make sure there are no pallets about to cause jam
if Failure_Flag == 0
    disp('Purging the Conveyor Belt')
    Purge = NXTMotor('C','Power',100,'TachoLimit', 9000,'ActionAtTachoLimit','Brake','SmoothStart',true);
    Purge.SendToNXT(load);
    Purge.WaitFor(0,load);
end

% initiailsie the pusher arm
if Failure_Flag == 0
    disp('Beginning to Initialise Motor A (Pusher Motor)')
    loadA.SendToNXT(load); %Start moving pusher inwards
    time_start_push = toc;
    while GetSwitch(SENSOR_1, load) == false && Failure_Flag == 0 %keep spinning motor while touch sensor isn't pressed
       Go = exist (path2go);
        if Go ==2    
            % if the start command has been issued before the
            % initialisation can compelte then the unit will not perform
            % correctly. In which case fial the run and issue a global stop
            % command. The comments for this process would be the same as
            % those found in the finishing section of this script.
            disp('ERROR:The Start Command has been executed before the motors are zeroed (Pusher Sensor) quitting matlab')
            error_type = 'The Start Command has been executed before the motors are zeroed (Pusher Sensor)'; 
            delete(path2errorlog)
            ffeedid=fopen(path2errorlog,'w');
            fprintf(ffeedid,'The Error Occured on Feed Unit ');
            fprintf(ffeedid,feed_id);
            fprintf(ffeedid,'\n');
            fprintf(ffeedid,'The Error Was: ');
            fprintf(ffeedid,error_type);
            fclose(ffeedid);
            COM_SetDefaultNXT(load);
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
        % section to check if the motor has turned too far and is causing
       % damage to the structure  
       if (toc - time_start_push) > 3.0
            % if the motor has been turning for too long then is will cause
            % damage as the switch has not been pressed, in which case stop
            % everything and issue a fail order
            disp('ERROR:The Pusher Sensor Has Failed to Initialise Properly and May Cause Damage')
            error_type = 'The Pusher Sensor has failed to initialise properly'; 
            Failure_Flag = 1;
            COM_SetDefaultNXT(load);
            StopMotor('all', false);
            % wait until the start command has been isssued and then issue
            % a global shutdown command 
            while exist(path2stop) == 2
                pause(0.2)
            end
            pause(5.0)
            if exist(path2go) == 2
                Kill_Line;
            end
       end 
       pause(0.2)
    end
end
loadA.Stop('brake',load); %Brake motor
pause(0.5); %Allow transients to die away

% this section simply gets the transfer pusher set up as approproate and
% was written by Konrad Newton. the reason for the differences between this
% and other sections have never been determined however it seems to work
% and so it was decided to leave it alone. 
reset = NXTMotor('A','Power',8,'SpeedRegulation',false); %speed regulation off so that when pusher stops moving due to reaching end of travel, motor power does not ramp up!
pos=0;
pos2=1;
reset.SendToNXT(load); %Tell motor to start to gently retract
motoron = reset.ReadFromNXT(load); %Read motor state

% this is a section to esnure that the motors have stopoped, it may be a
% little redundant but we keep it ehre just in case it is actually
% critical, LEGO can sometimes be like that. 
while (pos2 - pos) ~= 0 && Failure_Flag == 0%read position of motor, (pos) then a small time later read position again 	(pos2) if motor is spinning pos2-pos will not equal 0. If motor has stopped, while loop will 	end since pos2-pos=0
	motoron = reset.ReadFromNXT(load);
	pos=motoron.Position;
	pause(0.2) %small pause before next reading since matlab can read position so fast that a 	slow spinning motor will appear stopped!
	motoron = reset.ReadFromNXT(load);
	pos2=motoron.Position;
end
reset.Stop('off',load);
disp('Finished Initialising Motor A')
toc
disp('Completed Physical Initialisations')
%% Create Relevant variables 

disp('Creating relevant Operating Variables')
toc 

% setup some running variables 
feed_times = []; % matrix containing the time each pallet is to be and actuall is fed into the system 
error_type = 'none'; % variable to containg the text to be returned to allow error identification 
pallet_number = 1; % pallet counter such that each pallet entering the system can be identified 
armcheck=0; % variable which allows for a count to be taken on the number of positive responses on the light sensor. A single response is the transfer arm swinign, multiple responses are indicative of a pallet being present. 
first_run = 1; %Tells functions that this is the first run

% setup the name and lcoation of a mat file in which to store the light
% sensors data for later evaluation. 

filename_local_val = ['Fval_Current',num2str(feed_id),'.txt'];
filepath_local_val = [path2sensordata,filename_local_val];

% if buffer state is zero set to 1 s these two cses operate the same script
% for the feeder unit
		if Line{2}== '0'
			Line{2} = '1';
        end


% finish setting up the state and other running variables 
%$ these variables are the names of state positions along the conveyor belt
%with a being the pallet entry point, b being below the light sensor on the
%feed unit, c and d being on the transfer line belt and e being at the
%front of the line at the transfer point. 
a=0;
b=0;
c=0;
d=0;
e=0;

t=0; %time between pallet feeds, set by "get_time" - feedrate

t1=0; %toc-t1 = time since last pallet dispatched
t2=0; %toc-t2 = time since d=0
t3=0; %Debug timer
t4=0; %limit time between crate move forwards

first_run = 1; %Tells functions that this is the first run
delay=0;
trap =0; % trap flag to tell if a unit is transit from one place to another 


pallet_clear = 0; % variable to track if a pallet has just been cleared, operated by the light sensor script and feed scripts
% two feeding variables which show the status of two feeding processes, the
% first is the belt moving a pallet from a to b and the second indicating a
% pallet is to be pushed off the belt onto the transfer section - called in
% feed_pallet script 
feeding = 0; 
feeding2 = 0;
Fault_correct=0; %26/10/12 flag to tell if a pallet is jammed at the start of the feed line and correction is being attempted

status = [a,b,c,d,e]; %Status of line
status2= [a,b,c,d,e]; %Previous status, when status ~= status 2 then something has changed

N=0; %N= Number of pallets in buffer
N_tr=0; %Number of pallets sent to transfer
N_tr_out=0; %Number of pallets counted out of transfer

exception = 0;
ce=0; %Flag parameters to make note of transient states while pallet is moving
de=0;
cde=0;
flag=0; %flag when c=0 d=1 and e=1

% New section to track the amount of data read/written
% using the databus simualtion. These are broken down into the type of data
% and hence the type of bus it would come from and the direction of its
% flow. They are created and zeroes at this point. 
sensor_data_read_amount =0;
sensor_data_write_amount =0;
messages_data_read_amount =0;
messages_data_write_amount =0;

status = [0,0];
disp('Setting Up Variables Completed')
toc 
%% 
% Set up routines for feed unit. 
disp('Setting Up Motor Commands')
toc 
belt_error_run = NXTMotor('C','Power',(-1*speed));
belt_error_stop = NXTMotor('C','Power',0);

pushin = NXTMotor('A','Power', 100,'TachoLimit', 650,'ActionAtTachoLimit','Brake'); %Move pusher in
pushout = NXTMotor('A','Power', -100,'TachoLimit', 650,'ActionAtTachoLimit','Brake'); %Move pusher out

raise = NXTMotor('B','Power',100, 'TachoLimit', 200,'ActionAtTachoLimit','Brake'); %Lift pallets up
lower = NXTMotor('B','Power',-50,'TachoLimit', 200,'ActionAtTachoLimit','Brake'); %Drop pallets down

move = NXTMotor('C','Power',(-1*speed),'TachoLimit', 2350 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward to light sensor at end of feed
move_full = NXTMotor('C','Power',(-1*speed),'TachoLimit', 3500 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward past light sensor and onto transfer unit (used when zero buffer)
disp('Completed Setting Up Motor Commands') 
toc 
disp('Waiting To Start')
%% Operations Section
Go = exist (path2go); %delay program until GO exists
while Go == 0 && Failure_Flag == 0 
	Go = exist (path2go);
	pause (0.2); %slow down check so the loop isn't just wasting processor
end
disp('---------------------------------------------------------------')
disp('Started Operations')
%resets the clock into running mode and allows syncing of clocks in oepration across all units as 
%each unit will initisalise in a different time but will start operations at the same time. 
tic;
get_time %Run get_time function for the first time
transfer_status; 
first_run = 0; %15/11/11 line moved from bottom of code to avoid overwriting sensor data 
Go = exist (path2go);
% this is the oeprating while loop whislt in data harvesting mode. No other
% operations other than recording the sensor data by calling transfer
% status and writing this data to the netowkr for other units is requried
% and so this simple loop is sufficient. This takes some of
% the load off the processor by reducing the num,ber of heavy proicesses
% required. It loops whislt the file called
% Go.txt exists in the shadow folder. 

Time_started_Program = toc;
while Go == 2
    disp('Start of Loop')
    toc 
    transfer_status;  
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
buffer_number = str2num(Line{2});
filename_experidata=['feed_',num2str(feed_id),'_results.mat'];
filepath_experidata=[path2experimentresults filename_experidata];
save(filepath_experidata,'a','error_type','buffer_number','t')
 
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
    ffeedid=fopen(path2errorlog,'wt');
    fprintf(ffeedid,'The Error Occured on Feed Unit ');
    fprintf(ffeedid,num2str(feed_id));
    fprintf(ffeedid,'\n');
    fprintf(ffeedid,'The Error Was: ');
    fprintf(ffeedid,error_type);
    fclose(ffeedid)  ;
end

% shutdown routine to stop all motors, turn off all sensors and shutdown
% the line/conenction to NXT.
COM_SetDefaultNXT(load);
StopMotor('all', false);
disp('stopped motors')
CloseSensor(SENSOR_1)
CloseSensor(SENSOR_2)
CloseSensor(SENSOR_3)
CloseSensor(SENSOR_4)
disp('Closed All Sensors')
COM_CloseNXT('all') %Close connection to NXT
quit %close this instance of matlab to prevent excessive build up of old instances not in use and save processing resources. 