% Global_Controller.m - script which contains the primary running of the
% global controller - may branch out to different cases of controller or
% levels of control. 

% generate the diary function required and print headers including a date
% and time. 
diary([path2eventlog,'Global_Controller.log'])
disp('Running the Global Controller')
time=clock;
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1))];
disp(date)
time=[num2str(time(4)),' : ',num2str(time(5)),' : ',num2str(time(6))];
disp(time)
clear time
clear date

tic ; %start the clock for setup. 

% setup variables 
Failure_Flag = 0; % flag to look for failures of the global controller. 
val_test =0;

% New section to track the amount of data read/written 2/11/12
% variables for amount of sensor data read and written
sensor_data_read_amount =0;
sensor_data_write_amount =0;
% variables for the amount of state data read or recieved. Usually updated
% int eh global read / write scripts.
messages_data_read_amount =0;
messages_data_write_amount =0;
% format for reading state data from files. 
data_read_format = '%s %s %s %s %s %s';

 
%Open master config file
fid = fopen(path2master,'rt');
out = textscan(fid,'%s	%s	%s	%s');
fclose(fid);

% find the number of feed lines - this allows loops to be set to the
% correct length to allow flexible code
ind=strmatch('No_of_Feedlines',out{1},'exact');
Number_of_Feedlines = out{2}(ind);
disp(['The number of feed lines is ',Number_of_Feedlines{1}])
Number_of_Feedlines=str2num(Number_of_Feedlines{1});
% find the number of splitters- this allows loops to be set to the
% correct length to allow flexible code
ind=strmatch('No_of_Splitters',out{1},'exact');
Number_of_Splitters = out{2}(ind);
disp(['The number of splitters is ',Number_of_Splitters{1}])
Number_of_Splitters=str2num(Number_of_Splitters{1});
    
%Open config file
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out = textscan(fid,'%s %s	%s	%s	%s');
%Close file
fclose(fid);

% we need to knwo what each of the units is doing and so we work down the model 
% from upstream assessing the state of each section - we could get this from the
% data input however this method is equivalent and can be done off line. 


% determine the state of the upstream units
ind=strmatch('Upstream',out{1},'exact');
Upstream = out{2}(ind);
UpstreamMode= out{3}(ind);   
if Upstream{1} == '1' 
        disp('Upstream Unit Present')    
        disp(['The priority system is ',UpstreamMode{1},' line Priority']);
        filename_global_instructions ='Global_Instructions_Upstream.txt';
end
 disp('Finsihed Assessing Upstream Status')
 toc
 
