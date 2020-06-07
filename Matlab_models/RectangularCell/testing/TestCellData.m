classdef TestCellData < matlab.unittest.TestCase
	
	methods (Test)


		function TestCellArea(testCase)

			% To Do

		end

		function TestCellAreaSquare(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(c.cellData('cellArea').GetData(c), 1);

			% Test a different shape
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1.1,1.1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(c.cellData('cellArea').GetData(c), 1.1);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(c.cellData('cellArea').GetData(c), 1.1);

		end

		function TestCellPerimeter(testCase)

			% Test a bunch of different shapes and see that the perimeter
			% is correct for all cell types
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('cellPerimeter').GetData(c), 4);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('cellPerimeter').GetData(c), 4);

		end

		function TestTargetArea(testCase)

			% Test a bunch of different shapes and see that the perimeter
			% is correct for all cell types
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(c.cellData('targetArea').GetData(c), 1);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(c.cellData('targetArea').GetData(c), 1);


			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.SetAge(2);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;

			testCase.verifyEqual(ccm.GetAge(), 2);

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.GetAge(), 2);
			testCase.verifyEqual(c.cellData('targetArea').GetData(c), 0.5);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('targetArea').GetData(c), 0.5);

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;
			ccm.SetAge(8);

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('targetArea').GetData(c), 0.8);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('targetArea').GetData(c), 0.8);

		end

		function TestTargetPerimeterSquare(testCase)

			% Almost identical to test target area
			% With NoCellCycle
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(c.cellData('targetPerimeter').GetData(c), 4);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(c.cellData('targetPerimeter').GetData(c), 4);


			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.SetAge(2);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;

			testCase.verifyEqual(ccm.GetAge(), 2);

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.GetAge(), 2);
			testCase.verifyEqual(c.cellData('targetPerimeter').GetData(c), 3);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('targetPerimeter').GetData(c), 3);

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;
			ccm.SetAge(8);

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('targetPerimeter').GetData(c), 3.6);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			testCase.verifyEqual(c.cellData('targetPerimeter').GetData(c), 3.6);

		end


	end


end