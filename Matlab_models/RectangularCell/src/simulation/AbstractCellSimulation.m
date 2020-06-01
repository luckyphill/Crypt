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

		edgeFlipDetected = false

		stochasticJiggle = true

		centreLine

		wiggleRatio = 1;

		avgYDeviation
		alphaWrinkleParameter

		storeWiggleRatio = []
		storeNumCells = []
		storeAvgYDeviation = []
		storeAlphaWrinkleParameter = []

		leftBoundaryCell
		rightBoundaryCell

		leftBoundary = -Inf;
		rightBoundary = Inf;

		cellBasedForces AbstractCellBasedForce
		elementBasedForces AbstractElementBasedForce
		neighbourhoodBasedForces AbstractNeighbourhoodBasedForce

		boxes SpacePartition

		usingBoxes = true;

		limitedWidth = false;
		
	end

	properties (Abstract)

		dt
		t

	end

	methods

		function Visualise(obj)

			h = figure();
			hold on

			% Intitialise the vector
			fillObjects(length(obj.cellList)) = fill([1,1],[2,2],'r');

			for i = 1:length(obj.cellList)
				c = obj.cellList(i);
				
				x1 = c.nodeTopLeft.x;
				x2 = c.nodeTopRight.x;
				x3 = c.nodeBottomRight.x;
				x4 = c.nodeBottomLeft.x;
				x = [x1,x2,x3,x4];
				y1 = c.nodeTopLeft.y;
				y2 = c.nodeTopRight.y;
				y3 = c.nodeBottomRight.y;
				y4 = c.nodeBottomLeft.y;
				y = [y1,y2,y3,y4];

				fillObjects(i) = fill(x,y,c.GetColour());
			end

			axis equal

			obj.UpdateCentreLine();
			plot(obj.centreLine(:,1), obj.centreLine(:,2), 'k');


		end

		function VisualiseLine(obj)

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

		function VisualiseLinePrevious(obj)

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

			plot(t,obj.storeWiggleRatio, t, obj.storeAvgYDeviation, t, obj.storeAlphaWrinkleParameter);
			legend({'Wiggle', 'YDev', 'alpha'});

		end

		function SetRNGSeed(obj, seed)

			rng(seed);

		end

		function AnimateLine(obj, n, sm)
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
			while totalSteps < n && ~obj.edgeFlipDetected

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

				% Delete the line objects when there are too many
				for j = length(lineObjects):-1:length(obj.elementList)+1
					lineObjects(j).delete;
					lineObjects(j) = [];
				end
				drawnow
				title(sprintf('t=%g',obj.t));

			end

		end


		function Animate(obj, n, sm)
			% Since we aren't storing data at this point, the only way to animate is to
			% calculate then plot

			% Set up the line objects initially

			% Initialise an array of line objects
			h = figure();
			hold on

			fillObjects(length(obj.cellList)) = fill([1,1],[2,2],'r');

			for i = 1:length(obj.cellList)
				c = obj.cellList(i);
				
				x1 = c.nodeTopLeft.x;
				x2 = c.nodeTopRight.x;
				x3 = c.nodeBottomRight.x;
				x4 = c.nodeBottomLeft.x;
				x = [x1,x2,x3,x4];
				y1 = c.nodeTopLeft.y;
				y2 = c.nodeTopRight.y;
				y3 = c.nodeBottomRight.y;
				y4 = c.nodeBottomLeft.y;
				y = [y1,y2,y3,y4];

				fillObjects(i) = fill(x,y,c.GetColour());
			end

			totalSteps = 0;
			while totalSteps < n && ~obj.edgeFlipDetected

				obj.NTimeSteps(sm);
				totalSteps = totalSteps + sm;

				for j = 1:length(obj.cellList)
					c = obj.cellList(j);

					x1 = c.nodeTopLeft.x;
					x2 = c.nodeTopRight.x;
					x3 = c.nodeBottomRight.x;
					x4 = c.nodeBottomLeft.x;
					x = [x1,x2,x3,x4];
					y1 = c.nodeTopLeft.y;
					y2 = c.nodeTopRight.y;
					y3 = c.nodeBottomRight.y;
					y4 = c.nodeBottomLeft.y;
					y = [y1,y2,y3,y4];

					if j > length(fillObjects)
						fillObjects(j) = fill(x,y,c.GetColour());
					else
						fillObjects(j).XData = x;
						fillObjects(j).YData = y;
						fillObjects(j).FaceColor = c.GetColour();
					end
				end

				% Delete the line objects when there are too many
				for j = length(fillObjects):-1:length(obj.cellList)+1
					fillObjects(j).delete;
					fillObjects(j) = [];
				end
				drawnow
				title(sprintf('t=%g',obj.t),'Interpreter', 'latex');

			end

		end

		function NextTimeStep(obj)
			% Updates all the forces and applies the movements
			
			
			obj.GenerateCellBasedForces();
			obj.GenerateElementBasedForces();

			if obj.usingBoxes
				obj.GenerateNeighbourhoodBasedForces();
			end

			% Element forces must happen last because it contains the rigid body
			% tweak to prevent element flipping. This is a dodgy way to do it,
			% but I can't think of a better and quick solution
			% 17042020 no longer necessary to have these in this order because not using
			% that particular edge flipping stopper. Still ought to implement a 'modifier'
			% stage in time stepping
			
			
			obj.MakeNodesMove();

			obj.MakeCellsDivide();

			obj.UpdateBoundaryCells();

			if obj.limitedWidth
				obj.KillBoundaryCells();
			end

			obj.UpdateWiggleRatio();

			% obj.UpdateAverageYDeviation();

			% obj.UpdateAlphaWrinkleParameter

			% Store the relevant data
			obj.storeWiggleRatio(end + 1) = obj.wiggleRatio;
			% obj.storeNumCells(end + 1) = obj.GetNumCells();
			% obj.storeAvgYDeviation(end + 1) = obj.avgYDeviation;
			% obj.storeAlphaWrinkleParameter(end + 1) = obj.alphaWrinkleParameter;

			obj.MakeCellsAge();

			obj.t = obj.t + obj.dt;

		end

		function NTimeSteps(obj, n)
			% Advances a set number of time steps
			
			for i = 1:n
				% Do all the calculations
				obj.NextTimeStep();

				% Make sure nothing has gone wrong
				if obj.DetectEdgeFlip()
					error('Edge flip detected. Stopped at t = %.2f\n',obj.t);
					break;
				end

				if mod(i, 1000) == 0
					fprintf('Time = %3.3f, Steps = %6d\n',obj.t,i);
				end

			end
			
		end

		function RunToTime(obj, t)

			% Given a time, run the simulation until we reach said time
			if t > obj.t
				n = ceil((t-obj.t) / obj.dt);
				NTimeSteps(obj, n);
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

		function GenerateNeighbourhoodBasedForces(obj)

			for i = 1:length(obj.neighbourhoodBasedForces)
				obj.neighbourhoodBasedForces(i).AddNeighbourhoodBasedForces(obj.nodeList, obj.boxes);
			end

		end

		function MakeNodesMove(obj)

			for i = 1:length(obj.nodeList)
				
				n = obj.nodeList(i);

				eta = n.eta;
				force = n.force;
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

				newPosition = n.position + obj.dt/eta * force;

				n.MoveNode(newPosition);

				if obj.usingBoxes
					obj.boxes.UpdateBoxForNode(n);
				end
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

				% Writing the code without the loop since we know precisely which
				% nodes and elements are new
				nc.nodeTopRight.id = obj.GetNextNodeId();
				nc.nodeBottomRight.id = obj.GetNextNodeId();
				
				obj.boxes.PutNodeInBox(nc.nodeTopRight);
				obj.boxes.PutNodeInBox(nc.nodeBottomRight);

				nc.elementTop.id = obj.GetNextElementId();
				nc.elementRight.id = obj.GetNextElementId();
				nc.elementBottom.id = obj.GetNextElementId();

				obj.boxes.PutElementInBoxes(nc.elementTop);
				obj.boxes.PutElementInBoxes(nc.elementBottom);

				% Before division, the top and bottom elements for oc
				% extended from nc.nodeTopLeft to oc.nodeTopRight
				% so we need to remove the left half of the original
				% top and bottom elements from the element space partition

				oc = nc.elementRight.GetOtherCell(nc);

				[ql,il,jl] = obj.boxes.GetBoxIndicesBetweenNodes(nc.nodeTopLeft, oc.nodeTopRight);
				for i = 1:length(ql)
					obj.boxes.RemoveElement(ql(i),il(i),jl(i),oc.elementTop);
				end

				[ql,il,jl] = obj.boxes.GetBoxIndicesBetweenNodes(nc.nodeBottomLeft, oc.nodeBottomRight);
				for i = 1:length(ql)
					obj.boxes.RemoveElement(ql(i),il(i),jl(i),oc.elementBottom);
				end

				obj.boxes.PutElementInBoxes(oc.elementTop);
				obj.boxes.PutElementInBoxes(oc.elementBottom);


				% This loop is unecessary because for a new well
				% we know it must be the right nodes that are new
				% for i = 1:4
				% 	% If the new nodes aren't already in the node list
				% 	% give them the next ID in sequence and add them to
				% 	% the space partition
				% 	if ~ismember(nc.nodeList(i),obj.nodeList)
				% 		nc.nodeList(i).id = obj.GetNextNodeId();
				% 		if obj.usingBoxes
				% 			obj.boxes.PutNodeInBox(nc.nodeList(i));
				% 		end
				% 	end

				% end

				% for i = 1:4
				% 	if ~ismember(nc.elementList(i),obj.elementList)
				% 		nc.elementList(i).id = obj.GetNextElementId();
				% 		if obj.usingBoxes && ~nc.elementList(i).IsElementInternal()
				% 			% Need to put the new elements in their correct boxes
				% 			obj.boxes.PutElementInBoxes(nc.elementList(i));
				% 			% This code doesn't account for removing the shortened
				% 			% element from boxes it is not longer in
				% 		end
				% 	end
				% end

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

		function AddNeighbourhoodBasedForce(obj, f)

			if isempty(obj.neighbourhoodBasedForces)
				obj.neighbourhoodBasedForces = f;
			else
				obj.neighbourhoodBasedForces(end + 1) = f;
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

		function UpdateWiggleRatio(obj)

			obj.UpdateCentreLine();

			l = 0;

			for i = 1:length(obj.centreLine)-1
				l = l + norm(obj.centreLine(i,:) - obj.centreLine(i+1,:));
			end

			w = obj.centreLine(end,1) - obj.centreLine(1,1);

			obj.wiggleRatio = l / w;
		
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

		function KillBoundaryCells(obj)

			% Kills the cells at the boundary if requested
			UpdateBoundaryCells(obj);

			while obj.IsPastLeftBoundary(obj.leftBoundaryCell)

				obj.RemoveLeftBoundaryCellFromSimulation();

			end

			while obj.IsPastRightBoundary(obj.rightBoundaryCell)

				obj.RemoveRightBoundaryCellFromSimulation();

			end

		end

		function past = IsPastLeftBoundary(obj, c)

			past = false;
			if c.nodeTopRight.x < obj.leftBoundary || c.nodeBottomRight.x < obj.leftBoundary
				past = true;
			end

		end

		function past = IsPastRightBoundary(obj, c)

			past = false;
			if c.nodeTopLeft.x > obj.rightBoundary || c.nodeBottomLeft.x > obj.rightBoundary
				past = true;
			end

		end

		function RemoveBoundaryCellFromSimulation(obj, c)

			% This is used when a cell is removed on the boundary
			% A different method is needed when the cell is internal

			% Need to becareful to actually remove the nodes etc.
			% rather than just lose the links

			nodeRemoveList = Node.empty();
			elementRemoveList = Element.empty();

			for i = 1:length(c.nodeList)
				
				n = c.nodeList(i);
				if length(n.cellList) == 1
					% If the node is only part of the cell to be killed
					% then we need to get rid of it
					obj.nodeList(obj.nodeList == n) = [];
					nodeRemoveList(end + 1) = n;
				else
					% If the node is still part of an existing cell
					% we need to update its cell list (and element list too)
					n.cellList(n.cellList == c) = [];
				end

			end

			for i = 1:length(c.elementList)
				
				e = c.elementList(i);
				if length(e.cellList) == 1
					% If the node is only part of the cell to be killed
					% then we need to get rid of it
					obj.elementList(obj.elementList == e) = [];
					e.nodeList(e.nodeList == e.Node1) = [];
					e.nodeList(e.nodeList == e.Node2) = [];
					elementRemoveList(end + 1) = e;
				else
					e.cellList(e.cellList == c) = [];
				end

			end

			obj.cellList(obj.cellList == c) = [];
			
			for i = 1:length(nodeRemoveList)
				nodeRemoveList(i).delete;
			end

			for i = 1:length(elementRemoveList)
				elementRemoveList(i).delete;
			end

			c.delete;

		end

		function RemoveLeftBoundaryCellFromSimulation(obj)

			% This is used when a cell is removed on the boundary
			% A different method is needed when the cell is internal

			% Need to becareful to actually remove the nodes etc.
			% rather than just lose the links

			c = obj.leftBoundaryCell;
			obj.leftBoundaryCell = c.elementRight.GetOtherCell(c);

			% Clean up elements

			obj.elementList(obj.elementList == c.elementTop) = [];
			obj.elementList(obj.elementList == c.elementLeft) = [];
			obj.elementList(obj.elementList == c.elementBottom) = [];

			c.nodeTopRight.elementList( c.nodeTopRight.elementList ==  c.elementTop ) = [];
			c.nodeBottomRight.elementList( c.nodeBottomRight.elementList ==  c.elementBottom ) = [];

			c.elementRight.cellList(c.elementRight.cellList == c) = [];

			obj.boxes.RemoveElementFromPartition(c.elementTop);
			obj.boxes.RemoveElementFromPartition(c.elementLeft);
			obj.boxes.RemoveElementFromPartition(c.elementBottom);

			c.elementTop.delete;
			c.elementLeft.delete;
			c.elementBottom.delete;

			% Clean up nodes

			obj.nodeList(obj.nodeList == c.nodeTopLeft) = [];
			obj.nodeList(obj.nodeList == c.nodeBottomLeft) = [];

			obj.boxes.RemoveNodeFromPartition(c.nodeTopLeft);
			obj.boxes.RemoveNodeFromPartition(c.nodeBottomLeft);

			c.nodeTopLeft.delete;
			c.nodeBottomLeft.delete;

			% Clean up cell

			obj.cellList(obj.cellList == c) = [];

			c.delete;

		end

		function RemoveRightBoundaryCellFromSimulation(obj)

			% This is used when a cell is removed on the boundary
			% A different method is needed when the cell is internal

			% Need to becareful to actually remove the nodes etc.
			% rather than just lose the links

			c = obj.rightBoundaryCell;
			obj.rightBoundaryCell = c.elementLeft.GetOtherCell(c);

			
			% Clean up elements

			obj.elementList(obj.elementList == c.elementTop) = [];
			obj.elementList(obj.elementList == c.elementRight) = [];
			obj.elementList(obj.elementList == c.elementBottom) = [];

			c.nodeTopLeft.elementList( c.nodeTopLeft.elementList ==  c.elementTop ) = [];
			c.nodeBottomLeft.elementList( c.nodeBottomLeft.elementList ==  c.elementBottom ) = [];

			c.elementLeft.cellList(c.elementLeft.cellList == c) = [];

			obj.boxes.RemoveElementFromPartition(c.elementTop);
			obj.boxes.RemoveElementFromPartition(c.elementRight);
			obj.boxes.RemoveElementFromPartition(c.elementBottom);

			c.elementTop.delete;
			c.elementRight.delete;
			c.elementBottom.delete;

			% Clean up nodes 

			obj.nodeList(obj.nodeList == c.nodeTopRight) = [];
			obj.nodeList(obj.nodeList == c.nodeBottomRight) = [];

			obj.boxes.RemoveNodeFromPartition(c.nodeTopRight);
			obj.boxes.RemoveNodeFromPartition(c.nodeBottomRight);

			c.nodeTopRight.delete;
			c.nodeBottomRight.delete;

			% Finally clean up cell

			obj.cellList(obj.cellList == c) = [];

			c.delete;

		end

		function [detected, varargout] = DetectEdgeFlip(obj)

			% If an edge has flipped, that means the cell is no longer a physical shape
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