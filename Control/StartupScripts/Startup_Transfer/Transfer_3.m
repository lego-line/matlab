diary([path2eventlog,'Transfer_','3','.log'])
Transfer_id = 3;
disp('Running Transfer 3')
time=clock;
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1))];
disp(date)
time=[num2str(time(4)),' : ',num2str(time(5)),' : ',num2str(time(6))];
disp(time)
clear time
clear date
Transfer_Setup