% This script processes the data from the slurm output files for the 
% mouse desc colon multi-run parameter search
% There was an error in TestCryptCrossSection that didn't name the files properly
% so the properly formatted output file was overwritten for each run
% Thankfully the data is still contained in the temporary output files.

directory = '/Users/phillipbrown/Research/Crypt/Data/Chaste/slurm/';
param_files = dir(directory);

for i = 3:length(param_files)
    
    try   
    	file_name = [directory, param_files(i).name];
    	fprintf('Trying %s\n', file_name);
    	process_slurm_data(file_name);
    end
        
end


function process_slurm_data(file_name)
	% Matches the slurm id to the crypt type
	temp = strsplit(file_name, '-');
	temp = strsplit(temp{2}, '_');
	type_num = temp{1};

	switch type_num
		case '16231865'
			crypt = 'HumanColon';
		case '16231886'
			crypt = 'MouseColonAsc';
		case '16231924'
			crypt = 'MouseColonTrans';
		case '16333243'
			crypt = 'MouseColonDesc';
		case '16231925'
			crypt = 'MouseColonCaecum';
		case '16231942'
			crypt = 'RatColonAsc';
		case '16445404'
			crypt = 'RatColonTrans';
		case '16231931'
			crypt = 'RatColonDesc';
		case '16374204'
			crypt = 'RatColonCaecum';
		otherwise
			error('Type not found');
	end

	fprintf('Getting data for %s\n', crypt);
    % Extracts the data from the output
    % of the simulation
    fid = fopen(file_name,'r');
    data = textscan(fid,'%s','delimiter', '\n');
    fclose(fid);
    data = data{1};
    temp = data{2};

    % The second line contains the parameter set
    temp = strsplit(temp,':');
    temp = temp{2};

    temp = strrep(temp,' -', '_');
    temp = strrep(temp,' ', '_');

    output_file_name = ['parameter_search', temp, '_run_1.txt'];

    anoikis_line = data{25};
    anoikis_line = strsplit(anoikis_line, ' = ');
    anoikis = str2num(anoikis_line{end});
    
    count_line = data{26};
    count_line = strsplit(count_line, ' = ');
    count = str2num(count_line{end});
    
    birth_line = data{27};
    birth_line = strsplit(birth_line, ' = ');
    birth = str2num(birth_line{end});
    
    pos_line = data{28};
    pos_line = strsplit(pos_line, ' = ');
    pos = str2num(pos_line{end});

    results = [anoikis; count; birth; pos];
    
    directory = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/ParameterOptimisation/TestCryptColumn/', crypt, '/'];
    output_file = [directory, output_file_name];
    
    csvwrite(output_file, results);
    fprintf('Done\n');

end
