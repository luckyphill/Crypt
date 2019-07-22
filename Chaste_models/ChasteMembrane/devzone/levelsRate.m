
dataFile = '/Users/phillipbrown/testoutput/TestCryptColumnMutation/n_29_np_12_EES_58_MS_216_CCT_15_WT_9_VF_0.675/mpos_1_Mnp_15_eesM_1_msM_1_cctM_1_wtM_1_Mvf_0.675/run_1/results_from_time_100/results.viznodes';

data = dlmread(dataFile);

times = data(:,1);
s = sqrt(3)/2;
s2 = s/2;

levelRanges = zeros(10,1);
for i = 1:15
    levelRanges(i) = [0.6 - s2 + s*(i-1)];
end

counts = [];
for i=1:length(data)
    x = data(i,2:2:end);
    counts = [counts; histcounts(x,levelRanges)];
end

close all
figure
hold on
for i = 2:14
    if ~all(counts(:,i))
        plot(times, counts(:,i))
    end
end

