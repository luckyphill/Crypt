classdef Cell < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% Essential porperties of a node
		id

		% This will be circular - each element will have two nodes
		% each node can be part of multiple elements
		elementTop
		elementBottom
		elementLeft
		elementRight

		elementList

		% Can't know for certain which order the nodes will be placed into the element
		% so need to determine these carefully when initialising
		nodeTopLeft
		nodeTopRight
		nodeBottomLeft
		nodeBottomRight

		% Knowing the location of the nodes is extremely useful, but sometimes it's quicker
		% to access a list
		nodeList

		age = 0
		cellArea
		cellPerimeter

		newCellTargetArea = 0.5
		grownCellTargetArea = 1
		currentCellTargetArea = 1

		newCellTargetPerimeter = 3
		grownCellTargetPerimeter = 4
		currentCellTargetPerimeter = 4

		% The natural length of the top and bottom elements
		% used to make cells trapezoidal shaped
		newCellTopLength = 0.5
		grownCellTopLength = 1
		currentCellTopLength = 1

		newCellBottomLength = 0.5
		grownCellBottomLength = 1
		currentCellBottomLength = 1

		CellCycleModel

		areaGradientTopLeft
		areaGradientTopRight
		areaGradientBottomRight
		areaGradientBottomLeft

		perimeterGradientTopLeft
		perimeterGradientTopRight
		perimeterGradientBottomRight
		perimeterGradientBottomLeft

		deformationEnergyParameter = 10
		surfaceEnergyParameter = 1
		
	end

	methods
		function obj = Cell(Cycle, elementList, id)
			% All the initilising
			% A cell will always have 4 elements
			% elementList must have 4 elements in the order [ElementTop, ElementBottom, ElementLeft, ElementRight]

			obj.elementTop = elementList(1);
			obj.elementBottom = elementList(2);
			obj.elementLeft = elementList(3);
			obj.elementRight = elementList(4);

			obj.elementList = elementList;

			obj.elementTop.AddCell(obj);
			obj.elementBottom.AddCell(obj);
			obj.elementLeft.AddCell(obj);
			obj.elementRight.AddCell(obj);

			obj.CellCycleModel = Cycle;

			obj.AddNodesInOrder();

			obj.id = id;

		end

		function set.CellCycleModel( obj, v )
			% This is to validate the object given to outputType in the constructor
			if isa(v, 'AbstractCellCycleModel')
            	validateattributes(v, {'AbstractCellCycleModel'}, {});
            	obj.CellCycleModel = v;
            else
            	error('c:NotValidCCM','Not a valid cell cycle');
            end

        end

		function UpdateCellArea(obj)
			% Use the shoelace formula to calculate the cellArea of the cell
			% See: https://en.wikipedia.org/wiki/Shoelace_formula

			tl = obj.nodeTopLeft.position;
			tr = obj.nodeTopRight.position;
			br = obj.nodeBottomRight.position;
			bl = obj.nodeBottomLeft.position;
			

			obj.cellArea = 0.5 * abs( tl(1) * tr(2) + tr(1) * br(2) + br(1) * bl(2) + bl(1) * tl(2)...
								-  tl(2) * tr(1) - tr(2) * br(1) - br(2) * bl(1) - bl(2) * tl(1));

		end

		function UpdateCellPerimeter(obj)

			obj.cellPerimeter = obj.elementTop.GetLength() + obj.elementRight.GetLength() + obj.elementBottom.GetLength() + obj.elementLeft.GetLength();

		end

		function targetArea = GetCellTargetArea(obj)
			% This is so the target area can be a function of cell age

			fraction = obj.CellCycleModel.GetGrowthPhaseFraction();

			targetArea = obj.newCellTargetArea + fraction * (obj.grownCellTargetArea - obj.newCellTargetArea);

		end

		function currentArea = GetCellArea(obj)

			obj.UpdateCellArea();

			currentArea = obj.cellArea;

		end

		function targetPerimeter = GetCellTargetPerimeter(obj)
			% This is so the target Perimeter can be a function of cell age
			targetArea = obj.GetCellTargetArea();	
			targetPerimeter = 2 * (1 + targetArea);

		end

		function currentPerimeter = GetCellPerimeter(obj)

			obj.UpdateCellPerimeter();
			currentPerimeter = obj.cellPerimeter;

		end

		function cellLeft = GetAdjacentCellLeft(obj)

			cellLeft = obj.elementLeft.GetOtherCell(obj);

		end

		function cellRight = GetAdjacentCellRight(obj)

			cellRight = obj.elementRight.GetOtherCell(obj);

		end

		function newCell = Divide(obj)
			% To divide, split the top and bottom elements in half
			% add an element in the middle

			% This process needs to be done carefully to update all the new
			% links between node, element and cell

			%  o------o------o
			%  |      |      |
			%  |      |      |
			%  |      |      |
			%  |      |      |
			%  |      |      |
			%  o------o------o

			% Becomes

			%  o------o~~~x---o
			%  |      |   l   |
			%  |      |   l   |
			%  |      |   l   |
			%  |      |   l   |
			%  |      |   l   |
			%  o------o~~~x---o

			% Links for everything in new cell will automatically be correct
			% but need to update links for old centre nodes and old centre edge
			% because they will point to the original cell


			% Find the new points for the nodes

			midTop 				= obj.elementTop.GetMidPoint;
			midBottom 			= obj.elementBottom.GetMidPoint;

			% Give -ve ids because id is a feature of the simulation
			% and can't be assigned here. This is handled in AbstractCellSimulation

			% Make the new nodes
			nodeMiddleTop 		= Node(midTop(1),midTop(2),-1);
			nodeMiddleBottom 	= Node(midBottom(1), midBottom(2),-2);
			
			% Make the new elements,
			newElementMiddle 	= Element(nodeMiddleTop, nodeMiddleBottom, -1);
			newElementTop 		= Element(obj.nodeTopLeft, nodeMiddleTop, -2);
			newElementBottom 	= Element(obj.nodeBottomLeft, nodeMiddleBottom, -3);

			% Duplicate the cell cycle model from the old cell
			newCCM = obj.CellCycleModel.Duplicate();

			% Now we have all the parts we need to build the new cell in its correct position
			% The new cell will have the correct links with its constituent elements and nodes
			newCell = Cell(newCCM, [newElementTop, newElementBottom, obj.elementLeft, newElementMiddle], 1);


			% Now we need to remodel the old cell and fix all the links

			% The old cell needs to change the links to the top left and bottom left nodes
			% and the left element
			% The old left element needs it's link to old cell (it already has a link to new cell)

			% The top and bottom elements stay with the old cell, but we need to replace the
			% left nodes with the new middle nodes. This function repairs the links from node
			% to cell
			obj.elementTop.ReplaceNode(obj.nodeTopLeft, nodeMiddleTop);
			obj.elementBottom.ReplaceNode(obj.nodeBottomLeft, nodeMiddleBottom);

			% Fix the link to the top left and bottom left nodes
			obj.nodeTopLeft.RemoveCell(obj);
			obj.nodeBottomLeft.RemoveCell(obj);

			nodeMiddleTop.AddCell(obj);
			nodeMiddleBottom.AddCell(obj);

			obj.nodeTopLeft = nodeMiddleTop;
			obj.nodeBottomLeft = nodeMiddleBottom;


			% Old top left nodes are now replaced.

			% Now to fix the links with the new left element and old left element

			% At this point, old left element still links to old cell (and vice versa), and new left element
			% only links to new cell.

			obj.elementLeft.RemoveCell(obj);
			obj.elementLeft = newElementMiddle;

			newElementMiddle.AddCell(obj);
						

			% Old cell should be completely remodelled by this point, adjust the age back to zero

			obj.CellCycleModel.SetAge(0);

			% Finally, reset the node list
			obj.nodeList = [obj.nodeTopLeft, obj.nodeTopRight, obj.nodeBottomRight, obj.nodeBottomLeft];
			obj.elementList = [obj.elementTop, obj.elementBottom, obj.elementLeft, obj.elementRight];
		end

		function ready = IsReadyToDivide(obj)

			ready = obj.CellCycleModel.IsReadyToDivide();

		end

		function AgeCell(obj, dt)

			% This will be done at the end of the time step
			obj.age = obj.age + dt;
			obj.CellCycleModel.AgeCellCycle(dt);

		end

		function age = GetAge(obj)

			age = obj.CellCycleModel.GetAge();
			
		end


		function inside = IsPointInsideCell(obj, point)

			% Assemble vertices in the correct order to produce a quadrilateral

			x = [obj.nodeList.x];
			y = [obj.nodeList.y];

			[inside, on] = inpolygon(point(1), point(2), x ,y);

			if inside && on
				inside = false;
			end

		end

		function flipped = HasEdgeFlipped(obj)

			flipped = false;
			% An edge will only flip on the top or bottom
			% When that happens, the left and right edges will cross
			% The following algorithm decides if the edges cross

			X1 = obj.elementLeft.Node1.x;
			X2 = obj.elementLeft.Node2.x;

			Y1 = obj.elementLeft.Node1.y;
			Y2 = obj.elementLeft.Node2.y;

			X3 = obj.elementRight.Node1.x;
			X4 = obj.elementRight.Node2.x;

			Y3 = obj.elementRight.Node1.y;
			Y4 = obj.elementRight.Node2.y;

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

			% denom == 0 means parallel

			if denom ~= 0
				% if the numerator for either t or s expression is larger than the
				% |denominator|, then |t| or |s| will be greater than 1, i.e. out of their range
				% so both must be less than
				tNum = (Y4 - Y3)*(X1 - X3) - (X4 - X3)*(Y1 - Y3);
				sNum = (Y2 - Y1)*(X1 - X3) - (X2 - X1)*(Y1 - Y3);
				
				if abs(tNum) <= abs(denom) && abs(sNum) <= abs(denom)
					% magnitudes are correct, now check the signs
					if sign(tNum) == sign(denom) && sign(sNum) == sign(denom)
						% If the signs of the numerator and denominators are the same
						% Then s and t satisfy their range restrictions, hence the elements cross
						flipped = true;
					end
				end
			end

		end

		function DrawCell(obj)

			% plot a line for each element

			% h = figure();
			hold on
			elementList = [obj.elementTop, obj.elementBottom, obj.elementLeft, obj.elementRight];
			for i = 1:length(elementList)

				x1 = elementList(i).Node1.x;
				x2 = elementList(i).Node2.x;
				x = [x1,x2];
				y1 = elementList(i).Node1.y;
				y2 = elementList(i).Node2.y;
				y = [y1,y2];

				line(x,y)
			end

			axis equal

		end

		function DrawCellPrevious(obj)

			% plot a line for each element

			h = figure();
			hold on
			elementList = [obj.elementTop, obj.elementBottom, obj.elementLeft, obj.elementRight];
			for i = 1:length(elementList)

				x1 = elementList(i).Node1.previousPosition(1);
				x2 = elementList(i).Node2.previousPosition(1);
				x = [x1,x2];
				y1 = elementList(i).Node1.previousPosition(2);
				y2 = elementList(i).Node2.previousPosition(2);
				y = [y1,y2];

				line(x,y)
			end

			axis equal

		end

	end

	methods (Access = private)
		function AddNodesInOrder(obj)
			% Adds the nodes properly so we always know which node is where

			% NodeTopLeft must be in both elementTop and elementLeft etc.
			% so use this fact to allocate the nodes properly

			top1 = obj.elementTop.Node1;
			top2 = obj.elementTop.Node2;

			left1 = obj.elementLeft.Node1;
			left2 = obj.elementLeft.Node2;

			if top1 == left1
				obj.nodeTopLeft = top1;
				obj.nodeTopRight = top2;
				obj.nodeBottomLeft = left2;
				obj.nodeBottomRight = obj.elementBottom.GetOtherNode(left2);
			end

			if top1 == left2
				obj.nodeTopLeft = top1;
				obj.nodeTopRight = top2;
				obj.nodeBottomLeft = left1;
				obj.nodeBottomRight = obj.elementBottom.GetOtherNode(left1);
			end

			if top2 == left1
				obj.nodeTopLeft = top2;
				obj.nodeTopRight = top1;
				obj.nodeBottomLeft = left2;
				obj.nodeBottomRight = obj.elementBottom.GetOtherNode(left2);
			end

			if top2 == left2
				obj.nodeTopLeft = top2;
				obj.nodeTopRight = top1;
				obj.nodeBottomLeft = left1;
				obj.nodeBottomRight = obj.elementBottom.GetOtherNode(left1);
			end

			% This order is critical for IsPointIncideCell to work correctly
			obj.nodeList = [obj.nodeTopLeft, obj.nodeTopRight, obj.nodeBottomRight, obj.nodeBottomLeft];
			
			obj.nodeTopLeft.AddCell(obj);
			obj.nodeTopLeft.isTopNode = true;
			obj.nodeTopRight.AddCell(obj);
			obj.nodeTopRight.isTopNode = true;
			obj.nodeBottomLeft.AddCell(obj);
			obj.nodeBottomLeft.isTopNode = false;
			obj.nodeBottomRight.AddCell(obj);
			obj.nodeBottomRight.isTopNode = false;

		end

	end


end