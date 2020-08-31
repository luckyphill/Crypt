classdef LayerOnStromaMembraneAdhesion < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT
		p = 10;
		g = 10;

		w = 10;
		n = 20;

		b = 2:2:20;

		sae = 10;
		spe = 0:0.1:10;

		seed = 1:20;

		targetTime = 500;

		analysisName = 'LayerOnStromaMembraneAdhesion';

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

		function obj = LayerOnStromaMembraneAdhesion()

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
									% Skip the case (p,g) = (5,5) because we need a slightly modified range
									if p~=5 || g~=5
										params(end+1,:) = [2*w,p,g,w,b,sae,spe];
									end

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
			for i = 1:700%length(obj.parameterSet)
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

			% g held constant on one plot
			h = figure;
			leg = {};
			for b = obj.b

				Lidx = obj.parameterSet(:,5) == b;
				data = obj.result(Lidx);

				plot(obj.spe, data,'LineWidth', 4)
				hold on
				
				leg{end+1} = sprintf('b=%g',b);

			end

			ylabel('Proportion','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
			title(sprintf('Proportion buckled with b = %g', b),'Interpreter', 'latex', 'FontSize', 22);
			xlim([0 10]);ylim([0 1]);
			legend(leg);
			SavePlot(obj, h, sprintf('PerimeterEnergy_b%g',b));

		end 
			
			

	end

end