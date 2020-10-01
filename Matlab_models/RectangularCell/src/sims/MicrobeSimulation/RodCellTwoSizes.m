classdef RodCellTwoSizes < FreeCellSimulation

	% This uses rod cells

	properties

		% None yet...

	end

	methods

		function obj = RodCellTwoSizes(r, s, g, seed)

			% r is the rod growing force
			% s is the separation force, pushing cells apart
			% g is the exponential growth rate
			n1 = Node(0,0,obj.GetNextNodeId());
			n2 = Node(0.5,0,obj.GetNextNodeId());

			e = Element(n1,n2,obj.GetNextElementId());

			ccm = ExponentialGrowthCellCycle(g, obj.dt);
			ccm.colour = 6;
			c = RodCell(e,ccm,obj.GetNextCellId());
			c.newCellTargetArea = 0.25;
			c.grownCellTargetArea = 0.5;

			obj.nodeList = [n1,n2];
			obj.elementList = e;
			obj.cellList = c;

			% Make the smaller cell
			n1 = Node(-0.2,0,obj.GetNextNodeId());
			n2 = Node(-0.1,0,obj.GetNextNodeId());

			e = Element(n1,n2,obj.GetNextElementId());

			ccm = ExponentialGrowthCellCycle(g, obj.dt);
			ccm.colour = 7;
			c = RodCell(e,ccm,obj.GetNextCellId());
			c.newCellTargetArea = 0.05;
			c.grownCellTargetArea = 0.1;
			
			obj.nodeList = [obj.nodeList, n1,n2];
			obj.elementList = [obj.elementList, e];
			obj.cellList = [obj.cellList , c];


			n1 = Node(-0.4,0,obj.GetNextNodeId());
			n2 = Node(-0.3,0,obj.GetNextNodeId());

			e = Element(n1,n2,obj.GetNextElementId());

			ccm = ExponentialGrowthCellCycle(g, obj.dt);
			ccm.colour = 7;
			c = RodCell(e,ccm,obj.GetNextCellId());
			c.newCellTargetArea = 0.05;
			c.grownCellTargetArea = 0.1;
			
			obj.nodeList = [obj.nodeList, n1,n2];
			obj.elementList = [obj.elementList, e];
			obj.cellList = [obj.cellList , c];


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
			obj.AddDataWriter(WriteSpatialState(20,'RodCellTwoSizes/'));



		end
		
	end

end