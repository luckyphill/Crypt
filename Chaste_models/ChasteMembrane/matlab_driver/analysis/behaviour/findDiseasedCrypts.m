function [diseased, pen] = findDiseasedCrypts(objectiveFunction)
	% This function takes an input of crypt type, and examines the LHS data
	% It finds the minimum objective function value from those points

	% This is also handy to practice for putting it into the surrogate search
	newSearchParamsFile = [getenv('HOME'), '/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/analysis/behaviour/', func2str(objectiveFunction), '.txt'];

	params = csvread(newSearchParamsFile);
	diseased = {};
	pen = [];
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

		% There are 10 sims for each point
		try
			% This shouldn't start running if the file doesn't exist
			b = behaviourObjective(objectiveFunction,n,np,ees,ms,cct,wt,vf,t,dt,bt,1, 'Dont run');
			outputStats = b.simul.data.behaviour_data;
			if outputStats(1) > 0.06 && outputStats(1) < 0.1
				diseased{end+1} = params(i,:);
				pen(end+1) = b.getPenalty('Dont run');
			end

		end

	end


end
