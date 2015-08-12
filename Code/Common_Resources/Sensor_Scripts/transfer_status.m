% transfer_status.m - a script file called by the feed unit to assess the
% state of the light sensor at the end of the transfer line. It uses this
% data to determine if a pallet has been cleared by teh transfer unit to
% make a judgement about the buffer state. 

%% Setup section
%  Code to: determine the presence/absence of a pallet at the end of the transfer conveyor.

disp('Running Transfer Status Check') 
toc
% Check whether GO.txt exists.  If it is not present, close down.
Go = exist(path2go);

%% Static Light Settings 

% Flash light and determine difference in light intensity between on/off.
OpenLight(SENSOR_3, 'ACTIVE', load); %Run light sensor in active mode
on = GetLight(SENSOR_3, load); %Reading when light sensor is in active mode
OpenLight(SENSOR_3, 'INACTIVE', load); %Run light sensor in passive mode
off=GetLight(SENSOR_3, load); %Reading when light sensor is in passive mode
val=on-off; %Difference in readings to compensate for ambient light levels
% If this is the first run, import relevant parameters from config_master.
if first_run == 1; %only run this on first run
disp('Running First Time Setup Script')
	%Get light sensor parameters from config_master
	fid = fopen(path2master,'rt');
	%Scan within file for text with certain formatting
	out = textscan(fid,'%s %s %s');
	%Close file
	fclose(fid);
	%Search for mainlineclear_Buffer in out
	ind = strmatch('TransferClearHI',out{1});
	%Place values from array ind into mainlineclear_Buffer
	mainlineclear_Buffer = [out{3}(ind)];

	ind = strmatch('TransferClearLOW',out{1});
	TransferClearLOW = [out{3}(ind)];

	ind = strmatch('TransientPause',out{1});
	TransientPause = [out{3}(ind)];

	mainlineclear_Buffer = str2num(mainlineclear_Buffer{1}); %Set mainlineclear_Buffer to value within array mainlineclear_Buffer{}
	%When value is above this, a pallet is sitting at the end of the transfer unit ready to be placed onto the mainline
	mainlineclear_Buffer = str2num(TransferClearLOW{1});
	%When value drops below this the pallet has moved on to the mainline

	TransientPause = str2num(TransientPause{1}); %Explained in master config file

	ind = strmatch('FeedUnloadPause',out{1});
	FeedUnloadPause = [out{3}(ind)];
	FeedUnloadPause = str2num(FeedUnloadPause{1});
	% 25/10/11 Initialise Fval_matrix to record light sensor readings.	
    Fval_matrix=[];
    pallet = 0; 
    
    % flags for showing when a new maximum or minimum value ahs been found
    % and informing the software to perform an update of the threshold for
    % whichever case is required 
	M_Max_Flag_Buffer = 0;
    M_Min_Flag_Buffer = 0;
    % maximum and minimum light sensor levels - used for calculating the
    % threshold value to detect a pallet 
    Max_MVal_Buffer =0;
    Min_MVal_Buffer =0; 
    % variables for storing a time avergaed version of the light sensor
    % history in 
    smooth_data_Buffer =[];  
    % flag for informing the software that the mean threshold exists and so it can use the new method of finding the threshold value  
    Update_Flag_Buffer =0;     
    M_Mean_Thresh_Buffer =0; 
    filename_tval = ['Tval_matrix',num2str(feed_id),'.mat'];
    filename_local_tval = ['Tval_Current',num2str(feed_id),'.txt'];
    filepath_tval = [path2sensordata,filename_tval];
    filepath_local_tval = [path2databus, filename_local_tval]; 
    local_format = '%s %s'; 
end

%% Dynamic Threshold Section

% sve the data for the log files and grahing tool 
Fval_matrix = [Fval_matrix; toc, val,mainlineclear_Buffer];
save(filepath_tval, 'Fval_matrix')

% asave the current value and threshold onto the data bus. 
flocal=fopen(filepath_local_tval,'w');
fprintf(flocal,local_format,num2str(val),num2str(mainlineclear_Buffer));
fclose(flocal); 
sensor_data_write_amount = sensor_data_write_amount + 16;
% assuming there is no pallet present initilally take a lot of results and
% average over them to get a baseline level 
if length(Fval_matrix) == 30
% 22/11/11 creating dynamic threshold for mainline light sensor
Min_MVal_Buffer =  mean(Fval_matrix(:,2));
M_Min_Flag_Buffer = 1;
disp('Initial Lower Bound threshold calculated and Applied to Feed Unit Transfer Point Sensor')
end

% check the local region of the data and decide if eitehr flag needs
% updating 

