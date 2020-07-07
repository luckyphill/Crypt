classdef CritcalRatio < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT
		p = 10:5:30;
		g = 10:5:30;

		w = 5:20;
		% n = 2*w;

		b = 0:10;

		seed = 1:5;

		targetTime = 1000;

		analysisName = 'CritcalRatio';

		avgGrid = {}
		timePoints = {}

		stabilityGrids = {};

		result

		parameterSet = []

		simulationRuns = 5
		slurmTimeNeeded = 72
		simulationDriverName = 'RunBeamMembranePinned'
		simulationInputCount = 5
		
		top
		middle
		bottom

	end

	methods

		function MakeParameterSet(obj)

			% This sweeps the parameter space coarsely where we know it to be
			% flat or buckled, and finely when it transitions between the
			% two states

			params = [];

			for p = 10:5:30

				w = 5;
				b = 0;
				

				h = 1.5;

				while w <= 20
					b = 0;
					while b <= 10
						if w - h < sqrt( (p-5)*b/2 ) + 5 && w + h > sqrt( (p-5)*b/2 ) + 5
							params(end + 1,:) = [floor(2*w),p,p,w,b];
						end
						b = b + 0.1;
					end
					w = w + 0.1;
				end

				w = 5;
				b = 0;

				while w <= 20
					b = 0;
					while b <= 10
						if w - h > sqrt( (p-5)*b/2 ) + 5 || w + h < sqrt( (p-5)*b/2 ) + 5
							params(end + 1,:) = [floor(2*w),p,p,w,b];
						end
						b = b + 1;
					end
					w = w + 1;
				end

			end

			obj.parameterSet = params;

		end

		function obj = CritcalRatio()

			

		end

		function BuildSimulation(obj)

			obj.MakeParameterSet();
			obj.ProduceSimulationFiles();
			
		end

		function AssembleData(obj)

			% Used when there is at least some data ready
			MakeParameterSet(obj);
			result = nan(1,length(obj.parameterSet));
			top = [];
			middle = [];
			bottom = [];
			for i = 1:length(obj.parameterSet)
				s = obj.parameterSet(i,:);
				n = s(1);
				p = s(2);
				g = s(3);
				w = s(4);
				b = s(5);

				if p == 10 && n == 10 % For intial test only

					
					for j = obj.seed
						% try
							a = RunBeamMembranePinned(n,p,p,w,b,j);
							a.LoadSimulationData();
							bottom = Concatenate(obj, bottom, a.data.bottomWiggleData');
						% end
					end

				end % For intitial test only

			end

			obj.bottom = bottom;


		end

		function ProcessData(obj)

			% For each wiggle ratio, count the number of simulation
			% where the maximum does not exceed wr, then find the first plateau
			wr = 1:0.0001:1.6;
			wr_count = zeros(size(wr));
			
			L = ~isnan(obj.bottom(:,1));
			d = obj.bottom(L,:);
			[n,~] = size(d);

			for i = 1:n
				m = max(d(i,:));
				for j = 1:length(wr)
					if m < wr(j)
						wr_count(j) = wr_count(j) +1;
					end
				end
			end

			figure
			pwr = wr_count/n;
			plot(wr, pwr);

			h = pwr(2:end) - pwr(1:(end-1));

			figure
			plot(wr(2:end), h);

		end

		function PlotData(obj)

			% AssembleData(obj)

			for p = 10 %obj.p

				L = obj.parameterSet(:,2) == p;
				X = obj.parameterSet(L,4);
				Y = obj.parameterSet(L,5);
				Z = obj.result(L);
				% Strip the nans
				Ln = ~isnan(Z);
				X = X(Ln);
				Y = Y(Ln);
				Z = Z(Ln);

				% Since we have an irregular grid, we need to regularise it in order to plot the
				% surface properly. A linear interpolation is sufficient here
				fo = fit([X,Y],Z','linearinterp');

				h = figure;
				w = 5:0.01:20;
				b = 0:0.01:10;
				[w,b] = meshgrid(w,b);
				
				surf(w,b,fo(w,b));
				% The x and y labels are flipped a bit... this makes it work so don't change it
				ylabel('Restoring force','Interpreter', 'latex', 'FontSize', 15);xlabel('Width','Interpreter', 'latex', 'FontSize', 15);
				title(sprintf('Wiggle ratio stability regions for p = g = %dhrs',p),'Interpreter', 'latex', 'FontSize', 22);
				shading interp
				xlim([5 20]);ylim([0 10]);
				colorbar;view(90,-90);caxis([1 1.5]);

				SavePlot(obj, h, sprintf('Stability-p%dg%d',p,p));

			end

		end

	end

end