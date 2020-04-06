classdef (Abstract) AbstractCellSimulation < matlab.mixin.SetGet
	% A parent class that contains all the functions for running a simulation
	% The child/concrete class will only need a constructor that assembles the cells

	properties

		cellList

		nodeList
		nextNodeId = 1

		elementList
		nextElementId = 1

		nextCellId = 1

		collisionDetectionOn = false

		collisionDetectionRequested = false

		topWiggleRatio
		bottomWiggleRatio
		avgYDeviation
		alphaWrinkleParameter

		storeTopWiggleRatio = []
		storeBottomWiggleRatio = []
		storeNumCells = []
		storeAvgYDeviation = []
		storeAlphaWrinkleParameter = []

		leftBoundaryCell
		rightBoundaryCell

		cellBasedForces
		elementBasedForces
		
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

		function PlotTimeSeriesData(obj)

			% Plots all of the stored calculations

			figure;
			t = obj.dt:obj.dt:obj.t;

			plot(t,obj.storeTopWiggleRatio, t, obj.storeAvgYDeviation, t, obj.storeAlphaWrinkleParameter);
			legend({'Wiggle', 'YDev', 'alpha'});


		end

		function SetRNGSeed(obj, seed)

			rng(seed);

		end

		function AnimateCellPopulation(obj)



		end

		function NextTimeStep(obj)
			% Updates all the forces and applies the movements
			
			
			obj.GenerateCellBasedForces();
			obj.GenerateElementBasedForces();

			% Element forces must happen last because it contains the rigid body
			% tweak to prevent element flipping
			
			
			obj.MakeNodesMove();

			obj.MakeCellsDivide();

			obj.UpdateBoundaryCells();

			obj.UpdateSimpleWiggleRatio();

			obj.UpdateAverageYDeviation();

			obj.UpdateAlphaWrinkleParameter

			if ~obj.collisionDetectionOn && obj.collisionDetectionRequested
				obj.UpdateIfCollisionDetectionNeeded();
			end

			obj.MakeCellsAge();

			obj.t = obj.t + obj.dt;
			
		end

		function NTimeSteps(obj, n)
			% Advances a set number of time steps
			
			for i = 1:n
				% Do all the calculations
				obj.NextTimeStep();

				% Store the relevant data
				obj.storeTopWiggleRatio(end + 1) = obj.topWiggleRatio;
				obj.storeBottomWiggleRatio(end + 1) = obj.bottomWiggleRatio;
				obj.storeNumCells(end + 1) = obj.GetNumCells();
				obj.storeAvgYDeviation(end + 1) = obj.avgYDeviation;
				obj.storeAlphaWrinkleParameter(end + 1) = obj.alphaWrinkleParameter;

				
				% Make sure nothing has gone wrong
				if obj.collisionDetectionOn
					if obj.DetectCollision()
						fprintf('Collision detected. Stopped at t = %.2f\n',obj.t);
						break;
					end
				end
				if obj.DetectEdgeFlip()
					fprintf('Edge flip detected. Stopped at t = %.2f\n',obj.t);
					break;
				end

				

			end
			
		end

		function UpdateBoundaryCells(obj)

			if isempty(obj.leftBoundaryCell)
				% Probably the first time this has been run,
				% so need to find the boundary cells first
				% This won't work in general, but will be the case most of the time at this point
				obj.leftBoundaryCell 	= obj.cellList(1);
				obj.rightBoundaryCell 	= obj.cellList(end);
			end

			if obj.leftBoundaryCell.GetAge() <= obj.dt
				% Boundary cell has just divided, so need to check which of the new
				% cells is the leftmost
				if length(obj.leftBoundaryCell.elementLeft.cellList) > 1
					% The left element of the cell is part of at least two cells
					% So need to replace the leftBoundaryCell
					if obj.leftBoundaryCell == obj.leftBoundaryCell.elementLeft.cellList(1)
						obj.leftBoundaryCell = obj.leftBoundaryCell.elementLeft.cellList(2);
					else
						obj.leftBoundaryCell = obj.leftBoundaryCell.elementLeft.cellList(1);
					end

				end

			end

			if obj.rightBoundaryCell.GetAge() <= obj.dt
				% Boundary cell has just divided, so need to check which of the new
				% cells is the rightmost
				if length(obj.rightBoundaryCell.elementRight.cellList) > 1
					% The right element of the cell is part of at least two cells
					% So need to replace the rightBoundaryCell
					if obj.rightBoundaryCell == obj.rightBoundaryCell.elementRight.cellList(1)
						obj.rightBoundaryCell = obj.rightBoundaryCell.elementRight.cellList(2);
					else
						obj.rightBoundaryCell = obj.rightBoundaryCell.elementRight.cellList(1);
					end

				end

			end

		end
		
		function GenerateCellBasedForces(obj)
			
			for i = 1:length(obj.cellBasedForces)
				obj.cellBasedForces(i).AddCellBasedForces(obj.cellList);
			end

		end

		function GenerateElementBasedForces(obj)

			for i = 1:length(obj.elementBasedForces)
				obj.elementBasedForces(i).AddElementBasedForces(obj.elementList);
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

		function AddCellBasedForce(obj, f)

			if isempty(obj.cellBasedForces)
				obj.cellBasedForces = f;
			else
				obj.cellBasedForces(end + 1) = f;
			end

		end

		function AddElementBasedForce(obj, f)

			if isempty(obj.elementBasedForces)
				obj.elementBasedForces = f;
			else
				obj.elementBasedForces(end + 1) = f;
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

		function UpdateIfCollisionDetectionNeeded(obj)

			% An approximate way to tell if collision detection is needed to speed up
			% simulation time when there is no chance

			detectionThresholdRatio = 1 / 0.85;

			if (obj.topWiggleRatio > detectionThresholdRatio || obj.bottomWiggleRatio > detectionThresholdRatio)
				obj.collisionDetectionOn = true;
				fprintf('Collision detection turned on at t=%.4f\n',obj.t);
			end

		end

		function UpdateSimpleWiggleRatio(obj)

			% Compares the x range that cells cover to the
			% path length that the top and bottom edges cover

			sTop 	= 0;
			sBottom = 0;

			widthTop 	= obj.rightBoundaryCell.nodeTopRight.x 		- obj.leftBoundaryCell.nodeTopLeft.x;
			widthBottom = obj.rightBoundaryCell.nodeBottomRight.x 	- obj.leftBoundaryCell.nodeBottomLeft.x;

			% Traverse the top and bottom elements to get the path lengths
			for i = 1:obj.GetNumCells()

				sTop 	= sTop + obj.cellList(i).elementTop.GetLength();
				sBottom = sBottom + obj.cellList(i).elementBottom.GetLength();

			end

			obj.topWiggleRatio = sTop / widthTop;
			obj.bottomWiggleRatio = sBottom / widthBottom;

		end

		function UpdateAlphaWrinkleParameter(obj)

			% Calculates the alpha wrinkliness parameter from Dunn 2011 eqn 10

			r = 0;

			for i = 1:obj.GetNumCells()

				c = obj.cellList(i);

				dy = c.elementTop.Node1.y - c.elementTop.Node2.y;
				dx = c.elementTop.Node1.x - c.elementTop.Node2.x;

				r = r + abs(dy/dx);

			end

			obj.alphaWrinkleParameter = r / obj.GetNumCells();
		end

		function UpdateAverageYDeviation(obj)

			% Go through each cell along the top and calculate the average distance
			% from the x axis

			heightSum = abs(obj.cellList(1).nodeTopLeft.y) + abs(obj.cellList(1).nodeTopRight.y);

			for i = 2:obj.GetNumCells()

				heightSum = heightSum + abs(obj.cellList(i).nodeTopRight.y);

			end

			obj.avgYDeviation = heightSum / ( obj.GetNumCells() + 1 );

		end

		function detected = DetectCollision(obj)

			detected = false;
			i = 1;
			while ~detected && i <= obj.GetNumCells()
				j = i+1;
				while ~detected && j <= obj.GetNumCells()

					cell1 = obj.cellList(i);
					cell2 = obj.cellList(j);

					c1c2(1) = cell1.IsPointInsideCell(cell2.nodeTopLeft.position);
					c1c2(2) = cell1.IsPointInsideCell(cell2.nodeTopRight.position);
					c1c2(3) = cell1.IsPointInsideCell(cell2.nodeBottomLeft.position);
					c1c2(4) = cell1.IsPointInsideCell(cell2.nodeBottomRight.position);

					c2c1(1) = cell2.IsPointInsideCell(cell1.nodeTopLeft.position);
					c2c1(2) = cell2.IsPointInsideCell(cell1.nodeTopRight.position);
					c2c1(3) = cell2.IsPointInsideCell(cell1.nodeBottomLeft.position);
					c2c1(4) = cell2.IsPointInsideCell(cell1.nodeBottomRight.position);

					detected = sum(c1c2) + sum(c2c1);

					j = j + 1;

				end

				i = i + 1;
			end

		end

		function detected = DetectEdgeFlip(obj)

			% If an edge has flipped, that mean the cell is no longer a physical shape
			% so we need to detect this and stop the simulation

			detected = false;
			i = 1;
			while ~detected && i <= obj.GetNumCells()

				detected = obj.cellList(i).HasEdgeFlipped();

				i = i + 1;

			end

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