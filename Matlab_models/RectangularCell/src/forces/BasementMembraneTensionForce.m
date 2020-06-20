classdef BasementMembraneTensionForce < AbstractElementBasedForce
	% This force adds in a tension for only to elements represetning
	% a basement membrane


	properties

		springRate

	end

	methods


		function obj = BasementMembraneTensionForce(s)

			obj.springRate = s;

		end

		function AddElementBasedForces(obj, elementList)

			for i = 1:length(elementList)
				e = elementList(i);
				if e.isMembrane
					obj.ApplySpringForce(e);
				end
			end
		end


		function ApplySpringForce(obj, e)

			% If the spring is in compression, push the end points away from each
			% other. Since obj.springFunction will give +ve value in this case
			% the unitvector must be made negative on Node1 and positive on Node2
			l = e.GetLength();
			unitVector1to2 = (e.Node2.position - e.Node1.position) / l;

			n = e.GetNaturalLength();
			mag = obj.springRate * (n - l);

			force = mag * unitVector1to2;

			e.Node1.AddForceContribution(-force);
			e.Node2.AddForceContribution(force);


		end

	end



end