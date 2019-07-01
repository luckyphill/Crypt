

p.input_flags = {'Mnp', 'msM'};
p.input_values = [14, 0.7];


p.static_flags = {'t','n','np','ees','ms','vf','cct','wt','dt'};
p.static_params= [400, 29, 12, 58, 216, 0.675, 15, 9, 0.001];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumnMutation';

%----------------------------------------------------------------------------
%----------------------------------------------------------------------------
p.obj = @MouseColonDescMutations;
%----------------------------------------------------------------------------
%----------------------------------------------------------------------------

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

p.process = 'PairCorrelation';
p.output_file_prefix = 'position_data';



data = run_position_data(p)