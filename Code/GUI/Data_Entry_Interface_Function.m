function Data_Entry_Interface_Function(source,event)
% function calling the gui for entering the configuration data  manually
% rather than directly editing the config file. This reads the existing
% config fileo get the inital settings and provides a number of tools to
% make chanages to a floating config. These changes can then be reviewd or
% written to the config file. 


% persisntent vriable used by all attempts to open this function - it
% tracks if the function is already open somehwere, and the following if
% statement will make any exitsing window current or open a new window if
% none exists 
persistent config_editor_flag
if config_editor_flag == 1
    % if window already exists make current
    figure(104)
    return
else 
    % else create a new window 
    
    % pull in some global variables that are needed for oepration 
    global Config_Editor_GUI
    global config_open_flag
    global path2master
    global path2writableconfig
    persistent options
    global path2gui

% setup a vector of the correct size for options if this in the first run
% of the GUI - options determine the state of various comonents such that
% the GUi will retian its last satte on any redraw operation- this allows
% us to store settings such as the current line which is being edited and
% so all of the elements of the GUi update to the elements of that line on
% redraw. It is simply a vector of numbers coding for properties of the
% uicontrol items which can be set to an initial state on draw. 
if isempty(options) == 1
    options = ones(21,1);
end 
    


% show that the GUi is open to te otehr GUi's to assist in automatic
% shutdown. 
config_editor_flag = 1;
config_open_flag = 1; 


% use the master file to determine the number of feed lines and splitters
% and hence allow it to create the correct drop down menus for the line and
% splitter boxes to select each unit to edit.
fid = fopen(path2master,'rt');
out = textscan(fid,'%s	%s	%s	%s');
fclose(fid);
% find the number of feed lines
ind=strmatch('No_of_Feedlines',out{1},'exact');
Number_of_Feedlines = out{2}(ind);
Number_of_Feedlines=str2num(Number_of_Feedlines{1});
% find the number of splitters 
ind=strmatch('No_of_Splitters',out{1},'exact');
Number_of_Splitters = out{2}(ind);
Number_of_Splitters=str2num(Number_of_Splitters{1});


%% The next thing we want to do is open the editable config file and read in the exsiting data to the function
%% a section to read in the various table types 
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
read_data = out2{2}(test_ind);
read_data = read_data{1};
if strcmp(read_data,'Local_Control') == 1
    options(1) = 1;
elseif strcmp(read_data,'Global_Control') == 1
    options(1) = 2;
elseif strcmp(read_data,'Networked_Sensors') == 1
    options(1) = 3;
elseif strcmp(read_data,'Networked_Sensors_e') == 1
    options(1) = 4;
elseif strcmp(read_data,'Networked_Units') == 1
    options(1) = 5;
end
Relevant2=[Relevant2;line];

test_ind=strmatch('Run_Downstream_Units',out2{1});
read_data = out2{2}(test_ind);
read_data = str2num(read_data{1});
options(2) = read_data;
line=[out2{1}(test_ind),out2{2}(test_ind)];
Relevant2=[Relevant2;line];



for i =1:1:Number_of_Splitters
    test_ind=strmatch(['ColourCode',num2str(i)],out2{1});
    line=[out2{1}(test_ind),out2{2}(test_ind)];
    Relevant2=[Relevant2;line];
end 

% 3 column data format
test_ind=strmatch('Upstream',out3{1});
read_data = out3{2}(test_ind);
read_data = str2num(read_data{1});
options(3) = read_data;
read_data = out3{3}(test_ind);
read_data = read_data{1};
if strcmp(read_data,'Main') == 1
    options(4) = 1;
elseif strcmp(read_data,'Feed') == 1
    options(4) = 2;
end 
line=[out3{1}(test_ind),out3{2}(test_ind),out3{3}(test_ind)];
Relevant3=[Relevant3;line];


for i =1:1:Number_of_Splitters
    test_ind=strmatch(['Splitter',num2str(i)],out3{1});
    line=[out3{1}(test_ind),out3{2}(test_ind),out3{3}(test_ind)];
    Relevant3=[Relevant3;line];
end 

% 4 Column Data Format
for i =1:1:Number_of_Splitters
    test_ind=strmatch(['PalletCode',num2str(i)],out4{1});
    line=[out4{1}(test_ind),out4{2}(test_ind),out4{3}(test_ind),out4{4}(test_ind)];
    Relevant4=[Relevant4;line];
end 

% 5 column data format
test_ind=strmatch('ControlUpstr',out5{1});
line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
read_data = out5{2}(test_ind);
read_data = read_data{1};
if strcmp(read_data,'P') == 1
    options(5) = 1; 
elseif strcmp(read_data,'N') == 1
    options(5) = 2; 
elseif strcmp(read_data,'T') == 1
    options(5) = 3; 
elseif strcmp(read_data,'R') == 1
    options(5) = 4; 
elseif strcmp(read_data,'L') ==  1
    options(5) =5;
elseif strcmp(read_data,'S') ==  1
    options(5) =6;
end 
Relevant5=[Relevant5;line];

% work across all feed lines and record the control inputs ( Buffer Sizes
% and Activitiesies)
for i = 1:1:Number_of_Feedlines
    test_ind=strmatch(['ControlLine',num2str(i)],out5{1});
    line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
    Relevant5=[Relevant5;line];
end 
% for each feed line record the etails of the inter arrival distribtuion
% sud. 
for i = 1:1:Number_of_Feedlines
    test_ind=strmatch(['Line',num2str(i)],out5{1});
    line=[out5{1}(test_ind),out5{2}(test_ind),out5{3}(test_ind),out5{4}(test_ind),out5{5}(test_ind)];
    Relevant5=[Relevant5;line];
end 

%% Record the Experimental parameters. 

% find the time to pass
index = strmatch('Pass_Time',out{1});
Time_To_Pass = out{2}(index);

% find the rate step 
index = strmatch('Rate_Step',out{1});
RateStep= out{2}(index);

% find the minimum rate possible 
index = strmatch('Minimum_Rate',out{1});
Min_Rate= out{2}(index);

%Find the Initial Rate 
index = strmatch('Initial_Rate',out{1});
Initial_Rate= out{2}(index);

% find the pallet buffer step 
index = strmatch('Buffer_Step',out{1});
PalletStep= out{2}(index);

% find the minimum size possible 
index = strmatch('Minimum_Size',out{1});
Min_Size= out{2}(index);

%Find the Initial size 
index = strmatch('Maximum_Size',out{1});
Maximum_Size= out{2}(index);

%% create the arrays which have the full rnage offeed line and splitter ID's to create the drop down menus later. 
available_lines ={};
for i=1:1:Number_of_Feedlines
    available_lines{i} =num2str(i);
end 
available_splitters = {}; 
for i=1:1:Number_of_Splitters
    available_splitters{i} =num2str(i);
end 

    
%% Section for Drawing The GUI
Config_Editor_GUI = figure(104);
colour_matrix =[0.8125,0.6328,0.5586,0.4023,0.6992;0.9258,0.7266,0.6562,0.5469,0.7070;0.8672,0.6875,0.6055,0.5430,0.5598]';
set(Config_Editor_GUI,'Visible','on','Numbertitle','off','MenuBar','none','color',colour_matrix(3,:),'HandleVisibility','callback','DeleteFcn',@Editor_Tool_Close_Fcn,'Name','Legoline Configuration Editor','Position',[500,50,800,600]);
assignin('caller','Config_Editor_GUI',Config_Editor_GUI)
movegui(Config_Editor_GUI,'center')
Redraw(0,0)

% section for storing variables related to the experimental value editor
% popup it it is required in order to get around the  workspace suspension
% it will cause, preventing it wriiting back data to this one which doesn't
% already exist. 
experiment_editor_flag = 0; 
experiment_editor_gui =[];
options(9) = 1;

end % end of if open window 

