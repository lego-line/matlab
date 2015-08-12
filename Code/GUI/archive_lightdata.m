% script called from command line to save the graphs for all light data in an archive instead
% of having to manually plot each graph and save 


%% Read In Data Section

% the basic mechanism is reapeated over all possible files 
% read in data 
% Add data matrix to a cell array of matrices in a specified order if it
% exists, else write an empty matrix which can be detected and ignored by
% the drawing section
if exist(path2splittermatrix1) == 2
    load Splitter_Matrix1 
    Light_Array_script{1} =Splitter_Matrix;
    Light_Array_script{34} =Splitter_Colour_Matrix;
    clear Splitter_Matrix 
    clear Splitter_Colour_Matrix
else 
    Light_Array_script{1} =[]; 
    Light_Array_script{34} =[]; 
end
if exist(path2entval1) == 2
    load Entval_matrix1
    Light_Array_script{2} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array_script{2} =[];    
end
if exist(path2entval2) == 2
    load Entval_matrix2
    Light_Array_script{3} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array_script{3} =[];  
end
if exist(path2entval3) == 2
    load Entval_matrix3
    Light_Array_script{4} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array_script{4} =[];  
end
if exist(path2entval4) == 2
    load Entval_matrix4
    Light_Array_script{5} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array_script{5} =[];  
end
if exist(path2entval5) == 2
    load Entval_matrix5
    Light_Array_script{6} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array_script{6} =[];  
end 
if exist(path2exitval1) == 2
    load Exitval_matrix1
    Light_Array_script{7} =Exit_matrix;
    clear Exit_matrix
else 
    Light_Array_script{7} =[];  
end 
if exist(path2exitval2) == 2
    load Exitval_matrix2
    Light_Array_script{8} =Exit_matrix;
    clear Exit_matrix
else 
    Light_Array_script{8} =[];  
end 
if exist(path2exitval3) == 2
    load Exitval_matrix3
    Light_Array_script{9} =Exit_matrix;
    clear Exit_matrix
else 
    Light_Array_script{9} =[];  
end 
if exist(path2exitval4) == 2
    load Exitval_matrix4
    Light_Array_script{10}=Exit_matrix;
    clear Exit_matrix
else 
    Light_Array_script{10} =[];  
end 
if exist(path2exitval5) == 2
    load Exitval_matrix5
    Light_Array_script{11}=Exit_matrix;
    clear Exit_matrix
else 
    Light_Array_script{11}=[];
end
if exist(path2entval4) == 2
    Light_Array_script{11} =[];  
end
if exist(path2tval1) == 2
    load Tval_matrix1
    Light_Array_script{12}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array_script{12} =[];  
end
if exist(path2tval2) == 2
    load Tval_matrix2
    Light_Array_script{13}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array_script{13} =[];  
end
if exist(path2tval3) == 2
    load Tval_matrix3
    Light_Array_script{14}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array_script{14} =[];  
end
if exist(path2tval4) == 2
    load Tval_matrix4
    Light_Array_script{15}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array_script{15} =[];  
end
if exist(path2tval5) == 2
    load Tval_matrix5
    Light_Array_script{16}=Fval_matrix;
    clear Fval_matrix
else
    Light_Array_script{16} =[];
end
if exist(path2fval1) == 2
    load Fval_matrix1
    Light_Array_script{17}=val_matrix;
    clear val_matrix
else 
    Light_Array_script{17} =[];  
end
if exist(path2fval2) == 2
    load Fval_matrix2
    Light_Array_script{18}=val_matrix;
    clear val_matrix
else 
    Light_Array_script{18} =[];  
end
if exist(path2fval3) == 2
    load Fval_matrix3
    Light_Array_script{19}=val_matrix;
    clear val_matrix
else 
    Light_Array_script{19} =[];  
end
if exist(path2fval4) == 2
    load Fval_matrix4
    Light_Array_script{20}=val_matrix;
    clear val_matrix
else 
    Light_Array_script{20} =[];  
end
if exist(path2fval5) == 2
    load Fval_matrix5
    Light_Array_script{21}=val_matrix;
    clear val_matrix
