file = '/Users/phillipbrown/Chaste/deathAge.txt';
data = csvread(file);

data1 = sort(data);

for i = 1:length(data)
    if data1(i) >= 10
        break;
    end
end

data2 = data1(1:2:i);
data3 = data1(i+1:end);
data4 = [data2;data3];

figure
histogram(data4, 'BinEdges',[0:16,20]);
    

