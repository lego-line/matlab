function limit= Plottingfailuresurface(filename,expt_type,axes_handle)
%Graphing tool to plot the simio data by different buffer values

%%Step 1: Import the data - We only want the values lying on the failure
%surface

%Import spreadsheet

fid=fopen(filename);
simiodata = csvread(filename,1,1);

%Filter for failure
failure_val=simiodata(:,11);
index=find(failure_val);

%Extracting only points that lie on the failure surface
i=1;
rate_data_failure=zeros(length(index),4);

if expt_type==1
    
    while (i<length(index)+1)
        rate_data_failure(i,1:3)=simiodata(index(i),1:3);
        rate_data_failure(i,4)=simiodata(index(i),4);
        i=i+1;
    end
        
    
elseif expt_type ==2
    while (i<length(index)+1)
        rate_data_failure(i,1:3)=simiodata(index(i),12:14);
        rate_data_failure(i,4)=simiodata(index(i),4);
        i=i+1;
    end
       
end
%save('Testmatrix2','rate_data_failure')
Max_mat=zeros(1,3);
Max_mat(1)=max(rate_data_failure(:,1));
Max_mat(2)=max(rate_data_failure(:,2));
Max_mat(3)=max(rate_data_failure(:,3));

limit=max(Max_mat);

%% Plotting the failure surface

% % Using triscatteredinterp
F1 = TriScatteredInterp(rate_data_failure(:,1),rate_data_failure(:,2),rate_data_failure(:,3),'natural');
t1 = 0:0.2:limit;
[qx,qy] = meshgrid(t1,t1);
qz = F1(qx,qy);


F2 = TriScatteredInterp(rate_data_failure(:,1),rate_data_failure(:,2),rate_data_failure(:,3),rate_data_failure(:,4),'natural');

pc=F2(qx,qy,qz);  %troublesome line

axes(axes_handle)
surf(axes_handle,qx,qy,qz,'FaceColor','interp','CData',pc);
hold on
plot3(axes_handle, rate_data_failure(:,1),rate_data_failure(:,2),rate_data_failure(:,3),'o');
cbar_axes=colorbar('peer',axes_handle,'EastOutside');
hold off
end

