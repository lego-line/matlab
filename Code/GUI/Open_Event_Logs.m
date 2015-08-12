% This script can be called by the user to open all of the possible event
% logs it has two cases as it opens the logs in a local editor such that
% the user can edit or save them. 
if isunix == 1
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
elseif ispc == 1
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
else
    disp('Operating System Not Supported')
end