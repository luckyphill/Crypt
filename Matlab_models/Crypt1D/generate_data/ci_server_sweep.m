function ci_server_sweep(stiffness, vol_frac, runs)

% Runs crypt_1D for a given stiffness, volume fraction that triggers
% contact inhibition, and wait time before checking compression. It outputs
% only the data structure and not the positions over time, reducing run
% time by a factor of 20. The last option run records the run number i.e.
% the number counting how many times a particular set has been run so far

p.ci = true;

p.ci_type = 3;

p.t_end = 100;


p.k = stiffness;

p.ci_fraction = vol_frac/100;

p.limit = 100;

p.dt = 0.001;

p.division_spring_length = 0.05;

p.division_separation = 0.05;

p.write = false;

fprintf('Testing %d, %d\n',stiffness, vol_frac);

all_li = [];
all_lp = [];

output_file_mat = ['CI_sweep/power_run_' num2str(stiffness) '_' num2str(vol_frac)];
output_file_li_csv = ['CI_sweep/power_run_li_' num2str(stiffness) '_' num2str(vol_frac) '.csv'];
% output_file_lp_csv = ['CI_sweep/power_run_lp_' num2str(stiffness) '_' num2str(vol_frac) '_' num2str(wait_time) '.csv'];
% save(output_file_mat,'all_li','all_lp','runs','p');

for r = 1:runs
    tic;
    try
	    out = crypt_1D(p);
	    
	    all_li = [all_li out.labelling_index];
	%     all_lp = [all_lp out.labelling_position];
	    
	    dlmwrite(output_file_li_csv,out.labelling_index,'-append');
	%     dlmwrite(output_file_lp_csv,out.labelling_position,'-append');
	    
	    fprintf('Completed run number %4d, taking %.2fs\n',r,toc);
	catch
		fprintf('Run number %4d failed after %.2fs\n',r,toc);
	end
end

save(output_file_mat,'all_li','all_lp','runs','p');

end