
function viewFillingAnalysis(Mnp,eesM,msM,cctM,wtM,Mvf)

	simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {29, 12, 58, 216, 15, 9, 0.675});

	f = fillingAnalysis(simParams,1,Mnp,eesM,msM,cctM,wtM,Mvf,4000,0.001,100,100,1);

	f.levelsOverTime();

end