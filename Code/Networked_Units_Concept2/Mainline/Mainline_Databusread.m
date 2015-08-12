 % Mainline_Databusread.m - Script file which will read in the data that is
 % required by the mainline from the surrounding units 
%entering_check
    %% entering check replacement code
    disp('Running an Entering Check - networked')
        if exist(filepath_local_Mval)~= 0 
            fid=fopen(filepath_local_Mval,'r');
            out=textscan(fid,local_format);
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')
            else     
                val_exiting_downstream=str2num(out{1,1}{1,1});
                mainlineclear_entry = str2num(out{1,2}{1,1});
                Ent_matrix = [Ent_matrix; toc, val_exiting_downstream,mainlineclear_entry];
                save(filepath_entval, 'Ent_matrix')
                if val_exiting_downstream > mainlineclear_entry
                    disp('A Package is Detected at entry')
                    toc
                    if entering_previous_pallet == 0
                        time_in_last = toc;
                        disp('A Pallet has Entered the Line')
                        toc
                        %increment number of pallets on mainline 
                        no_pallets_mainline = no_pallets_mainline +1; 
                        enteringflag=1; 
                    end 
                    entering_previous_pallet=1;
                else
                    disp('The Mainline is Clear') 
                    toc
                    % reset the previous pallet flag to show there was no pallet present at
                    % last check 
                    entering_previous_pallet=0; 
                    time_in_last = toc; 
                end
                sensor_data_read_amount = sensor_data_read_amount + 16;
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            enteringflag =0; 
        end

%%
    exiting_check
    %transfer_check
%%  Section for running a Transferline check 
disp('Running an TransferlineCheck-New')
        if exist(filepath_Platformstatus_main_light)~= 0 
            fid=fopen(filepath_Platformstatus_main_light,'r');
            out=textscan(fid,'%s %s');
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')    
            else     
                val = str2num(out{1,1}{1,1});
                mainlineclear_Buffer = str2num(out{1,2}{1,1});
                if val > mainlineclear_Buffer % 05/10/11: If val higher than threshold, then pallet present at end of transfer
                    armcheck = armcheck + 1;  % Armcheck means that light sensor has to flash twice to detect pallet. This stops the sensor accidentally picking up the transfer arm as it swings back.
                    if armcheck == 2
                        platform_dowsntream_input = 1;
                        transfer_previous_pallet=1;
                        armcheck = 0; % reset armcheck flag 
                        disp('A Pallet Has Been Detected at Position e')
                        toc
                    end
                end
                if val <= mainlineclear_Buffer; % 05/10/11: If val lower than threshold, then no pallet present at the end of the transfer unit.
                    platform_dowsntream_input = 0;
                    armcheck = 0;  % 05/10/11: Resets armcheck flag
                    disp('No Pallet Has Been Detected at Position e')
                %checking if a pallet has been cleared  
                if platform_dowsntream_input == 0  && transfer_previous_pallet == 1% 05/10/11: If currently no pallet present, but delay flag has been reset (i.e. previously was a pallet there).
                    disp('A Pallet has Entered the Line') 
                    no_pallets_mainline=no_pallets_mainline+1;
                    enteringflag = 1; 
                end
                transfer_previous_pallet=0;
                end
                sensor_data_read_amount = sensor_data_read_amount + 16;
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            enteringflag = 0; 
        end
%% Section for running a networked downstream check
if downstream_sensor == 1
disp('Attempting a Networked Sensor Check for a Blockage- Checking Light Sensor')
    if exist(filepath_local_downstream_blockage) ~= 0
            fid=fopen(filepath_local_downstream_blockage,'r');
            out=textscan(fid,'%s %s');
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')    
            else            
                val_exiting_downstream = str2num(out{1,1}{1,1});
                mainlineclear3 = str2num(out{1,2}{1,1});
                Transfer_Down_matrix = [Transfer_Down_matrix; toc, val_exiting_downstream,mainlineclear3];
                save(filepath_transval, 'Transfer_Down_matrix')
                if val_exiting_downstream > mainlineclear3
                    disp('The Downstream Line Has A Pallet Present')
                    downstream_pallet=1;
                else
                    disp('The Downstream Line is Clear') 
                    toc
                    downstream_pallet=0; 
                end
                sensor_data_read_amount = sensor_data_read_amount + 16;
            end
    else 
        disp('The File has not Been Created Yet')
        downstream_pallet = 0; 
    end 
%     disp('Attempting to Check the Touch Sensor on The Platform')
%     if exist(filepath_local_pushswitch)~= 0 
%             fid=fopen(filepath_local_pushswitch,'r');
%             out=textscan(fid,'%s');
%             fclose(fid);
%             if isempty(out{1,1})
%                 disp('Data is currently writing-use old value')    
%             else     
%                 platform_dowsntream_input = str2num(out{1,1}{1,1});
%             end
%         else
%             disp('File Not Yet Created- No Data Loaded')
%             platform_dowsntream_input =0; 
%     end
 % make a decision if the transfer is occuring i.e. whether the platform is up OR if the sensor is blocked   
    if   downstream_pallet == 1 %||platform_dowsntream_input == 1
        blockage = 1; 
    else
        blockage = 0; 
    end
    disp('The Value of Blockage is')
    disp(blockage)
elseif downstream_sensor == 0
    disp('No Data Available - Running Own Check')
    transferline_clear
end
%% Using Networked Sensors to Determine if the Pallet has Exited the second section of belt 
if downstream_sensor == 1
disp('Running an Exiting Check - Networked')
        if exist(filepath_exitval2)~= 0 
            fid=fopen(filepath_exitval2,'r');
            out=textscan(fid,local_format);
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')
            else     
                val_exiting_downstream=str2num(out{1,1}{1,1});
                mainlineclear_exit2 = str2num(out{1,2}{1,1});
                
                if val_exiting_downstream > mainlineclear_exit2
                    disp('A Package is Detected at Exit')
                    toc 
                    previous_exiting_package = 1;
                else
                    disp('The Mainline is Clear') 
                    toc
                    if previous_exiting_package ==  1
                        disp('A Pallet Has Just Left The Line')
                        if No_pallets_mainline2 > 0
                            No_pallets_mainline2 = No_pallets_mainline2 - 1;
                        end 
                    end
                    previous_exiting_package = 0;
                end
                sensor_data_read_amount = sensor_data_read_amount + 16;
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            downstream_transfer =0;
        end
else 
    disp('No Downstream Data is Available- Running On Timer Mode')
end