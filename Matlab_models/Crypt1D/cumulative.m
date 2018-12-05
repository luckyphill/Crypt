close all;
clear all;

stiffness = 40;
vol_frac = 30;
wait_time = 0;

str = sprintf('CI_sweep/power_run_%d_%d_%d.mat',stiffness,vol_frac,wait_time);
str2 = sprintf('CI_sweep/power_run_li_%d_%d_%d.csv',stiffness,vol_frac,wait_time);

load(str);

test = all_li;
nbins = 10;
l = 15;
xsteps = 100;
dx = 15/xsteps;
x = linspace(0,l,xsteps);
normaliser = length(test);
for i =1:xsteps
    cum_li(i) = length(test(test<x(i)))/normaliser;
end
hold on
%plot(x,cum_li,'k');
dj = 6;
j = 1:dj:xsteps-dj;
d_cum = (cum_li(j+dj)-cum_li(j))/(dx*dj);
plot(x(j),d_cum,'r');

points = 32;

[bandwidth,density,xmesh,cdf]=kde(test,points,0,15);
plot(xmesh,density,'k');
%plot(xmesh,cdf,'-');


histogram(test,nbins,'Normalization','probability')


% 
% all_li = csvread(str2);
% 
% [mm,nn]=size(all_li);
% for i = 1:mm
%     test = all_li(1:i,:);
%     [bandwidth,density_2,xmesh,cdf]=kde(test(test>0),points,0,15);
%     error(i) = norm(density-density_2);
% end
% figure
% plot(error)





