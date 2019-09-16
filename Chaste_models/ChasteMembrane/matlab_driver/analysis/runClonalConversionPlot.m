
function c = runClonalConversionPlot(crypt, sweep_mutations, sweep_ranges, reps)

	% crypt is a number 1 - 9 speifying the type of crypt
	% mutations is a cell array specifying the mutation values for this run
	% they will be in the order mpos,Mnp,eesM,msM,cctM,wtM,Mvf
	%

	% sweep_mutations is a cell array of mutation flags
	% sweep_ranges is a vector of the values that the mutations take
	% At this stage, the values in sweep_ranges will be used in all mutations
	% this makes the cctM wtM thingo work properly, but it won't neessarily be useful
	% for other mutation combinations. If that is needed, then rewrite clonalConversionPlot

	simParams 		= containers.Map({'crypt'},{crypt});

	c = clonalConversionPlot(simParams, sweep_mutations, sweep_ranges, reps);
	c.plotConversion();

end

