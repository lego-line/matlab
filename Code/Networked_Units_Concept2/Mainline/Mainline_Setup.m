% Mainline_Setup.m - a script which is called by all mainlines to eprform
% the initialisation of the section and then to determine which buffering
% case is present and call the appropriate Main_Buffer_X script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%NETWORKED UNITS  Version 2 VERSION%%%%%%%%%%%%
%% Initialisation Section
disp('Performing Mainline Setup')
%Read config file for NXT id
fid = fopen(path2master,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s');
%Close file
fclose(fid);

Failure_Flag = 0; 
error_type = 'none';
fault_flag = 0; 
fault_matrix = []; 
tic;


%Finds correct label within read data from config file by matching string
%to identify NXT
ind = strmatch(strcat('Main',num2str(Main_id)), out{1});

%Reads corresponding NXT Mac address into variable Code
disp('Found Code:')
Code = [out{2}(ind)]

% Establish connection with the NXT brick
OpenLink;
% Read maximum buffer size from the config file
disp('Reading Config File for Running Setup')
%Open config file
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s	%s	%s %s');
%Close file
fclose(fid);

state = [];
%section to read the speed for the mainline from file 
fid = fopen(path2master,'rt');
out2 = textscan(fid,'%s %s %s');
fclose(fid);
%21/10/12 - new section to determine if htere is a mainline section
%dowstream such that more intelligent behaviour can be employed

ind=strmatch('No_of_Feedlines',out2{1},'exact');
Number_of_Feedlines = out2{2}(ind);
Number_of_Feedlines=str2num(Number_of_Feedlines{1});


speed_ind= strmatch('SPEED_M',out2{1});
speed = out2{3}(speed_ind);
speed = str2num(speed{1});
disp(['The Running Speed is ' num2str(speed)])

%Search for 'LineN' and put values into array ind
ind = strmatch(strcat('Line',num2str(Main_id)), out{1});
if length(ind) > 1
     ind=ind(1);
end 
Buffer_num = out{5}(ind);
disp(['The Buffer State is ' Buffer_num])
Buffer_num = str2num(Buffer_num{1});


% Section of code to purge the mainline
disp('Purging The Conveyor')
conveyor_purgeA = NXTMotor('A','Power',100,'TachoLimit', (10000) ,'ActionAtTachoLimit','Brake','SmoothStart',true);
conveyor_purgeB = NXTMotor('B','Power',-100,'TachoLimit', (10000) ,'ActionAtTachoLimit','Brake','SmoothStart',true);
conveyor_purgeA.SendToNXT(Main);
conveyor_purgeB.SendToNXT(Main);

% section to declare teh step size variables
dist=700;
dist2=1800; 

% initialise two light sensors and one touch sensor 
disp('Initialising Sensors')
OpenLight(SENSOR_1, 'ACTIVE',Main);
%OpenLight(SENSOR_2, 'ACTIVE',Main);
OpenSwitch(SENSOR_3, Main); 
OpenLight(SENSOR_4, 'ACTIVE',Main);

% define the two separate motor sections
conveyor_1_GO = NXTMotor('B','Power',-1*speed);
conveyor_2_GO = NXTMotor('A','Power',speed);
conveyor_1_STOP = NXTMotor('B','Power',0);
conveyor_2_STOP = NXTMotor('A','Power',0);

conveyor_1_handover_stop = NXTMotor('B','Power',(-1*speed),'TachoLimit', 580 ,'ActionAtTachoLimit','Brake','SmoothStart',true);
conveyor_1_step  = NXTMotor('B','Power',(-1*speed),'TachoLimit', dist ,'ActionAtTachoLimit','Brake','SmoothStart',true);%step crate forward 1 step (newer alternative to move)
conveyor_1_step2 = NXTMotor('B','Power',(-1*speed),'TachoLimit', (dist*2) ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 2 step (newer alternative to move) step (newer alternative to move)
conveyor_2_step  = NXTMotor('A','Power',speed,'TachoLimit', dist2 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %step crate forward 1 step
conveyor_2_unload =NXTMotor('A','Power',speed,'TachoLimit', 820 ,'ActionAtTachoLimit','Brake','SmoothStart',true); %small step to push it off the edge

% section to declare variables which give the motor running time
time_on_1=0;  %last start time of the motor for the single belt 
time_off_1 =0;%last stop time of the motor for the single belt 
time_off_2=0; %last stop time of the motor for the single belt 
time_on_2=0;  %last start time of the motor for the single belt 
time_running_1=0; 
time_running_2=0; 



%run the first time sensor setup routine
first_run =1;
%initially no pallets on the mainline, this varibale keeps track of the
%number of pallets on the mainline 
no_pallets_mainline=0;
No_pallets_mainline2=0;
handshake_flag =0; % flag to show that a pallet is currently under the sensor and so will appear in both counts; 
%flags to show the previous status from the sensors
entering_previous_pallet=0;
exiting_previous_pallet=0;
transfer_previous_pallet=0; 
enteringflag=0;
exitingflag=0;
exitingflag2=0;
previous_exiting_package =0;
% New section to track the amount of data read/written 2/11/12
sensor_data_read_amount =0;
sensor_data_write_amount =0;
messages_data_read_amount =0;
messages_data_write_amount =0;

Running_1=0;
Running_2=0;
time_in =[]; 
t2 =0;
blockage = 0; 
pallet = 0; 
time_last_exit = 0; 

disp('Checking the Layout Configuration')
fid= fopen(path2layout);
out = textscan(fid,'%s %s %s');
fclose(fid);
ind = strmatch(['Main',num2str(Main_id)],out{1});
upstream = ind - 1;
downstream = ind +1;
upstream_type =0;
downstream_transfer =0;

%% section to determine the line structure downstream and see if there is a sensor there which may be used. 
if Main_id ~= 1
    if downstream <= length(out{1})
        downstream_type = out{1}(downstream);
    else
        downstream_type = 'none';
    end 

    if strmatch('Main',downstream_type) == 1
        for index = Number_of_Feedlines:-1:1
            if strcmp(['Main',num2str(index)],downstream_type)
                downstream_index = index
            end 
        end 
        disp('There is A Mainline Downstream - Can use intelligent Code for Second Belt')
        downstream_sensor =1;
        filename_exitval2 = ['Mval_Current',num2str(downstream_index),'.txt'];
        filepath_exitval2 = [path2databus,filename_exitval2];
        filename_local_downstream_blockage= ['Tval_Current',num2str(downstream_index),'.txt'];
        filepath_local_downstream_blockage = [path2databus,filename_local_downstream_blockage];
        push_format = '%s';
        Transfer_Down_matrix = [];
        filename_transval = ['Transferval_matrix',num2str(Main_id),'.mat'];
        filepath_transval = [path2sensordata,filename_transval];
        downstream_transfer = 1;
    else
        disp('There is not a downstream mainline unit - resorting to local behaviour') 
        downstream_sensor =0;
    end 
else 
    disp('The First Mainline Unit Will Never have A Downstream Miainline by numbering Convention')
    downstream_sensor = 0;
end 

if upstream > 0
    upstream_type = out{1}(upstream);
else 
    upstream_type = 'none';
    upstream_sensor = 0;
end 

filename_local_Mval = ['Mval_Current',num2str(Main_id),'.txt'];
filepath_local_Mval = [path2databus, filename_local_Mval];
filename_Platformstatus_main_light =['Tval_Current',num2str(Main_id),'.txt'];
filepath_Platformstatus_main_light=[path2databus,filename_Platformstatus_main_light];


% new code to find the shared sensors 12/10/12
Ent_matrix=[];
filename_entval = ['Entval_matrix',num2str(Main_id),'.mat'];
filepath_entval = [path2sensordata,filename_entval];
entering_previous_pallet=0;
transfer_previous_pallet=0; 
armcheck =0; %variable to track the number of sighting of pallet- 1 sighting is the arm retracting 2 sightings indicates a static pallet
blockage = 0;

%if go file does not exist wait at this loop until go file does exist
disp('Waiting to Go')
Go = exist (path2go);
while Go == 0
	Go = exist (path2go);
	pause (0.2);
end

%% Operations Section 
tic;
Time_started_Program = toc;
if Buffer_num == 0
    Main_Buffer_0_alt;
end

if Buffer_num == 1
    Main_Buffer_1;
end

if Buffer_num == 2
    Main_Buffer_2;
end

if Buffer_num == 3
    Main_Buffer_3;
end

%% If the Buffer Number is 100, simply run the mainline continously 
if Buffer_num == 100
    disp('Running the Mainline Continuously')
    % %Assign motor
    firstConveyor = NXTMotor('A');
    secondConveyor = NXTMotor('B');

    % %Motor command values (insert control here!)
    firstConveyor.Power = 1*speed;
    secondConveyor.Power = -1*speed;
    state = [2 2];
    % %Send command to activate
    firstConveyor.SendToNXT(Main);
    secondConveyor.SendToNXT(Main);
    time_on_1= toc; 
    % % run until Go is not equal to two, then proceed to the stop motor part of

    Go = exist (path2go);
    while Go == 2
        Go = exist (path2go);
        fault_matrix = [fault_matrix;toc,0];
        pause (0.2);
    end
    
    firstConveyor.Stop('off', Main)
    secondConveyor.Stop('off', Main)
    time_off_1 = toc; 
    time_running_1 = 2 * (time_off_1 - time_on_1);
    disp('The total motor running time is ',num2str(time_running_1),' seconds')
end

Time_Finished_Program = toc; 

%% Shutdown Section
% shutdown routine to stop all motors, turn off all sensors and shutdown
% the line/conenction to NXT.
path2faultmatrix = [path2failuredata,['Main_',num2str(Main_id),'_Failure_Matrix.mat']];
save(path2faultmatrix,'fault_matrix')

total_remaining = no_pallets_mainline + No_pallets_mainline2 - handshake_flag; 
filename_experidata=['main_',num2str(Main_id),'_results.mat'];
filepath_experidata=[path2experimentresults filename_experidata];
save(filepath_experidata,'total_remaining');

disp(['The Total Sensor data Read was ',num2str(sensor_data_read_amount),' bytes'])
disp(['The Total Sensor data Written was ',num2str(sensor_data_write_amount),' bytes'])
disp(['The Total Message data Read was ',num2str(messages_data_read_amount),' bytes'])
disp(['The Total Message data Written was ',num2str(messages_data_write_amount),' bytes'])
disp(['In ',num2str((Time_Finished_Program-Time_started_Program)),' seconds'])

if Failure_Flag == 1
    delete(path2errorlog)
    ffeedid=fopen(path2errorlog,'w');
    fprintf(ffeedid,'The Error Occured on Mainline_Unit ');
    fprintf(ffeedid,num2str(Main_id));
    fprintf(ffeedid,'\n');
    fprintf(ffeedid,'The Error Was: ');
    fprintf(ffeedid,error_type);
    fclose(ffeedid);
end

COM_SetDefaultNXT(Main);
StopMotor('all', false);
disp('stopped motors')
CloseSensor(SENSOR_1)
CloseSensor(SENSOR_2)
CloseSensor(SENSOR_3)
CloseSensor(SENSOR_4)
disp('Closed All Sensors')
COM_CloseNXT('all') %Close connection to NXT
quit % close this instance of matlab