classdef behaviourObjective < matlab.mixin.SetGet

	% A class to handle calculating the objective function value
	% for a given simulation of a healthy crypt

	properties
		simul
		objectiveFunction
		penalty

	end

	methods

		function obj = behaviourObjective(objectiveFunction,n,np,ees,ms,cct,wt,vf,t,dt,bt,run_number)

			outputType = behaviourData();

			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {n, np, ees, ms, cct, wt, vf});
			solverParams = containers.Map({'t', 'bt', 'dt'}, {t, bt, dt});
			seedParams = containers.Map({'run'}, {run_number});

			chastePath = [getenv('HOME'), '/'];
			outputLocation = getenv('CHASTE_TEST_OUTPUT');

			if isempty(outputLocation)
				chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];
			else
				if ~strcmp(outputLocation(end),'/')
					outputLocation(end+1) = '/';
				end
				chasteTestOutputLocation = outputLocation;
			end

			obj.objectiveFunction = objectiveFunction;


			obj.simul = simulateCryptColumn(simParams, solverParams, seedParams, outputType, chastePath, chasteTestOutputLocation);
			
			obj.getPenalty();
			

		end

		function runSimulation(obj)
			if obj.simul.generateSimulationData()
				obj.simul.loadSimulationData();
			else
				error('Failed to get the data')
			end
		end

		function penalty = getPenalty(obj)
			% Use the objective function to calculate the associated penalty
			obj.runSimulation();
			obj.simul.data.behaviour_data
			penalty = obj.objectiveFunction(obj.simul.data.behaviour_data);
			obj.penalty = penalty;

			fprintf('Anoikis: %g,\nCell count: %g,\nBirth rate: %g,\nProlif compartment: %g\n\nPenalty: %g\n',obj.simul.data.behaviour_data,penalty);


		end

	end

end