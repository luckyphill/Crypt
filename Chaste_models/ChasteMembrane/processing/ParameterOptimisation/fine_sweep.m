function parameter_space = fine_sweep(chaste_test, obj, input_flags, optimal, fixed_parameters, ignore_existing)
	% This function takes an optimal point (or the nearest that is calculated) and
	% performs a fine grained parameter sweep within a small region around that point
	% with the hope of finding the boundary of optimality

	% It sweeps a different number of points for each parameter about the optimal point found
	% n is limited to 2 either way				total = 5
	% np - 2 either way							total = 5
	% ees - 5 either way in steps of 5			total = 11
	% ms - 5 either way in steps of 5			total = 11
	% cct - 1 either way						total = 3
	% vf - 3 either way in steps of 0.02		total = 7

	% create the parameter vectors

	for i=1:length(input_flags)
		if strcmp(input_flags{i}, 'n')
			n = optimal(i);
			prange{i} = (n-2):(n+2);
		end
		if strcmp(input_flags{i}, 'np')
			np = optimal(i);
			prange{i} = (np-2):(np+2);
		end
		if strcmp(input_flags{i}, 'ees')
			ees = optimal(i);
			prange{i} = (ees-25):5:(ees+25);
		end
		if strcmp(input_flags{i}, 'ms')
			ms = optimal(i);
			prange{i} = (ms-25):5:(ms+25);
		end
		if strcmp(input_flags{i}, 'cct')
			cct = optimal(i);
			prange{i} = (cct-1):(cct+1);
		end
		if strcmp(input_flags{i}, 'vf')
			vf = optimal(i);
			prange{i} = (vf-0.06):0.02:(vf+0.06);
		end

	end

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
