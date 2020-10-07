classdef OrganoidPressureForce < AbstractTissueBasedForce
	% This force adds a pressure to the inside of the organoid
	% dependent on the amount of material inside, and a constant
	% pressure to the outside provided by the matrigel

	% It must only be used for a SquareCellJoined in a ring
	% simulation, as there needs to be a clearly defined inside
	% and outside (top and bottom).


	properties

		externalPressure
		internalPressure

	end

	methods


		function obj = OrganoidPressureForce(ep,ip)

			obj.externalPressure = ep;
			obj.internalPressure = ip;

		end

		function AddTissueBasedForces(obj, t)

			for i = 1:length(t.cellList)
				c = t.cellList(i);
				obj.ApplySpringForce(c)
			end

		end


		function ApplySpringForce(obj, c)

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

			nb = eb.GetOutwardNormal();
			Fb = -nb * et.GetLength() * obj.internalPressure;

			eb.Node1.AddForceContribution(Fb);
			eb.Node2.AddForceContribution(Fb);


		end

	end



end