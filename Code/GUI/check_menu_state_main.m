% check_menu_state_main - script to check the existence of the various
% menu files and populate a vector which contols which menu items in the
% log menus are or aren't made available to the user, those with a 1
% element are displayed as clickable, otherwise they are greyed out and
% unusable. 

% this script file checks the existence of each of the key log files and
% places a binary response in the appropriate element of the vector 
     if exist(path2feedlog1) ~=0
        current_menustate(1) = 1; 
     else
        current_menustate(1) = 0;     
     end
     if exist(path2feedlog2) ~=0
        current_menustate(2) = 1;     
     else
        current_menustate(2) = 0;
     end
     if exist(path2feedlog3) ~=0
        current_menustate(3) = 1;     
     else
        current_menustate(3) = 0;
     end
     if exist(path2feedlog4) ~=0
        current_menustate(4) = 1;    
     else
        current_menustate(4) = 0;    
     end
     if exist(path2feedlog5) ~=0
       current_menustate(5) = 1; 
     else
       current_menustate(5) = 0;
     end
     if exist(path2splitter1log) ~=0
        current_menustate(6) = 1;
     else
        current_menustate(6) = 0;
     end
     if exist(path2splitter2log) ~=0
         current_menustate(7) = 1;
     else
         current_menustate(7) = 0;
     end
     if exist(path2feedlogupstream) ~=0
         current_menustate(8) = 1;
     else
         current_menustate(8) = 0;
     end

    if exist(path2feedrtexptoutputs) ~= 0
         current_menustate(9) = 1;
    else 
         current_menustate(9) = 0;
    end   
    if exist(path2palletexptoutputs) ~= 0
         current_menustate(10) = 1;
    else
         current_menustate(10) = 0;
    end
    if exist(fpath2feed1log) ~=0
        current_menustate(11) = 1;
    else
        current_menustate(11) = 0;
    end
    if exist(fpath2feed2log) ~=0
       current_menustate(12) = 1;
    else
       current_menustate(12) = 0;
    end
    if exist(fpath2feed3log) ~=0
        current_menustate(13) = 1;
    else
        current_menustate(13) = 0;
    end
    if exist(fpath2feed4log) ~=0
        current_menustate(14) = 1;
    else
        current_menustate(14) = 0;
    end
    if exist(fpath2feed5log) ~=0
        current_menustate(15) = 1;
    else
        current_menustate(15) = 0;
    end
    if exist(fpath2transfer1log) ~=0
       current_menustate(16) = 1;
    else
        current_menustate(16) = 0;    
    end
    if exist(fpath2transfer2log) ~=0
        current_menustate(17) = 1;
    else
        current_menustate(17) = 0;
    end
    if exist(fpath2transfer3log) ~=0
        current_menustate(18) = 1;
    else
        current_menustate(18) = 0;
    end
    if exist(fpath2transfer4log) ~=0
        current_menustate(19) = 1;
    else
       current_menustate(19) = 0;
    end
    if exist(fpath2transfer5log) ~=0
        current_menustate(20) = 1;
    else
        current_menustate(20) = 0;
    end
    if exist(fpath2main1log) ~=0
        current_menustate(21) = 1;
    else 
        current_menustate(21) = 0;
    end
    if exist(fpath2main2log) ~=0
        current_menustate(22) = 1;
    else 
        current_menustate(22) = 0;
    end
    if exist(fpath2main3log) ~=0
        current_menustate(23) = 1;
    else 
        current_menustate(23) = 0;
    end
    if exist(fpath2main4log) ~=0
        current_menustate(24) = 1;
    else 
        current_menustate(24) = 0;
    end
    if exist(fpath2main5log) ~=0
        current_menustate(25) = 1;
    else 
        current_menustate(25) = 0; 
    end
    if exist(fpath2splitter1eventlog) ~=0
        current_menustate(26) = 1;
    else 
        current_menustate(26) = 0;
    end
    if exist(fpath2splitter2eventlog) ~=0
         current_menustate(27) = 1;
    else 
         current_menustate(27) = 0;
    end
    if exist(fpath2upstreamlog) ~=0
        current_menustate(28) = 1;
    else
        current_menustate(28) = 0;
    end
    % populate the exisitng menu states with zeros if it doesn't already
    % exist cuh that when they are compared again then the compariosn will
    % wokr as the vectors are compatible. 
    if isempty(existing_menustate) == 1
        existing_menustate = zeros(size(current_menustate));
    end
