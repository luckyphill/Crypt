classdef BuckleAnalysisFixedDomain < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made
		p = 11:40;
		g = 11:40;

		
		w = 10:20;
		n = 2 * w;

		seed = 1:10;

		timeGrid = nan(30,30);
		nGrid = nan(30,30);

		analysisName = 'BuckleAnalysisFixedDomain';

	end

	methods

		function obj = BuckleAnalysisFixedDomain()

			% Uses the data produced by BuckleSweepFixedDomain to produce
			% a plot of the average time/number of cells/width at buckling

			for p = 11:40
				for g = 11:40
					for w = 10:20
						
						t = 0;
						count = 0;
						for seed = 1:10
							try
								% Sometimes the data might not exist
								a = RunFixedDomainBuckle(obj.n, p, g, w, seed);
								a.LoadSimulationData();

								t = t + a.data.buckleData(1);

								count = count + 1;
							end

	                    end

	                    fprintf('Completed p = %d, g = %d, w = %d\n',p,g,w);
	    
						obj.timeGrid(p-4,g-4) = t / count;

					end

				end

			end

		end


		function PlotData(obj)


			[P,G] = meshgrid(5:50,5:50);
			% Plots for constant cell cycle length
			S = P + G;

			% Linewidth for plots
			lw = 2;

			%---------------------------------------------------------------------------------
			% Plot time to buckle
			%---------------------------------------------------------------------------------
			h = figure;

			subplot(2,2,1);
			surf(P,G,obj.timeGrid,'EdgeColor', 'None');
			xlabel('Pause','Interpreter', 'latex');ylabel('Growth','Interpreter', 'latex');
			xlim([5 50]);ylim([5 50])
			title(sprintf('Time to buckle'),'Interpreter', 'latex')
			colorbar;view(0,90);

			cct = 30;

			subplot(2,2,2);
			plot(P(G==cct), obj.timeGrid(G==cct), 'LineWidth', lw)
			xlabel('Pause','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Time to buckle: Growth = %d hr',cct),'Interpreter', 'latex')
			
			subplot(2,2,3);
			plot(G(P==cct), obj.timeGrid(P==cct), 'LineWidth', lw)
			xlabel('Growth','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Time to buckle: Pause = %d hr',cct),'Interpreter', 'latex')
			
			subplot(2,2,4);
			cct = 35;
			plot(P(S==cct), obj.timeGrid(S==cct), 'LineWidth', lw)
			xlabel('Pause','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Time to buckle: Growth + Pause = %d hr',cct),'Interpreter', 'latex')
			
			SavePlot(obj, h, 'Time')
			%---------------------------------------------------------------------------------


			%---------------------------------------------------------------------------------
			% Plot cell count at buckle:
			%---------------------------------------------------------------------------------
			h = figure;

			subplot(2,2,1);
			surf(P,G,obj.nGrid,'EdgeColor', 'None');
			xlabel('Pause','Interpreter', 'latex');ylabel('Growth','Interpreter', 'latex');
			xlim([5 50]);ylim([5 50])
			title(sprintf('Cell count at buckle'),'Interpreter', 'latex')
			colorbar;view(0,90);

			cct = 30;

			subplot(2,2,2);
			plot(P(G==cct), obj.nGrid(G==cct), 'LineWidth', lw)
			xlabel('Pause','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Cell count at buckle: Growth = %d hr',cct),'Interpreter', 'latex')
			
			subplot(2,2,3);
			plot(G(P==cct), obj.nGrid(P==cct), 'LineWidth', lw)
			xlabel('Growth','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Cell count at buckle: Pause = %d hr',cct),'Interpreter', 'latex')

			subplot(2,2,4);
			cct = 35;
			plot(P(S==cct), obj.nGrid(S==cct), 'LineWidth', lw)
			xlabel('Pause','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Cell count at buckle: Growth + Pause = %d hr',cct),'Interpreter', 'latex')
			
			SavePlot(obj, h, 'Count')
			%---------------------------------------------------------------------------------




			%---------------------------------------------------------------------------------
			% Scatter plots at buckle
			%---------------------------------------------------------------------------------
			h = figure;

			subplot(2,2,1);
			scatter3(obj.timeGrid(:),obj.nGrid(:),obj.widthGrid(:),'.')
			xlabel('Time','Interpreter', 'latex');ylabel('Number of cells','Interpreter', 'latex');zlabel('Width','Interpreter', 'latex')
			title(sprintf('Scatter plot at buckle: T vs N vs W'),'Interpreter', 'latex')

			subplot(2,2,2);
			scatter(obj.timeGrid(:),obj.widthGrid(:),'.')
			xlabel('Time','Interpreter', 'latex');ylabel('Width','Interpreter', 'latex')
			title(sprintf('Scatter plot at buckle: T vs W'),'Interpreter', 'latex')
			
			subplot(2,2,3);
			scatter(obj.nGrid(:),obj.widthGrid(:),'.')
			xlabel('Number of cells','Interpreter', 'latex');ylabel('Width','Interpreter', 'latex')
			title(sprintf('Scatter plot at buckle: N vs W'),'Interpreter', 'latex')


			subplot(2,2,4);
			scatter(obj.timeGrid(:),obj.nGrid(:),'.')
			xlabel('Time','Interpreter', 'latex');ylabel('Number of cells','Interpreter', 'latex')
			title(sprintf('Scatter plot at buckle: T vs N'),'Interpreter', 'latex')
			
			SavePlot(obj, h, 'Scatter')
			%---------------------------------------------------------------------------------
			
			
		end


	end


end