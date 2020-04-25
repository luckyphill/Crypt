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

		collisionDetected = false
		edgeFlipDetected = false

		collisionDetectionOn = false

		collisionDetectionRequested = false

		centreLine

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

		cellBasedForces AbstractCellBasedForce
		elementBasedForces AbstractElementBasedForce
		
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

			obj.UpdateCentreLine();
			plot(obj.centreLine(:,1), obj.centreLine(:,2), 'k');

		end

		function VisualisePrevious(obj)

			% plot a line for each element

			h = figure();
			hold on
			for i = 1:length(obj.elementList)

				x1 = obj.elementList(i).Node1.previousPosition(1);
				x2 = obj.elementList(i).Node2.previousPosition(1);
				x = [x1,x2];
				y1 = obj.elementList(i).Node1.previousPosition(2);
				y2 = obj.elementList(i).Node2.previousPosition(2);
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

		function AnimateNTimeSteps(obj, n, sm)
			% Since we aren't storing data at this point, the only way to animate is to
			% calculate then plot

			% Set up the line objects initially

			% Initialise an array of line objects
			h = figure();
			hold on

			lineObjects(length(obj.elementList)) = line([1,1],[2,2]);

			for i = 1:length(obj.elementList)
				
				x1 = obj.elementList(i).Node1.x;
				x2 = obj.elementList(i).Node2.x;
				x = [x1,x2];
				y1 = obj.elementList(i).Node1.y;
				y2 = obj.elementList(i).Node2.y;
				y = [y1,y2];

				lineObjects(i) = line(x,y);
			end

			totalSteps = 0;
			while totalSteps < n

				obj.NTimeSteps(sm);
				totalSteps = totalSteps + sm;

				for j = 1:length(obj.elementList)
				
					x1 = obj.elementList(j).Node1.x;
					x2 = obj.elementList(j).Node2.x;
					x = [x1,x2];
					y1 = obj.elementList(j).Node1.y;
					y2 = obj.elementList(j).Node2.y;
					y = [y1,y2];

					if j > length(lineObjects)
						lineObjects(j) = line(x,y);
					else
						lineObjects(j).XData = x;
						lineObjects(j).YData = y;
					end
				end

				drawnow
				title(sprintf('t=%g',obj.t));

			end

		end

		function NextTimeStep(obj)
			% Updates all the forces and applies the movements
			
			
			obj.GenerateCellBasedForces();
			obj.GenerateElementBasedForces();

			% Element forces must happen last because it contains the rigid body
			% tweak to prevent element flipping. This is a dodgy way to do it,
			% but I can't think of a better and quick solution
			% 17042020 no longer necessary to have these in this order because not using
			% that particular edge flipping stopper. Still ought to implement a 'modifier'
			% stage in time stepping
			
			
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
					obj.ProcessCollisions();
					if obj.collisionDetected
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

				% Since the new cell is made by the old cell, we don't know the
				% global id numbers until we get to this point
				nc.id = obj.GetNextCellId();

				nc.elementTop.id = obj.GetNextElementId();
				nc.elementBottom.id = obj.GetNextElementId();
				nc.elementLeft.id = obj.GetNextElementId();
				nc.elementRight.id = obj.GetNextElementId();

				nc.nodeTopLeft.id = obj.GetNextNodeId();
				nc.nodeTopRight.id = obj.GetNextNodeId();
				nc.nodeBottomLeft.id = obj.GetNextNodeId();
				nc.nodeBottomRight.id = obj.GetNextNodeId();

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


		function ProcessCollisions(obj)

			% Initial sort by x coordinate then y
			% Note: in testing this line of code it was not clear that the y coordinate was always
			% ordered in ascending order, however, this may have something to do
			% with the precision of the x coords involved. Two x coords that have
			% the same decimal representation up to 12 decimals may not be equal
			% past this, and that could be what I wasn't seeing
			a = reshape([obj.nodeList.position], [2, length(obj.nodeList)]);
			[~,idx] = sortrows(a');
			% Initial sort by x coordinate
			% [~,idx] = sort([obj.nodeList.x]);

			obj.nodeList = obj.nodeList(idx);

			collisions = obj.FindCollisions(obj.nodeList);

			% For each collision there is some pair of cells that need to be corrected
			% so they are not intersecting
			% A collision could also be when an edge has flipped, so need to be careful

			if ~isempty(collisions)
				obj.collisionDetected = true;
			end

		end

		function collisions = FindCollisions(obj, nodes)
			% Don't really need to take the argument nodes, but it helps for unit testing

			% At this point, the array nodes must be ordered by x coordinate.
			% Sorting could happen in here, but by sorting the actual list held by
			% the cell population, there will be some speed up since the order will
			% not change much between time steps

			% For each cell we are tracking the number of constituent nodes that have
			% been visited. When it reaches 4, then the cell is removed from consideration
			cellVisitTally = containers.Map( 'KeyType', 'double', 'ValueType', 'any');

			% a list of the cell that are cut by the scanning line
			activeCells = Cell.empty();

			% A cell array of edge pairs that collide
			collisions = {};

			for i = 1:length(nodes)


				candidates = nodes(i).cellList;

				% Update the list of active cells

				for j = 1:length(candidates)

					if isKey(cellVisitTally, candidates(j).id)
						% If this is the 4th node we've visited for a particular cell, then
						% get rid of it from active cells
						if cellVisitTally(candidates(j).id) == 3
							% Lidx = ismember(candidates(j), activeCells);
							% activeCells(Lidx) = [];
							activeCells(candidates(j)==activeCells) = [];
						else
							cellVisitTally(candidates(j).id) = cellVisitTally(candidates(j).id) + 1;
						end
					else
						cellVisitTally(candidates(j).id) = 1;
						activeCells = [activeCells, candidates(j)];
					end
				end

				
				% The only way collisions can occur is if an internal element (left or right)
				% intersects with an external element (top or bottom). Therefore, we only need
				% to compare these groups against each other. If an intersection is found,
				% then we just need to take the node from the internal element and the 
				% external element and we have our pairs.

				% Since we are visiting nodes in order already, we can just check if that node
				% is 




				% This check each active cell to see if the current node is inside
				% There are probably some speed benefits to be found by exploiting
				% y position order, but leave that for later

				for j = 1:length(activeCells)

					cell1 = activeCells(j);

					% Can make this a bit quicker by excluding the cells that the node
					% is part of, but the process of excluding may be slower than just checking

					if ~sum(cell1==candidates) 
						if cell1.IsPointInsideCell(nodes(i).position)
							% The node is inside the cell, we need to decide
							% which edge it crossed to get there. This will either
							% be the top or bottom edges.
							% Given the geometry of the simulation, top nodes can only cross
							% top edges, likewise with bottom, so just need to determine which it is
							% There may be some rare cases where the most reasonable edge topair with
							% is from an adjacent cell, but we ignore these for now

							if nodes(i).isTopNode
								collisions{end + 1} = {nodes(i), cell1.elementTop};
							else
								collisions{end + 1} = {nodes(i), cell1.elementBottom};
							end
						end

					end

				end

				% Keeping this seemingly bloated code here.
				% For some bizarre reason, the below section of code runs quicker than the above
				% is the check ~sum(cell1==candidates) is removed, even though there are roughly 16000
				% fewer calls in the stand profiler test. And it's not just a little bit, the difference
				% is roughly 100% slower...
				% I have no idea why this is the case, but I suspect it is something to do with matlab
				% optimising itself for multiple repeated calls to the same function since the profiler
				% marks the first call at 1.2s and subsequent calls at 0.7s
				% 

				% for j = 1:length(activeCells)

				% 	cell1 = activeCells(j);

				% 	for k = j+1:length(activeCells)
				% 		c1c2 = zeros(1,4);
				% 		c2c1 = zeros(1,4);
				% 		cell2 = activeCells(k);
				% 		% If the cells aren't immediate neighbours, check for intersections
				% 		if (cell2.nodeTopLeft ~= cell1.nodeTopLeft) && (cell2.nodeTopLeft ~= cell1.nodeTopRight)
							
				% 			% Check if they intersect
				% 			c1c2(1) = cell1.IsPointInsideCell(cell2.nodeTopLeft.position);
				% 			c1c2(2) = cell1.IsPointInsideCell(cell2.nodeTopRight.position);
				% 			c1c2(3) = cell1.IsPointInsideCell(cell2.nodeBottomLeft.position);
				% 			c1c2(4) = cell1.IsPointInsideCell(cell2.nodeBottomRight.position);

				% 			c2c1(1) = cell2.IsPointInsideCell(cell1.nodeTopLeft.position);
				% 			c2c1(2) = cell2.IsPointInsideCell(cell1.nodeTopRight.position);
				% 			c2c1(3) = cell2.IsPointInsideCell(cell1.nodeBottomLeft.position);
				% 			c2c1(4) = cell2.IsPointInsideCell(cell1.nodeBottomRight.position);

				% 			% The first cell contains a node from the second cell
							
				% 		else
				% 			% If they are immediate neighbours, determine which element they have in common
				% 			if cell1.elementLeft == cell2.elementRight
				% 				% Check the right nodes of cell 1 and left nodes of cell 2
				% 				c1c2(1) = cell1.IsPointInsideCell(cell2.nodeBottomLeft.position);
				% 				c1c2(2) = cell1.IsPointInsideCell(cell2.nodeTopLeft.position);

				% 				c2c1(1) = cell2.IsPointInsideCell(cell1.nodeBottomRight.position);
				% 				c2c1(2) = cell2.IsPointInsideCell(cell1.nodeTopRight.position);
				% 			end

				% 			if cell2.elementLeft == cell1.elementRight
				% 				% Check the right nodes of cell 2 and left nodes of cell 1
				% 				c1c2(1) = cell1.IsPointInsideCell(cell2.nodeBottomRight.position);
				% 				c1c2(2) = cell1.IsPointInsideCell(cell2.nodeTopRight.position);

				% 				c2c1(1) = cell2.IsPointInsideCell(cell1.nodeBottomLeft.position);
				% 				c2c1(2) = cell2.IsPointInsideCell(cell1.nodeTopLeft.position);
				% 			end


				% 		end

				% 		% If either are true, then we have an intersection
				% 		if sum(c1c2) > 0
				% 			collisions{end + 1} = {cell1, cell2};
				% 		end

				% 		if sum(c2c1) > 0
				% 			collisions{end + 1} = {cell2, cell1};
				% 		end

				% 	end

				% end





			end


		end

		function collisions = LineIntersections(obj, E)

			% NOT FULLY IMPLEMENTED YET
			% Naming convention follows that in Computational Geometry: An Introduction p 284
			% E is ordered list of nodes (by x then y)
			% A is a list of intersecting element pairs
			% L is an ordered list of active elements (by y)

			A = {};
			L = Element.empty();

			i = 1;
			while i <= length(E)
				n = E(i);

				% Decide which elements are in the list already
				[~, Lidx] = ismember(n.elementList, L);

				% If they are not in the list, then they are to be added
				% in their correct position and intersections checked
				
				L = [L, n.elementList(Lidx)];

				% If they are already in the list, then they are to be
				% removed, and the newly adjacent elements are to be checked
				L(~Lidx) = [];
				



				i = i + 1;
			end


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

		function UpdateCentreLine(obj)

			% Makes a sequence of points that defines the centre line of the cells
			cL = [];

			obj.UpdateBoundaryCells();

			c = obj.leftBoundaryCell;

			cL(end + 1, :) = c.elementLeft.GetMidPoint();
			e = c.elementRight;

			cL(end + 1, :) = e.GetMidPoint();

			% Jump through the cells until we hit the right most cell
			c = e.GetOtherCell(c);

			while ~isempty(c) 

				e = c.elementRight;
				cL(end + 1, :) = e.GetMidPoint();
				c = e.GetOtherCell(c);
			end

			obj.centreLine = cL;

		end

		function CentreLineFFT(obj)

			obj.UpdateCentreLine();

			% To do a FFT, we need the space steps to be even,
			% so we need to interpolate between points on the
			% centre line to get the additional points


			newPoints = [];

			dx = obj.cellList(1).newCellTopLength / 10;

			% Discretise the centre line in steps of dx between the endpoints
			% This usually won't hit the exact end, but we don't care about a tiny piece at the end
			x = obj.centreLine(1,1):dx:obj.centreLine(end,1);
			y = zeros(size(x));

			j = 1;
			i = 1;
			while j < length(obj.centreLine) && i <= length(x)

				cl = obj.centreLine([j,j+1],:);
					
				m = (cl(2,2) - cl(1,2)) / (cl(2,1) - cl(1,1));
				
				c = cl(1,2) - m * cl(1,1);


				f = @(x) m * x + c;

				while i <= length(x) && x(i) < obj.centreLine(j+1,1)

					y(i) = f(x(i));
					newPoints(i,:) = [x(i), y(i)];

					i = i + 1;
				end

				j = j + 1;


			end

			Y = fft(y);

			L = ceil(- obj.centreLine(1,1) + obj.centreLine(end,1));
			P2 = abs(Y/L);
			P1 = P2(1:L/2+1);
			P1(2:end-1) = 2*P1(2:end-1);

			f = (0:(L/2))/(L/dx);
			figure
			plot(f,P1)

		end

		function UpdateBoundaryCells(obj)

			if isempty(obj.leftBoundaryCell)
				% Probably the first time this has been run,
				% so need to find the boundary cells first
				% This won't work in general, but will be the case most of the time at this point
				obj.leftBoundaryCell 	= obj.cellList(1);
				obj.rightBoundaryCell 	= obj.cellList(end);
			end

			% if obj.leftBoundaryCell.GetAge() <= obj.dt
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

			% end

			% if obj.rightBoundaryCell.GetAge() <= obj.dt
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

			% end

		end

		function [detected, varargout] = DetectCollision(obj)

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

			if detected
				obj.collisionDetected = true;
				varargout{1} = cell1;
				varargout{2} = cell2;
			end

		end

		function [detected, varargout] = DetectEdgeFlip(obj)

			% If an edge has flipped, that mean the cell is no longer a physical shape
			% so we need to detect this and stop the simulation

			detected = false;
			i = 1;
			while ~detected && i <= obj.GetNumCells()

				detected = obj.cellList(i).HasEdgeFlipped();

				i = i + 1;

			end

			if detected
				obj.edgeFlipDetected = true;
				varargout{1} = obj.cellList(i);
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