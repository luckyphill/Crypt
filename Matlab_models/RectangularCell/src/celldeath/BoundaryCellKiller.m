classdef BoundaryCellKiller < AbstractCellKiller
	% A cell cycle that does nothing except count the age of the cell
	properties

		leftBoundary
		rightBoundary

	end
	methods

		function obj = BoundaryCellKiller(leftBoundary, rightBoundary)

			if leftBoundary => rightBoundary
				error('BCK:WrongOrder','Left boundary is further right than right boundary');
			end
			obj.leftBoundary = leftBoundary;
			obj.rightBoundary = rightBoundary;

		end

		function killList = MakeKillList(obj, cellList)

			% Implements abstract method from AbstractCellKiller
			% If a cell is further left than the leftBoundary
			% or further right than the rightBoundary, then it is killed
			% immediately
			killList = Cell.empty();
			for i = 1:length(cellList)
				c = cellList(i);
				
				% Kill left cells if they are entirely
				% past the left boundary
				if c.nodeTopRight.x < obj.leftBoundary || c.nodeBottomRight.x < obj.leftBoundary
					killList(end+1) = c;
				end

				% and if they are entirely past the right boundary
				if c.nodeTopLeft.x < obj.rightBoundary || c.nodeBottomLeft.x < obj.rightBoundary
					killList(end+1) = c;
				end

				% Note: this does not check if the cell meets both criteria at once
				% but this should be impossible as the left and right boundaries are
				% checked for compliance at instantiation
			end

		end

	end


end