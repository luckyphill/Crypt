cells = readmatrix('/Users/phillip/Research/Crypt/Data/Matlab/SimulationOutput/LayerOnStroma/SpatialState/cells.csv');
cellData = cells(:,2:end);
[m,~] = size(cellData);
cells = {};
for i = 1:m
    a = cellData(i,:);
    j = 1;
    counter = 1;
    while j <= length(a) && ~isnan(a(j))
        jump = a(j);
        cells{i,counter} = a(j+1:j+jump+1);
        j = j + jump + 2;
        counter = counter + 1;
    end

end

c = cells{1,:}