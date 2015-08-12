% Feed_Setup.m - a script common to all feed units which will run an
% initialisation of the unit and then call the relevant oeprating case
% script. 
%% Initialisation section
disp('Running Feed Setup') 
disp(['Feed_ID = ',num2str(feed_id)])
Failure_Flag =0;
fault_flag = 0;
fault_matrix = []; 
tic;
% flag to keep track of whether the line failed in this run on one of the feed units
% Get NXT id from file
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
%Place values from array ind into Matrix LineA
Code = [out{2}(ind)]
disp('Establishing A Connection')
load = COM_OpenNXTEx('USB', Code{1}); %connect to NXT
% section of code for extracting the belt running speed from the
% master_config file 
fid = fopen(path2master,'rt');
    out2 = textscan(fid,'%s %s %s');
fclose(fid);
speed_ind= strmatch('SPEED_F',out2{1});
speed = out2{3}(speed_ind);
disp(['The Speed is' speed])
speed = str2num(speed{1});


% Read modules present
%Open config file
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s %s	%s	%s');
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

% if buffer state is zero set to 1 s these two cses operate the saem script
		if Line{2}== '0'
			Line{2} = '1';
        end
   
tic; %Reset clock

disp('Initialising Sensors')
OpenLight(SENSOR_3, 'ACTIVE', load); %Open light sensor
OpenSwitch(SENSOR_1, load); %Open touch sensors
OpenSwitch(SENSOR_2, load);

%   Zero loader Motors:
loadA = NXTMotor('A','Power',30); %Pusher motor
loadB = NXTMotor('B','Power',15); %Lifter Motor

disp('Initialising Motor B (Lifter Motor)')
loadB.SendToNXT(load); %Tell lifter to move upwards
time_start_lift = toc;
while GetSwitch(SENSOR_2, load) == false && Failure_Flag == 0%keep spinning motor while touch sensor isn't pressed
    Go = exist (path2go);
    if Go ==2
        
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
            cd (path2control); 
            movefile(path2go,path2stop);
        end 
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
        COM_SetDefaultNXT(load);
        StopMotor('all', false);
        while exist(path2stop) == 2
            pause(0.2)
        end
        pause(5.0)
        if exist(path2go) == 2
            cd (path2control); 
            movefile(path2go,path2stop);
        end
    end
    pause(0.2)
end

loadB.Stop('brake',load); %Turn off motor and brake
pause(0.5); %Allow transients to die away
loadB.Stop('off',load); %Turn off motor

%Purge Conveyor, move it backwards to make sure there are no pallets about to cause jam
if Failure_Flag == 0
    disp('Purging the Conveyor Belt')
    Purge = NXTMotor('C','Power',100,'TachoLimit', 9000,'ActionAtTachoLimit','Brake','SmoothStart',true);
    Purge.SendToNXT(load);
    Purge.WaitFor(0,load);
end

% initiailsie the pusher 
if Failure_Flag == 0
    disp('Initialising Motor A (Pusher Motor)')
    loadA.SendToNXT(load); %Start moving pusher inwards
    time_start_push = toc;
    while GetSwitch(SENSOR_1, load) == false && Failure_Flag == 0 %keep spinning motor while touch sensor isn't pressed
       Go = exist (path2go);
        if Go ==2       
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
                cd (path2control); 
                movefile(path2go,path2stop);
            end
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
            COM_SetDefaultNXT(load);
            StopMotor('all', false);
            while exist(path2stop) == 2
                pause(0.2)
            end
            pause(5.0)
            if exist(path2go) == 2
                cd (path2control); 
                movefile(path2go,path2stop);
            end
       end 
       pause(0.2)
    end
end

loadA.Stop('brake',load); %Brake motor
pause(0.5); %Allow transients to die away
reset = NXTMotor('A','Power',8,'SpeedRegulation',false); %speed regulation off so that when pusher stops moving due to reaching end of travel, motor power does not ramp up!
pos=0;
pos2=1;
reset.SendToNXT(load); %Tell motor to start to gently retract
motoron = reset.ReadFromNXT(load); %Read motor state

