classdef LayerOnStromaBodyParams < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT
		p = [5,10,15];
		g = [5,10,15];

		w = 10;
		n = 20;

		b = 10;

		sae = [1:0.5:5,6:2:20];
		spe = [1:0.25:5,6:10];

		seed = 1:5;

		targetTime = 1000;

		analysisName = 'LayerOnStromaBodyParams';

		avgGrid = {}
		timePoints = {}

		stabilityGrids = {};

		parameterSet = []

		simulationRuns = 5
		slurmTimeNeeded = 72
		simulationDriverName = 'RunLayerOnStroma'
		simulationInputCount = 7
		

	end

	methods

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

		function obj = LayerOnStromaBodyParams()

			

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
				for j = obj.seed
					% try
						a = RunLayerOnStroma(n,p,g,w,b,sae,spe,j);
						a.LoadSimulationData();
						bottom = Concatenate(obj, bottom, a.data.bottomWiggleData');
					% end
				end

				b = nanmean(bottom);

				result(i) = max(b);


			end


			obj.result = result;

			

		end

		function PlotData(obj)

			for p = obj.p
				for g = obj.g

					h = figure;

					Lidx = obj.parameterSet(:,2) == p;
					tempR = obj.result(Lidx);
					Lidx = obj.parameterSet(Lidx,3) == g;
					data = tempR(Lidx);

					data = reshape(data,length(obj.spe),length(obj.sae));

					[A,P] = meshgrid(obj.sae,obj.spe);

					surf(A,P,data);
					xlabel('Area force parameter','Interpreter', 'latex', 'FontSize', 15);ylabel('Perimeter force parameter','Interpreter', 'latex', 'FontSize', 15);
					title(sprintf('Long term max wiggle ratio for stroma force params'),'Interpreter', 'latex', 'FontSize', 22);
					shading interp
					xlim([2 20]);ylim([1 10]);
					colorbar;view(90,-90);caxis([1 1.5]);

					SavePlot(obj, h, sprintf('BodyParams'));
					
				end

			end

		end

	end

end