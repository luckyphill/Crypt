function penalty = run_simulation(chaste_test, obj, input_flags, input_values, fixed_parameters, ignore_existing)
	% This function takes the parameter input and the chaste test
	% It first checks that data doesn't already exist (can provide an option to ignore this step)
	% If data does exist, it returns that data
	% If not, then it runs the simulation to generate that data, then applies the objective function
	% to produce a penalty. The penalty is returned

	base_path = '/Users/phillip/';

	simulation_command = [base_path, 'chaste_build/projects/ChasteMembrane/test/', chaste_test];

	data_file = generate_file_name(chaste_test, obj, input_flags, input_values, base_path);

	input_string = generate_input_string(input_flags, input_values, fixed_parameters);

	if exist(data_file, 'file') == 2 && ~ignore_existing
		fprintf('Found existing data\n');
		data = get_data_from_file(data_file);
	else
		fprintf('Data does not exist. Simulating with input: %s\n', input_string);
		[status,cmdout] = system([simulation_command, input_string],'-echo');
		data = get_data_from_output(cmdout, data_file);
	end

	penalty = obj(data);

	fprintf('Penalty for this parameter set: %g\n\n', penalty);

end