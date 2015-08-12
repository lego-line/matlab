% process_results.m-- a file to take the resutls matrices output by the
% legoline unit and combine them into a table which can be read or have
% graphs plotted from it

% get the data from the splitter unit about throughput. 
load splitter_results
Throughput = pallet_number;
clear pallet_number

% loop through the 3 lines and read the results data 

if Relevant4{2,2} == '1' || Relevant4{3,2} == '1' || Relevant4{4,2} == '1'
load main_1_results
M1 = total_remaining;
clear total_remaining 
else
M1=0; 
end 

if Relevant4{3,2} == '1' || Relevant4{4,2} == '1'
load main_2_results
M2 = total_remaining;
clear total_remaining 
else 
M2= 0; 
end


if Relevant4{2,2} == '1'
load transfer_1_results
ind = find(state);
T1 = length(ind);
clear state

load feed_1_results
Buffer_1 = str2num(Relevant4{2,3});
comments{1} = error_type;
F1=str2num(Relevant5{1,3});
T1= T1 + a;
clear buffer_number
clear error_type
clear a
clear t
else
T1 = 0;
Buffer_1 = 0;
F1= 0;
comments{1} = 'Unused';
end

if Relevant4{3,2} == '1'

load transfer_2_results
ind = find(state);
T2 = length(ind);
clear state

load feed_2_results
Buffer_2 = str2num(Relevant4{3,3});
comments{2} = error_type;
F2=str2num(Relevant5{2,3});
T2= T2 + a;
clear buffer_number
clear error_type
clear a
clear t
else
T2 = 0; 
Buffer_2 = 0;
F2= 0;
comments{2} = 'Unused';
end


if Relevant4{4,2} == '1'
load transfer_3_results
ind = find(state);
T3 = length(ind);
clear state

load main_3_results
M3 = total_remaining;
clear total_remaining 

load feed_3_results
Buffer_3 = str2num(Relevant4{4,3});
comments{3} = error_type;
F3=str2num(Relevant5{3,3});
T3= T3 + a;
clear buffer_number
clear error_type
clear a
clear t
else
M3 = 0;
T3 = 0;
Buffer_3 = 0;
F3= 0;
comments{3} = 'Unused';     
end


current_line = [Run,F1,F2,F3,Throughput,M1,T1,M2,T2,M3,T3,Buffer_1,Buffer_2,Buffer_3];
