function step_size = reduce_step_size(step_size, min_step_size, input_flag)
	% Ensures the step size doesn't go below the minimum
	% and ensures it remains an integer when needed
	fprintf('Reduced step size from %g', step_size);
	if (step_size/2 < min_step_size)
		step_size = min_step_size;
	else
		step_size = step_size/2;
	end
		

	% These input parameters must be integers
	if strcmp(input_flag, 'n') || strcmp(input_flag, 'np')
		step_size = floor(step_size);
	end
	fprintf(' to %g\n', step_size);

end