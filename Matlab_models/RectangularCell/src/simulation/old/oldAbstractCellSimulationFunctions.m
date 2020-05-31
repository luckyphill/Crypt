
% Old functions from AbstractCellSimulation that I don't want to throw away entirely

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
	etaD = eta1 + eta2 + etaA;
	rD = (eta1 * r1 + eta2 * r2 + etaA * rA) / etaD;

	% We then need the vector from the centre of drag to
	% both nodes (note, these are relative the fixed system of
	% coordinates, not the body system of coordinates)
	rDto1 = r1 - rD;
	rDto2 = r2 - rD;
	rDtoA = rA - rD;

	% These give us the moment of drag about the centre of drag
	ID = eta1 * norm(rDto1)^2 + eta2 * norm(rDto2)^2 + etaA * norm(rDtoA)^2;

	% The moment created by the node is then force times
	% perpendicular distance.  We must use the body system of
	% coordinates in order to get the correct direction.
	% (We could probably get away without the transform, 
	% since we only need the length, but wed have to be
	% careful about choosing the sign correctly)
	
	

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



%--------------------------------------------------------------------
% Testing
%--------------------------------------------------------------------




function TestProcessCollision(testCase)

			% This tests that the elements and nodes move properly
			% after a collision is detected and processed

			% Need a concrete class instance to access the method
			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.01;
			t.eta = 1;

			n = Node(0.1,0.6,1);

			n1 = Node(0,0,2);
			n2 = Node(0,1,3);
			e = Element(n1,n2,1);

			% Just loop through a few iterations until we get a collision
			% this is easier than manually determining the previous positions
			% and forces
			for i = 1:5
				n.AddForceContribution([-1.3,0]);
				n1.AddForceContribution([1,0]);
				n2.AddForceContribution([1,0]);

				n.UpdatePosition(t.dt/t.eta);
				n1.UpdatePosition(t.dt/t.eta);
				n2.UpdatePosition(t.dt/t.eta);
			end

			t.MoveNodeAndElement(n, e);

			testCase.verifyEqual(n.position, [0.043478260869565, 0.6], 'RelTol', 1e-8);
			testCase.verifyEqual(n1.position, [0.043478260869565, 0], 'RelTol', 1e-8);
			testCase.verifyEqual(n2.position, [0.043478260869565, 1], 'RelTol', 1e-8);


		end

		function TestProcessCollisionFromTestState1(testCase)
			% In development of collision processing, the simulation saved in
			% testState.mat failed to calculate the collision point properly
			% so that will be used as a test. All values are taken directly
			% from this simulation at the point of collision

			% This is the first point to fail. It was due to an error
			% in writing out the equations to find the intersection.
			% That means this ends up being a practical test for a standard
			% collision - a bit better than the one conjured up above


			t = CellGrowing(1,20,10,10,10,1,10);

			n = Node(2.679089843793793, 1.111279426020461, 1);
			n.previousPosition = [2.678993071095805,   1.111322535559900];
			n.previousForce = [0.019356072843268,  -0.008623370542502];

			n1 = Node(2.678125774934509, 1.099393998875818, 2);
			n1.previousPosition = [2.678224841525261,   1.099196272975437];
			n1.previousForce = [-0.019815031993694,   0.039549258131540];

			n2 = Node(2.737339808220937,   1.977995499569748, 3);
			n2.previousPosition = [2.737408966487447,   1.977577366126344];
			n2.previousForce = [-0.013839246351063,   0.083630457153625];

			e = Element(n1,n2,1);
			% figure
			% hold on

			% plot(n.x, n.y, 'ko');
			% plot(e.Node1.x, e.Node1.y, 'bo');
			% plot(e.Node2.x, e.Node2.y, 'bo');

			% plot([e.nodeList.x], [e.nodeList.y], 'k--');

			% plot(n.previousPosition(1), n.previousPosition(2), 'go');
			% plot(e.Node1.previousPosition(1), e.Node1.previousPosition(2), 'ro');
			% plot(e.Node2.previousPosition(1), e.Node2.previousPosition(2), 'ro');

			% plot([e.Node1.previousPosition(1),e.Node2.previousPosition(1)], [e.Node1.previousPosition(2),e.Node2.previousPosition(2)], 'r--');

			% No verifications have been explicitly written, but there are error trigger points
			% in the following function, so if all is not well, then we can catch the failure
			t.MoveNodeAndElement(n, e);

		end

		function TestProcessCollisionFromTestState2(testCase)
			% In development of collision processing, the simulation saved in
			% testState.mat failed to calculate the collision point properly
			% so that will be used as a test. All values are taken directly
			% from this simulation at the point of collision

			% This is the second time failure has occurred.
			% This failure is apparently due to subtraction of
			% almost equal numbers resulting in a number that
			% is highly susceptible to round-off/binary-to-decimal approximation errors

			% To remedy this, when numbers are very close to 0
			% we will simply set them to zero

			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.01;
			t.eta = 1;

			n = Node(4.289163775967404,  -0.430126629734065, 1);
			n.previousPosition = [4.288768222511362  -0.429082966112824];
			n.previousForce = [0.079097065192904  -0.208715046158330];

			n1 = Node(4.342369240828197,   0.237019662505578, 2);
			n1.previousPosition = [4.342609917545624   0.236289903275623];
			n1.previousForce = [-0.048124097742078   0.145941373102790];

			n2 = Node(4.279943205181989,  -0.527406852252034, 3);
			n2.previousPosition = [4.280809107292654  -0.527441298395918];
			n2.previousForce = [-0.173173181470151   0.006873482832686];

			e = Element(n1,n2,1);
			% figure
			% hold on

			% plot(n.x, n.y, 'ko');
			% plot(e.Node1.x, e.Node1.y, 'ko');
			% plot(e.Node2.x, e.Node2.y, 'ko');

			% plot([e.nodeList.x], [e.nodeList.y], 'k');

			% plot(n.previousPosition(1), n.previousPosition(2), 'r*');
			% plot(e.Node1.previousPosition(1), e.Node1.previousPosition(2), 'r*');
			% plot(e.Node2.previousPosition(1), e.Node2.previousPosition(2), 'r*');

			% plot([e.Node1.previousPosition(1),e.Node2.previousPosition(1)], [e.Node1.previousPosition(2),e.Node2.previousPosition(2)], 'r--');

			t.MoveNodeAndElement(n, e);

		end


		function TestProcessCollisionFromTestState3(testCase)
			% In development of collision processing, the simulation saved in
			% testState.mat failed to calculate the collision point properly
			% so that will be used as a test. All values are taken directly
			% from this simulation at the point of collision

			% This is the third failure. This time I believe it is due to
			% two collisions occurring involving the same edges
			% Briefly, the initial algorithm made no attempt to work out which
			% collision occurred first and handle the double collision properly
			% This resulted in on collision being resolved correctly by the node
			% ending up on the edge, while the second collision was resolved
			% based on an earlier, no longer relevant, set of positions
			% This left the second collision resolving to a position where the
			% node did not attached to the edge.

			% Concrete class to access the methods
			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.005;
			t.eta = 1;

			% Nodes involved

			nc1 = Node(7.516323235982217,  -0.510562827716617, 1);
			nc1.previousPosition = [7.515395256320858  -0.511046011542917];
			nc1.previousForce = [0.190044400221934   0.098953009736972];
			nc1.AdjustPosition(nc1.previousPosition + t.dt * nc1.previousForce/t.eta);

			nc2 = Node(7.522497481658915,  -0.663125885289055, 2);
			nc2.previousPosition = [7.523905969216058  -0.663230458083442];
			nc2.previousForce = [-0.288449396213211   0.021415850816997];
			nc2.AdjustPosition( nc2.previousPosition + t.dt * nc2.previousForce/t.eta );

			e1n1 = Node(7.477964004765953,   0.158281502068270, 3);
			e1n1.previousPosition = [7.477964004765953   0.158281502068270];
			e1n1.previousForce = [-0.088564005942511   0.028871917552375];
			e1n1.AdjustPosition(e1n1.previousPosition + t.dt * e1n1.previousForce/t.eta);

			e1n2 = nc2;

			e2n1 = Node(7.540171238449982,  -1.099837107359943, 4);
			e2n1.previousPosition = [7.539854029048046  -1.099702316192680];
			e2n1.previousForce = [0.064962491147076  -0.027604383592040];
			e2n1.AdjustPosition(e2n1.previousPosition + t.dt * e2n1.previousForce/t.eta);

			e2n2 = nc1;


			% Elements involved
			e1 = Element(e1n1,e1n2,1);
			e2 = Element(e2n1,e2n2,2);

			% t.MoveNodeAndElement(nc2, e2);
			% t.MoveNodeAndElement(nc1, e1);
			
			

			% Node and element for second collision
			% figure
			% hold on

			% plot(nc1.x, nc1.y, 'ko');
			% plot(e1.Node1.x, e1.Node1.y, 'ko');
			% plot(e1.Node2.x, e1.Node2.y, 'ko');

			% plot([e1.nodeList.x], [e1.nodeList.y], 'k');

			% plot(nc1.previousPosition(1), nc1.previousPosition(2), 'r*');
			% plot(e1.Node1.previousPosition(1), e1.Node1.previousPosition(2), 'r*');
			% plot(e1.Node2.previousPosition(1), e1.Node2.previousPosition(2), 'r*');

			% plot([e1.Node1.previousPosition(1),e1.Node2.previousPosition(1)], [e1.Node1.previousPosition(2),e1.Node2.previousPosition(2)], 'r--');

			% plot(nc2.x, nc2.y, 'bo');
			% plot(e2.Node1.x, e2.Node1.y, 'bo');
			% plot(e2.Node2.x, e2.Node2.y, 'bo');

			% plot([e2.nodeList.x], [e2.nodeList.y], 'b');

			% plot(nc2.previousPosition(1), nc2.previousPosition(2), 'c*');
			% plot(e2.Node1.previousPosition(1), e2.Node1.previousPosition(2), 'c*');
			% plot(e2.Node2.previousPosition(1), e2.Node2.previousPosition(2), 'c*');

			% plot([e2.Node1.previousPosition(1),e2.Node2.previousPosition(1)], [e2.Node1.previousPosition(2),e2.Node2.previousPosition(2)], 'c--');




		end

		function TestMoveNodeElementPair(testCase)

			% Tests that a node element pair that are in contact
			% move as expected

			% Need a concrete class instance to access the method
			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.01;
			t.eta = 1;

			n = Node(0,0.75,1);

			n1 = Node(0,0,2);
			n2 = Node(0,1,3);
			e = Element(n1,n2,1);
			e.GetLength()

			n.AddForceContribution([-100,0]);

			% n1.AddForceContribution([0.5,0]);
			% n2.AddForceContribution([0.5,0]);

			t.TransmitForcesPair(n,e);

			e.GetLength()

			% figure
			% hold on

			% plot(n.x, n.y, 'ko');
			% plot(e.Node1.x, e.Node1.y, 'ko');
			% plot(e.Node2.x, e.Node2.y, 'ko');

			% plot([e.nodeList.x], [e.nodeList.y], 'k');

			% plot(n.previousPosition(1), n.previousPosition(2), 'r*');
			% plot(e.Node1.previousPosition(1), e.Node1.previousPosition(2), 'r*');
			% plot(e.Node2.previousPosition(1), e.Node2.previousPosition(2), 'r*');

			% plot([e.Node1.previousPosition(1),e.Node2.previousPosition(1)], [e.Node1.previousPosition(2),e.Node2.previousPosition(2)], 'r--');



		end