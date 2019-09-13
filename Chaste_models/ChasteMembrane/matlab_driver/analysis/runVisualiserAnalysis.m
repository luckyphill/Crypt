function runVisualiserAnalysis(crypt, Mnp,eesM,msM,cctM,wtM,Mvf, run_number)

	% crypt is a number between 1 and 9 specifying the crypt type
	simParams = containers.Map({'crypt'}, {crypt});
	%   visualiserAnalysis(simParams,Mnp,eesM,msM,cctM,wtM,Mvf,t,bt,sm,run_number)
	v = visualiserAnalysis(simParams,Mnp,eesM,msM,cctM,wtM,Mvf,6000,100,1000,run_number);

end