classdef BasementMembraneBeamForce < AbstractTissueBasedForce

	properties

		springRate

	end

	methods

		function obj = BasementMembraneBeamForce(springRate)

			obj.springRate = springRate;

		end

		function AddTissueBasedForces(obj, tissue)

			% Along the epithelial layer, calculate the angle between two bottom elements
			% and add forces to push this towards flat
			for i = 1:length(tissue.elementList)
				e = tissue.elementList(i);

				if e.isMembrane
					% need to get it's neighbouring elements
					if ~(length(e.Node1.elementList) == 1)
						er = e.Node1.elementList(e.Node1.elementList~=e);

						nr = er.Node1;
						n  = e.Node1;
						nl = e.Node2;

						obj.CalculateAndAddRestoringForce(nl, n, nr); 

					end

					if ~(length(e.Node2.elementList) == 1)
						
						el = e.Node2.elementList(e.Node2.elementList~=e);

						nr = e.Node1;
						n  = el.Node1;
						nl = el.Node2;

						obj.CalculateAndAddRestoringForce(nl, n, nr); 

					end

					obj.CalculateAndAddTensionForce(e);

				end
			end

		end


		function CalculateAndAddRestoringForce(obj, nl, n, nr)


			ul = nl.position - n.position;

			ur = nr.position - n.position;

			% This force models the element
			% as a beam. The angle determined here is the angle of deflection
			% from the adjacent element, which is then used to determine a
			% linear deflection from a line running throught said adjacent element
			% By beam theory for a cantilever beam with a point load F at the end,
			% the deflection is u = FL^3 / 3EI, where L is the length, E the elastic
			% modulus and I the second moment of area. This means the Force is
			% F = 3EIsin(a)/L^2, where a is theta. If we assume that the membrane
			% has the cross section of a flat rectangle, then I about its neutral axis
			% is I = bh^3/12 where b is the breadth (into the plane we are looking at)
			% and h is the height or thickness of the membrane.
			% This gives F = EAh^2sin(a)/4L^2, where our force parameter replaces EA
			% In order to apply both the restoring force and the tension for using the
			% same parameter, we are going to assume a thickness of the beam.
			
			h = 0.1; % The normal hieght of a cell is 1

			theta = atan2(ul(1),ul(2)) - atan2(ur(1),ur(2));

			torque = (h^2) * obj.springRate * sin( -pi - theta ) / 4;

			ll = norm(ul)^2;
			lr = norm(ur)^2;

			vl = [ul(2), -ul(1)];
			vr = [ur(2), -ur(1)];

			nl.AddForceContribution(vl * torque / ll);
			n.AddForceContribution(-vl * torque / ll);

			n.AddForceContribution(vr * torque / lr);
			nr.AddForceContribution(-vr * torque / lr);

		end


		function CalculateAndAddTensionForce(obj, e)

			% If the spring is in compression, push the end points away from each
			% other. Since obj.springFunction will give +ve value in this case
			% the unitvector must be made negative on Node1 and positive on Node2

			% The force parameter is EA so we need a formulation of the tension
			% force involving these quantities. Using the definition of stress, this
			% provides: F = dxEA/L
			l = e.GetLength();
			unitVector1to2 = (e.Node2.position - e.Node1.position) / l;

			n = e.GetNaturalLength();
			mag = obj.springRate * (n - l) / l;

			force = mag * unitVector1to2;

			e.Node1.AddForceContribution(-force);
			e.Node2.AddForceContribution(force);


		end

	end

end