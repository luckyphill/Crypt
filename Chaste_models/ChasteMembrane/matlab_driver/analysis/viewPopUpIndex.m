
function [counts, edges, hours, pops] = viewPopUpIndex(keys, values, runs)

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
		hours = hours + f.simul.outputTypes{1}.finalPopUp;
	end

	edges = 0:19;
	h = figure('visible','off');
	histogram(data,edges, 'Normalization','probability');

	counts = histcounts(data,edges);

	pops = length(data);

	ylim([0 .12]);
	plot_title = sprintf('Pop up index:');
	for i = 1:length(keys)
		plot_title = [plot_title, sprintf(' %s = %g', keys{i}, values{i})];
	end

	plot_title = {plot_title; sprintf('%d events over %.0f hours split between %d simulations', pops, hours, sims)};
	title(plot_title);

	set(h,'Units','Inches');
	pos = get(h,'Position');
	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

	imageFile = [getenv('HOME'), '/Research/Crypt/Images/PopUpIndex/popup_index'];
	for i = 1:length(keys)
		imageFile = [imageFile, sprintf('_%s_%g', keys{i}, values{i})];
	end
	
	print(imageFile,'-dpdf');
	close(h)

end


