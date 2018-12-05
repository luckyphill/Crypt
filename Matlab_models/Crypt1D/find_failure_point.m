

% Running a bunch of simulations to see when the failures stop
stiffness = 2:2:40;
vol_frac = 5:5:100;

runs = 20;

successes = runs * ones(length(stiffness), length(vol_frac));
num = 2;
t_end = 100;

for i = 1:length(stiffness)
	for j = 1:length(vol_frac)

		fprintf('Testing %d, %d\n',stiffness(i), vol_frac(j));
		for k = 1:runs
			tic;
			fprintf('Started run number %4d\n',k);
			try
				run_crypt(stiffness(i),vol_frac(j),t_end);
				fprintf('Completed run number %4d, taking %.2fs\n',k,toc);
			catch
				successes(i,j) = successes(i,j)-1;
				fprintf('FAILURE run number %4d, taking %.2fs\n',k,toc);
			end
			
		end
		if  j > num && prod(successes(i,(j-num):j) == 20) == 1
			%Three in a row were successful, so break
			break;
		end
	end
end

h = figure()
h.Position = [1 1 936 737];
imagesc(successes)

ylabel('Stiffness', 'FontSize', 22, 'Interpreter','latex')
xlabel('CI Threshold', 'FontSize', 22, 'Interpreter','latex')
title('Number of physically correct simulations', 'FontSize', 22, 'Interpreter','latex')
xticklabels({'0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7', '0.8', '0.9', '1.0'});
yticklabels({'4', '8', '12', '16', '20', '24', '28', '32', '36', '40'});
h.PaperSize = [40,30];
colorbar
saveas(gcf,'/Users/phillipbrown/Box Sync/Phill Brown/proportion_successful_short.pdf')


