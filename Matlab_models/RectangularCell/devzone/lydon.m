function lydon(x,y)
hFig = figure('Visible','off');
hAx = axes;
tt=1;
NDataPoints=100;
gg=NDataPoints;
nTraces=fix(length(y)/NDataPoints);  % no full traces in dataset
ss1=1/(nTraces-1);  % scale to move a trace at a time
hL=plot(x(tt:gg),y(tt:gg),'k');
uicontrol('Style', 'slider',...
        'Min',1, ...
        'Max',nTraces, ...
        'Value',1,...
        'SliderStep',[ss1 ss1], ...
        'Position', [400 20 120 20],...
        'Callback', @src);
hFig.Visible='on'
function src(source,event)
  val = get(source, 'Value');
  i1=1+(val-1)*NDataPoints; 
  i2=val*NDataPoints;
  set(hL,'XData',x(i1:i2),'YData',y(i1:i2))
end
end