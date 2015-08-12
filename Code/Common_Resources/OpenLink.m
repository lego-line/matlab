% OpenLink.m script file with the necessary code to open the NXT Link by
% whatever means 
disp('Running Open Link Script to Open a Connection')
COM_CloseNXT('all') % close any open NXTS for safety 

if strcmp(Connection_Type,'USB') ==  1
    % in this case we want to open the link by USB cable. 
    %we check which type of unit we have by looking at
    % the id variable name to determnine what type and call the NXT handle
    % the correct name for that type of unit. 
    if exist('Transfer_id','var') == 1
        adder = COM_OpenNXTEx('USB', Code{1});
        COM_SetDefaultNXT(adder)
    elseif exist('feed_id','var') == 1
        load = COM_OpenNXTEx('USB', Code{1});
        COM_SetDefaultNXT(load)
    elseif exist('Main_id','var') == 1   
        Main = COM_OpenNXTEx('USB', Code{1});
        COM_SetDefaultNXT(Main)
    elseif exist('Splitter_id','var') == 1
        splitter = COM_OpenNXTEx('USB', Code{1});
        COM_SetDefaultNXT(splitter)
    end 
elseif strcmp(Connection_Type,'Bluetooth') ==  1
    % in this case we want to use the bluetooth capability to form the
    % link. and so again we check which type of unit we have by looking at
    % the id variable name to determnine what type and call the NXT handle
    % the correct name for that type of unit. 
else
    % else if the connection type is neither USB nor Bluetooth 
    disp('The Connection Type is Invalid')
    quit
end % end of conenction type if clause 