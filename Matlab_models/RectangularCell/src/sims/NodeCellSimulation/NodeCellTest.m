classdef NodeCellTest < AbstractCellSimulation

	% This uses node cells

	properties

		dt = 0.005
		t = 0
		step = 0

	end

	methods

		function obj = NodeCellTest(p, s, seed)

			% p the cycle length
			% s the spring rate

			obj.SetRNGSeed(seed);

			n = Node(0,0,obj.GetNextNodeId());

			obj.nodeList = n;

			ccm = NodeCellCycle(p);

			obj.cellList = NodeCell(n,ccm,obj.GetNextCellId);

			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(NodeOnlyForce(1, s));

			obj.boxes = SpacePartition(3, 3, obj);

			pathName = sprintf('NodeCellTest/');
			obj.AddSimulationData(NodeSpatialState());
			obj.AddDataWriter(WriteNodeSpatialState(20, pathName));

		end
		
	end

end