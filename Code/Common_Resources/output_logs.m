% Output_logs.m - a script file called by the feed units at the end of
% their run to create the log files which have the timing data for that run
% and to be presented to the user for inclusion in reports or projects 

% case for each feed unit greater than zero open a file with the appropriate name 
% Feed_X_times.txt in which to place the data 
if feed_id > 0
    filename_output=['Feed_',num2str(feed_id),'_times.txt'];
    filepath_output=[path2feedlog filename_output];  
    file_1=fopen(filepath_output,'w');
end 

% special case for the upstream units filename, otherwise it acts as a
% normal feed unit 
if feed_id ==0
    file_1 = fopen(path2feedlogupstream,'wt');   
end

% setup a title, date and heading by taking the time from the clock and the
% unit name into the title 
time = clock;
title=strcat('Feed Unit  ',num2str(feed_id),' Delivery Schedule');
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1)),'\r\n','\r\n'];
Headings ={'Number','Time','In','Out'};

% table formatting data 
Heading_Format =('%6s %6s %6s %6s\r\n');
Line_Format=('%6.0u %6.1f %6.1fs %6.1f\r\n');
size_table = size(feed_times);

% print the heading to the file 
fprintf(file_1,title);
fprintf(file_1,'\r\n');
fprintf(file_1,date);
fprintf(file_1,'error = ');
fprintf(file_1,error_type);
fprintf(file_1,'\r\n');
fprintf(file_1,'\r\n');
fprintf(file_1,Heading_Format,Headings{1},Headings{2},Headings{3},Headings{4});

% loop to print the main body of the table by iterating over all of the
% entities in the stored table from the run 
for i= 1:size_table(1)
    fprintf(file_1,Line_Format,feed_times(i,1),feed_times(i,2),feed_times(i,3),feed_times(i,4));   
end
% print some spaces 
for n = 1:4
    fprintf(file_1,'\r\n');
end

% loop to print the final status of the line , loop along the length of the
% status vector printing off each of the elements
fprintf(file_1,'%d ',a);
if feed_id ~= 0
    fprintf(file_1,'%d ',status);
end

% close the file 
fclose(file_1);
