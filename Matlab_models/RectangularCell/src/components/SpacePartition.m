classdef SpacePartition < matlab.mixin.SetGet
	% This class holds a space partition for all the nodes
	% in a simulation. It distributes each node into a box
	% based on its spatial position. This will help to minimise
	% the space searching effort needed to find collisions
	% and resolve them

	% The partition is regular, so that the width and height of each
	% box is the same, called dx and dy. A node can instantly work
	% out which box it is in by taking the integer part of x/dx and y/dy.
	% However, we also need a place to store all the nodes that are
	% in the same box, so they can be compared for interactions.

	% There are two main operations to perform here. The first is
	% move nodes between boxes, and the second is to query neighbours.
	% Depending on where the node is precisely found, the neighbours
	% will either be found in the same box, or an adjacent box
	% and nowhere else.

	% This will also need to store which boxes an element passes
	% through, in order to work out the node-edge interactions.
	% Setting and moving the edge boxes will take a bit more work.

	% We use matlab arrays to store the box contents, and we use a
	% bit of trickery to allow -ve indices

	% All of the box handling process will be done in the cell simulation
	% this just implements the processes the simulation will call

	properties

		% Each quadrant is part of the cartesian plane
		% 1: (+,+)
		% 2: (+,-)
		% 3: (-,-)
		% 4: (-,+)

		% nodesQ and elementsQ are cell vectors 
		% containing the 4 quadrants
		% The index matches to the quadrant number
		% Each quadrant is a cell matrix that matches
		% the actual box location.
		% Each box is a cell vector of nodes or elements
		% So, all in all they are cell vectors of cell arrays
		% of vectors
		nodesQ = {{},{},{},{}}
		elementsQ = {{},{},{},{}}

		% The size of the cell arrays is dynamic, so will be
		% regularly reallocated as the simulation progresses
		% This could cause issues as the simulation gets large
		% but I'm not aware of a manual way to deal with growing
		% arrays in matlab properly, but preallocating will help

		% These are the lengths of the box edges
		dx
		dy

		% A pointer to the simulation
		simulation


	end


	methods
		
		function obj = SpacePartition(dx, dy, s)
			% Need to pass in a cell simulation to initialise
			obj.dx = dx;
			obj.dy = dy;
			obj.simulation = s;

			for i = 1:length(s.nodeList)
				obj.PutNodeInBox(s.nodeList(i));
			end

			for i=1:length(s.elementList)
				% If the element is an internal element, skip it
				% because they don't interact with nodes
				
				e = s.elementList(i);
				if ~e.IsElementInternal()
					obj.PutElementInBoxes(e);
				end
			end

		end

		function neighbours = GetNeighbouringElements(obj, n, r)

			% The pinacle of this piece of code
			% A function that (hopefully) efficiently finds
			% the set of elements that are within a distance r
			% of the node n

			% There are two stages
			% 1. Get the candidate elements. This includes
			% grabbing elements from adjacent boxes if the
			% node is close to a box boundary
			% 2. Calculate the distances to each candidate
			% element. This involves making sure the node
			% is within the range of the element

			% The elements are assembled into a vector

			% First off, get the elements in the same box


			b = obj.AssembleCandidateElements(n, r);

			neighbours = Element.empty();

			for i = 1:length(b)

				e = b(i);

				u = e.GetVector1to2();
				v = [u(2), -u(1)];

				% Make box around element
				% determine if node is in that box

				n1 = e.Node1;
				n2 = e.Node2;

				p1 = n1.position + v * r;
				p2 = n1.position - v * r;
				p3 = n2.position - v * r;
				p4 = n2.position + v * r;

				x = [p1(1), p2(1), p3(1), p4(1)];
				y = [p1(2), p2(2), p3(2), p4(2)];

				[inside, on] = inpolygon(n.x, n.y, x ,y);

				if inside && on
					inside = false;
				end

				if inside
					neighbours(end+1) = e;
				end

			end
			
		end

		function neighbours = GetNeighbouringNodes(obj, n1, r)

			% Given the node n and the radius r find all the nodes
			% that are neighbours

			b = obj.AssembleCandidateNodes(n1, r);

			neighbours = Node.empty();

			for i = 1:length(b)

				n2 = b(i);

				n1ton2 = n2.position - n1.position;

				d = norm(n1ton2);

				if d < r
					neighbours(end + 1) = n2;
				end

			end

		end

		function [neighboursE, neighboursN] = GetNeighbouringNodesAndElements(obj, n, r)

			% Finds the neighbouring nodes and elements at the same
			% time, taking account of obtuse angled element pairs
			% necessitating node-node interactions


			b = obj.AssembleCandidateElements(n, r);

			neighboursN = Node.empty();
			neighboursE = Element.empty();

			for i = 1:length(b)

				e = b(i);

				u = e.GetVector1to2();
				v = [u(2), -u(1)];

				% Make box around element
				% determine if node is in that box

				n1 = e.Node1;
				n2 = e.Node2;

				p1 = n1.position + v * r;
				p2 = n1.position - v * r;
				p3 = n2.position - v * r;
				p4 = n2.position + v * r;

				x = [p1(1), p2(1), p3(1), p4(1)];
				y = [p1(2), p2(2), p3(2), p4(2)];

				[inside, on] = inpolygon(n.x, n.y, x ,y);

				if inside && on
					inside = false;
				end

				if inside
					neighboursE(end+1) = e;

					% If the node is determined to interact with an element
					% we need to make sure we remove any instances of it interacting
					% with any of the elements end nodes.

					neighboursN(neighboursN == e.Node1) = [];
					neighboursN(neighboursN == e.Node2) = [];
				else
					% If the node is not inside the element interaction box
					% then it might be in the node interaction wedge
					% Need to determine if which (if any) of the elements
					% nodes are in proximity to the node in question

					n1 = e.Node1;
					n2 = e.Node2;

					nton1 = n1.position - n.position;
					nton2 = n2.position - n.position;

					d1 = norm(nton1);
					d2 = norm(nton2);

					if d1 < r
						neighboursN(end + 1) = n1;
					end

					if d2 < r
						neighboursN(end + 1) = n2;
					end

				end

			end

			neighboursN = obj.QuickUniqueEmpty(neighboursN);
			
		end

		function b = AssembleCandidateElements(obj, n, r)

			b = obj.GetElementBoxFromNode(n);

			% Then check if the node is near a boundary

			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);

			% Need to decide if the process of check is more effort than
			% just taking the adjacent boxes always, even when the node is
			% in the middle of its box

			% A vector that matches q to the sign of x or y
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];


			% Check sides
			if abs(n.x - sx(q) * i * obj.dx) - r < 0
				% Close to left
				b = [b, obj.GetAdjacentElementBoxFromNode(n, [-1, 0])];
			end

			if abs(n.x - sx(q) * i * obj.dx) + r > obj.dx
				% Close to right
				b = [b, obj.GetAdjacentElementBoxFromNode(n, [1, 0])];
			end

			if abs(n.y - sy(q) * j * obj.dy) - r < 0
				% Close to bottom
				b = [b, obj.GetAdjacentElementBoxFromNode(n, [0, -1])];
			end

			if abs(n.y - sy(q) * j * obj.dy) + r > obj.dy
				% Close to top
				b = [b, obj.GetAdjacentElementBoxFromNode(n, [0, 1])];
			end

			% Checking diagonally not needed for elements when box side length
			% is about the same size as the maximum element length
			% If the box size is much smaller than the max element length
			% then it is most likely easier to not check at all, and just
			% add the adjacent boxes


			% Remove duplicates
			% b = unique(b);
			b = obj.QuickUnique(b);

			% Remove nodes own elements
			% Lidx = ismember(b,n.elementList);
			% b(Lidx) = [];
			for i = 1:length(n.elementList)
				b(b==n.elementList(i)) = [];
			end

		end

		function b = QuickUnique(obj, b)
			% Test to see if I can do the unique check quicker without
			% needing all the bells and whistles - it can by a factor of 2

			% Is there a more efficient way when the most repetitions is 3?

			b = sort(b);

			% If there are repeated elements, they will be adjacent after sorting
			Lidx = b(1:end-1) ~= b(2:end);
			Lidx = [Lidx, true];
			b = b(Lidx);

		end

		function b = QuickUniqueEmpty(obj, b)
			
			% Same a QuickUnique, but handles empty vectors
			if ~isempty(b)
				b = QuickUnique(obj, b);
			end

		end

		function b = AssembleCandidateNodes(obj, n, r)

			b = obj.GetNodeBoxFromNode(n);

			% Then check if the node is near a boundary

			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);

			% Check sides
			if abs(n.x - i * obj.dx) - r < 0
				% Close to left
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [-1, 0])];
			end

			if abs(n.x - i * obj.dx) + r > obj.dx
				% Close to right
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [1, 0])];
			end

			if abs(n.y - j * obj.dy) - r < 0
				% Close to bottom
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [0, -1])];
			end

			if abs(n.y - j * obj.dy) + r > obj.dy
				% Close to top
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [0, 1])];
			end

			% Check corners

			if ( abs(n.x - i * obj.dx) - r < 0 ) && ( abs(n.y - j * obj.dy) - r < 0)
				% Close to left bottom
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [-1, -1])];
			end

			if ( abs(n.x - i * obj.dx) + r ) > obj.dx && ( abs(n.y - j * obj.dy) - r < 0)
				% Close to right bottom
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [1, -1])];
			end

			if ( abs(n.x - i * obj.dx) - r < 0 ) && ( abs(n.y - j * obj.dy) + r > obj.dy)
				% Close to left top
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [-1, 1])];
			end

			if ( abs(n.x - i * obj.dx) + r > obj.dx ) && ( abs(n.y - j * obj.dy) + r > obj.dy) 
				% Close to right top
				b = [b, obj.GetAdjacentNodeBoxFromNode(n, [1, 1])];
			end

			b(b==n) = [];

		end

		function PutNodeInBox(obj, n)

			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);

			obj.InsertNode(q,i,j,n);

		end

		function b = GetNodeBoxFromNode(obj, n)
			% Returns the same box that n is in
			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);

			try
				b = obj.nodesQ{q}{i,j};
			catch
				error('SP:GetNodeBoxFromNode:Missing','Node doesnt exist where expected in the partition');
			end
		
		end

		function b = GetElementBoxFromNode(obj, n)
			% Returns the same box that n is in
			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);

			try
				b = obj.elementsQ{q}{i,j};
			catch
				error('SP:GetElementBoxFromNode:Missing','Elements dont exist where expected in the partition');
			end
		
		end

		function b = GetAdjacentNodeBoxFromNode(obj, n, dir)

			% Returns the node box adjacent to the one indicated
			% specifying the direction

			% dir = [a, b]
			% where a,b = 1 or -1
			% 1 indicates an increase in the global index etc.
			% a is applied to I and b applied to J

			b = [];
			a = dir(1);
			c = dir(2);
			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);
			[I, J] = obj.ConvertToGlobal(q,i,j);

			I = I + a;
			J = J + c;

			% This is needed because matlab doesn't index from 0!!!!!!!!!!!!!!!!!

			if I == 0; I = a; end
			if J == 0; J = c; end

			[q,i,j] = obj.ConvertToQuadrant(I,J);


			try
				b = obj.nodesQ{q}{i,j};
			catch ME
				if ~strcmp(ME.identifier,'MATLAB:badsubscript')
					error('SP:GetAdjacentNodeBox','Assignment didnt fail properly');
				end
			end

		end

		function b = GetAdjacentElementBoxFromNode(obj, n, dir)

			% Returns the node box adjacent to the one indicated
			% specifying the direction

			% dir = [a, b]
			% where a,b = 1 or -1
			% 1 indicates an increase in the global index etc.
			% a is applied to I and b applied to J
			a = dir(1);
			c = dir(2);
			b = [];
			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);
			[I, J] = obj.ConvertToGlobal(q,i,j);

			I = I + a;
			J = J + c;

			% This is needed because matlab doesn't index from 0!!!!!!!!!!!!!!!!!

			if I == 0; I = a; end
			if J == 0; J = c; end

			[q,i,j] = obj.ConvertToQuadrant(I,J);


			
			try
				b = obj.elementsQ{q}{i,j};
			catch ME
				if ~strcmp(ME.identifier,'MATLAB:badsubscript')
					error('SP:GetAdjacentElementBox','Assignment didnt fail properly');
				end
			end

		end

		function PutElementsInBoxesUsingNode(obj, n1)

			% Given the list of elements that a given node
			% is part of, distribute the elements to the element
			% boxes. This will require putting elements in 
			% intermediate boxes too

			for i=1:length(n1.elementList)
				% If the element is an internal element, skip it
				% because they don't interact with nodes
				
				e = n1.elementList(i);
				if ~e.IsElementInternal()

					n2 = e.GetOtherNode(n1);

					[Q,I,J] = GetBoxIndicesBetweenNodes(obj, n1, n2);

					for j = 1:length(Q)

						obj.InsertElement(Q(j),I(j),J(j),e);

					end

				end

			end

		end

		function PutElementInBoxes(obj, e)

			% Given the list of elements that a given node
			% is part of, distribute the elements to the element
			% boxes. This will require putting elements in 
			% intermediate boxes too

			n1 = e.Node1;
			n2 = e.Node2;

			[Q,I,J] = GetBoxIndicesBetweenNodes(obj, n1, n2);

			for j = 1:length(Q)

				obj.InsertElement(Q(j),I(j),J(j),e);
				
			end

		end

		function [ql,il,jl] = GetBoxIndicesBetweenNodes(obj, n1, n2)

			% Given two nodes, we want all the indices between them
			% If the nodes are in the same quadrant, this is simple,
			% but if they span quadrants, we need to be careful

			% ql,il,jl are vectors (lists) of all the possible box indices where
			% the element could pass through

			[q1,i1,j1] = obj.GetQuadrantAndIndices(n1.x,n1.y);
			[q2,i2,j2] = obj.GetQuadrantAndIndices(n2.x,n2.y);

			[ql,il,jl] = obj.MakeElementBoxList(q1,i1,j1,q2,i2,j2);

		end

		function [qp,ip,jp] = GetBoxIndicesBetweenNodesPrevious(obj, n1, n2)

			% Given two nodes, we want all the indices between them
			% in order to determine which boxes an element needs to go in

			% This function gets the box indices between nodes in the previous time step2

			% qp,ip,jp are vectors (lists) of all the possible box indices where
			% the element could pass through
			if isempty(n1.previousPosition) || isempty(n2.previousPosition)
				error('SP:GetBoxIndicesBetweenNodesPrevious:NoPrevious', 'There has not been a previous position');
			end


			[q1,i1,j1] = obj.GetQuadrantAndIndices(n1.previousPosition(1),n1.previousPosition(2));
			[q2,i2,j2] = obj.GetQuadrantAndIndices(n2.previousPosition(1),n2.previousPosition(2));

			[qp,ip,jp] = obj.MakeElementBoxList(q1,i1,j1,q2,i2,j2);

		end

		function [qp,ip,jp] = GetBoxIndicesBetweenNodesPreviousCurrent(obj, n1, n2)

			% Given two nodes, we want all the indices between them
			% in order to determine which boxes an element needs to go in

			% This function finds the previous boxes for the node that has just moved
			% and the current indices for its associated element paired node

			% qp,ip,jp are vectors (lists) of all the possible box indices where
			% the element could pass through
			if isempty(n1.previousPosition) || isempty(n2.previousPosition)
				error('SP:GetBoxIndicesBetweenNodesPrevious:NoPrevious', 'There has not been a previous position');
			end


			[q1,i1,j1] = obj.GetQuadrantAndIndices(n1.previousPosition(1),n1.previousPosition(2));
			[q2,i2,j2] = obj.GetQuadrantAndIndices(n2.x,n2.y);

			[qp,ip,jp] = obj.MakeElementBoxList(q1,i1,j1,q2,i2,j2);

		end

		function [ql,il,jl] = MakeElementBoxList(obj,q1,i1,j1,q2,i2,j2)

			% This method for finding the boxes that we should put the
			% elements in is not exact.
			% An exact method will get exactly the right boxes and no more
			% but as a consequence, will need to be checked at every time
			% step, which can slow things down. An exact method might be better
			% when the box size is quite small in relation to the max
			% element length.
			% An exact method transverses the vector beteen the ttwo nodes
			% and calculates the position where it crosses the box
			% boundaries. It uses this to know which box to add the element to

			% A non exact method will look at all the possible boxes the element 
			% could pass through, given that we only know which boxes its end
			% points are in. This will only need to be updated when
			% a node moves to a new box.

			% The non exact method used here is probably the greediest method
			% and the least efficient in a small box case, but is quick, and
			% arrives at the same answer when the boxes are the large, hence
			% it is kept for now.

			% To find the boxes that the element could pass through
			% it is much simpler to convert to global indices, then
			% back to quadrants
			[I1, J1] = obj.ConvertToGlobal(q1,i1,j1);
			[I2, J2] = obj.ConvertToGlobal(q2,i2,j2);


			if I1<I2; Il = I1:I2; else; Il = I2:I1; end
			if J1<J2; Jl = J1:J2; else; Jl = J2:J1; end

			% Once again, I need to hack a solution because matlab
			% decided to index from 1..........
			Il(Il==0) = [];
			Jl(Jl==0) = [];

			% This method will always produce a rectangular grid
			% of boxes which may be many times more than is needed
			% when the box size is small compared to the element length
			% This is an area for optimisation
			% In reality though, the box size probably won't be that small
			% so it should be ok
			[p,q] = meshgrid(Il, Jl);
			Il = p(:);
			Jl = q(:);

			[ql,il,jl] = obj.ConvertToQuadrant(Il,Jl);

		end

		function [ql,il,jl] = MakeExactElementBoxList(obj,q1,i1,j1,q2,i2,j2)

			% DOESN'T WORK YET - There may be a fundamental flaw to do with
			% the indexing

			% This method for finding the boxes uses the exact algorithm
			% to find the full range of boxes that an element could feasibly
			% be found in. It avoids the overshoot of the rectangle method

			% To find the boxes that the element could pass through
			% it is much simpler to convert to global indices, then
			% back to quadrants
			[I1, J1] = obj.ConvertToGlobal(q1,i1,j1);
			[I2, J2] = obj.ConvertToGlobal(q2,i2,j2);

			if I1<I2; Is = I1; Ie = I2; else; Is = I2; Ie = I1; end
			if J1<J2; Js = J1; Je = J2; else; Js = J2; Je = J1; end

			% To get the exact boxes, get the vector from top corner to top corner
			% If the upper box is to the right, take top left to top left
			% and vice versa if the upper box is to the left

			%      _    _
			%    /|_|  |_|\
			%   /          \
			%  /            \
			% /              \
			%|_|            |_|
			% 

			if Js < Je
				% Upper box is right

				pl = [Is, (Js+1)];
				pr = [Ie, (Je+1)];

				% v = (pr - pl)s + pl
				% For each vertical boundary that it crosses we need to solve
				% vx = i
				% Then use s to find the matching j
				% Then vice versa for the horizontal boundaries

				iI = Is:Ie;
				jJ = Js:Je;

				% Remove the 0 indices because matlab
				iI(iI==0) = [];
				jJ(jJ==0) = [];

				sx = ( iI - pl(1) )./(pr(1) - pl(1))
				sy = ( jJ - pl(2) )./(pr(2) - pl(2))

				jI = round((pr(2) - pl(2)) * sx - pl(2))
				iJ = round((pr(1) - pl(1)) * sy - pl(1))


				Il = [iI';iJ']
				Jl = [jI';jJ']

				% Since this is for the upper line, we need to duplicate it
				% for the lower line. This can be done by adding 1 to I and -1 to J

				Il = [Il; Il+1];
				Jl = [Jl; Jl-1];

				% And once again, because matlab indexes from 1...
				Il(Il==0) = 1;
				Jl(Jl==0) = -1;


			else
				% Upper box is left or directly above

			end

			[ql,il,jl] = obj.ConvertToQuadrant(Il,Jl);

		end

		function UpdateBoxForNode(obj, n)

			if isempty(n.previousPosition)
				error('SP:UpdateBoxForNode:NoPrevious', 'There has not been a previous position');
			end

			[qn,in,jn] = obj.GetQuadrantAndIndices(n.x,n.y);
			[qo,io,jo] = obj.GetQuadrantAndIndices(n.previousPosition(1),n.previousPosition(2));

			if ~prod([qn,in,jn] == [qo,io,jo])
				% The given node is in a different box compared to
				% the previous timestep/position, so need to do some adjusting

				obj.InsertNode(qn,in,jn,n);

				obj.nodesQ{qo}{io,jo}( obj.nodesQ{qo}{io,jo} == n ) = [];

				% Also need to adjust the elements
				obj.UpdateBoxesForElementsUsingNode(n);

			end

		end

		function UpdateBoxesForElementsUsingNode(obj, n1)

			% This function will be used as each node is moved
			% As such, we know the node n1 has _just_ moved therefore
			% we need to look at the current position and the previous
			% position to see which boxes need changing
			% We know nothing about the other nodes of the elements
			% so at this point we just assume they are in their final
			% position. This will cause doubling up of effort if both
			% nodes end up moving to a new box, but this should be
			% fairly rare occurrance.

			% Logic of processing:
			% If the node n1 is the first one from an element to move
			% boxes, then we use the current position for n2
			% If node n1 is the second to move, then the current position
			% for n2 will still be the correct to use

			for i=1:length(n1.elementList)
				% If the element is an internal element, skip it
				% because they don't interact with nodes
				
				e = n1.elementList(i);
				if ~e.IsElementInternal()

					n2 = e.GetOtherNode(n1);

					[ql,il,jl] = obj.GetBoxIndicesBetweenNodes(n1, n2);
					[qp,ip,jp] = obj.GetBoxIndicesBetweenNodesPreviousCurrent(n1, n2);

					% If the box appears in both, nothing needs to change
					% If it only appears in previous, remove element
					% If it only appears in current, add element

					new = [ql,il,jl];
					old = [qp,ip,jp];

					% Get the unique new boxes
					J = ~ismember(new,old,'rows');
					% And get the indices to add
					qa = ql(J);
					ia = il(J);
					ja = jl(J);
					
					for j = 1:length(qa)
						obj.InsertElement(qa(j),ia(j),ja(j),e);
					end

					% Get the old boxes
					J = ~ismember(old,new,'rows');
					% ... and rhe indices to remove
					qt = qp(J);
					it = ip(J);
					jt = jp(J);
					for j = 1:length(qt)
						obj.RemoveElement(qt(j),it(j),jt(j),e);
					end

				end

			end

		end

		function UpdateBoxesForElement(obj, e)

			% This function will be run in the simulation
			% It will be done after all the nodes have moved

			% This check should really be done in the simulation
			% but this is the only good spot to do it
			if ~e.IsElementInternal() 

				n1 = e.Node1;
				n2 = e.Node2;
				if obj.IsNodeInNewBox(n1) || obj.IsNodeInNewBox(n2)
					[ql,il,jl] = obj.GetBoxIndicesBetweenNodes(n1, n2);
					[qp,ip,jp] = obj.GetBoxIndicesBetweenNodesPrevious(n1, n2);

					% If the box appears in both, nothing needs to change
					% If it only appears in previous, remove element
					% If it only appears in current, add element

					new = [ql,il,jl];
					old = [qp,ip,jp];

					% Get the unique new boxes
					J = ~ismember(new,old,'rows');
					% And get the indices to add
					qa = ql(J);
					ia = il(J);
					ja = jl(J);
					
					for j = 1:length(qa)
						obj.InsertElement(qa(j),ia(j),ja(j),e);
					end

					% Get the old boxes
					J = ~ismember(old,new,'rows');
					% ... and rhe indices to remove
					qt = qp(J);
					it = ip(J);
					jt = jp(J);
					for j = 1:length(qt)
						obj.RemoveElement(qt(j),it(j),jt(j),e);
					end

				end

			end

		end

		function InsertNode(obj,q,i,j,n)

			% This is the sensible way to do this, but it doesn't always
			% work properly
			% if i > size(obj.nodesQ{q},1) || j > size(obj.nodesQ{q},2)
			% 	obj.nodesQ{q}{i,j} = [n];
			% else
			% 	obj.nodesQ{q}{i,j}(end + 1) = n;
			% end

			% I know it's bad practice to make the work flow work from an error
			% but it doesn't work the proper way if the box exists, but is empty
			% and you want to make sure the node doesn't already exist in there
			try
				obj.nodesQ{q}{i,j}(end + 1) = n;
				obj.nodesQ{q}{i,j} = unique(obj.nodesQ{q}{i,j});
			catch ME
				if (strcmp(ME.identifier,'MATLAB:badsubscript'))
					obj.nodesQ{q}{i,j} = [n];
				else
					error('SP:InsertNode:WrongFail','Assignment didnt fail properly');
				end
			end

		end

		function InsertElement(obj,q,i,j,e)


			try
				obj.elementsQ{q}{i,j}(end + 1) = e;
				obj.elementsQ{q}{i,j} = unique(obj.elementsQ{q}{i,j});
			catch ME
				if (strcmp(ME.identifier,'MATLAB:badsubscript'))
					obj.elementsQ{q}{i,j} = [e];
				else
					error('SP:InsertElement:WrongFail','Assignment didnt fail properly');
				end
			end

			% % Put the element in the box, first checking that the box exists
			% % This should be the best way to do it, but the line ~prod(obj.elementsQ{  Q(j)  }{  I(j), J(j)  } == e)
			% % doesn't work with an empty vector
			% if I(j) > size(obj.elementsQ{  Q(j)  }, 1 ) || J(j) > size(obj.elementsQ{  Q(j)  }, 2)


			% 	obj.elementsQ{  Q(j)  }{  I(j), J(j)  } = [e];

			% else
			% 	% If the box does exist, make sure we aren't duplicating
			% 	% the element
			% 	if ~prod(obj.elementsQ{  Q(j)  }{  I(j), J(j)  } == e)
			% 		obj.elementsQ{  Q(j)  }{  I(j), J(j)  }(end + 1) = e;
			% 	end

			% end

		end

		function RemoveElement(obj,q,i,j,e)

			% If it gets to this point, the element should be in
			% the given box, so no need for error catching
			% If it does in fact fail here, we want it to stop
			obj.elementsQ{q}{i,j}( obj.elementsQ{q}{i,j}==e ) = [];

		end

		function b = GetNodeBox(obj, x, y)
			% Given a pair of coordinates, access the matching box

			[q,i,j] = obj.GetQuadrantAndIndices(x,y);

			b = obj.nodesQ{q}{i,j};

		end

		function new = IsNodeInNewBox(obj, n)

			% Redundant now, but leaving for testing
			new = false;

			if isempty(n.previousPosition)
				error('SP:IsNodeInNewBox:NoPrevious', 'There has not been a previous position');
			end

			[qn,in,jn] = obj.GetQuadrantAndIndices(n.x,n.y);
			[qo,io,jo] = obj.GetQuadrantAndIndices(n.previousPosition(1),n.previousPosition(2));

			if ~prod([qn,in,jn] == [qo,io,jo])
				new = true;
			end

		end

		function b = GetElementBox(obj, x, y)
			% Given a pair of coordinates, access the matching box

			% Determine the indices
			[q,i,j] = obj.GetQuadrantAndIndices(x,y);

			b = obj.elementsQ{q}{i,j};

		end

		function [q,i,j] = GetQuadrantAndIndices(obj, x,y)
			
			q = obj.GetQuadrant(x,y);
			[i,j] = obj.GetIndices(x,y);

		end

		function [I,J] = GetGlobalIndices(obj, x, y)
			% The indices we would have if matlab could
			% handle negative indices

			I = sign(x) * (floor(abs(x/obj.dx)) + 1);
			J = sign(y) * (floor(abs(y/obj.dy)) + 1);

		end

		function [I, J] = ConvertToGlobal(obj,q,i,j)

			switch q
				case 1
					I = i;
					J = j;
				case 2
					I = i;
					J = -j;
				case 3
					I = -i;
					J = -j;
				case 4
					I = -i;
					J = j;
				otherwise
					error('q must be 1,2,3, or 4')
			end

		end

		function [q,i,j] = ConvertToQuadrant(obj,I,J)

			q = GetQuadrant(obj,I,J);
			i = abs(I);
			j = abs(J);

		end

		function [i,j] = GetIndices(obj, x,y)
			% Determine the indices
			% Have to add 1 because matlab is a shitty language that
			% doesn't index from zero, like a sensible language ¯\_(ツ)_/¯
			i = floor(abs(x/obj.dx)) + 1;
			j = floor(abs(y/obj.dy)) + 1;

		end

		function q = GetQuadrant(obj,x,y)


			% Determine the correct quadrant
			% 1: (+,+)
			% 2: (+,-)
			% 3: (-,-)
			% 4: (-,+)

			if length(x) > 1
				% Vectorising attempt
				q = (sign(x)+1) + 3 * (sign(y)+1);

				% Magic numbers
				% Basically, there are 8 situations to handle
				% The equation above produces a unique value
				% for each situation, which is processed below
				q(q==1) = 2;
				q(q==4) = 1;
				q(q==3) = 4;
				q(q==5) = 1;
				q(q==7) = 1;
				q(q==8) = 1;
				q(q==6) = 4;
				q(q==0) = 3;
			else
				% Quick checking if x,y are scalars 
				if sign(x) >= 0 
					if sign(y) >= 0
						q = 1;
					else
						q = 2;
					end
				else
					if sign(y) < 0
						q = 3;
					else
						q = 4;
					end
				end
			end	

		end

	end


end