function test_parameter_optimisation_functions

	% Tests to make sure the funcitons work correctly
	input_flags = {'n', 'ees', 'ms', 'cct', 'vf', 'np', 'run'};
	input_values = [26, 50, 120, 15, 0.75, 13, 1];
	base_path = '/Users/phillipbrown/';

	file_name = generate_file_name('TestCryptNewPhaseModel', @sin, input_flags, input_values, base_path);
	assert(strcmp(file_name, '/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterOptimisation/TestCryptNewPhaseModel/sin/parameter_search_n_26_ees_50_ms_120_cct_15_vf_0.75_np_13_run_1.txt'));
	new_dir = '/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterOptimisation/TestCryptNewPhaseModel/sin/';
	assert(exist(new_dir, 'dir')==7);


	input_string = generate_input_string(input_flags, input_values);
	assert(strcmp(input_string, ' -sm 10 -n 26 -ees 50 -ms 120 -cct 15 -vf 0.75 -np 13 -run 1'));

	cmdout = ['DEBUG: Cell popped up' newline ...
	'DEBUG: (*cell_iter)->GetAge() = 13.186' newline ...
	'DEBUG: p_cell->GetCellId() = 53' newline ...
	'DEBUG: Normal cell ready to die' newline ...
	'DEBUG: it->second = 87.274' newline ...
	'DEBUG: About to kill' newline ...
	'DEBUG: (*cell_iter)->GetCellId() = 53' newline ...
	'DEBUG: Cell popped up' newline ...
	'DEBUG: (*cell_iter)->GetAge() = 12.912' newline ...
	'DEBUG: p_cell->GetCellId() = 80' newline ...
	'DEBUG: Normal cell ready to die' newline ...
	'DEBUG: it->second = 87.316' newline ...
	'DEBUG: About to kill' newline ...
	'DEBUG: (*cell_iter)->GetCellId() = 80' newline ...
	'DEBUG: START' newline ...
	'DEBUG: p_sloughing_killer->GetCellKillCount() = 68' newline ...
	'DEBUG: p_anoikis_killer->GetCellKillCount() = 14' newline ...
	'DEBUG: proliferative = 26' newline ...
	'DEBUG: differentiated = 12' newline ...
	'DEBUG: total_cells = 38' newline ...
	'DEBUG: cellId = 120' newline ...
	'DEBUG: Wcells = 20' newline ...
	'DEBUG: Pcells = 6' newline ...
	'DEBUG: p_writer->GetBirthCount()/2 = 0' newline ...
	'DEBUG: END' newline ...
	'Passed' newline ...
	'OK!'];

	test_read_file = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/processing/ParameterOptimisation/testing/parameter_search_n_26_ees_50_ms_120_cct_15_vf_0.75_np_13_run_1.txt';

	data = get_data_from_output(cmdout, test_read_file);
	assert(prod(data == [68; 14; 26; 12; 38; 120; 20; 6; 0])==1);
	assert(exist(test_read_file,'file')==2);
	
	data2 = get_data_from_file(test_read_file);
	assert(prod(data2 == [68; 14; 26; 12; 38; 120; 20; 6; 0])==1);


	penalty = run_simulation('TestCryptNewPhaseModel', @sin, input_flags, input_values, false);

	data3 = get_data_from_file(file_name);
	assert(prod(data3 == [68; 14; 26; 12; 38; 120; 20; 6; 0])==1);


end