function Legoline_User_Interface()
% LegoLine - Program to Control The Lego production Line 
% 
% Tom Neat UROP Summer 2012
% This script file opens the main figure window and sets up the Gui 

% Set up the main figure window
% Includes Title 

close all; % Close any open figures.

% create the figure window and set some properties to make it look less
% like a matlab figure and allow us to add custom menus. 
Legoline_GUI=figure(101);
set(Legoline_GUI,'Visible','off','Numbertitle','off','MenuBar','none','color','m','Position',[360,500,800,600]);

% variables required to track the state of some of the menu's 
current_menustate=[]; 
existing_menustate=[]; 

% global flags to monitor the status of the otehr archive windows for the
% purpose of a unified shutdown, tehse are first declared and set here. 

global archive_open_flag 
global graphing_open_flag 
global config_open_flag

archive_open_flag =0;
graphing_open_flag =0;
config_open_flag = 0;

global Archive_GUI
global Graphing_Tool_GUI
global Config_Editor_GUI

% global file paths imported such that certain things can be identifed or
% saved to as may be required.

global path2control
global Rootpath
global path2eventlog
global path2feedlog
global path2palletexptoutputs
global path2feedrtexptoutputs
global path2userresults
global path2go

% global path variables imported such that the key files can be identified.


global fpath2main1log 
global fpath2main2log 
global fpath2main3log 
global fpath2main4log 
global fpath2main5log 
global fpath2transfer1log 
global fpath2transfer2log 
global fpath2transfer3log 
global fpath2transfer4log 
global fpath2transfer5log 
global fpath2feed1log     
global fpath2feed2log     
global fpath2feed3log     
global fpath2feed4log     
global fpath2feed5log     
global fpath2splitter1eventlog
global fpath2splitter2eventlog
global fpath2upstreamlog     
global fpath2globallog 

global path2feedlog1
global path2feedlog2
global path2feedlog3
global path2feedlog4
global path2feedlog5
global path2splitter1log
global path2splitter2log
global path2feedlogupstream



global path2feedrtsimiocsv
global path2palletsimiocsv
 
global path2rundrawingY
global path2rundrawingN

% create a timer object to exectute the menu update function periodically
% whislt running this updates the state of the log menus to reflect
% available log files. 
menu_update_timer = timer;
set(menu_update_timer,'ExecutionMode','fixedRate','BusyMode','queue','Period',3,'TimerFcn',@Update_menus_main);

% setup the colour matrix for buttons and the background image 
colour_matrix =[0.8125,0.6328,0.5586,0.4023,0.6992;0.9258,0.7266,0.6562,0.5469,0.7070;0.8672,0.6875,0.6055,0.5430,0.5598]';
background_axes_handle = axes('units','normalized','position',[0 0 1 1]);
uistack(background_axes_handle,'bottom');
I=imread('Legoline.JPEG');
hi = imagesc(I);
set(background_axes_handle,'handlevisibility','off','visible','off')

% Set up pull down menu for the running comamnds initialise start and stop 
runcommandmenu = uimenu('label','Run Commands ');
uimenu(runcommandmenu,'label','Single Run','Enable','off');
uimenu(runcommandmenu,'label','Initialise','call','initialise','separator','on');
uimenu(runcommandmenu,'label','Start','call','Start');
uimenu(runcommandmenu,'label','Finish','call','Finish');
uimenu(runcommandmenu,'label','Run Experiments','Enable','off','separator','on','Enable','off');
uimenu(runcommandmenu,'label','Buffer Size Experiment','call',@Pallet_Buffer_Experiment_Callback,'separator','on','Enable','off' );
uimenu(runcommandmenu,'label','Feed Rate Experiment','call',@Feed_Rate_Experiment_Callback,'Enable','off');
uimenu(runcommandmenu,'label','Import Data','call','import_simiodata');
uimenu(runcommandmenu,'label','Run Graphing Tool','separator','on','call',{@Graphing_Tool_GUI_Function2},'Enable','off');
uimenu(runcommandmenu,'label','Run Status Monitor','separator','on','call','Run_Statedraw');
uimenu(runcommandmenu,'label','Stop Status Monitor','call',@stop_statedraw_callback);
uimenu(runcommandmenu,'label','Simulate Upsstream Line','separator','on','call',@Generate_feed_data_callback);

% Configuration Menu and its sub items 
configmenu = uimenu('label','Configuration');
uimenu(configmenu,'label','Buffer and Feed','Callback',@getconfig);
uimenu(configmenu,'label','NXT MAC Data','Callback',@getconfig);
uimenu(configmenu,'label','Interactive Configuration Tool','Callback',@Data_Entry_Interface_Function);
uimenu(configmenu,'label','MAC Data Master','Callback',@getconfig,'Enable','off');


% Log File Menus, by calling the timer function early. 
resultmenu = uimenu(Legoline_GUI,'label','Data Logging');
logmenu = uimenu(Legoline_GUI,'label','Event Logs');
Update_menus_main(0,0)
     
% Set Up Buttons to Do The Run Commands for a demonstration run. 
initbutton = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Initialise','tooltipstring','Press to Initialise the motors and clear any pallets from the line','BackgroundColor','y','ForegroundColor','k','units','normal','Position',[0.1,0.8,0.2,0.1],'call','initialise');
startbutton = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Start','tooltipstring','Once Initialised Click Here to run the line','BackgroundColor','g','ForegroundColor','k','units','normal','Position',[0.1,0.5,0.2,0.1],'call','Start');
finishbutton = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Finish','tooltipstring','Click here to stop the line and record all data from the run','BackgroundColor','r','ForegroundColor','k','units','normal','Position',[0.1,0.2,0.2,0.1],'call','Finish');

% Function buttons for second cloumn, these generally run more complex
% experiments 

