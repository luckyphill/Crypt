classdef SquareCellJoined < AbstractCell
	% A square cell that is joined to its neighbours

	properties

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
		
	end

	methods
		
		function obj = SquareCellJoined(Cycle, elementList, id)
			% All the initialising
			% A square cell will always have 4 elements
			% elementList must have 4 elements in the order [elementTop, elementBottom, elementLeft, elementRight]

			% Since these are joined cells, one of the left or right
			% elements will be shared with another cell (assuming there is more
			% than one cell in the simulation). Hence, we need to carefully
			% assign the elements to acknowledge this.

			obj.elementTop 		= elementList(1);
			obj.elementBottom 	= elementList(2);
			obj.elementLeft 	= elementList(3);
			obj.elementRight 	= elementList(4);

			obj.MakeEverythingAntiClockwise();


			obj.CellCycleModel = Cycle;

			obj.age = Cycle.GetAge();

			
			obj.id = id;

			obj.ancestorId = id;

			cellDataArray = [CellAreaSquare(), CellPerimeter(), TargetPerimeterSquare(), TargetArea()];

			obj.AddCellDataArray(cellDataArray);

			obj.newCellTargetPerimeter = 3;
			obj.grownCellTargetPerimeter = 4;
			obj.currentCellTargetPerimeter = 4;

		end


		function cellLeft = GetAdjacentCellLeft(obj)
			
			cellLeft = [];
			if ~obj.freeCell
				cellLeft = obj.elementLeft.GetOtherCell(obj);
			end

		end

		function cellRight = GetAdjacentCellRight(obj)
			
			cellRight = [];
			if ~obj.freeCell
				cellRight = obj.elementRight.GetOtherCell(obj);
			end

		end

		function [newCell, newNodeList, newElementList] = Divide(obj)
			% Divide a cell in a simulation where cells are joined
			% in a monolayer
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

			% Important for Joined Cells
			newElementMiddle.internal = true;
			% Duplicate the cell cycle model from the old cell
			newCCM = obj.CellCycleModel.Duplicate();

			% Now we have all the parts we need to build the new cell in its correct position
			% The new cell will have the correct links with its constituent elements and nodes
			newCell = SquareCellJoined(newCCM, [newElementTop, newElementBottom, obj.elementLeft, newElementMiddle], -1);


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
			obj.age = 0;

			% Reset the node list
			obj.nodeList = [obj.nodeBottomLeft, obj.nodeBottomRight, obj.nodeTopRight, obj.nodeTopLeft];
			obj.elementList = [obj.elementBottom, obj.elementRight, obj.elementTop, obj.elementLeft];

			% Make a list of new nodes and elements
			newNodeList 	= [nodeMiddleTop, nodeMiddleBottom];
			newElementList	= [newElementMiddle, newElementTop, newElementBottom];

			% Update the sister cells
			newCell.sisterCell = obj;
			obj.sisterCell = newCell;
			% ...and ancestorId
			newCell.ancestorId = obj.id;
		
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

		function MakeEverythingAntiClockwise(obj)

			% A helper method to unclutter the constructor
			% Takes the nodes and elements and makes sure they are
			% all put in anticlockwise order. Has error checking when
			% the order of nodes in an element can't make it work

			
			% Starting from elementBottom, assemble elementList in anticlockwise order
			% Node1 from each element must match the order from AddNodesInOrder() 
			obj.elementList = [obj.elementBottom, obj.elementRight, obj.elementTop, obj.elementLeft];

			% First, need to make sure the nodes are in the correct elements

			% elementBottom and elementRight must share a node
			if ~ismember( obj.elementBottom.Node2, obj.elementRight.nodeList )
				% Maybe the nodes are not anticlockwise, so check they're not just
				% swapped
				if ~ismember( obj.elementBottom.Node1, obj.elementRight.nodeList )
					error('SCJ:MakeEverythingAntiClockwise:ElementsWrong','Bottom element doesnt share a node with Right element');
				else
					obj.elementBottom.SwapNodes();
				end

			end

			% elementRight and elementTop must share a node
			if ~ismember( obj.elementRight.Node2, obj.elementTop.nodeList )
				% Maybe the nodes are not anticlockwise, so check they're not just
				% swapped
				if ~ismember( obj.elementRight.Node1, obj.elementTop.nodeList)
					error('SCJ:MakeEverythingAntiClockwise:ElementsWrong','Right element doesnt share a node with Top element');
				else
					obj.elementRight.SwapNodes();
				end

			end

			% elementTop and elementLeft must share a node
			if ~ismember( obj.elementTop.Node2, obj.elementLeft.nodeList )
				% Maybe the nodes are not anticlockwise, so check they're not just
				% swapped
				if ~ismember( obj.elementTop.Node1, obj.elementLeft.nodeList )
					error('SCJ:MakeEverythingAntiClockwise:ElementsWrong','Top element doesnt share a node with Left element');
				else
					obj.elementTop.SwapNodes();
				end

			end

			% elementLeft and elementBottom must share a node
			if ~ismember( obj.elementLeft.Node2, obj.elementBottom.nodeList )
				% Maybe the nodes are not anticlockwise, so check they're not just
				% swapped
				if ~ismember( obj.elementLeft.Node1, obj.elementBottom.nodeList )
					error('SCJ:MakeEverythingAntiClockwise:ElementsWrong','Left element doesnt share a node with Bottom element');
				else
					obj.elementLeft.SwapNodes();
				end

			end

			% Elements are all good now, add them to the cell
			obj.elementTop.AddCell(obj);
			obj.elementBottom.AddCell(obj);
			obj.elementLeft.AddCell(obj);
			obj.elementRight.AddCell(obj);


			% If we get to this point, we know exactly where the nodes are
			obj.nodeBottomLeft 	= obj.elementBottom.Node1;
			obj.nodeBottomRight = obj.elementRight.Node1;
			obj.nodeTopRight 	= obj.elementTop.Node1;
			obj.nodeTopLeft 	= obj.elementLeft.Node1;

			obj.nodeList = [obj.nodeBottomLeft, obj.nodeBottomRight, obj.nodeTopRight, obj.nodeTopLeft];

			obj.nodeTopLeft.AddCell(obj);
			obj.nodeTopRight.AddCell(obj);
			obj.nodeBottomLeft.AddCell(obj);
			obj.nodeBottomRight.AddCell(obj);

			% Not sure if I still need this, but I'll leave it for now...
			obj.nodeTopLeft.isTopNode = true;
			obj.nodeTopRight.isTopNode = true;
			obj.nodeBottomLeft.isTopNode = false;
			obj.nodeBottomRight.isTopNode = false;

		end

	end


end