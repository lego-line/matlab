% Generate_Upstream_Times
% can be called to generate a user file which has the output times from an
% arbitrary line, which can be fed back into the upstream unit of legoline
% in order to give a simualtion of the line as part of a larger factory. 
%
% the script requires the user to give it a .txt file of any name, which
% contaisn a list of the various upstream lines and the associated inter
% arrival times. 
% in the format
%
% No_of_Feedlines ##
%
% ControlLine1 Dist P1 P2 P3
% ControlLine2 Dist P1 P2 P3
% where Dist is the distribution letter
% P1,P2,P3 are the parameters to define the distirbuition, given in
% seconds

 %% Collect the Data From a File 

% setup variables
clear all
load Path_File
sep=filesep;
diary([pwd sep 'Simualtion.log'])

path2gui =[pwd sep 'Code' sep 'GUI' sep];
% start a debug file
Element_Difference = []; % this stores the difference between the elemetns of the output vector and is used in modelling the pallet separation 
%performed by a splitter which in turn would prevent the upstream unit overloading itslef instnstantly
data_text = []; % a cell array to store the text data supplied by the user or read in from a text file from which operating parameters ae extracted 
Stop_Looping = 0; % a variable used to control the action of a while loop which simualtes the splitter 

Transfer_Line_Delay_Min = 16;% amount of time pallet takes from the entry point until it enters the mainline
Transfer_Line_Delay_Mode = 16;% based on a triangular distribution 
Transfer_Line_Delay_Max = 16; % with these three parameters 

Current_Line_Delay =[]; % variable to store the current value of transfer line time in 
Mainline_Delay = 19; %amount of time for the pallet to traverse one mainline section - assume this is static for simplicity 
Current_Mainline_Delay = Mainline_Delay ; % variable to store the current value of maineline delay time in 
Exiting_Times = []; % variable to write the exiting times into 

