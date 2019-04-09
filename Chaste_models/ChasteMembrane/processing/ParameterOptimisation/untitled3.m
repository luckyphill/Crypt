clear all;
close all;
input_flags= {'n','np','ees','ms','cct','vf','run'};
input_values = [26,12,50,200,15,0.7,1];
fixed_parameters = ' -t 2 -sm 1';

file = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

data1 = csvread(file);

run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

data2 = csvread(file);

time = data1(:,1);

m = min(length(data1),length(data2));

for i=1:m
	if(  prod(data1(i,:) == data2(i,:))==0  )
		time(i);
		i
		break;
	end
end

check = data1 == data2;
check1 = prod(check,2);
j = find(check1,1,'last')

check2 = sum(check,2);
plot(check2);
