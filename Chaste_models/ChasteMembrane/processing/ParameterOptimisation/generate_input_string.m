function input_string = generate_input_string(input_flags, input_values)

	% This function takes the flags and values and turns them into a complete
	% input command for this specific simulation

	n = length(input_flags);
	m = length(input_values);

	assert(n==m);

	input_string = ' -sm 10';

	for i = 1:n
		input_string = [input_string, sprintf(' -%s %g',input_flags{i}, input_values(i))];
	end

end