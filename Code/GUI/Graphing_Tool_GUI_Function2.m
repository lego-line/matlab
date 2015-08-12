function Graphing_Tool_GUI_Function2(source,event)
% script containing the gui for the graphing tools associated with plotting
% failure surafces extracted from the legoline model or from the simio
% model thereof. 


persistent Graphing_GUI_Flag
persistent current_figure_number
if isempty(current_figure_number)
    current_figure_number = 1;
end
if  Graphing_GUI_Flag == 1
    return
else    
    
% edit some global flags to show other GUI's that this one is already open.     
global graphing_open_flag
global Graphing_Tool_GUI
Graphing_GUI_Flag = 1;
graphing_open_flag = 1; 

% tell teh caller that this is the acase as a redundancy check
assignin('caller','graphing_open_flag',1)
% remove an annoying warning 
warning off MATLAB:TriScatteredInterp:DupPtsAvValuesWarnId
% setup the colour matrix to get a unified appearance 
colour_matrix =[0.8125,0.6328,0.5586,0.4023,0.6992;0.9258,0.7266,0.6562,0.5469,0.7070;0.8672,0.6875,0.6055,0.5430,0.5598]';

% this bit extracts the name of the function which called this GUI. This
% requires the type to be identified such that the correct fiedl can be
% extraceted. This means we can tell if the tol was invoked in 3D or 2D
% mode and if so whether light or error data is to be plotted. This keeps
% all of the code in one file allowing easy editing. 
sourcetype = get(source,'Type');
if strcmp(sourcetype,'uimenu') == 1
    inputname = get(source,'label');
end
if strcmp(sourcetype,'uicontrol') == 1
    inputname = get(source,'string');
end

% pull in global variables which point to the data files of interest. 
% lightsensor histories
global Light_Array
global Error_Array
global path2tval1
global path2tval2
global path2tval3
global path2tval4
global path2tval5
global path2mval1
global path2mval2
global path2mval3
global path2mval4
global path2mval5
global path2fval1
global path2fval2
global path2fval3
global path2fval4
global path2fval5
global path2entval1
global path2entval2
global path2entval3
global path2entval4
global path2entval5
global path2exitval1
global path2exitval2
global path2exitval3
global path2exitval4
global path2exitval5
global path2splittermatrix1
global path2splittermatrix2
global path2downstreamtransferval1
global path2downstreamtransferval2
global path2downstreamtransferval3
global path2downstreamtransferval4
global path2downstreamtransferval5
global path2downstreamtransfervalupstr
% failure datta histories
global path2feed1_failure 
global path2feed2_failure 
global path2feed3_failure 
global path2feed4_failure 
global path2feed5_failure 
global path2transfer1_failure 
global path2transfer2_failure 
global path2transfer3_failure 
global path2transfer4_failure 
global path2transfer5_failure 
global path2main1_failure
global path2main2_failure 
global path2main3_failure 
global path2main4_failure 
global path2main5_failure 
global path2splitter1_failure
global path2splitter2_failure
global path2upstream_failure 

% pull in the data from the simio experiments 
global path2feedrtsimiocsv
global path2feedrtexptcsv
global path2palletsimiocsv
global path2palletexptcsv

% create a bunch of variables used in one of the scriprs due to static
% workspace errors: if trying to run a script from a function then the
% script cannot create variables, only edit them, thus when loading .mat
% files we need to have exitsing variables with the same names as those
% loaded. 
Splitter_Matrix=[]; 
Ent_matrix=[];
Exit_matrix=[];
val_matrix=[];
Fval_matrix=[];
Mval_matrix=[];
Transfer_Down_matrix= [];
Transfer_Down_matrix_u = []; 
Splitter_Colour_Matrix =[];
fault_matrix = []; 

