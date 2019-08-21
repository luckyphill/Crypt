
function f = viewHeightAnalysis(keys, values)

	simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});

	mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {1,12,1,1,1,1,0.675,'no mutation'});

	for i=1:length(keys)
		mutantParams(keys{i}) = values{i};
	end

	f = heightAnalysis(simParams,mutantParams,8000,0.001,100,100,1);

	f.heightOverTime();
	
end