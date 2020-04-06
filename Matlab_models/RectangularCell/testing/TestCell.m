classdef TestCell < matlab.unittest.TestCase
   
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

			% TODO: Make this work with arbitrary order of elements
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

			d = c.Divide();

			testCase.verifyEqual(c.nodeTopLeft.position,[0.5, 1]);
			testCase.verifyEqual(c.nodeTopRight.position,[1, 1]);
			testCase.verifyEqual(c.nodeBottomLeft.position,[0.5, 0]);
			testCase.verifyEqual(c.nodeBottomRight.position,[1, 0]);

			testCase.verifyEqual(d.nodeTopLeft.position,[0, 1]);
			testCase.verifyEqual(d.nodeTopRight.position,[0.5, 1]);
			testCase.verifyEqual(d.nodeBottomLeft.position,[0, 0]);
			testCase.verifyEqual(d.nodeBottomRight.position,[0.5, 0]);

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

			% TODO: Make this work with arbitrary order of elements
			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyTrue(c.IsPointInsideCell([0.5, 0.5]));
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

			n2.NewPosition([0.5,0.5]);
			n4.NewPosition([0.5,1]);
			testCase.verifyFalse(c.HasEdgeFlipped());

			n2.NewPosition([1,0.5]);
			n4.NewPosition([1,1]);
			testCase.verifyTrue(c.HasEdgeFlipped());

			n2.NewPosition([1,1]);
			n4.NewPosition([0,1]);
			testCase.verifyTrue(c.HasEdgeFlipped());

		end

	end

end