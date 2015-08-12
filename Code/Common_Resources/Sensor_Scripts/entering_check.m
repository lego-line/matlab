% EnteringCheck.m - script file used by the mainline buffering code to
% consult the upstream light sensor on the preceeding section of mainline
% to check for an arrival from that section of mainline. 
%% Initialisation 
%Setting up light sensors
OpenLight(SENSOR_2, 'ACTIVE', Main);
on = GetLight(SENSOR_2, Main);
OpenLight(SENSOR_2, 'INACTIVE', Main);
off=GetLight(SENSOR_2, Main);
val_entering=on-off; 
% 18/10/11 subscript _m added to distinguish from feed unit val.
disp('Running Entering Sensor Check')
toc

if first_run == 1; %only run this on first run
    disp('Running First Time Setup Script')
	%Get light sensor parameters from config_master
	fid = fopen(path2master,'rt');
	%Scan within file for text with certain formatting
	out = textscan(fid,'%s %s %s');
	%Close file
	fclose(fid);
	%Search for MainlinePass in out

    % this is the mainline clear light sensor value 
	ind = strmatch('mainlineclear',out{1});
	mainlineclear_entry = [out{3}(ind)];
	mainlineclear_entry = str2num(mainlineclear_entry{1});

    % initialise Mval matrices for light data 
	Ent_matrix=[];
    % flags for showing when a new maximum or minimum value ahs been found
    % and informing the software to perform an update of the threshold for
    % whichever case is required 
	M_Max_Flag_Entry = 0;
    M_Min_Flag_Entry = 0;
    % maximum and minimum light sensor levels - used for calculating the
    % threshold value to detect a pallet 
    Max_MVal_Entry =0;
    Min_MVal_Entry =0; 
    % variables for storing a time avergaed version of the light sensor
    % history in 
    smooth_data_Entry =[];  
    % flag for informing the software that the mean threshold exists and so it can use the new method of finding the threshold value  
    Update_Flag_Entry =0;     
    M_Mean_Thresh_Entry =0; 
    filename_entval = ['Entval_matrix',num2str(Main_id),'.mat'];
    filepath_entval = [path2sensordata,filename_entval];
    
    local_format = '%s %s';
    filename_local_ent=['Entval_Current',num2str(Main_id),'.txt'];
    filepath_local_ent= [path2databus,filename_local_ent];
    
end

%End of initialisation

%% Dynamic Light Threshold Settings

Ent_matrix = [Ent_matrix; toc, val_entering,mainlineclear_entry];
save(filepath_entval, 'Ent_matrix')

flocal=fopen(filepath_local_ent,'w');
fprintf(flocal,local_format,num2str(val_entering),num2str(mainlineclear_entry));
fclose(flocal); 
sensor_data_write_amount = sensor_data_write_amount + 16;
% assuming there is no pallet present initilally take a lot of results and
% average over them to get a baseline level 
if length(Ent_matrix) == 30
    % 22/11/11 creating dynamic threshold for mainline light sensor
    Min_MVal_Entry =  mean(Ent_matrix(:,2));
    M_Min_Flag_Entry = 1;
    disp('Initial Lower Bound threshold calculated and Applied to Mainline Unit Entry Sensor')
end

% check the local region of the data and decide if eitehr flag needs
% updating 

if length(Ent_matrix) > 30
    smooth_data_Entry = movingav(Ent_matrix(:,2),10);

    if max(smooth_data_Entry) > Max_MVal_Entry && M_Max_Flag_Entry == 1
        M_Max_Flag_Entry = 0;
    end

    if min(smooth_data_Entry) < Min_MVal_Entry && M_Min_Flag_Entry == 1
        M_Min_Flag_Entry = 0; 
    end 

    if M_Max_Flag_Entry == 0 && Max_MVal_Entry == 0;
        Mlval = length(Ent_matrix);
        if Ent_matrix(Mlval-3:Mlval,2) > Min_MVal_Entry*1.75
            Max_MVal_Entry = max(smooth_data_Entry) + 30;
            M_Max_Flag_Entry = 1;
            M_Mean_Thresh_Entry = mean([Min_MVal_Entry,Max_MVal_Entry]);
            mainlineclear_entry = M_Mean_Thresh_Entry;
            disp('Initial upper bound thresholds calculated and applied to Mainline Unit Entry Sensor.')
        end
    end % end of if max flag needs updating section 

     % section for determining the new upper bound of the data    
    if M_Max_Flag_Entry == 0 && Max_MVal_Entry  > 0;
        Mlval = length(Ent_matrix);
        if Ent_matrix(Mlval-5:Mlval,2) > Min_MVal_Entry*1.75
            Max_MVal_Entry = max(smooth_data_Entry) + 30;
            M_Max_Flag_Entry = 1;
            M_Mean_Thresh_Entry = mean([Min_MVal_Entry,Max_MVal_Entry]);
            disp('New upper bound thresholds calculated and applied to Mainline Unit Entry Sensor.')
            Update_Flag_Entry =1;
        end
    end % end of if max flag needs updating section 

    if  M_Min_Flag_Entry == 0 && Max_MVal_Entry > Min_MVal_Entry 
        Mlval = length(Ent_matrix);
        if Ent_matrix(Mlval-5:Mlval,2) > Min_MVal_Entry*0.75 
            Min_MVal_Entry = min(smooth_data_Entry);
            M_Min_Flag_Entry = 1;
            M_Mean_Thresh_Entry = mean([Min_MVal_Entry,Max_MVal_Entry]);
            Update_Flag_Entry =1;
            disp('New lower bound thresholds calculated and applied to Mainline Unit Entry Sensor.')
        end
    end % end of if min flag needs updating section 

    % find the difference between the threshold and the current minimum
    %to set the actual threshold deviation from the minimum and then
    %update the threshold by adding it to the current time averaged
    %minimum 
    if Update_Flag_Entry == 1
            mainlineclear_entry =M_Mean_Thresh_Entry;
    end 
end% end of data longer than 30 section 


%% Operations Section

%If light has changed from blocked to unblocked the the edge of a pallet
%has been detected and so the mainline should increment the number of
%pallets that are present, in eitehr case update the previous statement 


if val_entering>mainlineclear_entry
    disp('A Package is Detected at entry')
    toc 
    if entering_previous_pallet == 0
        time_in_last = toc;
    end
    entering_previous_pallet=1;
else
    disp('The Mainline is Clear') 
    toc
    if entering_previous_pallet == 1; 
        disp('A Pallet has Entered the Line')
        toc
        %increment number of pallets on mainline 
        no_pallets_mainline = no_pallets_mainline +1; 
        enteringflag=1; 
    end 
    % reset the previous pallet flag to show there was no pallet present at
    % last check 
    entering_previous_pallet=0; 
    time_in_last = toc;
end
disp('Sensor Check Completed')