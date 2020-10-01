classdef RodsInChannel < FreeCellSimulation

	% This uses rod cells

	properties

		% None yet...

	end

	methods

		function obj = RodsInChannel(r, s, g, d, w, seed)

			% r is the rod growing force
			% s is the force pushing cells apart to their preferred distance
			% g is the time to grow from new cell to full size
			% d is the division probability for an hour
			% w is the width of the channel
			% The channel is represented by two infinitely long horizontal boundaries
			% set a width w apart

			n1 = Node(0,   w/2,obj.GetNextNodeId());
			n2 = Node(0.5, w/2,obj.GetNextNodeId());

			e = Element(n1,n2,obj.GetNextElementId());

			obj.nodeList = [n1,n2];
			obj.elementList = e;
			c = RodCell(e,SimpleRodCellCycle(g, d, obj.dt,0.7),obj.GetNextCellId());
			c.newCellTargetArea = 0.25;
			c.grownCellTargetArea = 0.5;
			obj.cellList = c;


			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(RodCellRepulsionForce(0.2, s, obj.dt));

			% A force to keep the rod cell at its preferred length
			obj.AddCellBasedForce(RodCellGrowthForce(r));

			obj.AddSimulationModifier(HorizontalChannel(0, w));
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(0.2, 0.2, obj);

			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			pathName = sprintf('RodsInChannel/r%gs%gg%gd%gw%g_seed%g/',r, s, g, d, w, seed);
			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20, pathName));



		end
		
	end

end