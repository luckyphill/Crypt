classdef TestSimulationData < matlab.unittest.TestCase
   
	methods (Test)

		function TestBoundaryCells(testCase)

			% A candidate simulation
			t = CellGrowing(20,5,5,20,10,1,10);

			BC = BoundaryCells();

			testCase.verifyEmpty(BC.data);

			b = BC.GetData(t);

			testCase.verifyEqual(b('left'), t.cellList(1));
			testCase.verifyEqual(b('right'), t.cellList(end));


		end

		function TestCentreLine(testCase)

			% A candidate simulation
			t = CellGrowing(20,5,5,20,10,1,10);

			CL = CentreLine();

			testCase.verifyEmpty(CL.data);

			% This will call the setter
			% and calculate the centre line
			% It relies on BoundaryCells working
			l = CL.GetData(t);


			testCase.verifyEqual(l(1,:), [0,0.5]);
			testCase.verifyEqual(l(end,:), [10,0.5]);
			
		end

	end
end
