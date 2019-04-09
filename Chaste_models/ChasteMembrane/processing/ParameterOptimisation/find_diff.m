file1 = '/Users/phillip/Chaste/details1.txt';
file3 = '/Users/phillip/Chaste/details3.txt';

data1 = csvread(file1);
data3 = csvread(file3);

m = min(length(data1),length(data3));

data1 = data1(1:m,:);
data3 = data3(1:m,:);


n1 = length(data1(1,:));
n3 = length(data3(1,:));
time = data1(:,1);

data1 = data1(:,2:n1);
data3 = data3(:,2:n3);

dataID1 = data1(:,1:5:(n1-1));
dataY1 = data1(:,3:5:(n1-1));
dataX1 = data1(:,2:5:(n1-1));

dataID3 = data3(:,1:5:(n3-1));
dataY3 = data3(:,3:5:(n3-1));
dataX3 = data3(:,2:5:(n3-1));


for i=1:m
	if(  prod(data1(i,:) == data3(i,:))==0  )
		time(i)
		i
		break;
	end
end
