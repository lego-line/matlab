% Global_Controller_Write.m - script file which writes the relevant
% instruction files to the units to ensure they are operating correctly, it is called by the global cotnroller every time it wants to
% update the status of the units 

%% Some Initial Setup
disp('Updating Any Relevant Instruction Files')
toc
% various formats which may be employed in writing a tabualr file which is
% easy to decode. 
global_write_file_format = '%s %s %s';
global_state_2_format = '%s %s %s';
global_state_3_format = '%s %s %s %s';
global_state_4_format = '%s %s %s %s %s';


%% The Maine Reading loop 
for index = 1:1: Number_of_Feedlines % loop over the number of feed lines to get all untis 
    % check if the feed line needs to be updated 
    % this is done by checking if the global cotnrolelr ahs set this to be
    % refreshed, this prevents unnessecary file write oeprations which can
    % be time consuming and affect performance. 
    if eval(['Update_Feed_',num2str(index)]) == 1 % if it is to update the feed units instructions 
        disp(['Updating Feed Unit ',num2str(index),' Instructions'])
        toc
        % open a relevant file in the data bus for the instructions to go
        % into 
        fid =fopen([path2databus, eval(['filepath_feed_',num2str(index)])],'w');
        % print some of the relevant flags into the file first in the
        % correct format. 
        fprintf(fid,global_write_file_format,'Flag','Hold',num2str(eval(['Hold_Feed_',num2str(index),])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['Arrival_Status_',num2str(index)],num2str(eval(['Arrival_Status_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['Unload_State_',num2str(index)],num2str(eval(['Unload_state_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['Belt_Speed_',num2str(index)],num2str(eval(['Feed_Belt_Speed_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;  
       % this write some state information to the unit, giving it the state
       % of the whole transfer line based on assessing the feed and
       % gtarsnefr and using the msot accurate data to determine the
       % overall local state of that line segment.     
        state_write = eval(['State_Read_',num2str(index+Number_of_Feedlines)]);
        % dependant on the length of the state vector use the correct
        % format to write tabular data. 
        if length(state_write) == 2
             fprintf(fid,global_state_2_format,'State',num2str(state_write(1)),num2str(state_write(2)));
             messages_data_write_amount = messages_data_write_amount + 16;
        elseif length(state_write) ==3
             fprintf(fid,global_state_3_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)));
             messages_data_write_amount = messages_data_write_amount + 24;
        elseif length(state_write) == 4
             fprintf(fid,global_state_4_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)),num2str(state_write(4)));
             messages_data_write_amount = messages_data_write_amount + 32;
        else
             disp('State Vector Not Recognised')
             messages_data_write_amount = messages_data_write_amount + 16;
        end
        fprintf(fid,'\r\n');
        fclose(fid); 
        % finish the feed unit file write oepration  
        % having updated put down the update flag 
        eval(['Update_Feed_',num2str(index),'=0;'])
        disp(['Updated Feed ',num2str(index) ' Instructions'])
        toc
    end 
     % check if the Transfer line needs to be updated 
    if eval(['Update_Transfer_',num2str(index)]) == 1 % if the update flag for the transfer unit in question is set then take some action
        disp(['Updating Transfer Unit ',num2str(index),' Instructions'])
        toc
        % open a relevant file in the data bus for the instructions to go
        % into 
        fid =fopen([path2databus, eval(['filepath_transfer_',num2str(index)])],'w');
        % print some of the relevant flags into the file first in the
        % correct format. 
        fprintf(fid,global_write_file_format,'Flag','Hold',num2str(eval(['Hold_Transfer_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['Pallet_Status_',num2str(index)],num2str(eval(['Pallet_Status_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['FeedingFlag_',num2str(index)],num2str(eval(['FeedingFlag_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['FeedingFlag2_',num2str(index)],num2str(eval(['FeedingFlag2_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['Belt_Speed_',num2str(index)],num2str(eval(['Transfer_Belt_Speed_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
       % this writes some state information to the unit, giving it the state
       % of the whole transfer line based on assessing the feed and
       % gtarsnefr and using the most accurate data to determine the
       % overall local state of that line segment.     
        state_write = eval(['State_Read_',num2str(index)]);
        if length(state_write) == 2
             fprintf(fid,global_state_2_format,'State',num2str(state_write(1)),num2str(state_write(2)));
             messages_data_write_amount = messages_data_write_amount + 16;
        elseif length(state_write) ==3
             fprintf(fid,global_state_3_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)));
             messages_data_write_amount = messages_data_write_amount + 24;
        elseif length(state_write) == 4
             fprintf(fid,global_state_4_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)),num2str(state_write(4)));
             messages_data_write_amount = messages_data_write_amount + 32;
        else
             disp('State Vector Not Recognised')
             messages_data_write_amount = messages_data_write_amount + 16;
        end 
        fprintf(fid,'\r\n');
        % finish the file write oeprations for the transfer unit 
        fclose(fid); 
        % having updated put down the update flag 
        eval(['Update_Transfer_',num2str(index),'=0;'])
        disp(['Updated Transfer ',num2str(index) ' Instructions'])
        toc
    end 
    
    % check if the main line section needs to be updated 
    if eval(['Update_Main_',num2str(index)]) == 1
        % open a relevant file in the data bus for the instructions to go
        % into 
        disp(['Updating Mainline Unit ',num2str(index),' Instructions'])
        toc
        % print some of the relevant flags into the file first in the
        % correct format. 
        fid =fopen([path2databus, eval(['filepath_main_',num2str(index)])],'w');
        fprintf(fid,global_write_file_format,'Flag','Hold',num2str(eval(['Hold_Main_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['Mainline_Clear_',num2str(index)],eval(['Mainline_Clear_',num2str(index)]));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
        fprintf(fid,global_write_file_format,'Flag',['Belt_Speed_',num2str(index)],num2str(eval(['Mainline_Belt_Speed_',num2str(index)])));
        fprintf(fid,'\r\n');
        messages_data_write_amount = messages_data_write_amount + 16;
       % this writes some state information to the unit, giving it the state
       % of the transfer line preceding it based on assessing the feed and
       % tarsnefr and using the most accurate data to determine the
       % overall local state of that line segment such that arrivals and exits can be determined .
        state_write = eval(['State_Read_',num2str(index+Number_of_Feedlines)]);
        if length(state_write) == 2
             fprintf(fid,global_state_2_format,'State',num2str(state_write(1)),num2str(state_write(2)));
             messages_data_write_amount = messages_data_write_amount + 16;
        elseif length(state_write) ==3
             fprintf(fid,global_state_3_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)));
             messages_data_write_amount = messages_data_write_amount + 24;
        elseif length(state_write) == 4
             fprintf(fid,global_state_4_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)),num2str(state_write(4)));
             messages_data_write_amount = messages_data_write_amount + 32;
        else
             disp('State Vector Not Recognised')
             messages_data_write_amount = messages_data_write_amount + 16;
        end 
        % for the upstream feedlines present the downstream data to them to
        % allow them to make a decision about the downstream transfer line 
        fprintf(fid,'\r\n');
        if exist('Main_id','var')
            if index > 1
                    state_write = eval(['State_Read_',num2str(index+Number_of_Feedlines-1)]);
                    if length(state_write) == 2
                         fprintf(fid,global_state_2_format,'Downstream_State',num2str(state_write(1)),num2str(state_write(2)));
                         messages_data_write_amount = messages_data_write_amount + 16;
                    elseif length(state_write) ==3
                         fprintf(fid,global_state_3_format,'Downstream_State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)));
                         messages_data_write_amount = messages_data_write_amount + 24;
                    elseif length(state_write) == 4
                         fprintf(fid,global_state_4_format,'Downstream_State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)),num2str(state_write(4)));
                         messages_data_write_amount = messages_data_write_amount + 32;
                    else
                         disp('State Vector Not Recognised')
                         messages_data_write_amount = messages_data_write_amount + 16;
                         fprintf('No Downstream State Vector')
                    end 
            end
        end 
        fprintf(fid,'\r\n');
        fclose(fid); 
        % having updated put down the update flag 
        eval(['Update_Main_',num2str(index),'=0;'])
        disp(['Updated Main ',num2str(index) ' Instructions'])
        toc
        
    end % end of if update main
    if Upstream{1} == '1' 
            fid =fopen([path2databus,filename_global_instructions],'w');
            state_write = eval(['State_Read_',num2str(2*Number_of_Feedlines)]);
            if length(state_write) == 2
                fprintf(fid,global_state_2_format,'State',num2str(state_write(1)),num2str(state_write(2)));
                messages_data_write_amount = messages_data_write_amount + 16;
            elseif length(state_write) ==3
                fprintf(fid,global_state_3_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)));
                messages_data_write_amount = messages_data_write_amount + 24;
            elseif length(state_write) == 4
                fprintf(fid,global_state_4_format,'State',num2str(state_write(1)),num2str(state_write(2)),num2str(state_write(3)),num2str(state_write(4)));
                messages_data_write_amount = messages_data_write_amount + 32;
            else
                disp('State Vector Not Recognised')
                messages_data_write_amount = messages_data_write_amount + 16;
            end 
            fprintf(fid,'\r\n');
            fclose(fid);
     end % end of if upstream
end % end of for loop over index for all lines
disp('Finished Updating Instructions')
toc