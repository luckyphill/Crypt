classdef fftPosition < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		
		chastePath
		chasteTestOutputLocation

		imageFile
		imageLocation

		fftData
		fftMagData
		max_pos_t
		times

		simul

	end

	methods

		function obj = fftPosition(crypt,mutantParams,t,bt,sm,run_number)

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

		function fftAnalysis(obj)
			% Displays a plot of the velocity data

			L = obj.times(end);
			test = obj.max_pos_t(:,1:29);
			out = fft(test);
			out2 = out(1:length(out)/2 + 1, : );
			out2= abs(out2 / L);
			out2(2:end -1, :) = 2*out2(2:end-1, :);

			obj.fftData = out;
			obj.fftMagData = out2;
			f = (1:length(out)-1)/30/L;

		end

		function visualiseCrypt(obj)
			% Runs the java visualiser
			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chase java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.simOutputLocation]);

		end

	end


	methods (Access = private)

		function processData(obj)
			% Turns the raw position data into max height data

			data = obj.simul.data.vispos_data;
			obj.times = data(:,1);


			steps = -0.5:29.5;
			nn = length(steps)-1;

			pos_max_t = nan(length(obj.times),nn);


			for i=1:length(data)
				clear sortedbypos;
				nz = find(data(i,:), 1, 'last');
				x = data(i,2:2:nz);
				y = data(i,3:2:nz);
				sortedbypos{nn} = [];
				for j = 1:length(x)
					for k=2:length(steps)
						if steps(k) >= y(j) && y(j) > steps(k-1)
							sortedbypos{k-1}(end + 1) = x(j);
						end
					end
				end
				
				for j = 1:nn
					temp = max(sortedbypos{j});
					if ~isempty(temp)
						pos_max_t(i,j) = temp;
					end
				end

			end

			obj.max_pos_t = pos_max_t;
			

		end


	end


end