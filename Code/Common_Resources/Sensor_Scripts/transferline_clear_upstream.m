% transferline_clear_upstream - script called by the upstream script to
% check the staus of the downstream transfer line exit point by consulting
% the light sensor placed there. 

%% take the Readings
disp('Running Downstream Sensor Check')
toc
% We aim to minimise the impact of ambient light changes in the course of a run by taking a
% differential reading: we take on and off readings, ambient light will
% affect both equally, and hence if we take the difference this additional
% contribution will cancel out. Thus if we threshold this value instead the
% threshold is more stable across the time of one run. 

% take an on reading by turning lgiht on and then reading
OpenLight(SENSOR_4, 'ACTIVE', upstream);
on = GetLight(SENSOR_4, upstream);
% take an off reading
OpenLight(SENSOR_4, 'INACTIVE', upstream);
off=GetLight(SENSOR_4, upstream);
% take the difference 
val_entering=on-off; 

%% Some file setup if this is the first time the script has been called 
if first_run == 1; %only run this on first run
    disp('Running First Time Setup Script')
	%Get light sensor parameters from config_master
	fid = fopen(path2master,'rt');
	%Scan within file for text with certain formatting
	out = textscan(fid,'%s %s %s');
	%Close file
	fclose(fid);
	%Search for MainlinePass in out

    % this is the mainline clear light sensor tolerance
	ind = strmatch('mainlineclear',out{1});
	mainlineclear = [out{3}(ind)];
	mainlineclear = str2num(mainlineclear{1});

    % initialise Mval matrices for light data 
	Transfer_Down_matrix_u = [];
    % flags for showing when a new maximum or minimum value has been found
    % and informing the software to perform an update of the threshold for
    % whichever case is required 
	M_Max_Flag = 0;
    M_Min_Flag = 0;
    % maximum and minimum light sensor levels - used for calculating the
    % threshold value to detect a pallet 
    Max_MVal3 =0;
    Min_MVal3 =0; 
	Max_Flag_mainline_clear=M_Max_Flag;
    % variables for storing a time averaged version of the light sensor
    % history in 
    smooth_data =[];  
    smoothdata2=[]; 
    difference =0;
    % flag for informing the software that the mean threshold exists and so it can use the new method of finding the threshold value  
    Update_Flag =0;     
    M_Mean_Thresh =0; 
    
    
end
%End of initialisation

% log the data into a transfer matrix and save the transfer matrix to the
% log file location.
Transfer_Down_matrix_u = [Transfer_Down_matrix_u; toc, val_entering,mainlineclear];
save(path2downstreamtransfervalupstr, 'Transfer_Down_matrix_u')

%% Calculating New Values for Dynamic Lighting Sensor 
% assuming there is no pallet present initilally take a lot of results and
% average over them to get a baseline level for the no pallet 
if length(Transfer_Down_matrix_u) == 30
    % 22/11/11 creating dynamic threshold for mainline light sensor
    Min_MVal3 =  mean(Transfer_Down_matrix_u(:,2));
    M_Min_Flag = 1;
    disp('Initial Lower Bound threshold calculated and Applied to Upstream Unit')
end
    
