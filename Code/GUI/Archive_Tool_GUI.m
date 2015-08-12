function Archive_Tool_GUI()
%ARCHIVE_TOOL_GUI Gui for the archiving tool for the legoline program
%   This program constructs a simple GUI which presents the user with a
%   variety of log files and adata which they can save and allows a
%   direcoty to be specified into which to store these folders. 
persistent Archive_Tool_GUI_Flag
% this is a persistent variable, due to the way matlab creates new
% workspaces for functions this creates a variable global to all times this
% function is called, but not global to any other type of workspaces, such
% we can track if this function is already running the GUI elswhere to
% prevent opening multiple windows. 

% If the archive tool is already open but lost then darg the window out to
% the front, else we need to setup the archive 
if Archive_Tool_GUI_Flag == 1
    figure(103)
    return
else
    
% pull in the path names to the various files from global data
global path2sensordata
global Rootpath
global path2eventlog
global path2feedlog
global path2userresults
global path2master
global path2writableconfig
global archive_open_flag
global Archive_GUI
global path2favouritespot
global path2failuredata   

% Set the archive open flag as persistent within the function workspace and
% within the base workspace
Archive_Tool_GUI_Flag =1;  
archive_open_flag = 1;
% the colour matrix dtermines the colours of buttons, bacjgrounds etc 
colour_matrix =[0.8125,0.6328,0.5586,0.4023,0.6992;0.9258,0.7266,0.6562,0.5469,0.7070;0.8672,0.6875,0.6055,0.5430,0.5598]';
% open a figure window with number 103 and a handle 
Archive_GUI=figure(103);
assignin('caller','Archive_GUI',Archive_GUI)
% Assign some of the base window properties to get rid of the default
% matlab menu bars and change the background colour - make temporarily
% invisible 
set(Archive_GUI,'Visible','off','Numbertitle','off','MenuBar','none','color',colour_matrix(3,:),'Position',[360,500,800,600]);


% Generate A Default Title for the archive by using time and date data 
% get the time data
time= clock;
date = [num2str(time(3)),'_',num2str(time(2)),'_',num2str(time(1))];
time=[num2str(time(4)),'_',num2str(time(5))];

% create the title by stringcat a defualt title and a time and date of
% creation this can be modified by the archive name edit box callback. 
current_archive_title =['Legoline_Data_Archive_Date_',date,'_Time_',time]; % variable to stroe the name of the current archive, defaults to date and time 

% path of where to store the archive, will be filled by one of the
% callbacks using a graphical selection method for user friendliness 
archive_path=[];

% vector of components to be stored corresponding to the check boxes;
% the checkbox callback function modifies this and the archive data button
% calllback uses it to determine which components of the data set to
% archive. 

% default to all ones such that the default is to include all data
components = ones(6,1); 


% a section of code to allow favorites to be entered; if a favourites file
% is added to the gui folder with a suitable location when the gui file
% select is launched it will default to this file location if not the user default
% start blocation is the root folder. 
if exist(path2favouritespot) == 2
    load Archiving_Location.mat
end

% create the Two panels One for the main buttons to perform operations  
Archive_Select_Panel = uipanel('Parent',Archive_GUI,'Title','Select Data','BackgroundColor',colour_matrix(2,:),'Position',[0.55,0.1,0.4,0.8]);
% and one to hold the checkbox options 
Archive_File_Panel = uipanel('Parent',Archive_GUI,'Title','Archive Browser','BackgroundColor',colour_matrix(2,:),'Position',[0.05,0.1,0.4,0.8]);

