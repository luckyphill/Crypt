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
			adhesionEnergy = 0;

			% Contact inhibition fraction
			f = 0.9;

			% Make nodes around a polygon
			N = 10;
			X = [0, 1, 0, 1];
			Y = [0, 0, 1, 1];

			for i = 1:length(X)
				x = X(i);
				y = Y(i);
				
				ccm = ContactInhibitionCellCycle(p, g, f, obj.dt);

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


			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(CorrectorForce(0.1, b, obj.dt));

			% Self explanitory, really. Tries to make the edges the same length
			obj.AddCellBasedForce(FreeCellPerimeterNormalisingForce(1));

			
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