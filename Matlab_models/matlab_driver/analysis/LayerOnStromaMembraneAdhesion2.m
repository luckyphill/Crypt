classdef LayerOnStromaMembraneAdhesion2 < Analysis

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

		b = [4,6,8,10,14,20];

		sae = 10;
		spe = 0:10;

		seed = 1:100;

		targetTime = 500;

		analysisName = 'LayerOnStromaMembraneAdhesion2';

		avgGrid = {}
		timePoints = {}

		stabilityGrids = {};

		result

		parameterSet = []

		simulationRuns = 100
		slurmTimeNeeded = 24
		simulationDriverName = 'RunLayerOnStroma'
		simulationInputCount = 7 % The number of parameters the driver function needs, not including the seed
		

	end

	methods

		function obj = LayerOnStromaMembraneAdhesion2()

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
				valid = 0;
				for j = obj.seed
					% try
						a = RunLayerOnStroma(n,p,g,w,b,sae,spe,j);
						a.LoadSimulationData();
						bottom = a.data.bottomWiggleData;
						if length(bottom) ~= 1
							valid = valid + 1;
							if max(bottom) > 1.05
								count = count + 1;
							end
						end
					% end
				end

				result(i) = count / valid;

				fprintf("%3d buckled out of %3d. Completed %.2f %%\n",count, valid, 100*i/length(obj.parameterSet));


			end


			obj.result = result;

			

		end

		function PlotData(obj)

			% AssembleData(obj);

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
			title(sprintf('Proportion buckled with p=g=%d', obj.p),'Interpreter', 'latex', 'FontSize', 22);
			xlim([0 10]);ylim([0 1]);
			legend(leg);
			SavePlot(obj, h, sprintf('PerimeterEnergy_b%g',b));

		end 
			
			

	end

end