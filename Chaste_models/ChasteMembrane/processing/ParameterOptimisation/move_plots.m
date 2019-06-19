function move_plots(p)



	% for each variable, grab up step and down step, and dump in a folder

	p.input_values(3) = p.input_values(3) + 35;
	p.input_values(4) = p.input_values(4) + 35;
	centre_point = p.input_values;

	vars = [1,2,5,6,7];
	folder = [p.base_path, 'Box Sync/Phill Brown/Images/ParameterSpace/', func2str(p.obj), '/'];

	for i = vars

		location = [folder, p.input_flags{i}, '/'];
		p.input_values = centre_point;
		image_file = generate_image_file_name(p);
		copyfile(image_file, location);

		p.input_values(i) = centre_point(i) + p.step_size(i);
		image_file = generate_image_file_name(p);
		copyfile(image_file, location);

		p.input_values(i) = centre_point(i) - p.step_size(i);
		image_file = generate_image_file_name(p);
		copyfile(image_file, location);

	end




end