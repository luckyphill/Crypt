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

		collisions

		collisionDetectionOn = false

		collisionDetectionRequested = false

		stopOnCollision = false

		stochasticJiggle = false

		centreLine

		topWiggleRatio = 1;
		bottomWiggleRatio = 1;
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

				if ~isempty(obj.elementList(i).Node1.previousPosition) && ~isempty(obj.elementList(i).Node2.previousPosition)
					x1 = obj.elementList(i).Node1.previousPosition(1);
					x2 = obj.elementList(i).Node2.previousPosition(1);
					x = [x1,x2];
					y1 = obj.elementList(i).Node1.previousPosition(2);
					y2 = obj.elementList(i).Node2.previousPosition(2);
					y = [y1,y2];

					line(x,y)
				else
					% There are three cases, where one or both nodes are new i.e. have no previous position
					if isempty(obj.elementList(i).Node1.previousPosition) && ~isempty(obj.elementList(i).Node2.previousPosition)
						x1 = obj.elementList(i).Node1.position(1);
						x2 = obj.elementList(i).Node2.previousPosition(1);
						x = [x1,x2];
						y1 = obj.elementList(i).Node1.position(2);
						y2 = obj.elementList(i).Node2.previousPosition(2);
						y = [y1,y2];

						line(x,y)
					end

					if ~isempty(obj.elementList(i).Node1.previousPosition) && isempty(obj.elementList(i).Node2.previousPosition)
						x1 = obj.elementList(i).Node1.previousPosition(1);
						x2 = obj.elementList(i).Node2.position(1);
						x = [x1,x2];
						y1 = obj.elementList(i).Node1.previousPosition(2);
						y2 = obj.elementList(i).Node2.position(2);
						y = [y1,y2];

						line(x,y)
					end

					if isempty(obj.elementList(i).Node1.previousPosition) && isempty(obj.elementList(i).Node2.previousPosition)
						x1 = obj.elementList(i).Node1.position(1);
						x2 = obj.elementList(i).Node2.position(1);
						x = [x1,x2];
						y1 = obj.elementList(i).Node1.position(2);
						y2 = obj.elementList(i).Node2.position(2);
						y = [y1,y2];
 
						line(x,y,'LineStyle',':')
					end

				end
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
			while totalSteps < n && ~obj.collisionDetected

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

			if ~obj.collisionDetectionOn && obj.collisionDetectionRequested
				obj.UpdateIfCollisionDetectionNeeded();
			end

			if obj.collisionDetectionOn
				obj.ProcessCollisions();
			end

			obj.MakeCellsDivide();

			obj.UpdateBoundaryCells();

			obj.UpdateSimpleWiggleRatio();

			obj.UpdateAverageYDeviation();

			obj.UpdateAlphaWrinkleParameter

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
				if obj.stopOnCollision
					fprintf('Collision detected. Stopped at t = %.2f\n',obj.t);
					break;
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

				eta = obj.nodeList(i).eta;
				force = obj.nodeList(i).force;
				if obj.stochasticJiggle
					% Add in a tiny amount of stochasticity to the force calculation
					% to nudge it out of unstable equilibria

					% Make a random direction vector
					v = [rand-0.5,rand-0.5];
					v = v/norm(v);

					% Add the random vector, and make sure it is orders of magnitude
					% smaller than the actual force
					force = force + v * norm(force) / 10000;

				end
				position = obj.nodeList(i).position;

				newPosition = position + obj.dt/eta * force;

				obj.nodeList(i).MoveNode(newPosition);
			end

		end

		function MakeCellsDivide(obj)

			% Call the divide process, and update the lists
			newCells = Cell.empty;
			for i = 1:length(obj.cellList)
				c = obj.cellList(i);
				if c.IsReadyToDivide()
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

				for i = 1:4
					if ~ismember(nc.nodeList(i),obj.nodeList)
						nc.nodeList(i).id = obj.GetNextNodeId();
					end
				end

				for i = 1:4
					if ~ismember(nc.elementList(i),obj.elementList)
						nc.elementList(i).id = obj.GetNextElementId();
					end
				end

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

			obj.collisions = obj.FindCollisions(obj.nodeList);

			% For each collision there is some pair of cells that need to be corrected
			% so they are not intersecting
			% A collision could also be when an edge has flipped, so need to be careful

			% if ~isempty(obj.collisions)
			% 	obj.collisionDetected = true;
			% end

			for i = 1:length(obj.collisions)
				node = obj.collisions{i}{1};
				element = obj.collisions{i}{2};
				obj.MoveNodeAndElement(node, element);
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

			% A cell array of element pairs that collide
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




				% This checks each active cell to see if the current node is inside
				% There are probably some speed benefits to be found by exploiting
				% y position order, but leave that for later

				for j = 1:length(activeCells)

					cell1 = activeCells(j);

					if ~sum(cell1==candidates) 
						if cell1.IsPointInsideCell(nodes(i).position)
							% The node is inside the cell, we need to decide
							% which element it crossed to get there. This will either
							% be the top or bottom elements.
							% Given the geometry of the simulation, top nodes can only cross
							% top elements, likewise with bottom, so just need to determine which it is
							% There may be some rare cases where the most reasonable element topair with
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
				% if the check ~sum(cell1==candidates) is removed, even though there are roughly 16000
				% fewer calls in the standard profiler test. And it's not just a little bit, the difference
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

		function MoveNodeToElement(obj, node, element)
			% Given a node/element pair that represents a collision
			% move the node so that it sits on the element

			% Draw a line between nodes current and previous positions
			% Where this crosses the element, place the node there

			X1 = element.Node1.x;
			X2 = element.Node2.x;

			Y1 = element.Node1.y;
			Y2 = element.Node2.y;

			X3 = node.x;
			X4 = node.previousPosition(1);

			Y3 = node.y;
			Y4 = node.previousPosition(2);

			% Basic run-down of algorithm:
			% The lines are parameterised so that
			% elementLeft  = (x1(t), y1(t)) = (A1t + a1, B1t + b1)
			% elementRight = (x2(s), y2(s)) = (A2s + a2, B2s + b2)
			% where 0 <= t,s <=1
			% If the lines cross, then there is a unique value of t,s such that
			% x1(t) == x2(s) and y1(t) == y2(s)
			% There will always be a value of t and s that satisfies these
			% conditions (except for when the lines are parallel), so to make
			% sure the actual segments cross, we MUST have 0 <= t,s <=1

			% Solving this, we have
			% t = ( B2(a1 - a2) - A2(b1 - b2) ) / (A2B1 - A1B2)
			% s = ( B1(a1 - a2) - A1(b1 - b2) ) / (A2B1 - A1B2)
			% Where 
			% A1 = X2 - X1, a1 = X1
			% B1 = Y2 - Y1, b1 = Y1
			% A2 = X4 - X3, a2 = X3
			% B2 = Y4 - Y3, b2 = Y3

			denom = (X4 - X3)*(Y2 - Y1) - (X2 - X1)*(Y4 - Y3);

			if denom == 0 
				error('Lines are parallel. THis should not be possible here')
			end

			tNum = (Y4 - Y3)*(X1 - X3) - (X4 - X3)*(Y1 - Y3);
			sNum = (Y2 - Y1)*(X1 - X3) - (X2 - X1)*(Y1 - Y3);

			crossed = false;
			if abs(tNum) <= abs(denom) && abs(sNum) <= abs(denom)
					% magnitudes are correct, now check the signs
				if sign(tNum) == sign(denom) && sign(sNum) == sign(denom)
					% If the signs of the numerator and denominators are the same
					% Then s and t satisfy their range restrictions, hence the elements cross
					crossed = true;
				end
			end

			% if ~crossed
			% 	error('Lines do not cross. This should not be possible here')
			% end



			t = tNum / denom;

			inter = [(X2 - X1) * t + X1, (Y2 - Y1) * t + Y1];

			node.AdjustPosition(inter);

		end

		function MoveNodeAndElement(obj, node, element)

			% Given a node/element pair that represents a collision
			% move the node and element to the point where the collision
			% occurred

			% Grab the previous positions

			X1 = element.Node1.previousPosition(1);
			X2 = element.Node2.previousPosition(1);

			Y1 = element.Node1.previousPosition(2);
			Y2 = element.Node2.previousPosition(2);

			X3 = node.previousPosition(1);
			Y3 = node.previousPosition(2);

			% Grab the previous forces

			F1x = element.Node1.previousForce(1);
			F2x = element.Node2.previousForce(1);

			F1y = element.Node1.previousForce(2);
			F2y = element.Node2.previousForce(2);

			F3x = node.previousForce(1);
			F3y = node.previousForce(2);

			% Divide through by eta to make the working clearer
			F1xe = F1x/element.Node1.eta;
			F2xe = F2x/element.Node2.eta;

			F1ye = F1y/element.Node1.eta;
			F2ye = F2y/element.Node2.eta;

			F3xe = F3x/node.eta;
			F3ye = F3y/node.eta;

			% To find the point of contact, we need to solve
			% s(X2 + h*F2xe - (X1 + h*F1xe)) + (X1 + h*F1xe) = X3 + h*F3xe
			% s(Y2 + h*F2ye - (Y1 + h*F1ye)) + (Y1 + h*F1ye) = Y3 + h*F3ye
			% to find the time and position of contact.
			% Where Xi is the position of node i before moving
			% Fixe is the force before moving divided by etai
			% and the parameter 0<s<1 defines the location on the edge
			% while 0<h<dt defines the time within the timestep interval
			% when contact occurs

			% Rearranging this pair of equations to solve for s and h is a bitch
			% so we break the components up separately

			% When solving for s and h we end up with quadratic equations
			% meaning there are possibly two solutions
			% In the context of the model, only one of them is valid, so
			% we need to carefully choose the correct one.

			% The quadratic solving t ends up being
			% Ah^2 + Bh + C = 0, where
			A = (F2ye - F1ye) * (F3xe - F2xe) - (F2xe - F1xe) * (F3ye - F2ye);
			B = (F3xe - F1xe) * (Y2 - Y1) + (F2ye - F1ye) * (X3 - X1) - (F3ye - F1ye) * (X2 - X1) - (F2xe - F1xe) * (Y3 - Y1);
			C = (X3 - X1) * (Y2 - Y1) - (X2 - X1) * (Y3 - Y1);

			% Since we are doing many subtractions, there is a chance that we will
			% subtract numbers that are almost, (but not quite) equal due to
			% the way numbers are represented 
			% In this instance, rounding/decimal approximation errors can dominate
			% the result and cause the collision finding to fail.
			% To remedy this, we will set the result manually to 0

			if abs(   ((F2ye - F1ye) * (F3xe - F2xe)) / ((F2xe - F1xe) * (F3ye - F2ye)) - 1   ) < 1e-8
				A = 0;
			end

			% B is a bit harder to handle since there are 3 addition/subtraction operations

			if abs(   ((X3 - X1) * (Y2 - Y1)) / ((X2 - X1) * (Y3 - Y1)) - 1   ) < 1e-8
				C = 0;
			end

			if A==0
				% Sometimes A==0, and in that case we can get the solution directly
				% If B==0 as well, then there is no solution
				if B==0
					error('A=0 and B=0, no solution exists')
				end
				h = -C/B;

				if ~(0 <= h && h <= obj.dt)
					error('h falls outside the expected range')
				end

			else

				% The solutions for h are then
				if C==0
					hplus = 0;
					hminu = -B/A;
				else
					hplus = (-B + sqrt(B^2 - 4*A*C) ) / (2*A);
					hminu = (-B - sqrt(B^2 - 4*A*C) ) / (2*A);
				end

				% The solutions for s are then
				splus = ( (X3 - X1) + hplus * (F3xe - F1xe) ) / ((X2 - X1) + hplus*(F2xe - F1xe) );
				sminu = ( (X3 - X1) + hminu * (F3xe - F1xe) ) / ((X2 - X1) + hminu*(F2xe - F1xe) );

				% These equations can also be used to solve s, and they MUST give the same result
				% splus = ( (Y3 - Y1) + hplus * (F3ye - F1ye) ) / ((Y2 - Y1) + hplus*(F2ye - F1ye) );
				% sminu = ( (Y3 - Y1) + hminu * (F3ye - F1ye) ) / ((Y2 - Y1) + hminu*(F2ye - F1ye) );

				% Both t and s must satisfy their range restrictions

				s = nan;
				h = nan;
				satisfied = false;
				if (0 <= splus && splus <=1) && (0 <= hplus && hplus <= obj.dt)
					s = splus;
					h = hplus;
					satisfied = true;
				end

				if (0 <= sminu && sminu <=1) && (0 <= hminu && hminu <= obj.dt)
					if satisfied == true
						error('Both plus and minus solutions satisfy the constraints');
					end
					s = sminu;
					h = hminu;
				end

				if isnan(h)
					error('Failed to find the collision point');
				end
			end

			eN1Position = [X1 + h*F1xe, Y1 + h*F1ye];
			eN2Position = [X2 + h*F2xe, Y2 + h*F2ye];
			nPosition = [X3 + h*F3xe, Y3 + h*F3ye];

			% element.Node1.AdjustPosition(eN1Position);
			% element.Node2.AdjustPosition(eN2Position);
			% node.AdjustPosition(nPosition);

			

			% Now that we have moved the nodes back to their collision point,
			% we need to account for the 'left over force' and balance that
			% out accoridingly in a rigid body approximation
			% The left over movement will be determined by the unused time
			% i.e. dt/eta - h, multiplied by the force

			% This currently causes bouncing so is not appropriate 
			% The signs of the components may not be correct


			% Let u be the unit vector along the edge, and v the
			% unit vector perpendicular.

			u = element.GetVector1to2();
			v = [u(2), -u(1)];

			F1 = [F1x, F1y];
			F2 = [F2x, F2y];
			F3 = [F3x, F3y];

			% Perpendicular forces
			Fp1 = dot(F1, v);
			Fp2 = dot(F2, v);
			Fp3 = dot(F3, v);

			% Tangent forces
			Ft1 = dot(F1, u);
			Ft2 = dot(F2, u);
			Ft3 = dot(F3, u); 

			l = element.GetLength();
			l1 = norm(eN1Position - nPosition);
			l2 = norm(eN2Position - nPosition);

			% Balanced out net perpendicular forces
			Fn1 = Ft1 * u;
			Fn2 = Ft2 * u;
			Fn3 = Ft3 * u;

			% Now we manually apply the perpendicular forces. This is not the best method
			% and will probably cause issues when multiple nodes are in
			% contact with the same edge

			eN1Position = eN1Position + (obj.dt - h) * Fn1 / element.Node1.eta;
			eN2Position = eN2Position + (obj.dt - h) * Fn2 / element.Node2.eta;
			nPosition = nPosition + (obj.dt - h) * Fn3 / node.eta;

			% % Finally, we apply the parallel forces. This will result in the
			% % contacting node to slide along the surface of the element
			% eN1Position = eN1Position + (obj.dt - h) * Ft1 / element.Node1.eta;
			% eN2Position = eN2Position + (obj.dt - h) * Ft2 / element.Node2.eta;
			% nPosition = nPosition + (obj.dt - h) * Ft3 / node.eta;

			element.Node1.AdjustPosition(eN1Position);
			element.Node2.AdjustPosition(eN2Position);
			node.AdjustPosition(nPosition);

			
		end

		function TransmitForcesPair(obj,n,e)

			% This takes a node-element pair where the node is on
			% the element, and calculates the force transmission
			% from one to the other
			% It uses the drag dominated equations of motion I developed
			% for a rigid body - see research diary

			% To solve the motion, we need to account for linear
			% movement and rotational movement. To do this, we solve
			% the angular velocity of the element in its body
			% system of coordinates. This requires a "moment of drag"
			% for the element, based on its length and the drag
			% coefficients of its nodes. We produce an angle that the
			% element rotates through during the time step
			% In addition to the rotation, we solve the linear motion
			% of the element at its "centre of drag", again, determined
			% by its length and the drag coefficients of its nodes. This
			% produces a vector that the centre of drag moves along in
			% the given time interval.
			% Once we have both the angle and vector, the rotation is aplied
			% first, moving the nodes to their rotated position assuming
			% no linear movement, then the linear movement is applied to each
			% node.

			% As yet, this doesn't account for the motion if the element
			% acting on the node

			
			% Grab the components we need so the code is cleaner
			F1 = e.Node1.force';
			F2 = e.Node2.force';
			Fa = n.force';

			eta1 = e.Node1.eta;
			eta2 = e.Node2.eta;
			etaA = n.eta;

			rA = n.position';
			r1 = e.Node1.position';
			r2 = e.Node2.position';
			
			
			% First, find the angle.
			% To do this, we need the force from the node, in the elements
			% body system of coordinates

			u = e.GetVector1to2();
			v = [u(2), -u(1)];

			Fab = [dot(Fa, v) * v, dot(Fa, u) * u];

			% Next, we determine the equivalent drag of the centre
			% and the position of the centre of drag
			etaD = eta1 + eta2;
			rD = (eta1 * r1 + eta2 * r2) / etaD;

			% We then need the vector from the centre of drag to
			% both nodes (note, these are relative the fixed system of
			% coordinates, not the body system of coordinates)
			rDto1 = r1 - rD;
			rDto2 = r2 - rD;

			% These give us the moment of drag about the centre of drag
			ID = eta1 * norm(rDto1)^2 + eta2 * norm(rDto2)^2;

			% The moment created by the node is then force times
			% perpendicular distance.  We must use the body system of
			% coordinates in order to get the correct direction.
			% (We could probably get away without the transform, 
			% since we only need the length, but wed have to be
			% careful about choosing the sign correctly)
			
			rDtoA = rA - rD;

			rDtoAb = dot(rDtoA, v) * v  +  dot(rDtoA, u) * u;

			% The moment is technically rDtoAby * Fabx - rDtoAbx * Faby
			% but by definition, the y-axis aligns with the element,
			% so all x components are 0
			M = -rDtoAb(2) * Fab(1);

			% Now we can find the change in angle in the given time step
			a = obj.dt * M / ID;

			% This angle can now be used in a rotation matrix to determine the new
			% position of the nodes. We can apply it directly to rDto1 and rDto2
			% since the angle is in the plane (a consequnce of 2D)

			Rot = [cos(a), -sin(a); sin(a), cos(a)];

			rDto1_new = Rot * rDto1;
			rDto2_new = Rot * rDto2;
			rDtoA_new = Rot * rDtoA;

			% Finally, the new positions of the nodes in the fixed system
			% of coordinates found by summing the vectors

			r1f = rD + rDto1_new;
			r2f = rD + rDto2_new;
			rAf = rD + rDtoA_new;

			% Hooray, weve done it! All that is left to do it translate
			% the nodes with the linear motion
			r1f = r1f + (obj.dt * Fa) / etaD;
			r2f = r2f + (obj.dt * Fa) / etaD;
			rAf = rAf + (obj.dt * Fa) / etaD;


			e.Node1.MoveNode(r1f);
			e.Node2.MoveNode(r2f);
			n.MoveNode(rAf);

		end

		function UpdateIfCollisionDetectionNeeded(obj)

			% An approximate way to tell if collision detection is needed to speed up
			% simulation time when there is no chance

			detectionThresholdRatio = 1.8;

			if (obj.topWiggleRatio > detectionThresholdRatio || obj.bottomWiggleRatio > detectionThresholdRatio)
				obj.collisionDetectionOn = true;
				fprintf('Collision detection turned on at t=%.4f\n',obj.t);
			end

		end

		function UpdateSimpleWiggleRatio(obj)

			% Compares the x range that cells cover to the
			% path length that the top and bottom elements cover

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
			figure
			plot(x,y)

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