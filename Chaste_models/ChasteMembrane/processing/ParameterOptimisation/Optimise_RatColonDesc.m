% This script runs the optimisation process for the RatColonDesc
% Objective function for the Rat Descending Colon
% Values taken from Sunter et al 1979B
% Crypt height: 41.8 cells
% Max division height: 34 cells (from figure)
% Birth rate: 0.42 cells/column/hour
% Cycle time: 58 hours
% G1 time: 46.6 hours

fprintf('Optimising Rat Descending Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf'};
p.prange = {[36, 42], [20, 28], [50, 100], [150, 200], [0.7]};
p.limits = {[30, 48], [16, 36], [10, 200], [50,  400], [0.6, 0.95]};
p.min_step_size = [1,1,1,1,0.005,1];

p.static_flags = {'t','cct','wt'};
p.static_params= [400, 58,   12];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @RatColonDesc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 2;


find_optimal_region(p);