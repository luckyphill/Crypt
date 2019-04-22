% This script runs the optimisation process for the MouseColonCaecum
% Objective function for the Mouse Colon Caecum
% Values taken from Sunter et al 1979
% Crypt height: 25.3 cells
% Max division height: 17 cells (from figure)
% Birth rate: 0.43 cells/column/hour
% Cycle time: 15.5 hours (average from position groups)
% G1 time: 6.7 hours

fprintf('Optimising Mouse Caecum parameters\n');

p.input_flags= {'n','np','ees','ms','vf','run'};
p.prange = {[18, 24], [8, 14], [50, 100], [150, 200], [0.7],[1]};
p.limits = {[14, 25], [6, 18], [10, 200], [50,  400], [0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400 -cct 15 -wt 9';

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonCaecum;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = '/home/a1738927/fastdir/';

p.repetitions = 2;


find_optimal_region(p);