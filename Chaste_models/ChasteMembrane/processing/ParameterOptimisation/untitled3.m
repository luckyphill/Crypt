% clear all;
close all;
input_flags= {'n','np','ees','ms','cct','vf','run'};
input_values = [26,12,50,200,15,0.7,1];
fixed_parameters = ' -t 2 -sm 1';

% file = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';
% nodes = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/node_pairs.txt';

file = '/tmp/phillip/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';
nodes = '/tmp/phillip/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/node_pairs.txt';

% run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

% data1 = csvread(file);
% nodes1 = csvread(nodes);
% 
% run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);
% 
% data2 = csvread(file);
% nodes2 = csvread(nodes);

time = data1(:,1);

check = data1 == data2;
check1 = prod(check,2);
j = find(check1,1,'last');

check2 = sum(check,2);
figure
plot(check2);
title('Data identical entries count per time step');

node_check = nodes1 == nodes2;
node_check2 = sum(node_check,2);
figure
plot(node_check2);
title('Unsorted node list identical entries count per time step');

s_nodes1 = sort(nodes1(:,2:end));
s_nodes2 = sort(nodes2(:,2:end));

s_node_check = s_nodes1 == s_nodes2;
s_node_check1 = prod(s_node_check,2);
s_node_check2 = sum(s_node_check,2);
figure
plot(s_node_check2);
title('Sorted node list identical entries count per time step');


diff = abs(data1 - data2);
error1 = sum(diff,2);
figure
semilogy(error1)
title('Error magnitude per time step');

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