else 
    Light_Array_script{21} =[];
end
if exist(path2mval1) == 2
    load Mval_matrix1
    Light_Array_script{22}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array_script{22} =[];  
end
if exist(path2mval2) == 2
    load Mval_matrix2
    Light_Array_script{23}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array_script{23} =[];  
end
if exist(path2mval3) == 2
    load Mval_matrix3
    Light_Array_script{24}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array_script{24} =[];  
end
if exist(path2mval4) == 2
    load Mval_matrix4
    Light_Array_script{25}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array_script{25} =[];  
end
if exist(path2mval5) == 2
    load Mval_matrix5
    Light_Array_script{26}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array_script{26} =[];  
end
if exist(path2splittermatrix2) == 2
    load Splitter_Matrix2
    Light_Array_script{27} =Splitter_Matrix;
    Light_Array_script{35} =Splitter_Colour_Matrix;
    clear Splitter_Matrix
    clear Splitter_Colour_Matrix
else 
    Light_Array_script{27} =[]; 
    Light_Array_script{35} =[];
end

if exist(path2downstreamtransferval1) == 2
    load Transferval_matrix1
    Light_Array_script{28} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else 
    Light_Array_script{28} =[];    
end

if exist(path2downstreamtransferval2) == 2
    load Transferval_matrix2
    Light_Array_script{29} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else 
    Light_Array_script{29} =[];    
end

if exist(path2downstreamtransferval3) == 2
    load Transferval_matrix3
    Light_Array_script{30} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else
    Light_Array_script{30} =[];    
end

if exist(path2downstreamtransferval4) == 2
     load Transferval_matrix4
     Light_Array_script{31} =Transfer_Down_matrix;
     clear Transfer_Down_matrix
else 
     Light_Array_script{31} =[];    
end  

if exist(path2downstreamtransferval5) == 2
    load Transferval_matrix5
    Light_Array_script{32} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else 
    Light_Array_script{32} =[];    
end 

if exist(path2downstreamtransfervalupstr)
    load Transferval_upstr
    Light_Array_script{33} = Transfer_Down_matrix_u;
    clear Tranfer_Down_matrix_u
else
    Light_Array_script{33} = [];
end

%% Section To Create The Directory in Which To Store The Files 

if exist(path2favouritespot) == 2
    % if an archive spot is located by the favorites file then start there
    load Archiving_Location.mat
    archive_path_script = uigetdir(archive_path,'Archive Location');
else
    % else star in the folder containing Legoline 
    archive_path_script = uigetdir(fileparts(Rootpath),'Archive Location');
end
sep_script=filesep;
% create a folder named LightgateGraphs within which the saved files will
% be put 
archive_name_script = [archive_path_script sep_script 'Lightgate Graphs' sep_script];
if exist(archive_name_script) == 0 
    mkdir(archive_name_script);
end

%% Section To generate The Files 

% a cell array containing the names of all of the possible lightgates 
available_script = {'Splitter 1 Lightgate','Mainline 1 In','Mainline 2 In','Mainline 3 In','Mainline 4 In','Mainline 5 In',...
    'Mainline 1 Out','Mainline 2 Out','Mainline 3 Out','Mainline 4 Out','Mainline 5 Out','Feed Unit 1','Feed Unit 2','Feed Unit 3',...
    'Feed Unit 4','Feed Unit 5','Transfer 1 In','Transfer 2 In','Transfer 3 In','Transfer 4 In','Transfer 5 In',...
    'Transfer 1 Out','Transfer 2 Out','Transfer 3 Out','Transfer 4 Out','Transfer 5 Out','Splitter 2 Lightgate','Downstream Transfer 1','Downstream Transfer 2'...
    'Downstream Transfer 3','Downstream Transfer 4','Downstream Transfer 5','Upstream Unit','Colourdata1','Colourdata2'};