%% Start Nested Functions
%% Start of Redraw Callback
function Redraw(src,evnt)
    % The Redraw function is called every time a popup menu is changed, or the edit boxes are refilled manually, such that the entire GUi is redrawn showing the 
    % I.E. if a ew feed line is slected the GUI is redrawn and the value in
    % the boxes etc are reflective of the propoerties of the new line to
    % prevent confusion, it is called abck from within all other  callbacks.
   
    
    % setup up each of the panels that contain groups of related features. 
    Control_Panel = uipanel('Parent',Config_Editor_GUI,'Title','Control Setup','BackgroundColor',colour_matrix(2,:),'Position',[0,0.8,0.5,0.2]);
    Experiment_Panel = uipanel('Parent',Config_Editor_GUI,'Title','Experiment Setup','BackgroundColor',colour_matrix(2,:),'Position',[0.5,0.8,0.5,0.2]);
    Upstream_Panel = uipanel('Parent',Config_Editor_GUI,'Title','Upstream Unit Setup','BackgroundColor',colour_matrix(2,:),'Position',[0,0.55,1,0.2]);
    FeedLine_Panel = uipanel('Parent',Config_Editor_GUI,'Title','Feed Line Setup','BackgroundColor',colour_matrix(2,:),'Position',[0,0.3,1,0.2]);
    Splitter_Panel = uipanel('Parent',Config_Editor_GUI,'Title','Splitter Setup','BackgroundColor',colour_matrix(2,:),'Position',[0,0.15,1,0.1]);
    Review_Panel   = uipanel('Parent',Config_Editor_GUI,'Title','Review','BackgroundColor',colour_matrix(2,:),'Position',[0,0,1,0.1]);

    % Setup Control Panel with features related to the opeartions of the
    % cotnrol system such as a popup toslect the type of control from a
    % dropdown menu or a check box to state running downstream units. 
    % also a large button to open the experiemnts variables which may be
    % required. 
    Control_type_Text = uicontrol(Control_Panel,'style','tex','units','normal', 'Position',[0.05,0.55,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Control Type');
   % option(1)
    Control_type_Popup = uicontrol(Control_Panel,'Style','popupmenu','String',{'Local_Control','Global_Control','Networked_Sensors','Networked_Sensors_e','Networked_Units'},'Value',options(1),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.55,0.55,0.4,0.4],'Callback',@popup_menu_Callback);
   % option(2)
    %Units_Running_Cb = uicontrol(Control_Panel,'Style','checkbox','String','Run Downstream Units','Value',options(2),'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.05,0.05 0.4 0.4],'callback',@checkbox_callback );
    % Setup Experiment Panel 
    experiment_button   = uicontrol(Experiment_Panel ,'Style','pushbutton','String','Setup Experiments','BackgroundColor',colour_matrix(1,:),'ForegroundColor','k','units','normal','Position',[0.05,0.05,0.9,0.9],'Callback',{@setup_experiment_callback});

    % Setup the Upstream Panel 
    % this contains a dropdown menu to slect if the main of feed line has
    % priority, a drop down menu to slect the distribution type used, and a
    % set of edit boxes which allow the user to type in the parameters. 
    %option(3)
    Upstream_Running_Cb = uicontrol(Upstream_Panel,'Style','checkbox','String','Run Upstream','Value',options(3),'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.05,0.55 0.4 0.4],'callback',@checkbox_callback );
    % create a checkbox to enable the upstream unit 
    if options(3) == 1
        % if the upstream unit is running then we enable all of the
        % controls.
        
        
        Upstream_Text_Priority = uicontrol(Upstream_Panel,'style','tex','units','normal', 'Position',[0.55,0.55,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Priority');
        %option(4) - create a label and a popup menu with all of the
        %options for the priority feed line versus tranfer line priority
        %such that the feed can model either a huffered or unbuffered
        %mainline approach. 
        Upstream_Mode_Popup = uicontrol(Upstream_Panel,'Style','popupmenu','String',{'Main','Feed'},'Value',options(4),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.55,0.2,0.4],'Callback',@popup_menu_Callback);
        Upstream_Text_Distribution = uicontrol(Upstream_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Distribution');
        %option(5) Create a popup menu and associated label for the
        %distribuiton type.
        Upstream_Distribution_Popup = uicontrol(Upstream_Panel,'Style','popupmenu','String',{'Periodic','Normal','Triangular','Rectangular','List','Simulation'},'value',options(5),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.05,0.15,0.4],'Callback',@popup_menu_Callback);
        %option(6) - basd on the distribution a different numbers of
        %parameters and meanings are needed, howver to maintian a standard
        %window appearance we use the same edit boxes, but give them
        %different labels, and disbale them where they are not requried by
        %the distribution selected such that the user cannot do anything
        %with them. 
        switch get(Upstream_Distribution_Popup,'value')
            case 1 % in this case the distribtuion type is periodic and so only a sinlge 
                    Upstream_Text_P1 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Period (s)');
                    Upstream_p1 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_upstreamv1_callback);
                    %option(7)
                    Upstream_Text_P2 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                    Upstream_p2 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_upstreamv2_callback,'enable','off');
                    %option(8)
                    Upstream_Text_P3 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                    Upstream_p3 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_upstreamv3_callback,'enable','off');
            case 2 %- in this case the user has selected a normal distribution s
                   %such that one edit box is designated as the mean and the second as the standard devaition whislt the third is disabled. 
                    Upstream_Text_P1 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Mean (s)');
                    Upstream_p1 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_upstreamv1_callback);
                    %option(7)
                    Upstream_Text_P2 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Std Dev (s)');
                    Upstream_p2 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_upstreamv2_callback);
                    %option(8)
                    Upstream_Text_P3 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                    Upstream_p3 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_upstreamv3_callback,'enable','off');
            case 3 % in this case the user has selected the triangular distribution and hence all three edit boxes need to be enabled
                % and given min, median and max titles respectively. 
                    Upstream_Text_P1 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Spacing (s)');
                    Upstream_p1 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_upstreamv1_callback);
                    %option(7)
                    Upstream_Text_P2 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Modal Spacing (s)');
                    Upstream_p2 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_upstreamv2_callback);
                    %option(8)
                    Upstream_Text_P3 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                    Upstream_p3 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_upstreamv3_callback);
            case 4 %- in this case the user wants a rectangualr distribution such theat boxes 1 and 2 are max and min inter arrival times
                % and box three is disbaled. 
                    Upstream_Text_P1 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Spacing (s)');
                    Upstream_p1 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_upstreamv1_callback);
                    %option(7)
                    Upstream_Text_P2 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                    Upstream_p2 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_upstreamv2_callback);
                    %option(8)
                    Upstream_Text_P3 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                    Upstream_p3 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_upstreamv3_callback,'enable','off');
            case 5 % - in ths case the user has selected to give a lsit specifying the arrival times and hence no other parameters anre needed such that all three
                % edit boxes are drawn in but disbaled. 
                Upstream_Text_P1 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                Upstream_p1 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_upstreamv1_callback,'enable','off');
                %option(7)
                Upstream_Text_P2 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                Upstream_p2 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_upstreamv2_callback,'enable','off');
                %option(8)
                Upstream_Text_P3 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                Upstream_p3 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_upstreamv3_callback,'enable','off');
            case 6% - in ths case the user has selected to give a simulation specifying the  times and hence no other parameters anre needed such that all three
                % edit boxes are drawn in but disbaled.
                Upstream_Text_P1 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                Upstream_p1 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_upstreamv1_callback,'enable','off');
                %option(7)
                Upstream_Text_P2 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                Upstream_p2 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_upstreamv2_callback,'enable','off');
                %option(8)
                Upstream_Text_P3 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                Upstream_p3 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_upstreamv3_callback,'enable','off');
        end % end switch 
    else
        % else if the upstream unit is not running then we display all of the
        % controls but disbale them. 
        Upstream_Text_Priority = uicontrol(Upstream_Panel,'style','tex','units','normal', 'Position',[0.55,0.55,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Prioirity');
        %option(4) - setup a dropdown menu to select the priority but
        %diabsle it. 
        Upstream_Mode_Popup = uicontrol(Upstream_Panel,'Style','popupmenu','String',{'Main','Feed'},'Value',options(4),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.55,0.2,0.4],'Callback',@popup_menu_Callback,'enable','off');
        Upstream_Text_Distribution = uicontrol(Upstream_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Distribution');
        %option(5) - create a dropdwn menu to slect the distribution but
        %diable it. 
        Upstream_Distribution_Popup = uicontrol(Upstream_Panel,'Style','popupmenu','String',{'Periodic','Normal','Triangular','Rectangular','List','Simulation'},'value',options(5),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.05,0.15,0.4],'Callback',@popup_menu_Callback,'enable','off');
        %option(6) - create editbox 1 - but disable it.
        Upstream_Text_P1 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
        Upstream_p1 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_upstreamv1_callback,'enable','off');
        %option(7) - create editbox 2 - but disable it.
        Upstream_Text_P2 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
        Upstream_p2 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_upstreamv2_callback,'enable','off');
        %option(8) - create editbox 3 - but disable it.
        Upstream_Text_P3 = uicontrol(Upstream_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
        Upstream_p3 = uicontrol(Upstream_Panel,'Style','edit','String',Relevant5{1,5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_upstreamv3_callback,'enable','off');
        
    end
    
  
    % Setup The Feed Panel
    % create a label for the line number dropdown box 
    Feed_Text_Linenumber = uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.05,0.55,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Line');
    %option(9)
    % create a line number dropdown with options of all available lines
    % and initialise to the last line edited as stored in the options
    % vector. 
    Feed_linenumber_Popup = uicontrol(FeedLine_Panel,'Style','popupmenu','String',available_lines,'value',options(9),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.55,0.15,0.4],'Callback',@popup_menu_Callback_feedline_number);
    %option(10)
    % this button is a check box which determiens if the lien is to run or
    % not, if the line is atatched to this amchine rather than another this
    % box is checked, else it diables the rest of the controls except the
    % lien selection box for this line. 
    options(10)=str2num(Relevant5{1+Number_of_Feedlines+options(9),2});
    Feed_Present_Cb = uicontrol(FeedLine_Panel,'Style','checkbox','String','Line Present','Value',options(10),'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.35,0.7 0.1 0.2],'callback',@checkbox_callback );
    %option(11)
    
    
    if options(10) == 1 % if the line is running we enable the other controls. 
        
        % if the line is present then we create a check box to determine if
        % the line is to be feeding or if it is to run in data gathering
        % mode only. 
          options(11)=str2num(Relevant5{1+Number_of_Feedlines+options(9),3});
          Feed_Running_Cb = uicontrol(FeedLine_Panel,'Style','checkbox','String','Run Line','Value',options(11),'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.35,0.55 0.1 0.2],'callback',@checkbox_callback );
          
          
          if options(11) == 1
              % in this case we have checked the box to say that the line
              % is feeding and hence we want to enable all of the controls
              % which allow us to customsie the feed line distribution and
              % buffer as well as the mainline buffer. 
              
            % first create a label for the feed line buffer size edit box  
            Feed_Text_Linebuffer= uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.55 0.55 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Side Line Buffer');
            
            % now we draw the feed lien buffer edit box 
            %option(12)
            options(12)= str2num(Relevant5{(1+Number_of_Feedlines+options(9)),4});
            Feed_Linebuffer = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+Number_of_Feedlines+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.55 0.1 0.4],'callback',@editbox_linebuffer_callback);
            
            % next a label for the mainline buffer size edit box 
            Feed_Text_MainBuffer= uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.75 0.55 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Main Line Buffer');
            
            % now we draw the mainlien edit box 
            %option(13)
            options(13)= str2num(Relevant5{1+Number_of_Feedlines+options(9),5});
            Feed_MainBuffer = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+Number_of_Feedlines+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.55 0.1 0.4],'callback',@editbox_mainbuffer_callback );
            
            % create a label for the distribution selection dropdown. 
            Feed_Text_Priority = uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Distribution');
            % read its state into a dummy variable 
            % and use this to code for which option from the menu it should
            % display.
            
            Dummyvar = Relevant5{(1+options(9)),2};
            if strcmp(Dummyvar,'P') == 1
                options(14) = 1; 
            elseif strcmp(Dummyvar,'N') == 1
                options(14) = 2; 
            elseif strcmp(Dummyvar,'R') == 1
                options(14) = 3; 
            elseif strcmp(Dummyvar,'T') == 1
                options(14) = 4; 
            elseif strcmp(Dummyvar,'L') ==  1
                options(14) = 5;
            end
            Feed_Distribution_Popup = uicontrol(FeedLine_Panel,'Style','popupmenu','String',{'Periodic','Normal','Rectangular','Triangular','List'},'value',options(14),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.05,0.15,0.4],'Callback',@popup_menu_Callback);
            % based on the value of the distribution popup configure the
            % edit boxes for the distro properties correctly. 
            %option(15)
            switch get(Feed_Distribution_Popup,'val')
                case 1 % in this case the user has selected a periodic distribution so enable a sinlge edit box for the period and no other edit boxes. 
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Period (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 2  % in this case the user has selected a normal distribution, so we label and draw two active edit boxes fr mean and SD
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Mean (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Std Dev (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback);
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 3  % in this case we have a rectangualr distribtuion and again we require two active edit boxes for min and max inter arrival times 
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Spacing (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback);
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 4 % this option enables all the edit boxes such that bthe three definin parameters of a triangualr distribtuion can be added. 
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Space(s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Modal Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback);
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback);
                case 5% - in ths case the user has selected to give a lsit specifying the arrival times and hence no other parameters anre needed such that all three
                % edit boxes are drawn in but disbaled. 
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
            end 
          else
              % else the user has elected to run the line in data gatehring
              % mode such that no other parameters need to be given except
              % for the mainline buffer. 
              
            % draw a label for the line buffer size edit box  
            Feed_Text_Linebuffer= uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.55 0.55 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Side Line Buffer');
            
            % now draw the edit box for the line buffer size and disable. 
            %option(12)
            options(12)= str2num(Relevant5{(1+Number_of_Feedlines+options(9)),4});
            Feed_Linebuffer = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+Number_of_Feedlines+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.55 0.1 0.4],'callback',@editbox_linebuffer_callback,'enable','off');    
            % draw a label for the mainline buffer size and enable it to
            % allow control of the mainline section. 
            Feed_Text_MainBuffer= uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.75 0.55 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Main Line Buffer');
            %option(13)
            options(13)= str2num(Relevant5{1+Number_of_Feedlines+options(9),5});
            Feed_MainBuffer = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+Number_of_Feedlines+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.55 0.1 0.4],'callback',@editbox_mainbuffer_callback,'enable','on' );
            % draw a label for the feed distribution drop down. 
            Feed_Text_Priority = uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Distribution');
            % read its state into a dummy variable 
            % and use this to code for which option from the menu it should
            % display.
            Dummyvar = Relevant5{(1+options(9)),2};
            if strcmp(Dummyvar,'P') == 1
                options(14) = 1; 
            elseif strcmp(Dummyvar,'N') == 1
                options(14) = 2; 
            elseif strcmp(Dummyvar,'R') == 1
                options(14) = 3; 
            elseif strcmp(Dummyvar,'T') == 1
                options(14) = 4; 
            elseif strcmp(Dummyvar,'L') ==  1
                options(14) = 5;
            end 
            Feed_Distribution_Popup = uicontrol(FeedLine_Panel,'Style','popupmenu','String',{'Periodic','Normal','Rectangular','Triangular','List'},'value',options(14),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.05,0.15,0.4],'Callback',@popup_menu_Callback,'enable','off');
            % based on the value of the distribution popup configure the
            % edit boxes for the distro properties correctly. 
            %option(15)
            switch get(Feed_Distribution_Popup,'val')
                case 1 % - in ths case the user has selected to give a perioidic distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled.
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Period (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 2  % - in ths case the user has selected to give a normal distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled.
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Mean (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Std Dev (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 3   % - in ths case the user has selected to give a rectangular distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled.
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Spacing (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 4  % - in ths case the user has selected to give a triangular distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled. 
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Space(s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Modal Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 5% - in ths case the user has selected to give a lsit specifying the arrival times and hence no other parameters anre needed such that all three
                % edit boxes are drawn in but disbaled. 
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
            end   
          end % end of if line running as a feed line or in data harvesting mode. 
          
    else % end if if line present yes
            % else if the line is not running on this mahcine then we clsoe
            % all of the options for it down but still draw them to
            % maintain the appearance of the window. 
            
            % first draw in the line running checkbox and disable. 
            options(11)=str2num(Relevant5{1+Number_of_Feedlines+options(9),3});
            Feed_Running_Cb = uicontrol(FeedLine_Panel,'Style','checkbox','String','Run Line','Value',options(11),'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.35,0.55 0.1 0.2],'callback',@checkbox_callback,'enable','off' );
            
            % draw a label for the line buffer size edit box
            Feed_Text_Linebuffer= uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.55 0.55 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Side Line Buffer');
            
            % draw the line buffer size edit box and disable. 
            %option(12)
            options(12)= str2num(Relevant5{(1+Number_of_Feedlines+options(9)),4});
            Feed_Linebuffer = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+Number_of_Feedlines+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.55 0.1 0.4],'callback',@editbox_linebuffer_callback,'enable','off');
           
            % draw a label for the mainline buffer size
            Feed_Text_MainBuffer= uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.75 0.55 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Main Line Buffer');
            %option(13)
            
            % draw in the mainline buffer size edit box and disable. 
            options(13)= str2num(Relevant5{1+Number_of_Feedlines+options(9),5});
            Feed_MainBuffer = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+Number_of_Feedlines+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.55 0.1 0.4],'callback',@editbox_mainbuffer_callback,'enable','off' );
           
            % create a dropdown menu for the priority label 
            Feed_Text_Priority = uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Distribution');
            % read its state into a dummy variable 
            % and use this to code for which option from the menu it should
            % display.
            Dummyvar = Relevant5{(1+options(9)),2};
            if strcmp(Dummyvar,'P') == 1
                options(14) = 1; 
            elseif strcmp(Dummyvar,'N') == 1
                options(14) = 2; 
            elseif strcmp(Dummyvar,'R') == 1
                options(14) = 3; 
            elseif strcmp(Dummyvar,'T') == 1
                options(14) = 4; 
            elseif strcmp(Dummyvar,'L') ==  1
                options(14) = 5;
            end 
            % use this coding to initilaise the opup menu even though it is
            % disabled. 
            Feed_Distribution_Popup = uicontrol(FeedLine_Panel,'Style','popupmenu','String',{'Periodic','Normal','Rectangular','Triangular','List'},'value',options(14),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.05,0.15,0.4],'Callback',@popup_menu_Callback,'enable','off');
            % based on the value of the distribution popup configure the
            % edit boxes for the distro properties correctly. 
            %option(15)
            switch get(Feed_Distribution_Popup,'val')
                case 1  % - in ths case the user has selected to give a perioidic distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled.
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Period (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 2  % - in ths case the user has selected to give a normal distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled.
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Mean (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Std Dev (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 3  % - in ths case the user has selected to give a rectangular distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled.
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Spacing (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 4% - in ths case the user has selected to give a triangular distribution for  the arrival times and hence three parameters are needed such that all three
                        % edit boxes are drawn in but disbaled. 
                        options(15)=str2num(Relevant5{(1+options(9)),3});
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Space(s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Modal Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 5% - in ths case the user has selected to give a lsit specifying the arrival times and hence no other parameters anre needed such that all three
                % edit boxes are drawn in but disabled.  
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),3},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        options(16)=str2num(Relevant5{(1+options(9)),4});
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),4},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        options(17)=str2num(Relevant5{(1+options(9)),5});
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',Relevant5{(1+options(9)),5},'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
            end          
       
    end % end of if line present yes/no 
    
    
    
    % Setup The Splitter Panel
    
    if Number_of_Splitters > 0
        % if there are some splitters present we want to draw the fields
        % and let the user edit the relevant ones. 
        % draw a label for the splitter number popup 
        Splitter_Text_Number= uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.05,0.55,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Splitter Number');
        %option(18)
        % draw the splitter number popup starting at the currently selected
        % splitter. The value selected by this menu determines what data is
        % set into eahc of the other boxes: 
        Splitter_number_Popup = uicontrol(Splitter_Panel,'Style','popupmenu','String',available_splitters,'value',options(18),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.25,0.55,0.1,0.4],'callback',@popup_menu_Callback_splitter_number);
        
        % the enxt thing to draw is the opop up menu for selecting the
        % splitter mode of operations, this enables or disbabls one of the
        % following menus to allow only code or colour selection as
        % appropriate. 
        Splitter_Text_Mode = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Mode');
       % we take the value of this and use it d]to determine if the user
       % wants colour or code separation such that we can draw the menus
       % for these apparopriately. 
        insert_val = Relevant3{1+options(18),3};
        if strcmp(insert_val,'Colour') == 1
            options(19) = 1;
        elseif strcmp(insert_val,'Code') == 1
            options(19) = 2;
        end
        Splitter_Mode_Popup   = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'Colour','Code'},'value',options(19),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.25,0.05,0.1,0.4],'callback',@popup_menu_Callback);
        
        % we now have two cases of the tol, one which is for the colour
        % slection in the opup menu which disbales the code box and one for
        % the code selection which disbales the colour menu.
        if get(Splitter_Mode_Popup,'value') == 1
            % this first case draws the case for when we want to enable the
            % colour menu but not the code menu as the slection box says
            % colour.  
            Splitter_Text_Colour = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.55,0.55,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Split Colour');
            %option(20)
            % here we determine the colourwhich is currently in for the
            % prupose of selecting the correct item to strta the menu off,
            % by coding each code as its decimal value and using this to
            % que the popup. 
            insert_val = Relevant2{2+options(18),2};
            if strcmp(insert_val,'Red') == 1
                options(20) = 1;
            elseif strcmp(insert_val,'Yellow') == 1
                options(20) = 2;
            elseif strcmp(insert_val,'Blue') == 1
                options(20) = 3;    
            elseif strcmp(insert_val,'LightGrey') == 1
                options(20) = 4;  
            elseif strcmp(insert_val,'DarkGrey') == 1
                options(20) = 5; 
            end 
            % here we draw the popup menu for colour and add labels for
            % both it and the code slection box. 
            Splitter_Colour_Popup = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'Red','Yellow','Blue','LightGrey','DarkGrey'},'value',options(20),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.55,0.2,0.4],'callback',@popup_menu_Callback);
            Splitter_Text_Code = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.55,0.05,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Split Code');
            %option(21)
            SplitterSettings([1,2,3]) = [Relevant4{options(18),2};Relevant4{options(18),3};Relevant4{options(18),4}];
            code=[str2num(SplitterSettings(1)),str2num(SplitterSettings(2)),str2num(SplitterSettings(3))];
            % here we determine the code which is currently in for the
            % prupose of selecting the correct item to strta the menu off,
            % by coding each code as its decimal value and using this to
            % que the popup. 
            if all(code == [0 0 0])
                   options(21) =1;
            elseif all(code == [0 0 1])
                   options(21) =2;
            elseif all(code == [0 1 0])
                   options(21) =3;
            elseif all(code == [0 1 1]) 
                   options(21) =4;
            elseif all(code == [1 0 0])
                   options(21) =5;
            elseif all(code == [1 0 1])
                   options(21) =6;
            elseif all(code == [1 1 0])
                   options(21) =7;
            elseif all(code == [1 1 1])
                   options(21) =8;
            end
            % draw the code popup menu. 
            Splitter_Code_Popup   = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'0 0 0','0 0 1','0 1 0','0 1 1','1 0 0','1 0 1','1 1 0','1 1 1'},'value',options(21),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.05,0.2,0.4],'callback',@popup_menu_Callback,'enable','off');
        else
            % this second  case draws the case for when we want to enable the
            % code menu but not the colour menu as the slection box says
            % code  
            Splitter_Text_Colour = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.55,0.55,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Split Colour');
            % here we determine the colourwhich is currently in for the
            % prupose of selecting the correct item to strta the menu off,
            % by coding each code as its decimal value and using this to
            % que the popup. 
            insert_val = Relevant2{2+options(18),2};
            if strcmp(insert_val,'Red') == 1
                options(20) = 1;
            elseif strcmp(insert_val,'Yellow') == 1
                options(20) = 2;
            elseif strcmp(insert_val,'Blue') == 1
                options(20) = 3;    
            elseif strcmp(insert_val,'LightGrey') == 1
                options(20) = 4;  
            elseif strcmp(insert_val,'DarkGrey') == 1
                options(20) = 5; 
            end 
            % add the labels for the dropdown menu and draw the colour box
            Splitter_Colour_Popup = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'Red','Yellow','Blue','LightGrey','DarkGrey'},'value',options(20),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.55,0.2,0.4],'callback',@popup_menu_Callback,'enable','off');
            Splitter_Text_Code = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.55,0.05,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Split Code');
            %option(21)
            SplitterSettings([1,2,3]) = [Relevant4{options(18),2};Relevant4{options(18),3};Relevant4{options(18),4}];
            code=[str2num(SplitterSettings(1)),str2num(SplitterSettings(2)),str2num(SplitterSettings(3))];
            % here we determine the code which is currently in for the
            % prupose of selecting the correct item to strta the menu off,
            % by coding each code as its decimal value and using this to
            % que the popup. 
            if all(code == [0 0 0])
                   options(21) =1;
            elseif all(code == [0 0 1])
                   options(21) =2;
            elseif all(code == [0 1 0])
                   options(21) =3;
            elseif all(code == [0 1 1]) 
                   options(21) =4;
            elseif all(code == [1 0 0])
                   options(21) =5;
            elseif all(code == [1 0 1])
                   options(21) =6;
            elseif all(code == [1 1 0])
                   options(21) =7;
            elseif all(code == [1 1 1])
                   options(21) =8;
            end
            % draw the code popup box 
            Splitter_Code_Popup   = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'0 0 0','0 0 1','0 1 0','0 1 1','1 0 0','1 0 1','1 1 0','1 1 1'},'value',options(21),'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.05,0.2,0.4],'callback',@popup_menu_Callback); 
        end 
    else % if there are no splitters running then we can draw the whole panel as normal but disable all the controls to prevent the user doing anything. 
        Splitter_Text_Number= uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.05,0.55,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Splitter Number');
        Splitter_number_Popup = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'Not Available'},'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.25,0.55,0.1,0.4],'callback',@popup_menu_Callback_splitter_number,'enable','off');
        Splitter_Text_Mode = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Mode');
        Splitter_Mode_Popup   = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'Not Available'},'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.25,0.05,0.1,0.4],'callback',@popup_menu_Callback,'enable','off'); 
        Splitter_Text_Colour = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.55,0.55,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Split Colour');
        Splitter_Colour_Popup = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'Not Available'},'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.55,0.2,0.4],'callback',@popup_menu_Callback,'enable','off','enable','off');
        Splitter_Text_Code = uicontrol(Splitter_Panel,'style','tex','units','normal', 'Position',[0.55,0.05,0.2,0.4],'backgroundcolor',colour_matrix(2,:),'String','Split Code');
        Splitter_Code_Popup   = uicontrol(Splitter_Panel,'Style','popupmenu','String',{'Not Available'},'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.75,0.05,0.2,0.4],'callback',@popup_menu_Callback,'enable','off'); 
    end % end number of splitters > 0 
    
    
    % Setup the Control Panel with a button to review the changes and a
    % button to commit the chnanges to the config file and close teh
    % editor. 
    review_button   = uicontrol(Review_Panel ,'Style','pushbutton','String','Review Config','BackgroundColor',colour_matrix(1,:),'ForegroundColor','k','units','normal','Position',[0.05,0.05,0.4,0.9],'Callback',{@review_file_callback});
    print_button   = uicontrol(Review_Panel ,'Style','pushbutton','String','Commit Changes and Close','BackgroundColor',colour_matrix(1,:),'ForegroundColor','k','units','normal','Position',[0.55,0.05,0.4,0.9],'Callback',{@create_file_callback});

    % disbale the visibility of the menu handles to prevent callbakcs from
    % destroying them accidentally. 
menuhandles = [findall(Control_Panel);findall(Experiment_Panel);findall(Upstream_Panel);findall(FeedLine_Panel);Splitter_Panel];
set(menuhandles,'HandleVisibility','on');
end 
%% end of the redraw function. 
%% Check Box Callbakcs. 
    function checkbox_callback (src,evnt)
        % this function is called back by the check boxes when the value in
        % them has been changed. 
        switch get(src,'String') % determine which check box called the function to allow one function for all checkboxes. 
            case 'Run Downstream Units' % if it was the run downstream units checkbox
                if (get(src,'Value') == get(src,'Max')) % determine the value of the checkbox
                % Checkbox is checked-take appropriate action
                    Relevant2{2,2} = '1';
                else
                    Relevant2{2,2} = '0';
                end
                % upstae the drawing options vector as appropriate. 
                options(2) = get(src,'Value');
            case 'Run Upstream' % this enables or disables the upstream unit from running and the associated panel. 
                if (get(src,'Value') == get(src,'Max'))
                % Checkbox is checked-take appropriate action
                    Relevant3{1,2} = '1';
                else
                    Relevant3{1,2} = '0';
                end
                % update the drawing options such that it rememebers the
                % change for redraw. 
                options(3) = get(src,'Value');
            case 'Line Present'
                 if (get(src,'Value') == get(src,'Max'))
                % Checkbox is checked-take appropriate action
                    Relevant5{1+Number_of_Feedlines+options(9),2} = '1';
                else
                    Relevant5{1+Number_of_Feedlines+options(9),2} = '0';
                 end
                 % in this case the redraw takes its value from that in the
                 % field jsut edited as there are different cases for each
                 % feed unit of this value. 
            case 'Run Line'
                if (get(src,'Value') == get(src,'Max'))
                % Checkbox is checked-take appropriate action
                    Relevant5{1+Number_of_Feedlines+options(9),3} = '1';
                else
                    Relevant5{1+Number_of_Feedlines+options(9),3} = '0';
                end 
                 % in this case the redraw takes its value from that in the
                 % field jsut edited as there are different cases for each
                 % feed unit of this value. 
        end % end of switch  
        % redraw the GUi to chanbge the display where features need
        % enabling or disbaling.
        Redraw(0,0)
    end % end of checkbox function

%% popup Menu Callbacks

function popup_menu_Callback_feedline_number(source,eventdata)
    % this function is called by the feed popup menu and allows the user to
    % select a feed line to view. 
                         str = get(source,'String');
                         val = get(source,'Value'); 
                         % this retrives the number of the item of the popup menu item - since we number our feedlines 1 to x anyway this value 
                         % automatically corresponds to the line number of
                         % interest
                         % so we simply stick it into the redraw options
                         % and request a redraw. 
                         options(9) = val; 
                         Redraw(0,0)
end 

function popup_menu_Callback_splitter_number(source,eventdata)
    % this function is called by the splitter select popup menu and allows the user to
    % select a feed line to view. 
                         str = get(source,'String');
                         val = get(source,'Value');
                         % this retrives the number of the item of the popup menu item - since we number our splitters 1 to x anyway this value 
                         % automatically corresponds to the line number of
                         % interest
                         % so we simply stick it into the redraw options
                         % and request a redraw. 
                         options(18) = val; 
                         Redraw(0,0)
end 


function popup_menu_Callback(source,eventdata) 
    % this function is called by all other popup menus, as they often have
    % mutlplie cases of what they can be dependant on the above two feed
    % menu selections. 
    
    
         % Determine the selected data set.
                     str = get(source,'String');
                     val = get(source,'Value');
                     
                     
                     if length(str) == 5 % if tehre are five possible options we do a vector compariosn to work out which menu it is based on the available options of the menu. 
                              if all(strcmp(str,{'Local_Control';'Global_Control';'Networked_Sensors';'Networked_Sensors_e';'Networked_Units'})) == 1
                                  % if it matches the control type
                                  % selection we edit the chosen control
                                  % type. 
                                    switch val
                                       % switch based ont eh selected menu
                                       % item to populate the appropriate
                                       % contents into the array which
                                       % stores the 2 column data types and
                                       % the row aligning with the
                                       % control_type designation. 
                                        case 1
                                            Relevant2{1,2} = 'Local_Control';
                                        case 2
                                            Relevant2{1,2} = 'Global_Control';
                                        case 3
                                            Relevant2{1,2} = 'Networked_Sensors';
                                        case 4
                                            Relevant2{1,2} = 'Networked_Sensors_e';
                                        case 5
                                            Relevant2{1,2} = 'Networked_Units';
                                    end% end switch 
                                    % set the drawing options to store this
                                    % change for use on all sequential
                                    % redraws of the GUI.
                                    options(1) = val;
                              elseif all(strcmp(str,{'Red';'Yellow';'Blue';'LightGrey';'DarkGrey'})) == 1
                                  % this is the case where we want to
                                  % change the colour to be separated by
                                  % the splitter. 
                                  switch val
                                      % based on what is selected populate the 2 column arrays appropriate column with the 
                                      % correct contents to ahcive that
                                      % operation. 
                                        case 1
                                            Relevant2{2+options(18),2} = 'Red';
                                        case 2
                                            Relevant2{2+options(18),2} = 'Yellow';
                                        case 3
                                            Relevant2{2+options(18),2} = 'Blue';
                                        case 4
                                            Relevant2{2+options(18),2} = 'LightGrey';
                                        case 5
                                            Relevant2{2+options(18),2} = 'DarkGray';
                                   end% end switch 
                                    % set the drawing options to store this
                                    % change for use on all sequential
                                    % redraws of the GUI.
                                    options(20) = val;
                            elseif all(strcmp(str, {'Periodic';'Normal';'Rectangular';'Triangular';'List'}))== 1
                                % this is the case for the feed line
                                % distribution, and populates the
                                % appropaite row of the 5 column data
                                % array. 
                              switch(val)
                               case 1
                                   Relevant5{1+options(9),2} = 'P';
                               case 2
                                   Relevant5{1+options(9),2} = 'N';
                               case 3
                                   Relevant5{1+options(9),2} = 'R';
                               case 4
                                   Relevant5{1+options(9),2} = 'T';
                               case 5 
                                   Relevant5{1+options(9),2} = 'L';
                               end % end of switch
                                    % set the drawing options to store this
                                    % change for use on all sequential
                                    % redraws of the GUI. such that the
                                    % correct edit box configuration is
                                    % displayed. 
                               options(14) = val;
                              end
                     elseif length(str) == 2       
                         % in this case it is a dropdown menu of two
                         % optiosn,l ether the splitter colour vs code menu
                         % or the priority selection by the upstream unit. 
                              if all(strcmp(str,{'Main';'Feed'})) == 1
                                  % if it is the priority of the upstream
                                  % unit we are intresested inthem we
                                  % populate the appropriate section of the
                                  % two column array with the appropriate
                                  % key word. 
                                  switch val
                                      case 1
                                          Relevant3{1,3} = 'Main';
                                      case 2
                                          Relevant3{1,3} = 'Feed';
                                  end% end switch
                                    % set the drawing options to store this
                                    % change for use on all sequential
                                    % redraws of the GUI.
                                  options(4) = val;
                              elseif all(strcmp(str,{'Colour';'Code'})) == 1
                                  % else we are determining for the given
                                  % splitter if we are to separate by
                                  % colour or by code, and so we change a
                                  % different part of the two colum table. 
                                   switch val
                                      case 1
                                          Relevant3{1+options(18),3} = 'Colour';
                                      case 2
                                          Relevant3{1+options(18),3} = 'Code';
                                  end% end switch
                                    % set the drawing options to store this
                                    % change for use on all sequential
                                    % redraws of the GUI.
                                  options(19) = val; 
                              end
                     elseif length(str) == 6   
                         % case for the upstream unit whereby we are
                         % selecting which distribution, this incluses the
                         % optional extra simualtion option and hence gets
                         % a 6 long selectin rather than 5. 
                         if all(strcmp(str,{'Periodic';'Normal';'Triangular';'Rectangular';'List';'Simulation'} ))== 1
                             % determine what the user has selected and
                             % edit the first row of the five column array
                             % as appropirate as this is alwys the upstream
                             % units row. 
                             switch(val)
                                 case 1
                                     Relevant5{1,2} = 'P';
                                 case 2
                                     Relevant5{1,2} = 'N';
                                 case 3
                                     Relevant5{1,2} = 'T';
                                 case 4
                                     Relevant5{1,2} = 'R';
                                 case 5
                                     Relevant5{1,2} = 'L';
                                 case 6
                                     Relevant5{1,2} = 'S';
                             end % end of value switch 
                                    % set the drawing options to store this
                                    % change for use on all sequential
                                    % redraws of the GUI.
                            options(5) = val; 
                         end
                            % case for the feed Lines 
                     
                     elseif length(str) == 8
                         % only the spliiter code ( 3 bit) has 8 possible
                         % chocies and so we determine the value of the
                         % code selected = val fn of the item and popualte
                         % the array as appropriate to get this code
                         % entered. 
                         switch(val)
                             % dependant on the value selected write the
                             % appropriate code to the relevant variable 
                             case 1
                                 Relevant4{options(18),2} = '0';
                                 Relevant4{options(18),3} = '0';
                                 Relevant4{options(18),4} = '0';
                             case 2
                                 Relevant4{options(18),2} = '0';
                                 Relevant4{options(18),3} = '0';
                                 Relevant4{options(18),4} = '1';                                 
                             case 3
                                 Relevant4{options(18),2} = '0';
                                 Relevant4{options(18),3} = '1';
                                 Relevant4{options(18),4} = '0';
                             case 4
                                 Relevant4{options(18),2} = '0';
                                 Relevant4{options(18),3} = '1';
                                 Relevant4{options(18),4} = '1';
                             case 5
                                 Relevant4{options(18),2} = '1';
                                 Relevant4{options(18),3} = '0';
                                 Relevant4{options(18),4} = '0';
                             case 6
                                 Relevant4{options(18),2} = '1';
                                 Relevant4{options(18),3} = '0';
                                 Relevant4{options(18),4} = '1';
                             case 7
                                 Relevant4{options(18),2} = '1';
                                 Relevant4{options(18),3} = '1';
                                 Relevant4{options(18),4} = '0';
                             case 8
                                 Relevant4{options(18),2} = '1';
                                 Relevant4{options(18),3} = '1';
                                 Relevant4{options(18),4} = '1';
                         end % end of switch        
                  end % end of length if 
         % Set current data to the selected data set.
         Redraw(0,0)
end % end popup menu callback 

%% Edit Box Callbacks. 

    function editbox_upstreamv1_callback(src,evnt)
                 % this function deals with the parameter 3 edit box for the upstream line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
        if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                Relevant5{1,3} = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                Relevant5{1,3} = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            Relevant5{1,3} = '1';
        end
        Redraw(0,0)
    end % end of upstream edit box callback 1

    function editbox_upstreamv2_callback(src,evnt)
         % this function deals with the parameter 2 edit box for the upstream line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
        if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                Relevant5{1,4} = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                Relevant5{1,4} = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            Relevant5{1,4} = '1';
        end
        Redraw(0,0)
    end % end of upstream edit box callback 2

    function editbox_upstreamv3_callback(src,evnt)
         % this function deals with the parameter 3 edit box for the upstream line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
       if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                Relevant5{1,5} = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                Relevant5{1,5} = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            Relevant5{1,5} = '1';
       end
       Redraw(0,0)
    end % end of upstream edit box callback 3

    function editbox_linebuffer_callback (src,evnt)
         % this function deals with the buffer size for the line edit box for the feed line line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
        if isnan(str2double(get(src,'string'))) == 0
           if  str2double(get(src,'string')) < 0
                 errordlg('Please Enter a Numeric Value Min:0 Max:4','Legoline Warning Dialogue');
                 Relevant5{1+Number_of_Feedlines+options(9),4} = '0';
           elseif str2double(get(src,'string')) > 4
                 errordlg('Please Enter a Numeric Value Min:0 Max:4','Legoline Warning Dialogue');
                 Relevant5{1+Number_of_Feedlines+options(9),4} = '4';
           else
                 Relevant5{1+Number_of_Feedlines+options(9),4} = get(src,'string');
           end 
        else 
            errordlg('Please Enter a Numeric Value Min:0 Max:4','Legoline Warning Dialogue');
            Relevant5{1,5} = '0';
        end
        Redraw(0,0)
    end % end of feed line buffer callback 

    function editbox_mainbuffer_callback (src,evnt)
         % this function deals with the buffer size for the mainline section edit box for the feed line line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
        if isnan(str2double(get(src,'string'))) == 0
           if  str2double(get(src,'string')) < 0
                 errordlg('Please Enter a Numeric Value Min:0 Max:5','Legoline Warning Dialogue');
                 Relevant5{1+Number_of_Feedlines+options(9),5} = '0';
           elseif str2double(get(src,'string')) > 4
                 errordlg('Please Enter a Numeric Value Min:0 Max:5','Legoline Warning Dialogue');
                 Relevant5{1+Number_of_Feedlines+options(9),5} = '4';
           else
                 Relevant5{1+Number_of_Feedlines+options(9),5} = get(src,'string');
           end 
        else 
            errordlg('Please Enter a Numeric Value Min:0 Max:5','Legoline Warning Dialogue');
            Relevant5{1,5} = '0';
        end
        Redraw(0,0)
    end % end of mainline buffer callback 


    function editbox_feedv1_callback(src,evnt)    
         % this function deals with the parameter 1 edit box for the feed line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
        if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                Relevant5{1+options(9),3} = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                Relevant5{1+options(9),3} = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            Relevant5{1+options(9),3} = '1';
        end
        Redraw(0,0)
    end % end of upstream edit box callback 1

    function editbox_feedv2_callback(src,evnt)
         % this function deals with the parameter 2 edit box for the feed line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
         if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                Relevant5{1+options(9),4} = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                Relevant5{1+options(9),4} = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            Relevant5{1+options(9),4} = '1';
         end       
        Redraw(0,0)
    end % end of upstream edit box callback 2

    function editbox_feedv3_callback(src,evnt)
         % this function deals with the parameter 3 edit box for the feed line being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
       if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                Relevant5{1+options(9),5} = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                Relevant5{1+options(9),5} = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            Relevant5{1+options(9),5} = '1';
       end
       Redraw(0,0)
    end % end of upstream edit box callback 3

%% Editor Close Function

    function Editor_Tool_Close_Fcn(src,evnt)
        % set the global flags such that other GUI's knwo that this one is
        % closed. 
        config_open_flag = 0;
        config_editor_flag = 0;   
        % if the experiemnt editor is open then this window also needs to
        % close as the function to which it reports will be deleted and so
        % errors would occur if it remains open independantly. 
        if  isempty(findobj('type','figure','name','Legoline Experiment Editor')) == 0
            delete(findobj('type','figure','name','Legoline Experiment Editor'))
        end
        experiment_editor_flag = 0;        
        % if the window is still open delete it, this takes into account
        % the use of the committ button to close such that the window has
        % not yet been delted. 
        delete(Config_Editor_GUI);
    end % end closedown function

%% File Operation Callbacks. 

    function create_file_callback(src,evnt)
        % This function is called from the commit changes button and writes
        % the new config file over the old version  when requested and then
        % shuts down the interface
        
        % open the config file for writing 
        fout=fopen(path2writableconfig,'wt');

        % determine the appropriate formats to create tabualr data 
        % which is betetr for reading in. each format represetnes one row
        % of a specific length followed by a line rbeak. 
        lineformat2=('%s %s\n');
        lineformat3=('%s %s %s\n');
        lineformat4=('%s %s %s %s\n');
        lineformat5=('%s %s %s %s %s\n');

        % determien the number of rows of each table, such that we can loop
        % over the rows printing a row until we run out of rows. 
        endpt2=size(Relevant2);
        endpt3=size(Relevant3);
        endpt4=size(Relevant4);
        endpt5=size(Relevant5);

        % Section for printing the two column table 
        for j=1:endpt2(1)
            fprintf(fout,lineformat2,Relevant2{j,1,1},Relevant2{j,2,1});
        end

         % Section for printing the three column table 
        for j=1:endpt3(1)
            fprintf(fout,lineformat3,Relevant3{j,1,1},Relevant3{j,2,1},Relevant3{j,3,1});
        end


        % Section for printing the four column table 
        for j=1:endpt4(1)
            fprintf(fout,lineformat4,Relevant4{j,1,1},Relevant4{j,2,1},Relevant4{j,3,1},Relevant4{j,4,1});
        end

        % Section for printing the five column table 
        for j=1:endpt5(1)
            fprintf(fout,lineformat5,Relevant5{j,1,1},Relevant5{j,2,1},Relevant5{j,3,1},Relevant5{j,4,1},Relevant5{j,5,1});
        end   
        % next we print out the experiemntal configuration data as its own
        % table as it all has different variablke names. 
        fprintf(fout,lineformat2,'Pass_Time',Time_To_Pass{1});
        fprintf(fout,lineformat2,'Rate_Step',RateStep{1});
        fprintf(fout,lineformat2,'Minimum_Rate',Min_Rate{1});
        fprintf(fout,lineformat2,'Initial_Rate',Initial_Rate{1});
        fprintf(fout,lineformat2,'Buffer_Step',PalletStep{1});
        fprintf(fout,lineformat2,'Minimum_Size',Min_Size{1});
        fprintf(fout,lineformat2,'Maximum_Size',Maximum_Size{1});
        % close and save the new config file
        fclose(fout);
        % clsoe the editor by calling the close function. 
        Editor_Tool_Close_Fcn(0,0)
    end % end of write file function

    function review_file_callback(src,evnt)
       % this call back is used by the review button to generate a user
        % friendly text file which contains a sumamry of all of the data
        % they have input such that it can be quickly reviewed. 
        
        
        % Open a File called Review_Config_File.TXT
        fout=fopen([path2gui,'Review_Config_File.TXT'],'wt');
        % format for various line lengths requried to get sensible output
        % formats
        lineformat2=('%s %s\n');
        lineformat3=('%s %s %s\n');
        lineformat4=('%s %s %s %s\n');
        lineformat5=('%s %s %s %s %s\n');

        % sizes of certain data arrays such we can loop to creta  tabualr
        % data where necessry. 

        %Print Headings to File      
        fprintf(fout,'General System Information');
        % leave some space for readability 
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        % generate a line telling the user  which control system is being
        % used. 
        fprintf(fout,['The line is running under a ',Relevant2{1,2,1},' System']);
        fprintf(fout,'\n');
        % print the General Options to state if downstream units are to be
        % run 
        if str2num(Relevant2{2,2,1}) == 1
            fprintf(fout,'Downstream Units are Being Run');
        else 
            fprintf(fout,'Downstream Units are not Being Run');
        end 
        fprintf(fout,'\n');
        % print out a statement of which type of priority system is being
        % used, not tehta this is only true for the upstream section,
        % otherwise it is determien by relative main and feed line buuffers
        % at each junction. 
        if strcmp(Relevant3{1,3,1},'Feed') == 1
            fprintf(fout,'Priority is Given to the Feed Lines over the Mainline'); 
        else
            fprintf(fout,'Priority is Given to the Mainline over the Feed Lines');
        end
        % Leave Some Space
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        
        
        % Start of Details for The Upstream Unit 
        fprintf(fout,'Upstream Unit');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        % Print the Upstream Unit Details 
        if str2num(Relevant3{1,2,1}) == 1 % if the upstream unit is set to run print ut is distro data 
            fprintf(fout,'The Upstream Unit is set to run with the following feed schedule\n');
            switch Relevant5{1,2,1}
                case 'P' % start arrival type switch - for each distro a different line is required to state what the unit is doing. 
                    fprintf(fout,['Arrivals Periodic : period = ',Relevant5{1,3,1},' seconds\n']);
                case 'N'
                    fprintf(fout,['Arrivals Normally Distributed: mean = ',Relevant5{1,3,1},' seconds, Standard deviation = ',Relevant5{1,4,1},' seconds\n']);
                case 'R'
                    fprintf(fout,['Arrivals Rectangular Distributed: Minimum Inter-arrival Time = ',Relevant5{1,3,1},' seconds, Maximum Inter-arrival Time = ',Relevant5{1,4,1},' seconds\n']);
                case 'T'
                    fprintf(fout,['Arrivals Rectangular Distributed: Minimum Inter-arrival Time = ',Relevant5{1,3,1},' seconds, Modal Inter-arrival time = ',Relevant5{1,4,1},' seconds, Maximum Inter-arrival Time = ',Relevant5{1,5,1},' seconds\n']);
                case 'L'
                    fprintf(fout,'Arrivals Specified By User Provided File else will Run Periodically:Period = 20 seconds\n');
                case 'S'
                    fprintf(fout,'Arrivals Specified By Simulated Upstream Lines,Remember to Run Simulation! else will Run Periodically:Period = 20 seconds\n');
            end % end of arrivals type switch
        else % else if unit is not running the print a statement to that effect 
            fprintf(fout,'The Upstream Unit will not run\n');
        end % end of if upstream unit running statement 
        % Leave Some Space for Readability
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        
       % Start of the section telling the user about all feed lines 
        fprintf(fout,'Feed Lines');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        % loop to print all you need to know  about feed lines
        for index_feedlines = 1:1:Number_of_Feedlines % loop over all feed lines in numerical order. 
            
            if str2num(Relevant5{1+Number_of_Feedlines+index_feedlines,2}) == 1 % if the feed line is present then we check furtehr what to print. 
                if str2num(Relevant5{1+Number_of_Feedlines+index_feedlines,3}) == 1 % if the line is actively feeding 
                    % print a general statement about the buffering o f the
                    % feed and mainline segments 
                    fprintf(fout,['Feed Line ',num2str(index_feedlines),'  is running in with a feed line buffer of ',Relevant5{1+Number_of_Feedlines+index_feedlines,4,1},' pallets and a Main Line Buffer of size',Relevant5{1+Number_of_Feedlines+index_feedlines,4,1},' pallets\n']);
                    % now we have a switch based ont eh selected
                    % distribution. We print out an appropriate statement
                    % in each case. 
                    switch Relevant5{1+index_feedlines,2,1}
                        case 'P'
                            fprintf(fout,['Arrivals Periodic : period = ',Relevant5{1+index_feedlines,3,1},' seconds\n']);
                        case 'N'
                            fprintf(fout,['Arrivals Normally Distributed: mean = ',Relevant5{1+index_feedlines,3,1},' seconds, Standard deviation = ',Relevant5{1+index_feedlines,4,1},' seconds\n']);
                        case 'R'
                            fprintf(fout,['Arrivals Rectangular Distributed: Minimum Inter-arrival Time = ',Relevant5{1+index_feedlines,3,1},' seconds, Maximum Inter-arrival Time = ',Relevant5{1+index_feedlines,4,1},' seconds\n']);
                        case 'T'
                            fprintf(fout,['Arrivals Rectangular Distributed: Minimum Inter-arrival Time = ',Relevant5{1+index_feedlines,3,1},' seconds, Modal Inter-arrival time = ',Relevant5{1+index_feedlines,4,1},' seconds, Maximum Inter-arrival Time = ',Relevant5{1+index_feedlines,5,1},' seconds\n']);
                        case 'L'
                            fprintf(fout,'Arrivals Specified By User Provided File else will Run Periodically:Period = 20 seconds\n');
                    end % end of arrivals type switch
                else % else the line needs to run in data gathering mode
                    fprintf(fout,['Feed Line ',num2str(index_feedlines),'  is running in data gathering mode only and will not feed\n']);
                end % end of if line is data harvesting only 
            else % else not present the we tell the user it is not present. 
                fprintf(fout,['Feed Line ',num2str(index_feedlines),'  is not present\n']);
            end % end of if the line is present 
            fprintf(fout,'\n');
            
        end % close the for loop over all feed lines 
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        
        % section to print out details of the splitter units ( if any) 
        fprintf(fout,'Splitter Information');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        if Number_of_Splitters > 0 % if some splitter units exist. 
            for index_splitters = 1:1:Number_of_Splitters % if there are splitters then loop over them
                if  str2num(Relevant3{1+index_splitters,2,1}) == 1 % if the splitter unit is present on this PC and is running 
                    fprintf(fout,['Splitter Unit ',num2str(index_splitters),' is sorting pallets based on ',Relevant3{1+index_splitters,3,1},'\n']);
                    switch Relevant3{1+index_splitters,3,1} % dependant on what is to be seperated write an approrpiate statement 
                        case 'Colour'
                            fprintf(fout,['The Colour of pallets separated is: ',Relevant2{2+index_splitters,2,1},'\n']);
                        case 'Code'
                            fprintf(fout,['The Code of pallets separated is: ',Relevant4{index_splitters,2,1},' ',Relevant4{index_splitters,3,1},' ', Relevant4{index_splitters,4,1},'\n']);
                    end % end of switch 
                else  % else if the splitter unit is not running on this PC then we state that it is not running 
                    fprintf(fout,['Splitter Unit ',num2str(index_splitters),' is not running\n']);
                end % end of loop to say if running 
            end % end the loop over all splitters 
            
        else % if the number of splitters is zero then we tell the user there are no splitter units present. 
            fprintf(fout,'There are no Splitter Units present\n');
        end 
        % leave some space for readability 
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        
        % start of the experiments section.
        
        fprintf(fout,'Experiment Information');
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        
        % print each of the experemtn propoerties on a separate line. 
        
        fprintf(fout,lineformat2,'Pass_Time',Time_To_Pass{1});
        fprintf(fout,lineformat2,'Rate_Step',RateStep{1});
        fprintf(fout,lineformat2,'Minimum_Rate',Min_Rate{1});
        fprintf(fout,lineformat2,'Initial_Rate',Initial_Rate{1});
        fprintf(fout,lineformat2,'Buffer_Step',PalletStep{1});
        fprintf(fout,lineformat2,'Minimum_Size',Min_Size{1});
        fprintf(fout,lineformat2,'Maximum_Size',Maximum_Size{1});
        fclose(fout);
        % open the file in the editor for viewing 
        edit Review_Config_File.TXT
    end % end of write file function

%% The final section is for the Separate Experiment Mode GUI
    function setup_experiment_callback(src,evnt)
        % this function is invoked by the experiemnt mode button and crates
        % another GUi which allows the editing of the experiment mode
        % values which need tweaking a little less often than the config
        % and so would waste spce on the main GUI, but can be helpfully
        % hidden behind a button. 
        if experiment_editor_flag == 1
            % if the GUi is already open make it current for the user and
            % return to the old version 
            figure(105)
            return 
        else 
            % else we need to draw the GUI. 
            
            % set the global flag to show that it is open such that its
            % partnt gUi can shut it down on closedown. 
            experiment_editor_flag = 1;
            % create the figure window and set its properties. 
            experiment_editor_gui = figure(105);
            set(experiment_editor_gui,'Visible','on','Numbertitle','off','MenuBar','none','color',colour_matrix(3,:),'HandleVisibility','callback','Name','Legoline Experiment Editor','Position',[500,50,800,600]);
            assignin('caller','experiment_editor_gui',experiment_editor_gui)
            movegui(experiment_editor_gui,'center')
            
            % two panels are created, one with all of the text in and one
            % with a whole pile of edit buttons such that the code breaks
            % up nicely. 
            Label_panel = uipanel('Parent',experiment_editor_gui,'BackgroundColor',colour_matrix(2,:),'Position',[0,0,0.5,1]);
            Edittext_panel = uipanel('Parent',experiment_editor_gui,'BackgroundColor',colour_matrix(2,:),'Position',[0.5,0,0.5,1]);
            
            % popualte the label panel with the appropriate labels. 
            label_panel_Text1 = uicontrol(Label_panel,'style','tex','units','normal', 'Position',[0.05,13/15,1,1/15],'backgroundcolor',colour_matrix(2,:),'String','Time To Pass Run Successfully (Seconds)');
            label_panel_text2 = uicontrol(Label_panel,'style','tex','units','normal', 'Position',[0.05,11/15,1,1/15],'backgroundcolor',colour_matrix(2,:),'String','Rate Step - Resolution (Seconds)');
            label_panel_text3 = uicontrol(Label_panel,'style','tex','units','normal', 'Position',[0.05,9/15,1,1/15],'backgroundcolor',colour_matrix(2,:),'String','Minimum Feed Rate (Seconds)');
            label_panel_text4 = uicontrol(Label_panel,'style','tex','units','normal', 'Position',[0.05,7/15,1,1/15],'backgroundcolor',colour_matrix(2,:),'String','Initial/Maximum Feed Rate (Seconds)');
            label_panel_text5 = uicontrol(Label_panel,'style','tex','units','normal', 'Position',[0.05,5/15,1,1/15],'backgroundcolor',colour_matrix(2,:),'String','Feed Line Buffer Step - Resoltuion');
            label_panel_text6 = uicontrol(Label_panel,'style','tex','units','normal', 'Position',[0.05,3/15,1,1/15],'backgroundcolor',colour_matrix(2,:),'String','Minimum Feed Line Buffer Size');
            label_panel_text7 = uicontrol(Label_panel,'style','tex','units','normal', 'Position',[0.05,1/15,1,1/15],'backgroundcolor',colour_matrix(2,:),'String','Initial/Maximum Feed Line Buffer Size');

            % create a whole bucnh of correpsonding edit boxes. 
            Edittext_Panel_text1 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,13/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Time_To_Pass{1},'callback',@edittext_local_callback);
            Edittext_Panel_text2 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,11/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',RateStep{1},'callback',@edittext_local_callback);
            Edittext_Panel_text3 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,9/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Min_Rate{1},'callback',@edittext_local_callback);
            Edittext_Panel_text4 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,7/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Initial_Rate{1},'callback',@edittext_local_callback);
            Edittext_Panel_text5 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,5/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',PalletStep{1},'callback',@edittext_local_callback);
            Edittext_Panel_text6 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,3/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Min_Size{1},'callback',@edittext_local_callback);
            Edittext_Panel_text7 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,1/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Maximum_Size{1},'callback',@edittext_local_callback);
        end
        %% begin Nested Nested Functions such that the edit box has a callback. 
         % local callback 
          function edittext_local_callback(src,evnt)
              % if any of the edit boxes in this GUi is changed this
              % function changes the appropriate values. 
                    if src == Edittext_Panel_text1
                        % this is the cse for the time to pass, whereby the
                        % user needs to enter a number of minutes which the
                        % run msut continue for before steady state
                        % operations can be verified as occuring
                        
                        % do some sense checks on the input 
                        if isnan(str2double(get(src,'string'))) == 0 
                            if str2double(get(src,'string'))> 0
                                Time_To_Pass{1} = get(src,'string');
                            else 
                                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                            end 
                        else 
                            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                        end    
                        % redraw the panel to save having to define a redraw function
                        Edittext_Panel_text1 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,13/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Time_To_Pass{1},'callback',@edittext_local_callback);
                        
                    elseif src == Edittext_Panel_text2
                        % do some sense checks on the input 
                                if isnan(str2double(get(src,'string'))) == 0
                                   if  str2double(get(src,'string')) < 0
                                         errordlg('Please Enter a Numeric Value Min:1 Max:10','Legoline Warning Dialogue');
                                   elseif str2double(get(src,'string')) > 10
                                         errordlg('Please Enter a Numeric Value Min:1 Max:10','Legoline Warning Dialogue');
                                   else
                                         RateStep{1} = get(src,'string');
                                   end 
                                else 
                                    errordlg('Please Enter a Numeric Value Min:1 Max:10','Legoline Warning Dialogue');
                                end
                                % redraw the panel to save having to define a redraw function
                                Edittext_Panel_text2 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,11/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',RateStep{1},'callback',@edittext_local_callback);
                                
                    elseif src == Edittext_Panel_text3
                        % do some sense checks on the input 
                               if isnan(str2double(get(src,'string'))) == 0
                                   if  str2double(get(src,'string')) < 17
                                         errordlg(['Please Enter a Numeric Value Min:17 Max:',Initial_Rate{1}]);
                                   elseif str2double(get(src,'string')) > str2double(Initial_Rate{1})
                                         errordlg(['Please Enter a Numeric Value Min:17 Max:',Initial_Rate{1}],'Legoline Warning Dialogue');
                                   else
                                         Min_Rate{1} = get(src,'string');
                                   end 
                                else 
                                    errordlg(['Please Enter a Numeric Value Min:17 Max:',Initial_Rate{1}],'Legoline Warning Dialogue');

                               end
                               % redraw the panel to save having to define a redraw function
                               Edittext_Panel_text3 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,9/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Min_Rate{1},'callback',@edittext_local_callback);
                    elseif src == Edittext_Panel_text4
                        % do some sense checks on the input 
                                 if isnan(str2double(get(src,'string'))) == 0
                                   if  str2double(get(src,'string')) < 17
                                         errordlg(['Please Enter a Numeric Value Min:',Min_Rate{1}]);
                                   elseif str2double(get(src,'string')) < str2double(Min_Rate{1})
                                         errordlg(['Please Enter a Numeric Value Min:',Min_Rate{1}],'Legoline Warning Dialogue');
                                   else
                                         Initial_Rate{1} = get(src,'string');
                                   end 
                                else 
                                    errordlg(['Please Enter a Numeric Value Min:',Min_Rate{1}],'Legoline Warning Dialogue');
                                 end
                                 % redraw the panel to save having to define a redraw function
                                Edittext_Panel_text4 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,7/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Initial_Rate{1},'callback',@edittext_local_callback);
                    elseif src == Edittext_Panel_text5
                        % do some sense checks on the input 
                         if isnan(str2double(get(src,'string'))) == 0
                                   if  str2double(get(src,'string')) < 0
                                         errordlg('Please Enter a Numeric Value Min:1 Max:3','Legoline Warning Dialogue');
                                   elseif str2double(get(src,'string')) > 3
                                         errordlg('Please Enter a Numeric Value Min:1 Max:3','Legoline Warning Dialogue');
                                   else
                                         PalletStep{1} = get(src,'string');
                                   end 
                                else 
                                    errordlg('Please Enter a Numeric Value Min:1 Max:3','Legoline Warning Dialogue');
                         end
                         % redraw the panel to save having to define a redraw function
                         Edittext_Panel_text5 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,5/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',PalletStep{1},'callback',@edittext_local_callback);
                    elseif src == Edittext_Panel_text6   
                        % do some sense checks on the input 
                             if isnan(str2double(get(src,'string'))) == 0
                                   if  str2double(get(src,'string')) < 0
                                         errordlg(['Please Enter a Numeric Value Min:0 Max: ',Maximum_Size{1}]);
                                   elseif str2double(get(src,'string')) > str2double(Maximum_Size{1})
                                         errordlg(['Please Enter a Numeric Value Min:0 Max:',Maximum_Size{1}],'Legoline Warning Dialogue');
                                   else
                                         Min_Rate{1} = get(src,'string');
                                   end 
                                else 
                                    errordlg(['Please Enter a Numeric Value Min:0 Max:',Maximum_Size{1}],'Legoline Warning Dialogue');
                                 end
                               % redraw the panel to save having to define a redraw function
                         Edittext_Panel_text6 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,3/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Min_Size{1},'callback',@edittext_local_callback);
                    elseif src == Edittext_Panel_text7   
                        % do some sense checks on the input 
                        if isnan(str2double(get(src,'string'))) == 0
                                   if  str2double(get(src,'string')) < str2double(Min_Size{1})
                                         errordlg(['Please Enter a Numeric Value Min:',Min_Size{1},' Max: 4']);
                                   elseif str2double(get(src,'string')) > 4
                                         errordlg(['Please Enter a Numeric Value Min:',Min_Size{1},' Max: 4'],'Legoline Warning Dialogue');
                                   else
                                         Maximum_Size{1} = get(src,'string');
                                   end 
                                else 
                                    errordlg(['Please Enter a Numeric Value Min:',Min_Size{1},' Max: 4'],'Legoline Warning Dialogue');
                        end
                        % redraw the panel to save having to define a redraw function
                         Edittext_Panel_text7 = uicontrol(Edittext_panel,'style','edit','units','normal', 'Position',[0.05,1/15,1,1/15],'backgroundcolor',colour_matrix(1,:),'String',Maximum_Size{1},'callback',@edittext_local_callback);
                    end % end of if statement 
            end  
    end % end of setup experiment callback 
end % end of main function loop 