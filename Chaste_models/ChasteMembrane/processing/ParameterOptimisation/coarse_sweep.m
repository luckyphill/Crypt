function best_input_values = coarse_sweep(p);
	% This function does a super coarse parameter sweep in order to find a starting zone
	% It expects p.prange to be a cell array with containing vectors
	% Each vector should have at most three entries, otherwise computation time will _really_
	% blow out.
	% It runs until all parameter combinations are complete, or it finds a combination
	% with an p.objective function penalty of 10 or below.

	% When it stops, it returns the parameter set that is the best/first below 10,
	% so that can be fed into the fine grain root finding algorithm

	% Only run each simulation once with a single seed
	p.run_number = 1;

	target_penalty = 10;

	n = length(p.prange);

	n_sets = uint8(1); % the number of parameter sets
	counts = nan(1,n); % used for it2indices - essentially it is a set of conversion rates

	for i = n:-1:1
	    counts(i) = n_sets;
	    n_sets = n_sets * uint8(length(p.prange{i}));
	end

	% indices is a completely enumerated list of all possible parameter index combinations
	indices = nan(n_sets,n);

	for i = 1:n_sets
	   
	   % it2indices uses a pretty nifty algorithm to convert the iterator i into a set
	   % indices refencing the position in p.prange that gives the parameter we want
	   % it avoids trying to code a set of nested for loops to an unknown depth
	   indices(i,:) = it2indices(i, counts);
	    
	end

	best_result = 10000;
	best_input_values = [];

	iters = 0;
	while best_result > target_penalty && iters < n_sets
		% Randomly sample the parameter sets until we get one with p.objective function
		% less than some limit
		
		% get the indices
		[a,b] = size(indices);
		set_index = randi(a);
		index_collection = indices(set_index,:);
		
		% delete the indices
		indices(set_index,:) = [];

		input_values = [];
		for i = 1:n
			input_values = [input_values; p.prange{i}(index_collection(i))];
		end

		p.input_values = input_values;
		result = run_simulation(p);

		if result < best_result
			best_input_values = input_values;
			best_result = result;
			fprintf('\n==============================================================\n');
			fprintf('New best result: %.2f\n', best_result);
			fprintf('Using parameters: %s\n', generate_input_string(p));
			fprintf('==============================================================\n');
		end

		iters = iters + 1;

	end
