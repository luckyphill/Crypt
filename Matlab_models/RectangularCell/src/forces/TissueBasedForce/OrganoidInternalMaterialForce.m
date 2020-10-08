classdef OrganoidInternalMaterialForce < AbstractTissueBasedForce
	% This force uses the Nagai Honda target area force
	% to push the inside of an organoid to a preferred
	% area. The goal is for the inside of the organoid
	% to keep a circular shape, and allow crypts to
	% grow off the edges


	properties

		areaEnergyParameter
		areaPerNewCell
		intialArea

	end

	methods


		function obj = OrganoidInternalMaterialForce(areaEnergyParameter, areaPerNewCell, intialArea)

			% Area energy as per Nagai Honda
			% each time a cell is addes, a certain amount of material
			% is added to the centre of the organoid.
			% The organoid must start with a certain area.

			obj.areaEnergyParameter = areaEnergyParameter;
			obj.areaPerNewCell = areaPerNewCell;
			obj.intialArea = intialArea;

		end

		function AddTissueBasedForces(obj, t)

			nodeList = Node.empty();
			% Collect the nodes around the inner of the organoid

			c = t.cellList(1);
			nodeList(end+1) = c.nodeBottomLeft;

			c = c.GetAdjacentCellLeft();

			while c ~= t.cellList(1)
				nodeList(end+1) = c.nodeBottomLeft;
				c = c.GetAdjacentCellLeft();
			end

			obj.AddTargetAreaForces(nodeList)

		end


		function AddTargetAreaForces(obj, nodeList)

			x = [nodeList.x];
			y = [nodeList.y];

			currentArea 		= polyarea(x,y);
			
			% Crucial to the whole force
			targetArea 			= obj.intialArea + length(nodeList) * obj.areaPerNewCell;

			magnitude = obj.areaEnergyParameter * (currentArea - targetArea);

			% First node outside the loop
			n = nodeList(1);
			ncw = nodeList(end);
			nacw = nodeList(2);

			u = nacw.position - ncw.position;
			v = [u(2), -u(1)];

			n.AddForceContribution( -v * magnitude);

			% Loop the intermediate nodes
			for i = 2:length(nodeList)-1

				n = nodeList(i);
				ncw = nodeList(i-1);
				nacw = nodeList(i+1);

				u = nacw.position - ncw.position;
				v = [u(2), -u(1)];

				n.AddForceContribution( -v * magnitude);

			end

			% Last node outside loop
			n = nodeList(end);
			ncw = nodeList(end-1);
			nacw = nodeList(1);

			u = nacw.position - ncw.position;
			v = [u(2), -u(1)];

			n.AddForceContribution( -v * magnitude);

		end

	end



end