% transferline_clear - script called by the mainline buffering scripts to
% check the staus of the downstream transfer line exit point by consulting
% the light sensor placed there. 

%% Take The Reading 
% We aim to minimise the impact of ambient light changes in the course of a run by taking a
% differential reading: we take on and off readings, ambient light will
% affect both equally, and hence if we take the difference this additional
% contribution will cancel out. Thus if we threshold this value instead the
% threshold is more stable across the time of one run. 
% 18/10/11 subscript _m added to distinguish from feed unit val.

disp('Running Downstream Sensor Check')
toc
% take an on reading by turning lgiht on and then reading
OpenLight(SENSOR_4, 'ACTIVE', Main);
on = GetLight(SENSOR_4, Main);
% take an off reading
OpenLight(SENSOR_4, 'INACTIVE', Main);
off=GetLight(SENSOR_4, Main);
val_entering=on-off; 

%% Set up variables on the First Run 
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
	ind = strmatch('TransferClearHI',out{1});
	mainlineclear3 = [out{3}(ind)];
	mainlineclear3 = str2num(mainlineclear3{1});
    % initialise Mval matrices for light data 
	Transfer_Down_matrix = [];
    % flags for showing when a new maximum or minimum value ahs been found
    % and informing the software to perform an update of the threshold for
    % whichever case is required 
	M_Max_Flag_Trans = 0;
    M_Min_Flag_Trans = 0;
    % maximum and minimum light sensor levels - used for calculating the
    % threshold value to detect a pallet 
    Max_MVal_Trans =0;
    Min_MVal_Trans =0; 
    % variables for storing a time avergaed version of the light sensor
    % history in 
    smooth_data_Trans =[];  
    % flag for informing the software that the mean threshold exists and so it can use the new method of finding the threshold value  
    Update_Flag_Trans =0;     
    M_Mean_Thresh_Trans =0;    
    % setup the names of the file to save the data into for the purpose of
    % the data bus. 
    filename_transval = ['Transferval_matrix',num2str(Main_id),'.mat'];
    filename_local_transferval = ['Transfer_Current',num2str(Main_id),'.txt'];
    filepath_transval = [path2sensordata,filename_transval];
    filepath_local_transferval = [path2databus,filename_local_transferval]; 
    local_format ='%s %s';
end


% log the data into a transfer matrix and save the transfer matrix to the
% log file location.
Transfer_Down_matrix = [Transfer_Down_matrix; toc, val_entering,mainlineclear3];
save(filepath_transval, 'Transfer_Down_matrix')

% strote the data from the sensors onto the data bus as this sensor is
% important. 
fstore=fopen(filepath_local_transferval,'w');
fprintf(fstore,local_format,num2str(val_entering),num2str(mainlineclear3));
fclose(fstore);
sensor_data_write_amount = sensor_data_write_amount + 16;

%% Calculating New Values for Dynamic Lighting Sensor Unit 1
%Setting up sensor thresholds based on existing data

