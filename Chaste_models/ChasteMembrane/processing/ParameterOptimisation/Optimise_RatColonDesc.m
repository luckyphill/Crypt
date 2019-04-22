% This script runs the optimisation process for the RatColonDesc
% Objective function for the Rat Descending Colon
% Values taken from Sunter et al 1979B
% Crypt height: 41.8 cells
% Max division height: 34 cells (from figure)
% Birth rate: 0.42 cells/column/hour
% Cycle time: 58 hours
% G1 time: 46.6 hours

fprintf('Optimising Rat Descending Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf','run'};
p.prange = {[36, 42], [20, 28], [50, 100], [150, 200], [0.7],[1]};
p.limits = {[30, 42], [16, 32], [10, 200], [50,  400], [0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400 -cct 58 -wt 12';

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @RatColonDesc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = '/home/a1738927/fastdir/';

p.repetitions = 2;


find_optimal_region(p);