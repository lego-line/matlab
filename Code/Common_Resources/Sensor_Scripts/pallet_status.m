% pallet_Status.m - a script file to check the arrival status of the sensor
% at the end of the feed unit. It is called by the transfer unit to check
% if there is a pallet arriving on its unit by checking for an edge to
% arrive. 


%% Initialisation Section 
disp('Running Pallet_Status Check')
toc
% Wait fot the go file to exist before starting the program 
Go = exist (path2go);

%get light sensor data 
OpenLight(SENSOR_3, 'ACTIVE', adder);
on = GetLight(SENSOR_3, adder);
OpenLight(SENSOR_3, 'INACTIVE', adder);
off=GetLight(SENSOR_3, adder);
val=on-off;


% first run passed from transfer_setup 
if first_run == 1; %only run this on first run

	%Get light sensor parameters from config_master
	fid = fopen(path2master,'rt');
	%Scan within file for text with certain formatting
	out = textscan(fid,'%s %s %s');
	%Close file
	fclose(fid);
	%Search for TransferClearHi in out
	ind = strmatch('PalletAcceptHI',out{1});
	%Place values from array ind into TransferClearHI
	mainlineclear_feed = [out{3}(ind)];

	ind = strmatch('PalletAcceptLOW',out{1});
	PalletAcceptLOW = [out{3}(ind)];


	mainlineclear_feed = str2num(mainlineclear_feed{1}); %Set TransferClearHI to value within array TransferClearHI{}
	%When value is above this, a pallet is sitting at the end of the transfer unit ready to be placed onto the mainline
	PalletAcceptLOW = str2num(PalletAcceptLOW{1});
	%When value drops below this the pallet has moved on to the mainline

	% 18/10/11 Initialise val_matrix to record light sensor readings.
	val_matrix = [];
    filename_val = ['Fval_matrix',num2str(Transfer_id),'.mat'];
    filepath_val = [path2sensordata,filename_val];
    
    
    % flags for showing when a new maximum or minimum value ahs been found
    % and informing the software to perform an update of the threshold for
    % whichever case is required 
	M_Max_Flag_Feed = 0;
    M_Min_Flag_Feed = 0;
    % maximum and minimum light sensor levels - used for calculating the
    % threshold value to detect a pallet 
    Max_MVal3_Feed =0;
    Min_MVal3_Feed =0; 
    % variables for storing a time avergaed version of the light sensor
    % history in 
    smooth_data_Feed =[];  
    % flag for informing the software that the mean threshold exists and so it can use the new method of finding the threshold value  
    Update_Flag_Feed =0;     
    M_Mean_Thresh_Feed =0; 
    
    local_format = '%s %s';
    filename_local_val = ['Fval_Current',num2str(Transfer_id),'.txt'];
    filepath_local_val = [path2databus,filename_local_val];
    
end
%% Dynamic Lighting Section 

    val_matrix = [val_matrix; toc, val,mainlineclear_feed];
    save(filepath_val, 'val_matrix')
    flocal_val= fopen(filepath_local_val,'w');
    fprintf(flocal_val,local_format,num2str(val),num2str(mainlineclear_feed));
    fclose(flocal_val);
    sensor_data_write_amount = sensor_data_write_amount + 16;
    % assuming there is no pallet present initilally take a lot of results and
    % average over them to get a baseline level 
	if length(val_matrix) == 30
        % 22/11/11 creating dynamic threshold for mainline light sensor
        Min_MVal3_Feed =  mean(val_matrix(:,2));
        M_Min_Flag_Feed = 1;
        disp('Initial Lower Bound threshold calculated and Applied to Transfer Unit 1 Feed Sensor')
    end
    
    % check the local region of the data and decide if eitehr flag needs
    % updating 
    
    if length(val_matrix) > 30
        smooth_data_Feed = movingav(val_matrix(:,2),10);
        
        if max(smooth_data_Feed) > Max_MVal3_Feed && M_Max_Flag_Feed == 1
            M_Max_Flag_Feed = 0;
        end
        
        if min(smooth_data_Feed) < Min_MVal3_Feed && M_Min_Flag_Feed == 1
            M_Min_Flag_Feed = 0; 
        end 
        
        if M_Max_Flag_Feed == 0 && Max_MVal3_Feed == 0;
            Mlval = length(val_matrix);
            if val_matrix(Mlval-3:Mlval,2) > Min_MVal3_Feed*1.75
                Max_MVal3_Feed = max(smooth_data_Feed) + 30;
                M_Max_Flag_Feed = 1;
                M_Mean_Thresh_Feed = mean([Min_MVal3_Feed,Max_MVal3_Feed]);
                mainlineclear_feed = M_Mean_Thresh_Feed;
                disp('Initial upper bound thresholds calculated and applied to Transfer Unit 1 Feed Sensor.')
            end
        end % end of if max flag needs updating section 
        
         % section for determining the new upper bound of the data    
        if M_Max_Flag_Feed == 0 && Max_MVal3_Feed  > 0;
            Mlval = length(val_matrix);
            if val_matrix(Mlval-5:Mlval,2) > Min_MVal3_Feed*1.75
                Max_MVal3_Feed = max(smooth_data_Feed) + 30;
                M_Max_Flag_Feed = 1;
                M_Mean_Thresh_Feed = mean([Min_MVal3_Feed,Max_MVal3_Feed]);
                disp('New upper bound thresholds calculated and applied to Transfer Unit 1 Feed Sensor.')
                Update_Flag_Feed =1;
            end
        end % end of if max flag needs updating section 

        if  M_Min_Flag_Feed == 0 && Max_MVal3_Feed > Min_MVal3_Feed 
            Mlval = length(val_matrix);
            if val_matrix(Mlval-5:Mlval,2) > Min_MVal3_Feed*0.75 
                Min_MVal3_Feed = min(smooth_data_Feed);
                M_Min_Flag_Feed = 1;
                M_Mean_Thresh_Feed = mean([Min_MVal3_Feed,Max_MVal3_Feed]);
                Update_Flag_Feed =1;
                disp('New lower bound thresholds calculated and applied to Transfer Unit 1 Feed Sensor.')
            end
        end % end of if min flag needs updating section 
        
        % find the difference between the threshold and the current minimum
        %to set the actual threshold deviation from the minimum and then
        %update the threshold by adding it to the current time averaged
        %minimum 
        if Update_Flag_Feed == 1
                mainlineclear_feed =  M_Mean_Thresh_Feed;
        end 
    end% end of data longer than 30 section 
%% Decision Section 

if val>=mainlineclear_feed
    pallet=1;
    disp('Pallet Detected at Point b')
end

%% Section of Code To handle Pallets Being Moved Across From the Unit-

if val<mainlineclear_feed && pallet==1;
    % if there is a pallet present last time and there is now no longer a
    % pallet then the pallet has mvoed forward ,raise the pallet_move flag
    pallet_move = 1;
    disp('Transition detected.Receiving Pallet  from point Feed Unit at Point B.Transfer line should now run.')
    toc
    pallet = 0;
elseif val<mainlineclear_feed
    % else if there was not a palelt last time then the pallet_move flag is
    % not required
    pallet=0;
    disp('No pallet detected at point B')
    toc
elseif val>mainlineclear_feed
    % raise the palelt flag if a palelt is detected at point b
    pallet = 1; 
    disp('There is a pallet at point B')
    toc
end
disp('Sensor Check Completed')