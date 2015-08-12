%transfer_check.m script to check the staus of an arrival from the uspretam transfer line, 
%called by the mainline buffering scripts to check if a pallet has been placed onto the mainline by the transfer unit 
%by consulting the stsus of the platform.  
disp('Running a Transfer Line Check')
toc
% read the data from the sensor
% take an appropriate action 
% if not pressed then no arrival
% unless it previously was pressed and then can class as an arrival hence
% update the no pallets on mainline 
% if pressed transfer in progress so wait until unpressed to show pallet from
% is descneding 

% read the status of the touch sensor
transfer_input=GetSwitch(SENSOR_3, Main); 
% decide if a pallet has arrived. 
if transfer_input == 1
    % if the switch has been pressed, state that a previous pallet has been
    % observed
    transfer_previous_pallet=1; 
    disp('A Transfer is In Progress')
else
    % else if the switch is unpressed. 
    if transfer_previous_pallet == 1 
        % if this is a falling edge then a transfer has just completed 
        disp('A Transfer has Just Been Completed')
        % set the entering flag high such that the mainline knows a new
        % pallet has arrived. 
        no_pallets_mainline=no_pallets_mainline+1;
        enteringflag = 1; 
    else
        % if there was no pallet previously then the lien was simply empty,
        % and so give a simpel message
        disp('The Transfer Line In is Clear')
    end
    % record the previous status for edge recgnition.
    transfer_previous_pallet=0;
end
disp('Sensor Check Completed')