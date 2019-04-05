% This script runs the optimisation process for the MouseColonDesc

input_flags= {'n','np','ees','ms','cct','vf','run'};
prange = {[26],[12], [50],[200],[15],[0.7],[1]};
limits = {[20,40],[8,16],[10,200],[20,400],[12,18],[0.6, 0.95],[1,1000]};
min_step_size = [1,1,1,1,1,0.01,1];

fixed_parameters = ' -t 200';


find_optimal_region('TestCryptColumn', @MouseColonDesc, input_flags, prange, limits, min_step_size, fixed_parameters, false);