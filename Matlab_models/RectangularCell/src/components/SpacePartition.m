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
		% of cell vectors
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

		end

		function N = GetNeighbours(obj, dr)

		end

		function PutNodeInBox(obj, n)

			[q,i,j] = obj.GetQuadrantAndIndices(n.x,n.y);

			obj.InsertNode(q,i,j,n);

		end

		function b = GetAdjacentNodeBox(obj, q,i,j, dir)

			% Returns the node box adjacent to the one indicated
			% specifying the direction

			% dir = [a, b]
			% where a,b = 1 or -1
			% 1 indicates an increase in the global index etc.
			% a is applied to I and b applied to J


			[I, J] = obj.ConvertToGlobal(q,i,j);

			I = I + a;
			J = J + b;

			% This is needed because matlab doesn't index from 0!!!!!!!!!!!!!!!!!

			if I == 0; I = a; end
			if J == 0; J = b; end

			[q,i,j] = obj.ConvertToQuadrant(I,J)


			b = obj.nodesQ{q}{i,j};

		end

		function b = GetAdjacentElementBox(obj, q,i,j, dir)

			% Returns the node box adjacent to the one indicated
			% specifying the direction

			% dir = [a, b]
			% where a,b = 1 or -1
			% 1 indicates an increase in the global index etc.
			% a is applied to I and b applied to J


			[I, J] = obj.ConvertToGlobal(q,i,j);

			I = I + a;
			J = J + b;

			% This is needed because matlab doesn't index from 0!!!!!!!!!!!!!!!!!

			if I == 0; I = a; end
			if J == 0; J = b; end

			[q,i,j] = obj.ConvertToQuadrant(I,J)


			b = obj.elementsQ{q}{i,j};

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
				if ~e.IsInternalElement()

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

		function [qp,ip,jp] = GetPreviousBoxIndicesBetweenNodes(obj, n1, n2)

			% Given two nodes, we want all the indices between them
			% in order to determine which boxes an element needs to go in

			% qp,ip,jp are vectors (lists) of all the possible box indices where
			% the element could pass through

			[q1,i1,j1] = obj.GetQuadrantAndIndices(n1.previousPosition(1),n1.previousPosition(2));
			[q2,i2,j2] = obj.GetQuadrantAndIndices(n2.previousPosition(1),n2.previousPosition(2));

			[qp,ip,jp] = obj.MakeElementBoxList(q1,i1,j1,q2,i2,j2);

		end

		function [ql,il,jl] = MakeElementBoxList(obj,q1,i1,j1,q2,i2,j2)

			% To find the boxes that the element could pass through
			% it is much simpler to convert to global indices, then
			% back to quadrants
			[I1, J1] = obj.ConvertToGlobal(q1,i1,j1);
			[I2, J2] = obj.ConvertToGlobal(q2,i2,j2);


			if I1<I2; Il = I1:I2; else; Il = I2:I1; end
			if J1<J2; Jl = J1:J2; else; Jl = J2:J1; end

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

		function UpdateBoxForNode(obj, n)

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


			for i=1:length(n1.elementList)
				% If the element is an internal element, skip it
				% because they don't interact with nodes
				
				e = n1.elementList(i);
				if ~e.IsElementInternal()

					n2 = e.GetOtherNode(n1);

					[ql,il,jl] = obj.GetBoxIndicesBetweenNodes(n1, n2);
					[qp,ip,jp] = obj.GetPreviousBoxIndicesBetweenNodes(n1, n2);

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
			% the given box, so no need for checking
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

			% Brute force checking 
			% if sign(x) >= 0 
			% 	if sign(y) >= 0
			% 		q = 1;
			% 	else
			% 		q = 2;
			% 	end
			% else
			% 	if sign(y) < 0
			% 		q = 3;
			% 	else
			% 		q = 4;
			% 	end
			% end	

		end

	end


end