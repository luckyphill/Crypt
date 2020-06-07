classdef Element < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% Essential porperties of an element
		id

		% The 'total drag' for the element at the centre of drag
		% This will be constant for an element, unless the 
		% coeficient of drag is changed for a node
		etaD 

		% This will be circular - each element will have two nodes
		% each node can be part of multiple elements
		Node1
		Node2

		% Used only when an element is modified during cell
		% division. Keep track of the old node to help with
		% adjusting the element boxes
		oldNode1
		oldNode2

		modifiedInDivision = false

		naturalLength = 1
		stiffness = 20

		minimumLength = 0.2

		nodeList
		cellList

		internal = false
		
	end

	methods

		function obj = Element(Node1, Node2, id)
			% All the initilising
			% An element will always have a pair of nodes

			% This ordering is important, because it defines the
			% orientation of the element. If the element is 
			% completely free in space, then the orientation is
			% arbitrary, but as soon as it is part of a cell (or membrane
			% if I end up developing one), then 1 to 2 must be chosen
			% so that if u = (Node2.position - Node1.position) / length,
			% then the unit vector v = [u(2), -u(1)] points out of the tissue.
			% Then, v will point to the right if forward is 1 to 2.
			% Due to the choice of v, travelling 1 to 2 will go
			% anticlockwise around the perimeter of the cell 

			% Note: v should be perpendicular, but I can't do that in ASCII art
			%        2 o
			%         /
			%        /
			%       /\
			%      /  \v
			%    u/    \
			%    /      
			% 1 o

			obj.Node1 = Node1;
			obj.Node2 = Node2;

			obj.nodeList = [Node1, Node2];

			obj.id = id;

			obj.Node1.AddElement(obj);
			obj.Node2.AddElement(obj);

			obj.UpdateTotalDrag();
			
		end

		function delete(obj)

			clear obj;

		end

		function UpdateTotalDrag(obj)
			% Of the three important physical quantities
			% total drag will only change if the drag coefficients
			% are explicitly changed

			obj.etaD = obj.Node1.eta + obj.Node2.eta;

		end

		function ID = GetMomentOfDrag(obj)
			% The length of the element will change at every time
			% step, so ID needs to be calculated every time
			r1 = obj.Node1.position;
			r2 = obj.Node2.position;

			rD = (obj.Node1.eta * r1 + obj.Node2.eta * r2) / etaD;

			rDto1 = r1 - rD;
			rDto2 = r2 - rD;

			ID = obj.Node1.eta * norm(rDto1)^2 + obj.Node2.eta * norm(rDto2)^2;

		end

		function SetNaturalLength(obj, len)

			obj.naturalLength = len;

		end

		function len = GetNaturalLength(obj)

			% Added here so it can be modified by cell age
			len = obj.naturalLength;

		end

		function len = GetLength(obj)
			
			len = norm(obj.Node1.position - obj.Node2.position);

		end

		function direction1to2 = GetVector1to2(obj)
			
			direction1to2 = obj.Node2.position - obj.Node1.position;
			direction1to2 = direction1to2 / norm(direction1to2);

		end

		function outward = GetOutwardNormal(obj)
			% See constructor for discussion about why this is the outward
			% normal
			u = obj.GetVector1to2();
			outward = [u(2), -u(1)];

		end

		function midPoint = GetMidPoint(obj)

			direction1to2 = obj.Node2.position - obj.Node1.position;
			midPoint = obj.Node1.position + 0.5 * direction1to2;

		end

		function AddCell(obj, c)

			obj.cellList = [obj.cellList , c];

		end

		function internal = IsElementInternal(obj)

			internal = obj.internal;

		end

		function otherNode = GetOtherNode(obj, node)

			if node == obj.Node1

				otherNode = obj.Node2;

			else

				if node == obj.Node2
					otherNode = obj.Node1;
				else
					error('Node not in this element');
				end

			end

		end

		function otherCell = GetOtherCell(obj, c)
			% Since we don't know what order the cells are in, we need a special way to grab the
			% other cell if we already know one of them. There will be two cases per simulation
			% where there is no other cell, so in these cases, return logical false

			otherCell = [];

			if length(obj.cellList) == 2

				if c == obj.cellList(1)

					otherCell = obj.cellList(2);

				else

					if c == obj.cellList(2)
						otherCell = obj.cellList(1);
					else
						error('Cell doesnt contain this element');
					end

				end

			end

		end

		function ReplaceNode(obj, oldNode, newNode)
			% Removes the old node from the element, and replaces
			% it with a new node. This is used in cell division primarily

			% To do this properly, we need fix all the links to nodes and cells
			if oldNode == newNode
				warning('e:sameNode', 'The old node is the same as the new node. This is probably not what you wanted to do')
			else
			
				switch oldNode
					case obj.Node1
						% Remove link back to this element
						obj.Node1.RemoveElement(obj);
						obj.nodeList(obj.nodeList == obj.Node1) = [];

						obj.Node1 = newNode;
						obj.Node1.AddElement(obj);
						obj.nodeList(end + 1) = obj.Node1;

						oldNode.elementList(oldNode.elementList == obj) = [];

						obj.modifiedInDivision = true;
						obj.oldNode1 = oldNode;

					case obj.Node2
						% Remove link back to this element
						obj.Node2.RemoveElement(obj);
						obj.nodeList(obj.nodeList == obj.Node2) = [];

						obj.Node2 = newNode;
						obj.Node2.AddElement(obj);
						obj.nodeList(end + 1) = obj.Node2;

						oldNode.elementList(oldNode.elementList == obj) = [];

						obj.modifiedInDivision = true;
						obj.oldNode2 = oldNode;
						
					otherwise
						error('e:nodeNotFound','Node not in this element')
				end
			end

		end

		function ReplaceCell(obj, oldC, newC)

			% Currently the cell list has at most two entries

			if obj.cellList(1) == oldC
				obj.cellList(1) = newC;
			else
				if length(obj.cellList) == 2
					if obj.cellList(2) == oldC
						obj.cellList(2) = newC;
					else
						error('Cell does not contain this element');
					end
				end
			end

		end

		function ReplaceCellList(obj, cellList)

			obj.cellList = cellList;
			
		end

		function RemoveCell(obj, c)
			% No error checking that cell is actually part of the list
			obj.cellList(obj.cellList == c) = [];

		end

	end

	methods (Access = private)


	end


end