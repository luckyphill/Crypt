
function fraction = ClonalRate_MouseColonDesc(param, value, N)
% This function simulates the chosen mutation parameter
% and returns the fraction of simulations where
% clonal conversion to the mutant cell type occurs

% The healthy crypt parameters are optimised to get as close as
% possible to the following output values:

% Values taken from Tsubouchi 1981
% Crypt height: 32.9 cells
% Max division height: 21 cells (from figure)
% Values taken from Sunter et al 1979
% Birth rate: 0.93 cells/column/hour
% Cycle time: 15 hours (average from position groups)
% G1 time: 7 hours

fprintf('Mutation sweep for Mouse Descending Colon\n');

p.input_flags = {};
p.input_flags = horzcat(p.input_flags, param);
p.input_values = [value];


p.static_flags = {'t','n','np','ees','ms','vf','cct','wt','dt'};
p.static_params= [400, 29, 12, 58, 216, 0.675, 15, 9, 0.001];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumnClonal';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonDescMutations;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

fraction = MutationEstablishmentFraction(p, N);

end
