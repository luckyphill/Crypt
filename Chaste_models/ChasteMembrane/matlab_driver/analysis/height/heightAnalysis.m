classdef heightAnalysis < matlab.mixin.SetGet

	% This class performs the height analysis, looking at the average, max and min height
	% at a particular point over time
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

		imageFiles
		imageLocation

		simul

		h_max_mean

		h_crypt_max_t
		h_crypt_min_t
		h_crypt_mean_t


		mean_h_max
		mean_h_min
		mean_h_mean

		times

	end

	methods

		function obj = heightAnalysis(simParams,mutantParams,t,bt,sm,run_number)

			outputTypes = {visPositionData(containers.Map({'sm'},{sm}))};
			solverParams = containers.Map({'t', 'bt'}, {t, bt});
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

			obj.imageLocation = [getenv('HOME'), '/Research/Crypt/Images/heightanalysis/'];
			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.simul = simulateCryptColumnFullMutation(simParams, mutantParams, solverParams, seedParams, outputTypes);

			obj.simul.loadSimulationData();

		end

		function visualiseCrypt(obj)
			% Runs the java visualiser
			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chaste java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.outputTypes{1}.getFullFilePath(obj.simul)], '-echo');

		end

		function heightOverTime(obj)
			% This will pick a point on the crypt wall and observe the maximum height of the
			% accumulated cells over time

			data = obj.simul.data.vispos_data;

			obj.times = data(:,1);

			% Matlab is fucking weird. In order to make sure only integers are given to obj.simul.n
			% I have to restrict the type to uintX (in my case I chose X = 16). But because of some
			% weird history about how matlab was built, you have to make sure the input argument types
			% to the colon operator are of the same type, and matlab treats anything without an explicitly
			% declared type as a double. So in the case of the line below, -0.5 is type double, and obj.simul.n
			% is of type uint16. You might think that the + 0.5 will force the RHS to be a double, but
			% you would be wrong, it actually makes it a uint16 ¯\_(ツ)_/¯
			% To get around this, I could cast everything as uint16, but  I'm sure I'd find more problems later on
			% so to keep matlab happy everything is a double...
			% See more at
			% https://stackoverflow.com/questions/48493352/error-colon-operands-must-be-in-the-range-of-the-data-type-no-sense
			n = ceil(max(max(data(:,2:end))));
			steps = -0.5:(n + 0.5);

			for i=1:length(data)
				clear sortedbypos;
				nz = find(data(i,:), 1, 'last');
				x = data(i,2:2:nz);
				y = data(i,3:2:nz);
				sortedbypos{length(steps)-1} = [];
				for j = 1:length(x)
					for k=2:length(steps)
						if steps(k) >= y(j) && y(j) > steps(k-1)
							sortedbypos{k-1}(end + 1) = x(j);
						end
					end
				end
				
				for j = 1:length(sortedbypos)
					if isempty(sortedbypos{j})
						h_min(j) = nan;
						h_max(j) = nan;
						h_mean(j) = nan;
					else
						h_min(j) = min(sortedbypos{j});
						h_max(j) = max(sortedbypos{j});
						h_mean(j) = mean(sortedbypos{j});
					end
				end
				
				h_min_t(i,:) = h_min;
				h_max_t(i,:) = h_max;
				h_mean_t(i,:) = h_mean;
							
			end

			obj.h_max_mean = nanmean(h_max_t);

			obj.h_crypt_max_t = max(h_max_t');
			obj.h_crypt_min_t = min(h_max_t');
			obj.h_crypt_mean_t = nanmean(h_max_t');

			obj.mean_h_max = mean(obj.h_crypt_max_t);
			obj.mean_h_min = mean(obj.h_crypt_min_t);
			obj.mean_h_mean = mean(obj.h_crypt_mean_t);

		end

		function plotHeightOverTime(obj)

			h = figure;
			% The x axis range is hard coded, this won't be correct in general, just for mousecolondesc
			plot(1:length(obj.h_max_mean), obj.h_max_mean, 'lineWidth', 4);
			xlabel('Position from stem cell niche')
			ylabel('Time average height above BM')
			title(['Time average stack height for each crypt position for mutation: ' obj.simul.mutantParams('name')]);
			ylim([0.6 4]);

			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

			print([getenv('HOME'), '/Research/Crypt/Images/heightanalysis/pos_time_avg ',obj.simul.mutantParams('name')],'-dpdf');

			h = figure;
			hold on
			plot(obj.times,obj.h_crypt_max_t)
			plot(obj.times,obj.h_crypt_min_t)
			plot(obj.times,obj.h_crypt_mean_t)
			legend('max height', 'min height', 'mean height');
			xlabel('Time')
			ylabel('Whole crypt maximum height above BM')
			title(['Maximum stack height over time for the whole crypt: ' obj.simul.mutantParams('name')]);
			ylim([0 8])

			plot(obj.times,obj.mean_h_max * ones(size(obj.times)));
			plot(obj.times,obj.mean_h_min * ones(size(obj.times)));
			plot(obj.times,obj.mean_h_mean * ones(size(obj.times)));

			legend( num2str(obj.mean_h_max), num2str(obj.mean_h_min) ,num2str(obj.mean_h_mean) )

			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
			
			print([getenv('HOME'), '/Research/Crypt/Images/HeightAnalysis/whole_crypt_max_min_mean  ',obj.simul.mutantParams('name')],'-dpdf');




		end

	end
	
end