% old code fragment for a button which can display all event logs for
% complex error tracking. 
%event_button = uicontrol('Style','pushbutton','String','Display Event Logs','BackgroundColor',colour_matrix(2,:),'ForegroundColor','k','Position',[475,500,150,50],'Callback',{@display_logdata,6,0});

run_timed_button = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Timed Run','tooltipstring','Once Initialsied Click Here to run the line for a specified time','BackgroundColor',colour_matrix(2,:),'ForegroundColor','k','units','normal','Position',[0.4,0.8,0.2,0.1],'call',@Timed_Run);
run_feed_button = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Run Feed Experiment','tooltipstring','Click Here to Lauch the Configured Feed Rate Experiment','BackgroundColor',colour_matrix(2,:),'ForegroundColor','k','units','normal','Position',[0.4,0.5,0.2,0.1],'call',@Feed_Rate_Experiment_Callback,'Enable','off');
run_pallet_button = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Run Buffer Experiment','tooltipstring','Click Here to Lauch the Configured Buffer Size Experiment','BackgroundColor',colour_matrix(2,:),'ForegroundColor','k','units','normal','Position',[0.4,0.2,0.2,0.1],'call',@Pallet_Buffer_Experiment_Callback,'Enable','off');

% print the thrid column of dashboard buttons - these tend to show results
% files 
feed_button = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Display Feed Logs','tooltipstring','Click here to display the feed logs from all units from the last run','BackgroundColor',colour_matrix(2,:),'ForegroundColor','k','units','normal','Position',[0.7,0.8,0.2,0.1],'Callback',{@display_logdata,5,0});
results_button = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Display Results','tooltipstring','If an experiment mode run has just been completed click here to generate the results file for saving','BackgroundColor',colour_matrix(2,:),'ForegroundColor','k','units','normal','Position',[0.7,0.5,0.2,0.1],'Callback',{@display_logdata,10,0},'Enable','off');
graphing_button = uicontrol(Legoline_GUI ,'Style','pushbutton','String','Graphing Tool','tooltipstring','If an experiment mode run has just been completed click here to view the failure surface in 3D','BackgroundColor',colour_matrix(2,:),'ForegroundColor','k','units','normal','Position',[0.7,0.2,0.2,0.1],'Callback',{@Graphing_Tool_GUI_Function2},'Enable','off');


menuhandles = findall(Legoline_GUI,'type','uimenu');
set(menuhandles,'HandleVisibility','on');


% Initialize the GUI.
% Change units to normalized so components resize 
set([Legoline_GUI,initbutton,startbutton,finishbutton,feed_button,graphing_button,results_button,run_feed_button,run_pallet_button,run_timed_button],'Units','normalized');
% Assign the GUI a name to appear in the window title.
set(Legoline_GUI,'Name','Legoline')
% Move the GUI to the center of the screen.
movegui(Legoline_GUI,'center')
start(menu_update_timer);
% Make the GUI visible.
set(Legoline_GUI,'Visible','on','handlevisibility','callback','CloseRequestFcn',@shutdown_fcn);

% -- begin Nested Functions
%%
    function Generate_feed_data_callback(src,evnt)
        % this function sets up a new instace of matlab to run the
        % simualtion of an upstream model. If the user wishes to run the
        % upstream uni as a simualtion of further lines this tool will
        % allow the simualtion to take palce ina separate instance of
        % amtlab to prevent excess variables and file error soccuring,
        % unsure why this happens but cannot run simualtion twice in same
        % instance of maltab for some file reason. 
        disp('Running the Simulation Now')
        cd(Rootpath)
        % prompt the user to confim this action as it is time consuming 
        selection_simulation = questdlg('Do You Really Want to Do This ?(Operation is time consuming)','Legoline Simulation Confimation','Yes','No','Yes'); 
                switch selection_simulation 
                    case 'Yes'
                        cd(Rootpath)
                        % if the user is sure start the new instance with
                        % the required scripts. 
                        !matlab -nosplash -minimize -r FindRootPath;run(path2simulation) &
                    case 'No'
                return 
                end
    end 

%% Experiment Button Callback Functions. 

    function Feed_Rate_Experiment_Callback(src,evnt)
                % a simple function to offer a user confirm before starting
                % a lengthy experiment
                selection_feedrate = questdlg('Are You Ready To Run the Feed Rate Experiment?','Legoline Experiment Confimation','Yes','No','No'); 
                switch selection_feedrate, 
                    case 'Yes'
                        Feed_Rate_Experiment
                    case 'No'
                    return 
                end
        
    end 

    function Pallet_Buffer_Experiment_Callback(src,evnt)
                % a simple function to offer a user confirm before starting
                % a lengthy experiment
                selection_palletrate = questdlg('Are You Ready To Run the Feed Line Buffer Size Experiment?','Legoline Experiment Confimation','Yes','No','No'); 
                switch selection_palletrate 
                    case 'Yes'
                        Pallet_Buffer_Experiment
                    case 'No'
                    return 
                end
        
    end 

%% Stop State Draw Callback Function

    function stop_statedraw_callback(src,evnt)
        %This function shuts down the state drawing system
        %   Offers the user a chocie of whether to stop the state draw to prevent
        %   mis-clicks and then swaps the go file for the stop file which breaks
        %   the main loop in the other instance of matlab and hence causes it to
        %   automatically quit. 
                selection = questdlg('Close Legoline Interface?','Legoline Close Confimation','Yes','No','Yes'); 
                switch selection, 
                    case 'Yes',
                        if exist(path2rundrawingY)
                            movefile(path2rundrawingY,path2rundrawingN)
                        end 
                    case 'No'
                    return 
                end
    end 

