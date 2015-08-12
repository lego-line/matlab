% splitter_unit_code_seperation-splitter unit script to seperate pallets based on the 3 bit code on the
% side. Pallets codes a read left to right by eye, an open passage is a 0 a
% blocked passage is a 1. The code to be seperated is set in the config
% file for the unit- clalled by setup_splitter.m. 

disp('Reading the Code To Separate From File')
toc 
% if in the mode to read the pallet code Read config and set pallet code for separation
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out2 = textscan(fid,'%s	%s	%s	%s');
fclose(fid);
% hunt down the relavant key word int he first column 
serachval2= strcat('PalletCode',num2str(Splitter_id));
set = strmatch(serachval2,out2{1});
%Place values from array ind into Matrix LineA
SplitterSettings([1,2,3]) = [out2{2}(set),out2{3}(set),out2{4}(set)];
code=[str2num(SplitterSettings{1}) str2num(SplitterSettings{2}) str2num(SplitterSettings{3})]; 
% display the code which is to be separated such that it is apaprent in the
% logs. 
disp('The Code to be seperated is')
disp(code)
disp('Finished Reading Code From File')
toc 
%% Setup variables and Waiting Section. 
time_to_pusher = 6;% this defines the time from when the pallet exist the gate to when it 
% reaches the pusher arm location such that we can push it when it is
% aligned if necessary. 

disp('Waiting to start')
toc; 
disp('---------------------------------------------------------------')
Go = exist (path2go);
while Go == 0 && Failure_Flag == 0 %While control file GO.txt does not exist stay in this loop
    Go = exist (path2go);
    pause (0.2); %Tiny pause so that loop uses insignificant processing power
end

%% Operations Section 
disp('Started Operations') 
tic; % start the clock 
% start the belt going 
belt_go.SendToNXT(splitter);
disp('turned on motors')
toc 
% setup the light sensor matrices and take readings to get a baseline level
% for detection by running the sensor scripts in first run mode, then lower
% the first run flag. 
Read_Crate_Colour
Read_Crate_Code;
first_run =0; 
Go = exist (path2go);
%% Main Operating Loop 
while Go == 2 && Failure_Flag == 0%Keep running loop while GO.txt exists
    disp('Start of Loop')
    toc 
    % First we colelct data to assess the satte of the plallet.Ideally this
    % would be a parallel process, but this sequential multitasking will
    % have to do. 
    Read_Crate_Colour
    Read_Crate_Code
    %  if the code matches then execute the push routine to seperate the pallet
	if current(1) == code(1) && current(2) == code(2) && current(3) == code(3) && registered == 0 
        %If current pallet = code then activate pusher after a few seconds
        disp('A Pallet with the code has been detected, seperating pallet')
        toc 
        % record the time of the palelt leaving the line by pusching into
        % the output table as well as a 0 to show it was rejected. 
        time_out = toc;
        output_table =[output_table;time_out,0];
        % set the registered flag to show that the exit ahs been
        % registered. 
        registered = 1; 
    end
    sizeofoutput= size(output_table);
    if sizeofoutput(1) >= line_pointer
        disp('We are needing to Separate a Pallet')
        toc 
        % if the size of the output table is greater than or equal to the
        % size of the line pointer there are more pallets in need of
        % seperating 
        Seperate_Pallet;
    end
    % update the fault matrix and check that go still exists so we can
    % continue around the loop. 
    disp('End of Loop')
    toc
    disp('---------------------------------------------------------------')
    fault_matrix=[fault_matrix;toc,fault_flag];
    Go = exist (path2go); %Check that GO.txt still exists
end