% Read_Crate_Code  -  (12/7/12) to read the code from the side
% of the crates in the splitter unit and return it to the main script. 

%% Startup Section 
disp('Running A Pallet Code Check') 
toc

% setup some key variables if on the first run. 
if first_run == 1
    % code to gather mainline data for the initial run 
    disp('Performing the initial setup for the light sensor')
    toc
    val_active =GetLight(SENSOR_4, splitter);
    val_passive=GetLight(SENSOR_3, splitter);
    mainline_clear =val_passive-val_active; 
    % take the difference to remove effect of ambient lighting to denote the level of sensor data for a mainline clear result
    mainline_clear_threshold = mainline_clear-50;
    % set a threshold to take into account some variation in lighting, not
    % necessarily the optimum way of setting this dynamically but it seems
    % to work. 
end

%% Operations Section 
% check the splitter light sensors to get a threshold reading or light
% shining through the gate. 
% if no pallet is present on the splitter then check the line to see if a
% pallet has arrived and take appropriate action if it has 

    data_1 = GetLight(SENSOR_3, splitter); %read light sensor passive
    data_2 = GetLight(SENSOR_4, splitter); % read light sensor active
    data_usable = data_1 - data_2;         % take difference to account for differences in the ambient lighting levels  
    
    Splitter_Matrix = [Splitter_Matrix;toc,data_usable,spike_threshold];%place value into matrix of results across all time

 %% Section to give Dynamic Light Sensor Updates

if length(Splitter_Matrix) >=100
    test_threshold = mean(Splitter_Matrix(:,2));
    if abs(test_threshold-mainline_clear_threshold) >= abs(mainline_clear_threshold/10)
        disp('Calculating New Threshold Value for Pallet')
        mainline_clear_threshold = (mainline_clear_threshold + test_threshold)/2;
        % move the threshold to the mean of the test threshold and the
        % original threshold to incorporate the new light data.
    end    
end

%% Decision Section

% if previously there was no pallet on the line 
if pallet==0;	
    % if the light level is high then there is no obstruction in the gate
    % and still no pallet entering 
    if data_usable > mainline_clear_threshold 
        % set the pallet flag to show no pallet was detected 
        disp('No Pallet was detected on the mainline')
        toc
    else
        % else a pallet is obscuring he gate and we treat it as a new
        % entity as no pallet was just present. 
        % raise the pallet flag to show we have a pallet 
        pallet =1;
        disp('A Pallet was Detected entering on the Mainline')
        disp(time_in)        
        % section to set up a local matrix to record the light sensor time history  over the length of the pallet.    
        clear code_results
        code_results = [];
        % setup a current vector which contains nominal bits for the three
        % bit code on the pallet which will be edited as the pallet
        % progresses through the gate. 
        current =[1 1 1];  
        % record the start time of the pallet 
        time_in = toc;
    end
end 

% section of the code to deal with the arrival of a pallet and
% recording the pallets code 

 %while pallet is present and time < 3 (i.e pallet hasn't yet passed through compeltely) read data and build array 
if (toc-time_in) < 3 && pallet==1;           
    % start the time at zero being the leading edge of the pallet, and 3
    % being roughly the end of the pallet
    code_results = [code_results ; (toc-time_in)  data_usable,spike_threshold]; %update the individual pallet array  aat each tiem interval
end 

% when the time is greater than 3 the pallet has passed sufficiently so analyse the data
% gatehred and make a decision about the code. 


if (toc-time_in) > 3 && pallet==1; %when time is >3 pallet has passed, analyse data

    % take a local maximum to find the highest sensor reading from the
    % time the pallet is passing. 
    max_val = max(code_results(:,1));
    % take a local minimum to find the lowest sensor reading from the
    % time the pallet is passing. 
    min_val = min(code_results(:,1));
    % take an average to find the appropriate threshold value to detect a
    % spike in value, assuming the maximum is approximately a hole and the
    % minimum represents a filled state or section of pallet side wall. 
    spike_threshold =(max_val+min_val)/2;
    % find the length of the results vector suhc that we can loop over it. 
    code_results_length = size(code_results,1);

    
    % loop over the entire vector. 
    for loop = 1:code_results_length
        % ifn this section t1-6 represent the boundaries of tiem intervals
        % in which we should look for the bits of the code, and are read
        % fom the master config file as they are based on belt speed. 
        
        
        % if time is in range specified for first bit and the gradient
        % exceeds the threshold then  a  0 bit is detected 
        % if there is no spike in the differntial in the corect region then the bit
        % is assumed to be a one 
        
        if (code_results(loop,1)) <= t2 && (code_results(loop,1)) >= t1; 
            if code_results(loop,2) >= spike_threshold 
			c=0; % set bit zero if the gradient exceeds spike threshold. 
            end

        end
        % if time is in range specifeid for second  bit and the gradient
        % exceeds the threshold then a 0 bit is detected 
        % if there is no spike in the differntial in the corect region then the bit
        % is assumed to be a one 
        if code_results(loop,1) <= t4 && code_results(loop,1) >= t3; 
            if code_results(loop,2) >= spike_threshold %if spike then b=1 
			b=0;
            end
            
        end
        % if time is in range specifeid for first bit and the gradient
        % exceeds the threshold then  a  0 bit is detected 
        % if there is no spike in the differntial in the corect region then the bit
        % is assumed to be a one 
        if code_results(loop,1) <= t6 && code_results(loop,1) >= t5; 
			if  code_results(loop,2) >= spike_threshold + 50
			a=0; 
            end
        end
    end
    
    % once we have finished determining the code of the pallet 
    % craete a new pallet if the colour sensor has also amde a detection,
    % this double check helps to eliminate false detections and allows
    % better detection of dark grey pallets, as the track is also percieved
    % as dark gray. 
    size_colour_table = size(colour_table);    
    if size_colour_table(1) >= pallet_number
        % some comments for the event log
        disp('A Pallet has Just exited The Splitter Light Gate')     
        pallet = 0 ; %there is no pallet in the system anymore 
        % record the current code from the bits determined previously.
        current = [a b c]; %set current pallet to the respective values
        disp('The code from the pallet was') % comments for the log. 
        disp(current)
        % add the pallets naumber, code, colout and time to the log. 
        palletlist=[palletlist;pallet_number toc current colour_table(pallet_number,2)]; %add the most recent pallet onto the end of an array
        % sets the pallet pointer to a new value. 
        pallet_number = pallet_number + 1;
        %reset a, b and c such that the enxt detection will work correctly.
        %
        a=1;
        b=1;
        c=1;
        % show the colour sensor that this pallet has been fully registered
        % as arriving and documented. 
        registered =0; 
    end
end