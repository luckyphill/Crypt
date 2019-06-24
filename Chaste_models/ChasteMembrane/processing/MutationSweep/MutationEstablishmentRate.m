function fraction = MutationEstablishmentFraction(p, N)

	% run the simulation N times with different seed values
	% return the percentage of simulations where the

	fraction = 0.0;

	for i = 1:N
		p.run_number = i;
		fraction = fraction + run_simulation(p);
	end

	fraction = fraction / N;

end