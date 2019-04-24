% This script runs the optimisation process for the MouseColonCaecum
% Objective function for the Mouse Colon Caecum
% Values taken from Sunter et al 1979
% Crypt height: 25.3 cells
% Max division height: 17 cells (from figure)
% Birth rate: 0.43 cells/column/hour
% Cycle time: 15.5 hours (average from position groups)
% G1 time: 6.7 hours

fprintf('Optimising Mouse Caecum parameters\n');

p.input_flags= {'n','np','ees','ms','vf'};
p.prange = {[24], [8], [100], [200], [0.7]};
p.limits = {[14, 30], [6, 18], [10, 200], [50,  400], [0.6, 0.95]};
p.min_step_size = [1,1,1,1,0.01];

p.static_flags = {'t','cct','wt'};
p.static_params= [400, 15,   9];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonCaecum;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 2;


find_optimal_region(p);