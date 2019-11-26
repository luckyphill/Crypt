
function f = viewHeightAnalysis(keys, values, run_number)

	simParams = containers.Map({'crypt'}, {1});

	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {12,1,1,1,1,0.675,'no mutation'});
	name = '';
	for i=1:length(keys)
		mutantParams(keys{i}) = values{i};
		name = [name, sprintf(' %s %g', keys{i},values{i}) ];
	end
	mutantParams('name') = name;


	f = heightAnalysis(simParams,mutantParams,6000,100,1000,run_number);

	f.heightOverTime();

	f.plotHeightOverTime();
	
end