close all;
clear all;

stiffness = 10:12;

vol_frac = 80:5:100;

wait_time = 0:3;

all = [];

for i = 1:100
    
    str = sprintf('CI_sweep/run_10_80_0_%d',i);
    load(str)
%     figure
%     histogram(p.labelling_index,15)
    
    all = [all p.labelling_index];
end
 
histogram(all,15)