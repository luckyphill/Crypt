classdef TestCell < matlab.unittest.TestCase
   
	methods (Test)

		function TestProperties(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			e1 = Element(n1,n2,1);
			e2 = Element(n1,n3,2);
			e3 = Element(n2,n4,3);
			e4 = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(e2, e4, e3, e1, 1);


			testCase.verifyEqual(c.id,1);

			testCase.verifyEqual(c.elementTop,e3);
			testCase.verifyEqual(c.elementBottom,e2);
			testCase.verifyEqual(c.elementLeft,e4);
			testCase.verifyEqual(c.elementRight,e1);

			testCase.verifyEqual(c.nodeTopLeft,n2);
			testCase.verifyEqual(c.nodeTopRight,n4);
			testCase.verifyEqual(c.nodeBottomLeft,n1);
			testCase.verifyEqual(c.nodeBottomRight,n3);

			testCase.verifyEqual(c.targetCellArea, 1);
			testCase.verifyEqual(c.deformationEnergyParameter,1);

		end


		function TestArea(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			e1 = Element(n1,n2,1);
			e2 = Element(n1,n3,2);
			e3 = Element(n2,n4,3);
			e4 = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(e2, e4, e3, e1, 1);


			c.UpdateCellArea();

			testCase.verifyEqual(c.cellArea, 1);

			% Test a different shape
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1.1,1.1,4);

			e1 = Element(n1,n2,1);
			e2 = Element(n1,n3,2);
			e3 = Element(n2,n4,3);
			e4 = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(e2, e4, e3, e1, 1);


			c.UpdateCellArea();

			testCase.verifyEqual(c.cellArea, 1.1);

		end

		function TestForces(testCase)
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1.1,1.1,4);

			e1 = Element(n1,n2,1);
			e2 = Element(n1,n3,2);
			e3 = Element(n2,n4,3);
			e4 = Element(n3,n4,4);

			% TODO: Make this work with arbitrary order of elements
			c = Cell(e2, e4, e3, e1, 1);

			c.UpdateAreaGradientAtNode();

			testCase.verifyEqual(c.areaGradientTopLeft,[0.55,-0.55]);
			testCase.verifyEqual(c.areaGradientTopRight,[-0.5,-0.5]);
			testCase.verifyEqual(c.areaGradientBottomLeft,[0.5,0.5]);
			testCase.verifyEqual(c.areaGradientBottomRight,[-0.55,0.55]);

			c.UpdateForce();
			
			testCase.verifyEqual(c.nodeTopLeft.force,[0.11,-0.11]);
			testCase.verifyEqual(c.nodeTopRight.force,[-0.11,-0.11]);
			testCase.verifyEqual(c.nodeBottomLeft.force,[0.11,0.11]);
			testCase.verifyEqual(c.nodeBottomRight.force,[-0.11,0.11]);

		end

	end

end