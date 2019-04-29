% This script runs the optimisation process for the RatColonTrans
% Objective function for the Rat Transverse Colon
% Values taken from Sunter et al 1979B
% Crypt height: 43 cells
% Max division height: 33 cells (from figure)
% Birth rate: 0.51 cells/column/hour
% Cycle time: 42 hours (average from position groups)
% G1 time: 30.7 hours

fprintf('Optimising Rat Transverse Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf'};
p.prange = {[36, 40], [20, 28], [50], [200], [0.7, 0.8]};
p.limits = {[24, 49], [16, 36], [10, 200], [50,  400], [0.6, 0.95]};
p.min_step_size = [1,1,1,1,0.005,1];

p.static_flags = {'t','cct','wt'};
p.static_params= [400, 42,   12];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @RatColonTrans;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 2;


find_optimal_region(p);