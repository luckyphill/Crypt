function plot_loop(e, m, p)


	% This function looks at the file sweep.txt for each crypt type and loops through
	% each parameter set, creating the ms vs ees parameter space plot

	sweep_file = [p.base_path, 'Research/Crypt/Chaste_models/ChasteMembrane/phoenix/ParameterOptimisation/', p.chaste_test, '/', func2str(p.obj), '/sweep.txt'];

	data = csvread(sweep_file);
	data(122,:)

	for i=1:length(data)
		p.input_values(1) = data(i,1);
		p.input_values(2) = data(i,2);
		p.input_values(3) = e(7); % purely for title generation
		p.input_values(4) = m(7);
		p.input_values(5) = data(i,3);
		p.input_values(6) = data(i,4);
		p.input_values(7) = data(i,5);

		plot_stiffness_space(e, m, p);
		fprintf('Done line %d\n', i);
	end


end