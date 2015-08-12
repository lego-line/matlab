diary([path2eventlog,'Main_','1','.log'])
Main_id = 1;
disp('Running Mainline 1')
time=clock;
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1))];
disp(date)
time=[num2str(time(4)),' : ',num2str(time(5)),' : ',num2str(time(6))];
disp(time)
clear time
clear date
Mainline_Setup