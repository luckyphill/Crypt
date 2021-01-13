classdef DivisionTest < FreeCellSimulation

	% Tests a actin ring method of contracting the cell at the centre

	properties

		% None yet...

	end

	methods

		function obj = DivisionTest()

			% First go with the free cell... lets see how it goes!

			obj.SetRNGSeed(1);

			areaEnergy = 20;
			perimeterEnergy = 10;
			adhesionEnergy = 1;

			% Make nodes around a polygon

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.6);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),obj.GetNextNodeId());
			end

			ccm = NoCellCycle();

			c = CellFree(ccm, nodes, 1);

			obj.nodeList = nodes;

			obj.elementList = c.elementList;

			obj.cellList = c;


			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(ChasteNagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));

			% Self explanitory really. Tries to make the edges the same length
			obj.AddCellBasedForce(FreeCellPerimeterNormalisingForce(1));

			obj.AddCellBasedForce(ActinRingForce(10,1.2));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			
			obj.boxes = SpacePartition(0.2, 0.2, obj);

			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20,'DivisionTest/'));



		end
		
	end

end