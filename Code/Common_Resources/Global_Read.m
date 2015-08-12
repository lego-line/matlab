% Global_read.m - script file to read the messages from the global
% controller to the units, called by each of the units to get their
% instructions
% looks for a text file in the simualted data bus folder with tabualr
% format
%
% State X X X X
% Flag Name Val 
% Flag Name Val 
% etc 
% and a name Global_Instructions_UnitType_UnitNumber.txt
disp('Reading Instructions From Global Controller')
toc 
%% First Run Section To Set Up variables Etc 
if first_run == 1
    % if the unit is a feed unit determine the file written by the global
    % controller to it
    if exist('feed_id','var')
        if feed_id > 0
            % for normal feed lines 
            filename_global_instructions =['Global_Instructions_Feed_',num2str(feed_id),'.txt'];
            % initialsie flag variables 
            eval(['Error_Correcting_Feed_',num2str(Number_of_Feedlines),'=0;']);
            eval(['Pallet_Status_',num2str(Number_of_Feedlines),'=0;']);
            eval(['FeedingFlag_',num2str(Number_of_Feedlines),'=0;']);
            eval(['FeedingFlag2_',num2str(Number_of_Feedlines),'=0;']);
        elseif feed_id == 0
            % else look for the upstream file if the ID is zero 
            filename_global_instructions ='Global_Instructions_Upstream.txt';
            % initialsie flag variables 
            eval(['Error_Correcting_Transfer_',num2str(feed_id),'=0;']);
            eval(['Mainline_Clear_',num2str(feed_id),'=0;']);
            eval(['Arrival_Status_',num2str(feed_id),'=0;']);
            eval(['Unload_state_',num2str(feed_id),'=0;']);
        end 
    elseif exist('Transfer_id','var')
    % if the unit is a transfer unit determine the file written by the global
    % controller to ita name and number is appended to the
    % instruction file name 
        filename_global_instructions =['Global_Instructions_Transfer_',num2str(Transfer_id),'.txt'];
    % Initialise Flag variables 
        eval(['Error_Correcting_Feed_',num2str(Transfer_id),'=0;']);
        eval(['Pallet_Status_',num2str(Transfer_id),'=0;']);
        eval(['FeedingFlag_',num2str(Transfer_id),'=0;']);
        eval(['FeedingFlag2_',num2str(Transfer_id),'=0;']);        
    elseif exist('Main_id','var')    
    % if the unit is a mainline unit determine the file written by the global
    % controller to it a name and number is appended to the
    % instruction file name 
        filename_global_instructions =['Global_Instructions_Main',num2str(Main_id),'.txt'];
        eval(['Mainline_Clear_',num2str(Main_id),'=0;']);
        transfer_previous_pallet_downstream = 0; 
     % Initialise Flag variables    
          eval(['Error_Correcting_Transfer_',num2str(Main_id),'=0;']);
          eval(['Mainline_Clear_',num2str(Main_id),'=0;']);
          eval(['Arrival_Status_',num2str(Main_id),'=0;']);
          eval(['Unload_state_',num2str(Main_id),'=0;']);        
    end  

    % setup some variables in which to put the   read state  
    State_Read = [];
    State_Read_Downstream =[]; 
    State_Read_Previous = []; 
    State_Read_Downstream_Previous = []; 
    instructions_read = 0; % flag to track if instructions have been receieved yet 
    Hold = 0; % all have a common hold flag to show if the unit should not move any pallets onto the next section
end % end of first run

%%  The Reading Section 


