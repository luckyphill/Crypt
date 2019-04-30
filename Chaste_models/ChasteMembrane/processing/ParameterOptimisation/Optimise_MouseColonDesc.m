% This script runs the optimisation process for the MouseColonDesc
% Objective function for the Mouse Descending Colon
% Values taken from Tsubouchi 1981
% Crypt height: 32.9 cells
% Max division height: 21 cells (from figure)
% Values taken from Sunter et al 1979
% Birth rate: 0.93 cells/column/hour
% Cycle time: 15 hours (average from position groups)
% G1 time: 7 hours

fprintf('Optimising Mouse Descending Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf','cct','wt'};
p.prange = {[29], [12], [58], [200], [0.7], [15], [8]};
p.limits = {[24, 38], [6, 21], [10, 200], [50,  400], [0.6, 0.95], [12, 18], [6, 10]};
p.min_step_size = [1,1,1,1,0.01,1,0.5,0.5];

p.static_flags = {'t'};
p.static_params= [400];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonDesc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 5;


find_optimal_region(p);