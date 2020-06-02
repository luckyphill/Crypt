classdef BoundaryCellKiller < AbstractTissueLevelCellKiller
	% A class for killing Boundary cells.
	% This only kills cells when they move past a certain position
	properties

		leftBoundary
		rightBoundary

	end
	methods

		function obj = BoundaryCellKiller(leftBoundary, rightBoundary)

			if leftBoundary >= rightBoundary
				error('BCK:WrongOrder','Left boundary is further right than right boundary');
			end
			obj.leftBoundary = leftBoundary;
			obj.rightBoundary = rightBoundary;

		end

		function KillCells(obj, t)

			% Kills the cells at the boundary if requested
			t.UpdateBoundaryCells();

			while obj.IsPastLeftBoundary(t.leftBoundaryCell)

				obj.RemoveLeftBoundaryCellFromSimulation(t);

			end

			while obj.IsPastRightBoundary(t.rightBoundaryCell)

				obj.RemoveRightBoundaryCellFromSimulation(t);

			end

		end

		function past = IsPastLeftBoundary(obj, c)

			past = false;
			if c.nodeTopRight.x < obj.leftBoundary || c.nodeBottomRight.x < obj.leftBoundary
				past = true;
			end

		end

		function past = IsPastRightBoundary(obj, c)

			past = false;
			if c.nodeTopLeft.x > obj.rightBoundary || c.nodeBottomLeft.x > obj.rightBoundary
				past = true;
			end

		end

		function RemoveLeftBoundaryCellFromSimulation(obj, t)

			% This is used when a cell is removed on the boundary
			% A different method is needed when the cell is internal

			% Need to becareful to actually remove the nodes etc.
			% rather than just lose the links

			c = t.leftBoundaryCell;
			t.leftBoundaryCell = c.elementRight.GetOtherCell(c);

			% Clean up elements

			t.elementList(t.elementList == c.elementTop) = [];
			t.elementList(t.elementList == c.elementLeft) = [];
			t.elementList(t.elementList == c.elementBottom) = [];

			c.nodeTopRight.elementList( c.nodeTopRight.elementList ==  c.elementTop ) = [];
			c.nodeBottomRight.elementList( c.nodeBottomRight.elementList ==  c.elementBottom ) = [];

			c.elementRight.cellList(c.elementRight.cellList == c) = [];

			if t.usingBoxes
				t.boxes.RemoveElementFromPartition(c.elementTop);
				t.boxes.RemoveElementFromPartition(c.elementLeft);
				t.boxes.RemoveElementFromPartition(c.elementBottom);
			end

			c.elementTop.delete;
			c.elementLeft.delete;
			c.elementBottom.delete;

			% Clean up nodes

			t.nodeList(t.nodeList == c.nodeTopLeft) = [];
			t.nodeList(t.nodeList == c.nodeBottomLeft) = [];

			if t.usingBoxes
				t.boxes.RemoveNodeFromPartition(c.nodeTopLeft);
				t.boxes.RemoveNodeFromPartition(c.nodeBottomLeft);
			end

			c.nodeTopLeft.delete;
			c.nodeBottomLeft.delete;

			% Clean up cell

			t.cellList(t.cellList == c) = [];

			c.delete;

		end

		function RemoveRightBoundaryCellFromSimulation(obj, t)

			% This is used when a cell is removed on the boundary
			% A different method is needed when the cell is internal

			% Need to becareful to actually remove the nodes etc.
			% rather than just lose the links

			c = t.rightBoundaryCell;
			t.rightBoundaryCell = c.elementLeft.GetOtherCell(c);

			
			% Clean up elements

			t.elementList(t.elementList == c.elementTop) = [];
			t.elementList(t.elementList == c.elementRight) = [];
			t.elementList(t.elementList == c.elementBottom) = [];

			c.nodeTopLeft.elementList( c.nodeTopLeft.elementList ==  c.elementTop ) = [];
			c.nodeBottomLeft.elementList( c.nodeBottomLeft.elementList ==  c.elementBottom ) = [];

			c.elementLeft.cellList(c.elementLeft.cellList == c) = [];

			if t.usingBoxes
				t.boxes.RemoveElementFromPartition(c.elementTop);
				t.boxes.RemoveElementFromPartition(c.elementRight);
				t.boxes.RemoveElementFromPartition(c.elementBottom);
			end

			c.elementTop.delete;
			c.elementRight.delete;
			c.elementBottom.delete;

			% Clean up nodes 

			t.nodeList(t.nodeList == c.nodeTopRight) = [];
			t.nodeList(t.nodeList == c.nodeBottomRight) = [];

			if t.usingBoxes
				t.boxes.RemoveNodeFromPartition(c.nodeTopRight);
				t.boxes.RemoveNodeFromPartition(c.nodeBottomRight);
			end

			c.nodeTopRight.delete;
			c.nodeBottomRight.delete;

			% Finally clean up cell

			t.cellList(t.cellList == c) = [];

			c.delete;

		end

	end


end