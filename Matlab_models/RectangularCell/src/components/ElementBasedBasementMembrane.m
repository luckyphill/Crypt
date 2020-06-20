classdef ElementBasedBasementMembrane < AbstractElementBasedTissue
	% A basement membrane made up of elements

	properties

		name = 'basementMembrane'

		partition

	end

	methods

		function obj = ElementBasedBasementMembrane(n, startPoint, endPoint, partition)

			% This partition must be for the whole organ
			obj.partition = partition;

			% n is the number of elements
			% startPoint is where the first node of the membrane is placed
			% endPoint is where the last is placed

			% The BM will be made up of n elements between startPoint and endPoint

			% n elements means n+1 nodes
			x0 = startPoint(1);
			y0 = startPoint(2);

			xf = endPoint(1);
			yf = endPoint(2);

			dx = (xf - x0) / n;
			dy = (yf - y0) / n;

			x = x0;
			y = y0;

			firstNode = Node(x, y, obj.GetNextNodeId());

			obj.nodeList = firstNode;
			obj.elementList = Element.empty();

			for i = 1:n

				x = x0 + i * dx;
				y = y0 + i * dy;

				secondNode = Node(x, y, obj.GetNextNodeId);
				obj.nodeList(end + 1) = secondNode;

				obj.elementList(end + 1) = Element(firstNode, secondNode, obj.GetNextElementId);

				firstNode = secondNode;

			end


		end

		function MakeTissueGrow(obj)

			% If elements are too stretched, split them
			% or if if they are too compressed, join them

			% At the moment, does nothing

		end

	end

end