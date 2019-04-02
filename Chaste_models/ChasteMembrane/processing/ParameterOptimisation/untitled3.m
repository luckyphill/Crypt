
input_flags = {'n','np','ees','ms','cct','vf','run'};
input_values = [26;14;100;328;15;0.8;1];

for i = 1:10
    input_values(end) = i;
    penalties(i) = run_simulation('TestCryptNewPhaseModel', @MouseColonDesc, input_flags, input_values, false);
end




function penalty = run_simulation(chaste_test, obj, input_flags, input_values, ignore_existing)
	% This function takes the parameter input and the chaste test
	% It first checks that data doesn't already exist (can provide an option to ignore this step)
	% If data does exist, it returns that data
	% If not, then it runs the simulation to generate that data, then returns it

	base_path = '/Users/phillipbrown/';

	simulation_command = [base_path, 'chaste_build/projects/ChasteMembrane/test/', chaste_test];

	data_file_dir = [base_path, 'Research/Crypt/Data/Chaste/ParameterOptimisation/', chaste_test, '/', func2str(obj), '/'];
	if exist(data_file_dir,'dir')~=7
		% Make the full path
		if exist([base_path, 'Research/Crypt/Data/Chaste/ParameterOptimisation/', chaste_test, '/'],'dir')~=7
			mkdir([base_path, 'Research/Crypt/Data/Chaste/ParameterOptimisation/', chaste_test, '/']);
		end

		mkdir(data_file_dir);

	end

	data_file_name = generate_file_name(input_flags, input_values);

	input_string = generate_input_string(input_flags, input_values);

	data_file = [data_file_dir, data_file_name];

	if exist(data_file, 'file') == 2 && ~ignore_existing
		fprintf('Found existing data\n');
		data = get_data_from_file(data_file);
	else
		fprintf('Data does not exist. Simulating with input: %s\n', input_string);
		[status,cmdout] = system([simulation_command, input_string],'-echo');
		data = get_data_from_output(cmdout, data_file);
	end

	penalty = obj(data);

	fprintf('Penalty for this parameter set: %g\n', penalty);

end

function file_name = generate_file_name(input_flags, input_values)

	% This function takes in the flags and values for this particular simulation,
	% and produces the file name. There are numerous variables that can be provided
	% and they all ought to be represented in the file name if they are specified
	% At the same time we want to keep them all in a regular order. This function
	% won't do that. If a special order is needed, that should be controlled 
	% outside find_optimal_region

	n = length(input_flags);
	m = length(input_values);

% 	assert(n==m);

	file_name = 'parameter_search';

	for i = 1:n
		file_name = [file_name, sprintf('_%s_%g',input_flags{i}, input_values(i))];
	end

	file_name = [file_name, '.txt'];

end

function input_string = generate_input_string(input_flags, input_values)

	% This function takes the flags and values and turns them into a complete
	% input command for this specific simulation

	n = length(input_flags);
	m = length(input_values);

% 	assert(n==m);

	input_string = ' -sm 10';

	for i = 1:n
		input_string = [input_string, sprintf(' -%s %g',input_flags{i}, input_values(i))];
	end

end


function data = get_data_from_file(data_file)
	% Reads the data from file
	data = csvread(data_file);
end

function data = get_data_from_output(cmdout, data_file)
	% Extracts data from the command line output, and saves it to file
	temp1 = strsplit(cmdout, 'START');
	temp2 = strsplit(temp1{2}, 'DEBUG: ');

	data = [];
	for i = 2:length(temp2)-1
		temp3 = strsplit(temp2{i}, ' = ');
		data = [data; str2num(temp3{2})];
	end

	csvwrite(data_file, data);

end