% assuming there is no pallet present initilally take a lot of results and
% average over them to get a baseline level 
	if length(Transfer_Down_matrix) == 30
        % 22/11/11 creating dynamic threshold for mainline light sensor
        Min_MVal_Trans =  mean(Transfer_Down_matrix(:,2));
        M_Min_Flag_Trans = 1;
        disp('Initial Lower Bound threshold calculated and Applied to Mainline Unit Transfer Unit Sensor.')
    end
    
    % check the local region of the data and decide if eitehr flag needs
    % updating 
    
    if length(Transfer_Down_matrix) > 30
        
        % smooth the data to eliminate some variablility which clouds
        % things
        smooth_data_Trans = movingav(Transfer_Down_matrix(:,2),10);
        % if the maximum is greater than the existing maximum then we have
        % found a new global maximum & its not update time, set the update
        % flag low to show it needs recaculating
        if max(smooth_data_Trans) > Max_MVal_Trans && M_Max_Flag_Trans == 1
            M_Max_Flag_Trans = 0;
        end
        % simialrly if the value is below the current minimum and the flag
        % is set to say that it is fine change the flag low to correct this on the update. 
        if min(smooth_data_Trans) < Min_MVal_Trans && M_Min_Flag_Trans == 1
            M_Min_Flag_Trans = 0; 
        end 
        % if the flag ahs been set low indicating that the maximum is
        % incorrect. 
        if M_Max_Flag_Trans == 0 && Max_MVal_Trans == 0;
            Mlval = length(Transfer_Down_matrix);
            if Transfer_Down_matrix(Mlval-3:Mlval,2) > Min_MVal_Trans*1.75
                Max_MVal_Trans = max(smooth_data_Trans) + 30;
                M_Max_Flag_Trans = 1;
                M_Mean_Thresh_Trans = mean([Min_MVal_Trans,Max_MVal_Trans]);
                mainlineclear3 = M_Mean_Thresh_Trans;
                disp('Initial upper bound thresholds calculated and applied to Mainline Unit Transfer Unit Sensor.')
            end
        end % end of if max flag needs updating section 
         % section for determining the new upper bound of the data    
        if M_Max_Flag_Trans == 0 && Max_MVal_Trans  > 0;
            Mlval = length(Transfer_Down_matrix);
            if Transfer_Down_matrix(Mlval-5:Mlval,2) > Min_MVal_Trans*1.75
                Max_MVal_Trans = max(smooth_data_Trans) + 30 ;
                M_Max_Flag_Trans = 1;
                M_Mean_Thresh_Trans = mean([Min_MVal_Trans,Max_MVal_Trans]);
                disp('New upper bound thresholds calculated and applied to Mainline Unit Transfer Unit Sensor.')
                Update_Flag_Trans =1;
            end
        end % end of if max flag needs updating section 
        if  M_Min_Flag_Trans == 0 && Max_MVal_Trans > Min_MVal_Trans 
            Mlval = length(Transfer_Down_matrix);
            if Transfer_Down_matrix(Mlval-5:Mlval,2) > Min_MVal_Trans*0.75 
                Min_MVal_Trans = min(smooth_data_Trans);
                M_Min_Flag_Trans = 1;
                M_Mean_Thresh_Trans = mean([Min_MVal_Trans,Max_MVal_Trans]);
                disp('New lower bound thresholds calculated and applied to Mainline Unit Transfer Unit Sensor.')
                Update_Flag_Trans = 1;
            end
        end % end of if min flag needs updating section 
        % find the difference between the threshold and the current minimum
        %to set the actual threshold deviation from the minimum and then
        %update the threshold by adding it to the current time averaged
        %minimum 
        
        % if the update flag is set then we copy the new mainline threshofl
        % as the average of the max and min values such that it is
        % hopefully lying in the middle of the data range. 
        if Update_Flag_Trans == 1
                mainlineclear3 = M_Mean_Thresh_Trans;
        end 
    end% end of data longer than 30 section 
%% Operations Section

%If light has changed from blocked to unblocked the the edge of a pallet
%has been detected and so the mainline should increment the number of
%pallets that are present, in eitehr case update the previous statement 
if val_entering > mainlineclear3
    % if the value is above the threshold then we have a pallet present 
    disp('The Downstream Line Has A Pallet Present')
    toc
    t2 = toc; 
    pallet=1;
else
    % esle the line is clear. 
    disp('The Downstream Line is Clear') 
    toc
    pallet=0; 
end
% if there is no pallet now, but there was a pallet less than three seconds
% ago then the pallet is in transfer, thus the blockage still persists past
% the time the pallet is detected as leaving the sensor for three seconds.
if (toc - t2) >= 7 && pallet == 0
    % if there is no pallet after three seconds then the blockage has
    % passed, and no new blockage has arrived.
    blockage = 0;
    disp('The DownStream Transfer has Completed')
end 
if  (toc - t2) <= 7
    % tell the user that the transfer is occuring if the pallet is still
    % there (toc approximately t2 if val_entering> mainlineclear or for
    % three seconds after it has left. 
    disp('The Downstream Line Is Transferring')
    blockage = 1;
end 
% some feed back from the log file. 
disp('The Value of Blockage is')
disp(blockage)
disp('Sensor Check Completed')