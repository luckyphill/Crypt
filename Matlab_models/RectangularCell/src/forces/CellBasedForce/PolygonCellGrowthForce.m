classdef PolygonCellGrowthForce < AbstractCellBasedForce
	
	% Applies energy based methods to drive the cell to a target area and perimeter
	% based on the energy density parameters

	properties

		areaEnergyParameter
		surfaceEnergyParameter

	end

	methods

		function obj = PolygonCellGrowthForce(areaP, surfaceP)

			obj.areaEnergyParameter 	= areaP;
			obj.surfaceEnergyParameter 	= surfaceP;
			
		end

		function AddCellBasedForces(obj, cellList)

			% For each cell in the list, calculate the forces
			% and add them to the nodes

			for i = 1:length(cellList)

				c = cellList(i);
				obj.AddTargetAreaForces(c);
				obj.AddTargetPerimeterForces(c);

			end

		end

		function AddTargetAreaForces(obj, c)

			% This force comes from "A dynamic cell model for the formation of epithelial
			% tissues", Nagai, Honda 2001. It comes from section 2.2 "Resistance force against
			% cell deformation". This force will push to cell to a target area. If left unchecked
			% the cell will end up at it's target area. The equation governing this energy is
			% U = \rho h_0^2 (A - A_0)^2
			% Here \rho is a area energy parameter, h_0 is the equilibrium height (in 3D)
			% and A_0 is the equilibrium area. In this force, \rho h_0^2 is replaced by \alpha
			% referred to areaEnergyParameter

			% This energy allows the cell to compress, but penalises the compression quadratically
			% The cyctoplasm of a cell is mostly water, so can be assumed incompressible, but
			% the bilipid membrane can have all sorts of molecules on its surface that
			% may exhibit some compressibility

			% The resulting force comes from taking the -ve divergence of the energy, and using
			% a cross-product method of finding the area of a given polygon. This results in:
			% -\sum_{i} \rho h_0^2 (A - A_0)^2 * [r_{acw} - r_{cw}] x k
			% Where r_{acw} and r_{cw} are vectors to the nodes anticlockwise and clockwise
			% respectively of the node i, and k is a unit normal vector perpendicular to the
			% plane of the nodes, and oriented by the right hand rule where anticlockwise is
			% cw -> i -> acw. The cross product produces a vector in the plane perpendicular
			% to r_{acw} - r_{cw}, and pointing out of the cell at node i

			% Practically, for each node in a cell, we take the cw and acw nodes, find the
			% vector cw -> acw, find it's perpendicular vector, and apply a force along
			% this vector according to the area energy parameter and the dA from equilibrium

			currentArea 		= c.GetCellArea();
			targetArea 			= c.GetCellTargetArea();

			magnitude = obj.areaEnergyParameter * (currentArea - targetArea);

			% First node outside the loop
			n = c.nodeList(1);
			ncw = c.nodeList(end);
			nacw = c.nodeList(2);

			u = nacw.position - ncw.position;
			v = [u(2), -u(1)];

			n.AddForceContribution( -v * magnitude);

			% Loop the intermediate nodes
			for i = 2:length(c.nodeList)-1

				n = c.nodeList(i);
				ncw = c.nodeList(i-1);
				nacw = c.nodeList(i+1);

				u = nacw.position - ncw.position;
				v = [u(2), -u(1)];

				n.AddForceContribution( -v * magnitude);

			end

			% Last node outside loop
			n = c.nodeList(end);
			ncw = c.nodeList(end-1);
			nacw = c.nodeList(1);

			u = nacw.position - ncw.position;
			v = [u(2), -u(1)];

			n.AddForceContribution( -v * magnitude);

		end

		function AddTargetPerimeterForces(obj, c)

			% This calculates the force applied to the cell boundary due to a difference
			% between current perimeter and target perimeter. The energy held in the boundary
			% is given by
			% U = \beta (p - P_0)^2 where p is the current perimeter and P_0 is the equilibrium
			% perimeter. The current perimeter is found by summing the magnitudes of the
			% vectors representing the edges around the perimeter.
			% To convert the energy to a force, the -ve divergence is taken with respect to the
			% variables identifying a given node's coordinates. Evidently the only vectors that
			% contribute are the one that contain the node.
			
			currentPerimeter 	= c.GetCellPerimeter();
			targetPerimeter 	= c.GetCellTargetPerimeter();

			magnitude = 2 * obj.surfaceEnergyParameter * (currentPerimeter - targetPerimeter);


			for i = 1:length(c.elementList)

				e = c.elementList(i);
				r = e.GetVector1to2();

				f = magnitude * r;

				e.Node1.AddForceContribution(f);
				e.Node2.AddForceContribution(-f);

			end

		end

	end

end