%% Timed Run Function 
    
    function Timed_Run(src,evnt)
        % this fucntion is really useful if running the line alone or doing
        % a tiemd experiment as it will issue the start and stop commands a
        % fixed time apart thus preventing the need for a stopwatch to be
        % used. - very handy if the final satte is important 
        
        % prompt the user to enter an number of minutes to run for. 
        prompt = {'Enter the Number of Minutes to Run'};
        name = 'Legoline Timer Input';
        % number of lines of dialogue in case it is even needed to be
        % increased. 
        numlines = 1;
        default_ans = {'3'};

        timer_cell = inputdlg(prompt,name,numlines,default_ans);
        timer_time = (str2num(timer_cell{1}))* 60;
        
        % take the time started
        time_started = toc;
        % in the base workspace evaluate the start command 
        evalin('base','Start;')
        stop_loop = 0;
        while toc - time_started  < timer_time && stop_loop == 0
            % whislt the elapsed time is less than the input time stay in
            % this loop 
            pause(0.3)
            % check that the line has not failed due to some error 
            go= exist(path2go);
            if go == 0 
                pause(2.0)
                % if so break out of the while loop prematurely
                disp('The Line was Stopped due to failure')
                stop_loop = 1;
            end 
        end 
        % send the finish command to make the line stop regardless of
        % whetehr this is due to a failure or if the lines time is up to
        % perform cleanup 
        evalin('base','Finish;')
        % give the user some feedback. 
        disp('The Timed Run Has Finished')
        if stop_loop == 0
            disp('The timer expired')
        end 
    end % end of tiemd run function. 

%%
    function shutdown_fcn(source,event)
        % this function shuts down the main legoline interface, all open
        % Legoline windows and even the main instance of matlab if
        % required. It is called when the user attempts to delete the main
        % legoline window by whatever means. 
        
                % create a selection menu offering the option to close down
                % the whole instance of matlab, just the Legoline
                % interfaces such that coding work can continue or to
                % remain open. 
                selection = questdlg('Close Legoline Interface?','Legoline Close Confimation','Just Interface','Full Shutdown','No','Just Interface'); 
                switch selection, 
                    case 'Just Interface',
                        % in the case of just the interface delete the main
                        % window
                       delete(Legoline_GUI) 
                       % if the archive tool is open delete that 
                       if  archive_open_flag == 1
                           delete(Archive_GUI)
                       end 
                       % if the graphing window is open delete that 
                       if graphing_open_flag ==1
                           delete(Graphing_Tool_GUI)
                       end  
                       % if the config editor is open delete that 
                       if  config_open_flag == 1
                           delete(Config_Editor_GUI)
                       end 
                       % stop the state draw tool if it is stil running 
                       if exist(path2rundrawingY)
                            movefile(path2rundrawingY,path2rundrawingN)
                       end 
                       % assigning the main workspce that the legoline
                       % window is closd, such that the RunLegoline
                       % function will create a new one when called rather
                       % than look for the existing one. 
                        assignin('base','user_interface_flag',0)
                        % stop and elete the refresh timer 
                        stop(menu_update_timer)
                        delete(menu_update_timer);
                    case 'Full Shutdown'
                        % in the case of whole instance of matlab is to be
                        % shutdown shutdown the interface and then issue
                        % the quit command 
                       delete(Legoline_GUI) 
                       % if the archive tool is open delete that 
                       if  archive_open_flag == 1
                           delete(Archive_GUI)
                       end 
                       % if the graphing window is open delete that 
                       if graphing_open_flag ==1
                           delete(Graphing_Tool_GUI)
                       end  
                       % if the config editor is open delete that 
                       if  config_open_flag == 1
                           delete(Config_Editor_GUI)
                       end 
                       % stop the state draw tool if it is stil running 
                       if exist(path2rundrawingY)
                            movefile(path2rundrawingY,path2rundrawingN)
                       end 
                       % assigning the main workspce that the legoline
                       % window is closd, such that the RunLegoline
                       % function will create a new one when called rather
                       % than look for the existing one. 
                        assignin('base','user_interface_flag',0)
                        % stop and elete the refresh timer 
                        stop(menu_update_timer)
                        delete(menu_update_timer);
                        % quit matlab 
                       quit
                    case 'No'
                        % else the user wants to continue working so return
                        % without taking action. 
                         return 
                end
    end% end of  shutdown function



%%
% function to open the specified config file when called from the menu 
% opening the editor to display it , it has a linux and windows version to
% use geddit or notepad, as these are always available and allow the user
% to edit the file happily. 
    function getconfig(source,event)
        input=get(source,'label');
        if strcmp(input,'Buffer and Feed')
                disp('Opening the Config File For Editing')
                if isunix == 1
                    cd(path2control)
                    ! gedit config.txt   
                    cd(Rootpath)
                elseif ispc == 1
                    cd(path2control)
                    edit config.txt   
                    cd(Rootpath)
                else
                    disp('Operating System Not Supported')
                end
        end
        if strcmp(input,'NXT MAC Data')
            disp('Opening the NXT MAC Address File for Editing')
            if isunix == 1
                cd(path2control)
                !gedit config_master.txt  
                cd(Rootpath)
            elseif ispc ==1
                cd(path2control)
                edit config_master.txt  
                cd(Rootpath)
            else
                disp('Operating System Not Supported')
            end
        end
        if strcmp(input,'MAC Data Master')
            % doesn't quite work yet...
            disp('Opening a Read Only Copy of the Master NXT Data')
            cd(path2control)
            ! gedit 'NXT Brick ID and Uses.txt' 
            cd(Rootpath)
        end     
    end
%%

% function to determine which logadata the user wants to display and
% opening the editor to display it , it has a linux and windows version to
% use geddit or notepad, as these are always available and allow the user
% to edit the file happily. 

