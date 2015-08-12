% Script to cleanup the results, output a .txt file of the results for
% printing and generate a csv file for imprting into the graphing module 

% some format variables and titles for the output files to give the report
% a fixed layout. 
Headings = {'Run','F1','F2','F3','Throughput','M1','T1','M2','T2','M3','T3','Buffer 1','Buffer 2','Buffer 3','Stop Time'};
Headings2 ={'Run','F1','F2','F3','Throughput','M1','T1','M2','T2','M3','T3','Buffer 1','Buffer 2','Buffer 3','Stop Time','Failed'};
TableHeadingFormat =('%4s %4s %4s %4s %10s %4s %4s %4s %4s %4s %4s %9s %9s %9s %10s \n');
TableLineFormat =('%4s %4s %4s %4s %10s %4s %4s %4s %4s %4s %4s %9s %9s %9s %10s \n');

% take the time to add to the report 
time = clock;
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1)),'\n','\n'];

% case for the feed rate experiment 
if Experiment_Type  == 1
    
    title = ['Feed Rate Experiment Results Table','\n'];
    % generate the printable .txt file 
    variables =round(([9;6;4]./180)*Time_To_Pass);
    X=[1;2;3];
    Y=[15 0 0;0 15 0;0 0 15];
    Z=[ 1 2 0 0 0 0 Results_Table(1,12) 0 0 Time_To_Pass 1;2 0 2 1 0 0 0 Results_Table(1,12) 0 Time_To_Pass 1; 3 0 2 0 1 2 0 0 Results_Table(1,12) Time_To_Pass 1];
    DefaultPoints=[X,Y,variables,Z];
    Results_Table=[DefaultPoints;Results_Table];
    Results_Output=num2cell(Results_Table);
    Size_Table=size(Results_Table);
    
    fout=fopen(path2feedrtexptoutputs,'w');
    fprintf(fout,title);
    fprintf(fout,date);
    fprintf(fout,TableHeadingFormat,Headings{1},Headings{2},Headings{3},Headings{4},Headings{5},Headings{6},Headings{7},Headings{8},Headings{9}...
        ,Headings{10},Headings{11},Headings{12},Headings{13},Headings{14},Headings{15});
    for i=1:Size_Table(1)
        fprintf(fout,TableLineFormat,num2str(Results_Output{i,1}),num2str(Results_Output{i,2}),num2str(Results_Output{i,3}),num2str(Results_Output{i,4}),num2str(Results_Output{i,5}),...
            num2str(Results_Output{i,6}),num2str(Results_Output{i,7}),num2str(Results_Output{i,8}),num2str(Results_Output{i,9}),num2str(Results_Output{i,10}),num2str(Results_Output{i,11}),...
            num2str(Results_Output{i,12}),num2str(Results_Output{i,13}),num2str(Results_Output{i,14}),num2str(Results_Output{i,15}));
    end
    fclose(fout)
   
    %generate the xls/csv file 
    xlswrite(path2feedrtexptcsv,Headings2,'Feed_Rate_Results','A1');
    xlswrite(path2feedrtexptcsv,Results_Table,'Feed_Rate_Results','B1');
end

% case for the transfer line buffer size experiment 
if Experiment_Type == 2
    % generate all of teh data needed for the report 
    title = ['Transfer Line Buffer Size Experiment Results Table','\n'];
    % add X, Y,Z and variables here
    X=[1;2;3];
    
    DefaultPoints=[X,Y,variables,Z];
    Results_Table=[DefaultPoints;Results_Table];
    Results_Output=num2cell(Results_Table);
    Size_Table=size(Results_Table);
    
    
    % generate the printable .txt file 
    fout=fopen(path2palletexptoutputs,'w');
    fprintf(fout,title);
    fprintf(fout,date);
    fprintf(fout,TableHeadingFormat,Headings{1},Headings{2},Headings{3},Headings{4},Headings{5},Headings{6},Headings{7},Headings{8},Headings{9}...
        ,Headings{10},Headings{11},Headings{12},Headings{13},Headings{14},Headings{15});
    for i=1:Size_Table(1)
        fprintf(fout,TableLineFormat,num2str(Results_Output{i,1}),num2str(Results_Output{i,2}),num2str(Results_Output{i,3}),num2str(Results_Output{i,4}),num2str(Results_Output{i,5}),...
            num2str(Results_Output{i,6}),num2str(Results_Output{i,7}),num2str(Results_Output{i,8}),num2str(Results_Output{i,9}),num2str(Results_Output{i,10}),num2str(Results_Output{i,11}),...
            num2str(Results_Output{i,12}),num2str(Results_Output{i,13}),num2str(Results_Output{i,14}),num2str(Results_Output{i,15}));
    end
    fclose(fout)
    
    %generate the xls/csv file 
    xlswrite(path2palletexptcsv,Headings2,'Buffer_Size_Results','A1');
    xlswrite(path2palletexptcsv,Results_Table,'Buffer_Size_Results','B1');
end


% perform a cleanup of the data files 
clear X
clear Y
clear Z
clear variables 
clear title
clear DefaultPoints
clear time
clear date
clear Headings
clear Headings2
clear TableLineFormat
clear TableHeadingFormat
clear Results_Output
clear Results_Table
clear Comments_Table
clear Size_Table
clear Time_To_Pass;