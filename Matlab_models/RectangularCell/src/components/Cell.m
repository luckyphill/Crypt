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

		% Can't know for certain which order the nodes will be placed into the element
		% so need to determine these carefully when initialising
		nodeTopLeft
		nodeTopRight
		nodeBottomLeft
		nodeBottomRight

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

		function newCell = Divide(obj)
			% To divide, split the top and bottom elements in half
			% add an element in the middle

			% After division, cell growth occurs

			tl 					= obj.nodeTopLeft.position;
			tr 					= obj.nodeTopRight.position;
			br 					= obj.nodeBottomRight.position;
			bl 					= obj.nodeBottomLeft.position;

			midTop 				= tl + (tr - tl)/2;
			midBottom 			= bl + (br - bl)/2;

			% TODO: Sort out id counting from here (maybe remove it altogether?)
			nodeMiddleTop 		= Node(midTop(1),midTop(2),1);
			nodeMiddleBottom 	= Node(midBottom(1), midBottom(2),2);
			
			elementMiddle 		= Element(nodeMiddleTop, nodeMiddleBottom, 1);

			% Existing cell is moved to the right, new cell appears to the left

			newElementTop 		= Element(obj.nodeTopLeft, nodeMiddleTop, 1);
			newElementBottom 	= Element(obj.nodeBottomLeft, nodeMiddleBottom, 1);

			% Create new cell before remodelling old cell
			newCCM = obj.CellCycleModel.Duplicate();
			newCell = Cell(newCCM, [newElementTop, newElementBottom, obj.elementLeft, elementMiddle], 1);

			% Preserve the existing elements to stay with the original cell
			obj.elementTop.ReplaceNode(obj.nodeTopLeft, nodeMiddleTop);
			obj.elementBottom.ReplaceNode(obj.nodeBottomLeft, nodeMiddleBottom);
			obj.elementLeft 	= elementMiddle;

			% Replace the nodes of the cell
			obj.nodeTopLeft 	= nodeMiddleTop;
			obj.nodeBottomLeft 	= nodeMiddleBottom;

			% Old cell should be completely remodelled by this point, adjust the age back to zero

			obj.CellCycleModel.SetAge(0);

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
			x = [obj.nodeTopLeft.x, obj.nodeTopRight.x, obj.nodeBottomRight.x, obj.nodeBottomLeft.x];
			y = [obj.nodeTopLeft.y, obj.nodeTopRight.y, obj.nodeBottomRight.y, obj.nodeBottomLeft.y];

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

			h = figure();
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

			% One of the nodes in elementTop must be nodeTopLeft
			% pick the leftmost of the two. If the cell gets rotated, this will need to change
			% but for now it will do

			if obj.elementTop.Node1.x < obj.elementTop.Node2.x
				obj.nodeTopLeft = obj.elementTop.Node1;
				obj.nodeTopRight = obj.elementTop.Node2;
			else
				obj.nodeTopLeft = obj.elementTop.Node2;
				obj.nodeTopRight = obj.elementTop.Node1;
			end

			if obj.elementBottom.Node1.x < obj.elementBottom.Node2.x
				obj.nodeBottomLeft = obj.elementBottom.Node1;
				obj.nodeBottomRight = obj.elementBottom.Node2;
			else
				obj.nodeBottomLeft = obj.elementBottom.Node2;
				obj.nodeBottomRight = obj.elementBottom.Node1;
			end


		end

	end


end