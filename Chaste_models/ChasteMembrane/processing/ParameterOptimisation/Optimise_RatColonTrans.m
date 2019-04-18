% This script runs the optimisation process for the RatColonTrans
% Objective function for the Rat Transverse Colon
% Values taken from Sunter et al 1979B
% Crypt height: 43 cells
% Max division height: 33 cells (from figure)
% Birth rate: 0.51 cells/column/hour
% Cycle time: 42 hours (average from position groups)
% G1 time: 30.7 hours

p.input_flags= {'n','np','ees','ms','vf','run'};
p.prange = {[36, 40], [20, 28], [50, 100], [150, 200], [0.7],[1]};
p.limits = {[24, 43], [16, 33], [10, 200], [50,  400], [0.6, 0.95],[1,1000]};
p.min_step_size = [1,1,1,1,0.005,1];

p.fixed_parameters = ' -t 400 -cct 42 -wt 12';

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @RatColonTrans;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = '/Users/phillipbrown/';

p.repetitions = 2;


find_optimal_region(p);