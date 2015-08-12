diary([path2eventlog,'Splitter_unit','1','.log'])
Splitter_id = 1;
disp('Running Splitter 1')
time=clock;
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1))];
disp(date)
time=[num2str(time(4)),' : ',num2str(time(5)),' : ',num2str(time(6))];
disp(time)
clear time
clear date
Setup_Splitter;