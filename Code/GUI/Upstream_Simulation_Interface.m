function [ output_args ] = Upstream_Simulation_Interface(sc,evnt,Filepath,No_of_Feedlines,figure_handle)
%Upstream_Simulation_Interface function which creates a user interface
%window to allow the user to control the upstream simulation by inputing
%the data into a user interface similar to that used by the main
%configuration editor 
global path2gui
      
        % Create a Cell Array To Store The Data While The User Edits It. Each line
        % defaults to periodic of period 20 
        
        % data_text is an array which contains the values of the parameters
        % entered by the user in text format, each row is of the form
        % ControlLineX DistroNameLetter P1 P2 P3 where P denotes a parameter
        % for the distribution
        data_text = cell(1,5);% create the basic cell array structure 
        for i =  1:1:No_of_Feedlines % add the lines to the cell array fields as vectors, this is a little 
            % idiosyncratic but allows a number of code fragments from the
            % other GUI which reads data using text read to be recycled. 
            eval(['data_text{1,1}{',num2str(i),',1} = [''ControlLine',num2str(i),'''];'])
            eval(['data_text{1,2}{',num2str(i),',1} = ''P'';'])
            eval(['data_text{1,3}{',num2str(i),',1} = ''20'';'])
            eval(['data_text{1,4}{',num2str(i),',1} = ''0'';'])
            eval(['data_text{1,5}{',num2str(i),',1} = ''0'';'])
        end 
        disp('Completed Generating Temporary Store')
        
        
        % Set up a number of operating variables. 
        Current_Line = 1; % variable to state which line is currently being edited in order to index the 
        available_lines ={}; % a cell aray to store the names of al of the possible lines 
        for i=1:1:No_of_Feedlines % popualte it with all of the line numbers such that a drop down menu could be created with these as variables and on ach update it starts at the line
            % identified in current line 
            available_lines{i} =num2str(i);
        end 
        On_Vector = ones(No_of_Feedlines,1); % vector to determine if the current line is to run of if it is simply representing a mainline buffering segment to add time delays or buffering capacity. 
        success_flag = 0; 
        
        
        % a Little bit to set up the GUI window
        Simulation_Config_Editor_GUI = figure_handle; % create a window 
        % the colour matrix determines the colours of the various
        % components by supplying 3 complementay colorus as RBG vectror
        % columns 
        colour_matrix =[0.8125,0.6328,0.5586,0.4023,0.6992;0.9258,0.7266,0.6562,0.5469,0.7070;0.8672,0.6875,0.6055,0.5430,0.5598]';
        % get rid of any existing figure tools since this is not a graph
        % and make it look like part of the Legoline 
        set(Simulation_Config_Editor_GUI,'Visible','on','Numbertitle','off','MenuBar','none','color',colour_matrix(3,:),'HandleVisibility','callback','DeleteFcn',@Editor_Tool_Close_Fcn,'Name','Legoline Simulation Configuration','Position',[500,50,800,600]);
        movegui(Simulation_Config_Editor_GUI,'center')
        % call the fucntion to redraw the GUI window initiallly with blank
        % variables. 
        Redraw(0,0)

        
%% Begin Nested Functions 
     function editbox_feedv1_callback(src,evnt)      
         % this function deals with the parameter 1 edit box being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
        if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                % if all is well then we are palce the text value entered
                % into the appropriate location 
                data_text{1,3}{Current_Line,1}  = get(src,'string');
            else 
                % stop them entering a negative paramter 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                data_text{1,3}{Current_Line,1}  = '1';
            end 
        else 
            % stop them entering a non numeric parameter 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            data_text{1,3}{Current_Line,1}  = '1';
        end
        % redraw the user interface to accept the new value 
        Redraw(0,0)
    end % end of upstream edit box callback 1

    function editbox_feedv2_callback(src,evnt)
         % this function deals with the parameter 2 edit box being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
         if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                data_text{1,4}{Current_Line,1}  = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                data_text{1,4}{Current_Line,1}  = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            data_text{1,4}{Current_Line,1}  = '1';
         end       
        Redraw(0,0)
    end % end of upstream edit box callback 2

    function editbox_feedv3_callback(src,evnt)
         % this function deals with the parameter 3 edit box being changed 
         % a lot of this is a santiy check on what the user inputs  and
         % providing warning boxes if they are entering rubbish 
       if isnan(str2double(get(src,'string'))) == 0 
            if str2double(get(src,'string'))> 0
                data_text{1,5}{Current_Line,1}  = get(src,'string');
            else 
                errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
                data_text{1,5}{Current_Line,1}  = '1';
            end 
        else 
            errordlg('Please Enter a Numeric Value Greater Than Zero','Legoline Warning Dialogue');
            data_text{1,5}{Current_Line,1}  = '1';
       end
       Redraw(0,0)
    end % end of upstream edit box callback 3

    function Editor_Tool_Close_Fcn(src,evnt)
        % function to do some tidying up at the end of the run, success
        % flag determines if a file ahs successfully been written out yet
        % or not 
        if success_flag == 1
            % if a file has been generated then we can state that the
            % process has compelted successfully and shut it down by
            % deleting the window, which allows the main script to proceed 
            disp('Data accepted successfully, runnign the simualtion')
            delete(Simulation_Config_Editor_GUI)
        else
            % else we prompt the user with a dialogue box asking them if
            % they want to continue editing and create a script, or if they
            % have changed their mind and wish to shutdown the simualtion
            % instead
            selection = questdlg('Data Entry Incomplete.Shutdown the Simulation Instead?','Legoline Close Confimation','Yes','No','Yes'); 
            if strcmp(selection,'Yes') == 1
                % if they want to stop then close the matlab instance
                quit
            else
                % else return to the main function to allow them to
                % continue editing 
                return
            end 
        end 
    end % end closedown function

    function popup_menu_Callback(source,eventdata) 
            % this callback is called whenever the drop down/pop up menu is
            % edited by the user to change the ditribution associated with
            % a line 
        
             % Determine the selected data set from the souce event(pop up
             % menu)'s value 
             val = get(source,'Value');
             % depending on which distribution has been selected from the
             % lsit write the appropriate code letter to the data_etxt file
             switch(val)
                   case 1
                      data_text{1,2}{Current_Line,1} = 'P';
                   case 2
                      data_text{1,2}{Current_Line,1}  = 'N';
                   case 3
                      data_text{1,2}{Current_Line,1}  = 'R';
                   case 4
                      data_text{1,2}{Current_Line,1}  = 'T';
             end 
             %Redraw the GUI to replace the old edit boxes with new ones
             %relfecting the paramters available to the new distribution.
             Redraw(0,0)
    end % end popup menu callback 

    function review_file_callback(src,evnt)
        % this call back is used by the review button to generate a user
        % friendly text file which contains a sumamry of all of the data
        % they have input such that it can be quickly reviewed. 
        
        fout=fopen([path2gui,'Review_File_Simulation.txt'],'wt');
        % open a text file and write a heading 
        fprintf(fout,'Feed Lines');
        % leave some space for readability 
        fprintf(fout,'\n');
        fprintf(fout,'\n');
        % loop to print all you need to know about feed lines
        for index_feedlines = 1:1:No_of_Feedlines
            % if the feed line is on then we print the information about it
            %s schedule 
            if On_Vector(index_feedlines) == 1;
                    switch data_text{1,2}{index_feedlines,1}
                        % switch based on the selected distribution to
                        % write the correct statement and use correct
                        % number of paramters
                        case 'P'
                            fprintf(fout,['Arrivals Periodic : period = ',data_text{1,3}{index_feedlines,1},' seconds\n']);
                        case 'N'
                            fprintf(fout,['Arrivals Normally Distributed: mean = ',data_text{1,3}{index_feedlines,1},' seconds, Standard deviation = ',data_text{1,4}{index_feedlines,1},' seconds\n']);
                        case 'R'
                            fprintf(fout,['Arrivals Rectangular Distributed: Minimum Inter-arrival Time = ',data_text{1,3}{index_feedlines,1},' seconds, Maximum Inter-arrival Time = ',data_text{1,4}{index_feedlines,1},' seconds\n']);
                        case 'T'
                            fprintf(fout,['Arrivals Rectangular Distributed: Minimum Inter-arrival Time = ',data_text{1,3}{index_feedlines,1},' seconds, Modal Inter-arrival time = ',data_text{1,4}{index_feedlines,1},' seconds, Maximum Inter-arrival Time = ',data_text{1,5}{index_feedlines,1},' seconds\n']);
                    end % end of arrivals type switch
            else % else if the line is not present as a feeder but is simulating a mianline buffer we state this 
                fprintf(fout,['Feed Line ',num2str(index_feedlines),'  is not present as a feed line but will act as a mainline buffer section\n']);
            end % end of if the line is present         
        end % close the for loop over all feed lines 
        % open the file for review. 
        edit Review_File_Simulation.txt
    end % end of write file function

    function popup_menu_Callback_feedline_number(source,eventdata)
        % this allows the user to select from a popup menu of the different
        % lines, it looks at which line has been selected from the oppup
        % menu 
         str = get(source,'String');
         val = get(source,'Value');
         % sets the current line variable to the right number
         Current_Line = val; 
         % and then redraws the GUI such that the correct distribution
         % popup and edit boxes are drawn out correctly. 
         Redraw(0,0)
    end  % end of feedline number callback 

    function create_file_callback(src,evnt)
        % this function writes the data to a file and closes the GUi when
        % the user is satisfied with their configuration. 
        
        % open a file to put the data in such that it can be retireved
        % later by the main script which does not access this workspace. 
        fout=fopen(Filepath,'wt');
        % some formats to give tabular data 
        lineformat5=('%s %s %s %s %s\n');
        lineformat2=('%s %s\n');
        % print the number of feedlines such that the file can be validated
        % as accurate
        fprintf(fout,lineformat2,'No_of_Feedlines',num2str(No_of_Feedlines));

        for index_feedlines=1:1:No_of_Feedlines
            if On_Vector(index_feedlines) == 1
                % if the feed line is on then we print the information about it
                % s schedule 
                fprintf(fout,lineformat5,data_text{1,1}{index_feedlines,1},data_text{1,2}{index_feedlines,1},data_text{1,3}{index_feedlines,1},data_text{1,4}{index_feedlines,1},data_text{1,5}{index_feedlines,1});
            else% else if the line is not present as a we set it periodic but with a period so high no pallet will be fed unless the user simualtes over a year
                fprintf(fout,lineformat5,data_text{1,1}{index_feedlines,1},data_text{1,2}{index_feedlines,1},'1000000000000','0','0');
            end
        end
        fclose(fout)
        % show a success flag to the shutdown function such that we know a
        % file has been successfully generated, esle it will warn the user
        % that it would be unwise to continue. 
        success_flag = 1;
        % call the close function to perform the startard window cleanup
        % operations
        Editor_Tool_Close_Fcn(0,0)
    end % end of write file callback

   function checkbox_callback (src,evnt)
       % call back for the if running checkbox to allow lines to be set as
       % spacing or buffering only 
                if (get(src,'Value') == get(src,'Max'))
                % Checkbox is checked-take appropriate action
                    On_Vector(Current_Line) = 1;
                else
                    On_Vector(Current_Line) = 0;
                end % end of if checked selection
                Redraw(0,0)
   end % end of checkbox callback function


%% The redrawing function         - this handles all of the graphics
function Redraw(src,evnt)
    % in order to keep the processing power down and keep clutter in the
    % rest of the code to a minimum this function can be called to redraw
    % the entire GUI such that any features which need enabling or
    % disabling, either by chang of distribution requiing different data
    % fields else, by disbaling all controls for an off line. 
    
    % if the GUi has already been drawn we delete any only text lables to
    % prevent hangovers or artefacts. 
    if exist('FeedLine_Panel','var') ~= 0
        menuhandles = findall(FeedLine_Panel,'type','uicontrol');
        delete(menuhandles)
    end 

    % create a panel for each of the line controls. 
    FeedLine_Panel = uipanel('Parent',Simulation_Config_Editor_GUI,'Title','Feed Line Setup','BackgroundColor',colour_matrix(2,:),'Position',[0,0.2,1,0.3],'handlevisibility','on');
    % create a panel for the reviw features to live in. 
    Review_Panel   = uipanel('Parent',Simulation_Config_Editor_GUI,'Title','Review','BackgroundColor',colour_matrix(2,:),'Position',[0,0.0,1,0.1]); 
    
    % Setup The Feed Panel 
    
    % a drop down menu that is always enabled which should have options for
    % the number of lines, such that the editing of a particular line can
    % be done. 
    % Create A Label For It 
    Feed_Text_Linenumber = uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.05,0.55,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Line');
    % Create A Dropdown Box Which defaults ofn redraw to whatever the
    % currently selected line is
    %option(9)
    Feed_linenumber_Popup = uicontrol(FeedLine_Panel,'Style','popupmenu','String',available_lines,'value',Current_Line,'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.55,0.15,0.4],'Callback',@popup_menu_Callback_feedline_number);
    
    % this creates a simple check box to determine if the line is to be a
    % fed line or simply a mianline buffer stage - if the box is checked
    % then the line feeds, else it simply induces a non linear time delay. 
    % it fills in an on vector which determine s which lines feed and which
    % lines run as buffers by a binary variable. 
    Feed_Running_Cb = uicontrol(FeedLine_Panel,'Style','checkbox','String','Run Line','Value',On_Vector(Current_Line),'backgroundcolor',colour_matrix(2,:),'units','normal','Position',[0.35,0.55 0.1 0.2],'callback',@checkbox_callback );
          
    % we now have two drawing cases, the first is if the line box is
    % checked, then we want to draw the distribution text boxes, with a
    % popup to select distribution, and the relevant edit boxes to enter
    % its parameters enabled. Else for conistency we  wish to draw all of
    % the features but disabled to prevent teh user adding data for a line
    % which is off. 
    
    if On_Vector(Current_Line) == 1
        % first if the unit is to run we want to draw the required
        % features:
        
        
        % create a label for a drop down menu allowing the selection of 
        % distribution types for the arrivals. 
            Feed_Text_Distro = uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Distribution');
            % at this point we read the existing distribution type from the
            % data in order to get the menu to default to the last known
            % item for this line, as these are text items, we convert them
            % to a numeric code such that we can set the menu to the
            % correct item from its list. 
            Dummyvar = data_text{1,2}{Current_Line,1};
            if strcmp(Dummyvar,'P') == 1
                current_distro = 1;
            elseif strcmp(Dummyvar,'N') == 1
                current_distro = 2; 
            elseif strcmp(Dummyvar,'R') == 1
                current_distro = 3; 
            elseif strcmp(Dummyvar,'T') == 1
                current_distro = 4; 
            end 
            
            % create the actual menu that the user selects from. 
            Feed_Distribution_Popup = uicontrol(FeedLine_Panel,'Style','popupmenu','String',{'Periodic','Normal','Rectangular','Triangular'},'value',current_distro,'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.05,0.15,0.4],'Callback',@popup_menu_Callback);
            
            % based on the value that is currently present in the menu we
            % need to configure the three edit boxes and their labels to
            % reflect the parameters which that distribution requires to
            % run. In each case all three boxes are drawn but any that are
            % not to be used are disabled to prevent editing in order tht
            % the windows appearance is consistent. 
            switch get(Feed_Distribution_Popup,'val')
                case 1
                        % in this case the user has selected a periodic
                        % distribution 
                        V1=data_text{1,3}{Current_Line,1};
                        % create the first data box as a perio time in
                        % seconds 
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Period (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);  
                       
                        % Draw the Other two data boxes as disabled
                        %option(16)
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 2
                    % in this case the user has selected a normal
                    % distribution 
                    
                    % setup the first edit box as one for the mean of the
                    % distribution and assciated label
                        V1=data_text{1,3}{Current_Line,1};
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Mean (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);
                        %option(16)
                        
                        % setup the second edit box and label as giving the
                        % standard deviation of the normal distribution
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Std Dev (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback);
                        
                        % Draw the Third Edit Box as Disbaled. 
                        %option(17)
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 3
                    % In this case the user has seelcted a rectangualr
                    % distribution and so we set up two buttons for the max
                    % and min interarrival times. 
                    
                        % setup a label and the first edit box to contain the
                        % minimum inter arrival time. 
                        V1=data_text{1,3}{Current_Line,1};
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Spacing (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);
                        
                        % setup a label and the second edit box to contain
                        % the maximum inter arrival time. 
                        %option(16)
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback);
                        
                        % Draw the Third Edit Box as Disbaled.
                        %option(17)
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 4
                    % In this case the user has selected a trinagular
                    % distribtuino for the inter arrival time which
                    % requires all three parameters 
                    
                        % Setup the first edit box and its associated label
                        % to get the minimum inter arrival time. 
                        V1=data_text{1,3}{Current_Line,1};
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Space(s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback);
                       
                        % Setup the second edit box to contain the modal
                        % inter arrival time and label it as such 
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Modal Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback);
                        
                        % setup the third edit box and its label to contain
                        % the maximum interarrival time permitted. 
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback);
            end 
          else % else if the line is off
        %  we want to draw the required features, but disabled. 
        
        % create a label for a drop down menu allowing the selection of 
        % distribution types for the arrivals. 
            Feed_Text_Distro = uicontrol(FeedLine_Panel,'style','tex','units','normal', 'Position',[0.05,0.05,0.1,0.4],'backgroundcolor',colour_matrix(2,:),'String','Feed Distribution');
            % at this point we read the existing distribution type from the
            % data in order to get the menu to default to the last known
            % item for this line, as these are text items, we convert them
            % to a numeric code such that we can set the menu to the
            % correct item from its list. 
            Dummyvar = data_text{1,2}{Current_Line,1};
            if strcmp(Dummyvar,'P') == 1
                current_distro = 1;
            elseif strcmp(Dummyvar,'N') == 1
                current_distro = 2; 
            elseif strcmp(Dummyvar,'R') == 1
                current_distro = 3; 
            elseif strcmp(Dummyvar,'T') == 1
                current_distro = 4; 
            end 
            
            % create the actual menu that the user selects from. 
            Feed_Distribution_Popup = uicontrol(FeedLine_Panel,'Style','popupmenu','String',{'Periodic','Normal','Rectangular','Triangular'},'value',current_distro,'BackgroundColor',colour_matrix(1,:),'units','normal', 'Position',[0.15,0.05,0.15,0.4],'Callback',@popup_menu_Callback,'enable','off');
            
            % based on the value that is currently present in the menu we
            % need to configure the three edit boxes and their labels to
            % reflect the parameters which that distribution requires to
            % run. In each case all three boxes are drawn but any that are
            % not to be used are disabled to prevent editing in order tht
            % the windows appearance is consistent. 
            switch get(Feed_Distribution_Popup,'val')
                case 1
                        % in this case the user has selected a periodic
                        % distribution 
                        V1=data_text{1,3}{Current_Line,1};
                        % create the first data box as a period time in
                        % seconds and disable
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Period (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');  
                       
                        % Draw the Other two data boxes as disabled
                        %option(16)
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        %option(17)
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 2
                    % in this case the user has selected a normal
                    % distribution 
                    
                    % setup the first edit box as one for the mean of the
                    % distribution and assciated label and disable
                        V1=data_text{1,3}{Current_Line,1};
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Mean (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        %option(16)
                        
                        % setup the second edit box and label as giving the
                        % standard deviation of the normal distribution and
                        % disable
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Std Dev (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        
                        % Draw the Third Edit Box as Disbaled. 
                        %option(17)
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 3
                    % In this case the user has seelcted a rectangualr
                    % distribution and so we set up two buttons for the max
                    % and min interarrival times. 
                    
                        % setup a label and the first edit box to contain the
                        % minimum inter arrival time. and disable
                        V1=data_text{1,3}{Current_Line,1};
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Spacing (s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                        
                        % setup a label and the second edit box to contain
                        % the maximum inter arrival time and disable 
                        %option(16)
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        
                        % Draw the Third Edit Box as Disbaled.
                        %option(17)
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
                case 4
                    % In this case the user has selected a trinagular
                    % distribtuino for the inter arrival time which
                    % requires all three parameters 
                    
                        % Setup the first edit box and its associated label
                        % to get the minimum inter arrival time and disable
                        V1=data_text{1,3}{Current_Line,1};
                        Feed_text_p1 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.35 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Min Space(s)');
                        Feed_p1 = uicontrol(FeedLine_Panel,'Style','edit','String',V1,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.45 0.05 0.1 0.4],'callback',@editbox_feedv1_callback,'enable','off');
                       
                        % Setup the second edit box to contain the modal
                        % inter arrival time and label it as such and
                        % disable
                        V2=data_text{1,4}{Current_Line,1};
                        Feed_text_p2 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.55 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Modal Spacing (s)');
                        Feed_p2 = uicontrol(FeedLine_Panel,'Style','edit','String',V2,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.65 0.05 0.1 0.4],'callback',@editbox_feedv2_callback,'enable','off');
                        
                        % setup the third edit box and its label to contain
                        % the maximum interarrival time permitted. and
                        % disable
                        V3=data_text{1,5}{Current_Line,1};
                        Feed_text_p3 = uicontrol(FeedLine_Panel,'style','tex','units','normal','position',[0.75 0.05 0.1 0.4],'backgroundcolor',colour_matrix(2,:),'String','Max Spacing (s)');
                        Feed_p3 = uicontrol(FeedLine_Panel,'Style','edit','String',V3,'units','normal','backgroundcolor',colour_matrix(1,:),'Position',[0.85 0.05 0.1 0.4],'callback',@editbox_feedv3_callback,'enable','off');
            end 
              
              

          end % end of if line running 
          
        % Setup the Review panel with two buttons to preview and commit the
        % changes 
        review_button   = uicontrol(Review_Panel ,'Style','pushbutton','String','Review Config','BackgroundColor',colour_matrix(1,:),'ForegroundColor','k','units','normal','Position',[0.05,0.05,0.4,0.9],'Callback',{@review_file_callback});
        print_button   = uicontrol(Review_Panel ,'Style','pushbutton','String','Commit Changes and Close','BackgroundColor',colour_matrix(1,:),'ForegroundColor','k','units','normal','Position',[0.55,0.05,0.4,0.9],'Callback',{@create_file_callback});
        
        menuhandles = findall(FeedLine_Panel);
        % make the menuhandles available
        set(menuhandles,'HandleVisibility','on');
end % end of redraw function
end % end of GUI function. 

