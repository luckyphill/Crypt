function stack_height(param, p_range)
	simParams = containers.Map({'crypt'}, {1});
	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf'}, {12,1,1,1,1,0.675});

	runs = 10;

	max_run = nan(runs,1);
	g = figure;
	ga = axes;
	hold on
	leg = {};
	for i = 1:length(p_range)

		for k=1:length(param)
			% Will have to pass in the mutaiton string in a cell array
			% This is useful for when two parameters are varied together
			% in the same way, as cctM and wtM are (to scale the cell cycle model)
			mutantParams(param{k}) = p_range(i);
		end
		h = heightAnalysis(simParams,mutantParams,6000,100,1000,1);
		h.heightOverTime();

		plot(ga,1:length(h.h_max_mean), h.h_max_mean, 'lineWidth', 4);
		leg{end+1} = num2str(p_range(i));
		
	end


	legend(ga,leg);
	xlabel('Position from stem cell niche')
	ylabel('Time average height above BM')
	plot_title = 'Time average thickness for mutation:' ;
    for i = 1:length(param)
        plot_title = [plot_title, ' ', param{i}];
    end
	title(plot_title);
	ylim([0.6 4])
	set(g,'Units','Inches');
	pos = get(g,'Position');
	set(g,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
	
	name = 'StackHeight';
	for i = 1:length(param)
        name = [name, '_', param{i}];
    end
	print(name,'-dpdf');
	
end
