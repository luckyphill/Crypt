classdef TestCellCycles < matlab.unittest.TestCase
   
	methods (Test)

		function TestNoCellCycle(testCase)

			% COMPLETE
			ccm = NoCellCycle();

			testCase.verifyEqual(ccm.GetAge(), 0);
			ccm.SetAge(10);
			testCase.verifyEqual(ccm.GetAge(), 10);
			ccm.AgeCellCycle(1);
			testCase.verifyEqual(ccm.GetAge(), 11);

			testCase.verifyEqual(ccm.GetColour, ccm.PAUSE);

			% NoCellCycle will never divide
			testCase.verifyFalse(ccm.IsReadyToDivide());
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 1);

			newCCM = ccm.Duplicate();
			testCase.verifyClass(newCCM, 'NoCellCycle');

			testCase.verifyEqual(newCCM.GetAge(), 0);
			testCase.verifyEqual(newCCM.GetColour, newCCM.PAUSE);
			testCase.verifyFalse(newCCM.IsReadyToDivide());
			testCase.verifyEqual(newCCM.GetGrowthPhaseFraction(), 1);

		end

		function TestSimplePhaseBasedCellCycle(testCase)

			% INCOMPLETE
			% Missing tests:
			% 1. Check the actual assigned phase lengths (they are normally distributed)


			ccm = SimplePhaseBasedCellCycle(20,10);

			% First check the things that are set on construction
			% checking obj.SetAge(randi(p - 1));
			testCase.verifyLessThan(ccm.GetAge(), 20);

			testCase.verifyEqual(ccm.meanPausePhaseLength, 20);
			testCase.verifyEqual(ccm.meanGrowingPhaseLength, 10);
			testCase.verifyEqual(ccm.GetColour, ccm.PAUSE);

			% Need some way to check the assigned phase lengths

			% Set some specific phase lengths to test division and 
			% growth stuff
			ccm.pausePhaseLength = 20;
			ccm.growingPhaseLength = 10;
			ccm.SetAge(10);

			% At this age, it is not ready to divide, and is not growing
			testCase.verifyEqual(ccm.GetAge(), 10);
			testCase.verifyFalse(ccm.IsReadyToDivide());
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 0);
			
			% Colour change is only triggered by aging the cell cycle
			ccm.AgeCellCycle(1);
			testCase.verifyEqual(ccm.GetColour, ccm.PAUSE);

			% At this age, cell is growing but is not ready to divide
			ccm.SetAge(25);

			testCase.verifyEqual(ccm.GetAge(), 25);
			testCase.verifyFalse(ccm.IsReadyToDivide());

			fraction = (25 - ccm.pausePhaseLength) / ccm.growingPhaseLength;
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), fraction);

			% Colour change is only triggered by aging the cell cycle
			ccm.AgeCellCycle(1);
			testCase.verifyEqual(ccm.GetColour, ccm.GROW);

			% At this age, is ready to divide
			ccm.SetAge(35);
			testCase.verifyEqual(ccm.GetAge(), 35);
			testCase.verifyTrue(ccm.IsReadyToDivide());


			% Test the duplicate ccm

			newCCM = ccm.Duplicate();
			testCase.verifyEqual(newCCM.GetAge(), 0);
			testCase.verifyFalse(newCCM.IsReadyToDivide());
			testCase.verifyEqual(newCCM.GetGrowthPhaseFraction(), 0);

			testCase.verifyEqual(newCCM.meanPausePhaseLength, 20);

			testCase.verifyEqual(newCCM.meanGrowingPhaseLength, 10);
			testCase.verifyEqual(newCCM.GetColour, newCCM.PAUSE);




		end

	end

end