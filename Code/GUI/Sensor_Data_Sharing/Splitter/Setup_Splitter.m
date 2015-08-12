% setup_splitter.m - script file to run the common tasks of the splitter
% unit such as setting up the unit and then choosing the appropriate mode
% of operations calling the split_colour/code/quality scripts

%% Initialisation Section 
disp('Running Splitter Setup')
Failure_Flag = 0; 
error_type = 'none';
fid = fopen(path2master,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s	%s');
%Close file
fclose(fid);
tic;
ind=strmatch('No_of_Feedlines',out{1},'exact');
Number_of_Feedlines = out{2}(ind);
Number_of_Feedlines=str2num(Number_of_Feedlines{1});
fault_flag = 0; 
fault_matrix = []; 



% craete a search strinf to find th requied splitter code and open the NXT
% link 
searchval=strcat('Split',num2str(Splitter_id));
%Search for Splitter and find NXT identifier, put values into array ind
ind = strmatch(searchval,out{1},'exact');
if length(ind) > 1
     ind=ind(1);
end 
%Place values from array ind into Matrix LineA
Code = [out{2}(ind)]
% open the link 
COM_CloseNXT('all')
disp('Establishing A Conenction')
splitter = COM_OpenNXTEx('USB', Code{1});

% section to read in timing values from the master_config file
    fid = fopen(path2master,'rt');
    out2 = textscan(fid,'%s %s %s');
    fclose(fid);  
    t1_ind= strmatch('T1',out2{1});
    t2_ind= strmatch('T2',out2{1});
    t3_ind= strmatch('T3',out2{1});
    t4_ind= strmatch('T4',out2{1});
    t5_ind= strmatch('T5',out2{1});
    t6_ind= strmatch('T6',out2{1});
    spike_threshold_ind= strmatch('SPIKE',out2{1});
    speed_ind= strmatch('SPEED_S',out2{1});
    
    t1 = out2{3}(t1_ind);
    t2 = out2{3}(t2_ind);
    t3 = out2{3}(t3_ind);
    t4 = out2{3}(t4_ind);
    t5 = out2{3}(t5_ind);
    t6 = out2{3}(t6_ind);
    spike_threshold = out2{3}(spike_threshold_ind);
    speed = out2{3}(speed_ind);
    
    t1 = str2num(t1{1});
    t2 = str2num(t2{1});
    t3 = str2num(t3{1});
    t4 = str2num(t4{1});
    t5 = str2num(t5{1});
    t6 = str2num(t6{1});
    spike_threshold = str2num(spike_threshold{1});
    speed = str2num(speed{1});
    
% create variables used in the Read_Crate_code routine 

clear smooth_code_results;
clear code_results;
clear d_code_result;
clear palletlist;
Splitter_Matrix = []; % results array for the pallet mainline data 
code_results =[];    % results for the current pallet only 
d_code_results=[];   % array into which a differntiate smoothed set of data can be palced for each pallet
smooth_code_results=[]; % array into which a smoothed set of results for each pallet can be placed
d_code_movav=[]; % array into which to put tiem averaged splitter data to get a baseline for comparison 
palletlist =[]; % array to give the feed logs from the splitter containing pallet and code data 
code_results_length =0; % variable to store the size of the code matrix to show how many data points need analysing 
pallet_number=1; % variable to keep track of the number of pallets passed 
a=1;      % variable to store the value of the bit - assumed to be a one unless a zero is detected
b=1;
c=1;
t=-3.2; % Set to -ve so first toc - t2 is greater than 3.2
pallet=0; % variable to flag the presence of a pallet between the light gate sensors atthe current time
first_run = 1;
current = [2 2 2]; % set current to an impossible value so that it can't be mistaken during setup. 
data_usable =0; % differntial value between the light gates at the current time 
data_1=0; % current data reading of the pasive light gate sensor 
data_2=0; % current data reading of the active light gate sensor 


data_ind=0; % value of the current colour sensor reading
data_r=0; % value of the colour sensors red value
data_g=0; % value of the colour sensors green value
data_b=0; % value of the colour sensors blue value
colour_table=[]; % table to store the number of the pallet and the colour as read by the colour sensor 
colour_sensor_pallet_number=0; % integer to keep track of the clour of the nth pallet the colour sensorhas read. 
previous_colour=[]; % colour of the previous colour sensor reading 

time_in =0;% variable to store the time of entry of the last pallet
time_out=0;% variable to store the time of exit of the last pallet

val_active =0; % variable to store threhold setting reading from the active light gate
val_passive=0; % variable to store threhold setting reading from the passive side of the light gate
mainline_clear=0; % difference between the light gate readings to remove effects of ambient light changes
mainline_clear_threshold=0; % threshold value for whih the mainline can be assumed to be clear 

Splitter_Colour_Matrix = [];
line_pointer = 1; % variable to store the table row index of the next output pallet to be checked against
output_table =[]; % variable to store the time that all seperateable pallets leave the light gate
seperator_state =0; % variable to keep track of the oepration that the pusher unit must perform next. 
registered =1; % flag to show if the current pallet has been registered in the output log or not 
colour_flag =1; % flag to show that the pallet passing through is the correct colour when it arrives at the 
Seperated_Colour =0; % variable to store the colour pallet which is to be seperated- only valid in colour seperation mode
Splitter_Colour_History = []; 
detected_pallet =0; 
time_in_c=0;
colour_state =0; % state of the colour registering process


Line_Colour_Average_r = 0;
Line_Colour_Average_g = 0;
Line_Colour_Average_b = 0;

% new section 18/10/12 - allows the splitter to read in from the upstream
% mainline - if any and to determine when pallets are about to arrive such
% that the conveyor only needs run whislt a pallet is present. 
fid= fopen(path2layout);
out = textscan(fid,'%s %s %s');
fclose(fid);
ind = strmatch(['Splitter',num2str(Splitter_id)],out{1});
upstream = ind - 1;
downstream = ind +1;
upstream_type = out{1}(upstream);
if downstream < length(out{1})
    downstream_type = out{1}(downstream);
else
    downstream_type = 'none';
end
if strmatch('Main',upstream_type) == 1
    for index = Number_of_Feedlines:-1:1
        if strcmp(['Main',num2str(index)],upstream_type)
            upstream_value = index;
        end 
    end 
    upstream_sensor =1;
    belt_running   =0;
    time_to_start_running  =[];
    time_to_finish_running =[];
    entering_previous_pallet = 0;
    % define the palce to look for the sensor file
    filename_sensor=['Exitval_Current',num2str(upstream_value),'.txt'];
    filepath_sensor=[path2sensordata,filename_sensor];
else
    upstream_sensor =0;
end 

%% Section to perform the physical setup of the splitter unit

% purge the conveyor of pallets 
disp('Purging the Conveyor Belt')
Conveyor_purge = NXTMotor('A','Power',-100,'TachoLimit',7000 ,'ActionAtTachoLimit','Brake','SmoothStart',true); 
Conveyor_purge.SendToNXT(splitter);


% setup the light sensors and other sensors 
disp('Initialising Sensors')
OpenLight(SENSOR_4, 'ACTIVE', splitter);
OpenLight(SENSOR_3, 'INACTIVE', splitter);
OpenColor(SENSOR_2,splitter);
OpenSwitch(SENSOR_1,splitter);


% section to zero the splitter 
disp('Resetting Splitter Pusher')
splitterarmreset = NXTMotor('B','Power',10); 
splitterarmreset.SendToNXT(splitter);

%Loop to check that the splitter is zeroed correctly before start command
%issued otherwise failure 
time_start_motor = toc; 
while GetSwitch(SENSOR_1,splitter) == 0
    Go = exist (path2go);
    if Go ==2
        if exist(path2go) == 2
            cd (path2control); 
            movefile(path2go,path2stop);
        end
        disp('ERROR:The Start Command has been executed before the motors are zeroed (Arm Sensor) quitting matlab')
        error_type = 'The Start Command has been executed before the motors are zeroed (Arm Sensor)'; 
        delete(path2errorlog)
        ffeedid=fopen(path2errorlog,'w');
        fprintf(ffeedid,'The Error Occured on Splitter Unit');
        fprintf(ffeedid,Splitter_id);
        fprintf(ffeedid,'\n');
        fprintf(ffeedid,'The Error Was: ');
        fprintf(ffeedid,error_type);
        fclose(ffeedid);
        COM_SetDefaultNXT(splitter);
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
   if (toc - time_start_motor) > 2.0
        % if the motor has been turnign for too long then is will cause
        % damage as the switch has not been pressed 
        
        disp('ERROR:The Pusher Sensor Has Failed to Initialise Properly and May Cause Damage')
        error_type = 'The Pusher Sensor has failed to initialise properly'; 
        Failure_Flag = 1;
        COM_SetDefaultNXT(splitter);
        StopMotor('all', false);
        delete(path2errorlog)
        ffeedid=fopen(path2errorlog,'w');
        fprintf(ffeedid,'The Error Occured on Splitter Unit');
        fprintf(ffeedid,num2str(Splitter_id));
        fprintf(ffeedid,'\n');
        fprintf(ffeedid,'The Error Was: ');
        fprintf(ffeedid,error_type);
        fclose(ffeedid);
        while exist(path2stop) == 2
            pause(0.2)
        end
        pause(5.0)
        cd (path2control); 
        movefile(path2go,path2stop);
   end 
   pause(0.2); % pause to save processor power 
end

splitterarmreset.Stop('brake', splitter);
splitterarmreset.Stop('off', splitter);

% create the commands to send to the pusher arm 
push_out     = NXTMotor('B','Power',-50,'TachoLimit', 140 ,'ActionAtTachoLimit','Brake','SmoothStart',true);
push_retract = NXTMotor('B','Power', 50);

belt_go = NXTMotor('A','Power',(-1*(speed+5)),'TachoLimit',0);%Move conveyor, N.B designed to run slightly faster than normal conveyor to separate pallets which are butted up against each other
belt_stop = NXTMotor('A','Power',0); % conveyor stop command 

%% Operations Section to Select Mode- Wiaitng occurs within mode file. 

% read the splitter unit mode from the config file 

fid = fopen(path2config,'rt');
out3 = textscan(fid,'%s	%s	%s	%s');
fclose(fid);


searchval2 =strcat('Splitter',num2str(Splitter_id));
index=strmatch(searchval2,out3{1});
mode=out3{3}(index);
disp('Waiting To Start')
if strcmp(mode{1},'Colour') == 1
    splitter_unit_colour_seperation
end

if strcmp(mode{1},'Code') == 1
    splitter_unit_code_seperation
end
if strcmp(mode{1},'Quality') == 1
    splitter_unit_quality_seperation
end
%% Shutdown Section

% shutdown routine to stop all motors, turn off all sensors and shutdown
% the line/conenction to NXT.
COM_SetDefaultNXT(splitter);
StopMotor('all', false);
disp('stopped motors')
CloseSensor(SENSOR_1)
CloseSensor(SENSOR_2)
CloseSensor(SENSOR_3)
CloseSensor(SENSOR_4)
disp('Closed All Sensors')
COM_CloseNXT('all') %Close connection to NXT

save(eval(['path2splittermatrix',num2str(Splitter_id)]),'Splitter_Matrix','Splitter_Colour_Matrix')
path2faultmatrix = [path2failuredata,'Splitter_',num2str(Splitter_id),'_Failure_Matrix.mat'];
save(path2faultmatrix,'fault_matrix')
%% Section To Create the Splitter Logfiles 
% section to save the relevant experimental data
pallet_number = pallet_number -1;
if Splitter_id ==1
    save(path2experimentalsplitter,'pallet_number')
end
% section to create the output file that can be read by the user
% setup data
time = clock;
title=['Splitter Unit Pallet Log for Splitter',num2str(Splitter_id),'\r\n'];
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1)),'\r\n','\r\n'];
Headings ={'Pallet Number','Time','Code','Colour'};
Heading_Format =('%15s %6s %12s %-10s\r\n');
Line_Format=('%15s %6.2f %3s %3s %3s %10s\r\n');
% open file 
filename_output=['Splitter_times_',num2str(Splitter_id),'.txt'];
filepath_output=[path2feedlog filename_output]; 
file_1 = fopen(filepath_output,'w');
% print headings
fprintf(file_1,title);
fprintf(file_1,date);
fprintf(file_1,Heading_Format,Headings{1},Headings{2},Headings{3},Headings{4});
Size_Table1=size(palletlist);
% loop to print out the data 
for i = 1:Size_Table1
switch palletlist(i,6)
    case 1
        colour_val = 'Dark Gray';
    case 2
        colour_val = 'Light Gray';
    case 3
        colour_val = 'Blue';
    case 4
        colour_val = 'Yellow';
    case 5
        colour_val ='Red';
end
fprintf(file_1,Line_Format,num2str(palletlist(i,1)),palletlist(i,2),num2str(palletlist(i,3)),num2str(palletlist(i,4)),num2str(palletlist(i,5)),colour_val);
end
fclose(file_1);    
quit % close this instance of amtlab 