classdef clearingAnalysis < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		
		chastePath
		chasteTestOutputLocation

		imageFile
		imageLocation


		times
		empty_interval_sizes
		empty_interval_times
		empty_fraction

		simul

	end

	methods

		function obj = clearingAnalysis(crypt,mutantParams,t,bt,sm,run_number)

			simParams = containers.Map({'crypt'},{crypt});
			outputTypes = {visPositionData(containers.Map({'sm'},{sm}))};

			solverParams = containers.Map({'t', 'bt'}, {t, bt});
			seedParams = containers.Map({'run'}, {run_number});

			obj.chastePath = [getenv('HOME'), '/'];
			obj.chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];


			obj.simul = simulateCryptColumnFullMutation(simParams, mutantParams, solverParams, seedParams, outputTypes);
			
			obj.simul.loadSimulationData();

			obj.processData();

		end


		function visualiseCrypt(obj)
			% Runs the java visualiser
			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chaste java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.saveLocation, 'run_', num2str(obj.simul.seedParams('run'))]);

		end

	end


	methods (Access = private)

		function processData(obj)
			% Make a vector that holds the time intervals where
			% no cells were popped up
			data = obj.simul.data.vispos_data;
			obj.times = data(:,1);

			lump_time_counts = [];
			lump_times = {};

			time_steps_with_no_lumps = 0;
			% The number of popped up cells at the previous time step, initialised
			prev_n = 1;
			for i = 1:length(obj.times)
				% Check if there are any popped up cells

				nz = find(data(i,:), 1, 'last');
				x = data(i,2:2:nz);
				n = length(x(x>1.1));

				if n == 0
					time_steps_with_no_lumps = time_steps_with_no_lumps + 1;
					if prev_n > 0
						start_time = obj.times(i);
					end
				else
					if time_steps_with_no_lumps > 0
						lump_time_counts(end+1) = time_steps_with_no_lumps;
						time_steps_with_no_lumps = 0;
						lump_times{end + 1} = [start_time, obj.times(i)];
					end
				end
				prev_n = n;
			end

			% If the simulation ended with no lumps, add in the last time
			if time_steps_with_no_lumps > 0
				lump_time_counts(end+1) = time_steps_with_no_lumps;
				time_steps_with_no_lumps = 0;
				lump_times{end + 1} = [start_time, obj.times(i)];
			end
		
			obj.empty_interval_sizes = lump_time_counts;
			obj.empty_interval_times = lump_times;

			obj.empty_fraction = sum(lump_time_counts)/i;

		end


	end


end