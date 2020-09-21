classdef LayerOnStromaPhaseTest < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT
		p = 5:.5:13;
		g = 5:.5:12;

		w = 10;
		n = 20;

		b = 10;

		sae = 10;
		spe = [5, 10, 15, 20];

		seed = 1:20;

		targetTime = 500;

		analysisName = 'LayerOnStromaPhaseTest';

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

		function obj = LayerOnStromaPhaseTest()

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

			for spe = obj.spe


				h = figure;

				Lidx = obj.parameterSet(:,7) == spe;
				dataP = obj.result(Lidx,1);
				dataT = obj.result(Lidx,2);

				params = obj.parameterSet(Lidx,[2,3]);

				scatter(params(:,2), params(:,1), 100, dataP,'filled');
				ylabel('Pause','Interpreter', 'latex', 'FontSize', 15);xlabel('Grow','Interpreter', 'latex', 'FontSize', 15);
				title(sprintf('Proportion buckled, spe=%d', spe),'Interpreter', 'latex', 'FontSize', 22);
				ylim([4.5 13.5]);xlim([4.5 12.5]);
				colorbar; caxis([0 1]);
				colormap jet;
				ax = gca;
				c = ax.Color;
				ax.Color = 'black';
				set(h, 'InvertHardcopy', 'off')
				set(h,'color','w');

				SavePlot(obj, h, sprintf('PhaseTestProp_spe%d',spe));

				h = figure;
				scatter(params(:,2), params(:,1), 100, dataT,'filled');
				ylabel('Pause','Interpreter', 'latex', 'FontSize', 15);xlabel('Grow','Interpreter', 'latex', 'FontSize', 15);
				title(sprintf('Tipping point, p=%g, g=%g',p,g),'Interpreter', 'latex', 'FontSize', 22);
				ylim([1 41]);xlim([1.5 15.5]);
				colorbar; caxis([1 1.1]);
				colormap jet;
				ax = gca;
				c = ax.Color;
				ax.Color = 'black';
				set(h, 'InvertHardcopy', 'off')
				set(h,'color','w');

				SavePlot(obj, h, sprintf('PhaseTestTip_spe%d',spe));

			end

			h = figure;
			leg = {};
			for spe = 5:5:20
				leg{end+1} = sprintf('spe=%d',spe);
				Lidx = obj.parameterSet(:,7) == spe;
				data = obj.result(Lidx);
				para = obj.parameterSet(Lidx,:);

				Lidx = (data > 0.4);

				data = data(Lidx);
				para = para(Lidx,:);

				Lidx = (data < 0.6);

				data = data(Lidx);
				para = para(Lidx,:);

				x = para(:,3);
				y = para(:,2);

				hold on
				% scatter(x,y,100,'filled');
				% Perform a least squares regression
				b = [ones(size(x)),x]\y;
				p = b' * [ones(size(obj.g)); obj.g];
				plot(obj.g,p,'LineWidth', 4)

			end

			ylabel('Pause','Interpreter', 'latex', 'FontSize', 15);xlabel('Grow','Interpreter', 'latex', 'FontSize', 15);
			title(sprintf('Proportion buckled = 0.5'),'Interpreter', 'latex', 'FontSize', 22);
			ylim([4.5 13.5]);xlim([4.5 12.5]);
			legend(leg);
			SavePlot(obj, h, sprintf('PhaseTestWaveFront_spe%d',spe));

		end

	end

end