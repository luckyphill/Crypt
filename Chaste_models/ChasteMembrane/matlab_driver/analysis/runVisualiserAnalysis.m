function runVisualiserAnalysis(crypt, Mnp,eesM,msM,cctM,wtM,Mvf, run_number)


	switch crypt
		case 'MouseColonDesc'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});
		case 'MouseColonTrans'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {37, 12, 100, 200, 21, 11, 0.9,'MouseColonTrans'});
		case 'MouseColonAsc'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {19, 8, 50, 200, 19, 8, 0.85,'MouseColonAsc'});
		case 'MouseColonCaecum'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {24, 8, 100, 200, 15.5, 7.5, 0.6125,'MouseColonCaecum'});
		case 'RatColonDesc'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {42, 28, 100, 134, 57, 9, 0.7,'RatColonDesc'});
		case 'RatColonTrans'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {36, 20, 50, 208, 42, 9, 0.6,'RatColonTrans'});
		case 'RatColonAsc'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {32, 16, 68, 200, 39, 13, 0.65,'RatColonAsc'});
		case 'RatColonCaecum'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {33, 12, 58, 392, 25, 8, 0.8,'RatColonCaecum'});
		case 'HumanColon'
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {60, 56, 50, 150, 26, 7.5, 0.8,'HumanColon'});
		otherwise
			error('crypt type not found');
	end

	%   visualiserAnalysis(simParams,mpos,Mnp,eesM,msM,cctM,wtM,Mvf,t,dt,bt,sm,run_number)
	v = visualiserAnalysis(simParams,1,Mnp,eesM,msM,cctM,wtM,Mvf,8000,0.001,100,1000,run_number);

end