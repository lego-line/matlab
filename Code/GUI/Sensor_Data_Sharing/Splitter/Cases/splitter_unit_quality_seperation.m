% splitter_unit_quality_seperation - script to perform seperation of the pallets in quality control mode.
% Those pallets not matching the quality control table set in the config
% file will be removed.  This script is called by splitter_setup 

% if in the mode to read the pallet code Read config and set pallet code for separation
fid = fopen(path2config,'rt');

%Scan within file for text with certain formatting
out2 = textscan(fid,'%s	%s %s %s');
fclose(fid);

string = strcat('redcode',num2str(Splitter_id));
idcol = strmatch(string,out2{1});
SplitterSettings([1,2,3]) = [out2{2}(idcol),out2{3}(idcol),out2{4}(idcol)];
red_code=[str2num(SplitterSettings{1}) str2num(SplitterSettings{2}) str2num(SplitterSettings{3})];
  
string = strcat('bluecode',num2str(Splitter_id));
idcol = strmatch(string,out2{1});
SplitterSettings([1,2,3]) = [out2{2}(idcol),out2{3}(idcol),out2{4}(idcol)];
blue_code=[str2num(SplitterSettings{1}) str2num(SplitterSettings{2}) str2num(SplitterSettings{3})];
  
string = strcat('yellowcode',num2str(Splitter_id));
idcol = strmatch(string,out2{1});
SplitterSettings([1,2,3]) = [out2{2}(idcol),out2{3}(idcol),out2{4}(idcol)];
yellow_code=[str2num(SplitterSettings{1}) str2num(SplitterSettings{2}) str2num(SplitterSettings{3})] ;

string = strcat('darkgreycode',num2str(Splitter_id));
idcol = strmatch(string,out2{1});
SplitterSettings([1,2,3]) = [out2{2}(idcol),out2{3}(idcol),out2{4}(idcol)];
dgreycode=[str2num(SplitterSettings{1}) str2num(SplitterSettings{2}) str2num(SplitterSettings{3})];

string = strcat('lightgreycode',num2str(Splitter_id));
idcol = strmatch(string,out2{1});
SplitterSettings([1,2,3]) = [out2{2}(idcol),out2{3}(idcol),out2{4}(idcol)];
lgreycode=[str2num(SplitterSettings{1}) str2num(SplitterSettings{2}) str2num(SplitterSettings{3})];
 
Go = exist (path2go);
disp('Waiting to start')
time_to_pusher = 6.5;

initial_length_pallet_table =0; 
unsatisfactory_flag =0; % variable to store whetehr the current pallet has not met the specification requirements.


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

%check the length of the pallet table    
initial_length_pallet_table = size(palletlist,1);
Read_Crate_Colour
Read_Crate_Code


%  if the size of the pallet table is greater than the initial size of the
%  pallet table a new pallet has been added and must be assessed for
%  quality. 
	if  size(palletlist,1) > initial_length_pallet_table
        % perform a quality control check on the new pallet 
        switch palletlist(size(palletlist,1),6) % switch based on the colour of the pallet
            case 1
                disp('Pallet is Dark Gray')
                if dgreycode(1) ~= palletlist(size(palletlist,1),3) || dgreycode(2) ~= palletlist(size(palletlist,1),4) || dgreycode(3) ~= palletlist(size(palletlist,1),5)
                    disp('The Pallet was Unsatisfatory and is Being Seperated')
                    unsatisfactory_flag = 1;
                else
                    disp('The Pallet was satisfatory')
                end
            case 2
                disp('Pallet is Light Gray')
                if lgreycode(1) ~= palletlist(size(palletlist,1),3) || lgreycode(2) ~= palletlist(size(palletlist,1),4) || lgreycode(3) ~= palletlist(size(palletlist,1),5)
                    disp('The Pallet was Unsatisfatory and is Being Seperated')
                    unsatisfactory_flag = 1;
                else
                    disp('The Pallet was satisfatory')
                end
            case 3
                disp('Pallet is Blue')
                if blue_code(1) ~= palletlist(size(palletlist,1),3) || blue_code(2) ~= palletlist(size(palletlist,1),4) || blue_code(3) ~= palletlist(size(palletlist,1),5)
                    disp('The Pallet was Unsatisfatory and is Being Seperated')
                    unsatisfactory_flag = 1;
                else
                    disp('The Pallet was satisfatory')
                end
            case 4
                disp('Pallet is Yellow Gray')
                if yellow_code(1) ~= palletlist(size(palletlist,1),3) || yellow_code(2) ~= palletlist(size(palletlist,1),4) || yellow_code(3) ~= palletlist(size(palletlist,1),5)
                    disp('The Pallet was Unsatisfatory and is Being Seperated')
                    unsatisfactory_flag = 1;
                else
                    disp('The Pallet was satisfatory')
                end
            case 5
                disp('Pallet is Red')
                if red_code(1) ~= palletlist(size(palletlist,1),3) || red_code(2) ~= palletlist(size(palletlist,1),4) || red_code(3) ~= palletlist(size(palletlist,1),5)
                    disp('The Pallet was Unsatisfatory and is Being Seperated')
                    unsatisfactory_flag = 1;
                else
                    disp('The Pallet was satisfatory')
                end
        end
        % add it to the output table to deal with the psuher arm 
        if unsatisfactory_flag == 1
            time_out = toc;
            output_table =[output_table;time_out,0];
            registered = 1;     
            unsatisfactory_flag =0; 
        end
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