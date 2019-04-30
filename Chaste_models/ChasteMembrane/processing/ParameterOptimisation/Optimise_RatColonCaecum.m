% This script runs the optimisation process for the RatColonCaecum
% Objective function for the Rat Colon Caecum
% Values taken from Sunter et al 1979B
% Crypt height: 32.8 cells
% Max division height: 20 cells (from figure)
% Birth rate: 0.43 cells/column/hour
% Cycle time: 25.4 hours (average from position groups)
% G1 time: 15.2 hours

fprintf('Optimising Rate Caecum parameters\n');

p.input_flags= {'n','np','ees','ms','vf','cct','wt'};
p.prange = {[30], [12], [58], [392], [0.75], [25], [10]};
p.limits = {[20, 37], [8,  23], [10, 200], [50,  500], [0.6, 0.95], [22, 28], [8, 12]};
p.min_step_size = [1,1,1,1,0.01,1,0.5,0.5];

p.static_flags = {'t'};
p.static_params= [400];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @RatColonCaecum;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 5;


find_optimal_region(p);