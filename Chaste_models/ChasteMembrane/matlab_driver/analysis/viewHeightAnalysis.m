
function f = viewHeightAnalysis(keys, values)

	simParams = containers.Map({'crypt'}, {1});

	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {12,1,1,1,1,0.675,'no mutation'});

	for i=1:length(keys)
		mutantParams(keys{i}) = values{i};
	end

	f = heightAnalysis(simParams,mutantParams,6000,100,1000,1);

	f.heightOverTime();
	
end