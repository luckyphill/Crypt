function InitialPoints = assembleInitialPointsSingleSeed(objectiveFunction, j)
	

	newSearchParamsFile = [getenv('HOME'), '/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/analysis/behaviour/', func2str(objectiveFunction), '.txt'];

	params = csvread(newSearchParamsFile);
	InitialPoints.X = [];
	InitialPoints.Fval = 0;

	for i = 1:length(params)

		n = params(i,1);
		np = params(i,2);
		ees = params(i,3);
		ms = params(i,4);
		cct = params(i,5);
		wt = params(i,6);
		vf = params(i,7);

		t = 2000;
		dt = 0.0005;
		bt = 200;

		pen = [];

		try
			% This shouldn't start running if the file doesn't exist
			b = behaviourObjective(objectiveFunction,n,np,ees,ms,cct,wt,vf,t,dt,bt,j, 'Dont run');
			pen = b.getPenalty('Dont run');

			InitialPoints(end+1).X = params(i,:);
			InitialPoints(end).Fval = mean(pen);

		end

		


	end

end