% popualte these variables with the appropriate history data by calling
% scripts which do the file reading to keep code here tidy. 
Update_Lightdata;
Update_ErrorData;
% setup soem variables used to instruct us which file we are currently
% studying 
current_data =[1,1];
index_figuretype =1;
assignin('caller','Lightdata',Light_Array)
% Initialize and hide the GUI as it is being constructed.
% retrieve the type of the source-ui menu or uicontrol to retrieve the name
% string as appropriate 
Graphing_Tool_GUI = figure(102);
assignin('caller','Graphing_Tool_GUI',Graphing_Tool_GUI)
set(Graphing_Tool_GUI,'Visible','off','color',colour_matrix(2,:),'Numbertitle','off','Position',[360,500,600,285]);

% create the previes axis in the GUI window 
preview_axes = axes('units','normal','Position',[0.1,0.1,0.4,0.8]);
grid(preview_axes)
rotate3d(preview_axes)

%% Case for When The Tool Is Plotting 3D Data 
if strcmp(inputname,'Graphing Tool') == 1 || strcmp(inputname,'Run Graphing Tool') == 1
% availabl defies the full list of possible 3D grpahs 
% available1 defiesn those for which the files are available and is used to
% generate the popup menu
available = {'Simio Feed Rate','Legoline Feed Rate','Simio Transfer Buffer Size','Legoline Transfer Buffer Size'};
%section to generate the list of available matrices
j=2; % start at second element of available 1 to allow a no picture option to exist
available1{1} = 'none'; % option 1, the user has not yet selected a graph
if exist(path2feedrtsimiocsv) == 2
    % check if the file exists and if so add the graph option to available
    % 1
    available1{j} = 'Simio Feed Rate';
    j=j+1;
end
if exist(path2feedrtexptcsv) == 2
        % check if the file exists and if so add the graph option to available
    % 1
    available1{j} = 'Legoline Feed Rate';
    j=j+1;
end
if exist(path2palletsimiocsv) == 2
        % check if the file exists and if so add the graph option to available
    % 1
    available1{j} = 'Simio Transfer Buffer Size';
    j=j+1;
end
if exist(path2palletexptcsv) == 2    
    % check if the file exists and if so add the graph option to available
    % 1
    available1{j} = 'Legoline Transfer Buffer Size';
    j=j+1;
