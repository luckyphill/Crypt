% This script runs the optimisation process for the RatColonAsc
% Objective function for the Rat Ascending Colon
% Values taken from Sunter et al 1979B
% Crypt height: 33.2 cells
% Max division height: 29 cells (from figure)
% Birth rate: 0.34 cells/column/hour
% Cycle time: 35 hours
% G1 time: 24.6 hours

p.input_flags= {'n','np','ees','ms','vf','run'};
p.prange = {[26, 32], [20, 28], [50, 100], [150, 200], [0.7],[1]};
p.limits = {[24, 33], [16, 29], [10, 200], [50,  400], [0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400 -cct 35 -wt 11';

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @RatColonAsc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = '/home/a1738927/fastdir/';

p.repetitions = 2;


find_optimal_region(p);