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
		stiffness = 10

		dx
		force

		direction1to2
		force1to2

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

		function SetStiffness(obj, stf)

			obj.stiffness = stf;
		end

		function len = GetLength(obj)
			len = norm(obj.Node1.position - obj.Node2.position);
		end

		function UpdateDx(obj)

			l = norm(obj.Node1.position - obj.Node2.position);
			obj.dx = obj.naturalLength - l;
		end

		function UpdateForce(obj)

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

	end

	methods (Access = private)


	end


end