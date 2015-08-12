% script to draw the sctructure of the line and keep the status up to date 
% setup section - variables 


System_State = zeros(9,5); % contaisn the system state at the last evaluation
Previous_System_State = zeros(9,5);% contains the last known system state 
System_Health = zeros(9,1); % contaisn the system health at the last evaluation
Previous_System_Health = zeros(9,1); % contains the previous system health for comparison
length_vector=zeros(9,1); % contains the length of each of the state vectors. 

% generate a state read variable and a previous state read variable for
% each case such that if a piece of data is temporarily missing we can fill
% it in. They default to empty. 
for i = 1:1:9
          eval(['State_Read_',num2str(i),'=[];'])
          eval(['PrevState_Read_',num2str(i),'= State_Read_',num2str(i),';'])
end 

% setup the varibales requried for the file oeprations such as the state
% read and the tabular format to extract. 
data_read_format = '%s %s %s %s %s %s';
clear State_Read
State_Read=[];

% setup up some variables for colours of things which make them easy to
% change if required. 
colour_matrix =[0.8125,0.6328,0.5586,0.4023,0.6992;0.9258,0.7266,0.6562,0.5469,0.7070;0.8672,0.6875,0.6055,0.5430,0.5598]';
% colour codes for the units
Unit_Good =[0.3451,0.9294,0.3922];
Unit_Error_Correct = 'r';
Unit_Off = colour_matrix(2,:);
% Colour Codes for the states
State_Running_Main = 'm';
State_Full_Feed ='b';
State_Full_Transfer = 'k'; 
State_Empty_Feed ='g';
State_Off = colour_matrix(2,:);
% for the overall screen colour. 
Picture_background =colour_matrix(3,:);

% perform initial setup of the screen 
% Close any open figures and setup our new figure for the state draw. 
close all; 
figure_handle = figure(10000);
set(figure_handle,'Visible','on','Numbertitle','off','MenuBar','none','color',Picture_background,'Name','Legoline Monitoring Interface','Position',[500,50,800,600]);

% create all of the required panels to represent the units 
Feed_1_Panel = uipanel('Parent',figure_handle,'Title','Feed 1','BackgroundColor','w','Position',[0.65,0.6,0.1,0.35]);
Feed_2_Panel = uipanel('Parent',figure_handle,'Title','Feed 2','BackgroundColor','w','Position',[0.35,0.6,0.1,0.35]);
Feed_3_Panel = uipanel('Parent',figure_handle,'Title','Feed 3','BackgroundColor','w','Position',[0.05,0.6,0.1,0.35]);
Transfer_1_Panel = uipanel('Parent',figure_handle,'Title','Transfer 1','BackgroundColor','w','Position',[0.65,0.25,0.1,0.35]);
Transfer_2_Panel = uipanel('Parent',figure_handle,'Title','Transfer 2','BackgroundColor','w','Position',[0.35,0.25,0.1,0.35]);
Transfer_3_Panel = uipanel('Parent',figure_handle,'Title','Transfer 3','BackgroundColor','w','Position',[0.05,0.25,0.1,0.35]);
Main_1_Panel = uipanel('Parent',figure_handle,'Title','Main 1','BackgroundColor','w','Position',[0.65,0.1,0.3,0.15]);
Main_2_Panel = uipanel('Parent',figure_handle,'Title','Main 2','BackgroundColor','w','Position',[0.35,0.1,0.3,0.15]);
Main_3_Panel = uipanel('Parent',figure_handle,'Title','Main 3','BackgroundColor','w','Position',[0.05,0.1,0.3,0.15]);

% Transfer 1 State Indictaors. 
Transfer_1_b = uipanel('Parent',Feed_1_Panel,'BackgroundColor','w','Position',[0.05,0.1,0.45,0.2]);
Transfer_1_c = uipanel('Parent',Transfer_1_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.65,0.45,0.2]);
Transfer_1_d = uipanel('Parent',Transfer_1_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.35,0.45,0.2]);
Transfer_1_e = uipanel('Parent',Transfer_1_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.05,0.45,0.2]);

% Transfer 3 State Indictaors. 
Transfer_2_b = uipanel('Parent',Feed_2_Panel,'BackgroundColor','w','Position',[0.05,0.1,0.45,0.2]);
Transfer_2_c = uipanel('Parent',Transfer_2_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.65,0.45,0.2]);
Transfer_2_d = uipanel('Parent',Transfer_2_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.35,0.45,0.2]);
Transfer_2_e = uipanel('Parent',Transfer_2_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.05,0.45,0.2]);

% Transfer 3 State Indictaors. 
Transfer_3_b = uipanel('Parent',Feed_3_Panel,'BackgroundColor','w','Position',[0.05,0.1,0.45,0.2]);
Transfer_3_c = uipanel('Parent',Transfer_3_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.65,0.45,0.2]);
Transfer_3_d = uipanel('Parent',Transfer_3_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.35,0.45,0.2]);
Transfer_3_e = uipanel('Parent',Transfer_3_Panel,'Title','','BackgroundColor','w','Position',[0.05,0.05,0.45,0.2]);

% Feed_1 State Indicators
Feed_1_a = uipanel('Parent',Feed_1_Panel,'BackgroundColor','w','Position',[0.5,0.7,0.9,0.2]);
Feed_1_b = uipanel('Parent',Feed_1_Panel,'BackgroundColor','w','Position',[0.5,0.1,0.45,0.2]);
Feed_1_c = uipanel('Parent',Transfer_1_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.65,0.45,0.2]);
Feed_1_d = uipanel('Parent',Transfer_1_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.35,0.45,0.2]);
Feed_1_e = uipanel('Parent',Transfer_1_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.05,0.45,0.2]);

