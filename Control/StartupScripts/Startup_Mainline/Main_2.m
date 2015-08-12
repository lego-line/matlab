diary([path2eventlog,'Main_','2','.log'])
Main_id = 2;
disp('Running Mainline 2')
time=clock;
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1))];
disp(date)
time=[num2str(time(4)),' : ',num2str(time(5)),' : ',num2str(time(6))];
disp(time)
clear time
clear date
Mainline_Setup