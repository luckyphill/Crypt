
function [counts, edges, hours, pops] = viewPopUpIndex(crypt, keys, values, runs)

	simParams = containers.Map({'crypt'}, {crypt});

	cryptName = getCryptName(crypt);

	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf','name'}, {12,1,1,1,1,0.675,'no mutation'});

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
		sims = sims + 1;
		hours = hours + f.simul.outputTypes{1}.finalTimeStep;
	end

	edges = 0:19;
	h = figure('visible','off');
	histogram(data,edges, 'Normalization','probability');

	counts = histcounts(data,edges);

	pops = length(data);

	ylim([0 .15]);
	plot_title = sprintf('Pop up index:');
	for i = 1:length(keys)
		plot_title = [plot_title, sprintf(' %s = %g', keys{i}, values{i})];
	end

	plot_title = {plot_title; sprintf('%d events over %.0f hours split between %d simulations', pops, hours, sims)};
	title(plot_title);

	set(h,'Units','Inches');
	pos = get(h,'Position');
	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

	imageLocation = [getenv('HOME'), '/Research/Crypt/Images/PopUpIndex/', cryptName '/'];

	if exist(imageLocation,'dir')~=7
		mkdir(imageLocation);
	end

	imageFile = [imageLocation, 'popup_index'];

	for i = 1:length(keys)
		imageFile = [imageFile, sprintf('_%s_%g', keys{i}, values{i})];
	end
	
	print(imageFile,'-dpdf');
	close(h)

end


