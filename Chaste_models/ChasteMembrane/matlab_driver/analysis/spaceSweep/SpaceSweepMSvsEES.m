classdef SpaceSweepMSvsEES < Analysis

	% This analysis sweeps over two parameters while keeping the others fixed
	% to try to show an optimal region

	properties

		% STATIC: DO NOT CHANGE
		% IF CHANGE IS NEEDED, MAKE A NEW OBJECT

		
		n 	= 19.1
		np 	= 9.3	
		ees = 100:10:400	
		ms 	= 100:10:400		
		cct = 22
		wt  = 3.4
		vf 	= 0.937	

		seed = 1;

		targetTime = 1000;

		analysisName = 'SpaceSweepMSvsEES';

		parameterSet = []
		missingParameterSet = []

		simulationRuns = 1
		slurmTimeNeeded = 4
		simulationDriverName = 'ManageCryptColumn'
		simulationInputCount = 7
		

	end

	methods

		function obj = SpaceSweepMSvsEES()

			obj.seedIsInParameterSet = false; % The seed not given in MakeParameterSet, it is set in properties
			obj.seedHandledByScript = false; % The seed will be in the parameter file, not the job script
			obj.usingHPC = true;

		end

		function MakeParameterSet(obj)

			% n,np,ees,ms,cct,wt,vf

			params = [];

			for n = obj.n
				for np = obj.np
					for ees = obj.ees
						for ms = obj.ms
							for cct = obj.cct
								for wt = obj.wt
									for vf = obj.vf

										params(end+1,:) = [n,np,ees,ms,cct,wt,vf];

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


			obj.MakeParameterSet();


			for i = 1:length(obj.parameterSet)

				s = obj.parameterSet(i,:);
				n 	= s(1);
				np 	= s(2);	
				ees = s(3);
				ms 	= s(4);		
				cct = s(5);
				wt  = s(6);
				vf 	= s(7);

				outputTypes = behaviourData();
				simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {n, np, ees, ms, cct, wt, vf});
				solverParams = containers.Map({'t', 'bt', 'dt'}, {1000, 100, 0.0005});
				seedParams = containers.Map({'run'}, {seed});

				sim = simulateCryptColumn(simParams, solverParams, seedParams, outputTypes);

				sim.loadSimulationData;

				data(i,:) = sim.data.behaviour_data;

				objectiveValue = MouseColonAsc(data(i,:));

			end

			obj.result = {data, objectiveValue};

		end

		function PlotData(obj)

			objectiveValue = obj.result{1};

			h = figure;

			scatter(obj.parameterSet(:,3), obj.parameterSet(:,4), 100, objectiveValue,'filled');
			ylabel('Area energy parameter','Interpreter', 'latex', 'FontSize', 15);
			xlabel('Perimeter energy parameter','Interpreter', 'latex', 'FontSize', 15);
			title(sprintf('Proportion buckled, p=%g, g=%g',obj.p,obj.g),'Interpreter', 'latex', 'FontSize', 22);
			ylim([min(obj.sae)-1, max(obj.sae)+1]);xlim([min(obj.spe)-1, max(obj.spe)+1]);
			colorbar; caxis([0 1]);
			colormap jet;
			ax = gca;
			c = ax.Color;
			ax.Color = 'black';
			set(h, 'InvertHardcopy', 'off')
			set(h,'color','w');

			SavePlot(obj, h, sprintf('BodyParams'));

		end

	end

end