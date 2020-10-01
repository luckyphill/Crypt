classdef RodsInChannelAngleAnalysis < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		% No input parameters needed

		r
		s
		g
		d
		w

		seed

		analysisName = 'RodsInChannelAngleAnalysis';

		parameterSet = []

		simulationRuns = 1
		slurmTimeNeeded = 24
		simulationDriverName = 'RodsInChannel'
		simulationInputCount = 7
		

	end

	methods

		function obj = RodsInChannelAngleAnalysis(varargin)

			% Each seed runs in a separate job
			obj.specifySeedDirectly = true;

			if ~isempty(varargin)
				obj.r = varargin{1};
			 	obj.s = varargin{2};
				obj.g = varargin{3};
				obj.d = varargin{4};
				obj.w = varargin{5};
				obj.seed = varargin{6};
				obj.analysisName = sprintf('%s/r%gs%gg%gd%gw%g_seed%g',obj.analysisName,obj.r,obj.s,obj.g,obj.d,obj.w,obj.seed);
			end

		end

		function MakeParameterSet(obj)

			obj.parameterSet = [];

		end

	

		function AssembleData(obj)

			% Just need to load the time series as in the visaliser
			if isempty(obj.r)
				obj.result = Visualiser('RodsInChannel/SpatialState/');
			else
				pathName = sprintf('RodsInChannel/r%gs%gg%gd%gw%g_seed%g/SpatialState/',obj.r,obj.s,obj.g,obj.d,obj.w,obj.seed);
				obj.result = Visualiser(pathName);
			end

		end

		function PlotData(obj, varargin)

			h = figure;

			angles = 0;
			% hs = histogram(angles, [-1.6:0.2:1.6], 'Normalization', 'probability');
			% xlim([-1.6 1.6]);
			% ylim([0  0.25]);\
			A = [];
			Q = [];
			L = [];
			lengths = [];
			% hs = histogram(angles, [0:0.2:1.6], 'Normalization', 'probability');
			xlim([0 1.6]);
			ylim([0  0.5]);
			[I,~] = size(obj.result.cells);
			startI = 1;
			if ~isempty(varargin)
				startI = varargin{1};
			end

			% i = 1900;
			for i = startI:I
				% i is the time steps
				[~,J] = size(obj.result.cells);
				j = 1;
				angles = [];
				while j <= J && ~isempty(obj.result.cells{i,j})

					c = obj.result.cells{i,j};
					ids = c(1:end-1);
					colour = c(end);
					nodeCoords = squeeze(obj.result.nodes(ids,i,:));

					x = nodeCoords(:,1);
					y = nodeCoords(:,2);

					angles(j) = atan( (x(1)-x(2)) / (y(1)-y(2)));
					if colour == 6
						lengths(end + 1) = norm(nodeCoords(1,:) - nodeCoords(2,:));
					end

					j = j + 1;

				end
				% j will always end up being 1 more than the total number of non empty cells

				Q(end + 1) = sqrt(  mean(cos( 2.* angles))^2 + mean(sin( 2.* angles))^2   );
				A(end + 1) = mean(abs(angles));
				L(end + 1) = mean(lengths);
				% hs.Data = abs(angles);
				% drawnow
				% title(sprintf('t = %g',obj.result.timeSteps(i)),'Interpreter', 'latex');
				% pause(0.1);

			end

			plot(obj.result.timeSteps,Q, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = 16;
			% title('Disorder factor Q over time','Interpreter', 'latex','FontSize', 22);
			ylabel('Q','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			ylim([0 1.1]);; xlim([0 180]);
			SavePlot(obj, h, sprintf('QFactor'));
			
			h = figure;
			plot(obj.result.timeSteps,A, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = 16;
			% title('Average angle over time','Interpreter', 'latex','FontSize', 22);
			ylabel('Avg. angle','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			ylim([0 1.7]); xlim([0 180]);
			SavePlot(obj, h, sprintf('AvgAngle'));

			h = figure;
			plot(obj.result.timeSteps,L, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = 16;
			% title('Average length over time','Interpreter', 'latex','FontSize', 22);
			ylabel('Avg. length','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			ylim([0.25 0.55]); xlim([0 180]);
			SavePlot(obj, h, sprintf('AvgLength'));

			figure
			h1 = subplot(3,1,1);xlim([-6 6]);ylim([-0.1 2.6]);
			h2 = subplot(3,1,2);xlim([-6 6]);ylim([-0.1 2.6]);
			h3 = subplot(3,1,3);xlim([-6 6]);ylim([-0.1 2.6]);

			obj.result.PlotRodTimeStep(1100);
			copyobj(allchild(gca),h1);

			obj.result.PlotRodTimeStep(1350);
			copyobj(allchild(gca),h2);

			obj.result.PlotRodTimeStep(1600);
			copyobj(allchild(gca),h3);

			SavePlot(obj, figure(4), sprintf('TimeSnapShots'));


		end

	end

end