%% The User Interface End Of Things 
% in this case we first prompt the user to enter a time to run over via a
% simple pop up window this should coincide with the run time of the model.
% Long times should be avoided 
timer_cell = inputdlg({'Enter the Number of Minutes to Run'},'Legoline Timer Input',1,{'3'});
Max_Time = (str2num(timer_cell{1}))* 60;
% present the suer with a chocie of how to enter the data or to close the
% simualtion if they have changed their mind, the chocei are to select a
% pseudo config file with the properties of the imaginary units feed time
% or to sue an interface like that used to generate the config file. 
selection = questdlg('How Would You Like To Enter Data?','Legoline Sumualtino Dialogue','Provide Config File','Enter Data Manually','Close Simualtion','Enter Data Manually'); 
switch selection
    case 'Provide Config File'
        % prompt the user to direct to a file which looks like a config via
        % a file browser window 
        [FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.txt', 'Please Select a Feed Schedule File');
        if FILTERINDEX == 1
                % if the file is accepted correctly get its location from
                % the window and open it for reading 
                data_file_location = [PATHNAME,FILENAME];
                disp('Data File Accepted')
                % read the text from the file into a buffer
                data_id = fopen(data_file_location,'r');
                data_text = textscan(data_id,'%s %s %s %s %s');
                fclose(data_id);
                pause(0.1)
                % check the number of feed lines has been provided 
                ind=strmatch('No_of_Feedlines',data_text{1});
                if isempty(ind) == 1
                    % tell the user that the file provided was not correct and quit 
                    disp('The File Provided Did Not Contain Suitable Information - No List Generated')
                else 
                    % else read the data out of the file into a more useful format
                    No_of_Feedlines = str2num(data_text{1,2}{ind,1});
                    for I = 1:1:No_of_Feedlines
                        set = strmatch(['ControlLine',num2str(I)],data_text{1});
                        eval(['Line_',num2str(I),'_Distribution=data_text{1,2}{',num2str(set),',1};'])
                        eval(['Line_',num2str(I),'_Param1=str2num(data_text{1,3}{',num2str(set),',1});'])
                        eval(['Line_',num2str(I),'_Param2=str2num(data_text{1,4}{',num2str(set),',1});'])
                        eval(['Line_',num2str(I),'_Param3=str2num(data_text{1,5}{',num2str(set),',1});'])
                        eval(['Arrival_Times_Line_',num2str(I),'=[];']);% variable to store the vector of feed times in 
                        eval(['Last_Arrival_Time_Line_',num2str(I),'=0;']);% variable to store the time of the last arrival 
                        disp(['Added Line ',num2str(I),' Data'])
                    end 
                    % debug comment to show successful operation 
                    disp('The List of Times was Generated Successfully')
                end 
        else
                % else the oepration failed to run, quit the instance of
                % matlab due to error 
                disp('Operation Aborted by User')
                bquit
        end % end of file grabbing
        disp('File Reading Completed')
        % end of case where user opts to provide a file 
    case 'Enter Data Manually'
        % case t open a GUi to allow the user to input the desired data
        % graphiclally. 
        
       % open a text dialogue to determine the number of lines the user is
       % interested in simulating. 
       number_cell = inputdlg({'Enter the Number of Lines to Simulate'},'Legoline Simulation Input',1,{'3'});
       No_of_Feedlines = (str2num(number_cell{1}));
       
       % create a location for the data file to go into 
       Data_File_Location = [pwd,sep,'Temporary_Upstream_Config.txt'];
       Handle_figure = figure(1001);
       
       % open the GUI function.
       Upstream_Simulation_Interface(0,0,Data_File_Location,No_of_Feedlines,Handle_figure)
       uiwait(Handle_figure); 
       
       % the GUi will generate a results file in the location, from ehre
       % the process is the same as the file input one
       % open the file 
       data_file_location = Data_File_Location;
       disp('Data File Accepted')
       % read the text from the file into a buffer
       data_id = fopen(data_file_location,'r');
       data_text = textscan(data_id,'%s %s %s %s %s');
       fclose(data_id);
       pause(0.1)
       % check the number of feed lines has been provided 
       ind=strmatch('No_of_Feedlines',data_text{1});
       if isempty(ind) == 1
           % tell the user that the file provided was not correct and quit 
           disp('The File Provided Did Not Contain Suitable Information - No List Generated')
       else 
           % else read the data out of the file into a more useful format. 
           No_of_Feedlines = str2num(data_text{1,2}{ind,1});
           for I = 1:1:No_of_Feedlines
               set = strmatch(['ControlLine',num2str(I)],data_text{1});
               eval(['Line_',num2str(I),'_Distribution=data_text{1,2}{',num2str(set),',1};'])
               eval(['Line_',num2str(I),'_Param1=str2num(data_text{1,3}{',num2str(set),',1});'])
               eval(['Line_',num2str(I),'_Param2=str2num(data_text{1,4}{',num2str(set),',1});'])
               eval(['Line_',num2str(I),'_Param3=str2num(data_text{1,5}{',num2str(set),',1});'])
               eval(['Arrival_Times_Line_',num2str(I),'=[];']);% variable to store the vector of feed times in 
               eval(['Last_Arrival_Time_Line_',num2str(I),'=0;']);% variable to store the time of the last arrival 
               disp(['Added Line ',num2str(I),' Data'])
           end
           disp('The List of Times was Generated Successfully')
       end 
    case 'Close Simualtion'
        quit;
end % end switch 
% save the output in cas a user is interested in retrieveing it later and
% for debugging purposes. 
save('Data_Out.mat','data_text')
%% Start generating each individual distribution 
% in this the rpemise aims to simualte the arrival times of each line.
% The profcess works
% at a time T we check the interarrival time of each line t
% if T - Last_Arrival_Time > t then a new pallet arrives and replaces last
% arrival time
% we loop this over the simulation time generating arrival vectors for each
% of the feed lines, thus we know all arrivals into the system 
% from this we simualte their process through the system as it was
% predicetd using a simio experiment to fidn the tarnsit time based on some
% observed parameters statisticlally. (We assume the merges are linear and
% hecne dsitributiosn proceed through a series of time delays where the
% length of the delay is itself a random parameter as per standrad
% industrial modelling. 

% loop over the time interval in 0.5 second steps checking if the current
% time coincidfes witht he time a palelt should arrive at the unit 
for time = 0:0.5:Max_Time
    % a debug line 
    disp(['Starting Evaluating The State at Time  ',num2str(time)])
    for J = 1:1:No_of_Feedlines % loop over all of the feed lines       
        % generate the interarrival time t dependant on the distribution,
        % this is a modified version of the get_time script used normally 
        if eval(['Line_',num2str(J),'_Distribution'])== 'P'
                % interarrival time t is periodic 
                t = eval(['Line_',num2str(J),'_Param1']);
        elseif eval(['Line_',num2str(J),'_Distribution'])== 'N'
                % normal inter arrival time generated 
                 Mean=eval(['Line_',num2str(J),'_Param1']);
                 SD=eval(['Line_',num2str(J),'_Param2']);
                    while(true) %Loops until t is +ve since this is not a valid input
                        t = normrnd(Mean,SD); %Generate normally distributed random number
                        if t >=4;
                             break; %if t is positive break the loop
                        end
                    end
        elseif eval(['Line_',num2str(J),'_Distribution'])== 'T'
                % trinagualr inter-arrival tme generated 
                xx=0;
                aa= eval(['Line_',num2str(J),'_Param2'])-eval(['Line_',num2str(J),'_Param1']);
                bb= eval(['Line_',num2str(J),'_Param3'])-eval(['Line_',num2str(J),'_Param2']);
                hh= 2/(aa+bb);
                AA=rand;
                if AA <= (1/2*aa*hh);
                        xx=sqrt((2*aa*AA)/hh);
                end
                if AA > (1/2*aa*hh);
                    xx = aa+bb - sqrt(bb*(aa+bb)-2*AA*bb/hh);
                end
                t=xx+eval(['Line_',num2str(J),'_Param1']); %add on offset
        elseif eval(['Line_',num2str(J),'_Distribution'])== 'R'
                % rectangualr interarrival time 
                Lower_bound=eval(['Line_',num2str(J),'_Param1']); %Read lower bound for rectangular distribution
                Upper_bound=eval(['Line_',num2str(J),'_Param2']); %Read Upper Bound for rectangular distribution
                t= Lower_bound(1)+rand*(Upper_bound(1)-Lower_bound(1)); %Random number between 0 and (Upper_bound - Lower_Bound) plus lower_bound time
        end 

        % based on the current time, the time of the last arrival and the
        % interarrival time calculate if the next arrival is due yet, f so
        % update the last arrival time for the line such that the
        % calculation time can be repeated. 
        if (time-eval(['Last_Arrival_Time_Line_',num2str(J)]))>= t % calulate if the elapsed interval between pallets is greated than the permitted interval 
                eval(['Arrival_Times_Line_',num2str(J),'=[Arrival_Times_Line_',num2str(J),';time];']);
                eval(['Last_Arrival_Time_Line_',num2str(J),'= time;']) ; 
        end% 
                % debug comments 
                disp(['Finished Evaluating The Current Time For Line ',num2str(J)])
    end % end of a particualr line evaulation
            % debug commetns 
            disp(['Finished Evaluating The State at Time  ',num2str(time)])
end % end of a time loop 

% a simple command to dipaly each of the generated arrival times for
% convenience 
for J = 1:1:No_of_Feedlines
    eval(['Arrival_Times_Line_',num2str(J)])
end

disp('Finished Generating Individual Feed Times')
%% Modify the Distributions such that they are now the distribution at the end of the line - I.E. Appropriately delayed 


for I = 1:1:No_of_Feedlines
        % in this case we use a stanard model to represent the delay
        % process as a triangualr distribution with experimentally measured
        % characteristics This is a standard process model for unknown
        % processes, and tries to capture some of the variability caused by
        % differing buffer states requiring slightly different trasfer
        % times as well as potential errors which delay the transfer /
        % merge processes. 
             
        % generate a triangular time based on the experimetnally determined
        % distribution, this is simialr to that used in get time and can be
        % shown to generate an apprprite value of t, the delay time. 
        xx=0;
        aa= Transfer_Line_Delay_Mode-Transfer_Line_Delay_Min;
        bb= Transfer_Line_Delay_Max-Transfer_Line_Delay_Mode;
        hh= 2/(aa+bb);
        AA=rand;
        if AA <= (1/2*aa*hh);
                xx=sqrt((2*aa*AA)/hh);
        end
        if AA > (1/2*aa*hh);
            xx = aa+bb - sqrt(bb*(aa+bb)-2*AA*bb/hh);
        end
        Current_Line_Delay=xx+Transfer_Line_Delay_Min; %add on offset
        
        % add the line delay from the process to the arrival time of the
        % pallet to get the transit time through the system I.E. turn an
        % arrival time into an exiting output 
        eval(['Arrival_Times_Line_',num2str(I),'=Arrival_Times_Line_',num2str(I),'+ Current_Line_Delay + (Current_Mainline_Delay*',num2str(I),');'])
        disp(['Finished Evaluating The Additional Time For Line ',num2str(I)])
end 

% for J = 1:1:No_of_Feedlines
%     eval(['Arrival_Times_Line_',num2str(J)])
% end
disp('Finished Adding Extra Time')



%% Concatenate Vectors and Shift Any Duplicated Results so they are not at the same time

% loop over all vectors to create a composite vector of output times I.E. a
% stacked vector with all output times but not sorted. 
disp('Beginning Vector Concatenation of Times')
for I = 1:1:No_of_Feedlines
    Exiting_Times = [Exiting_Times;eval(['Arrival_Times_Line_',num2str(I)])];
    disp(['Added Line ',num2str(I),' Data to the list'])
end 
disp('Finished Vector Concatenation of Times')

% sort the vector into order such that it represents a time progression 
Exiting_Times = sort(Exiting_Times);

% remove duplicate times 
while Stop_Looping == 0
    % take element differences in the vector to find out if any times are
    % the same 
    Element_Difference = diff(Exiting_Times);
    % find the indices of all elements of the vector which are techincially
    % at the same time (the 2 is the time needed to move pallets off the
    % upstream unit) 
    [Non_Zero_Indices,C,V] = find(Element_Difference < 2);
    if isempty(Non_Zero_Indices) == 0
        % if there are some indices which indicate pallets owuld occur at
        % the same time shirt them by the splitter seprataion of apllets
        % interval to make them adjacent events not coincident ones which
        % would cause failure
        Exiting_Times(Non_Zero_Indices+1)= Exiting_Times(Non_Zero_Indices+1)+2;
    else 
        % else the number of non zero entreis is the same a the lngth of
        % the vector, I.E. there are no repeat measurements therefore stop
        % the loop as duplictes have been removed 
        Stop_Looping = 1;
    end 
end 
disp('Duplicate Times Removed')
% write csv file to the location required for it 
csvwrite([path2userresults,'Upstream_Simulation_Results.csv'],Exiting_Times); % write out the csv file required and stop MATLAB
quit