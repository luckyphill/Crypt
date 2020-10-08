classdef TumourSpheroidAnalysis < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		% No input parameters needed

		p
		g
		b

		seed

		analysisName = 'TumourSpheroidAnalysis';

		parameterSet = []

		simulationRuns = 1
		slurmTimeNeeded = 24
		simulationDriverName = 'TumourSpheroid'
		simulationInputCount = 7
		

	end

	methods

		function obj = TumourSpheroidAnalysis(p,g,b,seed)

			% Each seed runs in a separate job
			obj.specifySeedDirectly = true;

			obj.p = p;
		 	obj.g = g;
			obj.b = b;
			obj.seed = seed;
			obj.analysisName = sprintf('%s/p%gg%gb%g_seed%g',obj.analysisName, obj.p, obj.g, obj.b, obj.seed);


		end

		function MakeParameterSet(obj)

			obj.parameterSet = [];

		end

	

		function AssembleData(obj)

			% Just need to load the time series as in the visaliser

			pathName = sprintf('TumourSpheroid/p%gg%gb%g_seed%g/SpatialState/',obj.p, obj.g, obj.b, obj.seed);
			obj.result = Visualiser(pathName);


		end

		function PlotData(obj)

			N = []; % Number of cells
			C = []; % Centre of area
			R80 = []; % Radius about C that captures 80% of the cells
			mA = []; % Mean area of non-growing cells
			RA = {}; % Area/Distance pairs
			pauseRA = {};
			
			[I,~] = size(obj.result.cells);

			for i = 1:I
				R = []; % Radii
				pauseAreas = []; % self evident
				pauseRadii = [];
				CC = []; % Cell centres
				A = []; % Areas
				% i is the time steps
				[~,J] = size(obj.result.cells);
				j = 1;
				angles = [];
				while j <= J && ~isempty(obj.result.cells{i,j})

					c = obj.result.cells{i,j};
					ids = c(1:end-1);
					colour = c(end);
					nodeCoords = squeeze(obj.result.nodes(ids,i,:));

					CC(j,:) = mean(nodeCoords);

					x = nodeCoords(:,1);
					y = nodeCoords(:,2);

					A(j) = polyarea(x,y);



					if colour == 1
						% Assemble areas of non-growing cells
						pauseAreas(end+1) = A(j);
						pauseRadii(end+1) = norm(mean(nodeCoords));
					end

					j = j + 1;

				end
				% j will always end up being 1 more than the total number of non empty cells

				N(end + 1) = j-1;
				C(end + 1,:) = mean(CC);
				mA(end + 1) = mean(pauseAreas);


				R = sqrt(sum(abs(CC-C(end,:)).^2,2));

				RA{end + 1} = [R,A'];
				pauseRA{end + 1} = [pauseRadii',pauseAreas'];

				R = sort(R);
				R80(end + 1) = R(ceil(.9*(j-1)));

				% hs.Data = abs(angles);
				% drawnow
				% title(sprintf('t = %g',obj.result.timeSteps(i)),'Interpreter', 'latex');
				% pause(0.1);

			end

			idx = 1800;
			r = pauseRA{idx}(:,1);
			a = pauseRA{idx}(:,2);
			h = figure;
			xlim([0 14])
			ylim([0.4 0.5]);
			hold on
			scatter(r,a);


			h = figure;
			plot(obj.result.timeSteps,N, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = 16;
			title('Cell count over time','Interpreter', 'latex','FontSize', 22);
			ylabel('N','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			xlim([0 obj.result.timeSteps(end)]);
			SavePlot(obj, h, sprintf('CellCount'));

			h = figure;
			plot(obj.result.timeSteps,mA, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = 16;
			title('Average cell area','Interpreter', 'latex','FontSize', 22);
			ylabel('Area','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			xlim([0 obj.result.timeSteps(end)]);
			SavePlot(obj, h, sprintf('AvgPauseArea'));

			h = figure;
			plot(obj.result.timeSteps,R80, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = 16;
			title('90\% Radius over time','Interpreter', 'latex','FontSize', 22);
			ylabel('Radius','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			xlim([0 obj.result.timeSteps(end)]);
			SavePlot(obj, h, sprintf('Radius80'));


		end

	end

end