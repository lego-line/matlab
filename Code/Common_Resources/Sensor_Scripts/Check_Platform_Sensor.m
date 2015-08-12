%Check_Platform_Sensor.m script to check the staus of an arrival from the upstream transfer line, 
% called by the transfer buffering scripts to check if a pallet has been placed onto the mainline 
% it checks the status of the platform touch sensor and logs it such that
% it can be shared with other units. 
if first_run == 1; %only run this on first run
    % store the data from the check into a log file and onto the data bus
    % such that other units can access it. This is different to the
    % parallel switch which is redundant under a newtowkred sensors
    % approach and is simply due to the lack of splitters availble. 
    disp('Running First Time Setup Script')
    filename_plat_val = ['Platform_Sensor_Data_',num2str(Transfer_id),'.mat'];
    filepath_plat_val = [path2sensordata,filename_plat_val]; 
    filename_local = ['Platform_Sensor_Data_Current_',num2str(Transfer_id),'.txt'];
    filepath_local = [path2databus,filename_local];
    push_format = '%s';
end
disp('Running a Transfer Line Check')
toc
% read the data from the sensor
% take an appropriate action 
% if not pressed then no arrival
% unless it previously was pressed and then can class as an arrival hence
% update the no pallets on mainline 
% if pressed transfer in progress so wait until unpressed to show pallet from
% is descneding 

% read the sensor data 
platform_status=GetSwitch(SENSOR_1, adder); 
% update the matrix of time-value pairs. 
transfer_platform_sensor_data =[transfer_platform_sensor_data;toc,platform_status];
save(filepath_plat_val,'transfer_platform_sensor_data')
% save it onto the data bus as a single value, threshold pair. 
flocal = fopen(filepath_local,'w');
fprintf(flocal,push_format,num2str(platform_status));
fclose(flocal);
sensor_data_write_amount = sensor_data_write_amount +8;
% now make a local decision for the calling script about the state 
if platform_status == 1
    % set the flag to show the previous state of having a pallet present 
    platform_previous_status=1; 
    disp('A Transfer is In Progress')
else
    % else if there is no pallet, but there was a pallet previously (signal
    % falling edge) then a transfer hsa just completed, show that a new
    % pallet has arrived by raising the entering flag
    if platform_previous_status == 1 
        % raise the entering flag to show a pallet is in transfer. 
        disp('A Transfer has Just Been Completed')
        enteringflag = 1; 
    else
        % else tehre was no pallet previously and no pallet now, thus we
        % display a message for the log. 
        disp('The Transfer Line In is Clear')
    end
    % record the status as being zero regardless of if it was an edge or
    % not. 
    platform_previous_status=0;
end
% feed back for the log file
disp('Sensor Check Completed')