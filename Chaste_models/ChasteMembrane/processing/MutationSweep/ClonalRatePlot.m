function ClonalRatePlot(param, p_range, N)



	% This function runs the clonal rate function for each step of
	% the mutation value and stores it in a vector, then plots this

	l = length(p_range);
	fraction = nan(1,l);
	for i = 1:l
		fraction(i) = ClonalRate_MouseColonDesc(param, p_range(i), N);

	end

	plot(p_range, fraction)


end