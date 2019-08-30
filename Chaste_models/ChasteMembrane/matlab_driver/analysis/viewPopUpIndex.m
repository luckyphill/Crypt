
function data = viewPopUpIndex(keys, values, runs)

	simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});

	mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {1,12,1,1,1,1,0.675,'no mutation'});

	for i=1:length(keys)
		mutantParams(keys{i}) = values{i};
	end

	data = [];
	sims = 0;
	hours = 0;
	for i = 1:runs
		f = popuplocationAnalysis(simParams,mutantParams,6000,0.0005,100,100,i);
		f.popUpIndex();
		data = [data; f.puLocation];
		sims = sims + 1;
		hours = hours + f.simul.outputTypes{1}.finalTimeStep;
	end

	figure();
	histogram(data,0:19, 'Normalization','probability');
	ylim([0 .12]);
	plot_title = sprintf('Pop up index: %s = %g', keys{1}, values{1});
	for i = 2:length(keys)
		plot_title = [plot_title, sprintf(', %s = %g', keys{i}, values{i})];
	end

	plot_title = {plot_title; sprintf('%d events over %.0f hours split between %d simulations', length(data), hours, sims)};
	title(plot_title);

end


