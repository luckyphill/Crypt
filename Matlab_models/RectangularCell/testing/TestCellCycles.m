classdef TestCellCycles < matlab.unittest.TestCase
   
	methods (Test)

		function TestNoCellCycle(testCase)

			ccm = NoCellCycle();

			testCase.verifyFalse(ccm.IsReadyToDivide());
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 1);
			testCase.verifyClass(ccm.Duplicate(), 'NoCellCycle');

		end

		function TestSimplePhaseBasedCellCycle(testCase)

			ccm = SimplePhaseBasedCellCycle(20,10);

			ccm.SetAge(10);

			% At this age, it is not ready to divide, and is not growing
			testCase.verifyEqual(ccm.GetAge(), 10);
			testCase.verifyFalse(ccm.IsReadyToDivide());
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 0);

			testCase.verifyEqual(ccm.meanPausePhaseLength, 20);
			% testCase.verifyGreaterThanOrEqual(ccm.pausePhaseLength, 17);
			% testCase.verifyLessThanOrEqual(ccm.pausePhaseLength, 23);

			testCase.verifyEqual(ccm.meanGrowingPhaseLength, 10);
			% testCase.verifyGreaterThanOrEqual(ccm.growingPhaseLength, 7);
			% testCase.verifyLessThanOrEqual(ccm.growingPhaseLength, 13);

			% At this age, cell is growing but is not ready to divide
			ccm.SetAge(25);

			testCase.verifyEqual(ccm.GetAge(), 25);
			testCase.verifyFalse(ccm.IsReadyToDivide()); % << 
			% Can fail on occasion because the phases are chosen from a normal distribution

			fraction = (25 - ccm.pausePhaseLength) / ccm.growingPhaseLength;
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), fraction);

			% At this age, is read to divide
			ccm.SetAge(35);
			testCase.verifyEqual(ccm.GetAge(), 35);
			testCase.verifyTrue(ccm.IsReadyToDivide());


			% Test the duplicate ccm

			newCCM = ccm.Duplicate();
			testCase.verifyEqual(newCCM.GetAge(), 0);
			testCase.verifyFalse(newCCM.IsReadyToDivide());
			testCase.verifyEqual(newCCM.GetGrowthPhaseFraction(), 0);

			testCase.verifyEqual(newCCM.meanPausePhaseLength, 20);
			% testCase.verifyGreaterThanOrEqual(newCCM.pausePhaseLength, 17);
			% testCase.verifyLessThanOrEqual(newCCM.pausePhaseLength, 23);

			testCase.verifyEqual(newCCM.meanGrowingPhaseLength, 10);
			% testCase.verifyGreaterThanOrEqual(newCCM.growingPhaseLength, 7);
			% testCase.verifyLessThanOrEqual(newCCM.growingPhaseLength, 13);



		end

	end

end