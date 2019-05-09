
% This script produces the parameter space heat maps for the parameters given
% in the relevant sweep.txt file
% It reads the sweep file, creates the input file name, reads the input file,
% calculates the penalty, stores it in a multi dimensional array and plots
% slices of the space

directory = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/phoenix/ParameterOptimistation/TestCryptColumn/';
crypts = {'HumanColon', 'MouseColonAsc', 'MouseColonTrans', 'MouseColonDesc', 'MouseColonCaecum', 'RatColonAsc', 'RatColonTrans', 'RatColonDesc', 'RatColonCaecum'};

p.input_flags= {'n','np','ees','ms','vf','cct','wt'};

p.static_flags = {'t'};
p.static_params= [400];

p.run_flag = 'run';
p.run_number = 1;

p.chaste_test = 'TestCryptColumn';

p.ignore_existing = false;

p.base_path = [getenv('HOME'), '/'];

for i = 2
	file = [directory, crypts{i}, '/sweep.txt'];
	params = csvread(file);
	p.obj = str2func(crypts{i});
	penalty = nan(length(params),1);

	for j = 1:length(params)
		p.input_values = params(j,:);

		data_file = generate_file_name(p);
		try
			data = get_data_from_file(data_file);

			penalty(j) = p.obj(data);
		end
	end
end

