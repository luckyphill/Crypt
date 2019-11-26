function runClearingAnalysis(crypt, mutation, mrange)

	mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf'}, {12,1,1,1,1,0.675});


	
	for j = 1:length(mrange)
		total_times = 0;
		total_empty = 0;
		for i = 1:length(mutation)
			mutantParams(mutation{i}) = mrange(j);
		end
		for i = 1:10
			c = clearingAnalysis(crypt,mutantParams,6000,100,1000,i);
			total_times = total_times + length(c.times);
			total_empty = total_empty + sum(c.empty_interval_sizes);
		end

		ratio(j) = total_empty/total_times;

	end

	h = figure();
	plot(mrange,ratio, 'LineWidth', 4);
	xlim([min(mrange) max(mrange)]);
	ylim([0 1]);
	xlabel('Mutation factor')
	ylabel('Proportion')
	ptitle = {'Proportion of time crypt is clear of serrations with mutation:'};
	ftitle = '';
	for i = 1:length(mutation)
		ptitle{end + 2} = mutation{i};
		ftitle = [ftitle, '_', mutation{i}];
	end
	title(ptitle);

	set(h,'Units','Inches');
	pos = get(h,'Position');
	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
	
	print([getenv('HOME'), '/Research/Crypt/Images/ClearingAnalysis/clear_proportion_',c.simul.cryptName, ftitle],'-dpdf');

end