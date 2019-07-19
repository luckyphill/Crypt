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

		function obj = visualiserAnalysis(simParams,mpos,Mnp,eesM,msM,cctM,wtM,Mvf,t,dt,bt,sm,run_number)

			outputType = visualiserData(containers.Map({'sm'},{100}));
			mutationParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {mpos,Mnp,eesM,msM,cctM,wtM,Mvf});
			solverParams = containers.Map({'t', 'bt', 'dt'}, {t, bt, dt});
			seedParams = containers.Map({'run'}, {run_number});

			obj.chastePath = [getenv('HOME'), '/'];
			obj.chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];


			obj.simul = simulateCryptColumnMutation(simParams, mutationParams, solverParams, seedParams, outputType, obj.chastePath, obj.chasteTestOutputLocation);
			
			if ~obj.simul.generateSimulationData()
				error('Failed to get the data')
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
