% Network_write.m - script file to report thet status of the unit to the
% simulated data bus called by all running scripts in the main loop of the
% program. 
%  The result is a file called UnitType_Unit_UnitNumber.txt in a folder 
%  called SimulatedDataBus under control with the contenets
%  State X X X X
%  Flag Name Val
%  Flag Name Val
%  etc 
%% first run section to define relevant variables and format 

    % create a 3 column format for the flag, the first will contain the
    % word flag such that when reading this can be identified as a flag
    % variable rather that a status, the second column contains the
    % variable name and the third contaions its value 
    Flag_format = '%s %s %s';
     
    % next we need to create two things, a filename indicating the unit of
    % origin and a path to the save file 
    % as well as a format string for the state vector dependant on the
    % length of the state vector 
    
    if exist('feed_id','var')
        % case for a feed unit 
        if feed_id == 0  
            % if an upstream unit then call it upstream and use the full
            % two state vector which the upstream always uses 
            filename_out_name = 'Upstream_Unit_Datastream.txt';
            state_format = '%s %s';
        else
            % else if a numbered feed unit, i.e. a feed line then use its
            % number and feed as the file identified 
            filename_out_name = ['Feed_Unit_',num2str(feed_id),'_Datastream.txt'];
            
            % start creating a state vector output format with 1 element to
            % write the word state into such that when reading the next
            % characters are interpreted correctly as the state 
            state_format =['%s '];
            for i=1:1:length(status)
                % loop over the length of status adding extra columsn to
                % the format equal to the number of elements of state such
                % that we have enough
                state_format = [state_format,'%s '];
            end
        end
    elseif exist('Transfer_id','var')
        filename_out_name = ['Transfer_Unit_',num2str(Transfer_id),'_Datastream.txt'];
            % start creating a state vector output format with 1 element to
            % write the word state into such that when reading the next
            % characters are interpreted correctly as the state 
        state_format =['%s '];
        for i=1:1:length(state)
                % loop over the length of status adding extra columsn to
                % the format equal to the number of elements of state such
                % that we have enough
            state_format = [state_format,'%s '];
        end  
    elseif exist('Main_id','var')    
       filename_out_name = ['Mainline_Unit_',num2str(Main_id),'_Datastream.txt'];
            % start creating a state vector output format with 1 element to
            % write the word state into such that when reading the next
            % characters are interpreted correctly as the state 
       state_format =['%s '];
       for i=1:1:length(state)
                % loop over the length of status adding extra columsn to
                % the format equal to the number of elements of state such
                % that we have enough           
            state_format = [state_format,'%s '];
       end
    end
    filepath_out_message = [path2control sep 'Data_Bus_Simulated' sep  filename_out_name];

% small tweak to get round the fact that in the original program the
% transfer and feed units call the state different variables. 
if exist('status','var')
    state = status;
end 

%%  section to write the file 
% open file 
 fid = fopen(filepath_out_message,'wt');
 % write the state in its appropriate format dependant on the length of the
 % state vector. If length state = 2 then need a write command with 3
 % columns and the appropriate data etc. 
 if length(state) == 2
     fprintf(fid,state_format,'State',num2str(state(1)),num2str(state(2)));
     messages_data_write_amount = messages_data_write_amount + 16;
 elseif length(state) ==3
     fprintf(fid,state_format,'State',num2str(state(1)),num2str(state(2)),num2str(state(3)));
     messages_data_write_amount = messages_data_write_amount + 24;
 elseif length(state) == 4
     fprintf(fid,state_format,'State',num2str(state(1)),num2str(state(2)),num2str(state(3)),num2str(state(4)));
     messages_data_write_amount = messages_data_write_amount + 32;
 else
     disp('State Vector Not Recognised')
     messages_data_write_amount = messages_data_write_amount + 16;
     fprintf('No State Vector')
 end
 % create a new line for the flags to go on. 
 fprintf(fid,'\r\n');
 %% now write any important flags 
 if exist('feed_id','var')
     % if there exists a variable called feed_id then the unit calling the
     % script is a feed unit, and hence the appropriate flkags to
     % communicate with other units need to be printed. This is only true
     % for non upstream units - the upstream unit only reports it status as
     % this is all that is required downstream of it
         fprintf(fid,Flag_format,'Flag',['Error_Correcting_Feed_',num2str(feed_id)],num2str(fault_flag));
         fprintf(fid,'\r\n');
         fprintf(fid,Flag_format,'Flag',['Pallet_Status_',num2str(feed_id)],num2str(pallet));
         fprintf(fid,'\r\n');
         fprintf(fid,Flag_format,'Flag',['FeedingFlag_',num2str(feed_id)],num2str(feeding));
         fprintf(fid,'\r\n');
         fprintf(fid,Flag_format,'Flag',['FeedingFlag2_',num2str(feed_id)],num2str(feeding2));
         messages_data_write_amount = messages_data_write_amount + (24*4);
 elseif exist('Transfer_id','var')
     % this case writes the appropriate flags for the transfer unit as a
     % Transfer_id variable has been discovered 
     fprintf(fid,Flag_format,'Flag',['Error_Correcting_Transfer_',num2str(Transfer_id)],num2str(fault_flag));
     fprintf(fid,'\r\n');
     fprintf(fid,Flag_format,'Flag',['Mainline_Clear_',num2str(Transfer_id)],num2str(blockage));
     fprintf(fid,'\r\n');
     fprintf(fid,Flag_format,'Flag',['Arrival_Status_',num2str(Transfer_id)],num2str(pallet));
     fprintf(fid,'\r\n');
     fprintf(fid,Flag_format,'Flag',['Unload_state_',num2str(Transfer_id)],num2str(unload_state));
     messages_data_write_amount = messages_data_write_amount + (24*4);
 elseif exist('Main_id','var')    
     % this case writes the appropriate flags for the mainline unit 
     fprintf(fid,Flag_format,'Flag',['Error_Correction_Flag_Mainline_',num2str(Main_id)],num2str(fault_flag));
     messages_data_write_amount = messages_data_write_amount + (24*1);
 end
 fclose(fid); % file written, close file and finish script 