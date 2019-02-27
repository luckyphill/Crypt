function plot_parameter_space(n,ees,ms,cct,vf, run_count)

	% This function takes vectors of paramters and produces parameter space plots
	% in a region defined by the vectors. It assumes the data already exists, and
	% does not generate missing data. It expects each parameter set to have been run
	% multiple times (defined by run_count), so it tries to load each run in order.
	% If a run is missing, it ignores it. For each parameter set, the average objective
	% function penalty is calculated, by averaging over each existing run. This means
	% that the parameter sets can (and will) have averages over different numbers
	% of samples

	N = length(n);
	E = length(ees);
	M = length(ms);
	V = length(vf);
	C = length(cct);

	file_path = '/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterSearch/';

	pspace = nan(E,M,N,V,C);

	for k = 1:E
		for l = 1:M
			for j = 1:N
				for m = 1:V
					for i = 1:C
						if ees(k) < ms(l)
							runs = 0;
							obj_sum = 0;
							for r = 1:run_count
								file_name = sprintf('%sparameter_statistics_n_%d_EES_%d_MS_%d_VF_%g_CCT_%d_run_%d.txt',file_path, n(j), ees(k), ms(l), 100 * vf(m), cct(i), r);
								[total_count, slough, anoikis, prolif, differ, total_end] = get_data(file_name);
								obj = objective_function(total_count, slough, anoikis, prolif, differ, total_end);
								if ~isnan(obj)
									runs = runs + 1;
									obj_sum = obj_sum + obj;
								end
							end
							if runs == 10
								pspace(k,l,j,m,i) = obj_sum / runs;
							end
						end
					end
				end
			end
		end
	end

	for j = 1:N
		for m = 1:V
			for i = 1:C
				% Plot each slice of parameter space
				h = figure;
				imagesc(flipud(pspace(:,:,j,m,i)),'AlphaData',~isnan(flipud(pspace(:,:,j,m,i))), [1,40]);
				set(gca, 'YTick', 2:2:E);
				set(gca, 'YTickLabel', floor(fliplr(linspace(ees(1), ees(end-1), 8))));
				set(gca, 'XTick', 1:5:25);
				set(gca, 'XTickLabel', 150:25:250);
				colorbar
				heading = {'Objective function value for', sprintf('$n=$%d, $vf=$%g and G1 phase length = %d',n(j), vf(m), cct(i))};
				title(heading, 'Interpreter', 'latex');
				xlabel('Adhesion stiffness', 'Interpreter', 'latex');
				ylabel('Epithelial stiffness', 'Interpreter', 'latex');

				set(h,'Units','Inches');
			    pos = get(h,'Position');
			    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
			    
			    image_file = sprintf('/Users/phillipbrown/Research/Crypt/Images/ObjectiveFunction/MouseColonDesc/ObjectiveFunction_N_%d_VF_%d_CCT_%d', n(j), 100 * vf(m), cct(i));
			    print(image_file,'-dpdf');

				%close(h);
			end
		end
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
    
    
end