while (pos2 - pos) ~= 0 && Failure_Flag == 0%read position of motor, (pos) then a small time later read position again 	(pos2) if motor is spinning pos2-pos will not equal 0. If motor has stopped, while loop will 	end since pos2-pos=0
	motoron = reset.ReadFromNXT(load);
	pos=motoron.Position;
	pause(0.2) %small pause before next reading since matlab can read position so fast that a 	slow spinning motor will appear stopped!
	motoron = reset.ReadFromNXT(load);
	pos2=motoron.Position;
end

reset.Stop('off',load);

% setup some running variables 
feed_times = [];
error_type = 'none';
pallet_number = 1;
armcheck=0;
first_run = 1; %Tells functions that this is the first run
filename_local_val = ['Fval_Current',num2str(feed_id),'.txt'];
filepath_local_val = [path2databus,filename_local_val];

% New section to track the amount of data read/written 2/11/12
sensor_data_read_amount =0;
sensor_data_write_amount =0;
messages_data_read_amount =0;
messages_data_write_amount =0;

% finish setting up the state and other running variables 
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


pallet_clear = 0;
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

first_run = 1; %Tells functions that this is the first run
delay=0;
trap =0; % trap flag to tell if a unit is transit from one place to another 


% Set up routines for feed unit. 
belt_error_run = NXTMotor('C','Power',(-1*speed));
belt_error_stop = NXTMotor('C','Power',0);

pushin = NXTMotor('A','Power', 100,'TachoLimit', 650,'ActionAtTachoLimit','Brake'); %Move pusher in
pushout = NXTMotor('A','Power', -100,'TachoLimit', 650,'ActionAtTachoLimit','Brake'); %Move pusher out

raise = NXTMotor('B','Power',100, 'TachoLimit', 200,'ActionAtTachoLimit','Brake'); %Lift pallets up
lower = NXTMotor('B','Power',-50,'TachoLimit', 200,'ActionAtTachoLimit','Brake'); %Drop pallets down

move = NXTMotor('C','Power',(-1*speed),'TachoLimit', 2350 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward to light sensor at end of feed
move_full = NXTMotor('C','Power',(-1*speed),'TachoLimit', 3500 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %Move pallet forward past light sensor and onto transfer unit (used when zero buffer)


move_correct = NXTMotor('C','Power',(-1*speed),'SmoothStart',true);
stop_correct = NXTMotor('C','Power',0);
time_started_error_correct =0; 
disp('Waiting To Start')

%% Operations Section
Go = exist (path2go); %delay program until GO exists
while Go == 0 && Failure_Flag == 0 
	Go = exist (path2go);
	pause (0.2); %slow down check so the loop isn't just wasting processor
end
tic;
% 05/10/11: Withdraw push-arm on feed unit.
if Failure_Flag == 0
    pushout.SendToNXT(load);
    pushout.WaitFor(0,load);
end
get_time %Run get_time function for the first time
Time_started_Program = toc; 


                if Line{2}== '1'
                    feed_1
                end
                if Line{2}== '2'
                    feed_2
                end

                if Line{2}== '3'
                    feed_3
                end

                if Line{2}== '4'
                    feed_4
                end

                if Line{2}== '5'
                    feed_5
                end
                
Time_Finished_Program = toc; 

 %% Shutdown Section
path2faultmatrix = [path2failuredata,['Feed_',num2str(feed_id),'_Failure_Matrix.mat']];
save(path2faultmatrix,'fault_matrix')
buffer_number = str2num(Line{2});
filename_experidata=['feed_',num2str(feed_id),'_results.mat'];
filepath_experidata=[path2experimentresults filename_experidata];
save(filepath_experidata,'a','error_type','buffer_number','t')
 
messages_data_read_amount =0;
messages_data_write_amount =0;

disp(['The Total Sensor data Read was ',num2str(sensor_data_read_amount),' bytes'])
disp(['The Total Sensor data Written was ',num2str(sensor_data_write_amount),' bytes'])
disp(['The Total Message data Read was ',num2str(messages_data_read_amount),' bytes'])
disp(['The Total Message data Written was ',num2str(messages_data_write_amount),' bytes'])
disp(['In ',num2str((Time_Finished_Program-Time_started_Program)),' seconds'])

if Failure_Flag == 1
    delete(path2errorlog)
    ffeedid=fopen(path2errorlog,'w');
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
quit %close this instance of matlab 