clear all;
close all;
input_flags= {'n','np','ees','ms','cct','vf','run'};
input_values = [26,12,50,200,15,0.7,1];
fixed_parameters = ' -bt 100 -t 2 -sm 1';

file = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';
% file = '/tmp/phillip/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

data1 = csvread(file);

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

data2 = csvread(file);

time = data1(:,1);

m = min(length(data1),length(data2));

bigerrors = [];
for i=1:m
	if(  sum(data1(i,:) - data2(i,:)) < 1e-15  )
		time(i);
		bigerrors = [bigerrors,i];
	end
end

check = data1 == data2;
check1 = prod(check,2);
j = find(check1,1,'last');

check2 = sum(check,2);
figure
plot(check2);

diff = abs(data1 - data2);
error1 = sum(diff,2);
figure
semilogy(error1)

datalast = data1(find(error1,1,'last'),:)';
datalast(5:8:end) =[];
datalast(5:7:end) =[];
datalast(1) = [];

ids = datalast(1:6:end);
xpos = datalast(2:6:end);
ypos = datalast(3:6:end);
ages = datalast(4:6:end);
parents = datalast(5:6:end);
phases = datalast(6:6:end);


