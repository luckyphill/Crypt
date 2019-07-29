
function f = viewHeightAnalysis(Mnp,eesM,msM,cctM,wtM,Mvf)

	simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});

	f = heightAnalysis(simParams,1,Mnp,eesM,msM,cctM,wtM,Mvf,4000,0.001,100,100,1);

	f.heightOverTime();

end