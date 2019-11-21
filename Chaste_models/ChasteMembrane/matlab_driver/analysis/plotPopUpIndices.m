function plotPopUpIndices(crypt, keys, values, plot_title)
	% crypt is a number corresponeding to the crypts specified in getCryptName
	% keys is a cell array specifing the mutations applied (as the mutation flags)
	% values is a vector of the mutation factors to show on the plot
	% plot_title will be shown as the title

	
	% The number of simulations to aggregate for one pop up index curve
	num_runs = 10;

	% Set up the plot and axes
	h = figure();
	ha = axes;
	cla(ha)
	hold on
	leg = {};

	% Plot the histogram values as a smooth curve
	for val = values

		figure(h);
		hold on
		[counts, edges, hours, pops] = getPopUpData(crypt, keys, {val}, num_runs);

		% Plot the agregate pop up index for a given mutation value
		% Scale the numbers so that the y axis is pops per hour
		if pops > 100
			plot(ha,edges(2:end),counts./hours, 'LineWidth',3);
			leg{end+1} = num2str(val);
		end

	end

	% Making the plot look good
	legend(ha,leg);

	title(plot_title);
	ylim([0 0.1]);


	% Set up and save the plot
	set(h,'Units','Inches');
	pos = get(h,'Position');
	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
	
	% Get the crypt name
	cryptName = getCryptName(crypt);

	imageLocation = [getenv('HOME'), '/Research/Crypt/Images/PopUpIndex/', cryptName, '/'];
	if exist(imageLocation,'dir')~=7
		mkdir(imageLocation);
	end

	imageFile = [imageLocation, 'popup_index'];
	for i = 1:length(keys)
		imageFile = [imageFile, sprintf('_%s', keys{i})];
	end
	print(imageFile,'-dpdf');
end