function penalty = get_simulation_output(p)



	data_file = generate_file_name(p);

	penalty = nan;

	try
		data = get_data_from_file(data_file);
	catch
		%fprintf('Problem retrieving data\n');
		penalty = nan;
		return
	end

	penalty = p.obj(data);

end
