% This script runs the optimisation process for the MouseColonDesc
% Objective function for the Mouse Descending Colon
% Values taken from Tsubouchi 1981
% Crypt height: 32.9 cells
% Max division height: 21 cells (from figure)
% Values taken from Sunter et al 1979
% Birth rate: 0.93 cells/column/hour
% Cycle time: 15 hours (average from position groups)
% G1 time: 7 hours

fprintf("Optimising Mouse Descending Colon parameters\n");

p.input_flags= {'n','np','ees','ms','vf','run'};
p.prange = {[26, 30], [8, 12], [50, 100], [150, 200], [0.7],[1]};
p.limits = {[24, 32], [6, 14], [10, 200], [50,  400], [0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400 -cct 15 -wt 8';

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonDesc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = '/home/a1738927/fastdir/';

p.repetitions = 2;


find_optimal_region(p);