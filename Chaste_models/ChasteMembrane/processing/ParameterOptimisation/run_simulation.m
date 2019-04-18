function penalty = run_simulation(p, input_values)
	% This function takes the parameter input and the chaste test
	% It first checks that data doesn't already exist (can provide an option to ignore this step)
	% If data does exist, it returns that data
	% If not, then it runs the simulation to generate that data, then applies the p.objective function
	% to produce a penalty. The penalty is returned

	simulation_command = [p.base_path, 'chaste_build/projects/ChasteMembrane/test/', p.chaste_test];

	data_file = generate_file_name(p, input_values);

	input_string = generate_input_string(p, input_values);

	if exist(data_file, 'file') == 2 && ~p.ignore_existing
		fprintf('Found existing data\n');
		data = get_data_from_file(data_file);
	else
		fprintf('Data does not exist. Simulating with input: %s\n', input_string);
		[status,cmdout] = system([simulation_command, input_string],'-echo');
		data = get_data_from_output(cmdout, data_file);
	end

	penalty = p.obj(data);

	fprintf('Penalty for this parameter set: %g\n\n', penalty);

end