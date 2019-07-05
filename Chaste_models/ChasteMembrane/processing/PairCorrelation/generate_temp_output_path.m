function output_path = generate_temp_output_path(p);
	
	% Creates the path to the tmp output location
	% This uses the structure in TestCryptColumnMutation

	% Default values for each input
	n = 20;
	np = 10;
	ees = 20;
	ms = 50;
	cct = 15;
	wt = 10;
	vf = 0.75;

	bt = 40;
	t = 100;
	dt = 0.001;

	mpos = 1;
	
	rdiv = 0;
	rple = 'MAX';
	rcct = 15;
	use_resist = false;

	Mnp = 10;
	eesM = 1;
	msM = 1;
	cctM = 1;
	wtM = 1;
	Mvf = 0.75;

	for i = 1:length(p.static_flags)

		flag = p.static_flags{i};

		switch flag
		 	case 'n'
		 		n = p.static_params(i);
		 	case 'np'
		 		np = p.static_params(i);
		 		Mnp = np;
		 	case 'ees'
		 		ees = p.static_params(i);
		 	case 'ms'
		 		ms = p.static_params(i);
		 	case 'cct'
		 		cct = p.static_params(i);
		 		rcct = cct;
		 	case 'wt'
		 		wt = p.static_params(i);
		 	case 'vf'
		 		vf = p.static_params(i);
		 		Mvf = vf;
		 	case 'bt'
		 		bt = p.static_params(i);
		 	case 't'
		 		t = p.static_params(i);
		 	case 'dt'
		 		dt = p.static_params(i);
		 	case 'sm'
		 		a = 1;
		 	otherwise
		 		error('Unknown flag')
		end
	end

	for i = 1:length(p.input_flags)

		flag = p.input_flags{i};

		switch flag
			case 'Mnp'
		 		Mnp = p.input_values(i);
		 	case 'eesM'
		 		eesM = p.input_values(i);
		 	case 'msM'
		 		msM = p.input_values(i);
		 	case 'cctM'
		 		cctM = p.input_values(i);
		 	case 'wtM'
		 		wtM = p.input_values(i);
		 	case 'Mvf'
		 		Mvf = p.input_values(i);
		 	case 'rdiv'
		 		rdiv = p.input_values(i);
		 		use_resist = true;
		 	case 'rple'
		 		rple = p.input_values(i);
		 	case 'rcct'
		 		rcct = p.input_values(i);
		 	otherwise
		 		error('Unknown flag')	 		
		end
	end


% 	path_start = '/tmp/phillipbrown/testoutput/';
    
    path_start = '/tmp/phillip/testoutput/';

	path_normal = sprintf('n_%d_np_%d_EES_%g_MS_%g_CCT_%g_WT_%g_VF_%g_run_%d/', n, np , ees, ms, cct, wt, vf, p.run_number);

	path_mpos = sprintf('mpos_%d_', mpos);

	output_path = [path_start, p.chaste_test, '/', path_normal, path_mpos];

	if use_resist
		path_resist = sprintf('rdiv_%d_rple_%g_rcct_%g_', rdiv, rple, rcct);
		output_path  = [output_path, path_resist];
	end

	path_mutant = sprintf('Mnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/', Mnp, eesM, msM, cctM, wtM, Mvf);

	path_results = sprintf('results_from_time_%d/',bt);

	output_path =  [output_path, path_mutant, path_results];


end
