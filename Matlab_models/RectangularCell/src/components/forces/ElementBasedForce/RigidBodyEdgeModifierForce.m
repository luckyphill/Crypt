classdef RigidBodyEdgeModifierForce < AbstractElementBasedForce
	% This class gives the details for how a force will be applied
	% to each Element (as opposed to each cell, or the whole population)


	properties

		minLength

	end

	methods

		function obj = RigidBodyEdgeModifierForce(minLength)

			obj.minLength = minLength;

		end

		function AddElementBasedForces(obj, elementList)

			for i = 1:length(elementList)
				e = elementList(i);
				if e.GetLength() <= obj.minLength
					obj.AppliedRigidBodyForces(e);
				end
			end
		end


		function AppliedRigidBodyForces(obj, e)

			% If the resulting forces on the element result in compression
			% treat the element like a rigid body by transferring the axial forces
			% from one element to the other
			unitVector1to2 = (e.Node2.position - e.Node1.position) / e.GetLength();

			axial1 = sum(e.Node1.force .* unitVector1to2);
			axial2 = sum(e.Node2.force .* unitVector1to2);

			if axial1 > 0 && axial2 < 0
				% The forces are pointing towards each other
				% apply axial forces to other nodes
				e.Node1.AddForceContribution(axial2 * unitVector1to2);
				e.Node2.AddForceContribution(axial1 * unitVector1to2);
				% fprintf('Responded to compression\n')
			end

			if (axial1 > 0 && axial2 > 0) && axial1 > axial2
				% The forces are pointing in the same direction but the
				% inward pointing force is larger, so add inward for to
				% the other node
				e.Node2.AddForceContribution(axial1 * unitVector1to2);
				% fprintf('Responded to pushing 1 to 2\n')
			end

			if (axial1 < 0 && axial2 < 0) && axial1 > axial2
				% Same as above, but the other force is inwards facing
				e.Node1.AddForceContribution(axial2 * unitVector1to2);
				% fprintf('Responded to pushing 2 to 1\n')
			end



		end

	end



end