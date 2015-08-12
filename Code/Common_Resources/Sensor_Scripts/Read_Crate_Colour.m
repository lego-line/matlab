% Read_Crate_Colour - script to read the data from the colour sensor attached to the splitter
% unit and determine the colour of the pallet 
disp('Performing A Pallet Colour Reading')
toc 
% read the colour data in 
[data_ind,data_r,data_g,data_b]=GetColor(SENSOR_2,0,splitter);


% save the data into a history such that it can be evaluated later. 
Splitter_Colour_Matrix = [Splitter_Colour_Matrix;toc,data_ind,data_r,data_g,data_b,Line_Colour_Average_r,Line_Colour_Average_g,Line_Colour_Average_b];

% for the first few time intervals we record the read data to get an idea
% of the apparent colour of the track under the lighting conditions, this
% assumes that no pallet arrives for the first 30 readings fractions of a
% second hopefully. 
if size(Splitter_Colour_Matrix,1) == 30
    % avergae the rgb readings over this interval to determine the apparent
    % track colour. 
    Line_Colour_Average_r = mean(Splitter_Colour_Matrix(:,2));
    Line_Colour_Average_g = mean(Splitter_Colour_Matrix(:,3));
    Line_Colour_Average_b = mean(Splitter_Colour_Matrix(:,4));
end


if data_ind <=15 && data_ind > 12
    % in this case we use the colour sensors own index to colour to
    % determine that it is basically seeing black or very dark gray and
    % hence something is wrong with the detection. 
    disp('No pallet colour is detected')
    previous_colour = 0;
    Splitter_Colour_History =[Splitter_Colour_History,0];
end

% case for a gray pallet in the dark gray region. 
if  data_ind >= 11 && data_ind <= 12 
    disp('A Gray Pallet is Present')
end
    
% if the colour is less than three we may have a gray or blue pallet, which
% w can determine more accurately by looking at the RBG values retruned. 
if data_ind <=3 
    if (data_b/data_r) > 3.5 
        % if there is much more blue than red we can say that the pallet is
        % liekly blue - this is based on empirical data. 
        disp('A Blue Pallet is Present')
        Splitter_Colour_History =[Splitter_Colour_History,3];
        previous_colour = 3; % code for the colour seen. 
    else
        %if the RBg values are approximately equal and close to the track
        %colour we have a dark gray pallet on the line 
        if  data_g < (Line_Colour_Average_g * 1.25) && data_b < (Line_Colour_Average_b * 1.25) && data_r < (Line_Colour_Average_r * 1.25)
            disp('The Pallet Present is Dark Gray')
            Splitter_Colour_History =[Splitter_Colour_History,1];
            previous_colour = 1; % code for dark gray 
        else
            % else the pallet must be light gray. 
            disp('The pallet Present is Light Gray')
            Splitter_Colour_History =[Splitter_Colour_History,2];
            previous_colour = 2; % code for light gray 
        end
    end
end

if data_ind >=4 && data_ind <=6 
    % this is the range of colour valus from yellow and is accurate as
    % yellow is a suibaly different colour to the others in terms of
    % spectral content.
        disp('A Yellow Pallet is Present')
        Splitter_Colour_History =[Splitter_Colour_History,4];
        previous_colour = 4; % code for yellow
end

if data_ind >=7 && data_ind <=11 
    % this is the range of colour valus from red and is accurate as
    % red is a suibaly different colour to the others in terms of
    % spectral content.
        disp('A Red Pallet is Present')
        Splitter_Colour_History =[Splitter_Colour_History,5];
        previous_colour = 5; % code for red. 
end

% find the length of the colour history vector
Length_Val = length(Splitter_Colour_History);

% if the vector has at least four elements we can moving average over them
if Length_Val > 4
    % if the most recent value is different to the previous value, and a
    % pallet is present we have probably detected the edge of the pallet as
    % the edge causes odd colour conetent and a lot of variation to be
    % observed. 
    if Splitter_Colour_History(Length_Val) ~= Splitter_Colour_History(Length_Val-1) && detected_pallet ==0 && colour_state ==0 ;
        time_in_c = toc;
        % record this tim,e, if we then wait a few moments we can record
        % teh colour from the flat side of the pallet which is more
        % reliable than trying to do it near the rounded ront edge. 
        disp('The edge of a pallet has been detected- waiting to take a reading once the pallet is fully under the sensor')
        % show that a pallet has been detected to prevent this stage
        % happening again for the same pallet. 
        detected_pallet = 1;
        colour_state=1;
    end     
    
    % we check to see if we have four consisnt colour readings after a
    % short interval, such that we have four consecutive colour readings
    % from the flat side of the pallet to eliminate sensor variabnce 
    if Splitter_Colour_History(Length_Val) == Splitter_Colour_History(Length_Val-1) && Splitter_Colour_History(Length_Val-2) == Splitter_Colour_History(Length_Val-3) && Splitter_Colour_History(Length_Val-2) == Splitter_Colour_History(Length_Val-1)&& Splitter_Colour_History(Length_Val) ~= 0 && detected_pallet == 1 && (toc-time_in_c) > 0.5  && colour_state == 1      
        disp('This is a new pallet updating the colour table')
        % state for the log that we have successfully identified the
        % colour. 
        colour_sensor_pallet_number = colour_sensor_pallet_number +1;
        % add it to the colour table which is later unified with the code
        % table by the code reading script. 
        colour_table=[colour_table;colour_sensor_pallet_number,Splitter_Colour_History(Length_Val),data_r,data_g,data_b];
        % if the pallet is to be separated we lower the flag to show that
        % this is a not acceptable pallet and the pusher needs to be fired
        % to sepaarte it. 
        if Splitter_Colour_History(Length_Val) == Seperated_Colour
            colour_flag =0; 
        end 
        
        colour_state =2; 
    end
    if (toc - time_in_c) > 3 && detected_pallet == 1 && colour_state == 2;
        % after a time interval we reset the variables used in the
        % intermediate stages such that the enxt pallet can be identified. 
        detected_pallet =0; 
        colour_state =0; 
    end
    
end 
