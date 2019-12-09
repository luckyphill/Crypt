function penalty = parObjectiveFunction(params, objectiveFunction, N)

	% Takes a vector of input parameters, runs N instances of them in parallel
	% then assesses the output through the objectiveFunction
	% Each parameter is multiplied by a factor of 10^a where a is the number of
	% decimal places we care about in accuracy.
	% The optimisation algorithm outside this function has an option for restricting
	% the inputs to integers, but not decimal, so this is a work around

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


	c = parcluster;
	job = createJob(c);


	testFunction = @(run_number)behaviourObjective(objectiveFunction,n,np,ees,ms,cct,wt,vf,t,dt,bt,run_number);


	for i = 1:N

		createTask(job, testFunction, 1, {i});

	end

	f = functions(objectiveFunction);
	job.AttachedFiles = {f.file};
	submit(job);
	
	wait(job);
	taskoutput = fetchOutputs(job);

	pensum = 0;
	for i = 1:N
		pensum = pensum + taskoutput{i}.penalty;
	end

	penalty = pensum/N;

end
