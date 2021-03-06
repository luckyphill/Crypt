classdef basinObjective < matlab.mixin.SetGet

	% Given a crypt and a version, along with mutation factors for each parameter
	% This will run a simulation for a crypt based on an optimal parameter set
	% which has been perturbed from optimal according to the mutation factors

	% THIS HAS BEEN MODIFIED WITHOUT CHECKING PREVIOUS FILES THAT USED IT

	properties
		simul
		objectiveFunction
		params
		penalty
		cryptName

	end

	methods

		function obj = basinObjective(crypt, vers, nM, npM, eesM, msM, cctM, wtM, vfM, varargin)
			obj.cryptName = getCryptName(crypt);
			obj.params = getOptimalParams(crypt, vers);
			obj.objectiveFunction = str2func(obj.cryptName);

			n = obj.params(1);
			np = obj.params(2);
			ees = obj.params(3);
			ms = obj.params(4);
			cct = obj.params(5);
			wt = obj.params(6);
			vf = obj.params(7);

			if ~obj.physical(n,np,ees,ms,cct,wt,vf,nM,npM,eesM,msM,cctM,wtM,vfM)
				error('Check the input parameters or factors are physically possible, e.g. wt*wtM < cct*cctM - 2');
			end
			
			outputTypes = behaviourData();
			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {n*nM, np*npM, ees*eesM, ms*msM, cct*cctM, wt*wtM, vfM*vf});
			solverParams = containers.Map({'t', 'bt', 'dt'}, {1000, 100, 0.0005});
			seedParams = containers.Map({'run'}, {1});

			obj.simul = simulateCryptColumn(simParams, solverParams, seedParams, outputTypes);
			
			% A hack to stop it from running when we're analysing the data
			if length(varargin) >= 1
				obj.getPenalty(varargin);
			else
				obj.getPenalty();
			end			

		end

		function runSimulation(obj)
			if obj.simul.generateSimulationData()
				obj.simul.loadSimulationData();
			else
				error('Failed to get the data')
			end
		end

		function penalty = getPenalty(obj, varargin)
			% Use the objective function to calculate the associated penalty
			if length(varargin) <1
				obj.runSimulation();
			else
				obj.simul.loadSimulationData();
			end

			obj.penalty = obj.objectiveFunction(obj.simul.data.behaviour_data);

			fprintf('Anoikis: %g,\nCell count: %g,\nBirth rate: %g,\nProlif compartment: %g\n\nPenalty: %g\n',obj.simul.data.behaviour_data,obj.penalty);


		end

		function correct = physical(obj, n,np,ees,ms,cct,wt,vf,nM,npM,eesM,msM,cctM,wtM,vfM)
			% Need to make sure the parameters are physically possible
			correct = true;
			if wtM*wt < 2
				% The minimum we can have is a growing time of 2
				correct = false;
			else
				if wtM*wt > cctM*cct - 2
					% wt must be at least 2 hours less than cct
					correct = false;
				end
			end

			if npM*np > nM*n - 4
				% Need at least some space where the crypt has differentiated cells
				correct = false;
			end
			
			if vfM*vf >1
				% Makes no sense for CI volume fraction to be greater than 1
				correct = false;
			end
		end

	end

end