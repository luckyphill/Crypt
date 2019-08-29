
function f = viewPopUpIndex(keys, values, runs)

	simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});

	mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {1,12,1,1,1,1,0.675,'no mutation'});

	for i=1:length(keys)
		mutantParams(keys{i}) = values{i};
	end

	data = [];
	for i = 1:runs
		h = popuplocationAnalysis(simParams,mutantParams,6000,0.0005,100,100,i);

		try
			h.popupIndex();
			data = [data, h.puLocation];
		end
	end


	histogram(data);

end


