classdef LayerOnStromaTippingPoint < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		% Analyses the tipping point value for the wiggle ratio

		p = 10;
		g = 10;

		w = 10;
		n = 20;

		b = 10;

		sae = 10;
		spe = 2;

		seed = 1:100;

		targetTime = 500;

		analysisName = 'LayerOnStromaTippingPoint';

		parameterSet = []

		simulationRuns = 100
		slurmTimeNeeded = 24
		simulationDriverName = 'RunLayerOnStroma'
		simulationInputCount = 7
		

	end

	methods

		function obj = LayerOnStromaTippingPoint(n,p,g,w,b,sae,spe, runs)

			% Each seed runs in a separate job
			obj.specifySeedDirectly = true;

			obj.n = n;
			obj.p = p;
			obj.g = g;
			obj.w = w;
			obj.b = b;
			obj.sae = sae;
			obj.spe = spe;
			obj.seed = 1:runs;

			obj.analysisName = sprintf('%s/n%d_p%g_g%g_w%g_b%g_sae%g_spe%g',obj.analysisName,n,p,g,w,b,sae,spe);

		end

		function MakeParameterSet(obj)

			obj.parameterSet = [obj.n,obj.p,obj.g,obj.w,obj.b,obj.sae,obj.spe];

		end

		

		function BuildSimulation(obj)

			obj.MakeParameterSet();
			obj.ProduceSimulationFiles();
			
		end

		function AssembleData(obj)

			% Used when there is at least some data ready
			MakeParameterSet(obj);
			bottom = [];
			for j = obj.seed
				a = RunLayerOnStroma(obj.n,obj.p,obj.g,obj.w,obj.b,obj.sae,obj.spe,j);
				a.LoadSimulationData();
				bottom = Concatenate(obj, bottom, a.data.bottomWiggleData');
			end

			% Find the tipping point when all buckle
			jumpsize = 10;
			J = 1:length(bottom)-jumpsize;
			% sortc = sort(bottom,1);
			% sortc(sortc > 1.1) = nan;
			diffc = bottom(:,J+jumpsize) - bottom(:,J);
			
			% diffc(diffc < 0.9) = nan;
			% [~,I] = max(diffc);
			% nanmean(max(sortc(I,:)));
			% nanmean(bottom(:))
			% obj.result = sortc;
			figure;plot(bottom')
			figure;plot(diffc')
			% Find the tipping point when none buckle
			% max(bottom(:))

		end

		function PlotData(obj)

			h = figure;

			data = obj.result;

			params = obj.parameterSet(:,[5,7]);

			scatter(params(:,2), params(:,1), 100, data,'filled');
			ylabel('Membrane adhesion','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy','Interpreter', 'latex', 'FontSize', 15);
			title(sprintf('Proportion buckled'),'Interpreter', 'latex', 'FontSize', 22);
			ylim([0.5 20.5]);xlim([-0.5 21.5]);
			colorbar; caxis([0 1]);
			colormap jet;
			ax = gca;
			c = ax.Color;
			ax.Color = 'black';
			set(h, 'InvertHardcopy', 'off')

			SavePlot(obj, h, sprintf('TippingPoint'));


		end

	end

end