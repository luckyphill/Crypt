function ManageCryptColumn(n, np, ees, ms, cct, wt, vf, seed)
	
	% A dumb mamanger - it sets the variables and runs the simulation
	% Ideally I'd want to implement this in the same way as for EdgeBased
	% But at this point I don't really need to

	outputTypes = behaviourData();
	simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {n, np, ees, ms, cct, wt, vf});
	solverParams = containers.Map({'t', 'bt', 'dt'}, {1000, 100, 0.0005});
	seedParams = containers.Map({'run'}, {seed});
	
	if verifyParams(n,np,ees,ms,cct,wt,vf)

		fprintf('Parameters are valid, starting simulation\n');
		sim = simulateCryptColumn(simParams, solverParams, seedParams, outputTypes);
		sim.generateSimulationData();

	else

		fprintf('Parameters invalid. Stopping.\n');

	end
end

function physical = verifyParams(n,np,ees,ms,cct,wt,vf)
	% Need to make sure the parameters are physically possible
	physical = true;
	if wt < 2
		% The minimum we can have is a growing time of 2
		physical = false;
	else
		if wt > cct - 2
			% wt must be at least 2 hours less than cct
			physical = false;
		end
	end

	if np > n - 4
		% Need at least some space where the crypt has differentiated cells
		physical = false;
	end
	
	if vf >1
		% Makes no sense for CI volume fraction to be greater than 1
		physical = false;
	end
end

