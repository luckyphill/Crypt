
close all
clear all

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

h_crypt_max_t = max(h_max_t');
h_crypt_min_t = min(h_max_t');
h_crypt_mean_t = nanmean(h_max_t');


figure
hold on
plot(times,h_crypt_max_t)
plot(times,h_crypt_min_t)
plot(times,h_crypt_mean_t)

plot(times,mean(h_crypt_max_t) * ones(size(times)));
plot(times,mean(h_crypt_min_t) * ones(size(times)));
plot(times,mean(h_crypt_mean_t) * ones(size(times)));

figure
l = line(steps(2:end),h_max_t(1,:));
xlim([0 30])
ylim([0 8])
figure
l2 = line(1:14,fabs(1:14,1)/14);
xlim([0 15])
ylim([0 10])
for i = 20000:length(data)
    l.YData = h_max_t(i,:);
    l2.YData = fabs(1:14,i)/14;
    
    drawnow
    pause(0.001)
end

f = fft(h_max_t(:,1:end-1)');
fabs = abs(f);
[~, idx] = sort(fabs,2);
[ff,idx] = max(fabs);
ff2 = max(ff(ff~=ff(:,idx)));

