% This script runs the optimisation process for the RatColonAsc
% Objective function for the Rat Ascending Colon
% Values taken from Sunter et al 1979B
% Crypt height: 33.2 cells
% Max division height: 29 cells (from figure)
% Birth rate: 0.34 cells/column/hour
% Cycle time: 35 hours
% G1 time: 24.6 hours

fprintf('Optimising Rat Ascending Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf','cct','wt'};
p.prange = {[26, 34], [18, 26], [50, 100], [150, 200], [0.7], [35], [11]};
p.limits = {[29, 38], [16, 28], [10, 200], [50,  400], [0.6, 0.95], [31, 39], [8, 14]};
p.min_step_size = [1,1,1,1,0.01,1,0.5,0.5];

p.static_flags = {'t'};
p.static_params= [400];

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

p.repetitions = 5;


find_optimal_region(p);