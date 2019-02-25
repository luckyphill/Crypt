% This script processes the data from the slurm output files for the 
% mouse desc colon multi-run parameter search
% There was an error in TestCryptCrossSection that didn't name the files properly
% so the properly formatted output file was overwritten for each run
% Thankfully the data is still contained in the temporary output files.

directory = '/Users/phillip/Research/Crypt/Data/Chaste/ParameterSearch/';
param_files = dir([directory, 'slurm_output/']);

for i = 3:length(param_files)
    
    try   
    	process_slurm_data([directory, 'slurm_output/', param_files(i).name], directory);
    end
        
end


function process_slurm_data(file_name, directory)
    % Extracts the slough, anoikis and total cell numbers from the output
    % of the simulation
    fid = fopen(file_name,'r');
    temp = textscan(fid,'%s','delimiter', '\n');
    data = temp{1};

    % The second line contains the parameter set
    temp = strsplit(data{2},' ');
    n = str2num(temp{4});
    ees = str2num(temp{6});
    ms = str2num(temp{8});
    cct = str2num(temp{10});
    vf = str2num(temp{12});

    
    % loop through each line in the slurm output
    got_simulation = false;
    for i = 3:length(data)
    	% Flag to tell us if we have a run number
    	if (~got_simulation)
    		temp = strsplit(data{i},' ');

	    	if length(temp) > 1 && strcmp(temp{end-1}, '-run')
	    		run_number = str2num(temp{end});
	    		got_simulation = true;
	    	end
	    else
	    	% If we do have a up to date run number
	    	if (strcmp(data{i}, 'DEBUG: Stopped because the number of cells exceeded the limit'))
	    		% Found the start of a simulation
	    		% The previous cell contains the 

	    		% run simulation
	    		got_simulation = false;
	    		% fprintf('Simulation stopped because too many cells: Rerunning\n')
	    		fprintf('/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n %d -ees %d -ms %d -cct %d -vf %g -run %d\n',n, ees, ms, cct, vf, run_number);
	    		% run_simulation(n, ees, ms ,cct, vf, run_number);
	    		i = i + 8;
	    	else
	    		temp = strsplit(data{i}, ' ');
	    		if length(temp) > 1 && strcmp(temp{2}, 'p_sloughing_killer->GetCellKillCount()')
	    			% We've found the data section, so extract it
	    			slough = str2num(temp{end});

	    			temp = strsplit(data{i+1}, ' ');
	    			anoikis = str2num(temp{end});

	    			temp = strsplit(data{i+2}, ' ');
	    			prolif = str2num(temp{end});

	    			temp = strsplit(data{i+3}, ' ');
	    			differ = str2num(temp{end});

	    			temp = strsplit(data{i+4}, ' ');
	    			total_end = str2num(temp{end});

	    			temp = strsplit(data{i+5}, ' ');
	    			total_count = str2num(temp{end});

	    			% Advance to where the next simulation should start
	    			i = i + 8;
	    			got_simulation = false;

	    			output_file = sprintf('parameter_statistics_n_%d_EES_%d_MS_%d_VF_%d_CCT_5_run_%d.txt', n, ees, ms, 100*vf, run_number);

	    			% fid_out = fopen([directory, output_file],'w');
	    			% fprintf(fid_out, 'Total cells, killed sloughing, killed anoikis, final proliferative, final differentiated, final total\n');
	    			% fprintf(fid_out, sprintf('%d, %d, %d, %d, %d, %d', total_count, slough, anoikis, prolif, differ, total_end));
	    			% fclose(fid_out);
	    			% fprintf('Wrote file for: n = %d, EES = %g, MS = %g, VF = %g, CCT = %d Run %d\n', n, ees, ms, vf, cct, run_number);

	    		end
	    	end
	    end
    end

    fclose(fid);

    if run_number < 10
    	for i = (run_number + 1):10
    		% run simulation
    		fprintf('/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n %d -ees %d -ms %d -cct %d -vf %g -run %d\n',n, ees, ms, cct, vf, i);
    		% fprintf('Didnt get up to run, running now %d\n', i)
    		% run_simulation(n, ees, ms ,cct, vf, i)
    	end
    end
    

end


function run_simulation(n, ees, ms ,cct, vf, run_number)
    
%         file = sprintf('/Users/phillipbrown/Research/Crypt/Data/Chaste//ParameterSearch/parameter_statistics_n_%d_EES_%d_MS_%d_VF_%d_CCT_5_run_%d.txt', n, ees, ms, 100*vf, run_number);
    file = sprintf('/Users/phillip/Research/Crypt/Data/Chaste/ParameterSearch/parameter_statistics_n_%d_EES_%d_MS_%d_VF_%d_CCT_5_run_%d.txt', n, ees, ms, 100*vf, run_number);
    if exist(file, 'file')
        fprintf('Found existing data: n = %d, EES = %g, MS = %g, VF = %g, CCT = %d Run %d\n', n, ees, ms, vf, cct, run_number);
    else
        fprintf('Running simulation: n = %d, EES = %g, MS = %g, VF = %g, CCT = %d Run %d\n', n, ees, ms, vf, cct, run_number);
%             [status,cmdout] = system(sprintf('/Users/phillipbrown/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n %d -ees %d -ms %d -cct %d -vf %g -run %d\n',n, ees, ms, cct, vf, run_number));
        [status,cmdout] = system(sprintf('/Users/phillip/chaste_build/projects/ChasteMembrane/test/TestCryptCrossSection -n %d -ees %d -ms %d -cct %d -vf %g -run %d\n',n, ees, ms, cct, vf, run_number));
    end

end


