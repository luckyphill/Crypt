fid = fopen('sweep.txt','w');
stiffness = 2:2:40;

vol_frac = 5:5:100;

wait_time = 0;

for i = 1:length(stiffness)
    p.k = stiffness(i);
    for j = 1:length(vol_frac)
        p.ci_fraction = vol_frac(j)/100;
        for k = 1:length(wait_time)
            
            p.ci_pause_time = wait_time(k);
            str = sprintf('%d,%.2f\n', stiffness(i), vol_frac(j));
            fprintf(fid,str);
            
        end
    end
end

