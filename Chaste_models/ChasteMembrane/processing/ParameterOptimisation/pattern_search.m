function values = pattern_search(p)
	% This script uses the pattern search optimisation algorithm to find the
	% point in parameter space that gives the best column crypt behaviour.
	% See https://en.wikipedia.org/wiki/Pattern_search_(optimization)
	%
	% Briefly, in a multidimensional problem, the algorithm takes steps along
	% one axis until the p.objective function fails to improve. When it fails, it
	% halves the step size in that coordinate, then moves to the next axis and
	% repeats the process. This continues until the p.objective function reaches
	% it target.

	% This function must have p.input_values defined, which will be used as the starting point

	iterations = 0;
	it_limit = 30;

	first_step = true; % When we start searching in a new variable/dimension
					   % we need to look both directions before we start stepping
	fprintf('Pre-loop re-test\n');
	fprintf('Testing parameters %s\n', generate_input_string(p));
	penalty = run_multiple(p);
	fprintf('Done\n\n');

	step_size = set_initial_step_size(p.min_step_size, p.limits, p.input_flags); % Make this start off at 0.1 of the limit range
	axis_index = 1; % The variable that will be stepped in

	direction = 1; % use this to choose increasing or decreasing

	values = p.input_values;

	fprintf('Starting loop\n');
	% Start the optimisation procedure
	while penalty > 0 && iterations < it_limit
	    % choose an axis, choose a direction, take steps until no improvement
	    % if no improvement, halve the step size, try a new axis
	    test_values = values;
	    
	    test_values(axis_index) = values(axis_index) + direction * step_size(axis_index);
	    
	    % If the step goes outside the p.limits
	    if test_values(axis_index) > p.limits{axis_index}(2) || test_values(axis_index) < p.limits{axis_index}(1)
	    	% Halve the step size, move to the next variable
	    	fprintf('Stepped outside of range for %s\n\n', p.input_flags{axis_index});
	    	step_size(axis_index) = reduce_step_size(step_size(axis_index), p.min_step_size(axis_index), p.input_flags{axis_index});
	    	axis_index = next_index(axis_index, p.input_flags);
	    	first_step = true;
	    	continue;
	    end
	    
	    p.input_values = test_values;
	    fprintf('Stepping in direction of %s\n', p.input_flags{axis_index});
	    fprintf('Testing parameters %s\n', generate_input_string(p));
	    
	    new_penalty = run_multiple(p);
	    
	    fprintf('Done\n\n');
	    
	    if first_step && new_penalty > penalty
	        % Run again, but this time stepping in the oposite direction
	        test_values = values;
	    
	        test_values(axis_index) = values(axis_index) - direction * step_size(axis_index);
	        
	        if test_values(axis_index) > p.limits{axis_index}(2) || test_values(axis_index) < p.limits{axis_index}(1)
		    	% Halve the step size, move to the next variable
		    	fprintf('Stepped outside of range for %s\n\n', p.input_flags{axis_index});
		    	step_size(axis_index) = reduce_step_size(step_size(axis_index), p.min_step_size(axis_index), p.input_flags{axis_index});
		    	axis_index = next_index(axis_index, p.input_flags);
		    	first_step = true;
	    	else
	        	
	        	p.input_values = test_values;

		        fprintf('Simulating opposite direction\n');
		        fprintf('Testing parameters %s\n', generate_input_string(p));
		        
		        new_penalty_2 = run_multiple(p);
		        
		        fprintf('Done\n\n');
		        
		        if new_penalty_2 < new_penalty
		            fprintf('Opposite direction better, stepping that direction\n');
		            new_penalty = new_penalty_2;
		            direction = -direction;
		        end
		        first_step = false;
		    end

	    end
	    
	    % if the result is better...
	    if new_penalty < penalty
	        fprintf('Step produced improvement\n');
	        penalty = new_penalty;
	        values(axis_index) = values(axis_index) + direction * step_size(axis_index);
	        fprintf('penalty = %g, with input %s\n\n', penalty, generate_input_string(p, values));
	    else
	        % if it is not better, halve the step size, move to the next
	        % axis, reset the stepping direction and reset the first step tracker
	        step_size(axis_index) = reduce_step_size(step_size(axis_index), p.min_step_size(axis_index), p.input_flags{axis_index});
	    	axis_index = next_index(axis_index, p.input_flags);
	    	fprintf('Step did not improve penalty, moving to variable %s\n\n', p.input_flags{axis_index});

	        
	        first_step = true;
	        direction = +1;
	    end

	    
	    iterations = iterations + 1;
	        
	end

end


function penalty = run_multiple(p)
	% Runs multiple tests for each parameter set and returns the average penalty

	penalties = nan(p.repetitions,1);

	for i = 1:p.repetitions
		% Set the run number here
		p.run_number = i;
		penalties(i) = run_simulation(p);
		penalty = mean(penalties);
	end

	penalty = mean(penalties);
	fprintf('Mean penalty for this parameter set: %g\n\n', penalty);

end