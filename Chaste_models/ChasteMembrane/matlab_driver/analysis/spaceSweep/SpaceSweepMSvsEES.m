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

			

		end

		function PlotData(obj)


		end

	end

end