% This script runs the optimisation process for the MouseColonTrans
% Objective function for the Mouse Transverse Colon
% Values taken from Sunter et al 1979
% Crypt height: 34.7 cells
% Max division height: 29 cells (from figure)
% Birth rate: 0.44 cells/column/hour
% Cycle time: 21 hours (average from position groups)
% G1 time: 10.3 hours

fprintf('Optimising Mouse Transverse Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf'};
p.prange = {[28, 33], [16, 24], [50, 100], [150, 200], [0.7]};
p.limits = {[24, 40], [12, 32], [10, 200], [50,  400], [0.6, 0.95]};
p.min_step_size = [1,1,1,1,0.005,1];

p.static_flags = {'t','cct','wt'};
p.static_params= [400, 21,   11];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonTrans;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 2;


find_optimal_region(p);