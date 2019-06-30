function data = get_data_from_output(cmdout, data_file)
	% Extracts data from the command line output, and saves it to file
	try
		temp1 = strsplit(cmdout, 'START');
		temp1 = strsplit(temp1{2}, 'END');
		temp2 = strsplit(temp1{1}, 'DEBUG: ');
	catch
		% save cmdout for debugging
		fid = fopen(data_file,'w');
		fprintf(fid, cmdout);
		fclose(fid);
		error('Output does not match expected format, dumping console output')
	end

	data = [];
	for i = 2:length(temp2)-1
		temp3 = strsplit(temp2{i}, ' = ');
		try
			data = [data; str2num(temp3{2})];
		catch
			% save cmdout for debugging
			fid = fopen(data_file,'w');
			fprintf(fid, temp2);
			fclose(fid);
			error(['Problem reading output intended for ', data_file, ' dumping simulation output'])
		end
	end

	csvwrite(data_file, data);

end