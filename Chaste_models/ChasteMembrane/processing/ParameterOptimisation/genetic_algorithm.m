function best_result = genetic_algorithm(p)
	% This function uses a genetic algorithm to search the parameter space
	% The gene is made up of a binary representation of the input parameters
	% Crossing over swaps the binary digits, but at the same time forces them to stay
	% between certain limits

	N = 20; % gene pool size
	G = 20; % generations


	% Choose some random starting genes
	lpl = length(p.limits);
	combinations = 1;

	for i = 1:lpl
		lims = p.limits{i};
		spread = lims(2) - lims(1);
		counts(i) = uint32(spread / p.min_step_size(i));
		combinations = combinations * counts(i);
	end
	combinations
	% Initial seeding of the population
	for i = 1:N
		random_input = randi(combinations);
		it2indices(random_input, counts)
		genes{i} = it2indices(random_input, counts);
		p.input_values = genes{i};
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
		best_result = animals(1).gene;

		generation = generation + 1;
	end



end


function animals = add_new_animals(animals, p, N)
	% Takes the population and adds new animals by crossing over
	% genes. The animals will be chosen at random, weighted by fitness

	for i = 1:n_new
		[q, r] = pick_pair(animals);
		animals(N + i).gene = cross_over(animals, p, q, r);
		p.input_values  = animals(N + i).gene;
		animals(N + i).fitness = run_simulation(p);
	end

end


function [q, r] = pick_pair(animals, N)
	% Randomly picks two animals based on their fitness

	% Calculates the sum of the reciprocals
	for i = 1:N
		recip = recip + 1/animals(i).fitness;
	end

	% Makes each animals probability
	probs = [0, (1./[animals(:).fitness])/recip];

	rand_q = rand;
	rand_r = rand;

	for i = 1:N
		if rand_q < probs(i) && rand_q < probs(i+1)
			q = i;
		end
		if rand_r < probs(i) && rand_r < probs(i+1)
			r = i;
		end
	end

end


function gene = cross_over(animals, p, q, r)

	gene_q = animals(q).gene;
	gene_r = animals(r).gene;

	for i = 1:length(gene_q)
		die = rand;
		if die < 0.4
			gene(i) = gene_q(i);
		end
		if die > 0.6
			gene(i) = gene_r(i);
		end
		if die > 0.4 && die < 0.6
			top = max(gene_q(i),gene_r(i));
			bot = min(gene_q(i),gene_r(i));
			options = bot:p.min_step_size(i):top;
			gene(i) = options(randi(length(options)));
		end
	end
end
