classdef SteadyStateWiggleRatioAnalysis < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made
		p = 10:5:30;
		g = 10:5:30;

		w = 5:20;
		n = 10:2:40;

		b = 0:10;

		seed = 1:10;

		targetTime = 1000;

		analysisName = 'SteadyStateWiggleRatioAnalysis';

		avgGrid = {}

	end

	methods

		function obj = SteadyStateWiggleRatioAnalysis()

			% Uses the data produced by BuckleSweepFixedDomain to produce
			% a plot of the average time/number of cells/width at buckling
			for p = obj.p
				g = p;
				for w = obj.w
					for b = obj.b
						wD = [];
						for seed = obj.seed
							try
								% Sometimes the data might not exist
								a = RunBeamMembrane(2*w, p, g, w, b, seed);
								a.LoadSimulationData();
								temp = a.data.wiggleData(:,2)';

								if isempty(wD)
									wD = temp;
								else
									% If there is a discrepancy between the sizes,
									% pad either the matrix or vector to fix it
									if length(temp) > length(wD)
										% pad matrix
										wD = padarray(wD, [0, length(temp) - length(wD)], nan, 'post');
									end

									if length(temp) < length(wD)
										% pad vector
										temp = padarray(temp, [0, length(wD) - length(temp)], nan, 'post');
									end

									wD(count, :) = temp;

								end

							end

						end

						

						fprintf('Completed p = %d, g = %d, w = %d, b = %d\n',p,g,w,b);
			
						% Varying numbers of ending entries will be nans, so use nan mean to remove them
						% This will mean the number of entries for each column may be decresing, so
						% expect the variance to increase for later values

						obj.avgGrid{p,w,b+1} = nanmean(wD,1);

					end

				end

			end

		end


		function PlotData(obj)


			[P,G,W] = meshgrid(11:40,11:40,10:20);
			% Plots for constant cell cycle length
			S = P + G;

			[P1,G1] = meshgrid(11:40,11:40);
			% Plots for constant cell cycle length
			S1 = P1 + G1;

			% Linewidth for plots
			lw = 2;

			w = 1;

			%---------------------------------------------------------------------------------
			% Plot time to buckle
			%---------------------------------------------------------------------------------
			h = figure;

			surf(P1,G1,obj.timeGrid(:,:,w),'EdgeColor', 'None');
			xlabel('Pause','Interpreter', 'latex');ylabel('Growth','Interpreter', 'latex');
			xlim([11 40]);ylim([11 40])
			title(sprintf('Time to buckle'),'Interpreter', 'latex')
			colorbar;view(0,90);

			cct = 30;

			h = figure;
			plot(P(G==cct), obj.timeGrid(G==cct), 'LineWidth', lw)
			xlabel('Pause','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Time to buckle: Growth = %d hr',cct),'Interpreter', 'latex')
			
			subplot(2,2,3);
			plot(G(P==cct), obj.timeGrid(P==cct,w), 'LineWidth', lw)
			xlabel('Growth','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Time to buckle: Pause = %d hr',cct),'Interpreter', 'latex')
			
			subplot(2,2,4);
			cct = 35;
			plot(P(S==cct), obj.timeGrid(S==cct,w), 'LineWidth', lw)
			xlabel('Pause','Interpreter', 'latex');ylabel('Time','Interpreter', 'latex')
			title(sprintf('Time to buckle: Growth + Pause = %d hr',cct),'Interpreter', 'latex')
			
			SavePlot(obj, h, 'Time')
			%---------------------------------------------------------------------------------


			% %---------------------------------------------------------------------------------
			% % Scatter plots at buckle
			% %---------------------------------------------------------------------------------
			% h = figure;

			% subplot(2,2,1);
			% scatter3(obj.timeGrid(:),obj.nGrid(:),obj.widthGrid(:),'.')
			% xlabel('Time','Interpreter', 'latex');ylabel('Number of cells','Interpreter', 'latex');zlabel('Width','Interpreter', 'latex')
			% title(sprintf('Scatter plot at buckle: T vs N vs W'),'Interpreter', 'latex')

			% subplot(2,2,2);
			% scatter(obj.timeGrid(:),obj.widthGrid(:),'.')
			% xlabel('Time','Interpreter', 'latex');ylabel('Width','Interpreter', 'latex')
			% title(sprintf('Scatter plot at buckle: T vs W'),'Interpreter', 'latex')
			
			% subplot(2,2,3);
			% scatter(obj.nGrid(:),obj.widthGrid(:),'.')
			% xlabel('Number of cells','Interpreter', 'latex');ylabel('Width','Interpreter', 'latex')
			% title(sprintf('Scatter plot at buckle: N vs W'),'Interpreter', 'latex')


			% subplot(2,2,4);
			% scatter(obj.timeGrid(:),obj.nGrid(:),'.')
			% xlabel('Time','Interpreter', 'latex');ylabel('Number of cells','Interpreter', 'latex')
			% title(sprintf('Scatter plot at buckle: T vs N'),'Interpreter', 'latex')
			
			% SavePlot(obj, h, 'Scatter')
			% %---------------------------------------------------------------------------------
			
			
		end


	end


end