% clear out the read variables in order that old values do not get confused
% with newer values
State_Read = [];
State_Read_Downstream = [];
if exist([path2databus,filename_global_instructions])
    % open file and do a textscan for tabular data 
    fid=fopen([path2databus,filename_global_instructions]);
    global_text_raw = textscan(fid,'%s %s %s %s %s');
    fclose(fid); 
    if isempty(global_text_raw{1,1})
        if instructions_read == 1
         % if the file exists but there is no data in it it is still being
         % edited and hence use the previous values 
            disp('Global Instructions Not Available-file open but no data- Operating on Last Known Data')
            State_Read = State_Read_Previous;
        else
            disp('No Global Instructions yet Received- file open but no data - Operating Locally')
        end 
    else
        disp('Extracting Flags')
        % in this case we create a vector of indexs pointing to the rows
        % which have the designation FLAG in the first column 
        ind=strmatch('Flag',global_text_raw{1});
        for i=1:1:length(ind)
             % assign the value found in the third colmun of the row, to
             % the variable named in the second column
            eval([global_text_raw{1,2}{ind(i),1},'=',num2str(global_text_raw{1,3}{ind(i),1})]);
        end
        disp('Flag Extraction Completed')
        disp('Extracting State')
        % look in the read data for a row starting with the STATE
        % designation in the first column
        ind = strmatch('State',global_text_raw{1},'exact');

        % loop across state reading in the variable to the @read state'
        % variable 
             % the basic concept here is to look across the columns; the
             % length of the state vector is unknon but the file is
             % formatted to write the state vector from left to right and
             % then leave empty columns, thus we move L to R along the row,
             % if an element of state vector exists then we append it to
             % our generated state vector, and once we reach an empty
             % column we know that the full state vector has been
             % retireved. 
         if isempty(ind) == 0
             for i=2:1:5
                 if isempty(global_text_raw{1,i}) ~=1
                     if isempty(global_text_raw{1,i}{ind,1}) ~=1
                        State_Read =[State_Read,str2num(global_text_raw{1,i}{ind,1})];
                     end
                 end 
             end
         end 
         disp('The Read State Is')
         disp(State_Read)
         toc
         instructions_read = 1; % set instructions read flag to show some instrcutions have been receievd 
         disp('State Read Completed')
        if exist('Main_id','var')
            disp('Reading Downstream State Begin')
            % special case for the mainline wehreby there are two state
            % vectors written into the communication file, one for the
            % incoming transfer and one for the trnasfer which may be
            % causing blockages to prevent pallet release from the section
             if downstream_transfer == 1
                 ind = strmatch('Downstream_State',out{1},'exact');
        % loop across state reading in the variable to the @read state'
        % variable 
             % the basic concept here is to look across the columns; the
             % length of the state vector is unknon but the file is
             % formatted to write the state vector from left to right and
             % then leave empty columns, thus we move L to R along the row,
             % if an element of state vector exists then we append it to
             % our generated state vector, and once we reach an empty
             % column we know that the full state vector has been
             % retireved. 
                 if isempty(ind) ~= 0
                     for i=2:1:(length(status)+1)
                         if isempty(global_text_raw{1,i}) == 0
                             if isempty(global_text_raw{1,i}{ind,1}) ~=1
                                State_Read_Downstream =[State_Read_Downstream,str2num(global_text_raw{1,i}{ind,1})];
                             end
                         end 
                     end
                 end 
             end
         disp('The Read Downstream State Is')
         disp(State_Read)
         disp('Compelted reading Downstream State')
         end 
    end
else % if the file does not exist then use the previous data 
    if instructions_read == 1
        disp('Global Instructions Not Available- Operating on Last Known Data')
        State_Read = State_Read_Previous;
    else % else if the global controller cannot operate state that the units will be
        % operating locally 
        disp('No Global Instructions yet Received - no file - Operating Locally')
    end 
end 

State_Read_Previous =  State_Read;
disp('Reading Completed')
toc 

%% section to override the local control options
% since the global controller may have a transitory startup period then the
% units are capable of oeprating locally, once the global data begins to
% arrive then the options which allow local control should be overwritten,
% thus effetcively operating on global control. I.E. the global controller
% data is translaetd and injected into the normal flow chart as changes in
% state or flags to produce the desired behaviour such that the overall
% oeprating loop is unchanged and hence a fiar compariosn of controlk
% system can be made. 

% message received- will be type dependant
%% Feed Unit
if exist('feed_id','var') ~= 0 && isempty(State_Read) == 0
    if all(status == State_Read) == 0
        if feed_id > 0 
            % state matching for the feed units 
            if length(status) == 3
                if status(2) ~= State_Read(2)
                    status(2) = State_Read(2);
                end
            end
            % different case for the longer status 
            if length(status) == 4
                if status(2) ~= State_Read(2)
                    status(2) = State_Read(2);
                end
                if status(3) ~= State_Read(3)
                    status(3) = State_Read(3);
                end
            end
        end
    end 
elseif exist('feed_id','var') ~= 0 && isempty(State_Read) == 1
        State_Read = zeros(1,length(status));
        % popualte a state vector if non exists such that the unit has
        % something to work from 
end 
%% Transfer Units
if exist('Transfer_id','var')
    if Hold == 1
        % if the unit is told to hold then no more pallets may be moved
        % onto the mainline - this allows the creation of gaps on the
        % mainline to allow pallets further down to be inserted. 
        blockage = 1; 
    end 
end 
%% Mainline Units
if exist('Main_id','var')
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
