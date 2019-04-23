function best_result = genetic_algorithm(p)
	% This function uses a genetic algorithm to search the parameter space
	% The gene is made up of a binary representation of the input parameters
	% Crossing over swaps the binary digits, but at the same time forces them to stay
	% between certain limits

	N = 20; % gene pool size
	G = 20; % generations


	% Choose some random starting genes
	lpl = length(p.limits)
	combinations = 1;

	for i = 1:lpl
		spread = p.limits{i}[2] - p.limits{i}[1];
		counts(i) = uint16(spread / p.min_step_size(i));
		combinations = combinations * counts(i);
	end

	% Initial seeding of the population
	for i = 1:N
		random_input = randi(combinations);
		indices = it2indices(random_input, counts);
		genes{i} = make_gene(p, indices);
		fitness{i} = run_simulation(p);
	end

	animals = struct('gene', genes, 'fitness', fitness);

	% Initial sort
	temp = struct2table(animals);
	sortedtemp = sortrows(temp,'fitness');
	animals = table2struct(sortedtemp);


	while best_fitness > 0 && generation < G

		% sort by order of fitness
		% cross_over
		% determine fitness
		% find best fitness
		% remove weakest
		% next step

		animals = add_new_animals(animals, p, N);

		temp = struct2table(animals);
		sortedtemp = sortrows(temp,'fitness');
		animals = table2struct(sortedtemp);

		animals = animals(1:N);

		best_fitness = animals(1).fitness;

		generation = generation + 1;
	end



end


function animals = add_new_animals(animals, p, N)
	% Takes the population and adds new animals by crossing over
	% genes. The animals will be chosen at random, weighted by fitness

	for i = 1:n_new
		[q, r] = pick_pair(animals);
		animals(N + i).gene = cross_over(q, r);
		p.input_values  = gene2input(animals(N + i).gene);
		animals(N + i).fitness = run_simulation(p);
	end

end


function [q, r] = pick_pair(animals, N)
	% Randomly picks two animals based on their fitness



end
