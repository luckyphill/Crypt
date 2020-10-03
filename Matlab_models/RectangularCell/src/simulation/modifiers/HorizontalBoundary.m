classdef HorizontalBoundary < AbstractSimulationModifier
	% This modifier makes the boundary nodes for the left and
	% right boundary cells have the same y position
	% In theory this will stop a buckled monolayer from flapping about
	% and will simulate - to some extent - the stabilising influence
	% of a stromal underlayer

	properties

		bottom

	end

	methods

		function obj = HorizontalBoundary(bottom)

			obj.bottom = bottom;

		end

		function ModifySimulation(obj, t)

			% This keeps the nodes within a horizontal
			% channel by noving them back to the boundary
			% if they cross it. Energy is lost from the system
			% but it is a quick solution

			for i = 1:length(t.nodeList)
				n = t.nodeList(i);

				if n.y < obj.bottom
					t.AdjustNodePosition(n, [n.x, obj.bottom]);
				end

			end
			
		end

	end

end