%Network_Read.m a script file to read the contents of a unit message from
%the data bus and get the data into the current units operating variables
%such that it can be acted on 
%
%  From  a file called UnitType_Unit_UnitNumber.txt in a folder 
%  called SimulatedDataBus under control with the contenets
%  State X X X X
%  Flag Name Val
%  Flag Name Val
%  etc 
%
% the state should be extracted and then each of the flag variables
% extracted 

disp('Performing a Network Read')
toc

if first_run == 1
    % setup relevant variables, the text format string should allow reading
    % from the file of all flags and a maximum length state vector, this is
    % important as sometimes the existence of these avriables are assumed
    % later and writing corrective coe for the cases where they are not is
    % time consuming and inaccurate 
    data_read_format = '%s %s %s %s %s %s';
    
    % these variables store the state which is being read (State_read) and
    % a previous version such that if the current state cannot be read for
    % example if is is incomplete the old state may be used. the same
    % exists for the downstream state used by the mainlines
    State_Read=[];
    State_Read_Downstream=[];
    State_Read_prev=[];
    State_Read_Downstream_prev=[];

    if exist('feed_id','var') ;
        if feed_id == 0
            % if is it the upstream want to read from the nearby feed unit
            % to get the status of the line and the blockage flag(if
            % required). This allows the upstream unit to determine if a pallet is waiting at the transfer point 
            %( which will then cause it to hold, emulating a  buffered
            %mainlien if using feed line priority)
            
            % this section creates variables for this upstream most feed
            % line to put data into and defualts them all to zero. 
            eval(['Error_Correcting_Feed_',num2str(Number_of_Feedlines),'=0;']);
            eval(['Pallet_Status_',num2str(Number_of_Feedlines),'=0;']);
            eval(['FeedingFlag_',num2str(Number_of_Feedlines),'=0;']);
            eval(['FeedingFlag2_',num2str(Number_of_Feedlines),'=0;']);
            % this tells the script which file to read the data from on the
            % databus 
            filename_readbus = ['Feed_Unit_',num2str(Number_of_Feedlines),'_Datastream.txt']; 
        else 
            % else for a normal feed unit 
            % setup relevant variables to read from the transfer line
            % partnered with it such that they can coordinate 
            eval(['Error_Correcting_Transfer_',num2str(feed_id),'=0;']);
            eval(['Mainline_Clear_',num2str(feed_id),'=0;']);
            eval(['Arrival_Status_',num2str(feed_id),'=0;']);
            eval(['Unload_state_',num2str(feed_id),'=0;']);
            % instruct the program to read from the adjacent transfer units
            % output file 
            filename_readbus = ['Transfer_Unit_',num2str(feed_id),'_Datastream.txt'];
        end
    elseif exist('Transfer_id','var')
        % else if the unit is a transfer we want to read from the partnered
        % feed unit and so set up suitable variables to house the incoming
        % data
        eval(['Error_Correcting_Feed_',num2str(Transfer_id),'=0;']);
        eval(['Pallet_Status_',num2str(Transfer_id),'=0;']);
        eval(['FeedingFlag_',num2str(Transfer_id),'=0;']);
        eval(['FeedingFlag2_',num2str(Transfer_id),'=0;']);
        % tell the script to read from the partnered feed unit 
        filename_readbus = ['Feed_Unit_',num2str(Transfer_id),'_Datastream.txt'];  
    elseif exist('Main_id','var')
        % in this case the unit is a mainline and is interested in the
        % state of the transfer unit that joins into it to determine
        % incoming pallets. A slight workaround is used whereby this unit
        % uses the blockage flag of the tarnsfer to detect pallets arriving
        % from the preceeding mainline section as the better placed sensor
        % is atatched to this unit and activates that flag. 

        % setup appropirate variables to capture the data from a transfer
        % unit 
          eval(['Error_Correcting_Transfer_',num2str(Main_id),'=0;']);
          eval(['Mainline_Clear_',num2str(Main_id),'=0;']);
          eval(['Arrival_Status_',num2str(Main_id),'=0;']);
          eval(['Unload_state_',num2str(Main_id),'=0;']);
          % instruct the un it to read from the right transfer units output
          % file. 
          filename_readbus = ['Transfer_Unit_',num2str(Main_id),'_Datastream.txt'];
          if downstream_transfer == 1
              % on coordinated control, if the unit believes that there is
              % a transfer unit downstream also it can use the satte and
              % flags of this unit to coordinate its buffering action as
              % well as gain more accurate knowledge of its own oeprations.
              
              % hence we create variables with modified names to store the
              % data from the downstream transfer unit 
                eval(['Error_Correcting_Transfer_Downstream_',num2str(Main_id-1),'=0;']);
                eval(['Mainline_Clear_Downstream_',num2str(Main_id-1),'=0;']);
                eval(['Arrival_Status_Downstream_',num2str(Main_id-1),'=0;']);
                eval(['Unload_state_Downstream_',num2str(Main_id-1),'=0;']);
                
                % and we create a new pointer to tell the script to read
                % from another file also. 
                filename_readbus_Downstream = ['Transfer_Unit_',num2str(Main_id - 1),'_Datastream.txt'];
                % create the full path pointing to the file to read
                path2readfile_databus_downstream = [path2databus filename_readbus_Downstream];
                transfer_previous_pallet_downstream=0; 
          end
    end 
    % create the full path pointing to the file to read
    path2readfile_databus = [path2databus filename_readbus];
