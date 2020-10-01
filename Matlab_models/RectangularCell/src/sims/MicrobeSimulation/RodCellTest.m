classdef RodCellTest < FreeCellSimulation

	% This uses rod cells

	properties

		% None yet...

	end

	methods

		function obj = RodCellTest(r, s, g, d, seed)

			% r is the rod growing force
			% s is the force pushing cells apart to their preferred distance
			% g is the time to grow from new cell to full size
			% d is the division probability for an hour
			n1 = Node(0,0,obj.GetNextNodeId());
			n2 = Node(0.5,0,obj.GetNextNodeId());

			e = Element(n1,n2,obj.GetNextElementId());

			obj.nodeList = [n1,n2];
			obj.elementList = e;
			c = RodCell(e,SimpleRodCellCycle(g, d, obj.dt),obj.GetNextCellId());
			c.newCellTargetArea = 0.25;
			c.grownCellTargetArea = 0.5;
			obj.cellList = c;


			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(RodCellRepulsionForce(0.2, s, obj.dt));

			% A force to keep the rod cell at its preferred length
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