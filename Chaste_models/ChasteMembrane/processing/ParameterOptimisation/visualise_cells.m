function visualise_cells(data)

% Takes in a vector of cell ID positions parents phases ages etc. and
% Plots it in a way that can be inspected

% Draws lines between twin nodes

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


cells = struct(f1,ids,f2,xs,f3,ys,f4,ages,f5,parents,f6,phases);
cells(1).phase = 0;
scatter([cells(:).x], [cells(:).y],50,[cells(:).phase])

wphase = [];
for i=1:length(cells)
    wphase = [wphase, i];
    
end



end