classdef LayerOnStromaSPEvsPandG < Analysis

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

		sae = 10;
		spe = 0:10;

		seed = 1:100;

		targetTime = 500;

		analysisName = 'LayerOnStromaSPEvsPandG';

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

		function obj = LayerOnStromaSPEvsPandG()

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

			%AssembleData(obj);

            % g held constant on one plot
			for g = obj.g

				h = figure;
                leg = {};
				for p = obj.p

					if p~=5 || g~=5


					

						Lidx = obj.parameterSet(:,2) == p;
						tempR = obj.result(Lidx);
						Lidx = obj.parameterSet(Lidx,3) == g;
						data = tempR(Lidx);

						plot(obj.spe, data,'LineWidth', 4)
						hold on
                        
                        leg{end+1} = sprintf('p=%g',p);

					end
					

				end

				ylabel('Proportion','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
				title(sprintf('Proportion buckled with g = %g', g),'Interpreter', 'latex', 'FontSize', 22);
				xlim([0 10]);ylim([0 1]);
                legend(leg);
				SavePlot(obj, h, sprintf('PerimeterEnergy_g%g',g));
            end
            
            
            % p held constant on one plot
            for p = obj.p

				h = figure;
                leg = {};
				for g = obj.g

					if p~=5 || g~=5


					

						Lidx = obj.parameterSet(:,2) == p;
						tempR = obj.result(Lidx);
						Lidx = obj.parameterSet(Lidx,3) == g;
						data = tempR(Lidx);

						plot(obj.spe, data,'LineWidth', 4)
						hold on
                        
                        leg{end+1} = sprintf('g=%g',g);

					end
					

				end

				ylabel('Proportion','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
				title(sprintf('Proportion buckled with p = %g', p),'Interpreter', 'latex', 'FontSize', 22);
				xlim([0 10]);ylim([0 1]);
                legend(leg);
				SavePlot(obj, h, sprintf('PerimeterEnergy_p%g',p));
            end
            
            
            % Constant cell cycle length
            h = figure;
            leg = {};
            cct = 20;
            for g = obj.g

				
				for p = obj.p

					if p + g == cct


					

						Lidx = obj.parameterSet(:,2) == p;
						tempR = obj.result(Lidx);
						Lidx = obj.parameterSet(Lidx,3) == g;
						data = tempR(Lidx);

						plot(obj.spe, data,'LineWidth', 4)
                        %scatter(obj.spe, data,'filled');
						hold on
                        
                        leg{end+1} = sprintf('p=%g,g=%g',p,g);

					end
					

				end

            end
            
            ylabel('Proportion','Interpreter', 'latex', 'FontSize', 15);xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
            title(sprintf('Proportion buckled with p+g = %g', cct),'Interpreter', 'latex', 'FontSize', 22);
            xlim([0 10]);ylim([0 1]);
            legend(leg);
            SavePlot(obj, h, sprintf('PerimeterEnergy_pg%g',cct));
            

		end

	end

end