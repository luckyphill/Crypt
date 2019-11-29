function penalty = parObjectiveFunction(params, objectiveFunction, N)

	% Takes a vector of input parameters, runs N instances of them in parallel
	% then assesses the output through the objectiveFunction

	n = params(1);
	np = params(2);
	ees = params(3);
	ms = params(4);
	cct = params(5);
	wt = params(6);
	vf = params(7);

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
