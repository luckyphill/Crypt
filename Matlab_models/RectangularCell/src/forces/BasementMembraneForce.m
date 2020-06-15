classdef BasementMembraneForce < AbstractTissueBasedForce
	% Keeps the cells flat


	properties

		springRate

	end

	methods

		function obj = BasementMembraneForce(springRate)

			obj.springRate = springRate;

		end

		function AddTissueBasedForces(obj, tissue)


			% Along the epithelial layer, calculate the angle between two bottom elements
			% and add forces to push this towards flat
			for i = 1:length(tissue.cellList)
				c = tissue.cellList(i);
				% Get the left cell, get the right cell, get the angle
				% about the bottom nodes

				leftCell = c.elementLeft.GetOtherCell(c);
				rightCell = c.elementRight.GetOtherCell(c);

				if ~isempty(leftCell)

					nl = leftCell.nodeBottomLeft;
					n = c.nodeBottomLeft;
					nr = c.nodeBottomRight;

					obj.CalculateAndAddRestoringForce(nl, n, nr);

				end


				if ~isempty(rightCell)

					nl = c.nodeBottomLeft;
					n = c.nodeBottomRight;
					nr = rightCell.nodeBottomRight;

					obj.CalculateAndAddRestoringForce(nl, n, nr);

				end

			end

		end


		function CalculateAndAddRestoringForce(obj, nl, n, nr)


			ul = nl.position - n.position;

			ur = nr.position - n.position;

			theta = atan2(ul(1),ul(2)) - atan2(ur(1),ur(2));

			torque = obj.springRate * ( -pi - theta );

			ll = norm(ul);
			lr = norm(ur);

			vl = [ul(2), -ul(1)];
			vr = [ur(2), -ur(1)];

			nl.AddForceContribution(vl * torque / ll);
			n.AddForceContribution(-vl * torque / ll);

			n.AddForceContribution(vr * torque / lr);
			nr.AddForceContribution(-vr * torque / lr);

		end

	end

end