% Feed_2 State Indicators
Feed_2_a = uipanel('Parent',Feed_2_Panel,'BackgroundColor','w','Position',[0.5,0.7,0.9,0.2]);
Feed_2_b = uipanel('Parent',Feed_2_Panel,'BackgroundColor','w','Position',[0.5,0.1,0.45,0.2]); 
Feed_2_c = uipanel('Parent',Transfer_2_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.65,0.45,0.2]);
Feed_2_d = uipanel('Parent',Transfer_2_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.35,0.45,0.2]);
Feed_2_e = uipanel('Parent',Transfer_2_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.05,0.45,0.2]);

% Feed_3 State Indicators
Feed_3_a = uipanel('Parent',Feed_3_Panel,'BackgroundColor','w','Position',[0.5,0.7,0.9,0.2]);
Feed_3_b = uipanel('Parent',Feed_3_Panel,'BackgroundColor','w','Position',[0.5,0.1,0.45,0.2]);
Feed_3_c = uipanel('Parent',Transfer_3_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.65,0.45,0.2]);
Feed_3_d = uipanel('Parent',Transfer_3_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.35,0.45,0.2]);
Feed_3_e = uipanel('Parent',Transfer_3_Panel,'Title','','BackgroundColor','w','Position',[0.5,0.05,0.45,0.2]);

% Main_1 State Indicators
Main_1_a = uipanel('Parent',Main_1_Panel,'BackgroundColor','w','Position',[0.05,0.05,0.15,0.9]);
Main_1_X = uipanel('Parent',Main_1_Panel,'BackgroundColor','w','Position',[0.30,0.05,0.15,0.9]);
Main_1_Y = uipanel('Parent',Main_1_Panel,'BackgroundColor','w','Position',[0.55,0.05,0.15,0.9]);
Main_1_Z = uipanel('Parent',Main_1_Panel,'BackgroundColor','w','Position',[0.80,0.05,0.15,0.9]);

% Main_2 State Indicators
Main_2_a = uipanel('Parent',Main_2_Panel,'BackgroundColor','w','Position',[0.05,0.05,0.15,0.9]);
Main_2_X = uipanel('Parent',Main_2_Panel,'BackgroundColor','w','Position',[0.30,0.05,0.15,0.9]);
Main_2_Y = uipanel('Parent',Main_2_Panel,'BackgroundColor','w','Position',[0.55,0.05,0.15,0.9]);
Main_2_Z = uipanel('Parent',Main_2_Panel,'BackgroundColor','w','Position',[0.80,0.05,0.15,0.9]);

% Main_3 State Indicators
Main_3_a = uipanel('Parent',Main_3_Panel,'BackgroundColor','w','Position',[0.05,0.05,0.15,0.9]);
Main_3_X = uipanel('Parent',Main_3_Panel,'BackgroundColor','w','Position',[0.30,0.05,0.15,0.9]);
Main_3_Y = uipanel('Parent',Main_3_Panel,'BackgroundColor','w','Position',[0.55,0.05,0.15,0.9]);
Main_3_Z = uipanel('Parent',Main_3_Panel,'BackgroundColor','w','Position',[0.80,0.05,0.15,0.9]);

% Draw the Key
Key_Panel = uipanel('Parent',figure_handle,'Title','Key','BackgroundColor',colour_matrix(1,:),'Position',[0.8,0.25,0.2,0.70]);
% key items for a unit 
Key_1 = uipanel('Parent',Key_Panel,'BackgroundColor',Unit_Good,'Position',[0.05,0.85,0.25,0.1]);
Key_2 = uipanel('Parent',Key_Panel,'BackgroundColor',Unit_Error_Correct,'Position',[0.05,0.75,0.25,0.1]);
Key_3 = uipanel('Parent',Key_Panel,'Title','','BackgroundColor',Unit_Off,'Position',[0.05,0.65,0.25,0.1]);

% key items for the state 
Key_4 = uipanel('Parent',Key_Panel,'Title','','BackgroundColor',State_Off,'Position',[0.05,0.45,0.25,0.1]);
Key_5 = uipanel('Parent',Key_Panel,'Title','','BackgroundColor',State_Running_Main,'Position',[0.05,0.35,0.25,0.1]);
Key_6 = uipanel('Parent',Key_Panel,'Title','','BackgroundColor',State_Empty_Feed,'Position',[0.05,0.25,0.25,0.1]);
Key_7 = uipanel('Parent',Key_Panel,'Title','','BackgroundColor',State_Full_Feed,'Position',[0.05,0.15,0.25,0.1]);
Key_8 = uipanel('Parent',Key_Panel,'Title','','BackgroundColor',State_Full_Transfer,'Position',[0.05,0.05,0.25,0.1]);

% add the text comments 
KT1 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.85 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','UnitRunning Without Error');
KT2 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.75 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','Unit Running With Error');
KT3 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.65 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','Unit Not Running');
KT4 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.45 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','State Position Not Available');
KT5 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.35 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','Mainline State Running Continously');
KT6 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.25 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','State Unoccupied');
KT7 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.15 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','State Occupied Feed or Main');
KT8 = uicontrol(Key_Panel,'style','tex','units','normal','position',[0.35 0.05 0.6 0.1],'backgroundcolor',colour_matrix(1,:),'String','State Occupied Transfer');

% find some key variables for the first time. 
Run_Continue = exist(path2rundrawingY);

% we use this go vs previous go to trigger a redraw of the screen
go = exist(path2go); 
previous_go = go; 

pause(0.05)    


%The main operations loop, run continuously whislt the specific Go file
%exists else stop the loop and quit the instance of matlab 
while Run_Continue ~=0

  if isempty( findobj('type','figure','name','Legoline Monitoring Interface'))
      % if teh user closes the figure window then we shutdown the instance
      % as it is no longer required. 
       if exist(path2rundrawingY) ~= 0
           movefile(path2rundrawingY,path2rundrawingN)
       end
       quit
   end    
    
