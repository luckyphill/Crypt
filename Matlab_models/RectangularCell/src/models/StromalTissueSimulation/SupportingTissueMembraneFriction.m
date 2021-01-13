classdef SupportingTissueMembraneFriction < LineSimulation

	% This simulation is the most basic - a simple row of cells growing on
	% a plate. It allows us to choose the number of initial cells
	% the force related parameters, and the cell cycle lengths

	properties

		dt = 0.005
		t = 0
		eta = 1

		timeLimit = 1000

	end

	methods

		function obj = SupportingTissueMembraneFriction(nCells, p, g, w, b, seed, varargin)
			% All the initialising
			obj.SetRNGSeed(seed);

			if ~isempty(varargin)
				if length(varargin) == 3
					areaEnergy = varargin{1};
					perimeterEnergy = varargin{2};
					adhesionEnergy = varargin{3};
				else
					error('Error using varargin, must have 3 args, areaEnergy, perimeterEnergy, and adhesionEnergy');
				end
			else
				areaEnergy = 20;
				perimeterEnergy = 10;
				adhesionEnergy = 1;
			end

			% This simulation only allows cells to exist in a limited x domain

			% Cells are set to be 0.5 units wide, so total starting width is
			% 0.5*n. In order to keep things symmetric as much as possible, we
			% will set the boundaries so the row of cells starts in the middle
			% We will also check that the width is greater than the row of cells
			% While the death process probably could handle this, I don't want to push it

			if 0.5 * nCells > w
				error('Make the width larger than the initial number of cells')
			end

			endPiece = (w - 0.5 * nCells) / 2;

			leftBoundary = -endPiece;
			rightBoundary = 0.5 * nCells + endPiece;

			k = BoundaryCellKiller(leftBoundary, rightBoundary);

			obj.AddTissueLevelKiller(k);

			%---------------------------------------------------
			% Make all the cells
			%---------------------------------------------------

			% The first cell needs all elements and nodes created
			% subsquent cells will have nodes and elements from their
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

			% n elements means n+1 nodes

			n = 2 * nCells;
			x0 = rightBoundary;
			xf = leftBoundary;

			dx = (x0 - xf) / n;

			x = x0;
			y = -0.1;

			firstNode = Node(x, y, obj.GetNextNodeId());

			pinned = firstNode;

			obj.AddNodesToList(firstNode);

			for i = 1:n

				% Subtract because going right to left
				x = x0 - i * dx;

				secondNode = Node(x, y, obj.GetNextNodeId);
				obj.AddNodesToList(secondNode);

				e = Element(firstNode, secondNode, obj.GetNextElementId);
				e.naturalLength = dx;
				e.isMembrane = true;
				obj.AddElementsToList(e);

				firstNode = secondNode;

			end

			pinned(end + 1) = secondNode;

			%---------------------------------------------------
			% Add the modfier to keep the stromal corner cells
			% locked in place
			%---------------------------------------------------
			
			% nodeList comes from building the stroma
			% obj.AddSimulationModifier(   PinNodes(  pinned  )   );

			%---------------------------------------------------
			% Add in the forces
			%---------------------------------------------------

			% Nagai Honda forces
			obj.AddCellBasedForce(ChasteNagaiHondaForce(areaEnergy, perimeterEnergy, adhesionEnergy));

			% Corner force to prevent very sharp corners
			obj.AddCellBasedForce(CornerForceCouple(0.1,pi/2));

			% Element force to stop elements becoming too small
			obj.AddElementBasedForce(EdgeSpringForce(@(n,l) 20 * exp(1-25 * l/n)));

			% Node-Element interaction force - requires a SpacePartition
			obj.AddNeighbourhoodBasedForce(AdhesionRepulsionFriction(0.1, 10, 0.1, obj.dt));

			% Force to keep epithelial layer flat
			if b > 0
				obj.AddTissueBasedForce(SupportingTissueMembraneForce(b));
			else
				fprintf('No basement membrane force applied\n');
			end
			
			%---------------------------------------------------
			% Add space partition
			%---------------------------------------------------
			% In this simulation we are fixing the size of the boxes
			obj.usingBoxes = true;
			obj.boxes = SpacePartition(0.2, 0.2, obj);

			%---------------------------------------------------
			% Add the modfier to keep the boundary cells at the
			% same vertical position
			%---------------------------------------------------
			
			% obj.AddSimulationModifier(ShiftBoundaryCells());


			%---------------------------------------------------
			% Add the data writers
			%---------------------------------------------------

			obj.AddSimulationData(SpatialState());
			obj.AddDataWriter(WriteSpatialState(20,'SupportingTissueMembraneFriction/'));
			% pathName = sprintf('SupportingTissueMembraneFriction/p%dg%dw%db%d_seed%d/',p,g,w,b,seed);
			% obj.AddDataWriter(WriteWiggleRatio(20,pathName));
			obj.AddDataWriter(WriteBottomWiggleRatio(20,'SupportingTissueMembraneFriction/'));

			%---------------------------------------------------
			% All done. Ready to roll
			%---------------------------------------------------

		end

	end

end
