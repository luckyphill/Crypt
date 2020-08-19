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

		result

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
			result = nan(1,length(obj.parameterSet));
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
				count = 0;
				for j = obj.seed
					% try
						a = RunLayerOnStroma(n,p,g,w,b,sae,spe,j);
						a.LoadSimulationData();
						bottom = a.data.bottomWiggleData;
						if max(bottom) > 1.05
							count = count + 1;
						end
					% end
				end

				result(i) = count / obj.simulationRuns;

				fprintf("Completed %.2f %%\n", 100*i/length(obj.parameterSet));
			end


			obj.result = result;

			

		end

		function PlotData(obj)

			% AssembleData(obj);


			for p = obj.p
				for g = obj.g


					h = figure;

					Lidx = obj.parameterSet(:,2) == p;
					tempR = obj.result(Lidx);
					Lidx = obj.parameterSet(Lidx,3) == g;
					data = tempR(Lidx);

					params = obj.parameterSet(Lidx,[6,7]);

					% data = reshape(obj.result,10,20);

					% [A,P] = meshgrid(obj.spe,obj.sae);

					% surf(P,A,data');

					scatter(params(:,2), params(:,1), 100, data,'filled');
					ylabel('Area energy parameter','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
					title(sprintf('Proportion buckled, p=%g, g=%g',p,g),'Interpreter', 'latex', 'FontSize', 22);
					shading interp
					ylim([1 41]);xlim([1.5 15.5]);
					colorbar; caxis([0 1]);
					colormap jet;
					ax = gca;
					c = ax.Color;
					ax.Color = 'black';
					set(h, 'InvertHardcopy', 'off')

					SavePlot(obj, h, sprintf('BodyParams'));

				end
			end

		end

	end

end