available_script_2 = {'Splitter_1_Lightgate','Mainline_1_In','Mainline_2_In','Mainline_3_In','Mainline_4_In','Mainline_5_In',...
    'Mainline_1_Out','Mainline_2_Out','Mainline_3_Out','Mainline_4_Out','Mainline_5_Out','Feed_Unit_1','Feed_Unit_2','Feed_Unit_3',...
    'Feed_Unit_4','Feed_Unit_5','Transfer_1_In','Transfer_2_In','Transfer_3_In','Transfer_4_In','Transfer_5_In',...
    'Transfer_1_Out','Transfer_2_Out','Transfer_3_Out','Transfer_4_Out','Transfer_5_Out','Splitter_2_Lightgate','Downstream_Transfer_1','Downstream_Transfer_2'...
    'Downstream_Transfer_3','Downstream_Transfer_4','Downstream_Transfer_5','Upstream_Unit','Colourdata1','Colourdata2'};


for i = 1:1:35
        % loop over all of the possible cases which are stored in the cell
        % array created in the read ins ection 
        if isempty(Light_Array_script{i}) == 0
            % if the matrix is empty then don't take any action, else we
            % need to draw the graphs and save them to the archive.
            
            % create a high number figure handle to work in 
            if ishandle(9999) == 1
                close(9999)
            end % end of close figure if it exists 
            % generate new figure on 9999
            figure(9999)
            set(9999,'NumberTitle','off','Visible','off')
            
            if size(Light_Array_script{i},2) == 3
                % if three lines are available then plot and label as
                % lightdata and threshold against time 
                plot(Light_Array_script{i}(:,1),Light_Array_script{i}(:,2),'b',Light_Array_script{i}(:,1),Light_Array_script{i}(:,3),'r')
                % give the graph appropriate titles 
                legend('Sensordata','Threshold')
                title_string_script=strcat({'Graph of Light Sensor Data For the '},available_script{i},{' sensor'});
                title(title_string_script);
                xlabel('time/seconds');
                ylabel('Light Level/Sensor Units');
                % create a filename for the graph such that it can be saved
                filename=['Graph_Light_Sensor_Data_For_',available_script_2{i},'_sensor'];
            elseif size(Light_Array_script{i},2) == 8
                % case for plotting the splitter colour data in RGB format 
                plot (Light_Array_script{i}(:,1),Light_Array_script{i}(:,2),'k',Light_Array_script{i}(:,1),Light_Array_script{i}(:,3),'r',...
                Light_Array_script{i}(:,1),Light_Array_script{i}(:,4),'g',Light_Array_script{i}(:,1),Light_Array_script{i}(:,5),'b')
                % add some titles and a legend 
                legend('Colour Index','Red Content','Green Content', 'Blue Content')
                title_string_script=strcat({'Graph of Light Sensor Data For the '},available_script{i},{' sensor'});
                title(title_string_script);
                xlabel('time/seconds');
                ylabel('Light Level/Sensor Units');     
                % craete a file name 
                filename=['Graph_Light_Sensor_Data_For_',available_script_2{i},'_sensor'];
            else
                % else if only a single line is present plot it as
                % lightdata without the threshold 
                plot(Light_Array_script{i}(:,1),Light_Array_script{i}(:,2),'b')
                % add some titles and a legend 
                legend('Sensordata')
                title_string_script=strcat({'Graph of Light Sensor Data For the '},available_script{i},{' sensor'});
                title(title_string_script);
                xlabel('time/seconds');
                ylabel('Light Level/Sensor Units');
                % create a file name 
                filename=['Graph_Light_Sensor_Data_For_',available_script_2{i},'_sensor'];
            end   % end of length if statement 
        end% end of if statement about if the file is empty
        % section to save as a figure and as a jpeg file 
        saveas(gcf,[archive_name_script filename],'jpeg')
        saveas(gcf,[archive_name_script filename],'fig')        
end% end of for loop for all light data 
% close the figure as it is no longer required once saved. 
 if ishandle(9999) == 1
                close(9999)
 end % end of close figure if it exists 
 % cleanup variables 
clear filename
clear title_string_script
clear Light_Array_script
clear available_script_2
clear available_script
clear archive_path_script
clear sep_script
clear archive_name_script
disp('The Archiving of Graphs is Completed')
clear i