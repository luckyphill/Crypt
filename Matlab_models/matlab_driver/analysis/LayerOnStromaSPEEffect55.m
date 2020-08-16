classdef LayerOnStromaSPEEffect55 < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT
		p = 5;
		g = 5;

		w = 10;
		n = 20;

		b = 10;

		sae = 10;
		spe = 10:0.1:20;

		seed = 1:20;

		targetTime = 500;

		analysisName = 'LayerOnStromaSPEEffect55';

		avgGrid = {}
		timePoints = {}

		stabilityGrids = {};

		result

		parameterSet = []

		simulationRuns = 20
		slurmTimeNeeded = 24
		simulationDriverName = 'RunLayerOnStroma'
		simulationInputCount = 7 % The number of parameters the driver function needs, not including the seed
		

	end

	methods

		function obj = LayerOnStromaSPEEffect55()
			% Same as LayerOnStromaSPEEffect, except a different range of spe for the case (p,g) = (5,5)
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
						if max(bottom) > 1.05
							count = count + 1;
						end
					% end
				end

				result(i) = count / obj.simulationRuns;


			end


			obj.result = result;

			

		end

		function PlotData(obj)

			AssembleData(obj);


			for p = obj.p

				h = figure;
				for g = obj.g


					

					Lidx = obj.parameterSet(:,2) == p;
					tempR = obj.result(Lidx);
					Lidx = obj.parameterSet(Lidx,3) == g;
					data = tempR(Lidx);

					plot(obj.spe, data,'LineWidth', 4)
					hold on
					

				end

				ylabel('Chance of buckling','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter force parameter','Interpreter', 'latex', 'FontSize', 15);
				title(sprintf('Chance of buckling with p = %g', p),'Interpreter', 'latex', 'FontSize', 22);
				xlim([0 10]);ylim([0 1]);

				SavePlot(obj, h, sprintf('BodyParams_vs_PhaseLength'));
			end

		end

	end

end