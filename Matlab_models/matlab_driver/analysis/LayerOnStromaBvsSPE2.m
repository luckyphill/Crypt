classdef LayerOnStromaBvsSPE2 < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		% Constant cell cycle length, and decreasing even cell cycle length
		% This will be used in conjunction with LayerOnStromaBvsSPE
		p = [5, 15];
		g = [5, 15];

		w = 10;
		n = 20;

		b = 1:20;

		sae = 10;
		spe = 0:21;

		seed = 1:20;

		targetTime = 500;

		analysisName = 'LayerOnStromaBvsSPE2';

		parameterSet = []

		simulationRuns = 20
		slurmTimeNeeded = 24
		simulationDriverName = 'RunLayerOnStroma'
		simulationInputCount = 7
		

	end

	methods

		function obj = LayerOnStromaBvsSPE2()

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

			SavePlot(obj, h, sprintf('BvsSPE'));


		end

	end

end