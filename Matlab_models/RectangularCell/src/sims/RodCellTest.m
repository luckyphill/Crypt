classdef RodCellTest < FreeCellSimulation

	% This uses rod cells

	properties

		% None yet...

	end

	methods

		function obj = RodCellTest(r, g, d, seed)


			n1 = Node(0,0,obj.GetNextNodeId());
			n2 = Node(0.5,0,obj.GetNextNodeId());

			e = Element(n1,n2,obj.GetNextElementId());

			obj.nodeList = [n1,n2];
			obj.elementList = e;
			obj.cellList = RodCell(e,SimpleRodCellCycle(g, d, obj.dt),obj.GetNextCellId());


			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(RodCellRepulsionForce(0.2, obj.dt));

			% A force to keep the rod cell at tis preferred length
			obj.AddCellBasedForce(RodCellGrowthForce(r));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(0.2, 0.2, obj);

			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20,'RodCellTest/'));



		end
		
	end

end