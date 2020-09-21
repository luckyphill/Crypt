classdef LayerOnStromaSAENoEffect2 < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT
		p = 5;
		g = 10;

		w = 10;
		n = 20;

		b = 10;

		sae = [2:2:40];
		spe = [2:0.5:15];

		seed = 1:20;

		targetTime = 500;

		analysisName = 'LayerOnStromaSAENoEffect2';

		avgGrid = {}
		timePoints = {}

		stabilityGrids = {};

		parameterSet = []

		simulationRuns = 20
		slurmTimeNeeded = 24
		simulationDriverName = 'RunLayerOnStroma'
		simulationInputCount = 7
		

	end

	methods

		function obj = LayerOnStromaSAENoEffect2()

			% Each seed runs in a separate job
			obj.specifySeedDirectly = true;

		end

		function MakeParameterSet(obj)


			params = [];

			for p = obj.p
				for g = obj.g
					for w = obj.w
						for b = obj.b
							for sae = obj.sae
								for spe = obj.spe

									params(end+1,:) = [2*w,p,g,w,b,sae,spe];

								end
							end
						end
					end
				end
			end

			

			obj.parameterSet = params;

		end

		

		function BuildSimulation(obj)

			obj.MakeParameterSet();
			obj.ProduceSimulationFiles();
			
		end

		function AssembleData(obj)

			% Used when there is at least some data ready
			MakeParameterSet(obj);
			obj.result = [nan,nan];
			tip = nan(1,length(obj.parameterSet));
			prop = nan(1,length(obj.parameterSet));
			for i = 1:length(obj.parameterSet)
				s = obj.parameterSet(i,:);
				n = s(1);
				p = s(2);
				g = s(3);
				w = s(4);
				b = s(5);
				sae = s(6);
				spe = s(7);


				bottom = [];
				collection = [];
				count = 0;
				for j = obj.seed
					% try
						a = RunLayerOnStroma(n,p,g,w,b,sae,spe,j);
						a.LoadSimulationData();
						bottom = a.data.bottomWiggleData;
						collection(j) = max(bottom);
						if collection(j) > 1.1
							count = count + 1;
						end
					% end
				end

				jumpSize = 3;
				J = obj.seed(1:end-jumpSize);
				sortc = sort(collection);
				diffc = sortc(J+jumpSize) - sortc(J);
				[mdiffc,k] = max(diffc);
				
				if mdiffc > 0.3
					tip(i) = sortc(k);
				end

				prop(i) = count / obj.simulationRuns;

				obj.result(i,:) = [prop(i), tip(i)];

				fprintf("Completed %.2f %%\n", 100*i/length(obj.parameterSet));
			end

		end

		function PlotData(obj)

			for p = obj.p
				for g = obj.g


					

					Lidx = obj.parameterSet(:,2) == p;
					tempP = obj.result(Lidx,1);
					tempT = obj.result(Lidx,2);
					Lidx = obj.parameterSet(Lidx,3) == g;
					dataP = tempP(Lidx);
					dataT = tempT(Lidx);

					params = obj.parameterSet(Lidx,[6,7]);

					% data = reshape(obj.result,10,20);

					% [A,P] = meshgrid(obj.spe,obj.sae);

					% surf(P,A,data');
					h = figure;
					scatter(params(:,2), params(:,1), 100, dataP,'filled');
					ylabel('Area energy parameter','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
					title(sprintf('Proportion buckled, p=%g, g=%g',p,g),'Interpreter', 'latex', 'FontSize', 22);
					ylim([1 41]);xlim([1.5 15.5]);
					colorbar; caxis([0 1]);
					colormap jet;
					ax = gca;
					c = ax.Color;
					ax.Color = 'black';
					set(h, 'InvertHardcopy', 'off')
					set(h,'color','w');

					SavePlot(obj, h, sprintf('BodyParamsProp'));


					h = figure;
					scatter(params(:,2), params(:,1), 100, dataT,'filled');
					ylabel('Area energy parameter','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
					title(sprintf('Tipping point, p=%g, g=%g',p,g),'Interpreter', 'latex', 'FontSize', 22);
					ylim([1 41]);xlim([1.5 15.5]);
					colorbar; caxis([1 1.06]);
					colormap jet;
					ax = gca;
					c = ax.Color;
					ax.Color = 'black';
					set(h, 'InvertHardcopy', 'off')
					set(h,'color','w');

					SavePlot(obj, h, sprintf('BodyParamsTip'));

				end
			end

		end

	end

end