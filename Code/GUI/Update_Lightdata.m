% laod data script retrives all light sensor data and experiemntal results
% and  compiles into one matrix, in the same way the update error data
% script works. It is called by the graphing GUI to compile the data to
% allow the graphing tool to work correctly 

% the basic mechanism of operation for each file is:
% Open file if it exists
% copy data into a matrix in a cell array
% else palce in an empty matrix which can be detecetd and used to filter
% out those which are not present. 

if exist(path2splittermatrix1) == 2
    load Splitter_Matrix1 
    Light_Array{1} =Splitter_Matrix;
    clear Splitter_Matrix 
else 
    Light_Array{1} =[];  
end
if exist(path2entval1) == 2
    load Entval_matrix1
    Light_Array{2} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array{2} =[];    
end
if exist(path2entval2) == 2
    load Entval_matrix2
    Light_Array{3} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array{3} =[];  
end
if exist(path2entval3) == 2
    load Entval_matrix3
    Light_Array{4} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array{4} =[];  
end
if exist(path2entval4) == 2
    load Entval_matrix4
    Light_Array{5} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array{5} =[];  
end
if exist(path2entval5) == 2
    load Entval_matrix5
    Light_Array{6} =Ent_matrix;
    clear Ent_matrix
else 
    Light_Array{6} =[];  
end 
if exist(path2exitval1) == 2
    load Exitval_matrix1
    Light_Array{7} =Exit_matrix;
    clear Exit_matrix
else 
    Light_Array{7} =[];  
end 
if exist(path2exitval2) == 2
    load Exitval_matrix2
    Light_Array{8} =Exit_matrix;
    clear Exit_matrix
else 
    Light_Array{8} =[];  
end 
if exist(path2exitval3) == 2
    load Exitval_matrix3
    Light_Array{9} =Exit_matrix;
    clear Exit_matrix
else 
    Light_Array{9} =[];  
end 
if exist(path2exitval4) == 2
    load Exitval_matrix4
    Light_Array{10}=Exit_matrix;
    clear Exit_matrix
else 
    Light_Array{10} =[];  
end 
if exist(path2exitval5) == 2
    load Exitval_matrix5
    Light_Array{11}=Exit_matrix;
    clear Exit_matrix
else 
    Light_Array{11} =[];  
end
if exist(path2tval1) == 2
    load Tval_matrix1
    Light_Array{12}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array{12} =[];  
end
if exist(path2tval2) == 2
    load Tval_matrix2
    Light_Array{13}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array{13} =[];  
end
if exist(path2tval3) == 2
    load Tval_matrix3
    Light_Array{14}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array{14} =[];  
end
if exist(path2tval4) == 2
    load Tval_matrix4
    Light_Array{15}=Fval_matrix;
    clear Fval_matrix
else 
    Light_Array{15} =[];  
end
if exist(path2tval5) == 2
    load Tval_matrix5
    Light_Array{16}=Fval_matrix;
    clear Fval_matrix
else
    Light_Array{16} =[];
end
if exist(path2fval1) == 2
    load Fval_matrix1
    Light_Array{17}=val_matrix;
    clear val_matrix
else 
    Light_Array{17} =[];  
end
if exist(path2fval2) == 2
    load Fval_matrix2
    Light_Array{18}=val_matrix;
    clear val_matrix
else 
    Light_Array{18} =[];  
end
if exist(path2fval3) == 2
    load Fval_matrix3
    Light_Array{19}=val_matrix;
    clear val_matrix
else 
    Light_Array{19} =[];  
end
if exist(path2fval4) == 2
    load Fval_matrix4
    Light_Array{20}=val_matrix;
    clear val_matrix
else 
    Light_Array{20} =[];  
end
if exist(path2fval5) == 2
    load Fval_matrix5
    Light_Array{21}=val_matrix;
    clear val_matrix
else 
    Light_Array{21} =[];
end
if exist(path2mval1) == 2
    load Mval_matrix1
    Light_Array{22}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array{22} =[];  
end
if exist(path2mval2) == 2
    load Mval_matrix2
    Light_Array{23}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array{23} =[];  
end
if exist(path2mval3) == 2
    load Mval_matrix3
    Light_Array{24}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array{24} =[];  
end
if exist(path2mval4) == 2
    load Mval_matrix4
    Light_Array{25}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array{25} =[];  
end
if exist(path2mval5) == 2
    load Mval_matrix5
    Light_Array{26}=Mval_matrix;
    clear Mval_matrix
else 
    Light_Array{26} =[];  
end
if exist(path2splittermatrix2) == 2
    load Splitter_Matrix2
    Light_Array{27} =Splitter_Matrix;
    clear Splitter_Matrix
else 
    Light_Array{27} =[]; 
end

if exist(path2downstreamtransferval1) == 2
    load Transferval_matrix1
    Light_Array{28} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else 
    Light_Array{28} =[];    
end

if exist(path2downstreamtransferval2) == 2
    load Transferval_matrix2
    Light_Array{29} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else 
    Light_Array{29} =[];    
end

if exist(path2downstreamtransferval3) == 2
    load Transferval_matrix3
    Light_Array{30} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else 
    Light_Array{30} =[];    
end

if exist(path2downstreamtransferval4) == 2
     load Transferval_matrix4
     Light_Array{31} =Transfer_Down_matrix;
     clear Transfer_Down_matrix
else 
     Light_Array{31} =[];    
end  

if exist(path2downstreamtransferval5) == 2
    load Transferval_matrix5
    Light_Array{32} =Transfer_Down_matrix;
    clear Transfer_Down_matrix
else 
    Light_Array{32} =[];    
end 

if exist(path2downstreamtransfervalupstr)
    load Transferval_upstr
    Light_Array{33} = Transfer_Down_matrix_u;
    clear Tranfer_Down_matrix_u
else
    Light_Array{33} = [];
end