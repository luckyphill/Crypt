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
		edgeAdhesionParameter = 0.1

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

		function SetEdgeAdhesionParameter(obj, p)

			obj.edgeAdhesionParameter = p;

		end

		function len = GetNaturalLength(obj)

			% Added here so it can be modified by cell age
			len = obj.naturalLength;

		end

		function SetStiffness(obj, stf)

			obj.stiffness = stf;

		end

		function len = GetLength(obj)

			len = norm(obj.Node1.position - obj.Node2.position);

		end

		function UpdateDx(obj)

			obj.dx = obj.GetNaturalLength() - obj.GetLength();

		end

		function UpdateForce(obj)

			% obj.UpdateForceSpring();
			obj.UpdateForceAdhesion();
			
		end

		function UpdateForceAdhesion(obj)

			% Each element has a gradient according to NagaiHonda force that is used for calculating the contribution from adhesion
			% The gradient is the opposite sign at each node, so need to take care to make sure the sign is correct
			% for each node when the force is actually applied. To this end, we will always have the vector pointing from Node1 to Node2
			% This force always wants to shrink the element, so pushes the nodes together along the element's vector
			obj.edgeGradient = (obj.Node2.position - obj.Node1.position) / obj.GetLength();

			force = obj.edgeAdhesionParameter * obj.edgeGradient;

			obj.Node1.AddForceContribution(force);
			obj.Node2.AddForceContribution(-force);

		end

		function UpdateForceSpring(obj)

			obj.UpdateDx()
			obj.force = obj.stiffness * obj.dx;

			obj.direction1to2 = obj.Node2.position - obj.Node1.position;
			obj.direction1to2 = obj.direction1to2 / norm(obj.direction1to2);

			obj.force1to2 = obj.direction1to2 * obj.force;

			obj.Node1.AddForceContribution(-obj.force1to2);
			obj.Node2.AddForceContribution(obj.force1to2);

		end


		function AddCell(obj, c)

			obj.cellList = [obj.cellList , c];

		end


		function ReplaceNode(obj, oldNode, newNode)
			% Removes the old node from the element, and replaces
			% it with a new node. This is used in cell division primarily
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