classdef FreeCellTest < FreeCellSimulation

	% This uses free cells, i.e. cells that never share
	% elemetns or node with other cells

	properties

		% None yet...

	end

	methods

		function obj  = FreeCellTest(p, g, seed)

			% First go with the free cell... lets see how it goes!

			obj.SetRNGSeed(seed);

			areaEnergy = 20;
			perimeterEnergy = 10;
			adhesionEnergy = 1;

			% Make nodes around a polygon

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			ccm = SimplePhaseBasedCellCycle(p, g);

			c = CellFree(ccm, nodes, 1);

			obj.nodeList = nodes;

			obj.elementList = c.elementList;

			obj.cellList = c;


			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(ChasteNagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));

			% % Node-Element interaction force - requires a SpacePartition
			% obj.AddNeighbourhoodBasedForce(NodeElementRepulsionForce(0.1, obj.dt));

			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(SimpleAdhesionRepulsionForce(0.1, obj.dt));

			% A small element based force to regularise the placement of the nodes
			% around the perimeter of the cell
			obj.AddElementBasedForce(EdgeSpringForce(@(n, l) 2*(n - l)));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(0.2, 0.2, obj);



		end
		
	end

end