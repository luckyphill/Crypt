classdef visualiserAnalysis < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		
		chastePath
		chasteTestOutputLocation

		imageFile
		imageLocation

		simul

	end

	methods

		function obj = visualiserAnalysis(simParams,Mnp,eesM,msM,cctM,wtM,Mvf,t,bt,sm,run_number)

			outputType = {   visualiserData(containers.Map({'sm'},{sm})) ,  popUpData() };
			mutationParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf'}, {Mnp,eesM,msM,cctM,wtM,Mvf});
			solverParams = containers.Map({'t', 'bt'}, {t, bt});
			seedParams = containers.Map({'run'}, {run_number});

			obj.chastePath = [getenv('HOME'), '/'];


			obj.simul = simulateCryptColumnFullMutation(simParams, mutationParams, solverParams, seedParams, outputType);
			
			if ~obj.simul.generateSimulationData()
				fprintf('Failed to get the data');
			end

		end

		function visualiseCrypt(obj)
			% Runs the java visualiser

			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chaste java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.saveLocation]);

		end

	end
	
end
