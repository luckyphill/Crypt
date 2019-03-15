file_name = '/tmp/phillipbrown/testoutput/TestCryptAlternatePhaseLengths/n_26_EES_50_VF_0.75_MS_240_CCT_15_run_1/results_from_time_0/cell_birth.txt';
data = csvread(file_name);
data2 = data(:,2:end);
data3 = data2(:);
data4 = data3(data3 ~=0);
hist(data4,15);