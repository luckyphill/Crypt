function find_optimal_region(chaste_test, obj, input_flags, prange)

	% This function takes in the name of a Chaste test, and an associated objective function
	% The goal is to explore the parameter space and find a point/region where the objective function
	% is minimised. It also needs to take a list of input parameters and an initial search
	% range for each parameter

	% obj is a function handle. It takes a vector of numbers and returns a single number representing the score
	% of the relevant parameter set. The order of the number will be determined by the output {chaste_test}
	% produces. If there is an issue with the expected values in the input vector not matching
	% it should be addressed in the file {chaste_test}

	% input_flags contains the input flag names
	% prange gives the initial coarse grained parameters to test

	% The Chaste test will print all the relevent data to the command line
	% This output will be captured and saved to file
	% The capture function will look for output between the lines "DEBUG: START" and "DEBUG: END"
	% and on each line will put the data (assumed numerical) found after the "=" into a vector
	% This vector will be passed to the objective function for processing
	% The file name will be automatically generated using the parameter names in input_flags
	% and the parameter values used by the particular simulation instance
	% Files will be stored in the directory structure: "/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/{chaste_test}/{obj}"
	% in other words, it treats each objective function like the specification of a different type of crypt  

	% A test to ensure basic functionality
	% test(1);

	% Optimisation in three stages:
	% Stage 1: A super coarse sweep, as determined by prange
	% Stage 2: Pick the best coarse parameter set as a starting point and find the minimum from there
	% Stage 3: With an optimal solution (assuming penalty of 0) branch out in multiple directions to
	%		   find the boundaries of the zero region

	best_input_values = coarse_sweep(chaste_test, obj, input_flags, prange)




end

function best_input_values = coarse_sweep(chaste_test, obj, input_flags, prange);
	% This function does a super coarse parameter sweep in order to find a starting zone
	% It expects prange to be a cell array with containing vectors
	% Each vector should have at most three entries, otherwise computation time will _really_
	% blow out.
	% It runs until all parameter combinations are complete, or it finds a combination
	% with an objective function penalty of 10 or below.

	% When it stops, it returns the parameter set that is the best/first below 10,
	% so that can be fed into the fine grain root finding algorithm

	target_penalty = 5;

	n = length(prange);

	n_sets = uint8(1); % the number of parameter sets
	counts = nan(1,n); % used for it2indices - essentially it is a set of conversion rates

	for i = n:-1:1
	    counts(i) = n_sets;
	    n_sets = n_sets * uint8(length(prange{i}));
	end

	% indices is a completely enumerated list of all possible parameter index combinations
	indices = nan(n_sets,n);

	for i = 1:n_sets
	   
	   % it2indices uses a pretty nifty algorithm to convert the iterator i into a set
	   % indices refencing the position in prange that gives the parameter we want
	   % it avoids trying to code a set of nested for loops to an unknown depth
	   indices(i,:) = it2indices(i, n, counts);
	    
	end

	best_result = 10000;
	best_input_values = [];

	iters = 0;
	while best_result > target_penalty && iters < n_sets
		% Randomly sample the parameter sets until we get one with objective function
		% less than some limit
		
		% get the indices
		set_index = randi(length(indices));
		index_collection = indices(set_index,:);
		
		% delete the indices
		indices(set_index,:) = [];

		input_values = [];
		for i = 1:n
			input_values = [input_values; prange{i}(index_collection(i))];
		end

		result = run_simulation(chaste_test, obj, input_flags, input_values);

		if result < best_result
			best_input_values = input_values;
			best_result = result;
			fprintf('New best result: %d\n', best_result);
		end

		iters = iters + 1;

	end

end

function indices = it2indices(i, n, counts)
    
    % This function takes a base 10 number 
    % and converts it to a non uniform base
    % using the conversion rates specified in counts
    
    % This is essentially the same process as converting
    % say, 100,000s in to days, hours, minutes and seconds, or
    % 200p into pounds, schillings pence
    % counts is the conversion rate for each level
    % i.e. if we are talking time conversion then
    % counts = (86400, 3600, 60, 1)

    indices = nan(1,n);
        
    for j = 1:n
       indices(j) = idivide(i, counts(j),'ceil');
       i = i - counts(j) * (indices(j)-1);  % -1 necessary because matlab indexes from 1 -\(o-o)/-
    end
    
end


function penalty = run_simulation(chaste_test, obj, input_flags, input_values)
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

	if exist(data_file, 'file') == 2
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

	assert(n==m);

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

	assert(n==m);

	input_string = '';

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


function parameters = optimiser(simulation_command, obj, p)



end


function test(n)

	% Tests to make sure the funcitons work correctly
	input_flags = {'n', 'ees', 'ms', 'cct', 'vf', 'np', 'run'};
	input_values = [26, 50, 120, 15, 0.75, 13, 1];

	file_name = generate_file_name(input_flags, input_values);
	assert(strcmp(file_name, 'parameter_search_n_26_ees_50_ms_120_cct_15_vf_0.75_np_13_run_1.txt'));

	input_string = generate_input_string(input_flags, input_values);
	assert(strcmp(input_string, ' -n 26 -ees 50 -ms 120 -cct 15 -vf 0.75 -np 13 -run 1'));

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

	file_dir = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/processing/ParameterOptimisation/';
	data_file = [file_dir, file_name];

	data = get_data_from_output(cmdout, data_file);
	assert(prod(data == [68; 14; 26; 12; 38; 120; 20; 6; 0])==1);
	assert(exist(data_file,'file')==2);
	
	data2 = get_data_from_file(data_file);
	assert(prod(data2 == [68; 14; 26; 12; 38; 120; 20; 6; 0])==1);


	penalty = run_simulation('TestCryptNewPhaseModel', @sin, input_flags, input_values);
	new_dir = '/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterOptimisation/TestCryptNewPhaseModel/sin/';
	assert(exist(new_dir, 'dir')==7);

	data_file = [new_dir, file_name];
	data3 = get_data_from_file(data_file);
	assert(prod(data3 == [68; 14; 26; 12; 38; 120; 20; 6; 0])==1);


end
