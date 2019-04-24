% This script runs the optimisation process for the RatColonAsc
% Objective function for the Rat Ascending Colon
% Values taken from Sunter et al 1979B
% Crypt height: 33.2 cells
% Max division height: 29 cells (from figure)
% Birth rate: 0.34 cells/column/hour
% Cycle time: 35 hours
% G1 time: 24.6 hours

fprintf('Optimising Rat Ascending Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf'};
p.prange = {[26, 32], [20, 28], [50, 100], [150, 200], [0.7]};
p.limits = {[24, 38], [16, 32], [10, 200], [50,  400], [0.6, 0.95]};
p.min_step_size = [1,1,1,1,0.005,1];

p.static_flags = {'t','cct','wt'};
p.static_params= [400, 35,   11];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @RatColonAsc;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 2;


find_optimal_region(p);