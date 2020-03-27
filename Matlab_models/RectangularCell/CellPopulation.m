classdef CellPopulation < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% A cell population must have a list of cells

		cellList

		nodeList
		nextNodeId = 1

		elementList
		nextElementId = 1

		nextCellId = 1

		dt = 0.01
		t = 0
		eta = 1
		
	end

	methods
		function obj = CellPopulation(nCells, cct, wt)
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


			obj.cellList = Cell(elementBottom, elementLeft, elementTop, elementRight, obj.GetNextCellId());
			obj.cellList(1).SetCellCycleLength(cct);
			obj.cellList(1).SetGrowingPhaseLength(wt);
			obj.cellList(1).SetBirthTime(wt + randi(cct - wt - 1));


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

				obj.cellList(i) = Cell(elementBottom, elementLeft, elementTop, elementRight, obj.GetNextCellId());
				obj.cellList(i).SetCellCycleLength(20);
				obj.cellList(i).SetGrowingPhaseLength(5);
				obj.cellList(i).SetBirthTime(6 + randi(13));
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

		function AnimateCellPopulation(obj)


		end



		function NextTimeStep(obj)
			% Updates all the forces and applies the movements


			
			obj.UpdateElementForces();
			obj.UpdateCellAreaForces();
			
			obj.MakeNodesMove();

			obj.MakeCellsDivide();

			obj.MakeCellsAge();

			obj.t = obj.t + obj.dt;
			

		end

		function UpdateCellAreaForces(obj)
			
			for i = 1:length(obj.cellList)
				obj.cellList(i).UpdateForce();
			end

		end

		function UpdateElementForces(obj)

			for i = 1:length(obj.elementList)
				obj.elementList(i).UpdateForce();
			end

		end

		function MakeNodesMove(obj)

			for i = 1:length(obj.nodeList)

				force = obj.nodeList(i).force;
				position = obj.nodeList(i).position;

				newPosition = position + obj.dt/obj.eta * force;

				obj.nodeList(i).MoveNode(newPosition);
			end

		end

		function MakeCellsDivide(obj)

			% Call the divide process, and update the lists
			newCells = Cell.empty;
			for i = 1:length(obj.cellList)
				c = obj.cellList(i);
				if c.IsReadyToDivide();
					newCells(end + 1) = c.Divide();
				end
			end

			obj.AddNewCells(newCells);


		end

		function MakeCellsAge(obj)

			for i = 1:length(obj.cellList)
				obj.cellList(i).AgeCell(obj.dt);
			end

		end

		function AddNewCells(obj, newCellList)
			% When a cell divides, need to make sure the new cell object
			% as well as the new elements and nodes are correctly added to
			% their respective lists

			for i = 1:length(newCellList)
				% If we get to this point, the cell should definitely be new
				% so don't have to worry about checking
				nc = newCellList(i);
				obj.cellList(end + 1) = nc;

				obj.AddNodesToList([nc.nodeTopLeft, nc.nodeTopRight, nc.nodeBottomLeft, nc.nodeBottomRight]);

				obj.AddElementsToList([nc.elementRight, nc.elementLeft, nc.elementTop, nc.elementBottom]);

			end

		end

		function numCells = GetNumCells(obj)

			numCells = length(obj.cellList);
		end

		function numElements = GetNumElements(obj)

			numElements = length(obj.elementList);
		end

		function numNodes = GetNumNodes(obj)

			numNodes = length(obj.nodeList);
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

		function id = GetNextCellId(obj)
			id = obj.nextCellId;
			obj.nextCellId = obj.nextCellId + 1;
		end

		function AddNodesToList(obj, listOfNodes)
			for i = 1:length(listOfNodes)
				% If any of the nodes are already in the list, don't add them
				if sum(ismember(listOfNodes(i), obj.nodeList)) == 0
					obj.nodeList = [obj.nodeList, listOfNodes(i)];
				end
			end

		end

		function AddElementsToList(obj, listOfElements)
			for i = 1:length(listOfElements)
				% If any of the Elements are already in the list, don't add them
				if sum(ismember(listOfElements(i), obj.elementList)) == 0
					obj.elementList = [obj.elementList, listOfElements(i)];
				end
			end
		end

	end


end