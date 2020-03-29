classdef AbstractCellSimulation < matlab.mixin.SetGet
	% A parent class that contains all the functions for running a simulation
	% The child/concrete class will only need a constructor that assembles the cells

	properties

		cellList

		nodeList
		nextNodeId = 1

		elementList
		nextElementId = 1

		nextCellId = 1
		
	end

	properties (Abstract)

		dt
		t
		eta

	end

	methods

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
			obj.UpdateCellForces();
			
			obj.MakeNodesMove();

			obj.MakeCellsDivide();

			obj.MakeCellsAge();

			obj.t = obj.t + obj.dt;
			
		end

		function NTimeSteps(obj, n)
			% Advances a set number of time steps
			
			for i = 1:n
				obj.NextTimeStep();
			end
			
		end

		function UpdateCellForces(obj)
			
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

	methods (Access = protected)
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