classdef PushCellForce < AbstractTissueBasedForce
	% Adds a constant force to a given cell


	properties

		movingCell
		force

	end

	methods

		function obj = PushCellForce(c, f)

			obj.movingCell = c;
			if length(f) ~=2
				error('Force needs to be a 2x1 vector');
			end
			obj.force = f;

		end


		function AddTissueBasedForces(obj, tissue)

			% Ignore the tissue, just focus on the membrane passed in

			for i = 1:length(obj.movingCell.nodeList)

				n = obj.movingCell.nodeList(i);

				n.AddForceContribution(obj.force);

			end

		end

	end

end