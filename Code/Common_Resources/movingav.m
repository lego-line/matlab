function [y]=movingav(x,lag)
% [y]=movingav(x,lag) custom written moving average function in order to
% smooth the data from the light gate on the splitter unit. Y is an output
% vector and X is an input vector to be smoothed. The lag input gives the
% number of terms to moving av over. The initial terms will all be
% identical to the first until the leg time is reached. 
if lag==1
    % is lag = 1 there is no moving average 
    y=x;
    return
end

if size(x,1)== 1
  % if X is the wrong way around, transpose it 
    x=x';
end

        
    f=zeros(lag,1)+1/lag;
    % take the size of the input vector 
    sizein=size(x,1);
    isodd=bitand(lag,1);
    lag2=floor(lag/2);

    % perform the moving average operation as appropriate to the lenbgth of
    % the vector and lag 
    if (size(x,2)==1)
        y=filter(f,1,x);
        y=y([zeros(1,lag2-1+isodd)+lag,lag:sizein,zeros(1,lag2)+sizein]);
    else
        y=filter2(f,x);
        y(1:(lag2-~isodd),:)=y(lag2+isodd+zeros(lag2-~isodd,1),:);
        y((sizein-lag2+1):end,:)=y(sizein-lag2+zeros(lag2,1),:);
    end

return
