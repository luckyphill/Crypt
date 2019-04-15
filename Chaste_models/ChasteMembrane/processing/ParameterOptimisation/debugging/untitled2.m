file1 = '/Users/phillip/Chaste/forceNodes1.txt';
file2 = '/Users/phillip/Chaste/forceNodes3.txt';

data1 = csvread(file1);
data2 = csvread(file2);

% Break into groups by timestamp
% Within each entry, order by lowest node index
% Within each group, order by first index then second index
% Compare ordered lists

n = min(length(data1),length(data2));
data1 = data1(1:n,:);
data2 = data2(1:n,:);
% Puts the indices in ascending order
starti1 = [1];
endi1 = [];
starti2 = [1];
endi2 = [];
for i=1:n
    data1(i,2:3) = sort(data1(i,2:3));
    data2(i,2:3) = sort(data2(i,2:3));
    
    data1(i,4:5) = sort(data1(i,4:5));
    data2(i,4:5) = sort(data2(i,4:5));
    
    if i < n
        if data1(i,1) ~= data1(i+1,1)
            starti1 = [starti1, i+1];
            endi1 = [endi1, i];
        end
    end
    if i < n
        if data2(i,1) ~= data2(i+1,1)
            starti2 = [starti2, i+1];
            endi2 = [endi2, i];
        end
    end
end
endi1 = [endi1, n];
endi2 = [endi2, n];

% For each group of the same time, sortrows

for i = 1:length(starti1)
    data1(starti1(i):endi1(i),:) = sortrows(data1(starti1(i):endi1(i),:));
end

for i = 1:length(starti2)
    data2(starti2(i):endi2(i),:) = sortrows(data2(starti2(i):endi2(i),:));
end
    
diff = data1 == data2;

for i=1:n
    if sum(diff(i,1:7)) <7
        i
        break;
    end
end

data1(i,:)
data2(i,:)
