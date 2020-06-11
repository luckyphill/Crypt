classdef TestCellData < matlab.unittest.TestCase
	% Tests the cell data works correctly
	methods (Test)

		function TestBasicFunctions(testCase)

			% COMPLETE
			% Use a concrete class to test functionality in Abstract
			% As long as it works here, no need to recheck in the following tests
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			cA = CellAreaSquare();

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			testCase.verifyEqual(cA.ageStamp, -1);

			cA.GetData(c);

			% Age will now be intial age from ccm
			testCase.verifyEqual(cA.ageStamp, 0);

			% Age has been set, so will only get area from cA.data
			cA = cA;
			cA.data = 11;
			testCase.verifyEqual(cA.GetData(c), 11);

			% After aging, will recalculate the data
			c.CellCycleModel.AgeCellCycle(1);
			testCase.verifyEqual(cA.GetData(c), 1);

		end

		function TestCellArea(testCase)

			% COMPLETE
			% Implicitly tests the name field
			% CellArea only valid for CellFree
			% Test area was copied from the actual calculation

			% Calculate area for a generic polygon
			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			c = CellFree(NoCellCycle, nodes, 1);

			cA = CellArea();

			% Just copied the actual calcualted answer, this will only
			% flag an error if the calculation method drastically changes
			testCase.verifyEqual(cA.GetData(c), 0.470228201833979, 'RelTol', 1e-4);

		end

		function TestCellAreaSquare(testCase)

			% COMPLETE
			% Implicitly tests the name field
			% CellAreaSquare valid for SquareCellJoined and SquareCellFree

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			cA1 = CellAreaSquare();

			testCase.verifyEqual(cA1.GetData(c), 1);

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

			% Need to de this to avoid triggering the age stamp
			cA2 = CellAreaSquare();

			testCase.verifyEqual(cA2.GetData(c), 1.1);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);

			cA3 = CellAreaSquare();

			testCase.verifyEqual(cA3.GetData(c), 1.1);

		end

		function TestCellPerimeter(testCase)

			% COMPLETE
			% Implicitly tests the name field
			% CellPerimeter valid for CellFree, SquareCellJoined and SquareCellFree
			
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
			cP1 = CellPerimeter();
			testCase.verifyEqual(cP1.GetData(c), 4);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);
			cP2 = CellPerimeter();
			testCase.verifyEqual(cP2.GetData(c), 4);

			n = 10;
			pgon = nsidedpoly(n, 'SideLength', 0.5);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			c = CellFree(NoCellCycle, nodes, 1);
			cP3 = CellPerimeter();
			testCase.verifyEqual(cP3.GetData(c), 5);

		end

		function TestTargetArea(testCase)


			% COMPLETE
			% Implicitly tests the name field
			% TargetArea valid for CellFree, SquareCellJoined and SquareCellFree
			% TargetArea depends on the cell cycle, so need to test at least one
			% cell cycle that modifies the target area

			%----------------------------
			% Test Square Cells
			%----------------------------

			% Test no cell cycle
			%----------------------------
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);
			tA1 = TargetArea();
			testCase.verifyEqual(tA1.GetData(c), 1);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);
			tA2 = TargetArea();
			testCase.verifyEqual(tA2.GetData(c), 1);


			% Test Phase Base Cycle
			%----------------------------

			% Pause Phase

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

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			tA3 = TargetArea();
			testCase.verifyEqual(tA3.GetData(c), 0.5);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			tA4 = TargetArea();
			testCase.verifyEqual(tA4.GetData(c), 0.5);

			% Growing Phase

			% From here ***
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
			% To here ***
			% should be able to be cut out, but can't because something becomes
			% unsealed in Matlab terminology:
			% Error using  == 
			% Unable to call method 'eq' because one or more inputs of class 'SquareCellJoined'
			% are heterogeneous and 'eq' is not sealed.  For more details please see the method
			% dispatching rules for heterogeneous arrays.

			ccm.SetAge(8);

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			tA5 = TargetArea();
			testCase.verifyEqual(tA5.GetData(c), 0.8);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			tA6 = TargetArea();
			testCase.verifyEqual(tA6.GetData(c), 0.8);


			%----------------------------
			% Test General Cell
			%----------------------------

			% Test no cell cycle
			%----------------------------

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			c = CellFree(NoCellCycle, nodes, 1);
			tA7 = TargetArea();
			testCase.verifyEqual(tA7.GetData(c), 1);


			% Test Phase Base Cycle
			%----------------------------

			% Pause Phase

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;
			ccm.SetAge(2);

			c = CellFree(ccm, nodes, 1);
			tA8 = TargetArea();
			testCase.verifyEqual(tA8.GetData(c), 0.5);

			
			% Growing Phase

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;
			ccm.SetAge(8);

			c = CellFree(ccm, nodes, 1);
			tA9 = TargetArea();
			testCase.verifyEqual(tA9.GetData(c), 0.8);

		end

		function TestTargetPerimeter(testCase)


			% COMPLETE
			% Implicitly tests the name field
			% TargetPerimeter valid for CellFree only
			% TargetPerimeter depends on the cell cycle, so need to test at least one
			% cell cycle that modifies the target area
			% Test perimeter was copied from the actual calculation

			%----------------------------
			% Test General Cell
			%----------------------------

			% Test no cell cycle
			%----------------------------

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			c = CellFree(NoCellCycle, nodes, 1);
			tA7 = TargetPerimeter();
			testCase.verifyEqual(tA7.GetData(c), 3.60510580279085, 'RelTol', 1e-4);


			% Test Phase Base Cycle
			%----------------------------

			% Pause Phase

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;
			ccm.SetAge(2);

			c = CellFree(ccm, nodes, 1);
			tA8 = TargetPerimeter();
			testCase.verifyEqual(tA8.GetData(c), 2.54919476004838, 'RelTol', 1e-4);

			
			% Growing Phase

			n = 10;
			pgon = nsidedpoly(n, 'Radius', 0.4);
			v = flipud(pgon.Vertices);

			nodes = Node.empty();

			for i = 1:n
				nodes(i) = Node(v(i,1),v(i,2),i);
			end

			ccm = SimplePhaseBasedCellCycle(5, 5);
			ccm.pausePhaseLength = 5;
			ccm.growingPhaseLength = 5;
			ccm.SetAge(8);

			c = CellFree(ccm, nodes, 1);
			tA9 = TargetPerimeter();
			testCase.verifyEqual(tA9.GetData(c), 3.22450465644772, 'RelTol', 1e-4);

		end

		function TestTargetPerimeterSquare(testCase)


			% COMPLETE
			% TargetPerimeterSquare valid for SquareCellFree and SquareCellJoined
			% TargetPerimeterSquare depends on the cell cycle, so need to test at least one
			% cell cycle that modifies the target area


			% Test no cell cycle
			%----------------------------
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);
			tA1 = TargetPerimeterSquare();
			testCase.verifyEqual(tA1.GetData(c), 4);

			c = SquareCellFree(NoCellCycle, [et,eb,el,er], 1);
			tA2 = TargetPerimeterSquare();
			testCase.verifyEqual(tA2.GetData(c), 4);


			% Test Phase Base Cycle
			%----------------------------

			% Pause Phase

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

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			tA3 = TargetPerimeterSquare();
			testCase.verifyEqual(tA3.GetData(c), 3);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			tA4 = TargetPerimeterSquare();
			testCase.verifyEqual(tA4.GetData(c), 3);

			% Growing Phase

			% From here ***
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
			% To here ***
			% should be able to be cut out, but can't because something becomes
			% unsealed in Matlab terminology:
			% Error using  == 
			% Unable to call method 'eq' because one or more inputs of class 'SquareCellJoined'
			% are heterogeneous and 'eq' is not sealed.  For more details please see the method
			% dispatching rules for heterogeneous arrays.

			ccm.SetAge(8);

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);
			tA5 = TargetPerimeterSquare();
			testCase.verifyEqual(tA5.GetData(c), 3.6);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);
			tA6 = TargetPerimeterSquare();
			testCase.verifyEqual(tA6.GetData(c), 3.6);

		end

	end

end