classdef TumourSpheroidMultiAnalysis < Analysis

	properties

		% These cannot be changed, since they relate to a specific
		% set of data. If different values are needed, new data is needed
		% and a new analysis class should be made


		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		% No input parameters needed

		p
		g
		b

		seed

		analysisName = 'TumourSpheroidMultiAnalysis';

		parameterSet = []

		simulationRuns = 1
		slurmTimeNeeded = 24
		simulationDriverName = 'TumourSpheroid'
		simulationInputCount = 7
		

	end

	methods

		function obj = TumourSpheroidMultiAnalysis(p,g,b,seed)

			% Each seed runs in a separate job
			obj.specifySeedDirectly = true;

			obj.p = p;
		 	obj.g = g;
			obj.b = b;
			obj.seed = seed;
			obj.analysisName = sprintf('%s/p%gg%gb%g',obj.analysisName, obj.p, obj.g, obj.b);


		end

		function MakeParameterSet(obj)

			obj.parameterSet = [];

		end

	

		function AssembleData(obj)

			allN = [];
			allR90 = [];
			allPauseRA = {};
			
			for k = 1:obj.seed
				pathName = sprintf('TumourSpheroid/p%gg%gb%g_seed%g/SpatialState/',obj.p, obj.g, obj.b, k);
				r = Visualiser(pathName);

				N = []; % Number of cells
				C = []; % Centre of area
				R90 = []; % Radius about C that captures 90% of the cells
				mA = []; % Mean area of non-growing cells
				RA = {}; % Area/Distance pairs
				pauseRA = {};
				
				[I,~] = size(r.cells);

				for i = 1:I
					R = []; % Radii
					pauseAreas = []; % self evident
					pauseRadii = [];
					CC = []; % Cell centres
					A = []; % Areas
					% i is the time steps
					[~,J] = size(r.cells);
					j = 1;
					angles = [];
					while j <= J && ~isempty(r.cells{i,j})

						c = r.cells{i,j};
						ids = c(1:end-1);
						colour = c(end);
						nodeCoords = squeeze(r.nodes(ids,i,:));

						CC(j,:) = mean(nodeCoords);

						x = nodeCoords(:,1);
						y = nodeCoords(:,2);

						A(j) = polyarea(x,y);



						if colour == 1 && A(j) > 0.4 
							% The are limit cuts out some extreme outliers possibly
							% due to a division event in the previous timestep that
							% does not reflect the true area of the cell
							% Assemble areas of non-growing cells
							pauseAreas(end+1) = A(j);
							pauseRadii(end+1) = norm(mean(nodeCoords));
						end

						j = j + 1;

					end
					% j will always end up being 1 more than the total number of non empty cells

					N(end + 1) = j-1;
					C(end + 1,:) = mean(CC);
					mA(end + 1) = mean(pauseAreas);


					R = sqrt(sum(abs(CC-C(end,:)).^2,2));

					RA{end + 1} = [R,A'];
					pauseRA{end + 1} = [pauseRadii',pauseAreas'];

					R = sort(R);
					R90(end + 1) = R(ceil(.9*(j-1)));


				end

				allN(k,:) = N;
				allR90(k,:) = R90;
				allPauseRA{k} = pauseRA;

			end

			obj.result = {allN, allR90, allPauseRA};


		end

		function PlotData(obj)


			

			h=figure;
			hold on
			box on
			leg = {};
			allPauseRA = obj.result{3};
			bins = 0:0.8:14;
			M = [];
			for k = 1:obj.seed
				pauseRA = allPauseRA{k};
				allMean = [];
				for idx = 400:400:2000

					if ~isempty(pauseRA{idx})
						r = pauseRA{idx}(:,1);
						a = pauseRA{idx}(:,2);
						
						m = [];
						for i = 1:length(bins)-1
							m(i) = mean(a(  logical( (r>bins(i)) .* (r <= bins(i+1))  )   ) );
						end
						
					end
					allMean(end+1) = m;
				end

				M(:,:,k) = allMean; 

			end

			


			tFontSize = 40;
			lFontSize = 40;
			aFontSize = 24;
			% legend(leg)
			ax = gca;
			ax.FontSize = aFontSize;
			title('Avg cell area vs radius','Interpreter', 'latex','FontSize', tFontSize);
			ylabel('Avg area','Interpreter', 'latex', 'FontSize', lFontSize);xlabel('Radius','Interpreter', 'latex', 'FontSize', lFontSize);
			xlim([0 14]);
			ylim([0.425 0.48]);
			
			SavePlot(obj, h, sprintf('AreaRadiusDistribution'));


			h = figure;
			plot(obj.result.timeSteps,N, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = aFontSize;
			title('Cell count over time','Interpreter', 'latex','FontSize', tFontSize);
			ylabel('N','Interpreter', 'latex', 'FontSize', lFontSize);xlabel('time','Interpreter', 'latex', 'FontSize', lFontSize);
			xlim([0 obj.result.timeSteps(end)]);
			SavePlot(obj, h, sprintf('CellCount'));

			h = figure;
			plot(obj.result.timeSteps,mA, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = aFontSize;
			title('Average cell area','Interpreter', 'latex','FontSize', tFontSize);
			ylabel('Area','Interpreter', 'latex', 'FontSize', lFontSize);xlabel('time','Interpreter', 'latex', 'FontSize', lFontSize);
			xlim([0 obj.result.timeSteps(end)]);
			SavePlot(obj, h, sprintf('AvgPauseArea'));

			h = figure;
			plot(obj.result.timeSteps,R90, 'LineWidth', 4);
			ax = gca;
			ax.FontSize = aFontSize;
			title('90\% Radius over time','Interpreter', 'latex','FontSize', tFontSize);
			ylabel('Radius','Interpreter', 'latex', 'FontSize', lFontSize);xlabel('time','Interpreter', 'latex', 'FontSize', lFontSize);
			xlim([0 obj.result.timeSteps(end)]);
			SavePlot(obj, h, sprintf('Radius80'));


		end

	end

end