% the mode switch determines which type of file to open, a feed log file or
% a event log file
% the unit variable controls which exact log case to open, each unit
% recieves a number based on the menu item handle which called the script
% and so may not be the actual unit ID, some cases also open multiple
% files. 
    function display_logdata(source,event,mode,unit)
        if isunix == 1
            switch mode
                case 1
                % switch case where requiring the feed_times logs     
                    switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                        disp('Opening the Feedtimes log for Line 1')
                        cd(path2feedlog)
                            ! gedit Feed_1_times.txt &
                            cd(Rootpath)
                        case 2
                            disp('Opening the Feedtimes log for Line 2')
                            cd(path2feedlog)
                            ! gedit Feed_2_times.txt &
                            cd(Rootpath)
                        case 3
                            cd(path2feedlog)
                            ! gedit Feed_3_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for Line 3')
                        case 4
                            cd(path2feedlog)
                            ! gedit Feed_4_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for Line 4')
                        case 5    
                            cd(path2feedlog)
                            ! gedit Feed_5_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for Line 5')
                        case 6
                            cd(path2feedlog)
                            ! gedit Splitter_times_1.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for the splitter')
                        case 7
                            cd(path2feedlog)
                            ! gedit Splitter_times_2.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for the splitter') 
                        case 8
                            cd(path2feedlog)
                            ! gedit Upstream_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes Log for The Upstream Unit')
                        case 9
                            if exist(path2feedrtexptoutputs) ~= 0
                                cd(path2userresults)
                                edit Feed_Rate_Experiments_Results.txt & 
                                cd(Rootpath)
                            end
                        case 10
                            if exist(path2palletexptoutputs) ~= 0
                                cd(path2userresults)
                                edit Pallet_Experiments_Results.txt & 
                                cd(Rootpath)
                            end
                    end 
                case 2
                % case where the event log for a feed unit is requried    
                        switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                            disp('Opening the Event log for FeedLine 1') 
                            cd(path2eventlog)
                            !gedit Feed_1.log &
                            cd(Rootpath)
                        case 2
                            disp('Opening the Event log for FeedLine 2')
                            cd(path2eventlog)
                            !gedit Feed_2.log &
                            cd(Rootpath)
                        case 3
                            disp('Opening the Event log for FeedLine 3')
                            cd(path2eventlog)
                            !gedit Feed_3.log &
                            cd(Rootpath)                                                        
                            case 4
                            disp('Opening the Event log for Feed Line 4')
                            cd(path2eventlog)
                            !gedit Feeduntitled2.m_4.log &
                            cd(Rootpath)  
                            case 5
                            disp('Opening the Event log for Feed Line 5')
                            cd(path2eventlog)
                            !gedit Feed_5.log &
                            cd(Rootpath)  
                        end        
                case 3
                % case where the event log for a transfer unit is requried     
                        switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                            disp('Opening the Event Log for Transfer Line 1') 
                            cd(path2eventlog)
                            !gedit Transfer_1.log &
                            cd(Rootpath)
                        case 2
                            disp('Opening the Event Log for Transfer Line 2')
                            cd(path2eventlog)
                            !gedit Transfer_2.log &
                            cd(Rootpath)
                        case 3
                            disp('Opening the Event Log for Transfer Line 3')
                            cd(path2eventlog)
                            !gedit Transfer_3.log &
                            cd(Rootpath) 
                        case 4
                            disp('Opening the Event Log for Transfer Line 4')
                            cd(path2eventlog)
                            !gedit Transfer_4.log &
                            cd(Rootpath) 
                        case 5
                            disp('Opening the Event Log for Transfer Line 5')
                            cd(path2eventlog)
                            !gedit Transfer_5.log &
                            cd(Rootpath)                       
                        end 
                case 4
                % case where the event log for a mainline unit is requried 
                        switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                           disp('Opening the Event Log for MainLine 1') 
                           cd(path2eventlog)
                           !gedit Main_1.log &
                           cd(Rootpath)
                        case 2
                           disp('Opening the Event Log for MainLine 2')
                           cd(path2eventlog)
                           !gedit Main_2.log &
                           cd(Rootpath)

                        case 3
                           disp('Opening the Event Log for MainLine 3')
                           cd(path2eventlog)
                           !gedit Main_3.log &
                           cd(Rootpath)
                       case 4
                            disp('Opening the Event Log for MainLine 4')
                           cd(path2eventlog)
                           !gedit Main_4.log &
                           cd(Rootpath)
                       case 5
                           disp('Opening the Event Log for MainLine 5')
                           cd(path2eventlog)
                           !gedit Main_5.log &
                           cd(Rootpath)                                                               
                        end     
                case 5
                    % case where all feed time logs are required
                    disp('Opening all Control Feedtime Logs')
                    cd(path2feedlog)
                    if exist(path2feedlog1) ~=0
                    ! gedit Feed_1_times.txt &
                    end
                    if exist(path2feedlog2) ~=0
                    ! gedit Feed_2_times.txt &
                    end
                    if exist(path2feedlog3) ~=0
                    ! gedit Feed_3_times.txt &
                    end
                    if exist(path2feedlog4) ~=0
                    ! gedit Feed_4_times.txt &
                    end
                    if exist(path2feedlog5) ~=0
                    ! gedit Feed_5_times.txt &
                    end
                    if exist(path2splitter1log) ~=0
                    ! gedit Splitter_times_1.txt &
                    end
                    if exist(path2splitter2log) ~=0
                    ! gedit Splitter_times_2.txt &
                    end
                    if exist(path2feedlogupstream) ~=0
                    ! gedit Upstream_times.txt &
                    end
                    cd(Rootpath)
                case 6
                    % case where all event logs are requried 
                    disp('Opening All Event Logs')
                    cd(path2eventlog);
                    if exist(fpath2feed1log) ~=0
                    !gedit Feed_1.log &
                    end
                    if exist(fpath2feed2log) ~=0
                    !gedit Feed_2.log &
                    end
                    if exist(fpath2feed3log) ~=0
                    !gedit Feed_3.log &
                    end
                    if exist(fpath2feed4log) ~=0
                    !gedit Feed_4.log &
                    end
                    if exist(fpath2feed5log) ~=0
                    !gedit Feed_5.log &
                    end
                    if exist(fpath2transfer1log) ~=0
                    !gedit Transfer_1.log &
                    end
                    if exist(fpath2transfer2log) ~=0
                    !gedit Transfer_2.log &
                    end
                    if exist(fpath2transfer3log) ~=0
                    !gedit Transfer_3.log &
                    end
                    if exist(fpath2transfer4log) ~=0
                    !gedit Transfer_4.log &
                    end
                    if exist(fpath2transfer5log) ~=0
                    !gedit Transfer_5.log &
                    end
                    if exist(fpath2main1log) ~=0
                    !gedit Main_1.log &
                    end
                    if exist(fpath2main2log) ~=0
                    !gedit Main_2.log &
                    end
                    if exist(fpath2main3log) ~=0
                    !gedit Main_3.log &
                    end
                    if exist(fpath2main4log) ~=0
                    !gedit Main_4.log &
                    end
                    if exist(fpath2main5log) ~=0
                    !gedit Main_5.log &
                    end
                    if exist(fpath2splitter1eventlog) ~=0
                    !gedit Splitter_unit1.log &
                    end
                    if exist(fpath2splitter2eventlog) ~=0
                    !gedit Splitter_unit2.log &
                    end
                    if exist(fpath2upstreamlog) ~=0
                    !gedit Upstream_unit.log &
                    end
                    cd(Rootpath);
                case 7
                    % case to open the splitter unit logs 
                    disp('Opening The Splitter Unit 1 Event Log')
                    cd(path2eventlog);
                    !gedit Splitter_unit1.log &
                    cd(Rootpath);
               case 8
                    % case to open the splitter unit logs 
                    disp('Opening The Splitter Unit 2 Event Log')
                    cd(path2eventlog);
                    !gedit Splitter_unit2.log &
                    cd(Rootpath);
                case 9
                    disp('Opening The Upstream Units Event Log')
                    cd(path2eventlog);
                    !gedit Upstream_unit.log &
                    cd(Rootpath);
                case 10
                    disp('Open Results Files')
                    if exist(path2palletexptoutputs) ~= 0
                        cd(path2userresults)
                        !gedit Pallet_Experiments_Results.txt & 
                        cd(Rootpath)
                    else
                        disp('No Buffer Size Experiment Results To Display')
                    end % end if 
                    if exist(path2feedrtexptoutputs) ~= 0
                        cd(path2userresults)
                        !gedit Feed_Rate_Experiments_Results.txt & 
                        cd(Rootpath)
                    else
                        disp('No Feed rate Experiment Results To Display')
                    end % end if 
                case 11
                    disp('Opening Global Controller Logfile')
                    cd(path2userresults)
                        !gedit Global_Controller.log & 
                    cd(Rootpath)
            end % switch end 
        elseif ispc == 1 
            switch mode
                case 1
                % switch case where requiring the feed_times logs     
                    switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                            disp('Opening the Feedtimes log for Line 1')
                            cd(path2feedlog)
                            ! notepad Feed_1_times.txt &
                            cd(Rootpath)
                        case 2
                            disp('Opening the Feedtimes log for Line 2')
                            cd(path2feedlog)
                            ! notepad Feed_2_times.txt &
                            cd(Rootpath)
                        case 3
                            cd(path2feedlog)
                            ! notepad Feed_3_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for Line 3')
                        case 4
                            cd(path2feedlog)
                            ! notepad Feed_4_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for Line 4')
                        case 5    
                            cd(path2feedlog)
                            ! notepad Feed_5_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for Line 5')
                        case 6
                            cd(path2feedlog)
                            ! notepad Splitter_times_1.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for the splitter')
                        case 7
                            cd(path2feedlog)
                            ! notepad Splitter_times_2.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes log for the splitter') 
                        case 8
                            cd(path2feedlog)
                            ! notepad Upstream_times.txt &
                            cd(Rootpath)
                            disp('Opening the Feedtimes Log for The Upstream Unit')
                        case 9
                            if exist(path2feedrtexptoutputs) ~= 0
                                cd(path2userresults)
                                edit Feed_Rate_Experiments_Results.txt & 
                                cd(Rootpath)
                            end
                        case 10
                            if exist(path2palletexptoutputs) ~= 0
                                cd(path2userresults)
                                edit Pallet_Experiments_Results.txt & 
                                cd(Rootpath)
                            end
                    end 
                case 2
                % case where the event log for a feed unit is requried    
                        switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                            disp('Opening the Event log for FeedLine 1') 
                            cd(path2eventlog)
                            !notepad Feed_1.log &
                            cd(Rootpath)
                        case 2
                            disp('Opening the Event log for FeedLine 2')
                            cd(path2eventlog)
                            !notepad Feed_2.log &
                            cd(Rootpath)
                        case 3
                            disp('Opening the Event log for FeedLine 3')
                            cd(path2eventlog)
                            !notepad Feed_3.log &
                            cd(Rootpath)                                                        
                            case 4
                            disp('Opening the Event log for Feed Line 4')
                            cd(path2eventlog)
                            !notepad Feed_4.log &
                            cd(Rootpath)  
                            case 5
                            disp('Opening the Event log for Feed Line 5')
                            cd(path2eventlog)
                            !notepad Feed_5.log &
                            cd(Rootpath)  
                        end        
                case 3
                % case where the event log for a transfer unit is requried     
                        switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                            disp('Opening the Event Log for Transfer Line 1') 
                            cd(path2eventlog)
                            !notepad Transfer_1.log &
                            cd(Rootpath)
                        case 2
                            disp('Opening the Event Log for Transfer Line 2')
                            cd(path2eventlog)
                            !notepad Transfer_2.log &
                            cd(Rootpath)
                        case 3
                            disp('Opening the Event Log for Transfer Line 3')
                            cd(path2eventlog)
                            !notepad Transfer_3.log &
                            cd(Rootpath) 
                        case 4
                            disp('Opening the Event Log for Transfer Line 4')
                            cd(path2eventlog)
                            !notepad Transfer_4.log &
                            cd(Rootpath) 
                        case 5
                            disp('Opening the Event Log for Transfer Line 5')
                            cd(path2eventlog)
                            !notepad Transfer_5.log &
                            cd(Rootpath)                       
                        end 
                case 4
                % case where the event log for a mainline unit is requried 
                        switch unit 
                        % switch depending on which unit is to be evaulated 
                        case 1
                           disp('Opening the Event Log for MainLine 1') 
                           cd(path2eventlog)
                           !notepad Main_1.log &
                           cd(Rootpath)
                        case 2
                           disp('Opening the Event Log for MainLine 2')
                           cd(path2eventlog)
                           !notepad Main_2.log &
                           cd(Rootpath)

                        case 3
                           disp('Opening the Event Log for MainLine 3')
                           cd(path2eventlog)
                           !notepad Main_3.log &
                           cd(Rootpath)
                       case 4
                            disp('Opening the Event Log for MainLine 4')
                           cd(path2eventlog)
                           !notepad Main_4.log &
                           cd(Rootpath)
                       case 5
                           disp('Opening the Event Log for MainLine 5')
                           cd(path2eventlog)
                           !notepad Main_5.log &
                           cd(Rootpath)                                                               
                        end     
                case 5
                    % case where all feed time logs are required
                    disp('Opening all Control Feedtime Logs')
                    cd(path2feedlog)
                    if exist(path2feedlog1) ~=0
                    ! notepad Feed_1_times.txt &
                    end
                    if exist(path2feedlog2) ~=0
                    ! notepad Feed_2_times.txt &
                    end
                    if exist(path2feedlog3) ~=0
                    ! notepad Feed_3_times.txt &
                    end
                    if exist(path2feedlog4) ~=0
                    ! notepad Feed_4_times.txt &
                    end
                    if exist(path2feedlog5) ~=0
                    ! notepad Feed_5_times.txt &
                    end
                    if exist(path2splitter1log) ~=0
                    ! notepad Splitter_times_1.txt &
                    end
                    if exist(path2splitter2log) ~=0
                    ! notepad Splitter_times_2.txt &
                    end
                    if exist(path2feedlogupstream) ~=0
                    ! notepad Upstream_times.txt &
                    end
                    cd(Rootpath)
                case 6
                    % case where all event logs are requried 
                    disp('Opening All Event Logs')
                    cd(path2eventlog);
                    if exist(fpath2feed1log) ~=0
                    !notepad Feed_1.log &
                    end
                    if exist(fpath2feed2log) ~=0
                    !notepad Feed_2.log &
                    end
                    if exist(fpath2feed3log) ~=0
                    !notepad Feed_3.log &
                    end
                    if exist(fpath2feed4log) ~=0
                    !notepad Feed_4.log &
                    end
                    if exist(fpath2feed5log) ~=0
                    !notepad Feed_5.log &
                    end
                    if exist(fpath2transfer1log) ~=0
                    !notepad Transfer_1.log &
                    end
                    if exist(fpath2transfer2log) ~=0
                    !notepad Transfer_2.log &
                    end
                    if exist(fpath2transfer3log) ~=0
                    !notepad Transfer_3.log &
                    end
                    if exist(fpath2transfer4log) ~=0
                    !notepad Transfer_4.log &
                    end
                    if exist(fpath2transfer5log) ~=0
                    !notepad Transfer_5.log &
                    end
                    if exist(fpath2main1log) ~=0
                    !notepad Main_1.log &
                    end
                    if exist(fpath2main2log) ~=0
                    !notepad Main_2.log &
                    end
                    if exist(fpath2main3log) ~=0
                    !notepad Main_3.log &
                    end
                    if exist(fpath2main4log) ~=0
                    !notepad Main_4.log &
                    end
                    if exist(fpath2main5log) ~=0
                    !notepad Main_5.log &
                    end
                    if exist(fpath2splitter1eventlog) ~=0
                    !notepad Splitter_unit1.log &
                    end
                    if exist(fpath2splitter2eventlog) ~=0
                    !notepad Splitter_unit2.log &
                    end
                    if exist(fpath2upstreamlog) ~=0
                    !notepad Upstream_unit.log &
                    end
                    cd(Rootpath);
                case 7
                    % case to open the splitter unit logs 
                    disp('Opening The Splitter Unit 1 Event Log')
                    cd(path2eventlog);
                    !notepad Splitter_unit1.log &
                    cd(Rootpath);
               case 8
                    % case to open the splitter unit logs 
                    disp('Opening The Splitter Unit 2 Event Log')
                    cd(path2eventlog);
                    !notepad Splitter_unit2.log &
                    cd(Rootpath);
                case 9
                    disp('Opening The Upstream Units Event Log')
                    cd(path2eventlog);
                    !notepad Upstream_unit.log &
                    cd(Rootpath);
                case 10
                    disp('Open Results Files')
                    if exist(path2palletexptoutputs) ~= 0
                        cd(path2userresults)
                     !notepad Pallet_Experiments_Results.txt & 
                        cd(Rootpath)
                    end % end if 
                    if exist(path2feedrtexptoutputs) ~= 0
                        cd(path2userresults)
                        !notepad Feed_Rate_Experiments_Results.txt & 
                        cd(Rootpath)
                    end % end if
               case 11
                    disp('Opening Global Controller Logfile')
                    cd(path2eventlog)
                        !notepad Global_Controller.log & 
                    cd(Rootpath)
                    
            end % switch end 
        end % end of OS selection
    end % function end 

