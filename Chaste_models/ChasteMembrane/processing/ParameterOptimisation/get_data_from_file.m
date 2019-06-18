function data = get_data_from_file(data_file)
	% Reads the data from file
	try
		data = csvread(data_file);
	catch
		fprintf('Problem reading file: %s\n',data_file);
		error('Check the file printed above');
	end
end