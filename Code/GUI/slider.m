%read the value of the slider
slidervalue=get(hpop,'Value');

%change the position of hpanel, all children of hpanel are moved as well
%'+1' because of change of slider start position

set(hpanel,'Position',[pos(1) pos(2)-slidervalue+1 pos(3) pos(4)]);