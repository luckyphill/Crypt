classdef CellPopulation < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% A cell population must have a list of cells

		cellList

		nodeList
		nextNodeId

		elementList
		nextElementId

		nextCellId
		
	end

	methods
		function obj = CellPopulation(nCells)
			% All the initilising

			% For the first cell, need to create 4 elements and 4 nodes
			obj.nextNodeId = 1;
			obj.nextElementId = 1;


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


			obj.cellList = Cell(elementBottom, elementLeft, elementTop, elementRight, 1);

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

				obj.cellList(i) = Cell(elementBottom, elementLeft, elementTop, elementRight, i);
			end

		end



		function VisualiseCellPopulation(obj)

			% plot a line for each element

			h = figure();
			hold on
			for i = 1:length(obj.elementList)

				x1 = obj.elementList(i).Node1.x;
				x2 = obj.elementList(i).Node2.x;
				x = [x1,x2];
				y1 = obj.elementList(i).Node1.y;
				y2 = obj.elementList(i).Node2.y;
				y = [y1,y2];

				line(x,y)
			end

			axis equal
		end

	end

	methods (Access = private)
		function id = GetNextNodeId(obj)
			id = obj.nextNodeId;
			obj.nextNodeId = obj.nextNodeId + 1;
		end

		function id = GetNextElementId(obj)
			id = obj.nextElementId;
			obj.nextElementId = obj.nextElementId + 1;
		end

		function AddNodesToList(obj, listOfNodes)
			obj.nodeList = [obj.nodeList, listOfNodes];
		end

		function AddElementsToList(obj, listOfElements)
			obj.elementList = [obj.elementList, listOfElements];
		end

	end


end