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

		function TestTargetAreaForce(testCase)
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

			c.deformationEnergyParameter = 1;

			c.UpdateAreaGradientAtNode();

			testCase.verifyEqual(c.areaGradientTopLeft, [0.55, -0.55]);
			testCase.verifyEqual(c.areaGradientTopRight, [-0.5, -0.5]);
			testCase.verifyEqual(c.areaGradientBottomLeft, [0.5, 0.5]);
			testCase.verifyEqual(c.areaGradientBottomRight, [-0.55, 0.55]);

			c.UpdateTargetAreaForce();
			
			testCase.verifyEqual(c.nodeTopLeft.force, [0.11, -0.11], 'RelTol', 1e-8);
			testCase.verifyEqual(c.nodeTopRight.force, [-0.1, -0.1], 'RelTol', 1e-8);
			testCase.verifyEqual(c.nodeBottomLeft.force, [0.1, 0.1], 'RelTol', 1e-8);
			testCase.verifyEqual(c.nodeBottomRight.force, [-0.11, 0.11], 'RelTol', 1e-8);


		end

		function TestTargetPerimeterForce(testCase)
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
			c.surfaceEnergyParameter = 1;

			c.UpdatePerimeterGradientAtNode();

			testCase.verifyEqual(c.elementTop, et);
			testCase.verifyEqual(c.elementRight, er);
			testCase.verifyEqual(c.elementBottom, eb);
			testCase.verifyEqual(c.elementLeft, el);

			testCase.verifyEqual(c.elementTop.GetLength(), 1.1045 ,'AbsTol', 1e-4);
			testCase.verifyEqual(c.elementRight.GetLength(), 1.1045 ,'AbsTol', 1e-4);
			testCase.verifyEqual(c.elementBottom.GetLength(), 1 ,'AbsTol', 1e-4);
			testCase.verifyEqual(c.elementLeft.GetLength(), 1 ,'AbsTol', 1e-4);

			testCase.verifyEqual(c.perimeterGradientTopLeft, [0.9959, -0.9095], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.perimeterGradientTopRight, [-1.0864, -1.0864], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.perimeterGradientBottomLeft, [1, 1], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.perimeterGradientBottomRight, [-0.9095, 0.9959], 'AbsTol', 1e-4);

			c.UpdateTargetPerimeterForce();

			testCase.verifyEqual(c.GetCellTargetPerimeter(), 4);
			testCase.verifyEqual(c.GetCellPerimeter(), 4.2090,'AbsTol', 1e-4);

			testCase.verifyEqual(c.nodeTopLeft.force, [0.4163, -0.3802], 'AbsTol', 1e-3);
			testCase.verifyEqual(c.nodeTopRight.force, [-0.4541, -.4541], 'AbsTol', 1e-3);
			testCase.verifyEqual(c.nodeBottomLeft.force, [0.418, 0.418], 'AbsTol', 1e-3);
			testCase.verifyEqual(c.nodeBottomRight.force, [-0.3802, 0.4163], 'AbsTol', 1e-3);


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

	end

end