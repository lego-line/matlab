% initialise.m - script file which reads the config file and checks which
% units are to be run.  The run options are written to the command window
% for validation and teh appropriate scripts are run in the new instances
% of matlab that are opened. The instances are opeend from upstream to
% downstream to allow purging of pallets from the mainline and the transfer
% lines

% if statement to prevent the unit being overloaded by the user double
% pressing buttons or issuing erroneous commands. 
if Ready_Flag == 0
    % in this case the ready flag shows the unit is not running and is
    % uninitailised and hence is ready to be run 
    
    % set the ready flag to show in itialisation is being and will have
    % been performed 
    Ready_Flag =1; 
    % change to the root folder, this is requried for the operations that
    % are to come to force all instances of matlab called to open in this
    % folder also as a fixed reference point and having some key scripts
    % such as FindRootPath readily available. 
    cd(Rootpath);
    
    
    %Close any NXT threads that might be inadvertently already open
    COM_CloseNXT('all')

    %Check GO.txt exists
    Go = exist (path2go);
    %If GO.txt exists, change it to STOP.txt so that system does not run until user specifies
    if Go == 2
        movefile(path2go,path2stop)
    end
    
    % Purge the old log files so new ones can be generated
    Purge_Logs
    
    % create a new error log file which states that there is no error yet.
    % This can be modified by any unit which fails to identify the location
    % and cuase of the failure. 
    finitid = fopen(path2errorlog,'w');
    fprintf(finitid,'There was no error');
    fclose(finitid);
    
    % check if configfile is setup for experiment mode- if in experiment
    % mode then a config file will have been written into the shadow
    % folder, else the editable config file must be copied in its place 
    if exist(path2config) == 0
        % cases for pc and unix are required to get around some
        % restrictions on matlab copyfile operations 
        if ispc == 1
            copyfile(path2writableconfig,path2config);
        elseif isunix == 1
            command = ['cp -f ' path2writableconfig ' ' path2config];
            system(command);
        elseif ismac == 1
            % MAC not supported 
            disp('ERROR: MAC OS NOT SUPPORTED - TRY WINDOWS OR LINUX INSTEAD')
            break
        else
            disp('ERROR: Unknown Operating System')
            break
        end 
    end

    %% Read modules present
    
    %Open master config file
    fid = fopen(path2master,'rt');
    out = textscan(fid,'%s	%s	%s	%s');
    fclose(fid);

    % find the number of feed lines, display it and convert it into a
    % number rather than a string from the file 
    ind=strmatch('No_of_Feedlines',out{1},'exact');
    Number_of_Feedlines = out{2}(ind);
    disp(['The number of feed lines is ',Number_of_Feedlines{1}])
    Number_of_Feedlines=str2num(Number_of_Feedlines{1});
    % and do the same for the number of splitters 
    ind=strmatch('No_of_Splitters',out{1},'exact');
    Number_of_Splitters = out{2}(ind);
    disp(['The number of splitters is ',Number_of_Splitters{1}])
    Number_of_Splitters=str2num(Number_of_Splitters{1});
    % these are used in the following loops to let them know how many units
    % are needed to be looped over such that all units are started 
    
    %Open config file
    fid = fopen(path2config,'rt');
    %Scan within file for text with certain formatting
    out = textscan(fid,'%s %s	%s	%s	%s');
    %Close file
    fclose(fid);
    
    % first look up the method of control to be employed in the run 
    ind=strmatch('Control_Method',out{1},'exact');
    control_type = out{2}(ind);
    
    % print it into a file in the shadow folder such that it can be
    % accessed by each of the new instances and  used to control the
    % folders which are added to the path and hence the versions of the
    % common scripts which correspond to each of the control systems.The
    % files have the same names and are screened from matlab by
    % selectively adding folders to the path of each isnatnce suhc that 
    % only one file with the name called can be located  
    fid=fopen(path2controltype,'w');
    fprintf(fid,control_type{1});
    fclose(fid);
    
    % if the type is global control then an instance of matlab to run the
    % global controller is required, this command opens a new version of
    % matlab and runs the required scripts to set it in motion.
    if strcmp(control_type,'Global_Control') == 1
        !matlab  -nodesktop -minimize -nosplash -r FindRootPath;run(path2pathingscript);Global_Controller &
    end 
    
    % look up the upstream units running orders and determine if the
    % upstream unit is to run. In this case open an instance of matlab and
    % run the appropriate script to set it in motion. 
    ind=strmatch('Upstream',out{1},'exact');
    Upstream = out{2}(ind);
    UpstreamMode= out{3}(ind);   
    if Upstream{1} == '1' 
        % present some info for the user on teh state of the upstream unit.
        disp('Upstream Unit Present')    
        disp(['The priority system is ',UpstreamMode{1},' line Priority']);
        !matlab  -minimize -nodesktop -nosplash -r FindRootPath;run(path2pathingscript);Upstream &
    end
    %P_time is a pause between loading events to allow the instances of
    %matlab to load a little faster by not overloading the processor with
    %many processes at once 
    p_time = 3; 
    pause(p_time)
    
    % in this section the script loops over all of the feed lines from 1 up
    % to the maximum stipulated in the master file 
    for index = Number_of_Feedlines:-1:1
        % for each feed line the relevant section of the config file giving
        % the salient buffer sizes etc is found by looking in the first
        % column and data copied in 
        ind = strmatch(['Line',num2str(index)],out{1},'exact');
        if length(ind) > 1
            ind=ind(1);
        end 
        % if the line is to be run at all then take some action else if the
        % line is not to be run ignore this eetup stage for it 
        if  str2num(out{1,2}{ind,1}) == 1
            % create a string dependant on if the unit is to run in as a
            % feeder or as a pure data gathering system  and create a
            % string to display to the user to this effect 
            if str2num(out{1,3}{ind,1}) == 0
                str=strcat('Line ',num2str(index),' Running: Data Gathering Only');
            else
                str=strcat('Line ',num2str(index),' Running:Tranfer Line Buffer Limit = ',out{4}(ind),' Mainline Buffer = ',out{5}(ind));
            end 
            disp(str{1})
            % use the index to set the feed_id, Transfer_id and Main_id for
            % the purpose of the following writing script which generate
            % the required startup files 
            feed_id=index;
            Transfer_id= index;
            Main_id = index; 
            % run the writing scripts to generate the start up files
            % required to differentiate between units
            % whilst allowing a large body of common code. This allows
            % modularity to be maintained, and keeps the size of the file
            % down when copying it by removing these files which are small
            % and numerous from the folder when they are not required. 
            Write_Feed_Startup
            Write_Main_Startup
            Write_Transfer_Startup
            % the following commands create the new instances of matlab
            % required to run the line and set them running on the correct
            % Startup files as generated previously 
            eval(['!matlab  -minimize -nodesktop -nosplash -r FindRootPath;run(path2pathingscript);Transfer_',num2str(Transfer_id),' > Transfer_unit',num2str(Transfer_id),'.log 2>&1 &']);
            pause(p_time)
            eval(['!matlab  -minimize -nodesktop -nosplash -r FindRootPath;run(path2pathingscript);Feed_',num2str(feed_id),' > Feed_unit',num2str(feed_id),'.log 2>&1 &']);  
            eval(['!matlab  -minimize -nodesktop -nosplash -r FindRootPath;run(path2pathingscript);Main_',num2str(Main_id),' > Main_unit',num2str(Main_id),'.log 2>&1 &']); 
        else % if the unit is not running 
            % create a string to tell the user the line is not running 
            str=strcat('Line ',num2str(index),' Not Running');
            disp(str{1})
        end % end of if line present loop 
    end 
    

     % in this section the script loops over all of the splitters from 1 up
    % to the maximum stipulated in the master file 
    for index = Number_of_Splitters:-1:1
        % for each splitter the relevant section of the config file giving
        % the salient splitter decisions etc is found by looking in the first
        % column and data copied in 
        ind = strmatch(['Splitter',num2str(index)],out{1},'exact');
        if length(ind) > 1
            ind=ind(1);
        end
        eval(['Splitter',num2str(index),'= out{2}(ind);'])
        
        if str2num(eval(['Splitter',num2str(index),'{1}'])) == 1
            % copy relevant data for each splitter from the config file and
            % make it available to assess what the splitter should be
            % doing, i.e. if is is a colour or code or other splitter and
            % what the criteria for splitting is 
            eval(['Splitter_Mode',num2str(index),' =out{3}(ind);'])
            eval(['ind = strmatch(''PalletCode',num2str(index),''',out{1});'])
            eval(['PalletCode',num2str(index),' = [out{2}(ind),out{3}(ind),out{4}(ind)];'])
            eval(['ind = strmatch(''ColourCode',num2str(index),''',out{1});'])
            eval(['ColourCode',num2str(index),' = [out{2}(ind)];'])
            % create some string to tell the user what the splitter should
            % be doing in the main window  
            if strcmp(eval(['Splitter_Mode',num2str(index),'{1}']),'Colour') == 1
                str=strcat('Splitter ',num2str(index),' Running:Mode = Colour Detection, Seperation Criteria = ',eval(['ColourCode',num2str(index),'{1}']));
            elseif strcmp(eval(['Splitter_Mode',num2str(index),'{1}']),'Code') == 1
                str=strcat('Splitter ',num2str(index),' Running:Mode = Code Detection, Seperation Criteria = ',eval(['PalletCode',num2str(index),'{1}']),',',eval(['PalletCode',num2str(index),'{2}']),',',eval(['PalletCode',num2str(index),'{3}']));
            end
            disp(str)
            % in the same manner as for the feed lines use the index to
            % generate a Splitter_index variable and use it to create a
            % startup file which is present only through the running time
            % and then initialise a new instance of matlab to run this file
            Splitter_id=index;
            Write_Splitter_Startup
            eval(['!matlab -minimize -nodesktop -nosplash -r FindRootPath;run(path2pathingscript);Splitter_Unit_',num2str(Splitter_id),' &']); 
        end
    end
    % set the ready flag to show the unit is ready to start 
    Ready_Flag = 1; 
    % Since the initialisation process is lengthy this locks the control to
    % stop the user doing something which would upset the unit. hence the
    % tactic employed in other lengthy operations of gicing the user a wait
    % bar is employed. This one is quite simpe and waits for a fixed time
    % called 'initialisation_time' and slowly updates to allow the unit
    % time to fully initialise as not all of the initailisation processes
    % invlove moving aprts that can be visibly seen. 
    waiting = waitbar(0,'Please wait for initialisation to complete');
    movegui(waiting,'center')
    set(waiting,'name','Legoline Initialisation Bar');
    tic;
    initialisation_time = 15;
    while toc <initialisation_time
        waitbar(toc / initialisation_time)
        pause (0.3)
    end
    close(waiting) 
    disp('Type "Start" to go, "Finish" to stop. Please wait for motors to stop spinning before starting') 
elseif Ready_Flag == 1
    % In this case the unit has already been initialised but has not yet
    % been started. This section tells the user that this is the case
    % and preventing any hamrful commands being sent 
    disp('Type "Start" to go, "Finish" to stop. Please wait for motors to stop spinning before starting')
    warndlg('The Line Is Already Initialised and ready to Start','Legoline Warning Dialogue')
elseif Ready_Flag == 2
    % in this case the unit has been initialised and started but not yet
    % finished and data harvested, tehrefore the user is informed of the
    % case and told to execute the finish commands 
    disp('The Line cannot Be Initialised Until the Finish Command Has Been Issued')
    warndlg('The Line Cannot Be Initialised until the finish command has been issued','Legoline Warning Dialogue')
end 