if length(Fval_matrix) > 30
    smooth_data_Buffer = movingav(Fval_matrix(:,2),10);

    if max(smooth_data_Buffer) > Max_MVal_Buffer && M_Max_Flag_Buffer == 1
        M_Max_Flag_Buffer = 0;
    end

    if min(smooth_data_Buffer) < Min_MVal_Buffer && M_Min_Flag_Buffer == 1
        M_Min_Flag_Buffer = 0; 
    end 

    if M_Max_Flag_Buffer == 0 && Max_MVal_Buffer == 0;
        Mlval = length(Fval_matrix);
        if Fval_matrix(Mlval-3:Mlval,2) > Min_MVal_Buffer*1.75
            Max_MVal_Buffer = max(smooth_data_Buffer) + 30;
            M_Max_Flag_Buffer = 1;
            M_Mean_Thresh_Buffer = mean([Min_MVal_Buffer,Max_MVal_Buffer]);
            mainlineclear_Buffer = M_Mean_Thresh_Buffer;
            disp('Initial upper bound thresholds calculated and applied to Feed Unit Transfer Sensor.')
        end
    end % end of if max flag needs updating section 

     % section for determining the new upper bound of the data    
    if M_Max_Flag_Buffer == 0 && Max_MVal_Buffer  > 0;
        Mlval = length(Fval_matrix);
        if Fval_matrix(Mlval-5:Mlval,2) > Min_MVal_Buffer*1.75
            Max_MVal_Buffer = max(smooth_data_Buffer) + 30;
            M_Max_Flag_Buffer = 1;
            M_Mean_Thresh_Buffer = mean([Min_MVal_Buffer,Max_MVal_Buffer]);
            disp('New upper bound thresholds calculated and applied to Feed Unit Transfer Sensor.')
            Update_Flag_Buffer =1;
        end
    end % end of if max flag needs updating section 

    if  M_Min_Flag_Buffer == 0 && Max_MVal_Buffer > Min_MVal_Buffer 
        Mlval = length(Fval_matrix);
        if Fval_matrix(Mlval-5:Mlval,2) > Min_MVal_Buffer*0.75 
            Min_MVal_Buffer = min(smooth_data_Buffer);
            M_Min_Flag_Buffer = 1;
            M_Mean_Thresh_Buffer = mean([Min_MVal_Buffer,Max_MVal_Buffer]);
            Update_Flag_Buffer =1;
            disp('New lower bound thresholds calculated and applied to Feed Unit Transfer Sensor.')
        end
    end % end of if min flag needs updating section 

    % find the difference between the threshold and the current minimum
    %to set the actual threshold deviation from the minimum and then
    %update the threshold by adding it to the current time averaged
    %minimum 
    if Update_Flag_Buffer == 1  
            mainlineclear_Buffer = M_Mean_Thresh_Buffer;
    end   
end% end of data longer than 30 section 

%% Section Checking If a pallet is present, or has recently been
% transfrerred from the end of the transfer section and changes the last
% value of status to indicate the prescence or absence of a pallet at the
% end of the line 

% Check to see whether there is a pallet at the end of the transfer unit.
if val>mainlineclear_Buffer % 05/10/11: If val higher than threshold, then pallet present at end of transfer
    armcheck = armcheck + 1;  % Armcheck means that light sensor has to flash twice to detect pallet. This stops the sensor accidentally picking up the transfer arm as it swings back.
    if armcheck == 2
        pallet = 1;
        pallet_clear = 0; % pallet clear =0 means can move a to b
        delay = 0;
        armcheck = 0; % reset armcheck flag 
        disp(' A Pallet Has Been Detected at Position e')
        toc
    end
end

if val<=mainlineclear_Buffer; % 05/10/11: If val lower than threshold, then no pallet present at the end ofthe transfer unit.
    pallet = 0;
    armcheck = 0;  % 05/10/11: Resets armcheck flag
    disp('No Pallet Has Been Detected at Position e')
end

%checking if a pallet has been cleared  
if pallet == 0 && delay == 0   % 05/10/11: If currently no pallet present, but delay flag has been reset (i.e. previously was a pallet there).
	delay = 1;
	t2=toc;
    disp('A Pallet has Just Been Cleared from e') 
end

if (toc-t2)>=FeedUnloadPause && pallet == 0; %No crate at end of transfer
    pallet_clear = 1; % hence allow items to be moved by feed_x script into this location 
    delay = 0;
    disp('Position E has Been Cleared and transfer may occur')
end
status(size(status,2)) = pallet; %Set last value in status vector to be equal to 'pallet' variable such that the end of the state vector is accurate. 
% print some comments for the event logs. 
disp('The status at the end of the transfer check is')
disp(status)
toc
disp('Sensor Check Completed')