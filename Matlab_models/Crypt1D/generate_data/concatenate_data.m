% Used on phoenix to concatenate all the labelling index data between runs
% of the same parameter sets

clear all;
stiffness = 31:40;

vol_frac = .05:.05:1;

runs = 400;

for i = 1:length(stiffness)
    for j = 1:length(vol_frac)
        all_li = [];
        fprintf('Grabbing %d %g data\n', stiffness(i), vol_frac(j));
        for n = 1:runs
            path_to_file = sprintf('/fast/users/a1738927/Chaste/testoutput/TestCrypt1DWithEndCI/n_20_EES_%d_VF_%g_run_%d/results_from_time_0/divisions.dat',stiffness(i), vol_frac(j), n);
            % path_to_file = sprintf('/tmp/phillipbrown/testoutput/TestCrypt1DWithEndCI/n_20_EES_%d_VF_%g_run_%d/results_from_time_0/divisions.dat',stiffness(i), vol_frac(j), n);
            
            disp(path_to_file);
            try
                data = dlmread(path_to_file,'\t');
                all_li = [all_li data(:,3)'];
                fprintf('Got run %d\n',n);
            catch
                fprintf('Run %d hasnt happened yet\n',n);
            end
        end
        path_to_output = sprintf('/fast/users/a1738927/Chaste/projects/ChasteMembrane/divisions/EES_%d_VF_%d.dat',stiffness(i), vol_frac(j)*100);
        % path_to_output = sprintf('/Users/phillipbrown/Documents/MATLAB/Crypt model/divisions/EES_%d_VF_%d.dat',stiffness(i), vol_frac(j)*100);
        csvwrite(path_to_output,all_li);
        fprintf('File written EES_%d_VF_%d.dat\n',stiffness(i), int16(vol_frac(j)*100)); 
    end
end

