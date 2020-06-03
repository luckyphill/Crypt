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

		function obj = ShiftBoundaryCells()

			% No special initialisation

		end

		function ModifySimulation(obj, t)

			% Get the left and right boundary cells
			% Shift the left mosta nd right most nodes to the
			% same y position, which should be the average of
			% the two original positioons

			bcs = t.simData('boundaryCells').GetData(t);

			left = bcs('left');
			right = bcs('right');

			ytl = left.nodeTopLeft.y;
			ybl = left.nodeBottomLeft.y;

			ytr = right.nodeTopRight.y;
			ybr = right.nodeBottomRight.y;

			yt = (ytl + ytr) / 2;
			yb = (ybl + ybr) / 2;

			ptl = [left.nodeTopLeft.x, yt];
			pbl = [left.nodeBottomLeft.x, yb];

			ptr = [right.nodeTopRight.x, yt];
			pbr = [right.nodeBottomRight.x, yb];

			t.AdjustNodePosition(left.nodeTopLeft, ptl);
			t.AdjustNodePosition(left.nodeBottomLeft, pbl);
			t.AdjustNodePosition(right.nodeTopRight, ptr);
			t.AdjustNodePosition(right.nodeBottomRight, pbr);
			
		end

	end

end