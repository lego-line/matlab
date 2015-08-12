% Mainline_Clear.m - a script file called by the tarsnfer unit to check the
% stsus of the upstream mianline sensor to see if a transfer can occur(the
% mainline is clear) Pallets at this sensor start a timer which then counts
% down until the pallet has cleared the junction and tarnsfer can occur.

%% Initialisation 
%Setting up light sensors
OpenLight(SENSOR_4, 'ACTIVE', adder);
on = GetLight(SENSOR_4, adder);
OpenLight(SENSOR_4, 'INACTIVE', adder);
off=GetLight(SENSOR_4, adder);
val_m=on-off; 
% 18/10/11 subscript _m added to distinguish from feed unit val.
disp('Running Mainline Clear Check')
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
	ind = strmatch('MainlinePass',out{1});
	%Place values from array ind into TransferClearHI- this is the t;ime
	%taken to move the package past the mainline junction
	MainlinePass = [out{3}(ind)];
	MainlinePass = str2num(MainlinePass{1});


	ind = strmatch('mainlineclear',out{1});
	mainlineclear_mainline = [out{3}(ind)];
	mainlineclear_mainline = str2num(mainlineclear_mainline{1});

    % initialise Mval matrices for light data 
	Mval_matrix = [];    
    % flags for showing when a new maximum or minimum value ahs been found
    % and informing the software to perform an update of the threshold for
    % whichever case is required 
	M_Max_Flag_Main = 0;
    M_Min_Flag_Main = 0;
    % maximum and minimum light sensor levels - used for calculating the
    % threshold value to detect a pallet 
    Max_MVal_Main =0;
    Min_MVal_Main =0; 
    % variables for storing a time avergaed version of the light sensor
    % history in 
    smooth_data_Main =[];  
    difference_Main =0;
    % flag for informing the software that the mean threshold exists and so it can use the new method of finding the threshold value  
    Update_Flag_Main =0;     
    M_Mean_Thresh_Main =0; 
    filename_Mval = ['Mval_matrix',num2str(Transfer_id),'.mat'];
    filepath_Mval = [path2sensordata,filename_Mval];
    local_format = '%s %s';
    filename_local_Mval=['Mval_Current',num2str(Transfer_id),'.txt'];
    filepath_local_Mval= [path2databus,filename_local_Mval];
    % added 30/11/12 to ensure that the 'last pallet' seen at the start of
    % the run was sufficiently far in the past that the line is clear from
    % t>0 to accurately reflect the state 
    t2=-1 * MainlinePass;
end

%End of initialisation
%% Calculating New Values for Dynamic Lighting Sensor First Unit  
%Setting up sensor thresholds based on existing data
    Mval_matrix = [Mval_matrix; toc, val_m,mainlineclear_mainline];
    save(filepath_Mval, 'Mval_matrix')
    flocal=fopen(filepath_local_Mval,'w');
    fprintf(flocal,local_format,num2str(val_m),num2str(mainlineclear_mainline));
    fclose(flocal); 
    sensor_data_write_amount = sensor_data_write_amount + 16;
    
    % assuming there is no pallet present initilally take a lot of results and
    % average over them to get a baseline level 
	if length(Mval_matrix) == 30
        % 22/11/11 creating dynamic threshold for mainline light sensor
        Min_MVal_Main =  mean(Mval_matrix(:,2));
        M_Min_Flag_Main = 1;
        disp('Initial Lower Bound threshold calculated and Applied to Transfer Unit Mainline Sensor')
    end
    
    % check the local region of the data and decide if eitehr flag needs
    % updating 
    
    if length(Mval_matrix) > 30
        smooth_data_Main = movingav(Mval_matrix(:,2),10);
        
        if max(smooth_data_Main) > Max_MVal_Main && M_Max_Flag_Main == 1
            M_Max_Flag_Main = 0;
        end
        
        if min(smooth_data_Main) < Min_MVal_Main && M_Min_Flag_Main == 1
            M_Min_Flag_Main = 0; 
        end 
        
        if M_Max_Flag_Main == 0 && Max_MVal_Main == 0;
            Mlval = length(Mval_matrix);
            if Mval_matrix(Mlval-3:Mlval,2) > Min_MVal_Main*1.75
                Max_MVal_Main = max(smooth_data_Main) + 30;
                M_Max_Flag_Main = 1;
                M_Mean_Thresh_Main = mean([Min_MVal_Main,Max_MVal_Main]);
                mainlineclear_mainline = M_Mean_Thresh_Main;
                disp('Initial upper bound thresholds calculated and applied to Transfer Unit Mainline Sensor.')
            end
        end % end of if max flag needs updating section 
        
         % section for determining the new upper bound of the data    
        if M_Max_Flag_Main == 0 && Max_MVal_Main  > 0;
            Mlval = length(Mval_matrix);
            if Mval_matrix(Mlval-5:Mlval,2) > Min_MVal_Main*1.75
                Max_MVal_Main = max(smooth_data_Main) + 30;
                M_Max_Flag_Main = 1;
                M_Mean_Thresh_Main = mean([Min_MVal_Main,Max_MVal_Main]);
                disp('New upper bound thresholds calculated and applied to Transfer Unit Mainline Sensor.')
                Update_Flag_Main =1;
            end
        end % end of if max flag needs updating section 

        if  M_Min_Flag_Main == 0 && Max_MVal_Main > Min_MVal_Main 
            Mlval = length(Mval_matrix);
            if Mval_matrix(Mlval-5:Mlval,2) > Min_MVal_Main*0.75 
                Min_MVal_Main = min(smooth_data_Main);
                M_Min_Flag_Main = 1;
                M_Mean_Thresh_Main = mean([Min_MVal_Main,Max_MVal_Main]);
                Update_Flag_Main =1;
                disp('New lower bound thresholds calculated and applied to Transfer Unit Mainline Sensor.')
            end
        end % end of if min flag needs updating section 
        
        % find the difference between the threshold and the current minimum
        %to set the actual threshold deviation from the minimum and then
        %update the threshold by adding it to the current time averaged
        %minimum 
        if Update_Flag_Main == 1
                mainlineclear_mainline = M_Mean_Thresh_Main;
        end 
    end% end of data longer than 30 section 
    
%% Operations Section

%If light has changed from blocked to unblocked then wait for a passing
%time to clear the pallet away from the mechanism 
% fix t2 to be the last known time when a brick was present- i.e. the back
% edge of the brick passing the sensor if there is no value t2 is retained,
% therefore toc-t2 is increasing with time
if val_m>mainlineclear_mainline
    t2=toc;
    disp('Package Detected, Waiting For Blockage to Clear') 
    toc
end

% if elapsed time from falling edge is greater than the passing time then
% the line is clear 
if (toc-t2)>MainlinePass
    blockage=0;
    disp('Mainline is Clear')
    toc
end
% else if the passing time has not elapsed then the line is blocked 
if (toc-t2)<MainlinePass
    blockage=1;
    disp('Mainline is Still Blocked') 
    toc
end
disp('Sensor Check Completed')