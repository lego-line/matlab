diary([path2eventlog,'Feed_','2','.log'])
feed_id = 2;
disp('Running Feeder 2')
time=clock;
date = [num2str(time(3)),' / ',num2str(time(2)),' / ',num2str(time(1))];
disp(date)
time=[num2str(time(4)),' : ',num2str(time(5)),' : ',num2str(time(6))];
disp(time)
clear time
clear date
Feed_setup