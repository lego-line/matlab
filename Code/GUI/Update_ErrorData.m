% Update_errordata - script file which runs through all of the failure flag
% logs and compiles into one matrix, in the same way the upsdate light data
% script works. It is called by the graphing GUI to compile teh data to
% allow the graphin tool to work correctly 

% the basic mechanism of operation for each file is:
% Open file if it exists
% copy data into a matrix in a cell array
% else palce in an empty matrix which can be detecetd and used to filter
% out those which are not present. 
if exist(path2splitter1_failure) == 2
    load Splitter_1_Failure_Matrix.mat
    Error_Array{1} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{1} =[];  
end
if exist(path2feed1_failure ) == 2
    load Feed_1_Failure_Matrix.mat
    Error_Array{2} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{2} =[];  
end
if exist(path2feed2_failure ) == 2
      load Feed_2_Failure_Matrix.mat
    Error_Array{3} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{3} =[];  
end
if exist(path2feed3_failure ) == 2
    load Feed_3_Failure_Matrix.mat
    Error_Array{4} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{4} =[];  
end
if exist(path2feed4_failure ) == 2
    load Feed_4_Failure_Matrix.mat
    Error_Array{5} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{5} =[];  
end
if exist(path2feed5_failure) == 2
    load Feed_5_Failure_Matrix.mat
    Error_Array{6} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{6} =[];  
end
if exist(path2transfer1_failure) == 2
    load Transfer_1_Failure_Matrix.mat
    Error_Array{7} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{7} =[];  
end
if exist(path2transfer2_failure) == 2
    load Transfer_2_Failure_Matrix.mat
    Error_Array{8} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{8} =[];  
end
if exist(path2transfer3_failure) == 2
    load Transfer_3_Failure_Matrix.mat
    Error_Array{9} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{9} =[];  
end
if exist(path2transfer4_failure) == 2
    load Transfer_4_Failure_Matrix.mat
    Error_Array{10} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{10} =[];  
end
if exist(path2transfer5_failure) == 2
    load Transfer_5_Failure_Matrix.mat
    Error_Array{11} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{11} =[];  
end
if exist(path2main1_failure) == 2
    load Main_1_Failure_Matrix.mat
    Error_Array{12} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{12} =[];  
end
if exist(path2main2_failure) == 2
    load Main_2_Failure_Matrix.mat
    Error_Array{13} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{13} =[];  
end
if exist(path2main3_failure) == 2
    load Main_3_Failure_Matrix.mat
    Error_Array{14} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{14} =[];  
end
if exist(path2main4_failure) == 2
    load Main_4_Failure_Matrix.mat
    Error_Array{15} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{15} =[];  
end
if exist(path2main5_failure) == 2
    load Main_5_Failure_Matrix.mat
    Error_Array{16} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{16} =[];  
end
if exist(path2splitter2_failure) == 2
    load Splitter_2_Failure_Matrix.mat
    Error_Array{17} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{17} =[];  
end
if exist(path2upstream_failure) == 2
    load Upstream_Failure_Matrix.mat
    Error_Array{18} =fault_matrix;
    clear fault_matrix 
else 
    Error_Array{18} =[];  
end
