classdef CritcalWiggleRatioBeamMembrane < Analysis

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

		analysisName = 'CritcalWiggleRatioBeamMembrane';

		avgGrid = {}
		timePoints = {}

		stabilityGrids = {};

		parameterSet = []

		simulationRuns = 5
		slurmTimeNeeded = 72
		simulationDriverName = 'RunBeamMembranePinned'
		simulationInputCount = 5
		

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

		function obj = CritcalWiggleRatioBeamMembrane()

			

		end

		function BuildSimulation(obj)

			obj.MakeParameterSet();
			obj.ProduceSimulationFiles();
			
		end

		function AssembleData(obj)

			% Used when there is at least some data ready

			

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