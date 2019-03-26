file = '/tmp/phillipbrown/testoutput/TestCryptAlternatePhaseLengths/n_26_EES_50_VF_0.75_MS_200_CCT_15_run_2/results_from_time_0/cell_force.txt';
data = csvread(file);
n = length(data(1,:));
data2 = data(:,2:n);
time = data(:,1);
dataID = data2(:,1:5:(n-1));
dataY = data2(:,3:5:(n-1));
dataX = data2(:,2:5:(n-1));
IDS = (1:40)';

% When doing the equality, matlab treats matrices as vectors, where
% each column from 1:end is concatentated to the end of the previous
% column. This is done after the Y positions are found, meaning the 
% Y position are stored in reverese order
% TO fix this, transpose the matrix
dataYT = dataY';

figure
hold on;
for i = 1:length(IDS)
    
    plot(time(sum(dataID == IDS(i),2) == 1), dataYT(dataID' == IDS(i)));
end

xlim([0,100]);