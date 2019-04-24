% This script runs the optimisation process for the RatColonCaecum
% Objective function for the Rat Colon Caecum
% Values taken from Sunter et al 1979B
% Crypt height: 32.8 cells
% Max division height: 20 cells (from figure)
% Birth rate: 0.43 cells/column/hour
% Cycle time: 25.4 hours (average from position groups)
% G1 time: 15.2 hours

fprintf('Optimising Rate Caecum parameters\n');

p.input_flags= {'n','np','ees','ms','vf'};
p.prange = {[24, 28], [12, 16], [50, 100], [150, 200], [0.7]};
p.limits = {[20, 37], [8,  23], [10, 200], [50,  400], [0.6, 0.95]};
p.min_step_size = [1,1,1,1,0.005,1];

p.static_flags = {'t','cct','wt'};
p.static_params= [400, 25,   10];

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

p.repetitions = 2;


find_optimal_region(p);