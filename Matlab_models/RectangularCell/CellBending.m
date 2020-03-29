classdef CellBending < AbstractCellSimulation

	% This class tests the tissue level behaviour for a handful off cells
	% that have differing cell adhesion parameters at the top and bottom
	properties

		dt = 0.01
		t = 0
		eta = 1

	end

	methods
		function obj = CellBending(nCells, trapCells, topAdhesion, bottomAdhesion)
			% All the initilising

			% For the first cell, need to create 4 elements and 4 nodes

			nodeBottomLeft 	= Node(0,0,obj.GetNextNodeId());
			nodeBottomRight	= Node(1,0,obj.GetNextNodeId());
			nodeTopRight 	= Node(1,1,obj.GetNextNodeId());
			nodeTopLeft 	= Node(0,1,obj.GetNextNodeId());

			obj.AddNodesToList([nodeBottomLeft, nodeBottomRight, nodeTopRight, nodeTopLeft]);

			elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
			elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());
			elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
			elementLeft 	= Element(nodeBottomLeft, nodeTopLeft,obj.GetNextElementId());

			obj.AddElementsToList([elementBottom, elementRight, elementTop, elementLeft]);

			ccm = NoCellCycle();

			obj.cellList = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());


			for i = 2:nCells
				% Each time we advance to the next cell, the right most nodes and element of the previous cell
				% become the leftmost element of the new cell

				nodeBottomLeft 	= nodeBottomRight;
				nodeTopLeft 	= nodeTopRight;
				nodeBottomRight	= Node(i,0,obj.GetNextNodeId());
				nodeTopRight 	= Node(i,1,obj.GetNextNodeId());

				obj.AddNodesToList([nodeBottomRight, nodeTopRight]);

				elementLeft 	= elementRight;
				elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
				elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
				elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());

				obj.AddElementsToList([elementBottom, elementRight, elementTop]);

				ccm = NoCellCycle();

				obj.cellList(i) = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			end


			for i = 1:length(trapCells)
				idx = trapCells(i);
				obj.cellList(idx).elementTop.SetEdgeAdhesionParameter(topAdhesion);
				obj.cellList(idx).elementTop.SetEdgeAdhesionParameter(bottomAdhesion);
			end


		end

	end

end
