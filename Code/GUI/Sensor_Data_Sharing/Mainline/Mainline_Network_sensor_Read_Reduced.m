 % Mainline_Network_sensor_Read_Reduced - script which contains the working
 % code to poll the networked sensors required for the mainline operations
 
%entering_check
    %% entering check replacement code
    disp('Running an Entering Check - networked')
        if exist(filepath_Mval_main)~= 0 
            fid=fopen(filepath_Mval_main,'r');
            out=textscan(fid,local_format);
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')
            else     
                val_entering=str2num(out{1,1}{1,1});
                mainlineclear_entry = str2num(out{1,2}{1,1});
                Ent_matrix = [Ent_matrix; toc, val_entering,mainlineclear_entry];
                save(filepath_entval, 'Ent_matrix')
                if val_entering > mainlineclear_entry
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
                sensor_data_read_amount=sensor_data_read_amount+16;
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            enteringflag =0; 
        end

%%
    exiting_check
    %transfer_check
%%  Section for running a Transferline check 
disp('Running a TransferlineCheck-New')
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
                        transfer_input = 1;
                        transfer_previous_pallet=1;
                        armcheck = 0; % reset armcheck flag 
                        disp('A Pallet Has Been Detected at Position e')
                        toc
                    end
                end
                if val <= mainlineclear_Buffer; % 05/10/11: If val lower than threshold, then no pallet present at the end of the transfer unit.
                    transfer_input = 0;
                    armcheck = 0;  % 05/10/11: Resets armcheck flag
                    disp('No Pallet Has Been Detected at Position e')
                %checking if a pallet has been cleared  
                if transfer_input == 0  && transfer_previous_pallet == 1% 05/10/11: If currently no pallet present, but delay flag has been reset (i.e. previously was a pallet there).
                    disp('A Pallet has Entered the Line') 
                    no_pallets_mainline=no_pallets_mainline+1;
                    enteringflag = 1; 
                end
                transfer_previous_pallet=0;
                end
                sensor_data_read_amount=sensor_data_read_amount+16;
            end
        else
            disp('File Not Yet Created- No Data Loaded')
            enteringflag = 0; 
        end
%% Section for running a networked downstream check
transferline_clear
%%