% if The line is running we want to update the window, else we don't to save on processing power.     
if go == 2  
    
    % if the previous go was zero and the current go is one then we have
    % started a new run and hence we wish to reset all of the avirables to
    % empty such that we can show that all the units are off - at the end
    % of a run the final state is displayed until the start of the next run
    % to allow the user to analyse it. 
    
    % the unit holds an empty state vector until some satte dat is recived
    % - once this has happened some state dat is always present in the
    % vector - if the ere is none in the current file as it is being
    % written then the previous dta is substituted back in to ensure that
    % the  grey screen bug whereby a units data is temporarily not recived
    % does not happen - this causes annoying flicker. 
    
    if previous_go == 0
        for i = 1:1:9
          eval(['State_Read_',num2str(i),'=[];'])
          eval(['PrevState_Read_',num2str(i),'= State_Read_',num2str(i),';'])
        end   
    end 
    previous_go = go; 
    
    
    
% harvest all of the data from the data bus - Feed Units 
%% Cell to Collect all of the data from the network bus and store it 
% loop over the lines of interest, i.e. only the first three due to the
% standard model being of three lines. 
%% Fed Unit Case
    for i = 1:1:3
        % determine the file path. 
        filename_readbus = ['Feed_Unit_',num2str(i),'_Datastream.txt'];
        path2readfile_databus = [path2databus,filename_readbus];
        % if the file exists. 
        if exist(path2readfile_databus) ~= 0 
          % if the file exists open it and scan for text 
         fid = fopen(path2readfile_databus,'r');
         out=textscan(fid,data_read_format);
         fclose(fid);
         if isempty(out{1,1})
             % if the file is empty then it is still being edited by the unit
             % generating it 
             disp('Data is currently writing-use old value')
             eval(['State_Read_',num2str(i),'=Prev_State_Read_',num2str(i),';'])
             eval(['System_Health(',num2str(i),')=Prev_System_Health(',num2str(i),');'])
         else
             % else the file contains useful data 
             % section to retrieve the flag data 
             ind=strmatch('Flag',out{1});
             for m=1:1:length(ind)
                 eval([out{1,2}{ind(m),1},'=',num2str(out{1,3}{ind(m),1}),';']);
             end
             eval(['System_Health(',num2str(i),')=Error_Correcting_Feed_',num2str(i),';'])
             % section to retrieve the state data 
             ind = strmatch('State',out{1});
             if isempty(ind) ~= 1
                 % if a state exists then we read it in 
                 for j=2:1:6 % loop over the state
                     if isempty(out{1,j}) ~=1
                         % read it in by checking if each element exists
                         % and appending it if st does to build up the
                         % correct length vector. 
                         if isempty(out{1,j}{ind,1}) ~=1
                            State_Read =[State_Read,str2num(out{1,j}{ind,1})];
                         end % end of second if 
                     end % end of if the first element 
                 end % end of state loop 
             else
                 % else use the previous value of state read when one does
                 % not exist. 
                 eval(['State_Read=Prev_State_Read_',num2str(i),';'])
             end
            % update the output vectors based on what found in file. 
            eval(['State_Read_',num2str(i),'=State_Read;'])
            eval(['System_Health(',num2str(i),')=Error_Correcting_Feed_',num2str(i),';'])
         end % end of file is empty
        else
            % else if the file does not exist we simply use the old data
            % palcing an empty matrix into the state_read_i and a zero into
            % the system health
             disp('The File Does Not Exist - Using Old Data')
             eval(['State_Read_',num2str(i),'=Prev_State_Read_',num2str(i),';'])
             eval(['System_Health(',num2str(i),')=Prev_System_Health(',num2str(i),');'])
        end % end of if file exists 
         % clear the state read so that the vector does not kep groing with
         % new elements being appended in the next cycle.
         clear State_Read
         State_Read=[]; 
    end  % end of feed unit data harvest. 
    
 

% harevest all of the data from the data bus - Transfer Units 
    for i = 1:1:3
        % determine the file path. 
        filename_readbus = ['Transfer_Unit_',num2str(i),'_Datastream.txt'];
        path2readfile_databus = [path2databus,filename_readbus];
        % if the file exists. 
        if exist(path2readfile_databus) ~= 0 
          % if the file exists open it and scan for text 
             fid = fopen(path2readfile_databus,'r');
             out=textscan(fid,data_read_format);
             fclose(fid);
            if isempty(out{1,1})
                 % if the file is empty then it is still being edited by the unit
                 % generating it 
                 disp('Data is currently writing-use old value')
                 eval(['State_Read_',num2str(i+3),'=Prev_State_Read_',num2str(i+3),';'])
                 eval(['System_Health(',num2str(i+3),')=Prev_System_Health(',num2str(i+3),');'])
            else
                 % else the file contains useful data 
                 % section to retrieve the flag data 
                 ind=strmatch('Flag',out{1});
                 for m=1:1:length(ind)
                     eval([out{1,2}{ind(m),1},'=',num2str(out{1,3}{ind(m),1}),';']);
                 end
                 % section to retrieve the state data 
                 ind = strmatch('State',out{1});
                 if isempty(ind)~=1
                     % if a state can be found read it in 
                     for j=2:1:5
                         % read it in by checking if each element exists
                         % and appending it if st does to build up the
                         % correct length vector. 
                         if isempty(out{1,j}) ~= 1
                             if isempty(out{1,j}{ind,1}) ~= 1
                                State_Read =[State_Read,str2num(out{1,j}{ind,1})];
                             end
                         end 
                     end
                 else
                     % else use the previous state
                     eval(['State_Read=Prev_State_Read_',num2str(i+3),';'])
                 end
            end
            % update the output vectors based on what found in file. 
            eval(['State_Read_',num2str(i+3),'=State_Read;'])
            eval(['System_Health(',num2str(i+3),')=Error_Correcting_Transfer_',num2str(i),';'])
        else
            % else if the file does not exist we simply use the old data
            % palcing an empty matrix into the state_read_i and a zero into
            % the system health
            disp('The File Does Not Exist - Using Old Data')
            eval(['State_Read_',num2str(i+3),'=Prev_State_Read_',num2str(i+3),';'])
            eval(['System_Health(',num2str(i+3),')=Prev_System_Health(',num2str(i+3),');'])
        end 
         % clear the state read so that the vector does not kep groing with
         % new elements being appended in the next cycle.
            clear State_Read           
            State_Read=[];
    end 
    
