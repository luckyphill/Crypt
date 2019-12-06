% This should not be run after dumping the sims on phoenix
% since the LHS method is stochastic and will produce different results
% setting rng default in makeLHSParams seems to make the output
% deterministic, but for the sake of reproducibility, this still should
% not be touched just in case

files = {	'MouseColonDesc.txt'
			'MouseColonAsc.txt'
			'MouseColonTrans.txt'
			'MouseColonCaecum.txt'
			'RatColonDesc.txt'
			'RatColonAsc.txt'
			'RatColonTrans.txt'
			'RatColonCaecum.txt'
			'HumanColon.txt'};

pathOldP = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/test/params/';
pathStoreP = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/analysis/behaviour/';
pathTestP = '/Users/phillipbrown/Research/Crypt/Chaste_models/ChasteMembrane/phoenix/NewOptimisation/';

nParams = 100;
nReps = 10;

for i = 1:length(files)
	oldLocation = [pathOldP, files{i}];

	% Use the old pattern search params as a centre point
	params = csvread(oldLocation);
	n = params(1);
	np = params(2);
	cct = round(params(6));

	% This requires a special approach to make sure the wt is cct-2 > wt > 2
	% we specify wt as a fraction of cct since we want it to take a fairly large range
	% the lhs could pick wt larger than cct. Using ratios of the smallest cct is too
	% restrictive for the upper end of the range
	wtFmin = round(2/( 0.66*cct),2);
	wtFmax = round((0.66*cct - 2)/(0.66*cct),2);
	% Set the upper and lower bounds to search
	lb  = [0.8 * n, 0.8 * np, 20, 20, 0.66 * cct, wtFmin, 0.5];
	ub  = [1.2 * n, 1.2 * np, 500, 500, 1.33 * cct, wtFmax, 1.0];

	P = makeLHSParams(nParams,lb,ub);

	% Need to readjust wtF back to wt
	P(:,6) = round(P(:,5).*P(:,6),1);

	storeLocation = [pathStoreP, files{i}];

	csvwrite(storeLocation, P);

	temp = repmat(1:nReps,nParams,1);
	testP = [repmat(P,nReps,1), temp(:)];

	testLocation = [pathTestP, files{i}];

	csvwrite(testLocation, testP);

end



