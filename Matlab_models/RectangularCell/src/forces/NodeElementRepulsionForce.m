classdef NodeElementRepulsionForce < AbstractNodeElementInteractionForce
	% Applies a force to push the angle of a cell corner towards its prefered value


	properties

		springRate

	end

	methods

		function obj = NodeElementRepulsionForce(springRate)

			obj.springRate = springRate;
			
		end

		function AddNodeElementInteractionForces(obj, nodeElementPairs)

			% For each cell in the list, calculate the forces
			% and add them to the nodes

			for i = 1:length(nodeElementPairs)

				c = cellList(i);
				obj.AddCouples(c);

			end

		end


	end



end