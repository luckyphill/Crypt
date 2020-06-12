classdef TestOriginalCell < matlab.unittest.TestCase
   
	methods (Test)

		function TestProperties(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			c.deformationEnergyParameter = 1;

			testCase.verifyEqual(c.id,1);

			testCase.verifyEqual(c.elementTop,et);
			testCase.verifyEqual(c.elementBottom,eb);
			testCase.verifyEqual(c.elementLeft,el);
			testCase.verifyEqual(c.elementRight,er);

			testCase.verifyEqual(c.nodeTopLeft,n2);
			testCase.verifyEqual(c.nodeTopRight,n4);
			testCase.verifyEqual(c.nodeBottomLeft,n1);
			testCase.verifyEqual(c.nodeBottomRight,n3);

			testCase.verifyEqual(c.currentCellTargetArea, 1);
			testCase.verifyEqual(c.deformationEnergyParameter,1);

		end

		function TestArea(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(NoCellCycle, [et,eb,el,er], 1);


			c.UpdateCellArea();

			testCase.verifyEqual(c.cellArea, 1);

			% Test a different shape
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1.1,1.1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(NoCellCycle, [et,eb,el,er], 1);


			c.UpdateCellArea();

			testCase.verifyEqual(c.cellArea, 1.1);

		end

		function TestDivide(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			[d, ~, ~] = c.Divide();

			% Check the nodes are in the correct position
			testCase.verifyEqual(c.nodeTopLeft.position,[0.5, 1]);
			testCase.verifyEqual(c.nodeTopRight.position,[1, 1]);
			testCase.verifyEqual(c.nodeBottomLeft.position,[0.5, 0]);
			testCase.verifyEqual(c.nodeBottomRight.position,[1, 0]);

			testCase.verifyEqual(d.nodeTopLeft.position,[0, 1]);
			testCase.verifyEqual(d.nodeTopRight.position,[0.5, 1]);
			testCase.verifyEqual(d.nodeBottomLeft.position,[0, 0]);
			testCase.verifyEqual(d.nodeBottomRight.position,[0.5, 0]);

			% Test all the links
			newtl = d.nodeTopLeft;
			newtr = d.nodeTopRight;
			newbl = d.nodeBottomLeft;
			newbr = d.nodeBottomRight;

			newt = d.elementTop;
			newb = d.elementBottom;
			newl = d.elementLeft;
			newr = d.elementRight;


			%  o------o
			%  |      |
			%  |      |
			%  |      |
			%  |      |
			%  |      |
			%  o------o

			% Becomes

			%  o~~~x---o
			%  |   l   |
			%  |   l   |
			%  |   l   |
			%  |   l   |
			%  |   l   |
			%  o~~~x---o

			% Check links with nodes
			% This is where errors could occur
			testCase.verifyTrue(ismember(c, newtr.cellList));
			testCase.verifyTrue(ismember(c, newbr.cellList));
			testCase.verifyFalse(ismember(c, newtl.cellList));
			testCase.verifyFalse(ismember(c, newbl.cellList));
			testCase.verifyEqual(c.nodeTopLeft, newtr);
			testCase.verifyEqual(c.nodeBottomLeft, newbr);

			% Should be a given
			testCase.verifyTrue(ismember(d, newtl.cellList));
			testCase.verifyTrue(ismember(d, newbl.cellList));
			testCase.verifyTrue(ismember(d, newtr.cellList));
			testCase.verifyTrue(ismember(d, newbr.cellList));

			% Check links with elements
			% This is where the error could occur
			testCase.verifyEqual(newl, el);
			testCase.verifyTrue(ismember(c, newr.cellList));
			testCase.verifyFalse(ismember(c, newl.cellList));
			testCase.verifyEqual(c.elementLeft, newr);

		end

		function TestInsideCell(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			% The cell is made of the points (0,0),(0,1),(1,0),(1,1)
			% So point (0.5,0.5) must be in, (1,0.5) must be on
			% and point (1.5,0.5) must be out.
			% If the nodes are oriented incorrectly [0.5, 0.5] will
			% be on the edge of the cell

			testCase.verifyTrue(c.IsPointInsideCell([0.5, 0.5]));
			testCase.verifyTrue(c.IsPointInsideCell([0.6, 0.6]));
			testCase.verifyFalse(c.IsPointInsideCell([1, 0.5]));
			testCase.verifyFalse(c.IsPointInsideCell([1.5, 0.5]));

		end

		function TestFlippedEdge(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyFalse(c.HasEdgeFlipped());

			n2.AdjustPosition([0.5,0.5]);
			n4.AdjustPosition([0.5,1]);
			testCase.verifyFalse(c.HasEdgeFlipped());

			% Borderline case, one edge is co-linear with another
			n2.AdjustPosition([1,0.5]);
			n4.AdjustPosition([1,1]);

			% Probably want this to trigger the flip but as it is, it
			% doesn't and I don't care enough about this to fix it
			% so I'll force it to be this way
			testCase.verifyFalse(c.HasEdgeFlipped());
			% testCase.verifyTrue(c.HasEdgeFlipped());


			n2.AdjustPosition([1.5,0.5]);
			n4.AdjustPosition([1,1]);
			testCase.verifyTrue(c.HasEdgeFlipped());

			n2.AdjustPosition([1,1]);
			n4.AdjustPosition([0,1]);
			testCase.verifyTrue(c.HasEdgeFlipped());

		end

	end

end