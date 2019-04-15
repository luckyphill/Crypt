close all;
clear all;

%--------------------------------------------------------------------------
% The input values for the test simulation
input_flags= {'n','np','ees','ms','cct','vf','run'};
input_values = [26,12,50,200,15,0.7,1];
fixed_parameters = ' -bt 100 -t 2 -sm 1';

%--------------------------------------------------------------------------
% Output location for the simulation
% file = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';
% nodes = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/node_pairs.txt';

file = '/tmp/phillip/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/cell_force.txt';
nodes = '/tmp/phillip/testoutput/TestCryptColumn/n_26_np_12_EES_50_MS_200_CCT_15_VF_0.7_run_1/results_from_time_0/node_pairs.txt';

% Comment out the two simulations if you don't want to run them again. Only
% works if ALL the data files are in memory
%--------------------------------------------------------------------------
% Run the first simulation and load the data
run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

data1 = csvread(file);
nodes1 = csvread(nodes);

%--------------------------------------------------------------------------
% Run the seconf simulation and load the data
run_simulation('TestCryptColumn', @MouseColonDesc, input_flags, input_values, fixed_parameters, true);

data2 = csvread(file);
nodes2 = csvread(nodes);

%--------------------------------------------------------------------------
% Find where the result simulation states are identical
time = data1(:,1);

check = data1 == data2;
check1 = prod(check,2);
last_identical_state = find(check1,1,'last');

check2 = sum(check,2);
figure
plot(check2);
title('Data identical entries count per time step');

%--------------------------------------------------------------------------
% Find where the rGetNodePairs list are identical
node_check = nodes1 == nodes2;
node_check1 = prod(node_check,2);
last_identical_list = find(node_check1,1,'last');
node_check2 = sum(node_check,2);
figure
plot(node_check2);
title('Unsorted node list identical entries count per time step');

%--------------------------------------------------------------------------
% Find where the rGetNodePairs list are identical after sorting, to account
% for the Chaste pairing algorithm putting things in a random order
s_nodes1 = sort(nodes1(:,2:end),2);
s_nodes2 = sort(nodes2(:,2:end),2);

s_node_check = s_nodes1 == s_nodes2;
s_node_check1 = prod(s_node_check,2);
last_identical_s_list = find(s_node_check1,1,'last');
s_node_check2 = sum(s_node_check,2);
figure
plot(s_node_check2);
title('Sorted node list identical entries count per time step');

%--------------------------------------------------------------------------
% Find the broad difference in each simulation state
diff = (data1 - data2);
diff = abs(diff);
error1 = nansum(diff,2);
figure
semilogy(error1)
title('Error magnitude per time step');
error2 = nansum(diff./data1,2);
figure
semilogy(error2)
title('Total relative error per time step');

%--------------------------------------------------------------------------
% Find the first point where the error jumps above 1e2
for i=1:length(error1)
    if error1(i) >= 10
        first_error_order_1e2 = i;
        break;
    end
end

%--------------------------------------------------------------------------
% We now have a range of time steps where the simulations go from identical
% to order 1e2 error
first = last_identical_state;
if isempty(first)
    first = 13000;
end
last = max(first_error_order_1e2, find(~s_node_check1,1,'first'));
if isempty(last)
    last = 14000;
end

%--------------------------------------------------------------------------
% Grab the error now for specific state variables
id_error = diff(:,1:8:end);
x_error = diff(:,3:8:end);
y_error = diff(:,4:8:end);
fx_error = diff(:,5:8:end);
fy_error = diff(:,6:8:end);
figure
plot(sum(id_error,2));
title('IDs different between output files')
figure
semilogy(sum(y_error,2));
title('Actual total error in y');
semilogy(nansum(y_error./data1(:,4:8:end),2));
title('Relative total error in y');
figure
semilogy(sum(fy_error,2));
title('Actual total error in fy');



%--------------------------------------------------------------------------
% For each state and each node list between first and last index clean the
% data and save it to file

