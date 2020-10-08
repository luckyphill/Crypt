classdef OrganoidRing < RingSimulation

	% This simulation makes a ring of cells, so there is no
	% start or end cell. Cell death needs a special apoptosis
	% mechanism to work properly

	properties

		dt = 0.005
		t = 0
		eta = 1

		timeLimit = 2000

	end

	methods

		function obj = OrganoidRing(nCells, p, g, ep, ip, seed)
			% All the initilising
			obj.SetRNGSeed(seed);

			% p = pause phase length, g = grow phase length
			% ep = external pressure

			% Use these values because they seem to do a good job
			% There's literally no other reason for these numbers

			areaEnergy = 20;
			perimeterEnergy = 10;
			adhesionEnergy = 1;




			%---------------------------------------------------
			% Make all the cells
			%---------------------------------------------------

			% The cells in this simulation form a closed ring
			% so every cell will have two neighbours
			% The diameter of the ring is determined by the number of cells
			% In order to have a sensible starting configuration, 
			% we set a minimum number of 10 cells

			if nCells < 10
				error('For a ring, at least 10 starting cells are needed');
			end

			%---------------------------------------------------
			% Make a list of top nodes and bottom nodes
			%---------------------------------------------------

			% We want to minimise the difference between the top and bottom
			% element lengths. The internal element lengths will be 1
			% Cells will be spaced evenly, covering 2pi/n rads
			% WE also keep the cell area at 0.5 since we are starting in Pause

			% Under these conditions, the radius r of the bottom nodes is given
			% by:

			r = 0.5 / sin(2*pi/nCells) - 0.5;

			topNodes = Node.empty();
			bottomNodes = Node.empty();

			for n = 1:nCells

				theta = 2*pi*n/nCells;
				xb = r * cos(theta);
				yb = r * sin(theta);

				xt = (r + 1) * cos(theta);
				yt = (r + 1) * sin(theta);

				bottomNodes(end + 1) = Node(xb, yb, obj.GetNextNodeId());
				topNodes(end + 1) = Node(xt, yt, obj.GetNextNodeId());

			end

			obj.AddNodesToList(bottomNodes);
			obj.AddNodesToList(topNodes);

			% The list of nodes goes anticlockwise, so from a node pair
			% i and i+1, i will be the right node, and i+1 the left

			%---------------------------------------------------
			% Make the first cell
			%---------------------------------------------------
			% Make the elements

			elementRight 	= Element(bottomNodes(1), topNodes(1), obj.GetNextElementId());
			elementLeft 	= Element(bottomNodes(2), topNodes(2), obj.GetNextElementId());
			elementBottom 	= Element(bottomNodes(1), bottomNodes(2), obj.GetNextElementId());
			elementTop	 	= Element(topNodes(1), topNodes(2), obj.GetNextElementId());
			
			% Critical for joined cells
			elementLeft.internal = true;

			obj.AddElementsToList([elementBottom, elementRight, elementTop, elementLeft]);

			% Cell cycle model

			ccm = SimplePhaseBasedCellCycle(p, g);

			% Assemble the cell

			obj.cellList = SquareCellJoined(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			%---------------------------------------------------
			% Make the middle cells
			%---------------------------------------------------

			for i = 2:nCells-1
				% Each time we advance to the next cell, the right most nodes and element of the previous cell
				% become the leftmost element of the new cell

				elementRight 	= elementLeft;
				elementLeft 	= Element(bottomNodes(i+1), topNodes(i+1), obj.GetNextElementId());
				elementBottom 	= Element(bottomNodes(i), bottomNodes(i+1), obj.GetNextElementId());
				elementTop	 	= Element(topNodes(i), topNodes(i+1), obj.GetNextElementId());

				% Critical for joined cells
				elementLeft.internal = true;

				obj.AddElementsToList([elementBottom, elementRight, elementTop]);

				ccm = SimplePhaseBasedCellCycle(p, g);

				obj.cellList(i) = SquareCellJoined(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			end

			%---------------------------------------------------
			% Make the last cell
			%---------------------------------------------------
			
			elementRight 	= elementLeft;
			elementLeft 	= obj.cellList(1).elementRight;
			elementBottom 	= Element(bottomNodes(nCells), bottomNodes(1), obj.GetNextElementId());
			elementTop	 	= Element(topNodes(nCells), topNodes(1), obj.GetNextElementId());

			% Critical for joined cells
			elementLeft.internal = true;

			obj.AddElementsToList([elementBottom, elementTop]);

			ccm = SimplePhaseBasedCellCycle(p, g);

			obj.cellList(nCells) = SquareCellJoined(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());


			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(NagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));

			% Corner force to prevent very sharp corners
			obj.AddCellBasedForce(CornerForceCouple(0.1,pi/2));

			% Element force to stop elements becoming too small
			obj.AddElementBasedForce(EdgeSpringForce(@(n,l) 20 * exp(1-25 * l/n)));

			% % Node-Element interaction force - requires a SpacePartition
			% obj.AddNeighbourhoodBasedForce(NodeElementRepulsionForce(0.1, obj.dt));

			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(SimpleAdhesionRepulsionForce(0.1, 10, obj.dt));

			obj.AddTissueBasedForce(OrganoidPressureForce(ep, ip));

			% Intial area calculation. This is to make sure the organoid doesn't collapse
			% or explode immediately
			areaPerCell = 0.2;
			initialArea = pi * r^2 - nCells * areaPerCell;
			obj.AddTissueBasedForce(OrganoidInternalMaterialForce(10,areaPerCell, initialArea));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			% In this simulation we are fixing the size of the boxes

			obj.boxes = SpacePartition(0.5, 0.5, obj);

			%---------------------------------------------------
			% Add the data we'd like to store
			%---------------------------------------------------

			obj.AddSimulationData(SpatialState());
			pathName = sprintf('OrganoidRing/n%gp%gg%gep%gip%g_seed%g/',nCells,p,g,ep,ip,seed);
			obj.AddDataWriter(WriteSpatialState(20,pathName));
			

			%---------------------------------------------------
			% All done. Ready to roll
			%---------------------------------------------------

		end


	end

end
