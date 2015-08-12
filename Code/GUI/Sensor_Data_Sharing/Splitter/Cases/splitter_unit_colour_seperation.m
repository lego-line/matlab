% Splitter_unit_colour_seperation - splitter unit script to seperate palelts based on the colour- pallets
% matching the read colour will be seperated by this unit, called by setup
% splitter

% if in the mode to read the pallet code Read config and set pallet code for separation
fid = fopen(path2config,'rt');
%Scan within file for text with certain formatting
out2 = textscan(fid,'%s	%s');
fclose(fid);
serahcval2=strcat('ColourCode',num2str(Splitter_id));
set = strmatch(serahcval2,out2{1});
read_colour =out2{2}(set);
disp('The Colour To Be Seperated is')
disp(read_colour)

if strmatch('Dark Gray',read_colour) == 1
        Seperated_Colour = 1;
end
if strmatch('Light Gray',read_colour) == 1
        Seperated_Colour = 2;
end
if strmatch('Blue',read_colour) == 1
        Seperated_Colour = 3;
end
        
if strmatch('Yellow',read_colour) == 1
        Seperated_Colour = 4;
end
if strmatch('Red',read_colour) == 1
        Seperated_Colour = 5;
end
 
time_to_pusher = 12.5;

Go = exist (path2go);
disp('Waiting to start')
while Go == 0 && Failure_Flag == 0%While control file GO.txt does not exist stay in this loop
Go = exist (path2go);
pause (0.2); %Tiny pause so that loop uses insignificant processing power
end

%% Operations Section 

tic; % start the clock 

belt_go.SendToNXT(splitter);
disp('turned on motors')

% setup the light sensor matrices and take readings to get a baseline level
% for detection.
Read_Crate_Code;
first_run =0; 

Go = exist (path2go);

while Go == 2 && Failure_Flag == 0%Keep running loop while GO.txt exists
Read_Crate_Colour
Read_Crate_Code
%  if the colour matches then execute the push routine to seperate the pallet
	if  colour_flag == 0 %If current pallet = colour then activate pusher after a few seconds
        disp('A Pallet with the colour has been detected, seperating pallet')
        toc 
        time_out = toc;
        output_table =[output_table;time_out,0];
        registered = 1; 
        colour_flag =1; % revert the flag to show that the event has been handled. 
    end
    sizeofoutput= size(output_table);
    if sizeofoutput(1) >= line_pointer
        % if the size of the output table is greater than or equal to the
        % size of the line pointer there are more pallets in need of
        % seperating 
        Seperate_Pallet;
    end
%pause(0.05)
Go = exist (path2go); %Check that GO.txt still exists

fault_matrix=[fault_matrix;toc,fault_flag];
end