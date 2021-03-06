% This script runs the optimisation process for the MouseColonAsc
% Objective function for the Mouse Ascending Colon
% Values taken from Sunter et al 1979
% Crypt height: 19.3 cells
% Max division height: 15 cells (from figure)
% Birth rate: 0.36 cells/column/hour
% Cycle time: 19 hours (average from position groups)
% G1 time: 9 hours

fprintf('Optimising Mouse Asecnding Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf','cct','wt'};
p.prange = {[19], [8], [50], [200], [0.7], [19], [10]};
p.limits = {[12, 26], [6, 15], [10, 200], [50,  400], [0.6, 0.95], [15, 21], [8, 12]};
p.min_step_size = [1,1,1,1,0.01,0.5,0.5];

p.static_flags = {'t'};
p.static_params= [400];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonAsc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 5;

find_optimal_region(p);