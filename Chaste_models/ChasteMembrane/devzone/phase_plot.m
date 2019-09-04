function phase_plot(param, p_range, name)
    simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf','name'}, {29, 12, 58, 216, 15, 9, 0.675,'MouseColonDesc'});
    mutantParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {1,12,1,1,1,1,0.675});

    runs = 10;

    max_run = nan(runs,1);
    min_run = nan(runs,1);
    mean_run = nan(runs,1);
    for i = 1:length(p_range)

        for k=1:length(param)
            % Will have to pass in the mutaiton string in a cell array
            % This is useful for when two parameters are varied together
            % in the same way, as cctM and wtM are (to scale the cell cycle model)
            mutantParams(param{k}) = p_range(i);
        end

        for j = 1:runs
            fprintf('Mutation %d, %f, %f, %f, %f, %f run %d\n',mutantParams('Mnp'),mutantParams('eesM'),mutantParams('msM'),mutantParams('cctM'),mutantParams('wtM'),mutantParams('Mvf'),j);	

            % load each simulation, get the averages, collate over parameter range
            h = heightAnalysis(simParams,mutantParams,6000,0.0005,100,100,j);
            try
                h.heightOverTime();

                if length(h.h_crypt_max_t) > 4000
                    max_run(j) = h.mean_h_max;
                    min_run(j) = h.mean_h_min;
                    mean_run(j) = h.mean_h_mean;
                end
            end
        end
        
        r_max(i) = nanmean(max_run);
        r_min(i) = nanmean(min_run);
        r_mean(i) = nanmean(mean_run);
    end
    
    plot_pics(r_max,r_mean,r_min,p_range,name)
    
end
    
function plot_pics(r_max,r_mean,r_min,p_range,name)
    

    g = figure;
    plot(p_range,r_max, p_range,r_min, p_range,r_mean,'LineWidth' , 4)
    title(name)
    ylim([0.5 5])
    set(g,'Units','Inches');
    pos = get(g,'Position');
    set(g,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(name,'-dpdf');

end