% This script runs the optimisation process for the MouseColonDesc

p.input_flags= {'n','np','ees','ms','cct','vf','run'};
p.prange = {[28],[12], [50],[200],[15],[0.7],[1]};
p.limits = {[24,34],[8,16],[10,200],[20,400],[14,16],[0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400';

p.chaste_test = 'TestCryptColumn';
p.obj = @MouseColonDesc;
p.ignore_existing = false;

p.base_path = '/Users/phillipbrown/';

p.repetitions = 2;


find_optimal_region(p);