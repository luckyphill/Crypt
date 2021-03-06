classdef VilusGrowth < LineSimulation

	% This simulation is the most basic - a simple row of cells growing on
	% a plate. It allows us to choose the number of initial cells
	% the force related parameters, and the cell cycle lengths

	properties

		dt = 0.005
		t = 0
		eta = 1

		timeLimit = 200

	end

	methods

		function obj = VilusGrowth(w, p, g, ep, seed)
			% All the initilising
			obj.SetRNGSeed(seed);

			areaEnergy = 20;
			perimeterEnergy = 10;
			adhesionEnergy = 1;



			% This simulation only allows cells to exist in a limited x domain

			% Cells are set to be 0.5 units wide, so total starting width is
			% 0.5*n. In order to keep things symmetric as much as possible, we
			% will set the boundaries so the row of cells starts in the middle
			% We will also check that the width is greater than the row of cells
			% While the death process probably could handle this, I don't want to push it
			nCells = w * 2;

			endPiece = (w - 0.5 * nCells) / 2;

			leftBoundary = -endPiece;
			rightBoundary = 0.5 * nCells + endPiece;

			k = BoundaryCellKiller(leftBoundary, rightBoundary);

			obj.AddTissueLevelKiller(k);



			%---------------------------------------------------
			% Make all the cells
			%---------------------------------------------------

			% The first cell needs all elements and nodes created
			% subsequent cells will have nodes and elements from their
			% neighbours

			% Make the nodes

			nodeTopLeft 	= Node(0,1,obj.GetNextNodeId());
			nodeBottomLeft 	= Node(0,0,obj.GetNextNodeId());
			nodeTopRight 	= Node(0.5,1,obj.GetNextNodeId());
			nodeBottomRight	= Node(0.5,0,obj.GetNextNodeId());

			obj.AddNodesToList([nodeBottomLeft, nodeBottomRight, nodeTopRight, nodeTopLeft]);

			% Make the elements

			elementBottom 	= Element(nodeBottomLeft, nodeBottomRight, obj.GetNextElementId());
			elementRight 	= Element(nodeBottomRight, nodeTopRight, obj.GetNextElementId());
			elementTop	 	= Element(nodeTopLeft, nodeTopRight, obj.GetNextElementId());
			elementLeft 	= Element(nodeBottomLeft, nodeTopLeft, obj.GetNextElementId());

			obj.AddElementsToList([elementBottom, elementRight, elementTop, elementLeft]);

			% Cell cycle model

			ccm = SimplePhaseBasedCellCycle(p, g);

			% Assemble the cell

			obj.cellList = SquareCellJoined(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());


			for i = 2:nCells
				% Each time we advance to the next cell, the right most nodes and element of the previous cell
				% become the leftmost element of the new cell

				nodeBottomLeft 	= nodeBottomRight;
				nodeTopLeft 	= nodeTopRight;
				nodeTopRight 	= Node(i*0.5,1,obj.GetNextNodeId());
				nodeBottomRight	= Node(i*0.5,0,obj.GetNextNodeId());
				

				obj.AddNodesToList([nodeBottomRight, nodeTopRight]);

				elementLeft 	= elementRight;
				elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
				elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
				elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());

				% Critical for joined cells
				elementLeft.internal = true;
				
				obj.AddElementsToList([elementBottom, elementRight, elementTop]);

				ccm = SimplePhaseBasedCellCycle(p, g);

				obj.cellList(i) = SquareCellJoined(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			end

			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(NagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));

			% Corner force to prevent very sharp corners
			obj.AddCellBasedForce(CornerForceCouple(0.1,pi/2));

			% Element force to stop elements becoming too small
			obj.AddElementBasedForce(EdgeSpringForce(@(n,l) 20 * exp(1-25 * l/n)));

			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(NodeElementRepulsionForce(0.1, obj.dt));

			obj.AddTissueBasedForce(OrganoidPressureForce(ep));


			obj.AddSimulationModifier(HorizontalBoundary(0));

			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------

			obj.boxes = SpacePartition(0.5, 0.5, obj);


			%---------------------------------------------------
			% Add the data we'd like to store
			%---------------------------------------------------

			obj.AddDataStore(StoreWiggleRatio(20));


			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			pathName = sprintf('VilusGrowth/w%gp%gg%gep%g_seed%g/',w, p, g, ep, seed);
			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20, pathName));

			%---------------------------------------------------
			% All done. Ready to roll
			%---------------------------------------------------

		end


		function RunToBuckle(obj)

			% This function runs the simulation until just after buckling has occurred
			% Buckling is defined by the wiggle ratio, i.e. epithelial length/domain width

			obj.AddStoppingCondition(BuckledStoppingCondition(1.1));

			obj.RunToTime(obj.timeLimit);

		end

	end

end
