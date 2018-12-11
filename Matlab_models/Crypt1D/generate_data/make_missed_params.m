close all;
clear all;

stiffness = 1:40;

m = length(stiffness);

vol_frac = 5:5:100;

n = length(vol_frac);

wait_time = 0:12;

o  = length(wait_time);


fid = fopen('sweep_remaining.txt','w');

for i = 1:m
    for j = 1:n
        for k = 1:o
            str = sprintf('CI_sweep/power_run_%d_%d_%d.mat',stiffness(i),vol_frac(j),wait_time(k));

            if ~exist(str, 'file')
                str2 = sprintf('%d,%d,%d\n', stiffness(i), vol_frac(j),wait_time(k));
                fprintf(fid,str2);
            end
        end
    end
end

 