% find out what the feed lines are doing and generate the relevant
% variables to determine if the instruction file needs returning 
for index = Number_of_Feedlines:-1:1
    % FIND THE LINE 
        ind = strmatch(['Line',num2str(index)],out{1},'exact');
        % and attempt to eliminate the effects of additional comments
        % placed in the config file by the user by selecting only one
        % entry.
        if length(ind) > 1
            ind=ind(1);
        end 
        % state that we have recognised if a line is running
        if  str2num(out{1,2}{ind,1}) == 1
            str=strcat('Line ',num2str(index),' Running:Tranfer Line Buffer Limit = ',out{4}(ind),' Mainline Buffer = ',out{5}(ind));
        end % end of if line present loop 
        %setup all of the relevant variables and initialise them as
        %appropriate - it is better to do this just in case we use the
        %variables in the if or for statements to prevent MATLAB taking
        %issue if they don't exist. 
        % setup variables to capture the health of each unit in the row. 
        eval(['Error_Correcting_Feed_',num2str(index),'=0;'])
        eval(['Error_Correcting_Transfer_',num2str(index),'=0;'])
        eval(['Error_Correcting_Main_',num2str(index),'=0;'])    
        eval(['Hold_Feed_',num2str(index),'=0;'])
        eval(['Hold_Transfer_',num2str(index),'=0;'])
        eval(['Hold_Main_',num2str(index),'=0;'])
        eval(['Update_Feed_',num2str(index),'=1;'])
        eval(['Update_Transfer_',num2str(index),'=1;'])
        eval(['Update_Main_',num2str(index),'=1;'])
        % setup paths such that we knwo where to write instructiosn to the
        % units to 
        eval(['filepath_feed_',num2str(index),'=[''Global_Instructions_Feed_'',''',num2str(index),''',''.txt''];'])
        eval(['filepath_transfer_',num2str(index),'=[''Global_Instructions_Transfer_'',''',num2str(index),''',''.txt''];'])
        eval(['filepath_main_',num2str(index),'=[''Global_Instructions_Main_'',''',num2str(index),''',''.txt''];'])
        eval(['Mainline_Clear_',num2str(index),'=0;'])
        eval(['Arrival_Status_',num2str(index),'=0;'])
        eval(['Unload_state_',num2str(index),'=0;'])
        eval(['Pallet_Status_',num2str(index),'=0;'])
        eval(['FeedingFlag_',num2str(index),'=0;'])
        eval(['FeedingFlag2_',num2str(index),'=0;']) 
        % note on belt speed - the belt will run at the speed set in the
        % master config file as a default. The value of this flag will
        % increase or decrease the speed by 10% * the value i.e. +1 = +10%
        % , -2 = -20% etc
        eval(['Mainline_Belt_Speed_',num2str(index),'=0;'])
        eval(['Feed_Belt_Speed_',num2str(index),'=0;'])
        eval(['Transfer_Belt_Speed_',num2str(index),'=0;'])
end 
disp('Finished Reading Line data')
toc 
% determtine the action of any splitter units which are attached to the
% line such that we know what they are meant to be doing. 
for index = Number_of_Splitters:-1:1
        ind = strmatch(['Splitter',num2str(index)],out{1},'exact');
        if length(ind) > 1
            ind=ind(1);
        end
        eval(['Splitter',num2str(index),'= out{2}(ind);'])
        if str2num(eval(['Splitter',num2str(index),'{1}'])) == 1
            eval(['Splitter_Mode',num2str(index),' =out{3}(ind);'])
            eval(['ind = strmatch([''PalletCode'',''',num2str(index),'''],out{1});'])
            eval(['PalletCode',num2str(index),' = [out{2}(ind),out{3}(ind),out{4}(ind)];'])
            eval(['ind = strmatch([''ColourCode'',''',num2str(index),'''],out{1});'])
            eval(['ColourCode',num2str(index),' = [out{2}(ind)];'])
            if strcmp(eval(['Splitter_Mode',num2str(index),'{1}']),'Colour') == 1
                str=strcat('Splitter ',num2str(index),' Running:Mode = Colour Detection, Seperation Criteria = ',eval(['ColourCode',num2str(index),'{1}']));
            elseif strcmp(eval(['Splitter_Mode',num2str(index),'{1}']),'Code') == 1
                str=strcat('Splitter ',num2str(index),' Running:Mode = Code Detection, Seperation Criteria = ',eval(['PalletCode',num2str(index),'{1}']),',',eval(['PalletCode',num2str(index),'{2}']),',',eval(['PalletCode',num2str(index),'{3}']));
            end
            disp(str)

        end
end
    disp('Finished Assessing Splitter Status')
    toc 
 
% generate the correct number of rows for the state matrix - if there is an
% upstream pend it onto the end. 

% the state read vectors will be organised thus
% first block = feed units
% second block = transfer units
% third block = mainline units
% append the upstream unit at the end if required 
if Upstream{1} == '1'
    % if the upstream exists we have one  three state evctors for  each
    % feed line plus one for the upstream unit 
    for i = 1:1:((3*Number_of_Feedlines)+1)
        eval(['State_Read_',num2str(i),'= [];']); 
        eval(['Prev_State_Read_',num2str(i),'= [];']);
    end 
    System_Health = zeros(((3*Number_of_Feedlines)+1),1); % contains the system health at the last evaluation
    Previous_System_Health = zeros(((3*Number_of_Feedlines)+1),1); % contains the previous system health for comparison
    length_vector=zeros(((3*Number_of_Feedlines)+1),1); % contains the length of each of the state vectors. 
else
    % else we just have three times the number of feed lines if the
    % upstream unit is not present. 
    for i = 1:1:(3*Number_of_Feedlines)
        eval(['State_Read_',num2str(i),'= [];']); 
        eval(['Prev_State_Read_',num2str(i),'= [];']);
    end 
    System_Health = zeros((3*Number_of_Feedlines),1); % contains the system health at the last evaluation
    Previous_System_Health = zeros((3*Number_of_Feedlines),1); % contains the previous system health for comparison
    length_vector=zeros((3*Number_of_Feedlines),1); % contains the length of each of the state vectors. 
end 

length_vector = [];% vector with the length of each of the statews recived in it. 
% this concludes the setup and so we display a waiting to start message 
disp('Waiting to Start')
toc 

%% wait to start wait for the go file to exist. 
go = exist(path2go); 
while go == 0
    pause(0.1)
    go = exist(path2go); 
end 
% we reset the clock such that all subsequent commands are cloked during
% the time of the run not during the time of the setup.
tic;
disp('Starting')
toc
%% Main Operating Loop 
Time_started_Program = toc;
while go == 2  && Failure_Flag == 0 
% take the readings from the data bus to determine what the units are
% doing. 

disp('Reading in the Data for the Feed Units')
toc 
for i = 1:1:Number_of_Feedlines
    disp(['Attempting to Read The State of Feed Unit ',num2str(i)])
        filename_readbus = ['Feed_Unit_',num2str(i),'_Datastream.txt'];
        path2readfile_databus = [path2databus,filename_readbus];
        if exist(path2readfile_databus) ~= 0
         fid = fopen(path2readfile_databus,'r');
         out=textscan(fid,data_read_format);
         fclose(fid);
         if isempty(out{1,1})
             disp('Data is currently writing-use old value')
         else
             % section to retrieve the flag data 
             ind=strmatch('Flag',out{1});
             for m=1:1:length(ind)
                 eval([out{1,2}{ind(m),1},'=',num2str(out{1,3}{ind(m),1}),';']);
             end
             % section to retrieve the state data 
             ind = strmatch('State',out{1});
             if isempty(ind) ~= 1
                 for j=2:1:6
                     if isempty(out{1,j}) ~=1
                         if isempty(out{1,j}{ind,1}) ~=1
                            State_Read =[State_Read,str2num(out{1,j}{ind,1})];
                         end
                     end 
                 end
             else
                 State_Read =[0,0]; 
             end
         end 
          eval(['State_Read_',num2str(i),'=State_Read'])
        else 
            disp('No Data could Be Read- File Did Not Exist')
        end
         clear State_Read
         State_Read=[]; 
end 
disp('Reading In The Data For The Transfer Units')
toc 

% harevest all of the data from the data bus - Transfer Units 
    for i = 1:1:Number_of_Feedlines
        disp(['Attempting to Read The State of Transfer Unit ',num2str(i)])
        filename_readbus = ['Transfer_Unit_',num2str(i),'_Datastream.txt'];
        path2readfile_databus = [path2databus,filename_readbus];
        if exist(path2readfile_databus) ~= 0
             fid = fopen(path2readfile_databus,'r');
             out=textscan(fid,data_read_format);
             fclose(fid);
             if isempty(out{1,1})
                 disp('Data is currently writing-use old value')
             else
                 % section to retrieve the flag data 
                 ind=strmatch('Flag',out{1});
                 for m=1:1:length(ind)
                     eval([out{1,2}{ind(m),1},'=',num2str(out{1,3}{ind(m),1}),';']);
                 end
                 % section to retrieve the state data 
                 ind = strmatch('State',out{1});
                 if isempty(ind)~=1
                     for j=2:1:5
                         if isempty(out{1,j}) ~= 1
                             if isempty(out{1,j}{ind,1}) ~= 1
                                State_Read =[State_Read,str2num(out{1,j}{ind,1})];
                             end
                         end 
                     end
                 else
                     State_Read =[0,0]; 
                 end
             end 
                eval(['State_Read_',num2str(i+Number_of_Feedlines),'=State_Read'])
        else 
            disp('No Data could Be Read- File Did Not Exist')
        end
            clear State_Read
            State_Read=[]; 
    end 

    disp('Reading In The Data For The Mainline Units')
    toc 
    
% harevest all of the data from the data bus - Mainline Units 
    for i = 1:1:Number_of_Feedlines
        disp(['Attempting to Read The State of Mainline Unit ',num2str(i)])
        filename_readbus = ['Mainline_Unit_',num2str(i),'_Datastream.txt'];
        path2readfile_databus = [path2databus filename_readbus];
        if exist(path2readfile_databus) ~= 0
         fid = fopen(path2readfile_databus,'r');
         out=textscan(fid,data_read_format);
         fclose(fid);
         if isempty(out{1,1})
             disp('Data is currently writing-use old value')
         else
             % section to retrieve the flag data 
             ind=strmatch('Flag',out{1});
             for m=1:1:length(ind)
                 eval([out{1,2}{ind(m),1},'=',num2str(out{1,3}{ind(m),1}),';']);
             end
                 % section to retrieve the state data 
                 ind = strmatch('State',out{1});
                 if isempty(ind) ~= 1
                     for j=2:1:5
                         if isempty(out{1,j}) ~= 1
                             if isempty(out{1,j}{ind,1}) ~= 1
                                State_Read =[State_Read,str2num(out{1,j}{ind,1})];
                             end
                         end 
                     end
                 else
                    State_Read =[0,0]; 
                 end
         end 
         eval(['State_Read_',num2str(i+Number_of_Feedlines+Number_of_Feedlines),'=State_Read'])
        else 
            disp('No Data could Be Read- File Did Not Exist')
        end
         clear State_Read
         State_Read=[]; 
    end 
   disp('Compiling a State Matrix')
   toc 
   System_State =[];
% compile a state matrix 
for k= 1:1:(3*Number_of_Feedlines)
         if exist(['State_Read_',num2str(k)],'var') ~= 0
              length_vector(k)=eval(['length(State_Read_',num2str(k),')']);
              if  length_vector(k) == 2
                  System_State(k,1)=eval(['State_Read_',num2str(k),'(',num2str(1),')']);
                  System_State(k,5)=eval(['State_Read_',num2str(k),'(',num2str(2),')']);
              elseif length_vector(k) == 3
                  System_State(k,1)=eval(['State_Read_',num2str(k),'(',num2str(1),')']);
                  System_State(k,3)=eval(['State_Read_',num2str(k),'(',num2str(2),')']);
                  System_State(k,5)=eval(['State_Read_',num2str(k),'(',num2str(3),')']);
              elseif length_vector(k) == 4
                  System_State(k,1)=eval(['State_Read_',num2str(k),'(',num2str(1),')']);
                  System_State(k,2)=eval(['State_Read_',num2str(k),'(',num2str(2),')']);
                  System_State(k,3)=eval(['State_Read_',num2str(k),'(',num2str(3),')']);
                  System_State(k,5)=eval(['State_Read_',num2str(k),'(',num2str(4),')']);
              elseif length_vector(k) == 5
                  for l = 1:1:5
                    System_State(k,l) = eval(['State_Read_',num2str(k),'(',num2str(l),')']);
                  end
              elseif length_vector(k) == 0 
                  disp('The State Vector Is Empty')
                 System_State(k,:) = [0 0 0 0 0];   
              end
         else 
             disp('No State vector Exists')
             length_vector(k) = 0; 
             System_State(k,:) = [0 0 0 0 0]; 
         end 
end
disp('The System State Is')
disp(System_State)
%%
disp('Beginning to Make State Decisions')
toc 
for index = Number_of_Feedlines:-1:1
    % the error section takes priority 
    if eval(['Error_Correcting_Transfer_',num2str(index)]) == 1
        eval(['Hold_Feed_',num2str(index),'=1;'])
    else 
        eval(['Hold_Feed_',num2str(index),'=0;'])
    end 
    if eval(['Error_Correcting_Feed_',num2str(index)]) == 1
        eval(['Hold_Transfer_',num2str(index),'=1;'])
    else   
        eval(['Hold_Transfer_',num2str(index),'=0;'])
    end 
        eval(['Hold_Main_',num2str(index),'=0;'])
        eval(['Update_Feed_',num2str(index),'=1;'])
        eval(['Update_Transfer_',num2str(index),'=1;'])
        eval(['Update_Main_',num2str(index),'=1;'])
end 

if toc > 20 && val_test == 0 
disp('Messing With Line Speeds')
toc 
        for index = Number_of_Feedlines:-1:1
            eval(['Mainline_Belt_Speed_',num2str(index),'=-1;'])
            eval(['Feed_Belt_Speed_',num2str(index),'=1;'])
            eval(['Transfer_Belt_Speed_',num2str(index),'=2;'])
        end 
        val_test = 1;
end 

%% Sectio to Perform the Writing Operation. 
disp('Writing')
toc 
Global_Controller_Write; 
disp('Finished Writing')
toc


% section to keep running 
go = exist(path2go);
end 
Time_Finished_Program = toc;
%% Shutdown Section


% detected that stop file exists and that line needs to shutdown. 
disp('Stop Signal Detected- Shutting Down');
toc
% New section to track the amount of data read/written 2/11/12
% as this is the global controller no sensor data has been written or read
% by the unit so we reset it just to make sure. 
sensor_data_read_amount =0;
sensor_data_write_amount =0;

% display some text for the log files showing what data was sent or
% recieved. 
disp(['The Total Sensor data Read was ',num2str(sensor_data_read_amount),' bytes'])
disp(['The Total Sensor data Written was ',num2str(sensor_data_write_amount),' bytes'])
disp(['The Total Message data Read was ',num2str(messages_data_read_amount),' bytes'])
disp(['The Total Message data Written was ',num2str(messages_data_write_amount),' bytes'])
disp(['In ',num2str((Time_Finished_Program-Time_started_Program)),' seconds'])

% shutdown the instance of matlab. 
quit;