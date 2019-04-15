%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
test_index = first + 40;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

for test_index = first:last

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

    what = s_test_nodesA == s_test_nodesB;

    %--------------------------------------------------------------------------
    % Look at the calculated node pairs between runs
    sum(sum(calculated_pairsA == calculated_pairsB));

    %--------------------------------------------------------------------------
    % Look at the order of the cells to spot when the pass through occurs

    prod(orderA == orderB)
end