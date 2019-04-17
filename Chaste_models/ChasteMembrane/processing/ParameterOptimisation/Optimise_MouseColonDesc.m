% This script runs the optimisation process for the MouseColonDesc

input_flags= {'n','np','ees','ms','cct','vf','run'};
prange = {[30],[12], [50],[200],[15],[0.7],[1]};
limits = {[24,35],[8,16],[10,200],[20,400],[12,18],[0.6, 0.95],[1,1000]};
min_step_size = [1,1,1,1,1,0.005,1];

fixed_parameters = ' -t 400';


find_optimal_region('TestCryptColumn', @MouseColonDesc, input_flags, prange, limits, min_step_size, fixed_parameters, false);