function input_string = generate_input_string(p)

	% This function takes the flags and values and turns them into a complete
	% input command for this specific simulation

	n = length(p.input_flags);
	m = length(p.input_values);

	r = length(p.static_flags);
	q = length(p.static_params);

	assert(n==m);
	assert(r==q);

	input_string = [];

	for i = 1:q
		input_string = [input_string, sprintf(' -%s %g',p.static_flags{i}, p.static_params(i))];
	end

	for i = 1:n
		input_string = [input_string, sprintf(' -%s %g',p.input_flags{i}, p.input_values(i))];
	end

	input_string = [input_string, sprintf(' -%s %g',p.run_flag, p.run_number)];

end