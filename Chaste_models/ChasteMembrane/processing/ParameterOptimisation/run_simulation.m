function penalty = run_simulation(p)
	% This function takes the parameter input and the chaste test
	% It first checks that data doesn't already exist (can provide an option to ignore this step)
	% If data does exist, it returns that data
	% If not, then it runs the simulation to generate that data, then applies the p.objective function
	% to produce a penalty. The penalty is returned

	% THE PURPOSE OF THIS FUNCTION IS TO ENSURE THAT EXISITING DATA IS NOT REGENERATED UNECESSARILY
	% THIS SHOULD ONLY BE USED WHEN THE OUTPUT MUST ALWAYS BE THE RESULT OF A COMPLETED SIMULATION
	% IF ONLY READING EXISTING DATA, THEN USE A READ DATA FUNCTION 

	simulation_command = [p.base_path, 'chaste_build/projects/ChasteMembrane/test/', p.chaste_test];

	data_file = generate_file_name(p);

	input_string = generate_input_string(p);

	if exist(data_file, 'file') == 2 && ~p.ignore_existing
		fprintf('Found existing data\n');
		try
			data = get_data_from_file(data_file);
		catch
			fprintf('Problem retrieving data, attempting to regenerate\n');
			[status,cmdout] = system([simulation_command, input_string],'-echo');
			data = get_data_from_output(cmdout, data_file);
		end
	else
		if p.ignore_existing
			fprintf('Existing data ignored. Simulating with input: %s\n', input_string);
		else
			fprintf('Data does not exist. Simulating with input: %s\n', input_string);
			fprintf('%s\n', data_file);
		end
		[status,cmdout] = system([simulation_command, input_string],'-echo');
		data = get_data_from_output(cmdout, data_file);
	end

	penalty = p.obj(data);

	fprintf('Penalty for this parameter set: %g\n\n', penalty);

end