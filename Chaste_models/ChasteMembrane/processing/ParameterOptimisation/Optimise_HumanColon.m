% This script runs the optimisation process for the HumanColon
% Objective function for the Human Colon
% Values taken from Potten et al 1992
% Crypt height: 82.2 cells
% Max division height: 65 cells (from figure)
% Birth rate: NOT GIVEN guess of 0.75 cells/column/hour
% Cycle time: 30 hours
% G1 time: NOT GIVEN

fprintf('Optimising Human Colon parameters\n');

p.input_flags= {'n','np','ees','ms','vf'};
p.prange = {[60, 83], [40, 50], [50, 100], [150, 200], [0.7]};
p.limits = {[55, 90], [40, 65], [10, 200], [50,  400], [0.6, 0.95]};
p.min_step_size = [1,1,1,1,0.01];

p.static_flags = {'t','cct','wt'};
p.static_params= [400, 30,   10];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @HumanColon;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.repetitions = 2;


find_optimal_region(p);