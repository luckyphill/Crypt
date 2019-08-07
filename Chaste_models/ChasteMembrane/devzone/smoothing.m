runs = [0,1,2,3,4,5,6,7,9,10];


hmax = nan(11, 8000);
hmin = nan(11, 8000);
hmean = nan(11, 8000);

for i=1:length(runs)
    
    [hmaxt,hmint,hmeant,h_max_mean(i),h_min_mean(i),h_mean_mean(i)] = heightsort(runs(i));
    j = length(hmaxt);
    hmax(i,1:j) = hmaxt;
    j = length(hmint);
    hmin(i,1:j) = hmint;
    j = length(hmeant);
    hmean(i,1:j) = hmeant;
end

figure
hold on
hmaxmean = mean((hmax(1:10,1:4067)));
plot(hmaxmean)
hminmean = mean((hmin(1:10,1:4067)));
plot(hminmean)
hmeanmean = mean((hmean(1:10,1:4067)));
plot(hmeanmean)

ylim([0 8])
plot(1:4000,mean(hmaxmean) * ones(size(1:4000)));
plot(1:4000,mean(hminmean) * ones(size(1:4000)));
plot(1:4000,mean(hmeanmean) * ones(size(1:4000)));
legend(num2str(mean(hmaxmean)), num2str(mean(hminmean)) ,num2str(mean(hmeanmean)))


std(h_max_mean)
std(h_min_mean)
std(h_mean_mean)
