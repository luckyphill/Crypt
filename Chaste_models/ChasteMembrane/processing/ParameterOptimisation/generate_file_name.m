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