% harevest all of the data from the data bus - Mainline Units 
    for i = 1:1:3
        % determine the file path. 
        filename_readbus = ['Mainline_Unit_',num2str(i),'_Datastream.txt'];
        path2readfile_databus = [path2databus filename_readbus];
        % if the file exists. 
        if exist(path2readfile_databus) ~= 0 
          % if the file exists open it and scan for text 
         fid = fopen(path2readfile_databus,'r');
         out=textscan(fid,data_read_format);
         fclose(fid);
         if isempty(out{1,1})
             % if the file is empty then it is still being edited by the unit
             % generating it 
             disp('Data is currently writing-use old value')
             eval(['State_Read_',num2str(i+6),'=Prev_State_Read_',num2str(i+6),';'])
             eval(['System_Health(',num2str(i+6),')=Prev_System_Health(',num2str(i+6),');'])
         else
             % else the file contains useful data 
             % section to retrieve the flag data 
             ind=strmatch('Flag',out{1});
             for m=1:1:length(ind)
                 eval([out{1,2}{ind(m),1},'=',num2str(out{1,3}{ind(m),1}),';']);
             end
             % section to retrieve the state data 
                 ind = strmatch('State',out{1});
                 if isempty(ind) ~= 1
                     for j=2:1:5
                         % read it in by checking if each element exists
                         % and appending it if st does to build up the
                         % correct length vector. 
                         if isempty(out{1,j}) ~= 1
                             if isempty(out{1,j}{ind,1}) ~= 1
                                State_Read =[State_Read,str2num(out{1,j}{ind,1})];
                             end
                         end 
                     end
                 else
                     % else use the previous state
                     eval(['State_Read=Prev_State_Read_',num2str(i+6),';'])
                 end
         end 
         % update the output vector based on what found in file
            eval(['State_Read_',num2str(i+6),'=State_Read;'])
            eval(['System_Health(',num2str(i+6),')=Error_Correction_Flag_Mainline_',num2str(i),';'])
        else
            % else if the file does not exist we simply use the old data
            % palcing an empty matrix into the state_read_i and a zero into
            % the system health
             disp('The File Does Not Exist - Using Old Data')
             eval(['State_Read_',num2str(i+6),'=Prev_State_Read_',num2str(i+6),';'])
             eval(['System_Health(',num2str(i+6),')=Prev_System_Health(',num2str(i+6),');'])
        end
         % clear the state read so that the vector does not kep groing with
         % new elements being appended in the next cycle.
         clear State_Read
         State_Read=[]; 
    end 

    
    
     %% Collates data into a state matrix 
     for k= 1:1:9
         if isempty(['State_Read_',num2str(k)]) == 0
             % if the state vector is not empty then we have recieved some
             % state data from the unit; hecne we can determine that the
             % unit exists and that we need to process its state
             
             % we determine the length of the state vector to give the
             % buffer number and determine which states are off versus
             % which states are not present, we also use it to distribute
             % the state vector into the full satte matrix. 
              length_vector(k)=eval(['length(State_Read_',num2str(k),')']);
              
              % the full state matrix has a form
              % b c d e for each row; and as many rows as units exist,
              % thus we need to interpret the state vector and palce the
              % elements of the vector into their correct palce in the
              % matrix, giving zero entries as the gaps. 

              if  length_vector(k) == 2
                  % if the state vector is two long then we palce the first
                  % element at the first location and the second element at
                  % the last location to show they are at either end of the
                  % feed line. 
                  System_State(k,1)=eval(['State_Read_',num2str(k),'(',num2str(1),')']);
                  System_State(k,5)=eval(['State_Read_',num2str(k),'(',num2str(2),')']);
              elseif length_vector(k) == 3
                  % if there are three elements to the state vector we have
                  % b,c and e and so we palce the three elements in these
                  % locations in the state matrix 
                  System_State(k,1)=eval(['State_Read_',num2str(k),'(',num2str(1),')']);
                  System_State(k,3)=eval(['State_Read_',num2str(k),'(',num2str(2),')']);
                  System_State(k,5)=eval(['State_Read_',num2str(k),'(',num2str(3),')']);
              elseif length_vector(k) == 4
                  % if we have four elements we have b,c,d,e and so we can
                  % palce them into the appropriate locations. 
                  System_State(k,1)=eval(['State_Read_',num2str(k),'(',num2str(1),')']);
                  System_State(k,2)=eval(['State_Read_',num2str(k),'(',num2str(2),')']);
                  System_State(k,3)=eval(['State_Read_',num2str(k),'(',num2str(3),')']);
                  System_State(k,5)=eval(['State_Read_',num2str(k),'(',num2str(4),')']);
              elseif length_vector(k) == 5
                  % this is the hypothetical case for the full five vector
                  % which may be generated by the mainline 
                  for l = 1:1:5
                    System_State(k,l) = eval(['State_Read_',num2str(k),'(',num2str(l),')']);
                  end
              end
              % we also want to update the systems health by looking at is
              % error correcting flag 
              eval(['System_Health(',num2str(i),')=Error_Correcting_Feed_',num2str(i),';'])
         else 
             % else if there is no satte vector then the unit is not
             % running and so we set the k th element of the length vector
             % to zero to show that the unit is off. 
             length_vector(k) = 0; 
         end 
         % now that the data has been logged we set the previous data to
         % this data such that we can compare it to the new data 
             eval(['Prev_State_Read_',num2str(i),'=State_Read_',num2str(i),';'])

             % this leaves us with an updated set of previous state and
             % health vectors but a new state matrix which we can compare
             % to the old one to determine which bits need redrawing. 
     end
          length_vector
          System_Health
     %% The Health Update Section - Run if the health previously and the health now are different. 