% populate the archive Browser panel with a text box displaying the
% currently selected directory
Text_etb = uicontrol(Archive_File_Panel,'style','tex','units','normal', 'Position',[0.1,0.89,0.8,0.05],'backgroundcolor',colour_matrix(2,:),'String','Archive Folder Name');
eth = uicontrol(Archive_File_Panel,'Style','edit','String',current_archive_title,'tooltipstring',' Please Type a Name for the Archive Folder Here then press enter','units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.1 0.725 0.8 0.15],'Callback',@edittext_Callback);
% a button to open a file browser to selct where the archvie should go
Text_pb1 = uicontrol(Archive_File_Panel,'style','tex','units','normal', 'Position',[0.1,0.65,0.8,0.05],'backgroundcolor',colour_matrix(2,:),'String','Set Archive Folder Location');
pbh1 = uicontrol(Archive_File_Panel,'Style','pushbutton','String','Select Archive Location','tooltipstring','Select the folder to place the archive in only needs to be set once','backgroundcolor',colour_matrix(1,:),'units','normal','Position',[0.1 0.5 0.8 0.15],'Callback',@getfolderlocation);
% a button to implement the save 
Text_pb2 = uicontrol(Archive_File_Panel,'style','tex','units','normal', 'Position',[0.1,0.425,0.8,0.05],'backgroundcolor',colour_matrix(2,:),'String','Archive Data Now');
pbh2 = uicontrol(Archive_File_Panel,'Style','pushbutton','String','Archive Data','tooltipstring','Press to Archive the Selected Data','units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.1 0.275 0.8 0.15],'Callback',{@save_archive_callback});
% and a button to laod another archive 
Text_pb3 = uicontrol(Archive_File_Panel,'style','tex','units','normal', 'Position',[0.1,0.2,0.8,0.05],'backgroundcolor',colour_matrix(2,:),'String','Load Saved Data');
pbh3 = uicontrol(Archive_File_Panel,'Style','pushbutton','String','Restore Session','tooltipstring','Press to reload a saved archive select the archive folder from prompt','units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.1 0.05 0.8 0.15],'Callback',{@load_archive_callback});

% populate the select data panel with tick boxes displaying the various
% types of data to save to the file 
cbh1 = uicontrol(Archive_Select_Panel,'Style','checkbox','String','Feed Logs','Value',1,'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.1 11/13 0.8 1/13],'Callback',@checkbox_callback);
cbh2 = uicontrol(Archive_Select_Panel,'Style','checkbox','String','Event Logs','Value',1,'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.1 9/13 0.8 1/13],'Callback',@checkbox_callback);
cbh3 = uicontrol(Archive_Select_Panel,'Style','checkbox','String','Experimental Results','Value',1,'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.1 7/13 0.8 1/13],'Callback',@checkbox_callback);
cbh4 = uicontrol(Archive_Select_Panel,'Style','checkbox','String','Light Sensor Data','Value',1,'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.1 5/13 0.8 1/13],'Callback',@checkbox_callback);
cbh5 = uicontrol(Archive_Select_Panel,'Style','checkbox','String','Configuration Files','Value',1,'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.1 3/13 0.8 1/13],'Callback',@checkbox_callback);
cbh6 = uicontrol(Archive_Select_Panel,'Style','checkbox','String','Error Data','Value',1,'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.1 1/13 0.8 1/13],'Callback',@checkbox_callback);


% a simple turn handle off precuation to rpevent the buttons being
% inadvertently deleted or modified. 
set([cbh1,cbh2,cbh3,cbh4,cbh5,cbh6,eth,pbh1,pbh2,pbh3],'handlevisibility','off')

% Initialize the GUI.
% Change units to normalized so components resize 
set(Archive_GUI,'Units','normalized');
% Assign the GUI a name to appear in the window title.
set(Archive_GUI,'Name','Legoline Archiving Tool')
% Move the GUI to the center of the screen.
movegui(Archive_GUI,'center')
% Make the GUI visible.
set(Archive_GUI,'Visible','on','HandleVisibility','callback','DeleteFcn',@Archive_Tool_Close_Fcn);
end% end of function

%% Nested Function CallBacks Begin - 
% these are the functions that are callled by the various buttons and features when clicked as well as a shutodwn function to clear up the gui
    function Archive_Tool_Close_Fcn(src,evnt)
        % close function - deletes the gui window and sets relevant
        % variables in the base workspace to show this gui is no longer
        % active. This is run whenever the gui window is attempted to be
        % closed by whatever means 
      Archive_Tool_GUI_Flag =0;
      archive_open_flag = 0;
      delete(Archive_GUI);
    end

    function checkbox_callback(source,event)
        % function which is called by each of the checkboxs. when the state
        % is change. It determines the name of the checkbox which has been
        % changed and then stest the vlaue of the components
        % vectorcorresponidng to that checkbox to match its state. The
        % components vector is the vector checked by the archive generation
        % function to determine what to arhcive. 
     switch get(source,'String')
        case 'Feed Logs'
            if (get(source,'Value') == get(source,'Max'))
                % Checkbox is checked-take appropriate action
                components(1) = 1;
            else
                components(1) =0 ; 
            end
        case 'Event Logs'
            if (get(source,'Value') == get(source,'Max'))
                % Checkbox is checked-take appropriate action
                components(2) = 1;
            else
                components(2) =0 ; 
            end
        case 'Experimental Results'
            if (get(source,'Value') == get(source,'Max'))
                % Checkbox is checked-take appropriate action
                components(3) = 1;
            else
                components(3) =0 ; 
            end
        case 'Light Sensor Data'
            if (get(source,'Value') == get(source,'Max'))
                % Checkbox is checked-take appropriate action
                components(4) = 1;
            else
                components(4) =0 ; 
            end
        case 'Configuration Files'
            if (get(source,'Value') == get(source,'Max'))
                % Checkbox is checked-take appropriate action
                components(5) = 1;
            else
                components(5) =0 ; 
            end
         case 'Error Data'
            if (get(source,'Value') == get(source,'Max'))
                % Checkbox is checked-take appropriate action
                components(6) = 1;
            else
                components(6) =0 ; 
            end
     end% end of switch
    end% end of function 



    function edittext_Callback(hObject,eventdata)
        % function which updates the current archive title based on the
        % string the user inputs into the archive name editbox      
        current_archive_title = get(hObject,'String');
        assignin('caller','current_archive_title',current_archive_title);
    end % end of cuntion 


    function getfolderlocation (source,event)
        % this function runs when the archive location button is pressed.
        % It determines if the user has already specified a path for the
        % archive to go to. If so it starts a file browser window from that point to allow the
        % user to explore sub or neighbouring directories, else it starts
        % the explorer from within the directory where the legoline Folder
        % resides. 
        if isempty(archive_path) == 1
            archive_path = uigetdir(fileparts(Rootpath),'Archive Location'); % ask user to navigate to the folder they want the archive to appear in 
        else
            archive_path = uigetdir(archive_path,'Archive Location'); % ask user to navigate to the folder they want the archive to appear in
        end
        assignin('caller','archive_path',archive_path)
    end

function save_archive_callback(source,event)
    % this function is the one that actually copies out and saves the data
    % from the legoline folder into the arhcive. It has two different
    % operation modes for windows and linux to get round some of the
    % permisiions that the teaching system at CUED has in place to prevent
    % MATLAb moving files around. It basically checks each element of the
    % components vector. If it is a 1 then the component is copied to the
    % archive, if 0 then the compoennt is not copied. 
           sep=filesep;
           archive_name = [archive_path sep current_archive_title];
           if ispc == 1
               % the windows version is quite self explanatory. 
               if exist(archive_name) == 0
                   % create a folder for the archived data with the name
                   % and location specified in the relevenat variables 
                    mkdir(archive_name);
               end
               if components(1) == 1
                   destination = [archive_name sep 'FeedLog'];
                   %mkdir(destination);
                   copyfile(path2feedlog,destination)
                   %command = ['xcopy ' path2feedlog ' ' destination ' /Q /Y'];
                   %system(command);
               end
               if components(2) == 1
                   destination = [archive_name sep 'EventLog'];
                   copyfile(path2eventlog,destination)
                   %mkdir(destination);
                   %command = ['xcopy ' path2eventlog ' ' destination ' /Q /Y'];
                   %system(command);
               end
               if components(3) == 1
                   
                   destination = [archive_name sep 'User_Results'];
                   copyfile(path2userresults,destination)
%                    mkdir(destination);
%                    command = ['xcopy ' path2userresults ' ' destination ' /Y'];
%                    system(command);
               end
               if components(4) == 1
                   destination = [archive_name sep 'SensorData'];
                   copyfile(path2sensordata,destination)
%                    mkdir(destination);
%                    command = ['xcopy ' path2sensordata ' ' destination ' /Y' ];
%                    system(command);
               end
               if components(5) == 1
                   destination = [archive_name sep 'config.txt'];
                   copyfile(path2writableconfig,destination)
%                    command = ['copy ' path2writableconfig ' ' destination];
%                    system(command);
                   destination = [archive_name sep 'master_config.txt'];
                   copyfile(path2master,destination)

               end        
               if components(6) == 1
                   destination = [archive_name sep 'Failure_Data'];
                   copyfile(path2failuredata,destination)
               end 
           elseif isunix == 1
               % the linux version to get round deparmtnetal restrictions
               % by going to the command line via matlab. 
               
               if exist(archive_name) == 0
                    mkdir(archive_name);
               end
               if components(1) == 1
                   destination = [archive_name sep];
                   command = ['cp -r -f ' path2feedlog ' ' destination];
                   system(command);
               end
               if components(2) == 1
                   destination = [archive_name sep];
                   command = ['cp -r -f ' path2eventlog ' ' destination];
                   system(command);
               end
               if components(3) == 1
                   destination = [archive_name sep];
                   command = ['cp -r -f ' path2userresults ' ' destination];
                   system(command);
               end
               if components(4) == 1
                   destination = [archive_name sep];
                   command = ['cp -r -f ' path2sensordata ' ' destination ];
                   system(command);
               end
               if components(5) == 1
                   destination = [archive_name sep];
                   command = ['cp -f ' path2writableconfig ' ' destination];
                   system(command);
                   destination = [archive_name sep];
                   command = ['cp -f ' path2master ' ' destination];
                   system(command);
          else
                disp('Current Operating System Not Supported')
          end 
        end % end of OS switch  
end % end of save archvie callback 

    function load_archive_callback(source,event)
        % function to reload a previously saved archive back into the
        % active workspace. 
        
        %The first few lines open a file browser to allow the user to select an archive to reload. 
        %If a default location has been entered by the favorites file mentioned previously then   
        % it will start here else it will start at the folder containing
        % the legoline folder
        if isempty(archive_path) == 1
            load_name= uigetdir(fileparts(Rootpath),'Archive Location'); % ask user to navigate to the folder they want the archive to load from.
        else 
            load_name= uigetdir(archive_path,'Archive Location'); % ask user to navigate to the folder they want the archive to load from.   
        end
        
            sep=filesep;
        % much like the write file two versions of the copy back operations are required to allow the 
        % matlab program to get around the restrictions placed on matlab
        % file operations by the departmental teaching system. Essentially
        % the contents of the archive are scanned and if certain elements
        % are found they are copied back into the Legoline folder
        % overwriting all that is there already. 
        if ispc == 1
            data_source = [load_name sep 'FeedLog']; 
            if exist(data_source)
                copyfile(data_source,path2feedlog)
            end
            data_source = [load_name sep 'EventLog'];
            if exist(data_source)
                copyfile(data_source,path2eventlog)
            end
            data_source = [load_name sep 'ExperimentResult'];
            if exist(data_source)
                copyfile(data_source,path2userresults)
            end
            data_source = [load_name sep 'SensorData'];
            if exist(data_source)
                copyfile(data_source,path2sensordata)
            end
            data_source = [load_name sep 'config.txt'];
            if exist(data_source)
                copyfile(data_source,path2writableconfig)
                data_source = [load_name sep 'master_config.txt'];
                copyfile(data_source,path2master)
            end
            data_source = [load_name sep 'Failure_Data'];
            if exist(data_source)
                copyfile(data_source,path2failuredata)
            end
        elseif isunix == 1
            data_source = [load_name sep 'FeedLog' sep];
            if exist(data_source)
                command = ['yes| cp -r -f ' data_source '*' ' ' path2feedlog];
                system(command);
            end
            data_source = [load_name sep 'EventLog' sep];
            if exist(data_source)
                command = ['yes| cp -r -f ' data_source '*' ' ' path2eventlog];
                system(command);
            end
            data_source = [load_name sep 'User_Results' sep];
            if exist(data_source)
% pull in the path names to the various reslts f
                command = ['yes| cp -r -f ' data_source '*' ' ' path2userresults];
                system(command);
            end
            data_source = [load_name sep 'SensorData' sep];
            if exist(data_source)
                command = ['yes| cp -r -f ' data_source '*'  ' ' path2sensordata];
                system(command);
            end
            data_source = [load_name sep 'config.txt'];
            if exist(data_source) 
                command = ['yes| cp -f ' data_source ' ' path2writableconfig];
                system(command);
                data_source = [load_name sep 'master_config.txt'];
                command = ['yes| cp -f ' data_source ' ' path2master];
                system(command);
            end          
        else
            disp('Current Operating System Not Supported')
        end % end of OS switch 
    end % end of load function 
% nested call back functions end 
end % end of GUI

