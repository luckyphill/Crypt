function [counts, edges, hours, pops] = getPopUpData(crypt, keys, values, runs)

	simParams = containers.Map({'crypt'}, {crypt});

	params = getCryptParams(crypt);

	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {params(2),1,1,1,1,params(5),'no mutation'});

	for i=1:length(keys)
		% Only works when the value is the same for both keys
		mutantParams(keys{i}) = values{i};
	end

	data = [];
	sims = 0;
	hours = 0;

	for i = 1:runs
		f = popuplocationAnalysis(simParams,mutantParams,6000,100,1000,i);
		f.popUpIndex();
		data = [data; f.puLocation];
		hours = hours + f.simul.outputTypes{1}.finalTimeStep;
	end

	if ~isempty(data)
		highest_pop = ceil(max(data));
		edges = 0:highest_pop;

		counts = histcounts(data,edges);

		pops = length(data);
	else
		edges = 0:20;
		counts = zeros(1,20);
		pops = 0;
	end

end


