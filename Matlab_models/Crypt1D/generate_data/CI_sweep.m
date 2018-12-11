close all;
clear all;

stiffness = 10:12;

vol_frac = 80:5:100;

wait_time = 0:3;

p.ci = true;

p.ci_type = 2;

for i = 1:length(stiffness)
    p.k = stiffness(i);
    for j = 1:length(vol_frac)
        p.ci_fraction = vol_frac(j)/100;
        for k = 1:length(wait_time)
            p.ci_pause_time = wait_time(k);
            
            p.output_file = ['CI_sweep/run_' num2str(stiffness(i)) '_' num2str(vol_frac(j)) '_' num2str(wait_time(k))];
            
            out = crypt_1D(p);
            
            disp(wait_time(k));
            
        end
    end
end
