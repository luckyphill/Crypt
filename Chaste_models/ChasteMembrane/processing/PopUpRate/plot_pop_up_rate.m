% This script takes the results of the long term parameter space pop up limit search
% and plots them
% It assumes that the paramters fall in the arrays below:

% n = [25,26,27];
% ees = 35:5:85;
% cct = 5;
% vf = 0.71:0.01:0.77;

function plot_pop_up_rate(n, vf)

ees = 35:5:85;
ms = 154:2:392;

% n = 25;
% vf = 0.77;
cct = 5;

E = length(ees);
M = length(ms);

pop_up_count = zeros(M,E);

path2files = '/Users/phillipbrown/Research/Crypt/Data/Chaste/PopUpRate/';

runs = 4; % Each parameter set had 4 successful runs before timing out

for i = 1:M
	for j = 1:E
		for r = 1:runs

			try
				file = sprintf('pop_up_count_n_%d_EES_%d_MS_%d_VF_%d_CCT_%d_run_%d.txt', n, ees(j), ms(i), 100*vf, cct, r);
				data = csvread([path2files, file]);
				pop_up_count(i,j) = pop_up_count(i,j) + data;
			catch
				pop_up_count(i,j) = nan;
			end

		end
	end
end

imagesc(flipud(pop_up_count),'AlphaData',~isnan(flipud(pop_up_count)));
set(gca, 'XTick', 1:11);
set(gca, 'XTickLabel', 35:5:85);
set(gca, 'YTick', 0:12:120);
set(gca, 'YTickLabel', fliplr(154:24:392));
colorbar


end