% check the local region of the data and decide if eitehr flag needs
% updating 
% if a baseline has already been established   
    if length(Transfer_Down_matrix_u) > 30
        % smooth the data to eliminate some variablility which clouds
        % things
        smooth_data = movingav(Transfer_Down_matrix_u(:,2),10);
        % if the maximum is greater than the existing maximum then we have
        % found a new global maximum & its not update time, set the update
        % flag low to show it needs recaculating
        if max(smooth_data) > Max_MVal3 && M_Max_Flag == 1
            M_Max_Flag = 0;
        end
        % simialrly if the value is below the current minimum and the flag
        % is set to say that it is fine change the flag low to correct this on the update. 
        if min(smooth_data) < Min_MVal3 && M_Min_Flag == 1
            M_Min_Flag = 0; 
        end 
       
        % if the flag ahs been set low indicating that the maximum is
        % incorrect. 
        if M_Max_Flag == 0 && Max_MVal3 == 0;
            % get the length of the vector 
            Mlval = length(Transfer_Down_matrix_u);
            % check if the new value is suitably far away from the 
            if Transfer_Down_matrix_u(Mlval-3:Mlval,2) > Min_MVal3*1.5
                % calculate the new maximumm
                Max_MVal3 = max(smooth_data) + 30;
                M_Max_Flag = 1;
                M_Mean_Thresh = mean([Min_MVal3,Max_MVal3]);
                mainlineclear = M_Mean_Thresh;
                disp('Initial upper bound thresholds calculated and applied to Upstream Unit.')
            end
        end % end of if max flag needs updating section 
        
         % section for determining the new upper bound of the data    
        if M_Max_Flag == 0 && Max_MVal3  > 0;
            Mlval = length(Transfer_Down_matrix_u);
            if Transfer_Down_matrix_u(Mlval-5:Mlval,2) > Min_MVal3*1.75
                Max_MVal3 = max(smooth_data)+30;
                M_Max_Flag = 1;
                M_Mean_Thresh = mean([Min_MVal3,Max_MVal3]);
                %mainlineclear = M_Mean_Thresh;
                disp('New upper bound thresholds calculated and applied to Upstream Unit.')
                Update_Flag =1;
            end
        end % end of if max flag needs updating section 

        % determine the new lower bound to the data if this is wrong. 
        if  M_Min_Flag == 0 && Max_MVal3 > Min_MVal3 
            Mlval = length(Transfer_Down_matrix_u);
            if Transfer_Down_matrix_u(Mlval-5:Mlval,2) > Min_MVal3*0.75 
                Min_MVal3 = min(smooth_data);
                M_Min_Flag = 1;
                M_Mean_Thresh = mean([Min_MVal3,Max_MVal3]);
                %mainlineclear = M_Mean_Thresh;
                disp('New lower bound thresholds calculated and applied to Upstream Unit.')
                Update_Flag =1;
            end
        end % end of if min flag needs updating section 
        
        % find the difference between the threshold and the current minimum
        % to set the actual threshold deviation from the minimum and then
        % update the threshold by adding it to the current time averaged
        % minimum 
        smoothdata2=movingav(Transfer_Down_matrix_u(:,2),(round(size(Transfer_Down_matrix_u,1)/4)));
        % if the update flag is set then we copy the new mainline threshofl
        % as the average of the max and min values such that it is
        % hopefully lying in the middle of the data range. 
        if Update_Flag == 1
                mainlineclear = M_Mean_Thresh;
        end
    end% end of data longer than 30 section 
%% Operations Section

%If light has changed from blocked to unblocked the the edge of a pallet
%has been detected and so the mainline should increment the number of
%pallets that are present, in eitehr case update the previous statement 
if val_entering > mainlineclear
    % if the value is above the threshold then we have a pallet present 
    disp('The Downstream Line Has A Pallet Present')
    toc
    t2 = toc; 
    pallet=1;
else
    % else there is no pallet present if the value is below the threshold.
    disp('The Downstream Line is Clear') 
    toc
    pallet=0; 
end
% if there is no pallet now, but there was a pallet less than three seconds
% ago then the pallet is in transfer, thus the blockage still persists past
% the time the pallet is detected as leaving the sensor for three seconds. 
if (toc - t2) >= 3 && pallet == 0
    % if there is no pallet after three seconds then the blockage has
    % passed, and no new blockage has arrived.
    blockage = 0;
    disp('The DownStream Transfer has Completed')
end 
if  (toc - t2) <= 3
    % tell the user that the transfer is occuring if the pallet is still
    % there (toc approximately t2 if val_entering> mainlineclear or for
    % three seconds after it has left. 
    disp('The Downstream Line Is Transferring')
    blockage = 1;
end 
% feed back for the log file
disp('The Value of Blockage is')
disp(blockage)
disp('Sensor Check Completed')