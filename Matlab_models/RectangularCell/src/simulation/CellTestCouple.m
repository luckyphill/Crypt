classdef CellTestCouple < AbstractCellSimulation

	% This class tests the tissue level behaviour for a handful off cells
	% that have differing cell adhesion parameters at the top and bottom
	properties

		dt = 0.01
		t = 0
		eta = 1

	end

	methods
		function obj = CellTestCouple()
			% All the initilising

			% For the first cell, need to create 4 elements and 4 nodes

			nodeBottomLeft 	= Node(0,0,obj.GetNextNodeId());
			nodeBottomRight	= Node(1,0,obj.GetNextNodeId());
			nodeTopRight 	= Node(1.2,1.2,obj.GetNextNodeId());
			nodeTopLeft 	= Node(0,1,obj.GetNextNodeId());

			obj.AddNodesToList([nodeBottomLeft, nodeBottomRight, nodeTopRight, nodeTopLeft]);

			elementBottom 	= Element(nodeBottomLeft, nodeBottomRight,obj.GetNextElementId());
			elementRight 	= Element(nodeBottomRight, nodeTopRight,obj.GetNextElementId());
			elementTop	 	= Element(nodeTopLeft, nodeTopRight,obj.GetNextElementId());
			elementLeft 	= Element(nodeBottomLeft, nodeTopLeft,obj.GetNextElementId());

			obj.AddElementsToList([elementBottom, elementRight, elementTop, elementLeft]);

			ccm = NoCellCycle();

			obj.cellList = Cell(ccm, [elementTop, elementBottom, elementLeft, elementRight], obj.GetNextCellId());

			obj.AddCellBasedForce(CornerForceCouple(10,pi/2));


		end

	end

end
