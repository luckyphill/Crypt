classdef fillingAnalysis < matlab.mixin.SetGet

	% This class performs the filling analysis
	% It implicitly assumes the data has already been generated, since
	% the simulation will be run for several 1000s of hours, meaning running
	% on anything but the server is not a good idea.
	% (It will still be possible to run the simulation, but it has to be
	% initiated explicitly).

	% It will load the visualiser data (or maybe the position data) and
	% analyse the number of cells in each layer over time

	properties
		
		chastePath
		chasteTestOutputLocation

		imageFile
		imageLocation

		simul

	end

	methods

		function obj = fillingAnalysis(simParams,mpos,Mnp,eesM,msM,cctM,wtM,Mvf,t,dt,bt,sm,run_number)

			outputType = visPositionData(containers.Map({'sm'},{100}));
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
			
			obj.loadSimulationData();

		end

		function visualiseCrypt(obj)
			% Runs the java visualiser
			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chaste java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.saveLocation]);

		end

		function levelsOverTime(obj)
			% This will load the data and count the number of cells in each level
			% over time. There is in theory no limit to the number of levels, but in practice
			% it will be exceedingly rare to see more than 10 levels, so the data will be
			% stored in an array of size 10 x (no time steps)

			data = obj.data;

			times = data(:,1);

			levelRanges = 


			levels = 

		end

	end
	
end
