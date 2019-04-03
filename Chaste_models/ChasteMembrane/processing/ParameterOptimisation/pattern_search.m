function values = pattern_search(chaste_test, obj, input_flags, values, limits, min_step_size, ignore_existing)
	% This script uses the pattern search optimisation algorithm to find the
	% point in parameter space that gives the best column crypt behaviour.
	% See https://en.wikipedia.org/wiki/Pattern_search_(optimization)
	%
	% Briefly, in a multidimensional problem, the algorithm takes steps along
	% one axis until the objective function fails to improve. When it fails, it
	% halves the step size in that coordinate, then moves to the next axis and
	% repeats the process. This continues until the objective function reaches
	% it target.

	iterations = 0;
	it_limit = 20;
	repetitions = 10;

	first_step = true; % When we start searching in a new variable/dimension
					   % we need to look both directions before we start stepping
	fprintf('Pre-loop re-test\n');
	fprintf('Testing parameters %s\n', generate_input_string(input_flags, values));
	penalty = run_multiple(chaste_test, obj, input_flags, values, ignore_existing, repetitions);
	fprintf('Done\n\n');

	step_size = set_initial_step_size(min_step_size, limits, input_flags); % Make this start off at 0.1 of the limit range
	axis_index = 1; % The variable that will be stepped in

	direction = 1; % use this to choose increasing or decreasing

	fprintf('Starting loop\n');
	% Start the optimisation procedure
	while penalty > 0 && iterations < it_limit
	    % choose an axis, choose a direction, take steps until no improvement
	    % if no improvement, halve the step size, try a new axis
	    test_values = values;
	    
	    test_values(axis_index) = values(axis_index) + direction * step_size(axis_index);
	    
	    % If the step goes outside the limits
	    if test_values(axis_index) > limits{axis_index}(2) || test_values(axis_index) < limits{axis_index}(1)
	    	% Halve the step size, move to the next variable
	    	fprintf('Stepped outside of range for %s\n\n', input_flags{axis_index});
	    	step_size(axis_index) = reduce_step_size(step_size(axis_index), min_step_size(axis_index), input_flags{axis_index});
	    	axis_index = next_index(axis_index, input_flags);
	    	first_step = true;
	    	continue;
	    end
	    
	    fprintf('Stepping in direction of %s\n', input_flags{axis_index});
	    fprintf('Testing parameters %s\n', generate_input_string(input_flags, test_values));
	    new_penalty = run_multiple(chaste_test, obj, input_flags, test_values, ignore_existing, repetitions);
	    fprintf('Done\n\n');
	    
	    if first_step && new_penalty > penalty
	        % Run again, but this time stepping in the oposite direction
	        test_values = values;
	    
	        test_values(axis_index) = values(axis_index) - direction * step_size(axis_index);
	        
	        if test_values(axis_index) > limits{axis_index}(2) || test_values(axis_index) < limits{axis_index}(1)
		    	% Halve the step size, move to the next variable
		    	fprintf('Stepped outside of range for %s\n\n', input_flags{axis_index});
		    	step_size(axis_index) = reduce_step_size(step_size(axis_index), min_step_size(axis_index), input_flags{axis_index});
		    	axis_index = next_index(axis_index, input_flags);
		    	first_step = true;
	    	else
	        
		        fprintf('Simulating opposite direction\n');
		        fprintf('Testing parameters %s\n', generate_input_string(input_flags, test_values));
		        new_penalty_2 = run_multiple(chaste_test, obj, input_flags, test_values, ignore_existing, repetitions);
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
	        fprintf('penalty = %g, with input %s\n\n', penalty, generate_input_string(input_flags, values));
	    else
	        % if it is not better, halve the step size, move to the next
	        % axis, reset the stepping direction and reset the first step tracker
	        step_size(axis_index) = reduce_step_size(step_size(axis_index), min_step_size(axis_index), input_flags{axis_index});
	    	axis_index = next_index(axis_index, input_flags);
	    	fprintf('Step did not improve penalty, moving to variable %s\n\n', input_flags{axis_index});

	        
	        first_step = true;
	        direction = +1;
	    end

	    
	    iterations = iterations + 1;
	        
	end

end


function penalty = run_multiple(chaste_test, obj, input_flags, test_values, ignore_existing, n, best_penalty)
	% Runs multiple tests for each parameter set and returns the average penalty

	penalties = nan(n,1);

	for i = 1:n
		% Set the run number here
		run_index = find(ismember(input_flags, 'run'));
		test_values(run_index) = i;
		penalties(i) = run_simulation(chaste_test, obj, input_flags, test_values, ignore_existing);
		penalty = mean(penalties);
	end

	penalty = mean(penalties);
	fprintf('Penalty for this parameter set: %g\n\n', penalty);

end