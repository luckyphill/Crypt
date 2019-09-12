
function runClonalConversion(crypt, mutations, instance)

	% crypt is a number 1 - 9 speifying the type of crypt
	% mutations is a cell array specifying the mutation values for this run
	% they will be in the order mpos,Mnp,eesM,msM,cctM,wtM,Mvf
	%

	simParams 		= containers.Map({'crypt'},{crypt});
	mutantParams 	= containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, mutations);
	solverParams 	= containers.Map({'t', 'bt'}, {1000, 100});
	seedParams 		= containers.Map({'run'}, {instance});

	outputTypes 	= clonalData();



	c = clonalConversion(simParams, mutantParams, solverParams, seedParams, outputTypes);
	c.runConversion();

end

