classdef TestSquareCellJoined < matlab.unittest.TestCase

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

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			c.deformationEnergyParameter = 1;

			testCase.verifyEqual(c.id,1);
			testCase.verifyEqual(c.ancestorId,1);

			testCase.verifyEqual(c.elementTop,et);
			testCase.verifyEqual(c.elementBottom,eb);
			testCase.verifyEqual(c.elementLeft,el);
			testCase.verifyEqual(c.elementRight,er);

			testCase.verifyEqual(c.nodeTopLeft,n2);
			testCase.verifyEqual(c.nodeTopRight,n4);
			testCase.verifyEqual(c.nodeBottomLeft,n1);
			testCase.verifyEqual(c.nodeBottomRight,n3);

		end

		function TestAccessData(testCase)

			% Test that the area and perimeter data can be accessed

			% At one point, the AbstractCellData approach to handling
			% the data only accessed on class instance for every cell
			% so need to check that each cell gets a unique value

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c1 = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);


			n1 = Node(0,0,1);
			n2 = Node(0,0.5,2);
			n3 = Node(1,0,3);
			n4 = Node(1,0.5,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c2 = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			c2.newCellTargetArea = 0.5;
			c2.grownCellTargetArea = 0.5;

			testCase.verifyEqual(c1.GetCellArea(), 1);
			testCase.verifyEqual(c1.GetCellTargetArea(), 1);

			testCase.verifyEqual(c1.GetCellPerimeter(), 4);
			testCase.verifyEqual(c1.GetCellTargetPerimeter(), 4);


			testCase.verifyEqual(c2.GetCellArea(), 0.5);
			testCase.verifyEqual(c2.GetCellTargetArea(), 0.5);

			testCase.verifyEqual(c2.GetCellPerimeter(), 3);
			testCase.verifyEqual(c2.GetCellTargetPerimeter(), 3);


		end

	end

end