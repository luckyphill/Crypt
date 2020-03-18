classdef Node < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% Essential porperties of a node
		x
		y

		position

		id

		force = [0, 0]

		% This will be circular - each element will have two nodes
		% each node can be part of multiple elements
		elementList = []

	end

	methods

		function obj = Node(x,y,id)
			% Initialise the node

			obj.x 	= x;
			obj.y 	= y;

			obj.position = [x,y];
			obj.id 	= id;
		end

		function AddForceContribution(obj, force)
			obj.force = obj.force + force;
		end

		function UpdatePosition(obj, dtEta)

			newPosition = obj.position + dtEta * obj.force;

			obj.NewPosition(newPosition);

			% Reset the force for next time step
			obj.force = [0,0];

		end

		function AddElement(obj, ele)
			obj.elementList = [obj.elementList , ele];
		end

		function NewPosition(obj, pos)

			obj.position = pos;

			obj.x = pos(1);
			obj.y = pos(2);

		end



	end

	methods (Access = private)
		

	end


end
