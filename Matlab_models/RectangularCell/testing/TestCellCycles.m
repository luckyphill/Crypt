classdef TestCellCycles < matlab.unittest.TestCase
   
	methods (Test)

		function TestNoCellCycle(testCase)

			ccm = NoCellCycle();

			testCase.verifyFalse(ccm.IsReadyToDivide());
			testCase.verifyEquals(ccm.GetGrowthPhaseFraction());
			testCase.verifyClass(ccm.Duplicate(), 'NoCellCycle');

		end

		function TestSimplePhaseBasedCellCycle(testCase)

			ccm = SimplePhaseBasedCellCycle(20,10);




		end

	end

end