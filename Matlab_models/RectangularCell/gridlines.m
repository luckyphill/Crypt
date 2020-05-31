function gridlines(dx, ax)
% Second arg should be gca
ax = gca;
grid;
ax.XTick = -30:dx:30;
ax.YTick = -10:dx:10;

end

