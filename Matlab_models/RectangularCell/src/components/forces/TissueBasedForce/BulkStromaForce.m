classdef BulkStromaForce < AbstractTissueBasedForce
	% Keeps the cells flat


	properties

		springRate;
		membrane;
		r0% the intial postion of each node in the membrane

	end

	methods

		function obj = BulkStromaForce(springRate, membrane)

			obj.springRate = springRate;
			obj.membrane = membrane;

			r0 = [];

			for i = 1:length(membrane)

				e = membrane(i);
				r0(e.Node1.id, :) = e.Node1.position;

			end

			obj.r0 = r0;


		end


		function AddTissueBasedForces(obj, tissue)

			% Ignore the tissue, just focus on the membrane passed in

			for i = 1:length(obj.membrane)

				e = obj.membrane(i);
				n = e.Node1;
				r0 = obj.r0(n.id,:);

				% Assume linear spring

				% Force will point from current position to original position
				dr = r0 - n.position;

				F = obj.springRate * dr;

				n.AddForceContribution(F);

			end

		end

	end

end