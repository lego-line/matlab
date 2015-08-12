% Exiting Check .m - script called by the mainline to check teh status of
% the exiting light sensor to see if there is a pallet present at the
% intesection of the two coneyor sections- used by all mainline buffering
% scripts. 
%% Initialisation 
%Setting up light sensors
OpenLight(SENSOR_1, 'ACTIVE', Main);
on = GetLight(SENSOR_1, Main);
OpenLight(SENSOR_1, 'INACTIVE', Main);
off=GetLight(SENSOR_1, Main);
val_exiting=on-off; 
% 18/10/11 subscript _m added to distinguish from feed unit val.
disp('Running Exiting Sensor Check')
toc
log_threshold=[];

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
	mainlineclear_exit = [out{3}(ind)];
	mainlineclear_exit = str2num(mainlineclear_exit{1})-100;
    % initialise Mval matrices for light data 
	Exit_matrix = [];
    % flags for showing when a new maximum or minimum value ahs been found
    % and informing the software to perform an update of the threshold for
    % whichever case is required 
	M_Max_Flag_Exit = 0;
    M_Min_Flag_Exit = 0;
    % maximum and minimum light sensor levels - used for calculating the
    % threshold value to detect a pallet 
    Max_MVal_Exit =0;
    Min_MVal_Exit =0; 
    % variables for storing a time avergaed version of the light sensor
    % history in 
    smooth_data_exit =[];  
    % flag for informing the software that the mean threshold exists and so it can use the new method of finding the threshold value  
    Update_Flag_exit =0;     
    M_Mean_Thresh_exit =0; 
    filename_exitval = ['Exitval_matrix',num2str(Main_id),'.mat'];
    filepath_exitval = [path2sensordata,filename_exitval];
    
    local_format = '%s %s';
    filename_local_exit=['Exitval_Current',num2str(Main_id),'.txt'];
    filepath_local_exit= [path2databus,filename_local_exit];
    
end
%End of initialisation
%% Dynamic Thresholding Section

%%Calculating New Values for Dynamic Lighting Sensor 
%Setting up sensor thresholds based on existing data
    Exit_matrix = [Exit_matrix; toc, val_exiting,mainlineclear_exit];
    save(filepath_exitval, 'Exit_matrix')
    flocal=fopen(filepath_local_exit,'w');
    fprintf(flocal,local_format,num2str(val_exiting),num2str(mainlineclear_exit));
    fclose(flocal); 
    sensor_data_write_amount = sensor_data_write_amount + 16;
    if length(Exit_matrix) == 30
        % 22/11/11 creating dynamic threshold for mainline light sensor
        Min_MVal_Exit =  mean(Exit_matrix(:,2));
        M_Min_Flag_Exit = 1;
        disp('Initial Lower Bound threshold calculated and Applied to Mainline Unit Exit Sensor.')
    end
    
    % check the local region of the data and decide if eitehr flag needs
    % updating 
    
    if length(Exit_matrix) > 30
        smooth_data_exit = movingav(Exit_matrix(:,2),10);
        
        if max(smooth_data_exit) > Max_MVal_Exit && M_Max_Flag_Exit == 1
            M_Max_Flag_Exit = 0;
        end
        
        if min(smooth_data_exit) < Min_MVal_Exit && M_Min_Flag_Exit == 1
            M_Min_Flag_Exit = 0; 
        end 
        
        if M_Max_Flag_Exit == 0 && Max_MVal_Exit == 0;
            Mlval = length(Exit_matrix);
            if Exit_matrix(Mlval-3:Mlval,2) > Min_MVal_Exit*1.75
                Max_MVal_Exit = max(smooth_data_exit) + 30;
                M_Max_Flag_Exit = 1;
                M_Mean_Thresh_exit = mean([Min_MVal_Exit,Max_MVal_Exit]);
                mainlineclear_exit = M_Mean_Thresh_exit;
                disp('Initial upper bound thresholds calculated and applied to Mainline Unit Exit Sensor.')
            end
        end % end of if max flag needs updating section 
        
         % section for determining the new upper bound of the data    
        if M_Max_Flag_Exit == 0 && Max_MVal_Exit  > 0;
            Mlval = length(Exit_matrix);
            if Exit_matrix(Mlval-5:Mlval,2) > Min_MVal_Exit*1.75
                Max_MVal_Exit = max(smooth_data_exit) + 30;
                M_Max_Flag_Exit = 1;
                M_Mean_Thresh_exit = mean([Min_MVal_Exit,Max_MVal_Exit]);
                disp('New upper bound thresholds calculated and applied to Mainline Unit Exit Sensor.')
                Update_Flag_exit =1;
            end
        end % end of if max flag needs updating section 

        if  M_Min_Flag_Exit == 0 && Max_MVal_Exit > Min_MVal_Exit 
            Mlval = length(Exit_matrix);
            if Exit_matrix(Mlval-5:Mlval,2) > Min_MVal_Exit*0.75 
                Min_MVal_Exit = min(smooth_data_exit);
                M_Min_Flag_Exit = 1;
                M_Mean_Thresh_exit = mean([Min_MVal_Exit,Max_MVal_Exit]);
                Update_Flag_exit =1;
                disp('New lower bound thresholds calculated and applied to Mainline Unit Exit Sensor.')
            end
        end % end of if min flag needs updating section 
        
        % find the difference between the threshold and the current minimum
        %to set the actual threshold deviation from the minimum and then
        %update the threshold by adding it to the current time averaged
        %minimum 
        if Update_Flag_exit == 1
                mainlineclear_exit = M_Mean_Thresh_exit;
        end 
    end% end of data longer than 30 section 

%% Operations Section

%If light has changed from blocked to unblocked the the edge of a pallet
%has been detected and so the mainline should decrement the number of
%pallets that are present, in eitehr case update the previous statement 


if val_exiting>mainlineclear_exit
    disp('A Package is Detected at Exit') 
    toc  
    if exiting_previous_pallet == 0
        exitingflag2 = 1;
        disp('Rising Edge Detected')
        handshake_flag =1; % raise handshake flag as the pallet has been added in both counts 
    end 
   exiting_previous_pallet=1;  
else
    disp('The Mainline is Clear')
    toc 
    if exiting_previous_pallet == 1; 
        disp('A Pallet has Exited the Line-Falling Edge')
        handshake_flag=0; % lower handhskae flag as now the number for the front has been decremented 
        toc
        if no_pallets_mainline > 0
            no_pallets_mainline = no_pallets_mainline - 1; 
        end
        exitingflag  = 1;
        % set the entering flag high to denote arrival of a pallet
    end 
    exiting_previous_pallet=0;
    time_out_last =toc; 
    % reset the previous pallet flag to show there was no pallet present at
    % last check   
end
disp('Sensor Check Completed')