end % end of firt run section 
%% The File Reading Section 
% clear out state read and state read downstream to allow new data to be
% put into them, the success of this operation can be measured by checking
% if the cector is subsequently filled.
State_Read=[];
State_Read_Downstream=[];

if exist(path2readfile_databus) ~= 0 % check existence of file 
    % open file and do a textscan for tabular data 
     fid = fopen(path2readfile_databus,'r');
     out=textscan(fid,data_read_format);
     fclose(fid);
     % now we can extract the data 
     if isempty(out{1,1})
         % if the file exists but there is no data in it it is still being
         % edited and hence use the previous values 
         disp('Data is currently writing-use old value')
         State_Read=State_Read_prev;
     else
         % else we can extract the data 
         % section to retrieve the flag data 
         disp('Extracting Flags')
         % in this case we create a vector of indexs pointing to the rows
         % which have the designation FLAG in the first column 
         ind=strmatch('Flag',out{1});
         for i=1:1:length(ind) % loop over all of the indices
             % assign the value found in the third colmun of the row, to
             % the variable named in the second column
             eval([out{1,2}{ind(i),1},'=',num2str(out{1,3}{ind(i),1})]);
         end
         disp('Flag Extraction Completed')
         % section to retrieve the state data 
         disp('Extracting State')
         % look in the read data for a row starting with the STATE
         % designation in the first column 
         ind = strmatch('State',out{1});
         % loop across state reading in the variable to the state_read
         % variable  
         for i=2:1:5 % loop across the latter columns of row ind 
             % the basic concept here is to look across the columns; the
             % length of the state vector is unknon but the file is
             % formatted to write the state vector from left to right and
             % then leave empty columns, thus we move L to R along the row,
             % if an element of state vector exists then we append it to
             % our generated state vector, and once we reach an empty
             % column we know that the full state vector has been
             % retireved. 
             if isempty(out{1,i}) ~=1 % if the column is not empty then another element of the state vector exists 
                 if isempty(out{1,i}{ind,1}) ~=1 % a simple check to prevent indexing errors 
                    State_Read =[State_Read,str2num(out{1,i}{ind,1})]; % append this onto the end of the state vector 
                 end
             end 
         end
         disp('State Extraction Completed')
     end 
else % else the file is missing, this could be a temporary error as it is being edited
    % hence display a warning message for the user 
    disp('Communications Failure - No File found')
    State_Read = State_Read_prev;
end 
State_Read_prev = State_Read;
% display the read state for the error log 
disp(State_Read)
disp('Primary State Read Finished')
%% If the unit is a mailine and needs to perform two reads
% for the mainline with a downstream transfer line is present then the
% data for that also needs to be retrieved as a secondary state read. This
% is done here in exactly the same manner as above
if exist('Main_id','var') ~= 0
    if downstream_transfer == 1
        disp('Secondary State Read Commencing')
        if exist(path2readfile_databus_downstream) ~= 0
             fid = fopen(path2readfile_databus_downstream,'r');
             out=textscan(fid,data_read_format);
             fclose(fid);
             if isempty(out{1,1})
                 disp('Data is currently writing-use old value')
                 State_Read_Downstream=State_Read_Downstream_prev;
             else
                 % section to retrieve the flag data 
                 disp('Extracting Flags')
                 ind=strmatch('Flag',out{1});
                 for i=1:1:length(ind)
                     eval([out{1,2}{ind(i),1},'=',num2str(out{1,3}{ind(i),1})]);
                 endState_Read_Downstream=State_Read_Downstream_prev;
                 % section to retrieve the state data
                 disp('Flag Extraction Completed')
                 disp('Extracting State')
                 ind = strmatch('State',out{1});
                 % loop across sate reading in the variable to the @read state'
                 % variable 
                 for i=2:1:5
                     if isempty(out{1,i}) ~=1
                         if isempty(out{1,i}{ind,1}) ~=1
                            State_Read_Downstream =[State_Read_Downstream,str2num(out{1,i}{ind,1})];
                         end
                     end 
                 end
                 end 
                disp('State Extraction Completed')
             end 
        else 
           disp('Communications Failure - No File found')
           State_Read_Downstream=State_Read_Downstream_prev;
        end
        State_Read_Downstream_prev  = State_Read_Downstream;
        disp('Secondary State Read Finished')
    end % end of if downstream section
