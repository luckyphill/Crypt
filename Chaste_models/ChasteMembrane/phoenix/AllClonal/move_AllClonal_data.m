% script to transfer the half finsihed sims to the correct location in Data


% The path to the data will be in part determined by the specific
% parameters given to the simulation, which are found in the relevant text
% file in phoenix/AllMutations
% Loop through all of these sims and if the files are in the testouput
% directory (or maybe _not_ in the Data directory), then move them

function move_AllClonal_data(cryptType)

	switch cryptType
		case 1
			cryptName = 'MouseColonDesc';
		case 2
			cryptName = 'MouseColonAsc';
		case 3
			cryptName = 'MouseColonTrans';
		case 4
			cryptName = 'MouseColonCaecum';
		case 5
			cryptName = 'RatColonDesc';
		case 6
			cryptName = 'RatColonAsc';
		case 7
			cryptName = 'RatColonTrans';
		case 8
			cryptName = 'RatColonCaecum';
		case 9
			cryptName = 'HumanColon';
		otherwise
			error('Crypt type not found');
	end


	paramsFile = ['/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/phoenix/AllMutations/', cryptName, '.txt'];
	firstPart = ['/Users/phillipbrown/testoutput/TestCryptColumnFullMutation/', cryptName, '/'];
	newFirstPart = ['/Users/phillipbrown/Research/Crypt/Data/Chaste/TestCryptColumnFullMutation', cryptName, '/'];

	params = dlmread(paramsFile);

	% Loop thorugh each parameter set in the paramsFile
	% Use it to check if the data is still there
	% If it is, move it.

	for i = 1:length(params)

		currentLocation = sprintf('%sMnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_100/',firstPart, params(i,:));

		% Need to change the order of the params to match how they are found in the Data directory
		swip = [params(i,1),params(i,6),params(i,4),params(i,2), params(i,3),params(i,5), params(i,7)];

		if isfile([currentLocation, 'results.viznodes'])
			% If one of the files is there, then all of them must be, so move them all
			newLocation = sprintf('%smutant_Mnp_%d_Mvf_%g_cctM_%g_eesM_%g_msM_%g_wtM_%g/numerics_bt_100_t_6000/run_%d/', newFirstPart, swip);
			
			if exist(newLocation,'dir')~=7
				mkdir(newLocation);
			end

			[status,cmdout] = system(['cp ', currentLocation, 'results.viznodes', ' ',  newLocation, 'results.viznodes'],'-echo');
			[status,cmdout] = system(['cp ', currentLocation, 'results.vizboundarynodes', ' ',  newLocation, 'results.vizboundarynodes'],'-echo');
			[status,cmdout] = system(['cp ', currentLocation, 'results.vizcelltypes', ' ',  newLocation, 'results.vizcelltypes'],'-echo');
			[status,cmdout] = system(['cp ', currentLocation, 'results.vizsetup', ' ',  newLocation, 'results.vizsetup'],'-echo');
			[status,cmdout] = system(['cp ', currentLocation, 'results.parameters', ' ',  newLocation, 'results.parameters'],'-echo');
			[status,cmdout] = system(['cp ', currentLocation, 'popup_location.txt', ' ',  newLocation, 'popup_location.txt'],'-echo');
			[status,cmdout] = system(['cp ', currentLocation, 'build.info', ' ',  newLocation, 'build.info'],'-echo');
			[status,cmdout] = system(['cp ', currentLocation, 'system_info_0.txt', ' ',  newLocation, 'system_info_0.txt'],'-echo');
		end
	end
end
