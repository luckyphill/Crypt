function [node_pairs,order]  = get_node_pairs(data)

% Takes in a vector of cell ID positions parents phases ages etc. and
% Returns the expected node pairs

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
ids = num2cell(0:(N-1));

cells = struct(f1,ids,f2,xs,f3,ys,f4,ages,f5,parents,f6,phases);

temp = struct2table(cells);
sortedtemp = sortrows(temp,'y');
cells_sorted = table2struct(sortedtemp);

order = [cells(:).ID];

pairs = [];
for i = 1:N-1
    pairs = [pairs ; [cells_sorted(i).ID,cells_sorted(i+1).ID]];
    pairs(i,:) = sort(pairs(i,:),2);
end

node_pairs = sortrows(pairs);

    


end