classdef LineSimulation < AbstractCellSimulation

	% This type of simulation is a row of cells with two distinct ends
	% I wanted to call this an abstract class, but I can't make the constructor
	% I need, so here we are...

	properties

		step = 0

	end

	methods

		function obj  = LineSimulation()

			obj.AddSimulationData(WiggleRatio());
			obj.AddSimulationData(CentreLine());
			obj.AddSimulationData(BoundaryCells());

		end
		
	end

end