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