if all(Previous_System_Health==System_Health) == 0
         %% Section to draw the 3 feed panels
         
% Feed Panel 1

    if length_vector(1) ~= 0  
        % if the line is transmitting state data then we code the unit based on its
        % health 
        if System_Health(1) == 1
            set(Feed_1_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Feed_1_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Feed_1_Panel,'BackgroundColor',Unit_Off);
    end 
    
% Feed Panel 2

    if length_vector(2) ~= 0   
        % if the line is transmitting state data then we code the unit based on its
        % health 
        if System_Health(2) == 1
            set(Feed_2_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Feed_2_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Feed_2_Panel,'BackgroundColor',Unit_Off);
    end 
    
%Feed Panel 3

    if length_vector(3) ~= 0 
        % if the line is transmitting state data then we code the unit based on its
        % health         
        if System_Health(3) == 1
            set(Feed_3_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Feed_3_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Feed_3_Panel,'BackgroundColor',Unit_Off);
    end 
    %% section to draw the three transfer panels
    
% Transfer Panel 1    
    if length_vector(4) ~= 0      
        % if the line is transmitting state data then we code the unit based on its
        % health 
        if System_Health(4) == 1
            set(Transfer_1_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Transfer_1_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Transfer_1_Panel,'BackgroundColor',Unit_Off);
    end 
    
% Transfer Panel 2 

    if length_vector(5) ~= 0 
        % if the line is transmitting state data then we code the unit based on its
        % health         
        if System_Health(5) == 1
            set(Transfer_2_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Transfer_2_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Transfer_2_Panel,'BackgroundColor',Unit_Off);
    end
    
% Transfer Panel 3 

    if length_vector(6) ~= 0
        % if the line is transmitting state data then we code the unit based on its
        % health 
        if System_Health(6) == 1
            set(Transfer_3_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Transfer_3_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Transfer_3_Panel,'BackgroundColor',Unit_Off);
    end 
    %% section to draw the three mainline panels 
    
% Mainline Panel 1
    
    if length_vector(7) ~= 0 
        % if the line is transmitting state data then we code the unit based on its
        % health 
        if System_Health(7) == 1
            set(Main_1_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Main_1_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Main_1_Panel,'BackgroundColor',Unit_Off);
    end
    
% Mainline Panel 2

    if length_vector(8) ~= 0  
        % if the line is transmitting state data then we code the unit based on its
        % health 
        if System_Health(8) == 1
            set(Main_2_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Main_2_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Main_2_Panel,'BackgroundColor',Unit_Off);
    end
    
% Mainline Panel 3 

    if length_vector(9) ~= 0 
        % if the line is transmitting state data then we code the unit based on its
        % health 
        if System_Health(9) == 1
            set(Main_3_Panel,'BackgroundColor',Unit_Error_Correct);
        else
            set(Main_3_Panel,'BackgroundColor',Unit_Good);
        end
    else
        %else the line is not running so draw as off 
        set(Main_3_Panel,'BackgroundColor',Unit_Off);
    end 
end % end of the Function to update the systm health 
% set the vectors to be the same now such that the last drawn health is
% known. 
Previous_System_Health=System_Health;

