classdef LayerOnStromaBvsSPE < Analysis

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

		b = 1:20;

		sae = 10;
		spe = 0:21;

		seed = 1:20;

		targetTime = 500;

		analysisName = 'LayerOnStromaBvsSPE';

		parameterSet = []

		simulationRuns = 20
		slurmTimeNeeded = 24
		simulationDriverName = 'RunLayerOnStroma'
		simulationInputCount = 7
		

	end

	methods

		function obj = LayerOnStromaBvsSPE()

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
			notip = nan(1,length(obj.parameterSet));
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
						if max(bottom) > 1.1
							count = count + 1;
						end
						collection = Concatenate(obj, collection, bottom');
					% end
				end

				% Three cases:
				% 1. No buckling. We choose the largest ratio achieved and store it in notip
				% 2. Some buckle. Find the biggest jump at the end
				% 3. All buckle. Search the full time series
				jumpSize = 3;
				if max(collection(:)) < 1.1
					notip(i) = max(collection(:))
				else
					if min(collection(:,end)) > 1.4

						J = obj.seed(1:end-jumpSize);
						sortc = sort(collection,1);
						diffc = sortc(J+jumpSize,:) - sortc(J,:);
						diffc(diffc < 0.3) = nan;
						% [~,I] = max(diffc);
						% nanmean(max(sortc(I,:)))
						% obj.result = sortc(:,I);
						
						if mdiffc > 0.3
							tip(i) = sortc(k);
						end

					else
						last = collection(:,end);
						J = obj.seed(1:end-jumpSize);
						sortc = sort(last);
						diffc = sortc(J+jumpSize) - sortc(J);
						[mdiffc,k] = max(diffc);
						
						if mdiffc > 0.3
							tip(i) = sortc(k);
						end

					end
				end

				prop(i) = count / obj.simulationRuns;

				obj.result(i,:) = [prop(i), tip(i)];

				fprintf("Completed %.2f %%\n", 100*i/length(obj.parameterSet));
			end

		end

		function PlotData(obj)

			h = figure;

			dataP = obj.result(:,1);
			dataT = obj.result(:,2);

			params = obj.parameterSet(:,[5,7]);

			scatter(params(:,2), params(:,1), 100, dataP,'filled');
			ylabel('Membrane adhesion','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy','Interpreter', 'latex', 'FontSize', 15);
			title(sprintf('Proportion buckled'),'Interpreter', 'latex', 'FontSize', 22);
			ylim([0.5 20.5]);xlim([-0.5 21.5]);
			colorbar; caxis([0 1]);
			colormap jet;
			ax = gca;
			c = ax.Color;
			ax.Color = 'black';
			set(h, 'InvertHardcopy', 'off')
			set(h,'color','w');

			SavePlot(obj, h, sprintf('BvsSPEProp'));

			h = figure;
			scatter(params(:,2), params(:,1), 100, dataT,'filled');
			ylabel('Membrane adhesion','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy','Interpreter', 'latex', 'FontSize', 15);
			title(sprintf('Tipping point'),'Interpreter', 'latex', 'FontSize', 22);
			ylim([0.5 20.5]);xlim([-0.5 21.5]);
			colorbar; caxis([1 1.1]);
			colormap jet;
			ax = gca;
			c = ax.Color;
			ax.Color = 'black';
			set(h, 'InvertHardcopy', 'off')
			set(h,'color','w');

			SavePlot(obj, h, sprintf('BvsSPETip'));


		end

	end

end