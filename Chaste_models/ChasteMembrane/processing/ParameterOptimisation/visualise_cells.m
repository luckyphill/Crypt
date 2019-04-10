function visualise_cells(data, plot_title)

% Takes in a vector of cell ID positions parents phases ages etc. and
% Plots it in a way that can be inspected

% Draws lines between twin nodes
data = data(1:find(data,1,'last'));
f1 = 'ID';
f2 = 'x';
f3 = 'y';
f4 = 'age';
f5 = 'parent';
f6 = 'phase';

n = length(data);
ids = num2cell(data(1:8:n));
xs = num2cell(data(2:8:n));
ys = num2cell(data(3:8:n));
ages = num2cell(data(6:8:n));
parents = num2cell(data(7:8:n));
phases = num2cell(data(8:8:n));
N = length(ids);

cells = struct(f1,ids,f2,xs,f3,ys,f4,ages,f5,parents,f6,phases);
cells(1).phase = 0;
cols = {[0 0.4470 0.7410], [0.9290 0.6940 0.1250], [0.4660 0.6740 0.1880]};
colours = {cols{[cells(:).phase]+1}};
figure
for i=1:N
    viscircles([cells(i).x, cells(i).y], 0.5, 'Color',colours{i});
end
hold on
scatter([cells(:).x], [cells(:).y],50)
title(plot_title);
xlim([-16,16])
ylim([-1,31])

wphase = [];
for i=1:length(cells)
    if cells(i).phase == 2
        wphase = [wphase, i];
    end
end

i=1;
for i = 1:length(wphase)
    I = wphase(i);
    for j = 1:length(wphase)
        J = wphase(j);
        if I~=J && cells(I).parent == cells(J).parent
           % draw a line between these two points
           % Remove them from the vector
           line([cells(I).x, cells(J).x],[cells(I).y, cells(J).y],'Color','black');
           break;
        end
    end
end
    


end