for i = first:last
    %----------------------------------------------------------------------
    % Extract the data into separate fields
    datastepA = data1(i,1:find(data1(i,:),1,'last'));
    step_time = datastepA(1);
    datastepA(1) = [];
    
    ids = datastepA(1:8:end);
    xpos = datastepA(2:8:end);
    ypos = datastepA(3:8:end);
    ages = datastepA(6:8:end);
    parents = datastepA(7:8:end);
    phases = datastepA(8:8:end);
    
    %----------------------------------------------------------------------
    % Rename the parents to match the new cell IDs that will come from the
    % simulation to come
    for j = length(parents):-1:1
        if ages(j) < 10
            parents(ages == ages(j)) = j-1;
        else
            parents(j) = j-1;
        end
    end
    
    %----------------------------------------------------------------------
    % Restructure the nodes list
    nodesA_file = sprintf('testing/nodesA_%d.txt', i);
    nodesA = reshape(nodes1(i,2:end),2,[])';
    nodesA = nodesA(1:find(nodesA(:,1),1,'last'),:);
    
    %----------------------------------------------------------------------
    % Rename the node pairs by the new ID
    [a,b] = size(nodesA);
    for j = 1:a*b
        nID = nodesA(j);
        index = find(ids == nID);
        nodesA(j) = index - 1;
    end
    
    all_nodesA{i} = nodesA;
    %----------------------------------------------------------------------
    % Write the nodes file
    csvwrite(nodesA_file, nodesA);

    %----------------------------------------------------------------------
    % Write the state to file. The ages are rounded to 3 decimal places.
    % This sometimes rounds to something other than a multiple of 0.002,
    % but this only occurs for ages > 20 or something. These cells are in
    % the differentiated phase, so it doesn't matter
    datastepA_file = sprintf('testing/stateA_%d.txt', i);
    stateA = [ids; xpos; ypos; round(ages,3); parents; phases];
    dlmwrite(datastepA_file, stateA, 'delimiter', ',', 'precision', 15);
    
    
    %----------------------------------------------------------------------
    % Repeate everything for the other simulation
    %----------------------------------------------------------------------
    % Extract the data into separate fields
    datastepB = data2(i,1:find(data2(i,:),1,'last'));
    step_time = datastepB(1);
    datastepB(1) = [];
    
    ids = datastepB(1:8:end);
    xpos = datastepB(2:8:end);
    ypos = datastepB(3:8:end);
    ages = datastepB(6:8:end);
    parents = datastepB(7:8:end);
    phases = datastepB(8:8:end);
    
    %----------------------------------------------------------------------
    % Rename the parents to match the new cell IDs that will come from the
    % simulation to come
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
    
    %----------------------------------------------------------------------
    % Restructure the nodes list
    nodesB_file = sprintf('testing/nodesB_%d.txt', i);
    nodesB = reshape(nodes2(i,2:end),2,[])';
    nodesB = nodesB(1:find(nodesB(:,1),1,'last'),:);
    
    %----------------------------------------------------------------------
    % Rename the node pairs by the new ID
    [a,b] = size(nodesB);
    for j = 1:a*b
        nID = nodesB(j);
        index = find(ids == nID);
        nodesB(j) = index - 1;
    end
    all_nodesB{i} = nodesB;
    %----------------------------------------------------------------------
    % Write the nodes file
    csvwrite(nodesB_file, nodesB);
    
    %----------------------------------------------------------------------
    % Write the state to file. The ages are rounded to 3 decimal places.
    % This sometimes rounds to something other than a multiple of 0.002,
    % but this only occurs for ages > 20 or something. These cells are in
    % the differentiated phase, so it doesn't matter
    datastepB_file = sprintf('testing/stateB_%d.txt', i);
    stateA = [ids; xpos; ypos; round(ages,3); parents; phases];
    dlmwrite(datastepB_file, stateB, 'delimiter', ',', 'precision', 15);
end



%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
test_index = first + 565;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Get the node pairs that SHOULD be selected, given the state

fprintf('Checking step %d\n',test_index);
[pairsA, orderA] = get_node_pairs(data1(test_index,2:end));
[pairsB, orderB] = get_node_pairs(data2(test_index,2:end));
    
%--------------------------------------------------------------------------
% Run TestForces_CM for the given state and Chaste candidate pair list
command = '/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestForces_CM';
argsA = sprintf(' -A -step %d', test_index);
argsB = sprintf(' -B -step %d', test_index);

[statusA,cmdoutA] = system([command, argsA]);
[statusB,cmdoutB] = system([command, argsB]);

%--------------------------------------------------------------------------
% Format the command line output into an array
temp1 = strsplit(cmdoutA, 'START');
temp2 = strsplit(temp1{2}, 'Passed');
temp3 = strsplit(temp2{1}, '\n');

for i = 2:(length(temp3)-1)
    calculated_pairsA(i-1,:) = str2num(temp3{i});
end

temp1 = strsplit(cmdoutB, 'START');
temp2 = strsplit(temp1{2}, 'Passed');
temp3 = strsplit(temp2{1}, '\n');

for i = 2:(length(temp3)-1)
    calculated_pairsB(i-1,:) = str2num(temp3{i});
end

%--------------------------------------------------------------------------
% Find pairs that are unaccounted for
extra_pairsA = calculated_pairsA;
extra_pairsB = calculated_pairsB;


for i = 1:length(pairsA)
    for j = 1:length(extra_pairsA)
        if pairsA(i,:) == extra_pairsA(j,:)
            extra_pairsA(j,:) = [];
            break;
        end
    end
end

for i = 1:length(pairsB)
    for j = 1:length(extra_pairsB)
        if pairsB(i,:) == extra_pairsB(j,:)
            extra_pairsB(j,:) = [];
            break;
        end
    end
end
            

fprintf('Branch A has %d pairs that should have been excluded\n', length(extra_pairsA));
fprintf('Branch B has %d pairs that should have been excluded\n', length(extra_pairsB));

error1(test_index);
[max_error, index] = max(diff(test_index,:));

%--------------------------------------------------------------------------
% Look at the starting lists of nodes in each case
test_nodesA = all_nodesA{test_index};
test_nodesB = all_nodesB{test_index};

for i=1:length(test_nodesA)
    test_nodesA(i,:) = sort(test_nodesA(i,:),2);
end

for i=1:length(test_nodesB)
    test_nodesB(i,:) = sort(test_nodesB(i,:),2);
end

s_test_nodesB = sortrows(test_nodesB);
s_test_nodesA = sortrows(test_nodesA);

what = sortrows(test_nodesA)== sortrows(test_nodesB);

%--------------------------------------------------------------------------
% Look at the calculated node pairs between runs
sum(sum(calculated_pairsA == calculated_pairsB));

%--------------------------------------------------------------------------
% Look at the order of the cells to spot when the pass through occurs
% It seems pass through happens ususally at the same time, but not sure
% about this
prod(orderA == orderB);

%--------------------------------------------------------------------------
% Check when the force becomes significantly different
[forceA,~] = get_forces(data1(test_index,2:end));
[forceB,~] = get_forces(data2(test_index,2:end));

check_force = forceA == forceB;
diff_force = forceA - forceB;
sum(~check_force)
diff_force(diff_force>0)