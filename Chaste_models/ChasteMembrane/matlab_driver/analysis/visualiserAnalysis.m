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

			outputType = {   visualiserData(containers.Map({'sm'},{sm})) ,  popUpData() };
			mutationParams = containers.Map({'mpos', 'Mnp','eesM','msM','cctM','wtM','Mvf'}, {mpos,Mnp,eesM,msM,cctM,wtM,Mvf});
			solverParams = containers.Map({'t', 'bt', 'dt'}, {t, bt, dt});
			seedParams = containers.Map({'run'}, {run_number});

			obj.chastePath = [getenv('HOME'), '/'];

			outputLocation = getenv('CHASTE_TEST_OUTPUT');

			if isempty(outputLocation)
				obj.chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/testoutput/'];
			else
				if ~strcmp(outputLocation(end),'/')
					outputLocation(end+1) = '/';
				end
				obj.chasteTestOutputLocation = outputLocation;
			end


			obj.simul = simulateCryptColumnMutation(simParams, mutationParams, solverParams, seedParams, outputType, obj.chastePath, obj.chasteTestOutputLocation);
			
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
