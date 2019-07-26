function c = prepareClonalConversion(simParams)

	Mnp = simParams('np');
	Mvf = simParams('vf');
	% Set the mutantParams to be the no mutated values. They will be set in the analysis
	mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,Mnp,1,1,1,1,Mvf});
	solverParams = containers.Map({'t', 'bt', 'dt'}, {400, 40, 0.0005});
	seedParams = containers.Map({'run'}, {1});

	outputTypes = clonalData(  containers.Map( {'Sml', 'Scc'}, {1, 1} )  );

	chastePath = [getenv('HOME'), '/'];

	chasteTestOutputLocation = getenv('CHASTE_TEST_OUTPUT');

	c = clonalConversion(simParams, mutantParams, solverParams, seedParams, outputTypes, chastePath, chasteTestOutputLocation);

end