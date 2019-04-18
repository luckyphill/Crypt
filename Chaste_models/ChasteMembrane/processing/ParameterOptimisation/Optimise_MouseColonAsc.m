% This script runs the optimisation process for the MouseColonAsc
% Objective function for the Mouse Ascending Colon
% Values taken from Sunter et al 1979
% Crypt height: 19.3 cells
% Max division height: 15 cells (from figure)
% Birth rate: 0.36 cells/column/hour
% Cycle time: 19 hours (average from position groups)
% G1 time: 9 hours

p.input_flags= {'n','np','ees','ms','vf','run'};
p.prange = {[15, 18], [8, 12], [50, 100], [150, 200], [0.7],[1]};
p.limits = {[12, 20], [6, 15], [10, 200], [50,  400], [0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400 -cct 19 -wt 10';

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonAsc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = '/Users/phillipbrown/';

p.repetitions = 2;


find_optimal_region(p);