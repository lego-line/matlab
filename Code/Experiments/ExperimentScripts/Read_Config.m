% script to read in the experimental data from the config file 

% read in the data from the config file extracting the bits used by the
% code files to extract the data which they want from the file 
fid=fopen(path2writableconfig,'rt');
out=textscan(fid,'%s %s %s %s %s');
fclose(fid);

fid=fopen(path2writableconfig,'rt');
out2=textscan(fid,'%s %s');
fclose(fid);

fid=fopen(path2writableconfig,'rt');
out3=textscan(fid,'%s %s %s');
fclose(fid);

fid=fopen(path2writableconfig,'rt');
out4=textscan(fid,'%s %s %s %s');
fclose(fid);

fid=fopen(path2writableconfig,'rt');
out5=textscan(fid,'%s %s %s %s %s');
fclose(fid);

% create empty arrays into which data from each format can be stored
Relevant2=[];
Relevant3=[];
Relevant4=[];
Relevant5=[];


%% Section To Read The Relevant Data from the file and create editable
%% arrays that can be written back to a new config file 

% 2 Column Data Format
test_ind =strmatch('Control_Method',out2{1});
line=[out2{1}(test_ind),out2{2}(test_ind)];
Relevant2=[Relevant2;line];

test_ind=strmatch('Run_Downstream_Units',out2{1});
line=[out2{1}(test_ind),out2{2}(test_ind)];
Relevant2=[Relevant2;line];

test_ind=strmatch('ColourCode1',out2{1});
line=[out2{1}(test_ind),out2{2}(test_ind)];
Relevant2=[Relevant2;line];

test_ind=strmatch('ColourCode2',out2{1});
line=[out2{1}(test_ind),out2{2}(test_ind)];
Relevant2=[Relevant2;line];



% 3 column data format
test_ind=strmatch('Upstream',out3{1});
line=[out3{1}(test_ind),out3{2}(test_ind),out3{3}(test_ind)];
Relevant3=[Relevant3;line];

test_ind=strmatch('Splitter1',out3{1});
line=[out3{1}(test_ind),out3{2}(test_ind),out3{3}(test_ind)];
Relevant3=[Relevant3;line];

test_ind=strmatch('Splitter2',out3{1});
line=[out3{1}(test_ind),out3{2}(test_ind),out3{3}(test_ind)];
Relevant3=[Relevant3;line];


% 4 Column Data Format
test_ind=strmatch('PalletCode1',out4{1});
line=[out4{1}(test_ind),out4{2}(test_ind),out4{3}(test_ind),out4{4}(test_ind)];
Relevant4=[Relevant4;line];

test_ind=strmatch('PalletCode2',out4{1});
line=[out4{1}(test_ind),out4{2}(test_ind),out4{3}(test_ind),out4{4}(test_ind)];
Relevant4=[Relevant4;line];


test_ind=strmatch('Line1',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
Relevant5=[Relevant5;line];

test_ind=strmatch('Line2',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
Relevant5=[Relevant5;line];

test_ind=strmatch('Line3',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
Relevant5=[Relevant5;line];

line ={'Line4','0','0','0','0'};
Relevant5=[Relevant5;line];
line ={'Line5','0','0','0','0'};
Relevant5=[Relevant5;line];

% 5 column data format
test_ind=strmatch('ControlLine1',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
Relevant5=[Relevant5;line];

test_ind=strmatch('ControlLine2',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
Relevant5=[Relevant5;line];

test_ind=strmatch('ControlLine3',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
Relevant5=[Relevant5;line];

line ={'ControlLine4','P','0','0','0'};
Relevant5=[Relevant5;line];
line ={'ControlLine5','P','0','0','0'};
Relevant5=[Relevant5;line];

test_ind=strmatch('ControlUpstr',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
Relevant5=[Relevant5;line];

% if the splitter has been disabled re-enable it for running experiments as
% it is the only way of measuring throughput
if Relevant2{1,2} == '0'
    Relevant2{1,2} ='1';
end

%% Section to Find Variables Within the Output That Will Be Used In The
% Experiment 


% find the time to pass
index = strmatch('Pass_Time',out{1});
Time_To_Pass = out{2}(index);
Time_To_Pass = str2num(Time_To_Pass{1});

% find the rate step 
index = strmatch('Rate_Step',out{1});
RateStep= out{2}(index);
RateStep= str2num(RateStep{1});

% find the minimum rate possible 
index = strmatch('Minimum_Rate',out{1});
Min_Rate= out{2}(index);
Min_Rate= str2num(Min_Rate{1});

%Find the Initial Rate 
index = strmatch('Initial_Rate',out{1});
Initial_Rate= out{2}(index);
Initial_Rate= str2num(Initial_Rate{1});

% find the pallet buffer step 
index = strmatch('Buffer_Step',out{1});
PalletStep= out{2}(index);
PalletStep= str2num(PalletStep{1});

% find the minimum size possible 
index = strmatch('Minimum_Size',out{1});
Min_Size= out{2}(index);
Min_Size= str2num(Min_Size{1});

%Find the Initial size 
index = strmatch('Maximum_Size',out{1});
Maximum_Size= out{2}(index);
Maximum_Size= str2num(Maximum_Size{1});