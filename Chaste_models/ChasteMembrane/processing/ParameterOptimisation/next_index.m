function axis_index = next_index(axis_index, input_flags)
	% Increments the axis index
	axis_index = axis_index + 1;

	if strcmp(input_flags{axis_index},'run')
		axis_index = axis_index + 1;
	end
	if (axis_index > length(input_flags))
		axis_index = 1;
	end

	fprintf('Moving to variable %s\n', input_flags{axis_index});

end