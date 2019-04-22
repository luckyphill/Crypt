% This script runs the optimisation process for the MouseColonTrans
% Objective function for the Mouse Transverse Colon
% Values taken from Sunter et al 1979
% Crypt height: 34.7 cells
% Max division height: 29 cells (from figure)
% Birth rate: 0.44 cells/column/hour
% Cycle time: 21 hours (average from position groups)
% G1 time: 10.3 hours

fprintf('Optimising Mouse Transverse Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf','run'};
p.prange = {[28, 33], [16, 24], [50, 100], [150, 200], [0.7],[1]};
p.limits = {[24, 35], [12, 30], [10, 200], [50,  400], [0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400 -cct 21 -wt 11';

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonTrans;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = '/home/a1738927/fastdir/';

p.repetitions = 2;


find_optimal_region(p);