end
% create the  tool panel which has the popup menu and the draw
% figure button in it and popualte with these tools. 
Graphing_Tool_Panel = uipanel('Parent',Graphing_Tool_GUI,'Title','Select Experiment','BackgroundColor',colour_matrix(2,:),'Position',[0.6,0.2,0.3,0.6]);
hpopup = uicontrol(Graphing_Tool_Panel,'Style','popupmenu','String',available1,'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[.05 .55 .9 .3],'Callback',{@popup_menu_Callback_failuresurface,preview_axes});
hgenerateprintableview =uicontrol(Graphing_Tool_Panel,'Style','pushbutton','String','Generate Figure','BackgroundColor',colour_matrix(1,:),'Units','normalized','Position',[.1 .15 .8 .3],'Callback',{@generate_printable_Callback_failuresurface});
end
%% Case for When The Tool Is Plotting Light Data 

if strcmp(inputname,'Light Sensor Data') == 1    
% available defies the full list of possible light history graphs
% available2 defiesn those for which the files are available and is used to
% generate the popup menu
available = {'none','Splitter 1 Lightgate','Mainline 1 In','Mainline 2 In','Mainline 3 In','Mainline 4 In','Mainline 5 In',...
    'Mainline 1 Out','Mainline 2 Out','Mainline 3 Out','Mainline 4 Out','Mainline 5 Out','Feed Unit 1','Feed Unit 2','Feed Unit 3',...
    'Feed Unit 4','Feed Unit 5','Transfer 1 In','Transfer 2 In','Transfer 3 In','Transfer 4 In','Transfer 5 In',...
    'Transfer 1 Out','Transfer 2 Out','Transfer 3 Out','Transfer 4 Out','Transfer 5 Out','Splitter 2 Lightgate','Downstream Transfer 1','Downstream Transfer 2'...
    'Downstream Transfer 3','Downstream Transfer 4','Downstream Transfer 5','Upstream Unit'};
% section to generate the list of available matrices

i=2; % start at second element of available 1 to allow a no picture option to exist
available2{1} = 'none'; % option 1, the user has not yet selected a graph
% check if file exists and if so add the element to the available 2 array
% to build a popup menu of what is possible.
if exist(path2splittermatrix1) == 2
available2{i} = 'Splitter 1 Lightgate';
i=i+1;
end
if exist(path2entval1) == 2
available2{i} = 'Mainline 1 In';
i=i+1; 
end
if exist(path2entval2) == 2
available2{i} = 'Mainline 2 In';
i=i+1;  
end
if exist(path2entval3) == 2
available2{i} = 'Mainline 3 In';
i=i+1; 
end
if exist(path2entval4) == 2
available2{i} = 'Mainline 4 In';
i=i+1;   
end
if exist(path2entval5) == 2
available2{i} = 'Mainline 5 In';
i=i+1;  
end 
if exist(path2exitval1) == 2
available2{i} = 'Mainline 1 Out';
i=i+1;  
end 
if exist(path2exitval2) == 2
available2{i} = 'Mainline 2 Out';
i=i+1;   
end 
if exist(path2exitval3) == 2
available2{i} = 'Mainline 3 Out';
i=i+1;    
end 
if exist(path2exitval4) == 2
available2{i} = 'Mainline 4 Out';
i=i+1;   
end 
if exist(path2exitval5) == 2
available2{i} = 'Mainline 5 Out';
i=i+1;   
end
if exist(path2tval1) == 2
available2{i} = 'Feed Unit 1';
i=i+1;  
end
if exist(path2tval2) == 2
available2{i} = 'Feed Unit 2';
i=i+1; 
end
if exist(path2tval3) == 2
available2{i} = 'Feed Unit 3';
i=i+1; 
end
if exist(path2tval4) == 2
available2{i} = 'Feed Unit 4';
i=i+1; 
end
if exist(path2tval5) == 2
available2{i} = 'Feed Unit 5';
i=i+1; 
end
if exist(path2fval1) == 2
available2{i} = 'Transfer 1 In';
i=i+1; 
end
if exist(path2fval2) == 2
available2{i} = 'Transfer 2 In';
i=i+1; 
end
if exist(path2fval3) == 2
available2{i} = 'Transfer 3 In';
i=i+1;  
end
if exist(path2fval4) == 2
available2{i} = 'Transfer 4 In';
i=i+1; 
end
if exist(path2fval5) == 2
    available2{i} = 'Transfer 5 In';
    i=i+1; 
end
if exist(path2mval1) == 2
    available2{i} = 'Transfer 1 Out';
    i=i+1;  
end
if exist(path2mval2) == 2
     available2{i} = 'Transfer 2 Out';
     i=i+1;  
end
if exist(path2mval3) == 2
    available2{i} = 'Transfer 3 Out';
    i=i+1;   
end
if exist(path2mval4) == 2
    available2{i} = 'Transfer 4 Out';
    i=i+1;  
end
if exist(path2mval5) == 2
    available2{i} = 'Transfer 5 Out';
    i=i+1;  
end
if exist(path2splittermatrix2) == 2
    available2{i} = 'Splitter 2 Lightgate';
    i=i+1;
end
if exist(path2downstreamtransferval1) == 2
    available2{i} = 'Downstream Transfer 1';
    i=i+1;
end
if exist(path2downstreamtransferval2) == 2
    available2{i} = 'Downstream Transfer 2';
    i=i+1;
end
if exist(path2downstreamtransferval3) == 2
    available2{i} = 'Downstream Transfer 3';
    i=i+1;
end
if exist(path2downstreamtransferval4) == 2
    available2{i} = 'Downstream Transfer 4';
    i=i+1;
end
if exist(path2downstreamtransferval5) == 2
    available2{i} = 'Downstream Transfer 5';
    i=i+1;
end
if exist(path2downstreamtransfervalupstr) == 2
    available2{i} = 'Upstream Unit';
end
% create the  tool panel which has the popup menu and the draw
% figure button in it and popualte with these tools. 
Graphing_Tool_Panel = uipanel('Parent',Graphing_Tool_GUI,'Title','Select Sensor','BackgroundColor',colour_matrix(2,:),'Position',[0.6,0.2,0.3,0.6]);
hpopup = uicontrol(Graphing_Tool_Panel,'Style','popupmenu','String',available2,'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[.05 .55 .9 .3],'Callback',{@popup_menu_Callback_lightsensor,preview_axes,Light_Array});   
hgenerateprintableview =uicontrol(Graphing_Tool_Panel,'Style','pushbutton','String','Generate Figure','BackgroundColor',colour_matrix(1,:),'Units','normalized','Position',[.1 .15 .8 .3],'Callback',{@generate_figure_function_light});
end

%% Case for When The Tool Is Plotting Failure Data 
if strcmp(inputname,'Error Monitoring') == 1  
% available defies the full list of possible light history graphs
% available2 defiesn those for which the files are available and is used to
% generate the popup menu
available = {'none','Splitter 1','Mainline 1','Mainline 2','Mainline 3','Mainline 4','Mainline 5',...
    'Feed Unit 1','Feed Unit 2','Feed Unit 3',...
    'Feed Unit 4','Feed Unit 5','Transfer 1','Transfer 2','Transfer 3','Transfer 4','Transfer 5',...
    'Splitter 2','Upstream Unit'};
% section to generate the list of available matrices 
i=2; % start at second element of available 1 to allow a no picture option to exist
available2{1} = 'none'; % option 1, the user has not yet selected a graph
% check if file exists and if so add the element to the available 2 array
% to build a popup menu of what is possible.
if exist(path2splitter1_failure) == 2
available2{i} = 'Splitter 1';
i=i+1;
end
if exist(path2main1_failure) == 2
available2{i} = 'Mainline 1';
i=i+1; 
end
if exist(path2main2_failure) == 2
available2{i} = 'Mainline 2';
i=i+1;  
end
if exist(path2main3_failure) == 2
available2{i} = 'Mainline 3';
i=i+1; 
end
if exist(path2main4_failure) == 2
available2{i} = 'Mainline 4';
i=i+1;   
end
if exist(path2main5_failure) == 2
available2{i} = 'Mainline 5';
i=i+1;  
end 
if exist(path2feed1_failure ) == 2
available2{i} = 'Feed Unit 1';
i=i+1;  
end
if exist(path2feed2_failure ) == 2
available2{i} = 'Feed Unit 2';
i=i+1; 
end
if exist(path2feed3_failure ) == 2
available2{i} = 'Feed Unit 3';
i=i+1; 
end
if exist(path2feed4_failure ) == 2
available2{i} = 'Feed Unit 4';
i=i+1; 
end
if exist(path2feed5_failure ) == 2
available2{i} = 'Feed Unit 5';
i=i+1; 
end
if exist(path2transfer1_failure ) == 2
available2{i} = 'Transfer 1';
i=i+1; 
end
if exist(path2transfer2_failure ) == 2
available2{i} = 'Transfer 2';
i=i+1; 
end
if exist(path2transfer3_failure ) == 2
available2{i} = 'Transfer 3';
i=i+1;  
end
if exist(path2transfer4_failure ) == 2
available2{i} = 'Transfer 4';
i=i+1; 
end
if exist(path2transfer5_failure ) == 2
    available2{i} = 'Transfer 5';
    i=i+1; 
end
if exist(path2splitter2_failure) == 2
    available2{i} = 'Splitter 2';
    i=i+1;
end
if exist(path2upstream_failure ) == 2
    available2{i} = 'Upstream Unit';
end
% create the  tool panel which has the popup menu and the draw
% figure button in it and popualte with these tools. 
Graphing_Tool_Panel = uipanel('Parent',Graphing_Tool_GUI,'Title','Select Module','BackgroundColor',colour_matrix(2,:),'Position',[0.6,0.2,0.3,0.6]);
hpopup = uicontrol(Graphing_Tool_Panel,'Style','popupmenu','String',available2,'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[.05 .55 .9 .3],'Callback',{@popup_menu_Callback_errors,preview_axes,Error_Array});   
hgenerateprintableview =uicontrol(Graphing_Tool_Panel,'Style','pushbutton','String','Generate Figure','BackgroundColor',colour_matrix(1,:),'Units','normalized','Position',[.1 .15 .8 .3],'Callback',{@generate_figure_function_error});
end


% Initialize the GUI.
align([hpopup,Graphing_Tool_Panel],'Center','None')
% Change units to normalized so components resize 
set([Graphing_Tool_GUI,preview_axes,hpopup],'Units','normalized');
% Assign the GUI a name to appear in the window title.
set(Graphing_Tool_GUI,'Name','Legoline Graphing Tool')
% Move the GUI to the center of the screen.
movegui(Graphing_Tool_GUI,'center')
% Make the GUI visible.
set(Graphing_Tool_GUI,'Visible','on','handlevisibility','callback','DeleteFcn',@Graphing_Gui_Closedown);
end
% --- Begin Nested Function ---    
                 function popup_menu_Callback_failuresurface(source,eventdata, axes_handle)
                     % This function is called whenever the user uses the
                     % popup menu to select a new item to view and updates
                     % the current data pointer and redraws the preview.
                     % This is the 3D case 
                       %Determine the selected data set
                       str = get(source, 'String');
                       val = get(source, 'Value');
                       %Set the path to the selected spreadsheet
                       switch str{val};
                           case 'Simio Feed Rate'
                               filename = path2feedrtsimiocsv;
                               expt_type = 1; %1=feed rate expt
                               index_figuretype = 1;
                           case 'Legoline Feed Rate'
                               filename = path2feedrtexptcsv;
                               expt_type = 1; %1=feed rate expt
                               index_figuretype = 2;
                           case 'Simio Transfer Buffer Size'
                               filename = path2palletsimiocsv;
                               expt_type = 2; %2=buffer state expt
                               index_figuretype = 3;
                           case 'Legoline Transfer Buffer Size'
                               filename = path2palletexptcsv;
                               expt_type = 2; %2=buffer state expt
                               index_figuretype = 4;
                       end
                       lim=Plottingfailuresurface(filename,expt_type,axes_handle);
                       set(preview_axes,'PlotBoxAspectRatio',[1 1 1]);
                       rotate3d(axes_handle, 'on')
                       xlim(axes_handle, [0 lim])
                       ylim(axes_handle, [0 lim])
                       zlim(axes_handle, [0 lim])
                       if expt_type ==1
                           xlabel(axes_handle,'Feed1')
                           ylabel(axes_handle,'Feed2')
                           zlabel(axes_handle,'Feed3')
                       elseif expt_type ==2
                           xlabel(axes_handle,'Buffer1')
                           ylabel(axes_handle,'Buffer2')
                           zlabel(axes_handle,'Buffer3')
                       end
                                     
                   end
               
                    function generate_printable_Callback_failuresurface(source,eventdata)
                       if index_figuretype  ~= 0 
                           switch index_figuretype
                               case 1
                                   filename = path2feedrtsimiocsv;
                                   expt_type = 1; %1=feed rate expt
                               case 2
                                   filename = path2feedrtexptcsv;
                                   expt_type = 1; %1=feed rate expt
                               case 3
                                   filename = path2palletsimiocsv;
                                   expt_type = 2; %2=buffer state expt
                               case 4
                                   filename = path2palletexptcsv;
                                   expt_type = 2; %2=buffer state expt          
                           end      
                           figure(current_figure_number)
                           current_figure_number=current_figure_number+1; 
                           if current_figure_number == 100
                               current_figure_number =105;
                           end
                           figure_axes = axes;                            
                           lim=Plottingfailuresurface(filename,expt_type,figure_axes);
                           set(figure_axes,'PlotBoxAspectRatio',[1 1 1]);
                           rotate3d(figure_axes, 'on')
                           xlim(figure_axes, [0 lim])
                           ylim(figure_axes, [0 lim])
                           zlim(figure_axes, [0 lim])
                           if expt_type ==1
                               xlabel(figure_axes,'Feed1')
                               ylabel(figure_axes,'Feed2')
                               zlabel(figure_axes,'Feed3')
                           elseif expt_type ==2
                               xlabel(figure_axes,'Buffer1')
                               ylabel(figure_axes,'Buffer2')
                               zlabel(figure_axes,'Buffer3')
                           end
                           switch index_figuretype
                               case 1
                                   title(figure_axes,'Feed Rate Failure Surface generated by Simio')
                               case 2
                                   title(figure_axes,'Feed Rate Failure Surface generated by Experiment')
                               case 3
                                   title(figure_axes,'Feed Line Buffer Size Failure Surface generated by Simio')
                               case 4
                                   title(figure_axes,'Feed Line Buffer Size Failure Surface generated by Experiment')        
                           end   
                       end                
                    end % end of failure surafce function 
              %%
                       
                   function popup_menu_Callback_lightsensor(source,eventdata,axes_handle,array) 
                     % This function is called whenever the user uses the
                     % popup menu to select a new item to view and updates
                     % the current data pointer and redraws the preview.
                     % This is the 2d Light Sensor case
                     % Determine the selected data set.
                     str = get(source,'String');
                     val = get(source,'Value'); 
                     % Set current data to the selected data set.
                     switch str{val};
                        case 'none'
                            current_data =[1,1];
                            index_figuretype =0;
                        case 'Splitter 1 Lightgate' 
                            current_data = array{1}(:,:);
                            index_figuretype =1;
                        case 'Mainline 1 In' 
                            current_data = array{2}(:,:);
                            index_figuretype =2;
                        case 'Mainline 2 In' 
                            current_data = array{3}(:,:);
                            index_figuretype =3;
                        case 'Mainline 3 In'  
                            current_data = array{4}(:,:);
                            index_figuretype =4;
                        case 'Mainline 4 In'  
                            current_data = array{5}(:,:);
                            index_figuretype =5;
                        case 'Mainline 5 In'  
                            current_data = array{6}(:,:);
                            index_figuretype =6;  
                        case 'Mainline 1 Out'
                            current_data = array{7}(:,:);
                            index_figuretype =7;
                        case 'Mainline 2 Out'
                            current_data = array{8}(:,:);
                            index_figuretype =8;
                        case 'Mainline 3 Out'
                            current_data = array{9}(:,:);
                            index_figuretype =9;
                        case 'Mainline 4 Out'
                            current_data = array{10}(:,:);
                            index_figuretype =10;
                        case 'Mainline 5 Out'
                            current_data = array{11}(:,:);
                            index_figuretype =11;  
                        case 'Feed Unit 1'
                            current_data = array{12}(:,:);
                            index_figuretype =12;
                        case 'Feed Unit 2'
                            current_data = array{13}(:,:);
                            index_figuretype =13;
                        case 'Feed Unit 3'
                            current_data = array{14}(:,:);
                            index_figuretype =14;
                        case 'Feed Unit 4'
                            current_data = array{15}(:,:);
                            index_figuretype =15;
                        case 'Feed Unit 5'
                            current_data = array{16}(:,:);
                            index_figuretype =16;
                        case 'Transfer 1 In'
                            current_data = array{17}(:,:);
                            index_figuretype =17;
                        case 'Transfer 2 In'
                            current_data = array{18}(:,:);
                            index_figuretype =18;
                        case 'Transfer 3 In'
                            current_data = array{19}(:,:);
                            index_figuretype =19;
                        case 'Transfer 4 In'
                            current_data = array{20}(:,:);
                            index_figuretype =20;
                        case 'Transfer 5 In'
                            current_data = array{21}(:,:);
                            index_figuretype =21;
                        case 'Transfer 1 Out'
                            current_data = array{22}(:,:);
                            index_figuretype =22;
                        case 'Transfer 2 Out'
                            current_data = array{23}(:,:);
                            index_figuretype =23;    
                        case 'Transfer 3 Out'
                            current_data = array{24}(:,:);
                            index_figuretype =24;    
                        case 'Transfer 4 Out'
                            current_data = array{25}(:,:);
                            index_figuretype =25;   
                        case 'Transfer 5 Out'
                            current_data = array{26}(:,:);
                            index_figuretype =26;  
                        case 'Splitter 2 Lightgate'
                            current_data = array{27}(:,:);
                            index_figuretype =27;  
                        case 'Downstream Transfer 1'
                            current_data = array{28}(:,:);
                            index_figuretype =28; 
                        case 'Downstream Transfer 2' 
                            current_data = array{29}(:,:);
                            index_figuretype =29; 
                        case 'Downstream Transfer 3'
                            current_data = array{30}(:,:);
                            index_figuretype =30; 
                        case 'Downstream Transfer 4'
                            current_data = array{31}(:,:);
                            index_figuretype =31; 
                        case 'Downstream Transfer 5'
                            current_data = array{32}(:,:);
                            index_figuretype =32; 
                         case 'Upstream Unit'
                             current_data = array{33}(:,:);
                             index_figuretype = 33; 
                     end
                     % update the previes axis, pointer is updated in the
                     % main switch 
                     plot(axes_handle,current_data(:,1),current_data(:,2));
                     axis([0,max(current_data(:,1)),(min(current_data(:,2))-10),(max(current_data(:,2))+10)])
                   end %% end of light sensor popup callback 
               
               
    function generate_figure_function_light(source,event)
            % this feature is the callback from the plot button and
            % automatically plots a pretty figure that can be saved. 
            % this is the light history version
        if index_figuretype ~= 0
            % open a new figure and increment the counter
            figure(current_figure_number)
            current_figure_number=current_figure_number+1; 
            % just in case the new number is in the range where our GUI's
            % are skip over them 
            if current_figure_number == 100
               current_figure_number =105;
            end
            % two type s of data can be presented, with or without
            % threshold value. 
            if size(current_data,2) == 3
                % if a threshold is presented we draw the graph with two
                % lins and add a legend 
                plot(current_data(:,1),current_data(:,2),'b',current_data(:,1),current_data(:,3),'r')
                legend('Sensor Data','Threshold')
            else
                % else we jsut plot the light history. This is the case for
                % the splitter light gate 
                plot(current_data(:,1),current_data(:,2),'b')
                legend('Sensordata')
            end 
            % add a title and some axis scaling to the expecetd arae to
            % make the graph pretty. 
            title_string=strcat({'Graph of Light Sensor Data For the '},available{index_figuretype+1},{' sensor.'});
            title(title_string);
            xlabel('time/seconds');
            ylabel('Light Level/Sensor Units');
            axis([0,max(current_data(:,1)),(min(current_data(:,2))-10),(max(current_data(:,2))+10)])
        end
    end     
    
    function popup_menu_Callback_errors(source,eventdata,axes_handle,array) 
         % This function is called whenever the user uses the
         % popup menu to select a new item to view and updates
         % the current data pointer and redraws the preview.
         % This is the 2d Failure Data case
         % Determine the selected data set.
                     str = get(source,'String');
                     val = get(source,'Value'); 
         % Set current data to the selected data set.
         switch str{val};
                        case 'none'
                            current_data =[1,1];
                            index_figuretype =0;
                        case 'Splitter 1' 
                            current_data = array{1}(:,:);
                            index_figuretype =1;
                        case 'Mainline 1' 
                            current_data = array{2}(:,:);
                            index_figuretype =2;
                        case 'Mainline 2' 
                            current_data = array{3}(:,:);
                            index_figuretype =3;
                        case 'Mainline 3'  
                            current_data = array{4}(:,:);
                            index_figuretype =4;
                        case 'Mainline 4'  
                            current_data = array{5}(:,:);
                            index_figuretype =5;
                        case 'Mainline 5'  
                            current_data = array{6}(:,:);
                            index_figuretype =6;  
                        case 'Feed Unit 1'
                            current_data = array{7}(:,:);
                            index_figuretype =7;
                        case 'Feed Unit 2'
                            current_data = array{8}(:,:);
                            index_figuretype =8;
                        case 'Feed Unit 3'
                            current_data = array{9}(:,:);
                            index_figuretype =9;
                        case 'Feed Unit 4'
                            current_data = array{10}(:,:);
                            index_figuretype =10;
                        case 'Feed Unit 5'
                            current_data = array{11}(:,:);
                            index_figuretype =11;
                        case 'Transfer 1'
                            current_data = array{12}(:,:);
                            index_figuretype =12;
                        case 'Transfer 2'
                            current_data = array{13}(:,:);
                            index_figuretype =13;
                        case 'Transfer 3'
                            current_data = array{14}(:,:);
                            index_figuretype =14;
                        case 'Transfer 4'
                            current_data = array{15}(:,:);
                            index_figuretype =15;
                        case 'Transfer 5'
                            current_data = array{16}(:,:);
                            index_figuretype =16;
                        case 'Splitter 2'
                            current_data = array{17}(:,:);
                            index_figuretype =17;  
                         case 'Upstream Unit'
                             current_data = array{18}(:,:);
                             index_figuretype = 18; 
         end
                     % update the previes axis, pointer is updated in the
                     % main switch 
                     plot(axes_handle,current_data(:,1),current_data(:,2));
                     axis([0,max(current_data(:,1)),-0.1,1.1])
    end 

    function generate_figure_function_error(source,event)
        if index_figuretype ~= 0
            % this feature is the callback from the plot button and
            % automatically plots a pretty figure that can be saved. 
            % this is the error data version.
            
            % open a figure with a new number 
            figure(current_figure_number)
            % incremenet the stored number for net time
            current_figure_number=current_figure_number+1; 
            % jsut in case the new number is in the range where our GUI's
            % are skip over them 
            if current_figure_number == 100
               current_figure_number =105;
            end
            % if the size of the data vector is 3, i.e. we have two lines 
            if size(current_data,2) == 3
                %plot both of them 
                plot(current_data(:,1),current_data(:,2),'b',current_data(:,1),current_data(:,3),'r')
            else
                % the more normal case is just to plot the first one
                % however 
                plot(current_data(:,1),current_data(:,2),'b')
            end 
            % add all of the other features of the grpah such as axis
            % scaling and labelling 
            title_string=strcat({'Graph of Error Data For '},available{index_figuretype+1});
            title(title_string);
            xlabel('time/seconds');
            ylabel('Failure Flag (Logic 0 or 1)');
            axis([0,max(current_data(:,1)),-0.1,1.1])
        end
    end   

    % call back function to close the GUI 
    function Graphing_Gui_Closedown(src,evnt)
        % change the global flags to show the graphing tool is now closed
     Graphing_GUI_Flag = 0;
     graphing_open_flag =0; 
     % delete the GUI
     delete(Graphing_Tool_GUI)
     % reinstate the warning we disbaled earlier. 
     warning on MATLAB:TriScatteredInterp:DupPtsAvValuesWarnId 
    end              
% -- end Nested Functions --- 
end

