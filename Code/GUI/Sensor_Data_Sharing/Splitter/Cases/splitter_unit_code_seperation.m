% splitter_unit_code_seperation-splitter unit script to seperate pallets based on the 3 bit code on the
% side. Pallets codes a read left to right by eye, an open passage is a 0 a
% blocked passage is a 1. The code to be seperated is set in the config
% file for the unit- clalled by setup_splitter.m. 

% if in the mode to read the pallet code Read config and set pallet code for separation
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out2 = textscan(fid,'%s	%s	%s	%s');
fclose(fid);
serachval2= strcat('PalletCode',num2str(Splitter_id));
set = strmatch(serachval2,out2{1});
	%Place values from array ind into Matrix LineA
SplitterSettings([1,2,3]) = [out2{2}(set),out2{3}(set),out2{4}(set)];
code=[str2num(SplitterSettings{1}) str2num(SplitterSettings{2}) str2num(SplitterSettings{3})]; 
disp('The Code to be seperated is')
disp(code)

Go = exist (path2go);
disp('Waiting to start')
time_to_pusher = 6.5;

while Go == 0 && Failure_Flag == 0%While control file GO.txt does not exist stay in this loop
Go = exist (path2go);
pause (0.2); %Tiny pause so that loop uses insignificant processing power
end

%% Operations Section 

tic; % start the clock 
if upstream_sensor == 0
    belt_go.SendToNXT(splitter);
    disp('turned on motors')
end 

% setup the light sensor matrices and take readings to get a baseline level
% for detection.
Read_Crate_Code;
first_run =0; 

Go = exist (path2go);

while Go == 2 && Failure_Flag == 0%Keep running loop while GO.txt exists
Read_Crate_Colour
Read_Crate_Code

if upstream_sensor == 1 % section to handle the case where there is an upstream unit and so belt can be controlled
%% Section to take the sensor reading    
    
    if exist(filepath_sensor)~= 0 
            fid=fopen(filepath_sensor,'r');
            out=textscan(fid,'%s %s');
            fclose(fid);
            if isempty(out{1,1})
                disp('Data is currently writing-use old value')
            else     
                val_entering=str2num(out{1,1}{1,1});
                mainlineclear_entry = str2num(out{1,2}{1,1});
                if val_entering>mainlineclear_entry
                        disp('A Package is Detected at entry')
                        toc 
                        entering_previous_pallet = 1; 
                else
                        disp('The Mainline is Clear') 
                        toc
                        % now check if there was previously a pallet such
                        % that it is known that a pallet is about to arrive
                        % at the splitter
                        if entering_previous_pallet == 1
                            disp('A Pallet is about to arrive at the splitter')
                            % update the time to start and the time to stop
                            % running appropriately. These values are
                            % dependant on the speed on the splitter 
                            time_to_start_running = toc + 5;
                            time_to_finish_running = toc + 20; 
                        end 
                        entering_previous_pallet=0; 
                        time_in_last = toc;
                end
            end
        else
            disp('File Not Yet Created- No Data Loaded')
        end
 
%% section to control the belt operatiuons    
    if isempty(time_to_start) ~= 1 % if this array is empty then no pallet has been deetcted yet - take no action
        disp('No Pallets Have Arrived Yet-No action Taken')
    else % else if pallets have arrived then take some action
        if belt_running == 0 && toc >= time_to_start_running
            belt_go.SendToNXT(Splitter)
            belt_running = 1;
        elseif belt_running == 1 && toc >= time_to_stop_running
            belt_stop.SendToNXt(Splitter) 
            belt_running = 0; 
        end 
    end 
end
% section to make a decision about if the pallet should go 
%  if the code matches then execute the push routine to seperate the pallet
	if current(1) == code(1) && current(2) == code(2) && current(3) == code(3) && registered == 0 %If current pallet = code then activate pusher after a few seconds
        disp('A Pallet with the code has been detected, seperating pallet')
        toc 
        time_out = toc;
        output_table =[output_table;time_out,0];
        registered = 1; 
    end
    sizeofoutput= size(output_table);
    if sizeofoutput(1) >= line_pointer
        % if the size of the output table is greater than or equal to the
        % size of the line pointer there are more pallets in need of
        % seperating 
        Seperate_Pallet;
    end
Go = exist (path2go); %Check that GO.txt still exists

fault_matrix=[fault_matrix;toc,fault_flag];
end