function find_optimal_region(chaste_test, obj, input_flags, prange, limits, min_step_size, fixed_parameters, ignore_existing)

	% This function takes in the name of a Chaste test, and an associated objective function
	% The goal is to explore the parameter space and find a point/region where the objective function
	% is minimised. It also needs to take a list of input parameters and an initial search
	% range for each parameter

	% obj is a function handle. It takes a vector of numbers and returns a single number representing the score
	% of the relevant parameter set. The order of the numbers will be determined by the output {chaste_test}
	% produces. If there is an issue with the expected values in the input vector not matching
	% it should be addressed in the file {chaste_test} or {obj}

	% input_flags contains the input flag names
	% prange gives the initial coarse grained parameters to test
	% limits gives the [min, max] values thta parameters can take
	% min_step_size is the minimum step size allowed in pattern_search - necessary since some inputs ar integers
	% ignore existing is a true/false flag that says if to run simulations even when data exists - important if {chaste_test} is modified

	% The Chaste test will print all the relevent data to the command line
	% This output will be captured and saved to file
	% The capture function will look for output between the lines "DEBUG: START" and "DEBUG: END"
	% and on each line will put the data (assumed numerical) found after the "=" into a vector
	% This vector will be passed to {obj} for processing
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

	best_input_values = coarse_sweep(chaste_test, obj, input_flags, prange, fixed_parameters, ignore_existing);

	fprintf('\n\nCoarse sweep completed, starting pattern search\n\n\n');

	minimum_point = pattern_search(chaste_test, obj, input_flags, best_input_values, limits, min_step_size, fixed_parameters, ignore_existing);

	fprintf('\n\nPattern search completed, best parameters are %s\n\n\n', generate_input_string(input_flags, minimum_point));

	% [parameter_space, ranges] = fine_sweep(chaste_test, obj, input_flags, minimum_point, fixed_parameters, ignore_existing)



end
