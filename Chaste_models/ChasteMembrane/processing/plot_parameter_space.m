% This script takes the completed parameter sets from grid_search
% and produces various 2D plots of the 4D parameter space, colouring
% the plot by the objective function

% n = 20:2:36;
% ees = 25:25:250;
% ms = 50:50:800;
% vf = 0.6:0.05:0.95;

n = 24:28;
ees = 25:5:100;
ms = 150:5:250;
vf = 0.68:0.01:0.82;

N = length(n);
E = length(ees);
M = length(ms);
V = length(vf);


cct = 5;

file_path = '/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/';

pspace = nan(E,M,N,V);

[total_count, slough, anoikis, prolif, differ, total_end] = get_data('/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/parameter_statistics_n_26_EES_50_MS_200_VF_75_CCT_5.txt');
objective_function(total_count, slough, anoikis, prolif, differ, total_end)

for k = 1:E
	for l = 1:M
		for j = 1:N
			for m = 1:V
				if ees(k) < ms(l)
					file_name = sprintf('%sparameter_statistics_n_%d_EES_%d_MS_%d_VF_%g_CCT_%d.txt',file_path, n(j), ees(k), ms(l), 100 * vf(m), cct);
					[total_count, slough, anoikis, prolif, differ, total_end] = get_data(file_name);
					pspace(k,l,j,m) = objective_function(total_count, slough, anoikis, prolif, differ, total_end);
                    if strcmp(file_name,'/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/parameter_statistics_n_26_EES_50_MS_200_VF_75_CCT_5.txt')
                        fprintf('%d,%d,%d,%d\n',k,l,j,m);
                    end
				end
			end
		end
	end
end

for j = 1:N
	for m = 1:V
		% Plot each slice of parameter space
		h = figure;
		imagesc(flipud(pspace(:,:,j,m)),'AlphaData',~isnan(flipud(pspace(:,:,j,m))), [0,50]);
		set(gca, 'YTick', 2:2:E);
		set(gca, 'YTickLabel', floor(fliplr(linspace(ees(1), ees(end), 8))));
		set(gca, 'XTick', 4:4:20);
		set(gca, 'XTickLabel', 150:25:250);
		colorbar
		heading = {'Objective function value for', sprintf('$n=$%d, $vf=$%g and G1 phase length = 5',n(j), vf(m))};
		title(heading, 'Interpreter', 'latex');
		xlabel('Adhesion stiffness', 'Interpreter', 'latex');
		ylabel('Epithelial stiffness', 'Interpreter', 'latex');

		set(h,'Units','Inches');
	    pos = get(h,'Position');
	    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
	    
	    print(['/Users/phillipbrown/Research/Crypt/Images/ObjectiveFunction/MouseColonDesc/ObjectiveFunction_N_' num2str(n(j)) '_VF_' num2str(100 * vf(m)), '_CCT_' num2str(cct)],'-dpdf');

		close(h);
	end
end


function [total_count, slough, anoikis, prolif, differ, total_end] = get_data(file_name)
	try
		data = csvread(file_name,1,0);
        total_count = data(1);
        slough = data(2);
        anoikis = data(3);
        prolif = data(4);
        differ = data(5);
        total_end = data(6);
    catch
    	% Dumb error catching - shuold make it run the simulation, but can't be bothered waiting just now
    	total_count = nan;
        slough = nan;
        anoikis = nan;
        prolif = nan;
        differ = nan;
        total_end = nan;
    end
end



function obj = objective_function(total_count, slough, anoikis, prolif, differ, total_end)

    obj =  penalty(anoikis,0,4,1) + penalty(total_end,31,35,1) + penalty(prolif,20,24,1) + penalty(anoikis + slough,85,95,1);


end

function pen = penalty(value, min, max, ramp)
    % If value is between min and max, penalty is 0
    % Otherwise it ramps up like a polynomial of order ramp

    pen = nan;
    
    if (value <= max && value >= min)
        pen = 0;
    end
    
    if value > max
        
        pen = abs(value - max) ^ ramp;
    end
    
    if value < min
        
        pen = abs(min - value) ^ ramp;
    end
    
    if pen < 0
        fprintf('Fucked up\n')
    end
    
end
