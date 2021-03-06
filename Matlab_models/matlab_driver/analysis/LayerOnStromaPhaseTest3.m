classdef LayerOnStromaPhaseTest3 < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		% This is to demonstrate that we only need to increase the parameter space resolution
		% not the number of simulation runs

		% MORE SIMULATION RUNS
		p = 5:15;
		g = 5:15;

		w = 10;
		n = 20;

		b = 10;

		sae = 10;
		spe = 15;

		seed = 1:100;

		targetTime = 500;

		analysisName = 'LayerOnStromaPhaseTest3';

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

		function obj = LayerOnStromaPhaseTest3()

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

		function params = BuildParametersWithSeed(obj)

			% This expects the seed property to be a vector of the seeds that will be applied
			% to each simulation. Each sim will have the same seeds. If different seeds
			% are required every time, this is not going to help you

			params = [];
			for i = 1:length(obj.parameterSet)
				s = obj.parameterSet(i,:);
				n = s(1);
				p = s(2);
				g = s(3);
				w = s(4);
				b = s(5);
				sae = s(6);
				spe = s(7);

				% An empirically determined formula to decide if the region likely to have no buckling
				if p > -1.3 * g - 3*log(spe) + 29.7 || p < -1.3 * g - 3*log(spe) + 22.8
					for seed = obj.seed
						params(end+1,:) = [obj.parameterSet(i,:), seed];
					end
				end

				
			end

		end

		

		function BuildSimulation(obj)

			obj.MakeParameterSet();
			obj.ProduceSimulationFiles();
			
		end

		function AssembleData(obj)

			% Used when there is at least some data ready
			MakeParameterSet(obj);
			obj.result = nan(1,length(obj.parameterSet));
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

				obj.result(i) = count / valid;

				fprintf("%3d buckled out of %3d. Completed %.2f %%\n",count, valid, 100*i/length(obj.parameterSet));


			end
			

		end

		function PlotData(obj)

			for spe = obj.spe


				h = figure;

				Lidx = obj.parameterSet(:,7) == spe;
				data = obj.result(Lidx);

				params = obj.parameterSet(Lidx,[2,3]);

				scatter(params(:,2), params(:,1), 100, data,'filled');
				ylabel('Pause','Interpreter', 'latex', 'FontSize', 15);xlabel('Grow','Interpreter', 'latex', 'FontSize', 15);
				title(sprintf('Proportion buckled, spe=%d', spe),'Interpreter', 'latex', 'FontSize', 22);
				shading interp
				ylim([4 14]);xlim([4 13]);
				colorbar; caxis([0 1]);
				colormap jet;
				ax = gca;
				c = ax.Color;
				ax.Color = 'black';
				set(h, 'InvertHardcopy', 'off')
				set(h,'color','w');

				SavePlot(obj, h, sprintf('PhaseTest_spe%d',spe));

			end

		end

	end

end