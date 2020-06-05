classdef CellFree < AbstractCell
	% A square cell that is joined to its neighbours

	properties

		% Division axis calculator maybe
	end

	methods
		
		function obj = CellFree(Cycle, nodeList, id)
			% All the initialising
			% This cell takes a list of nodes and uses them to
			% build the cell. The nodes must be in anticlockwise
			% order around the perimeter of the cell, otherwise bad
			% stuff will happen

			obj.nodeList = nodeList;

			k = length(nodeList)

			for i = 1:k-1

				e = Element(nodeList(i),nodeList(i+1), -1);
				obj.elementList(end + 1) = e;

			end

			obj.CellCycleModel = Cycle;

			obj.id = id;

			obj.ancestorId = id;

			obj.AddCellData(CellArea());
			obj.AddCellData(CellPerimeter());
			obj.AddCellData(TargetPerimeterSquare());
			obj.AddCellData(TargetArea());

		end


		function [newCell, newNodeList, newElementList] = Divide(obj)
			% Divide cell when simulation is made of free cells
			% that are not constrained to be adjacent to others
			% To divide, split the cell in half along a specified axis
			% and add in sufficient nodes and elements to maintain
			% a constant number of nodes and elements

			% This process needs to be done carefully to update all the new
			% links between node, element and cell

			%  o---------o
			%  |         |
			%  |         |
			%  |     1   |
			%  |         |
			%  |         |
			%  o---------o

			% With an even number of elements becomes

			%  x  o------o
			%  |\  \     |
			%  | \  \    |
			%  |  x  x 1 |
			%  | 2 \  \  |
			%  |    \  \ |
			%  o-----x   o

			% With an odd number of elements, it's harder to draw, but need to
			% choose an element to split or give uneven spread of new elements

			% Find the split points

			% Give -ve ids because id is a feature of the simulation
			% and can't be assigned here. This is handled in AbstractCellSimulation

			% Make the new nodes
			newNode		= Node
			
			% Make the new elements,
			newElement 	= Element

			% Duplicate the cell cycle model from the old cell
			newCCM = obj.CellCycleModel.Duplicate();

			% Now we have all the parts we need to build the new cell in its correct position
			% The new cell will have the correct links with its constituent elements and nodes
			newCell = CellFree(newCCM, [newElementTop, newElementBottom, obj.elementLeft, newElementMiddle], -1);


			% Remodel split elements
			element .ReplaceNode(obj.nodeTopLeft, nodeMiddleTop);

			% Adjust links between nodes and elements
			node .RemoveCell(obj);

			new node .AddCell(obj);

			obj.AddNodes

			% Adjust links between cell and elements

			element .RemoveCell(obj);
			obj.AddElements ;

			newElementMiddle.AddCell(obj);
						

			% Old cell should be completely remodelled by this point, adjust the age back to zero

			obj.CellCycleModel.SetAge(0);

			% Reset the node list
			obj.nodeList = 
			obj.elementList = 

			% Make a list of new nodes and elements
			newNodeList 	= 
			newElementList	= 

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

		function next = GetNextNode(obj, n, direction)

			% Use the elements to find the next node around
			% the perimeter in direction 
			% direction = 1 anticlockwise
			% direction = -1 clockwise

			% Probably more bloated than necessary, but this way adds in error catching
			switch direction
				case 1
					% Heading anticlockwise
					switch n
						case n.elementList(1).Node1
							next = n.elementList(1).Node2;
						case n.elementList(1).Node2
							next = n.elementList(2).Node2;
						otherwise
							error('SCF:GetNextNode','Error with node-element linking');
					end
					
				case -1
					switch n
						case n.elementList(1).Node2
							next = n.elementList(1).Node1;
						case n.elementList(1).Node1
							next = n.elementList(2).Node1;
						otherwise
							error('SCF:GetNextNode','Error with node-element linking');
					end

				otherwise
					error('SCF:GetNextNode','Dirction must be 1, anticlockwise, or -1, clockwise');
			end

		end

		function flipped = HasEdgeFlipped(obj)

			% Need to consider if this is important for this cell


			flipped = false;
			% % An edge will only flip on the top or bottom
			% % When that happens, the left and right edges will cross
			% % The following algorithm decides if the edges cross

			% X1 = obj.elementLeft.Node1.x;
			% X2 = obj.elementLeft.Node2.x;

			% Y1 = obj.elementLeft.Node1.y;
			% Y2 = obj.elementLeft.Node2.y;

			% X3 = obj.elementRight.Node1.x;
			% X4 = obj.elementRight.Node2.x;

			% Y3 = obj.elementRight.Node1.y;
			% Y4 = obj.elementRight.Node2.y;

			% % Basic run-down of algorithm:
			% % The lines are parameterised so that
			% % elementLeft  = (x1(t), y1(t)) = (A1t + a1, B1t + b1)
			% % elementRight = (x2(s), y2(s)) = (A2s + a2, B2s + b2)
			% % where 0 <= t,s <=1
			% % If the lines cross, then there is a unique value of t,s such that
			% % x1(t) == x2(s) and y1(t) == y2(s)
			% % There will always be a value of t and s that satisfies these
			% % conditions (except for when the lines are parallel), so to make
			% % sure the actual segments cross, we MUST have 0 <= t,s <=1

			% % Solving this, we have
			% % t = ( B2(a1 - a2) - A2(b1 - b2) ) / (A2B1 - A1B2)
			% % s = ( B1(a1 - a2) - A1(b1 - b2) ) / (A2B1 - A1B2)
			% % Where 
			% % A1 = X2 - X1, a1 = X1
			% % B1 = Y2 - Y1, b1 = Y1
			% % A2 = X4 - X3, a2 = X3
			% % B2 = Y4 - Y3, b2 = Y3

			% denom = (X4 - X3)*(Y2 - Y1) - (X2 - X1)*(Y4 - Y3);

			% % denom == 0 means parallel

			% if denom ~= 0
			% 	% if the numerator for either t or s expression is larger than the
			% 	% |denominator|, then |t| or |s| will be greater than 1, i.e. out of their range
			% 	% so both must be less than
			% 	tNum = (Y4 - Y3)*(X1 - X3) - (X4 - X3)*(Y1 - Y3);
			% 	sNum = (Y2 - Y1)*(X1 - X3) - (X2 - X1)*(Y1 - Y3);
				
			% 	if abs(tNum) <= abs(denom) && abs(sNum) <= abs(denom)
			% 		% magnitudes are correct, now check the signs
			% 		if sign(tNum) == sign(denom) && sign(sNum) == sign(denom)
			% 			% If the signs of the numerator and denominators are the same
			% 			% Then s and t satisfy their range restrictions, hence the elements cross
			% 			flipped = true;
			% 		end
			% 	end
			% end

		end

	end

end