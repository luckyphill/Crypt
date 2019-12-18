function penalty = objectiveFunctionSingleSeed(params, objectiveFunction, j)

	% Takes a vector of input parameters, runs the simulation with seed j
	% then assesses the output through the objectiveFunction
	% Each parameter is multiplied by a factor of 10^a where a is the number of
	% decimal places we care about in accuracy.
	% The optimisation algorithm outside this function has an option for restricting
	% the inputs to integers, but not decimal, so this is a work around

	% This is mainly a wrapper so the input parameters can be supplied as a vector,
	% instead of individual variables

	n = params(1) / 10;
	np = params(2) / 10;
	ees = params(3);
	ms = params(4);
	cct = params(5) / 10;
	temp_wt = params(6) / 100;
	vf = params(7) / 1000;

	wt = round(temp_wt * cct,1); % Necessary to make sure wt stays within acceptable limits

	dt = 0.0005;
	bt = 100;

	t = 1000;


	testFunction = behaviourObjective(objectiveFunction,n,np,ees,ms,cct,wt,vf,t,dt,bt,j);

	penalty = testFunction.penalty;


end
