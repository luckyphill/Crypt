classdef ShiftBoundaryCells < AbstractSimulationModifier
	% This modifier makes the boundary nodes for the left and
	% right boundary cells have the same y position
	% In theory this will stop a buckled monolayer from flapping about
	% and will simulate - to some extent - the stabilising influence
	% of a stromal underlayer

	properties

		% No special properties
	end

	methods


		function ShiftBoundaryCells()

			% No special initialisation

		end

		function ModifySimulation(obj, t)

			% Get the left and right boundary cells
			% Shift the left mosta nd right most nodes to the
			% same y position, which should be the average of
			% the two original positioons
		end
		
	end



end