end % end of if mainline 



%% Data Sync Up Section 
disp('Beginning Data Sync')

% Case for the feed Unit 
if exist('feed_id','var') ~= 0 && isempty(State_Read) == 0
    % in this case it was noted that the feed unit had no knowledge of
    % where pallets were once on the transfer eection in the higher buffer
    % states, I.E. if a pallet was buffered at C on the transfer and then
    % moved to E this intermediate step would not be found on the feed unit
    % as the two states weren't in sync, thus some of the error correction
    % routines and correct operation of the feed unit could not be ensured.
    % Therefore any intermediate state data from the transfer unit should
    % be copied into the feed untis state 
    if all(status == State_Read) == 0 %where the state vectors do not match 
        % state matching for the feed units when status is of length 3 
        if length(status) == 3
            % match the buffer state at postion c 
            if status(2) ~= State_Read(2)
                status(2) = State_Read(2);
            end
        end
        % different case for the longer status 
        % match the states at positions c and d to reflect the physical
        % changes
        if length(status) == 4
            if status(2) ~= State_Read(2)
                status(2) = State_Read(2);
            end
            if status(3) ~= State_Read(3)
                status(3) = State_Read(3);
            end
        end
    end 
elseif exist('feed_id','var') ~= 0 && isempty(State_Read) == 1
        % if still a feed unit and no state vector then simply fill it with
        % zeros as this is probably the case in reality at the start of the
        % run 
        State_Read = zeros(1,length(status));
elseif  exist('Transfer_id','var') ~= 0 && isempty(State_Read) == 1
        % same as above but for the transfer unit at the start of the run 
        State_Read = zeros(1,length(state));
end 


if exist('Main_id','var')
    % this section of code interprest the flags and state that the mainline
    % unit reads from the transfer unit such that the status of any
    % incoming palelts can be determined 
    
    % it oeprates by creating virtual input sensors based on teh data and
    % using them to set or de set some incoming flags that are used in the
    % main operating loop much like where real sensors are used. 
    if size(State_Read,2) ~= 0 
            if State_Read(size(State_Read,2)) == 1
            % set the flag to show the previous state 
                transfer_previous_pallet=1; 
                disp('A Transfer is In Progress')
            else
                if transfer_previous_pallet == 1 
                    disp('A Transfer has Just Been Completed')
                    no_pallets_mainline=no_pallets_mainline+1;
                    enteringflag = 1; 
                else
                    disp('The Transfer Line In is Clear')
                end
                transfer_previous_pallet=0;
            end
    else 
        transfer_previous_pallet=0;
    end 
    
    if eval(['Mainline_Clear_',num2str(Main_id)]) == 1
    % set the flag to show the previous state 
        if entering_previous_pallet == 0
            time_in_last = toc;
            disp('A Pallet has Entered the Line')
            toc
            %increment number of pallets on mainline 
            no_pallets_mainline = no_pallets_mainline +1; 
            enteringflag=1; 
        end 
        entering_previous_pallet=1;  
        disp('A Pallet Is Arriving')
    else
        disp('The Upstream Line In is Clear')
        entering_previous_pallet=0; 
    end
    
    if downstream_transfer == 1
     if size(State_Read_Downstream,2) ~= 0 
            if State_Read_Downstream(size(State_Read_Downstream,2)) == 1
            % set the flag to show the previous state 
                transfer_previous_pallet_downstream=1; 
                disp('A Transfer is In Progress')
                blockage = 1; 
            else
                if transfer_previous_pallet_downstream == 1 
                    disp('A Transfer has Just Been Completed')
                    no_pallets_mainline=no_pallets_mainline+1;
                    blockage = 0;
                else
                    disp('The Transfer Line Downstream is Clear')
                    blockage = 0;
                end
                transfer_previous_pallet_downstream=0; 
            end
    else 
        transfer_previous_pallet_downstream=0;
        blockage = 0;
    end 
    end % end of id downtream section
end % end of if mainline section. 