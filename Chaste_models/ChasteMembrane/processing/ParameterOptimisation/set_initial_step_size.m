function step_size = set_initial_step_size(min_step_size, limits, input_flags)
	% Sets the initial step sizes based on the limits
	for i=1:length(input_flags)
		r = limits{i}(2) - limits{i}(1);
		% Since the steps are halved at each step, ideally we want a power of 2 to start with
		% so, take the second largest power of two that is smaller than the range

		step_size(i) = 2^(floor(log2(r)) - 1);
		if strcmp(input_flags{i},'vf')
			step_size(i) = 0.1;
		end
	end

end