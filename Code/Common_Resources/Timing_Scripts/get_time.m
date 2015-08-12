%get time .m - script file which contains the code to generate the times at
%which the pallets must be fed. It is called by the feed pallet script and
%generates a value t, which represents the time between the last pallet fed and the next to be fed 
%The time is comapred to t to work out if the pallet is to be fed yet
%or not. 

%% First Run Data Read Section

if first_run == 1; %only read config file on first run to get the schedule data 
    disp('Reading in Feed Schedule')
    %Read module configuration
    if exist(path2config) ~= 0 % simple check to ensure config exists
        % open file 
        fidgettime = fopen(path2config,'rt');
        %Scan within file for text with certain formatting
        out2 = textscan(fidgettime,'%s	%s %s %s %s');
        fclose(fidgettime); % close file 
        
        if feed_id > 0 
            % dependant on the feed id retireve the row index of the correct line
            % by looking at rows of the config starting ControlLineX which
            % will have distribution data as opposed to LineX which has
            % on/off and buffering data 
            set = strmatch(['ControlLine',num2str(feed_id)],out2{1},'exact');
        end 
        if feed_id == 0
            % the upstream unit is special as it is tagged as feed 0 as it
            % is similar to the other feed lines but occurs in a different
            % physical location in the model and hence will require this
            % code. 
                set = strmatch('ControlUpstr',out2{1},'exact'); 
        end
        if length(set) > 1
            % simply ensure that if multiple line are present to take the
            % first one, although the exact reference present getting 1 and
            % 11 confused say this may just help with comments added to the
            % file by the user. 
             set=set(1);
        end 
        % based on the line index pull out the feed time data, distribution
        % is a letter coding the type of distribution of interarrival times
        % to use and the parameters give the relevant numbers to compute
        % the times from the statistical distribution
        Distribution = out2{2}(set);
        Param1 = (out2{3}(set));
        Param1=str2num(Param1{1});
        Param2 = (out2{4}(set));
        Param2=str2num(Param2{1});
        Param3 = (out2{5}(set));
        Param3=str2num(Param3{1});
    else
        %else there is no config file and an error has occured so quit matlab
        disp('Config File Deleted- Assuming that line Terminated Too Soon')
        toc
        Failure_Flag = 1;
        error_type = 'No config file was found in the folder by the get_time file' ;
    end 
    
    if Distribution{1} == 'L'
        % if a list is specified, read list into vector and then take the
        % difference of the arrival times to calculate the interarrival
        % times t that are requried in a vector List_of_Times
        if exist ([path2userresults,'Arrival_Times_Feed_',num2str(feed_id),'.csv']) ~= 0
            % if the list of times is found use csv read to import the data
            % and then take difference 
            disp('List of Times Acquired: Reading In Timing Data')
            List_of_Times = csvread([path2userresults,'Arrival_Times_Feed_',num2str(feed_id),'.csv']);
            List_of_Time_Differences = diff(List_of_Times);
        else 
            % else the list could not be found a a generic fall back case
            % is used as periodic 20 seconds with a warning to the user 
            disp('No List of Times was Found: Reverting to Periodic Behaviour');
            Distribution{1} = 'P';
            Param1 = 20;
        end 
    end 
    
     if Distribution{1} == 'S'
        % if a list is specified by a simualtion then, read list into vector and then take the
        % difference of the arrival times to calculate the interarrival
        % times t that are requried in a vector List_of_Times
        if exist ([path2userresults,'Upstream_Simulation_Results.csv']) ~= 0
            disp('List of Times Acquired: Reading In Timing Data')
            List_of_Times = csvread([path2userresults,'Upstream_Simulation_Results.csv']);
            List_of_Time_Differences = diff(List_of_Times);
        else 
            % else the list could not be found a a generic fall back case
            % is used as periodic 20 seconds with a warning to the user 
            disp('No List of Times was Found: Reverting to Periodic Behaviour');
            Distribution{1} = 'P';
            Param1 = 20;
        end 
    end 
end % end of if first run cases

%% Generate Times Section Used In Running 

if Distribution{1} == 'L'
        % if a list is specified,take the element which correpsonds to the pallet number
        if pallet_number <= length(List_of_Time_Differences)
            % if the pallet number is within the length of the vector then
            % use that element to give t
            t = List_of_Time_Differences(pallet_number);
        else 
            % at the end of the list add an excessively large value to t
            % such that no further pallets are generated 
            t = 1000000000000000000000000000000;
        end 
end 

if Distribution{1} == 'S'
        % the case where a list is specified by the simulation of an
        % upstream line works the same way as the list mode, but is given a
        % separate case as it may be refiend and need additional code
        if pallet_number <= length(List_of_Time_Differences)
            % if the pallet number is within the length of the vector then
            % use that element to give t
            t = List_of_Time_Differences(pallet_number);
        else 
            % at the end of the list add an excessively large value to t
            % such that no further pallets are generated 
            t = 1000000000000000000000000000000;
        end 
end 


if Distribution{1} == 'P' %Periodic time period
    disp('Periodic')
    t=Param1; %Read period from textscan parameter 1
end

if Distribution{1} == 'N' %Normal time period
    disp('Normal')
    Mean=Param1; %Read mean from textscan
    SD=Param2; %Read standard deviation from textscan
    while(true) %Loops until t is +ve since this is not a valid input
    t = normrnd(Mean,SD); %Generate normally distributed random number
        if t >=4;
          break; %if t is positive break the loop as a number is sufficient 
        end
    end
end % end of normal distribution code 

if Distribution{1} == 'R' %Rectangular distribution
    disp('Rectangular')
    Lower_bound=Param1; %Read lower bound for rectangular distribution
    Upper_bound=Param2; %Read Upper Bound for rectangular distribution
    t= Lower_bound(1)+rand*(Upper_bound(1)-Lower_bound(1)); %Random number between 0 and (Upper_bound - Lower_Bound) plus lower_bound time
end % end of rectangular distribution code 


if Distribution{1} == 'T' %Triangular Distribution
    disp('Triangular')
    xx=0;
    info = textscan(LineSettings{1},'%c%c%f%c%f%c%f');
    % calculate two of the parameters required by the fucntion as the two
    % regions on eigtehr side of the mean 
    aa= Param2-Param1;
    bb= Param3-Param2;
    %Function takes uniform distribution (rand) which generates an area between
    %0 and 1. The xx value at which the cumilative probability under the triangle equals this area is computed.
    %Adding offset to this xx value then produces time t
    hh= 2/(aa+bb);
    AA=rand;
        if AA <= (1/2*aa*hh);
            xx=sqrt((2*aa*AA)/hh);
        end
        if AA > (1/2*aa*hh);
            xx = aa+bb - sqrt(bb*(aa+bb)-2*AA*bb/hh);
        end
    t=xx+Param1; %add on offset
end

