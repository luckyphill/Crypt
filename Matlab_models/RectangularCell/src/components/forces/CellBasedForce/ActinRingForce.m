classdef ActinRingForce < AbstractCellBasedForce
	% Pulls opposite nodes together to see how the Nagai Honda force handles it


	properties

		springRate
		shrinkRate

	end

	methods


		function obj = ActinRingForce(f, shrink)

			obj.springRate = f;
			obj.shrinkRate = shrink;

		end

		function AddCellBasedForces(obj, cellList)

			% For each cell in the list, calculate the forces
			% and add them to the nodes

			for i = 1:length(cellList)

				c = cellList(i);
				obj.ApplySpringForce(c);

			end

		end


		function ApplySpringForce(obj, c)

			% Takes the first and opposite nodes around the boundary and drags them together
			% It decreases the intended separation gradually over the life of the cell

			% This is intended for a single cell, so give it time to normalise first
			nTime = 2;
			if c.GetAge() > nTime
				n1 = c.nodeList(1);
				n2 = c.GetOppositeNode(1); % Must be even at this point

				v1to2 = n2.position - n1.position;

				y = norm(v1to2);
				x = 3-c.GetAge();
				if x < 0.2
					x = 0.2; 
				end

				u = v1to2 / y;

				force = u*obj.springRate*(y - x);

				n1.AddForceContribution(force);
				n2.AddForceContribution(-force);

				% fprintf('current = %.4g, target = %.4g\n',y,x);

			end


		end

	end



end