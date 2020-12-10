classdef RodsInChannelMultiAnalysis < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		% No input parameters needed

		n
		r
		s
		g
		d
		w

		seed

		analysisName = 'RodsInChannelMultiAnalysis';

		parameterSet = []

		simulationRuns = 1
		slurmTimeNeeded = 24
		simulationDriverName = 'RodsInChannel'
		simulationInputCount = 7

		allQ
		allL
		

	end

	methods

		function obj = RodsInChannelMultiAnalysis(n, r, s, g, d, w, seed)

			% Each seed runs in a separate job
			obj.specifySeedDirectly = true;

			obj.n = n;  
			obj.r = r;   
		 	obj.s = s;   
			obj.g = g;   
			obj.d = d;   
			obj.w = w;   
			obj.seed = seed;
			obj.analysisName = sprintf('%s/n%gr%gs%gg%gd%gw%g',obj.analysisName,obj.n,obj.r,obj.s,obj.g,obj.d,obj.w);


		end

		function MakeParameterSet(obj)

			obj.parameterSet = [];

		end

	

		function AssembleData(obj)

			allQ = [];
			allL = [];
			r = Visualiser.empty;
			for k = obj.seed
				pathName = sprintf('RodsInChannel/n%gr%gs%gg%gd%gw%g_seed%g/SpatialState/',obj.n,obj.r,obj.s,obj.g,obj.d,obj.w,k);
				r = Visualiser(pathName);

				angles = 0;

				Q = [];
				L = [];
				lengths = [];

				[I,~] = size(r.cells);
				for i = 1:I
					% i is the time steps
					[~,J] = size(r.cells);
					j = 1;
					angles = [];
					while j <= J && ~isempty(r.cells{i,j})

						c = r.cells{i,j};
						ids = c(1:end-1);
						colour = c(end);
						nodeCoords = squeeze(r.nodes(ids,i,:));

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
					L(end + 1) = mean(lengths);

				end

				allQ = Concatenate(obj, allQ, Q);
				allL = Concatenate(obj, allL, L);

			end

			obj.result = {allQ, allL};

		end

		function PlotData(obj, varargin)

			

			allQ = obj.result{1};
			allL = obj.result{2};

			tFontSize = 40;
			lFontSize = 20;
			aFontSize = 24;

			t = 0.1:0.1:200;
			

			mQ = nanmean(allQ);
			uQ = mQ + sqrt(nanvar(allQ));
			bQ = mQ - sqrt(nanvar(allQ));
			% figure;plot(sqrt(nanvar(allQ)))
			h = figure;
			plot(t,mQ, 'LineWidth', 4);
			hold on
			fill([t,fliplr(t)], [uQ,fliplr(bQ)], [0, .45, 0.74], 'FaceAlpha', 0.25, 'EdgeAlpha',0);
			ax = gca;
			ax.FontSize = 16;
			% title('Disorder factor Q over time','Interpreter', 'latex','FontSize', 22);
			ylabel('Q','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			ylim([0 0.6]);; xlim([0 200]);
			SavePlot(obj, h, sprintf('QFactor'));


			mL = nanmean(allL);
			uL = mL + 2*sqrt(nanvar(allL));
			bL = mL - 2*sqrt(nanvar(allL));

			uT = t(~isnan(uL));
			uL = uL(~isnan(uL));

			bT = t(~isnan(bL));
			bL = bL(~isnan(bL));
			
			h = figure;
			plot(t,mL, 'LineWidth', 4);
			hold on
			fill([bT,fliplr(uT)], [bL,fliplr(uL)], [0, .45, 0.74], 'FaceAlpha', 0.25, 'EdgeAlpha',0);
			ax = gca;
			ax.FontSize = 16;
			% title('Average length over time','Interpreter', 'latex','FontSize', 22);
			ylabel('Avg. length','Interpreter', 'latex', 'FontSize', 40);xlabel('time','Interpreter', 'latex', 'FontSize', 40);
			ylim([0.25 0.55]); xlim([0 200]);
			SavePlot(obj, h, sprintf('AvgLength'));

			




		end

	end

end