classdef popuplocationAnalysis < matlab.mixin.SetGet

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

		puLocation

	end

	methods

		function obj = popuplocationAnalysis(simParams,mutantParams,t,dt,bt,sm,run_number)

			outputType = popUpData();
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

			obj.imageLocation = [getenv('HOME'), '/Research/Crypt/Images/popuplocationanalysis/'];
			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.simul = simulateCryptColumnMutation(simParams, mutantParams, solverParams, seedParams, outputType, obj.chastePath, obj.chasteTestOutputLocation);
			
			obj.simul.loadSimulationData();

		end

		function visualiseCrypt(obj)
			% Runs the java visualiser
			pathToAnim = [obj.chastePath, 'Chaste/anim/'];
			fprintf('Running Chaste java visualiser\n');
			[failed, cmdout] = system(['cd ', pathToAnim, '; java Visualize2dCentreCells ', obj.simul.outputTypes{1}.getFullFilePath(obj.simul)], '-echo');

		end

		function popUpIndex(obj)
			% This will pick a point on the crypt wall and observe the maximum height of the
			% accumulated cells over time

			data = obj.simul.data.popup_data;

			times = data(:,1);

			% Strip the times
	        data = data(:,2:end);
	        % Strip the empty rows
	        data = data(:);
	        data( ~any(data,2), : ) = [];
	        obj.puLocation = data;


		end

		% function plotHeightOverTime(obj)

		% 	h = figure;
		% 	plot(0:double(obj.simul.n), obj.h_max_mean, 'lineWidth', 4);
		% 	xlabel('Position from stem cell niche')
		% 	ylabel('Time average height above BM')
		% 	title(['Time average stack height for each crypt position for mutation: ' obj.simul.mutantParams('name')]);
		% 	ylim([0.6 3.6]);

		% 	set(h,'Units','Inches');
		% 	pos = get(h,'Position');
		% 	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

		% 	print([getenv('HOME'), '/Research/Crypt/Images/popuplocationanalysis/pos_time_avg ',obj.simul.mutantParams('name')],'-dpdf');

		% 	h = figure;
		% 	hold on
		% 	plot(times,h_crypt_max_t)
		% 	plot(times,h_crypt_min_t)
		% 	plot(times,h_crypt_mean_t)
		% 	legend('max height', 'min height', 'mean height');
		% 	xlabel('Time')
		% 	ylabel('Whole crypt maximum height above BM')
		% 	title(['Maximum stack height over time for the whole crypt: ' obj.simul.mutantParams('name')]);
		% 	ylim([0 8])

		% 	plot(times,obj.mean_h_max * ones(size(times)));
		% 	plot(times,obj.mean_h_min * ones(size(times)));
		% 	plot(times,obj.mean_h_mean * ones(size(times)));

		% 	legend( num2str(obj.mean_h_max), num2str(obj.mean_h_min) ,num2str(obj.mean_h_mean) )

		% 	set(h,'Units','Inches');
		% 	pos = get(h,'Position');
		% 	set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
			
		% 	print([getenv('HOME'), '/Research/Crypt/Images/popuplocationanalysis/whole_crypt_max_min_mean  ',obj.simul.mutantParams('name')],'-dpdf');




		% end

	end
	
end
