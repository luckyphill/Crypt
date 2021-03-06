function parameter_collection = mega_dump(p, optimal)
	% This function takes an optimal point (or the nearest that is calculated) and
	% performs a fine grained parameter sweep within a small region around that point
	% with the hope of finding the boundary of optimality

	% It sweeps a different number of points for each parameter about the optimal point found
	% n is limited to 1 either way				total = 3
	% np - 1 either way							total = 3
	% cct - 1 either way						total = 3
	% wt - 1 either way							total = 3
	% vf - 1 either way in steps of 0.02		total = 3

	% create the parameter vectors
	prange = {};
	for i=1:length(p.input_flags)
		if strcmp(p.input_flags{i}, 'n')
			n = optimal(i);
			prange{end + 1} = (n-1):(n+1);
		end
		if strcmp(p.input_flags{i}, 'np')
			np = optimal(i);
			prange{end + 1} = (np-1):(np+1);
		end
		if strcmp(p.input_flags{i}, 'cct')
			cct = optimal(i);
			prange{end + 1} = (cct-1):(cct+1);
		end
		if strcmp(p.input_flags{i}, 'wt')
			wt = optimal(i);
			prange{end + 1} = (wt-1):(wt+1);
		end
		if strcmp(p.input_flags{i}, 'vf')
			vf = optimal(i);
			prange{end + 1} = (vf-0.02):0.02:(vf+0.02);
		end
	end

	N = length(prange);
	n_sets = 1; % the number of parameter sets
	counts = nan(1,N); % used for it2indices - essentially it is a set of conversion rates

	for i = N:-1:1
	    counts(i) = n_sets;
	    n_sets = n_sets * length(prange{i});
	end

	% indices is a completely enumerated list of all possible parameter index combinations
	indices = nan(n_sets,N);

	for i = 1:n_sets
	   
	   % it2indices uses a pretty nifty algorithm to convert the iterator i into a set
	   % indices refencing the position in prange that gives the parameter we want
	   % it avoids trying to code a set of nested for loops to an unknown depth
	   indices(i,:) = it2indices(i, counts);
	    
	end

	% For each parameter set in indices, create a file, create a batch file, run multiple jobs on phoenix

	parameter_collection = [];

	iters = 0;
	for i = 1:n_sets
		index_collection = indices(i,:);

		input_values = [];
		for j = 1:N
			input_values = [input_values, prange{j}(index_collection(j))];
		end

		parameter_collection = [parameter_collection; input_values];

	end


	sweep_path = [p.base_path, 'Research/Crypt/Chaste_models/ChasteMembrane/phoenix/ParameterOptimistation/', p.chaste_test, '/', func2str(p.obj), '/'];

	if exist(sweep_path,'dir')~=7
		% Make the full path
		if exist([p.base_path, 'Research/Crypt/Chaste_models/ChasteMembrane/phoenix/ParameterOptimistation/', p.chaste_test, '/'],'dir')~=7
			mkdir([p.base_path, 'Research/Crypt/Chaste_models/ChasteMembrane/phoenix/ParameterOptimistation/', p.chaste_test, '/']);
		end

		mkdir(sweep_path);

	end

	sweep_file = [sweep_path, 'sweep.txt'];
	csvwrite(sweep_file, parameter_collection);

	% Run the parameter sweep

	% ONLY TO BE RUN ON PHOENIX
	sbatch_file = [p.base_path, 'Research/Crypt/Chaste_models/ChasteMembrane/phoenix/ParameterOptimistation/generic_grid_', p.chaste_test, '_sweep.sh'];
	[status,cmdout] = system(['sbatch ', sbatch_file, ' ', sweep_file, ' ', num2str(optimal(3)), ' ', num2str(optimal(4)) , ' ', func2str(p.obj)],'-echo');


end

	