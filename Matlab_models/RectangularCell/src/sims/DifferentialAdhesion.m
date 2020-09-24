classdef DifferentialAdhesion < FreeCellSimulation

	% This uses free cells, i.e. cells that never share
	% elemetns or node with other cells. There are two cell
	% types, and they have different adhesion attraction rates
	% depending on if they are next to the same or different
	% cell types. No cell division occurs

	properties

		% None yet...

	end

	methods

		function obj = DifferentialAdhesion(repulsion, same, different, seed)

			obj.SetRNGSeed(seed);

			areaEnergy = 20;
			perimeterEnergy = 10;
			adhesionEnergy = 1;

			% Make nodes around a polygon
			N = 7;

			for x = 1:10
				for y = 1:10

					ccm = NoCellCycle();
					c = MakeCellAtCentre(obj, N, x + 0.5 * mod(y,2), y * sqrt(3)/2, ccm);
					c.cellType = randi([1 2]);
					ccm.colour = c.cellType;
					c.grownCellTargetArea = 0.8;
					
					obj.nodeList = [obj.nodeList, c.nodeList];
					obj.elementList = [obj.elementList, c.elementList];

					obj.cellList = [obj.cellList, c];

				end
			end


			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(ChasteNagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));
			% Random motion force
			obj.AddCellBasedForce(RandomMotionForce(0.05, obj.dt));

			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(DifferentialAdhesionForce(0.1, repulsion, same, different, obj.dt));

			% A small element based force to regularise the placement of the nodes
			% around the perimeter of the cell
			obj.AddElementBasedForce(EdgeSpringForce(@(n, l) 2*(n - l)));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(0.2, 0.2, obj);

			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20,'DifferentialAdhesion/'));



		end

		function c = MakeCellAtCentre(obj, N, x,y, ccm)

			pgon = nsidedpoly(N, 'Radius', 0.5);
			v = flipud(pgon.Vertices); % Necessary for the correct order

			nodes = Node.empty();

			for i = 1:N
				nodes(i) = Node(v(i,1) + x, v(i,2) + y, obj.GetNextNodeId());
			end

			c = CellFree(ccm, nodes, 1);

		end
		
	end

end