function data = get_data_from_output(cmdout, data_file)
	% Extracts data from the command line output, and saves it to file
	try
		temp1 = strsplit(cmdout, 'START');
		temp2 = strsplit(temp1{2}, 'DEBUG: ');
	catch
		error('Output does not match expected format')
	end

	data = [];
	for i = 2:length(temp2)-1
		temp3 = strsplit(temp2{i}, ' = ');
		try
			data = [data; str2num(temp3{2})];
		catch
			temp3
			error(['Problem reading output intended for ' data_file])
		end
	end

	csvwrite(data_file, data);

end