%%
function Update_menus_main(source,event)
    % this is the function which selectively greys out and makes inactive
    % thos menu options which allow the opening of the log files when no
    % log file can be found, for example if the unit was not running.
    
    % check the state of the files at this moment and compare it to the
    % state of the files which are currently drawn. 
    check_menu_state_main
    % if the state hasn't changed do not bother to redraw, and return 
    if current_menustate == existing_menustate
        return
    else
        % else if the files present have changed then update the menu to
        % reflect the new status 
        
     resultmenuhandles = findall(resultmenu,'type','uimenu');
     logmenuhandles = findall(logmenu,'type','uimenu');
     delete(resultmenuhandles)
     delete(logmenuhandles)
     % find the existing menu handles and delete them, such that new ones
     % can be created. 
     
     % update the current menu state to reflect the one that is about to be
     % drawn. 
     existing_menustate = current_menustate;
     
     % create the menus again in case they are corrupted. 
     resultmenu = uimenu(Legoline_GUI,'label','Data Logging');
     logmenu = uimenu(Legoline_GUI,'label','Event Logs');
     
     % print a heading 
     h0 = uimenu(resultmenu,'label','Feed Logs','Enable','off');
     
     % this basically loops over all existing items for the feed_logs menu.
     % the existence of the file is confirmed, if it is present then the
     % menu item appears as functional, else it appears greyed out 
     
     
     if exist(path2feedlog1) ~=0
         h1=uimenu(resultmenu,'label','Feed Unit 1','separator','on','Callback',{@display_logdata,1,1});
     else
         h1=uimenu(resultmenu,'label','Feed Unit 1','separator','on','Callback',{@display_logdata,1,1},'Enable','off');
     end
     if exist(path2feedlog2) ~=0
         h2 = uimenu(resultmenu,'label','Feed Unit 2','Callback',{@display_logdata,1,2});
     else
         h2 = uimenu(resultmenu,'label','Feed Unit 2','Callback',{@display_logdata,1,2},'Enable','off');
     end
      if exist(path2feedlog3) ~=0
         h3 = uimenu(resultmenu,'label','Feed Unit 3','Callback',{@display_logdata,1,3});
     else
         h3 = uimenu(resultmenu,'label','Feed Unit 3','Callback',{@display_logdata,1,3},'Enable','off');
      end
      if exist(path2feedlog4) ~=0
         h4 = uimenu(resultmenu,'label','Feed Unit 4','Callback',{@display_logdata,1,4});
     else
         h4 = uimenu(resultmenu,'label','Feed Unit 4','Callback',{@display_logdata,1,4},'Enable','off');
      end
      if exist(path2feedlog5) ~=0
         h5 = uimenu(resultmenu,'label','Feed Unit 5','Callback',{@display_logdata,1,5});
      else
         h5 = uimenu(resultmenu,'label','Feed Unit 5','Callback',{@display_logdata,1,5},'Enable','off');
      end
     if exist(path2splitter1log) ~=0
         h6 = uimenu(resultmenu,'label','Splitter 1','Callback',{@display_logdata,1,6});
     else
         h6 = uimenu(resultmenu,'label','Splitter 1','Callback',{@display_logdata,1,6},'Enable','off');
     end
     if exist(path2splitter2log) ~=0
         h7 = uimenu(resultmenu,'label','Splitter 2','Callback',{@display_logdata,1,7});
     else
         h7 = uimenu(resultmenu,'label','Splitter 2','Callback',{@display_logdata,1,7},'Enable','off');
     end
     if exist(path2feedlogupstream) ~=0
         h8 = uimenu(resultmenu,'label','Upstream','Callback',{@display_logdata,1,8});
     else
         h8 = uimenu(resultmenu,'label','Upstream','Callback',{@display_logdata,1,8},'Enable','off');
     end
         h9 = uimenu(resultmenu,'label','Experiment Results','separator','on','Enable','off');
    if exist(path2feedrtexptoutputs) ~= 0
         h10 = uimenu(resultmenu,'label','Feed Rate Experiment','separator','on','Callback',{@display_logdata,1,9});
    else 
         h10 = uimenu(resultmenu,'label','Feed Rate Experiment','separator','on','enable','off','Callback',{@display_logdata,1,9});   
    end   
    if exist(path2palletexptoutputs) ~= 0
        h11 = uimenu(resultmenu,'label','Buffer Size Experiment','Callback',{@display_logdata,1,10});
    else
        h12 = uimenu(resultmenu,'label','Buffer Size Experiment','enable','off','Callback',{@display_logdata,1,10}); 
    end
        h13 = uimenu(resultmenu,'label','Archive Tool','separator','on','Call','Archive_Tool_GUI');

     % this basically lops over all existing items for the event_logs menu.
     % the existence of the file is confirmed, if it is present then the
     % menu item appears as functional, else it appears greyed out 
        ha0 = uimenu(logmenu,'label','Event Logs','separator','on','Enable','off');
    if exist(fpath2feed1log) ~=0
        ha1 = uimenu(logmenu,'label','Feed Unit 1','separator','on','Callback',{@display_logdata,2,1});
    else
        ha1 = uimenu(logmenu,'label','Feed Unit 1','separator','on','Callback',{@display_logdata,2,1},'Enable','off');   
    end
    if exist(fpath2feed2log) ~=0
        ha2 = uimenu(logmenu,'label','Feed Unit 2','Callback',{@display_logdata,2,2});
    else
        ha2 = uimenu(logmenu,'label','Feed Unit 2','Callback',{@display_logdata,2,2},'Enable','off');  
    end
    if exist(fpath2feed3log) ~=0
        ha3 = uimenu(logmenu,'label','Feed Unit 3','Callback',{@display_logdata,2,3});
    else
        ha3 = uimenu(logmenu,'label','Feed Unit 3','Callback',{@display_logdata,2,3},'Enable','off');  
    end
    if exist(fpath2feed4log) ~=0
        ha4 = uimenu(logmenu,'label','Feed Unit 4','Callback',{@display_logdata,2,4});
    else
        ha4 = uimenu(logmenu,'label','Feed Unit 4','Callback',{@display_logdata,2,4},'Enable','off');  
    end
    if exist(fpath2feed5log) ~=0
        ha5 = uimenu(logmenu,'label','Feed Unit 5','Callback',{@display_logdata,2,5});
    else
        ha5 = uimenu(logmenu,'label','Feed Unit 5','Callback',{@display_logdata,2,5},'Enable','off');  
    end
    if exist(fpath2transfer1log) ~=0
        ha6 = uimenu(logmenu,'label','Transfer Unit 1','Callback',{@display_logdata,3,1});
    else
        ha6 = uimenu(logmenu,'label','Transfer Unit 1','Callback',{@display_logdata,3,1},'Enable','off');    
    end
    if exist(fpath2transfer2log) ~=0
        ha7 = uimenu(logmenu,'label','Transfer Unit 2','Callback',{@display_logdata,3,2});
    else
        ha7 = uimenu(logmenu,'label','Transfer Unit 2','Callback',{@display_logdata,3,2},'Enable','off'); 
    end
    if exist(fpath2transfer3log) ~=0
        ha8 = uimenu(logmenu,'label','Transfer Unit 3','Callback',{@display_logdata,3,3});
    else
        ha8 = uimenu(logmenu,'label','Transfer Unit 3','Callback',{@display_logdata,3,3},'Enable','off'); 
    end
    if exist(fpath2transfer4log) ~=0
        ha9 = uimenu(logmenu,'label','Transfer Unit 4','Callback',{@display_logdata,3,4});
    else
        ha9 = uimenu(logmenu,'label','Transfer Unit 4','Callback',{@display_logdata,3,4},'Enable','off'); 
    end
    if exist(fpath2transfer5log) ~=0
        ha10 = uimenu(logmenu,'label','Transfer Unit 5','Callback',{@display_logdata,3,5});
    else
        ha10 = uimenu(logmenu,'label','Transfer Unit 5','Callback',{@display_logdata,3,5},'Enable','off'); 
    end
    if exist(fpath2main1log) ~=0
        ha11 = uimenu(logmenu,'label','Mainline Unit 1','Callback',{@display_logdata,4,1});
    else 
        ha11 = uimenu(logmenu,'label','Mainline Unit 1','Callback',{@display_logdata,4,1},'Enable','off');   
    end
    if exist(fpath2main2log) ~=0
        ha12 = uimenu(logmenu,'label','Mainline Unit 2','Callback',{@display_logdata,4,2});
    else 
        ha12 = uimenu(logmenu,'label','Mainline Unit 2','Callback',{@display_logdata,4,2},'Enable','off');  
    end
    if exist(fpath2main3log) ~=0
        ha13 = uimenu(logmenu,'label','Mainline Unit 3','Callback',{@display_logdata,4,3});
    else 
        ha13 = uimenu(logmenu,'label','Mainline Unit 3','Callback',{@display_logdata,4,3},'Enable','off');  
    end
    if exist(fpath2main4log) ~=0
        ha14 = uimenu(logmenu,'label','Mainline Unit 4','Callback',{@display_logdata,4,4});
    else 
        ha14 = uimenu(logmenu,'label','Mainline Unit 4','Callback',{@display_logdata,4,4},'Enable','off');  
    end
    if exist(fpath2main5log) ~=0
        ha15 = uimenu(logmenu,'label','Mainline Unit 5','Callback',{@display_logdata,4,5});
    else 
        ha15 = uimenu(logmenu,'label','Mainline Unit 5','Callback',{@display_logdata,4,5},'Enable','off');  
    end
    if exist(fpath2splitter1eventlog) ~=0
        ha16 = uimenu(logmenu,'label','Splitter 1','Callback',{@display_logdata,7,0});
    else 
        ha16 = uimenu(logmenu,'label','Splitter 1','Callback',{@display_logdata,7,0},'Enable','off');   
    end
    if exist(fpath2splitter2eventlog) ~=0
        ha17 = uimenu(logmenu,'label','Splitter 2','Callback',{@display_logdata,8,0});
    else 
        ha17 = uimenu(logmenu,'label','Splitter 2','Callback',{@display_logdata,8,0},'Enable','off'); 
    end
    if exist(fpath2upstreamlog) ~=0
        ha18 = uimenu(logmenu,'label','Upstream','Callback',{@display_logdata,9,0});
    else
        ha18 = uimenu(logmenu,'label','Upstream','Callback',{@display_logdata,9,0},'Enable','off');   
    end
    if exist(fpath2globallog)  ~= 0
        ha19 = uimenu(logmenu,'label','Global Controller','Callback',{@display_logdata,11,0});
    else
        ha19 = uimenu(logmenu,'label','Global Controller','Callback',{@display_logdata,11,0},'Enable','off');   
    end 
    % this adds the final two items, which invoke the graphing tool on some
    % data
    uimenu(logmenu,'label','Light Sensor Data','Callback',{@Graphing_Tool_GUI_Function2},'separator','on');
    uimenu(logmenu,'label','Error Monitoring','callback',{@Graphing_Tool_GUI_Function2});
    end % end of if case where menu needs updating 
end% end of update menus callback function 
% end nested functions 
end