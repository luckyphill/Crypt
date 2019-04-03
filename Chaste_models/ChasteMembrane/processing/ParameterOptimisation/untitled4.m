clear all;
close all;

file_name = '/tmp/phillipbrown/testoutput/TestCryptColumn/n_26_np_14_EES_100_MS_328_CCT_15_VF_0.8_run_256/results_from_time_40/cellcyclephases.txt';

data = csvread(file_name);

total = data(:,5);

plot(total)
hold on

for i = 1:length(total)
    v(i) = var(total(1:i));
    avg(i) = mean(total(1:i));
end

plot(avg)

plot(avg - v.^0.5)
plot(avg + v.^0.5)

