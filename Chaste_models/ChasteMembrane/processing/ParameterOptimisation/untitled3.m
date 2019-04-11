% clear all;
close all;
input_flags= {'n','np','ees','ms','cct','vf','run'};
input_values = [26,12,50,200,15,0.7,1];
fixed_parameters = ' -t 2 -sm 1';

file = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';
nodes = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/node_pairs.txt';

% file = '/tmp/phillip/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';
% nodes = '/tmp/phillip/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/node_pairs.txt';

% run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);
% 
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
last_identical_state = find(check1,1,'last');

check2 = sum(check,2);
figure
plot(check2);
title('Data identical entries count per time step');

node_check = nodes1 == nodes2;
node_check1 = prod(node_check,2);
last_identical_list = find(node_check1,1,'last');
node_check2 = sum(node_check,2);
figure
plot(node_check2);
title('Unsorted node list identical entries count per time step');

s_nodes1 = sort(nodes1(:,2:end),2);
s_nodes2 = sort(nodes2(:,2:end),2);

s_node_check = s_nodes1 == s_nodes2;
s_node_check1 = prod(s_node_check,2);
last_identical_s_list = find(s_node_check1,1,'last');
s_node_check2 = sum(s_node_check,2);
figure
plot(s_node_check2);
title('Sorted node list identical entries count per time step');


diff = abs(data1 - data2);
error1 = sum(diff,2);
figure
semilogy(error1)
title('Error magnitude per time step');

for i=1:length(error1)
    if error1(i) >= 10
        first_error_order_1e2 = i;
        break;
    end
end

first = last_identical_state;
last = first_error_order_1e2;

% For each state and each node list between first and last index clean the
% data and save it to file

for i = first:last
    datastepA = data1(i,1:find(data1(i,:),1,'last'));
    step_time = datastepA(1);
    datastepA(1) = [];
    
    ids = datastepA(1:8:end);
    xpos = datastepA(2:8:end);
    ypos = datastepA(3:8:end);
    ages = datastepA(6:8:end);
    parents = datastepA(7:8:end);
    phases = datastepA(8:8:end);
    
    for j = length(parents):-1:1
        if ages(j) < 10
            parents(ages == ages(j)) = j-1;
        else
            parents(j) = j-1;
        end
    end
    
    nodesA_file = sprintf('testing/nodesA_%d.txt', i);
    nodesA = reshape(nodes1(i,2:end),2,[])';
    nodesA = nodesA(1:find(nodesA(:,1),1,'last'),:);
    
    [a,b] = size(nodesA);
    for j = 1:a*b
        nID = nodesA(j);
        index = find(ids == nID);
        nodesA(j) = index - 1;
    end
        
    
    csvwrite(nodesA_file, nodesA);

    % Change parents to mathc the new cell IDs
    datastepA_file = sprintf('testing/stateA_%d.txt', i);
    stateA = [ids; xpos; ypos; round(ages,3); parents; phases];
    dlmwrite(datastepA_file, stateA, 'delimiter', ',', 'precision', 15);
    
    datastepB = data1(i,1:find(data2(i,:),1,'last'));
    step_time = datastepB(1);
    datastepB(1) = [];
    
    ids = datastepB(1:8:end);
    xpos = datastepB(2:8:end);
    ypos = datastepB(3:8:end);
    ages = datastepB(6:8:end);
    parents = datastepB(7:8:end);
    phases = datastepB(8:8:end);
    
    for j = length(parents):-1:1
        if ages(j) < 10
            parents(ages == ages(j)) = j-1;
        else
            parents(j) = j-1;
        end
    end

    datastepB_file = sprintf('testing/stateB_%d.txt', i);
    stateB = [ids; xpos; ypos; round(ages,3); parents; phases];
    dlmwrite(datastepB_file, stateB, 'delimiter', ',', 'precision', 15);
    
    nodesB_file = sprintf('testing/nodesB_%d.txt', i);
    nodesB = reshape(nodes2(i,2:end),2,[])';
    nodesB = nodesB(1:find(nodesB(:,1),1,'last'),:);
    
    [a,b] = size(nodesB);
    for j = 1:a*b
        nID = nodesB(j);
        index = find(ids == nID);
        nodesB(j) = index - 1;
    end
    
    
    csvwrite(nodesB_file, nodesB);
end