%% Update the State Drawing - this section is run when the state of the system has changed. 
if all(all(System_State== Previous_System_State)) == 0
% this is called if the state matrix has changed and weill redraw all of
% the system state elements to reflect the new state.

    %% section to draw the transfer 1 state 
    if length_vector(4) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Transfer_1_b,'BackgroundColor',State_Off);
        set(Transfer_1_c,'BackgroundColor',State_Off);
        set(Transfer_1_d,'BackgroundColor',State_Off);
        set(Transfer_1_e,'BackgroundColor',State_Off);
    elseif length_vector(4) == 2
        % for a state vector of length 2
        
            % code the state element b based on its value
            if System_State(4,1) == 0
                set(Transfer_1_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_b,'BackgroundColor',State_Full_Transfer)  
            end
            % in the buffer config the middle two state positions are
            % unused. 
            set(Transfer_1_c,'BackgroundColor',State_Off);
            set(Transfer_1_d,'BackgroundColor',State_Off);
            % code the state elemente  based on its value
            if System_State(4,5) == 0
                set(Transfer_1_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(4) == 3
            % if the state vector is three long 
            
            % code the state element b based on its value
            if System_State(4,1) == 0
                set(Transfer_1_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_b,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element c based on its value
            if System_State(4,3) == 0
                set(Transfer_1_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_c,'BackgroundColor',State_Full_Transfer)  
            end
            % the second intermediate state element is off
            set(Transfer_1_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(4,5) == 0
                set(Transfer_1_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(4) == 4
            % code the state element b based on its value
            if System_State(4,1) == 0
                set(Transfer_1_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_b,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element c based on its value
            if System_State(4,2) == 0
                set(Transfer_1_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_c,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element d based on its value
            if System_State(4,3) == 0
                set(Transfer_1_d,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_d,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element e based on its value
            if System_State(4,5) == 0
                set(Transfer_1_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_1_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(5) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 1 Vector too long')
    end 

    %% section to draw the transfer 2 state
    if length_vector(5) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Transfer_2_b,'BackgroundColor',State_Off);
        set(Transfer_2_c,'BackgroundColor',State_Off);
        set(Transfer_2_d,'BackgroundColor',State_Off);
        set(Transfer_2_e,'BackgroundColor',State_Off);
    elseif length_vector(5) == 2
        % code the state element b based on its value
            if System_State(5,1) == 0
                set(Transfer_2_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_b,'BackgroundColor',State_Full_Transfer)  
            end
            % in the buffer config the middle two state positions are
            % unused. 
            set(Transfer_2_c,'BackgroundColor',State_Off);
            set(Transfer_2_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(5,5) == 0
                set(Transfer_2_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(5) == 3
            % code the state element b based on its value
            if System_State(5,1) == 0
                set(Transfer_2_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_b,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element c based on its value
            if System_State(5,3) == 0
                set(Transfer_2_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_c,'BackgroundColor',State_Full_Transfer)  
            end
            % the second intermediate state element is off
            set(Transfer_2_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(5,5) == 0
                set(Transfer_2_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(5) == 4
            % code the state element b based on its value
            if System_State(5,1) == 0
                set(Transfer_2_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_b,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element c based on its value
            if System_State(5,2) == 0
                set(Transfer_2_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_c,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element d based on its value
            if System_State(5,3) == 0
                set(Transfer_2_d,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_d,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element e based on its value
            if System_State(5,5) == 0
                set(Transfer_2_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_2_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(5) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 1 Vector too long')
    end 


    %% section to draw the transfer 3 state
    if length_vector(6) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Transfer_3_b,'BackgroundColor',State_Off);
        set(Transfer_3_c,'BackgroundColor',State_Off);
        set(Transfer_3_d,'BackgroundColor',State_Off);
        set(Transfer_3_e,'BackgroundColor',State_Off);
    elseif length_vector(6) == 2
        % code the state element b based on its value
            if System_State(6,1) == 0
                set(Transfer_3_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_b,'BackgroundColor',State_Full_Transfer)  
            end
            % in the buffer config the middle two state positions are
            % unused. 
            set(Transfer_3_c,'BackgroundColor',State_Off);
            set(Transfer_3_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(6,5) == 0
                set(Transfer_3_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(6) == 3
            % code the state element b based on its value
            if System_State(6,1) == 0
                set(Transfer_3_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_b,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element c based on its value
            if System_State(6,3) == 0
                set(Transfer_3_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_c,'BackgroundColor',State_Full_Transfer)  
            end
            % the second intermediate state element is off
            set(Transfer_3_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(6,5) == 0
                set(Transfer_3_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(6) == 4
            % code the state element b based on its value
            if System_State(6,1) == 0
                set(Transfer_3_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_b,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element c based on its value
            if System_State(6,2) == 0
                set(Transfer_3_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_c,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element d based on its value
            if System_State(6,3) == 0
                set(Transfer_3_d,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_d,'BackgroundColor',State_Full_Transfer)  
            end
            % code the state element e based on its value
            if System_State(6,5) == 0
                set(Transfer_3_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Transfer_3_e,'BackgroundColor',State_Full_Transfer)
            end 
        elseif length_vector(6) == 5
             % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 3 Vector too long')
    end 

    %% section to draw the feed 1 state 
    if length_vector(1) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Feed_1_a,'BackgroundColor',State_Off);
        set(Feed_1_b,'BackgroundColor',State_Off);
        set(Feed_1_c,'BackgroundColor',State_Off);
        set(Feed_1_d,'BackgroundColor',State_Off);
        set(Feed_1_e,'BackgroundColor',State_Off);
    elseif length_vector(1) == 2
        % code the state element b based on its value
            if System_State(1,1) == 0
                set(Feed_1_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_b,'BackgroundColor',State_Full_Feed)  
            end
            % in the buffer config the middle two state positions are
            % unused. 
            set(Feed_1_c,'BackgroundColor',State_Off);
            set(Feed_1_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(1,5) == 0
                set(Feed_1_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
            if FeedingFlag_1 == 0
                set(Feed_1_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(1) == 3
            % code the state element b based on its value
            if System_State(1,1) == 0
                set(Feed_1_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_b,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element c based on its value
            if System_State(1,3) == 0
                set(Feed_1_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_c,'BackgroundColor',State_Full_Feed)  
            end
            % the second intermediate state element is off
            set(Feed_1_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(1,5) == 0
                set(Feed_1_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value 
            if FeedingFlag_1 == 0
                set(Feed_1_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(1) == 4
            % code the state element b based on its value
            if System_State(1,1) == 0
                set(Feed_1_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_b,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element c based on its value
            if System_State(1,2) == 0
                set(Feed_1_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_c,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element d based on its value
            if System_State(1,3) == 0
                set(Feed_1_d,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_d,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element e based on its value
            if System_State(1,5) == 0
                set(Feed_1_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
            if FeedingFlag_1 == 0
                set(Feed_1_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_1_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(1) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 1 Vector too long')
    end 




    %% section to draw the feed 2 state
    if length_vector(2) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Feed_2_a,'BackgroundColor',State_Off);
        set(Feed_2_b,'BackgroundColor',State_Off);
        set(Feed_2_c,'BackgroundColor',State_Off);
        set(Feed_2_d,'BackgroundColor',State_Off);
        set(Feed_2_e,'BackgroundColor',State_Off);
    elseif length_vector(2) == 2
        % code the state element b based on its value
            if System_State(2,1) == 0
                set(Feed_2_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_b,'BackgroundColor',State_Full_Feed)  
            end
            % in the buffer config the middle two state positions are
            % unused. 
            set(Feed_2_c,'BackgroundColor',State_Off);
            set(Feed_2_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(2,5) == 0
                set(Feed_2_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
            if FeedingFlag_2 == 0
                set(Feed_2_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(2) == 3
            % code the state element b based on its value
            if System_State(2,1) == 0
                set(Feed_2_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_b,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element c based on its value
            if System_State(2,3) == 0
                set(Feed_2_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_c,'BackgroundColor',State_Full_Feed)  
            end
            % the second intermediate state element is off
            set(Feed_2_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(2,5) == 0
                set(Feed_2_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
            if FeedingFlag_2 == 0
                set(Feed_2_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(2) == 4
            % code the state element b based on its value
            if System_State(2,1) == 0
                set(Feed_2_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_b,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element c based on its value
            if System_State(2,2) == 0
                set(Feed_2_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_c,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element d based on its value
            if System_State(2,3) == 0
                set(Feed_2_d,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_d,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element e based on its value
            if System_State(2,5) == 0
                set(Feed_2_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
            if FeedingFlag_2 == 0
                set(Feed_2_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_2_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(2) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 2 Vector too long')
    end 


    %% section to draw the feed 3 state
    if length_vector(3) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Feed_3_a,'BackgroundColor',State_Off);
        set(Feed_3_b,'BackgroundColor',State_Off);
        set(Feed_3_c,'BackgroundColor',State_Off);
        set(Feed_3_d,'BackgroundColor',State_Off);
        set(Feed_3_e,'BackgroundColor',State_Off);
    elseif length_vector(3) == 2
        % code the state element b based on its value

            if System_State(3,1) == 0
                set(Feed_3_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_b,'BackgroundColor',State_Full_Feed)  
            end
            % in the buffer config the middle two state positions are
            % unused. 
            set(Feed_3_c,'BackgroundColor',State_Off);
            set(Feed_3_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(3,5) == 0
                set(Feed_3_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
            if FeedingFlag_3 == 0
                set(Feed_3_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(3) == 3
            % code the state element b based on its value
            if System_State(3,1) == 0
                set(Feed_3_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_b,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element c based on its value
            if System_State(3,3) == 0
                set(Feed_3_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_c,'BackgroundColor',State_Full_Feed)  
            end
            % the second intermediate state element is off
            set(Feed_3_d,'BackgroundColor',State_Off);
            % code the state element e based on its value
            if System_State(3,5) == 0
                set(Feed_3_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
             if FeedingFlag_3 == 0
                set(Feed_3_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(3) == 4
            % code the state element b based on its value
            if System_State(3,1) == 0
                set(Feed_3_b,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_b,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element c based on its value
            if System_State(3,2) == 0
                set(Feed_3_c,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_c,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element d based on its value
            if System_State(3,3) == 0
                set(Feed_3_d,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_d,'BackgroundColor',State_Full_Feed)  
            end
            % code the state element e based on its value
            if System_State(3,5) == 0
                set(Feed_3_e,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_e,'BackgroundColor',State_Full_Feed)
            end 
            % code the state element at the entry point based on its value
             if FeedingFlag_3 == 0
                set(Feed_3_a,'BackgroundColor',State_Empty_Feed)
            else
                set(Feed_3_a,'BackgroundColor',State_Full_Feed)
            end
        elseif length_vector(3) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 3 Vector too long')
    end 


    %% section to draw the main 1 state 
    if length_vector(7) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Main_1_a,'BackgroundColor',State_Off);
        set(Main_1_X,'BackgroundColor',State_Off);
        set(Main_1_Y,'BackgroundColor',State_Off);
        set(Main_1_Z,'BackgroundColor',State_Off);
    elseif length_vector(7) == 2
        % code the state element x based on its value
        %- if the belt is running on continuous we go for a purple
        %colour 
           if System_State(7,1) == 0
               set(Main_1_a,'BackgroundColor',State_Empty_Feed);
           elseif System_State(7,1) == 1
               set(Main_1_a,'BackgroundColor',State_Full_Feed);
           else
               set(Main_1_a,'BackgroundColor',State_Running_Main);
           end 
            % in the buffer config the middle two state positions are
            % unused. 
            set(Main_1_X,'BackgroundColor',State_Off);
            set(Main_1_Y,'BackgroundColor',State_Off);
            % code the state element z based on its value
            %- if the belt is running on continuous we go for a purple
            %colour 
           if System_State(7,5) == 0
               set(Main_1_Z,'BackgroundColor',State_Empty_Feed);
           elseif System_State(7,5) == 1
               set(Main_1_Z,'BackgroundColor',State_Full_Feed);
           else
               set(Main_1_Z,'BackgroundColor',State_Running_Main);
           end 
    elseif length_vector(7) == 3
                % code the state element x based on its value
           if System_State(7,1) == 0
               set(Main_1_a,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_1_a,'BackgroundColor',State_Full_Feed);
           end 
                   % code the state element y based on its value
           if System_State(7,3) == 0
               set(Main_1_X,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_1_X,'BackgroundColor',State_Full_Feed);
           end 
        % code the state element z based on its value
           if System_State(7,5) == 0
               set(Main_1_Z,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_1_Z,'BackgroundColor',State_Full_Feed);
           end 
           % the later buffer state is off to allow full buffering between
           % the sensors.
            set(Main_1_Y,'BackgroundColor',State_Off);    
    elseif length_vector(7) == 4
        % code the state element a based on its value
          if System_State(7,1) == 0
               set(Main_1_a,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_1_a,'BackgroundColor',State_Full_Feed);
          end 
        % code the state element x based on its value
           if System_State(7,2) == 0
               set(Main_1_X,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_1_X,'BackgroundColor',State_Full_Feed);
           end 
        % code the state element y based on its value
           if System_State(7,3) == 0
               set(Main_1_Y,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_1_Y,'BackgroundColor',State_Full_Feed);
           end 
        % code the state element z based on its value
           if System_State(7,5) == 0
               set(Main_1_Z,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_1_Z,'BackgroundColor',State_Full_Feed);
           end 
   elseif length_vector(7) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 3 Vector too long')
    end 

    %% section to draw the main 2 state
    if length_vector(8) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Main_2_a,'BackgroundColor',State_Off);
        set(Main_2_X,'BackgroundColor',State_Off);
        set(Main_2_Y,'BackgroundColor',State_Off);
        set(Main_2_Z,'BackgroundColor',State_Off);
    elseif length_vector(8) == 2
        % code the state element a based on its value
        %- if the belt is running on continuous we go for a purple
        %colour 
           if System_State(8,1) == 0
               set(Main_2_a,'BackgroundColor',State_Empty_Feed);
           elseif System_State(8,1) == 1
               set(Main_2_a,'BackgroundColor',State_Full_Feed);
           else
               set(Main_2_a,'BackgroundColor',State_Running_Main);
           end 
            % in the buffer config the middle two state positions are
            % unused. 
            set(Main_2_X,'BackgroundColor',State_Off);
            set(Main_2_Y,'BackgroundColor',State_Off);
        % code the state element z based on its value
        %- if the belt is running on continuous we go for a purple
        %colour 
           if System_State(8,5) == 0
               set(Main_2_Z,'BackgroundColor',State_Empty_Feed);
           elseif System_State(8,5) == 1
               set(Main_2_Z,'BackgroundColor',State_Full_Feed);
           else
               set(Main_2_Z,'BackgroundColor',State_Running_Main);
           end 
    elseif length_vector(8) == 3
        % code the state element a based on its value
           if System_State(8,1) == 0
               set(Main_2_a,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_2_a,'BackgroundColor',State_Full_Feed);
           end 
        % code the state element x based on its value
           if System_State(8,3) == 0
               set(Main_2_X,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_2_X,'BackgroundColor',State_Full_Feed);
           end 
        % code the state element z based on its value
           if System_State(8,5) == 0
               set(Main_2_Z,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_2_Z,'BackgroundColor',State_Full_Feed);
           end 
           % the later buffer state is off to allow full buffering between
           % the sensors.
            set(Main_2_Y,'BackgroundColor',State_Off);    
    elseif length_vector(8) == 4
        % code the state element a based on its value
          if System_State(8,1) == 0
               set(Main_2_a,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_2_a,'BackgroundColor',State_Full_Feed);
          end 
         % code the state element x based on its value
           if System_State(8,2) == 0
               set(Main_2_X,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_2_X,'BackgroundColor',State_Full_Feed);
           end 
           % code the state element y based on its value
           if System_State(8,3) == 0
               set(Main_2_Y,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_2_Y,'BackgroundColor',State_Full_Feed);
           end 
         % code the state element z based on its value
           if System_State(8,5) == 0
               set(Main_2_Z,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_2_Z,'BackgroundColor',State_Full_Feed);
           end 
   elseif length_vector(8) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 3 Vector too long')
    end 



    %% section to draw the main 3 state
    if length_vector(9) == 0
        % if the unit is off then we set all of its state icons to be off
        % also
        set(Main_3_a,'BackgroundColor',State_Off);
        set(Main_3_X,'BackgroundColor',State_Off);
        set(Main_3_Y,'BackgroundColor',State_Off);
        set(Main_3_Z,'BackgroundColor',State_Off);
    elseif length_vector(9) == 2
        % code the state element a based on its value
        %- if the belt is running on continuous we go for a purple
        %colour 
           if System_State(9,1) == 0
               set(Main_3_a,'BackgroundColor',State_Empty_Feed);
           elseif System_State(9,1) == 1
               set(Main_3_a,'BackgroundColor',State_Full_Feed);
           else
               set(Main_3_a,'BackgroundColor',State_Running_Main);
           end 
            % in the buffer config the middle two state positions are
            % unused. 
            set(Main_3_X,'BackgroundColor',State_Off);
            set(Main_3_Y,'BackgroundColor',State_Off);
        % code the state element z based on its value
        %- if the belt is running on continuous we go for a purple
        %colour 
           if System_State(9,5) == 0
               set(Main_3_Z,'BackgroundColor',State_Empty_Feed);
           elseif System_State(9,5) == 1
               set(Main_3_Z,'BackgroundColor',State_Full_Feed);
           else
               set(Main_3_Z,'BackgroundColor',State_Running_Main);
           end 
    elseif length_vector(9) == 3
           % code the state element a based on its value
           if System_State(9,1) == 0
               set(Main_3_a,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_3_a,'BackgroundColor',State_Full_Feed);
           end 
           % code the state element x based on its value
           if System_State(9,3) == 0
               set(Main_3_X,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_3_X,'BackgroundColor',State_Full_Feed);
           end 
            % code the state element z based on its value
           if System_State(9,5) == 0
               set(Main_3_Z,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_3_Z,'BackgroundColor',State_Full_Feed);
           end 
           % the later buffer state is off to allow full buffering between
           % the sensors.
            set(Main_3_Y,'BackgroundColor',State_Off);    
    elseif length_vector(9) == 4
        % code the state element a based on its value
          if System_State(9,1) == 0
               set(Main_3_a,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_3_a,'BackgroundColor',State_Full_Feed);
          end 
          % code the state element x based on its value
           if System_State(9,2) == 0
               set(Main_3_X,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_3_X,'BackgroundColor',State_Full_Feed);
           end 
           % code the state element y based on its value
           if System_State(9,3) == 0
               set(Main_3_Y,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_3_Y,'BackgroundColor',State_Full_Feed);
           end 
           % code the state element z based on its value
           if System_State(9,5) == 0
               set(Main_3_Z,'BackgroundColor',State_Empty_Feed);
           else
               set(Main_3_Z,'BackgroundColor',State_Full_Feed);
           end 
    elseif length_vector(9) == 5
            % in this case there has been an error and two state vectors
            % have got mashed togetehr in the reading process. 
            disp('error- State 3 Vector too long')
    end  
end% end of the function which will redraw all of the state elements 
% set the previous system state to the last drawn state such that we do now
% need to redraw if the state is the same - this saves on some processing
% power. 
Previous_System_State = System_State;

else   % ELSE if go = 0 then we want to not bother evaluating anything to save processing power.   
    % pause to save on processing power. 
      pause(0.5)
end % end of if go == 2
% check if the status montior is set to continue or if the line is stopped
% to save drawing the same thing over and over. 
Run_Continue = exist(path2rundrawingY);   
% check that go still exists 
go = exist(path2go); 
pause(0.05)    
end %end of while loop 
% quit the instance of matlab once the loop is over i.e. the program has
% been terminated from the main window. 
quit
