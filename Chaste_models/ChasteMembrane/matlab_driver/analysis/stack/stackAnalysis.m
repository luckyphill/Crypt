classdef stackAnalysis < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties

		crypt
		cryptName
		
		n

		muts
		values

		imageFile
		imageLocation

		times
		avgStackHeight

		simul

	end

	methods

		function obj = stackAnalysis(crypt, muts, values)
			% This object examines the time-average thickness at a given cell position
			% It breaks the crypt up into compartments determined by the ceiling of the
			% input parameter n. It needs to be smaller than the maximum number of cells
			% in the crypt in order to smooth out the function
			% The time average thickness for each cell location is plotted up to the point
			% where the special sloughing mechanism cuts in

			% muts is a cell array of strings matching 'Mnp','eesM','msM','cctM','wtM','Mvf'
			% values is a vector of the mutation factor values

			simParams = containers.Map({'crypt'}, {crypt});
			outputTypes = {visPositionData(containers.Map({'sm'},{1000}))};
			solverParams = containers.Map({'t', 'bt'}, {6000, 100});
			seedParams = containers.Map({'run'}, {1});
			
			params = getCryptParams(crypt);
			obj.n = params(1);

			mutantParams = containers.Map({'Mnp','eesM','msM','cctM','wtM','Mvf'}, {params(2), 1, 1, 1, 1, params(5)});

			assert(length(muts) == length(values));

			for i = 1:length(muts)
				mutantParams(muts{i}) = values(i);
			end

			obj.muts = muts;
			obj.values = values;


			obj.imageLocation = [getenv('HOME'), '/Research/Crypt/Images/StackAnalysis/', obj.cryptName, '/'];
			for i=1:length(obj.muts)
				obj.imageLocation = sprintf('%s%s', obj.imageLocation, obj.getParamName(obj.muts{i}));
			end
			obj.imageLocation = [obj.imageLocation, '/'];

			if exist(obj.imageLocation, 'dir') ~=7
				mkdir(obj.imageLocation);
			end

			obj.imageFile = obj.imageLocation;

			for i=1:length(obj.muts)
				obj.imageFile = sprintf('%s%s%g', obj.imageFile, obj.getParamName(obj.muts{i}), obj.values(i));
			end

			obj.imageFile = strrep(obj.imageFile, '.', '_');



			obj.simul = simulateCryptColumnFullMutation(simParams, mutantParams, solverParams, seedParams, outputTypes);

			obj.simul.loadSimulationData();

			obj.heightOverTime();


		end


		function visualiseCrypt(obj)
			% Runs the java visualiser
			pathToAnim = [obj.simul.chastePath, 'Chaste/anim/'];
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
			% n = ceil(max(max(data(:,2:end))));
			
			steps = -0.5:(ceil(obj.n) + 0.5);

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
						h_max(j) = nan;
					else
						h_max(j) = max(sortedbypos{j});
					end
				end

				% Puts the position of the highest cell in each cell column
				% into a vector, then appends that to the time series for each column
				h_max_t(i,:) = h_max;
							
			end

			% Takes the time average for each cell position
			obj.avgStackHeight = nanmean(h_max_t);

			% Remove the last couple of average values to account for the sloughing
			% mechanism that cuts off at an angle
			tmp = obj.avgStackHeight;
			tmp = tmp(1:end-1) - tmp(2:end);

			% Empirically detemined gradient limit
			% Should work for all plots since the limit was chosen from the plot with the steepest end part
			trimmed = 0;
			while tmp(end) > 0.1
				tmp(end) = [];
				obj.avgStackHeight(end) = [];
				trimmed = trimmed + 1;
			end

			% Pad out the vector with nans for later plotting
			obj.avgStackHeight = [obj.avgStackHeight, nan(1,trimmed)];


		end

		


		function h = makePlot(obj)

			h = figure;
			set(h,'Visible', 'off');

			plot(1:length(obj.avgStackHeight), obj.avgStackHeight, 'lineWidth', 4);
			xlabel('Cell Position','Interpreter','latex','FontSize',20);
			ylabel('Thickness','Interpreter','latex','FontSize',18);
			plotTitle = 'Average thickness for mutation to ';
			plotTitle = sprintf( '%s%s (%g)', plotTitle, obj.getParamName(obj.muts{1}), obj.values(1) );
			if length(obj.muts) > 1
				plotTitle = sprintf( '%s and %s (%g)', plotTitle, obj.getParamName(obj.muts{2}), obj.values(2) );
			end
			title(plotTitle,'Interpreter','latex','FontSize',20);
			ylim([0.6 5]);

		end

		function savePlot(obj)

			h = obj.makePlot();

			set(h,'Units','Inches');
			pos = get(h,'Position');
			set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

			print(obj.imageFile,'-dpdf');
		
		end

		function showPlot(obj)
			h = obj.makePlot();
			set(h,'Visible', 'on');

		end
		

		function name = getParamName(obj, I)

			switch I
				case 'Mnp'
					name = 'Compartment';
				case 'eesM'
					name = 'Stiffness';
				case 'msM'
					name = 'Adhesion';
				case 'cctM'
					name = 'Cycle';
				case 'wtM'
					name = 'Growth';
				case 'Mvf'
					name = 'Inhibition';
				otherwise
					error('Parameter type not found');
			end
		end

	end

end
