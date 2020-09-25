classdef TumourSpheroid < FreeCellSimulation

	% This uses free cells, i.e. cells that never share
	% elemetns or node with other cells

	properties

		% None yet...

	end

	methods

		function obj = TumourSpheroid(p, g, b, seed)

			obj.SetRNGSeed(seed);

			areaEnergy = 20;
			perimeterEnergy = 10;
			adhesionEnergy = 10;

			% Make nodes around a polygon
			N = 10;
			X = [0, 1, 0, 1];
			Y = [0, 0, 1, 1];

			for i = 1:length(X)
				x = X(i);
				y = Y(i);
				
				ccm = SimplePhaseBasedCellCycle(p, g);
				c = MakeCellAtCentre(obj, N, x + 0.5 * mod(y,2), y * sqrt(3)/2, ccm);

				obj.nodeList = [obj.nodeList, c.nodeList];
				obj.elementList = [obj.elementList, c.elementList];
				obj.cellList = [obj.cellList, c];

			end

			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(ChasteNagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));

			% % Node-Element interaction force - requires a SpacePartition
			% obj.AddNeighbourhoodBasedForce(NodeElementRepulsionForce(0.1, obj.dt));

			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(NonLinearAdhesionForce(0.1, b, obj.dt));

			% A small element based force to regularise the placement of the nodes
			% around the perimeter of the cell
			obj.AddElementBasedForce(EdgeSpringForce(@(n, l) 2*(n - l)));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(0.3, 0.3, obj);

			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------
			pathName = sprintf('TumourSpheroid/p%gg%gb%g_seed%g/',p,g,b,seed);
			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20, pathName));



		end
		
	end

end