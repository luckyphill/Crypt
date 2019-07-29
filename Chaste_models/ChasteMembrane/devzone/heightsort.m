


dataFile = '/Users/phillipbrown/testoutput/TestCryptColumnMutation/n_29_np_12_EES_58_MS_216_CCT_15_WT_9_VF_0.675/mpos_1_Mnp_15_eesM_1_msM_1_cctM_1_wtM_1_Mvf_0.675/run_1/results_from_time_100/results.viznodes';

data = dlmread(dataFile);

times = data(:,1);

steps = -0.5:(29 + 0.5);

i = 1;
for i=1:length(data)
    clear sortedbypos;
    nz = find(data(i,:), 1, 'last');
    x = data(i,2:2:nz);
    y = data(i,3:2:nz);
    sortedbypos{length(steps)-1} = [];
    for j = 1:length(x)
        for k=2:length(steps)
            if steps(k) > y(j) && y(j) > steps(k-1)
                sortedbypos{k-1}(end + 1) = x(j);
            end
        end
    end
    
    for j = 1:length(sortedbypos)
        if isempty(sortedbypos{j})
            h_min(j) = nan;
            h_max(j) = nan;
            h_mean(j) = nan;
        else
            h_min(j) = min(sortedbypos{j});
            h_max(j) = max(sortedbypos{j});
            h_mean(j) = mean(sortedbypos{j});
        end
    end
    
    h_min_t(i,:) = h_min;
    h_max_t(i,:) = h_max;
    h_mean_t(i,:) = h_mean;
                
end

h_max_mean = nanmean(h_max_t);
figure;
plot(h_max_mean);

