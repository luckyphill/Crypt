classdef SSWiggleRatioBeamMembraneAnalysis < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made
		p = 10:5:30;
		g = 10:5:30;

		w = 5:20;
		n = 10:2:40;

		b = 0:10;

		seed = 1:10;

		targetTime = 1000;

		analysisName = 'SSWiggleRatioBeamMembraneAnalysis';

		avgGrid = {}
		timePoints = {}

		stabilityGrids = {}; 

	end

	methods

		function obj = SSWiggleRatioBeamMembraneAnalysis()

			% Uses the data produced by BuckleSweepFixedDomain to produce
			% a plot of the average time/number of cells/width at buckling

			dt = 0.001;
			for p = obj.p
				g = p;
				for w = obj.w
					for b = obj.b
						wD = [];
						for seed = obj.seed
							try
								% Sometimes the data might not exist
								a = RunBeamMembrane(2*w, p, g, w, b, seed);
								a.LoadSimulationData();
								temp = a.data.wiggleData(:,2)';

								if isempty(wD)
									wD = temp;
								else
									wD = obj.Concatenate(wD, temp);
								end

							end

						end

						

						fprintf('Completed p = %d, g = %d, w = %d, b = %d\n',p,g,w,b);
			
						% Varying numbers of ending entries will be nans, so use nan mean to remove them
						% This will mean the number of entries for each column may be decresing, so
						% expect the variance to increase for later values

						obj.avgGrid{p,w,b+1} = nanmean(wD,1);
						obj.timePoints{p,w,b+1} = 0:dt:dt*length(obj.avgGrid{p,w,b+1});

					end

				end

			end

		end

		function A = Concatenate(obj, A, b)

			% Adds row vector b to the bottom of matrix A
			% If padding is needed, nans are added to the right
			% side of the matrix or vector as appropriate


			if length(b) < length(A)
				% pad vector
				d = length(A) - length(b);
				b = [b, nan(1,d)];
			end
			
			if length(b) > length(A)
				% pad matrix
				d = length(b) - length(A);
				[m,n] = size(A);
				A = [A,nan(m,d)];
			end

			A = [A;b];

		end

		function StabilityRegions(obj)

			
			for p = obj.p

				stabGrid = nan(20, 11);
				for w = obj.w
					for b = obj.b

						stabGrid(w,b+1) = max(obj.avgGrid{p,w,b+1});

					end

				end
				obj.stabilityGrids{p} = stabGrid; 

			end

		end

		function PlotData(obj)

			StabilityRegions(obj)

			for p = obj.p

				h = figure;
				surf(obj.b,1:20, obj.stabilityGrids{p});
				xlabel('Restoring force','Interpreter', 'latex');ylabel('Width','Interpreter', 'latex');
				title(sprintf('Wiggle ratio stability regions for p = g = %dhrs',p),'Interpreter', 'latex')
				colorbar;view(0,90);caxis([1 1.5]);

				SavePlot(obj, h, sprintf('Stability-p%dg%d',p,p));

			end

		end

	end

end