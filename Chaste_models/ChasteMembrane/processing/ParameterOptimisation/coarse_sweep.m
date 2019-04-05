function best_input_values = coarse_sweep(chaste_test, obj, input_flags, prange, fixed_parameters, ignore_existing);
	% This function does a super coarse parameter sweep in order to find a starting zone
	% It expects prange to be a cell array with containing vectors
	% Each vector should have at most three entries, otherwise computation time will _really_
	% blow out.
	% It runs until all parameter combinations are complete, or it finds a combination
	% with an objective function penalty of 10 or below.

	% When it stops, it returns the parameter set that is the best/first below 10,
	% so that can be fed into the fine grain root finding algorithm

	target_penalty = 10;

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
		[a,b] = size(indices);
		set_index = randi(a);
		index_collection = indices(set_index,:);
		
		% delete the indices
		indices(set_index,:) = [];

		input_values = [];
		for i = 1:n
			input_values = [input_values; prange{i}(index_collection(i))];
		end

		result = run_simulation(chaste_test, obj, input_flags, input_values, fixed_parameters, ignore_existing);

		if result < best_result
			best_input_values = input_values;
			best_result = result;
			fprintf('New best result: %d\n', best_result);
			fprintf('Using parameters: %s\n', generate_input_string(input_flags, input_values, fixed_parameters));
		end

		iters = iters + 1;

	end
