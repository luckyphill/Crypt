classdef SupportingTissueMembraneForce < AbstractTissueBasedForce
	% Keeps the cells flat


	properties

		springRate

	end

	methods

		function obj = SupportingTissueMembraneForce(springRate)

			obj.springRate = springRate;

		end

		function AddTissueBasedForces(obj, tissue)


			% Along the epithelial layer, calculate the angle between two bottom elements
			% and add forces to push this towards flat
			for i = 1:length(tissue.elementList)
				e = tissue.elementList(i);
				% Get the left cell, get the right cell, get the angle
				% about the bottom nodes
				if e.isMembrane
					obj.CalculateAndAddRestoringForce(e);
				end

			end

		end


		function CalculateAndAddRestoringForce(obj, e)


			% This force represents the stromal layer underneath the epithelium
			% as an elastic volume. Along the length of the element it imparts
			% a force based on the displacement from y = 0. It calculates this
			% force as an energy, integrates across the element, then applies
			% the force to the end nodes. See thesis write up for details

			nl = e.Node2; % Assuming a straight line with upward normal
			nr = e.Node1;

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