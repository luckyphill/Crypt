classdef visualiseResistantCrypt < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties

		chastePath
		imageFile
		imageLocation

		simul

		run_number

	end

	methods

		function obj = visualiseResistantCrypt(n,np,ees,ms,cct,wt,vf,t,bt,sm,run_number)

			outputTypes = {   visualiserData(containers.Map({'sm', 'vis'},{sm, 1}))   };
			simParams = containers.Map({'n','np','ees','ms','cct','wt','vf'}, {n, np,ees,ms,cct,wt,vf});
			solverParams = containers.Map({'t', 'bt','dt'}, {t, bt, 0.0005});
			seedParams = containers.Map({'run'}, {run_number});
			obj.run_number = run_number;
			obj.simul = simulateCryptColumnResistant(simParams, solverParams, seedParams, outputTypes)
			
			obj.chastePath = [getenv('HOME'), '/'];

			if ~obj.simul.generateSimulationData()
				fprintf('Failed to get the data');
			end

		end

		function visualiseCrypt(obj)
			% Runs the java visualiser

			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chaste java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.saveLocation], '-echo');

		end

	end
	
end
