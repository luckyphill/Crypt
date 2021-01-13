classdef SupportingTissueForce < AbstractTissueBasedForce
	% Keeps the cells flat


	properties

		springRate

	end

	methods

		function obj = SupportingTissueForce(springRate)

			obj.springRate = springRate;

		end

		function AddTissueBasedForces(obj, tissue)


			% Along the epithelial layer, calculate the angle between two bottom elements
			% and add forces to push this towards flat
			for i = 1:length(tissue.cellList)
				c = tissue.cellList(i);
				% Get the left cell, get the right cell, get the angle
				% about the bottom nodes
				obj.CalculateAndAddRestoringForce(c);

			end

		end


		function CalculateAndAddRestoringForce(obj, c)


			% This force represents the stromal layer underneath the epithelium
			% as an elastic volume. Along the length of the element it imparts
			% a force based on the displacement from y = 0. It calculates this
			% force as an energy, integrates across the element, then applies
			% the force to the end nodes. See thesis write up for details

			nl = c.nodeBottomLeft;
			nr = c.nodeBottomRight;

			yl = nl.y;
			yr = nr.y;

			L = abs(nr.x - nl.x);

			Fl = -obj.springRate * L * (yl/3 + yr/6);
			Fr = -obj.springRate * L * (yr/3 + yl/6);

			nl.AddForceContribution(Fl);
			nr.AddForceContribution(Fr);

		end

	end

end