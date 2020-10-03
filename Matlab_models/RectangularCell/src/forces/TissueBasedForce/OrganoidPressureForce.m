classdef OrganoidPressureForce < AbstractTissueBasedForce
	% This force adds a pressure to the inside of the organoid
	% dependent on the amount of material inside, and a constant
	% pressure to the outside provided by the matrigel

	% It must only be used for a SquareCellJoined in a ring
	% simulation, as there needs to be a clearly defined inside
	% and outside (top and bottom).


	properties

		externalPressure

	end

	methods


		function obj = OrganoidPressureForce(p)

			obj.externalPressure = p;

		end

		function AddTissueBasedForces(obj, t)

			% Find the area inside the organoid
			N = length(t.cellList);
			polyNodes = zeros(N,2);
			for i = 1:N
				polyNodes(i,:) = t.cellList(i).nodeBottomLeft.position;
			end
			x = polyNodes(:,1);
			y = polyNodes(:,2);
			A = polyarea(x,y);

			% Using a perverted form of the ideal gas law, the internal pressure
			% will be the internal mass divided by the internal area
			% For argument's sake, the internal mass is directly proprtional to
			% the number of cells around the perimeter

			ip = 0.05*N/A;

			for i = 1:N
				c = t.cellList(i);
				obj.ApplySpringForce(c,ip)
			end
		end


		function ApplySpringForce(obj, c, ip)

			% The top edge will experience a constant pressure, the bottom edge
			% will experience pressure according to the internal area
			% of the organoid

			et = c.elementTop;
			eb = c.elementBottom;

			% Since pressure is applied evenly across the full length of the
			% element, there is no rotation, hence the force can be applied directly
			% to the end nodes.
			nt = et.GetOutwardNormal();
			Ft = -nt * et.GetLength() * obj.externalPressure;

			et.Node1.AddForceContribution(Ft);
			et.Node2.AddForceContribution(Ft);

			% nb = eb.GetOutwardNormal();
			% Fb = -nb * et.GetLength() * ip;

			% eb.Node1.AddForceContribution(Fb);
			% eb.Node2.AddForceContribution(Fb);


		end

	end



end