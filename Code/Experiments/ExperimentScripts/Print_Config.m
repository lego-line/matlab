% Script to read the experimental data from the config file and to print a
% new config file for the experimental run 

fout=fopen(path2config,'w');

lineformat2=('%s %s\n');
lineformat3=('%s %s %s\n');
lineformat4=('%s %s %s %s\n');
lineformat5=('%s %s %s %s %s\n');

endpt2=size(Relevant2);
endpt3=size(Relevant3);
endpt4=size(Relevant4);
endpt5=size(Relevant5);

% Section for printing the two column table 
for i=1:endpt2(1)
    fprintf(fout,lineformat2,Relevant2{i,1,1},Relevant2{i,2,1});
end

 % Section for printing the three column table 
for i=1:endpt3(1)
    fprintf(fout,lineformat3,Relevant3{i,1,1},Relevant3{i,2,1},Relevant3{i,3,1});
end


% Section for printing the four column table 
for i=1:endpt4(1)
    fprintf(fout,lineformat4,Relevant4{i,1,1},Relevant4{i,2,1},Relevant4{i,3,1},Relevant4{i,4,1});
end


% Section for printing the five column table 
for i=1:endpt5(1)
    fprintf(fout,lineformat5,Relevant5{i,1,1},Relevant5{i,2,1},Relevant5{i,3,1},Relevant5{i,4,1},Relevant5{i,5,1});
end

fclose(fout);