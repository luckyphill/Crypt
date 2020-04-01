classdef CellBendingGrowing < AbstractCellSimulation

	% This class tests the tissue level behaviour for a handful off cells
	% that have differing cell adhesion parameters at the top and bottom
	properties

		dt = 0.01
		t = 0
		eta = 1

	end

	methods
		function obj = CellBendingGrowing(nCells, topAdhesion, bottomAdhesion)
			% All the initilising

			p = 20;
			g = 10;

			% The middle three cells are trapezoidal cells

			mid = ceil(nCells/2);
			f = mid - 1;
			l = mid + 1;

			% For the first cell, need to create 4 elements and 4 nodes

			nodeBottomLeft 	= Node(0,0,obj.GetNextNodeId());
			nodeBottomRight	= Node(0.5,0,obj.GetNextNodeId());
			nodeTopRight 	= Node(0.5,1,obj.GetNextNodeId());
			nodeTopLeft 	= Node(0,1,obj.GetNextNodeId());

			obj.AddNodesToList([nodeBottomLeft, nodeBottomRight, nodeTopRight, nodeTopLeft]);

			elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
			elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());
			elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
			elementLeft 	= Element(nodeBottomLeft, nodeTopLeft,obj.GetNextElementId());

			obj.AddElementsToList([elementBottom, elementRight, elementTop, elementLeft]);

			ccm = SimplePhaseBasedCellCycle(p, g);

			obj.cellList = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());


			for i = 2:(f-1)
				% Each time we advance to the next cell, the right most nodes and element of the previous cell
				% become the leftmost element of the new cell

				nodeBottomLeft 	= nodeBottomRight;
				nodeTopLeft 	= nodeTopRight;
				nodeBottomRight	= Node(i*0.5,0,obj.GetNextNodeId());
				nodeTopRight 	= Node(i*0.5,1,obj.GetNextNodeId());

				obj.AddNodesToList([nodeBottomRight, nodeTopRight]);

				elementLeft 	= elementRight;
				elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
				elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
				elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());

				obj.AddElementsToList([elementBottom, elementRight, elementTop]);

				ccm = SimplePhaseBasedCellCycle(p, g);

				obj.cellList(i) = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			end

			oldx = i * 0.5;
			for i = 1:3
				% Each time we advance to the next cell, the right most nodes and element of the previous cell
				% become the leftmost element of the new cell

				nodeBottomLeft 	= nodeBottomRight;
				nodeTopLeft 	= nodeTopRight;
				nodeBottomRight	= Node(oldx + i,0,obj.GetNextNodeId());
				nodeTopRight 	= Node(oldx + i,1,obj.GetNextNodeId());

				obj.AddNodesToList([nodeBottomRight, nodeTopRight]);

				elementLeft 	= elementRight;
				elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
				elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
				elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());

				elementTop.SetEdgeAdhesionParameter(topAdhesion);
				elementBottom.SetEdgeAdhesionParameter(bottomAdhesion);

				obj.AddElementsToList([elementBottom, elementRight, elementTop]);

				ccm = NoCellCycle();

				obj.cellList(i + f - 1) = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			end

			oldx = oldx + 3;
			for i = 1:nCells - l;
				% Each time we advance to the next cell, the right most nodes and element of the previous cell
				% become the leftmost element of the new cell

				nodeBottomLeft 	= nodeBottomRight;
				nodeTopLeft 	= nodeTopRight;
				nodeBottomRight	= Node(oldx + i*0.5,0,obj.GetNextNodeId());
				nodeTopRight 	= Node(oldx + i*0.5,1,obj.GetNextNodeId());

				obj.AddNodesToList([nodeBottomRight, nodeTopRight]);

				elementLeft 	= elementRight;
				elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
				elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
				elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());

				obj.AddElementsToList([elementBottom, elementRight, elementTop]);

				ccm = SimplePhaseBasedCellCycle(p, g);

				obj.cellList(i + l) = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			end

		end

	end

end
