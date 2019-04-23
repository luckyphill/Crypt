function data_file = generate_file_name(p)

	% This function takes in the flags and values for this particular simulation,
	% and produces the file name. There are numerous variables that can be provided
	% and they all ought to be represented in the file name if they are specified
	% At the same time we want to keep them all in a regular order. This function
	% won't do that. If a special order is needed, that should be controlled 
	% outside find_optimal_region

	n = length(p.input_flags);
	m = length(p.input_values);

	r = length(p.static_flags);
	q = length(p.static_params);

	assert(n==m);
	assert(r==q);

	file_dir = [p.base_path, 'Research/Crypt/Data/Chaste/ParameterOptimisation/', p.chaste_test, '/', func2str(p.obj), '/'];
	if exist(file_dir,'dir')~=7
		% Make the full path
		if exist([p.base_path, 'Research/Crypt/Data/Chaste/ParameterOptimisation/', p.chaste_test, '/'],'dir')~=7
			mkdir([p.base_path, 'Research/Crypt/Data/Chaste/ParameterOptimisation/', p.chaste_test, '/']);
		end

		mkdir(file_dir);

	end

	file_name = 'parameter_search';

	for i = 1:q
		file_name = [file_name, sprintf('_%s_%g',p.static_flags{i}, p.static_params(i))];
	end

	for i = 1:n
		file_name = [file_name, sprintf('_%s_%g',p.input_flags{i}, p.input_values(i))];
	end

	file_name = [file_name, sprintf('_%s_%g',p.run_flag, p.run_number)];

	file_name = [file_name, '.txt'];

	data_file = [file_dir, file_name];

end