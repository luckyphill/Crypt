classdef Element < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% Essential porperties of a node
		id

		% This will be circular - each element will have two nodes
		% each node can be part of multiple elements
		Node1
		Node2

		naturalLength = 1
		stiffness = 20

		len
		dx
		force

		direction1to2
		force1to2

		edgeGradient

		minimumLength = 0.2

		cellList
		
	end

	methods
		function obj = Element(Node1, Node2, id)
			% All the initilising
			% An element will always have a pair of nodes

			obj.Node1 = Node1;
			obj.Node2 = Node2;

			obj.id = id;

			obj.Node1.AddElement(obj);
			obj.Node2.AddElement(obj);
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
			direction1to2 = obj.direction1to2 / norm(obj.direction1to2);

		end


		function AddCell(obj, c)

			obj.cellList = [obj.cellList , c];
			obj.Node1.AddCell(c);
			obj.Node2.AddCell(c);

		end

		function otherNode = GetOtherNode(obj, node)
			% Since we don't know what order the nodes are in, we need a special way to grab the
			% other node if we already know one of them

			if node == obj.Node1
				otherNode = obj.Node1;
			else
				if node == obj.Node2
					otherNode = obj.Node2;
				else
					error('Node not in this element');
				end
			end


		end

		function ReplaceNode(obj, oldNode, newNode)
			% Removes the old node from the element, and replaces
			% it with a new node. This is used in cell division primarily

			% To do this properly, we need fix all the links to nodes and cells
			if oldNode == newNode
				warning('e:sameNode', 'The old node is the same as the new node. This is probably not what you wanted to do')
			end
			
			switch oldNode
				case obj.Node1
					% Remove link back to this element
					obj.Node1.RemoveElement(obj);
					obj.Node1 = newNode;
					obj.Node1.AddElement(obj);

				case obj.Node2
					% Remove link back to this element
					obj.Node2.RemoveElement(obj);
					obj.Node2 = newNode;
					obj.Node2.AddElement(obj);
				otherwise
					error('e:nodeNotFound','Node not in this element')
			end

		end

	end

	methods (Access = private)


	end


end