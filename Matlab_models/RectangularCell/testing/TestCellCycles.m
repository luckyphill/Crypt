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

		function TestLinearGrowthCellCycle(testCase)


			dt = 0.05;

			ccm = LinearGrowthCellCycle(5, 10, 15, 0.9, dt	);


			% Check all the initialising
			testCase.verifyEqual(ccm.meanGrowthPeriodStart, 5);
			testCase.verifyEqual(ccm.meanGrowthPeriodEnd, 10);
			testCase.verifyEqual(ccm.meanMinimumDivisionAge, 15);

			testCase.verifyEqual(ccm.minimumDivisionFraction, 0.9);

			testCase.verifyEqual(ccm.dt, dt);

			testCase.verifyEqual(ccm.growthPeriodStart, 5);
			testCase.verifyEqual(ccm.growthPeriodEnd, 10);
			testCase.verifyEqual(ccm.minimumDivisionAge, 15);

			testCase.verifyEqual(ccm.stochasticGrowthStart, false);
			testCase.verifyEqual(ccm.stochasticGrowthEnd, false);
			testCase.verifyEqual(ccm.stochasticDivisionAge, false);

			testCase.verifyEqual(ccm.useRandomTrial, false);
			testCase.verifyEmpty(ccm.funcRandomVariable);
			testCase.verifyEmpty(ccm.randomThreshold);

			testCase.verifyGreaterThanOrEqual(ccm.age, 0);
			testCase.verifyLessThanOrEqual(ccm.age, 5);

			% Test that turning on stochasticity resets the relevant values
			ccm.stochasticGrowthStart = true;
			ccm.stochasticGrowthEnd = true;
			ccm.stochasticDivisionAge = true;

			% This should pass almost surely. There's the exceptionally unlikely chance
			% that the randomly chosen number is precisely the original, but it's so rare
			% that it's not worth accounting for. If it does happen, just rerun the test
			% If the same test(s) repeatedly fail, then something is definitely wrong
			testCase.verifyNotEqual(ccm.growthPeriodStart, 5);
			testCase.verifyNotEqual(ccm.growthPeriodEnd, 10);
			testCase.verifyNotEqual(ccm.minimumDivisionAge, 15);

			% Test that the actual values fall in the range given by the uniform distribution
			% This will not be relevant if the hard coded range changes (TODO: unhardcode it)
			testCase.verifyGreaterThanOrEqual(ccm.growthPeriodStart, 3);
			testCase.verifyLessThanOrEqual(ccm.growthPeriodStart, 7);

			testCase.verifyGreaterThanOrEqual(ccm.growthPeriodEnd, 8);
			testCase.verifyLessThanOrEqual(ccm.growthPeriodEnd, 12);

			testCase.verifyGreaterThanOrEqual(ccm.minimumDivisionAge, 13);
			testCase.verifyLessThanOrEqual(ccm.minimumDivisionAge, 17);

			% The mean values shuold be unchanged
			testCase.verifyEqual(ccm.meanGrowthPeriodStart, 5);
			testCase.verifyEqual(ccm.meanGrowthPeriodEnd, 10);
			testCase.verifyEqual(ccm.meanMinimumDivisionAge, 15);


			% Test that turning it off again reverts the values to the mean
			ccm.stochasticGrowthStart = false;
			ccm.stochasticGrowthEnd = false;
			ccm.stochasticDivisionAge = false;

			testCase.verifyEqual(ccm.growthPeriodStart, 5);
			testCase.verifyEqual(ccm.growthPeriodEnd, 10);
			testCase.verifyEqual(ccm.minimumDivisionAge, 15);


			% Put the ccm in a cell for the following tests

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(0.5,0,3);
			n4 = Node(0.5,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = LinearGrowthCellCycle(5, 10, 15, 0.9, dt);

			% No particular reason for using this cell type, but there should
			% be no difference which ever is used
			c = SquareCellJoined(ccm, [et,eb,el,er], 1);


			% Test the correct growth fractions are returned
			% and the correct division readiness state
			% This will require the size of the cell to satisfy the
			% contact inhibition requirements

			% The cycle will start in the pre-growth period
			ccm.SetAge(0);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 0 );

			ccm.SetAge(6);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 0.2 );
			testCase.verifyFalse(ccm.IsReadyToDivide);

			ccm.SetAge(7);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 0.4 );
			testCase.verifyFalse(ccm.IsReadyToDivide);

			ccm.SetAge(8);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 0.6 );
			testCase.verifyFalse(ccm.IsReadyToDivide);

			ccm.SetAge(9);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 0.8 );
			testCase.verifyFalse(ccm.IsReadyToDivide);

			ccm.SetAge(10);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 1 );
			testCase.verifyFalse(ccm.IsReadyToDivide);

			ccm.SetAge(12);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 1 );
			testCase.verifyFalse(ccm.IsReadyToDivide);

			% At this point it will be old enough to divide, but it hasn't grown
			% so the area will be too small
			ccm.SetAge(16);
			testCase.verifyEqual(c.GetCellArea(), 0.5);
			testCase.verifyEqual(c.GetCellTargetArea(), 1);
			testCase.verifyEqual(ccm.GetGrowthPhaseFraction(), 1 );
			testCase.verifyFalse(ccm.IsReadyToDivide);

			% Move the nodes a bit but the cell is still not large enough
			n3.MoveNode([0.85, 0]);
			n4.MoveNode([0.85, 1]);
			c.AgeCell(dt); % Necessary because the new area will only be calculated on new timesteps
			testCase.verifyEqual(c.GetCellArea(), 0.85);
			testCase.verifyEqual(c.GetCellTargetArea(), 1);
			testCase.verifyFalse(ccm.IsReadyToDivide);

			% Move the nodes to make the cell bigger than the limit
			n3.MoveNode([0.95, 0]);
			n4.MoveNode([0.95, 1]);
			c.AgeCell(dt);
			testCase.verifyEqual(c.GetCellArea(), 0.95);
			testCase.verifyEqual(c.GetCellTargetArea(), 1);
			testCase.verifyTrue(ccm.IsReadyToDivide);


			% Now we test the random trial division

			func = @rand;

			ccm.SetRandomTrialDivisionCondition(func, 0);

			% Test that is assigns correctly and returns flase for division
			testCase.verifyTrue(ccm.useRandomTrial);
			testCase.verifyEqual(ccm.funcRandomVariable, func);
			testCase.verifyEqual(ccm.randomThreshold, 0);
			testCase.verifyFalse(ccm.IsReadyToDivide);

			% And test that it returns true
			ccm.SetRandomTrialDivisionCondition(func, 1/dt);
			testCase.verifyTrue(ccm.useRandomTrial);
			testCase.verifyEqual(ccm.funcRandomVariable, func);
			testCase.verifyEqual(ccm.randomThreshold, 1/dt);
			testCase.verifyTrue(ccm.IsReadyToDivide);


			% Now test the error cases

			testCase.verifyWarning(@()LinearGrowthCellCycle(5, 6, 15, 0.9, dt), "LinearGrowthCellCycle:ShortGrowthWarning", 'No short growth warning');
			testCase.verifyError(@()LinearGrowthCellCycle(5, 5, 15, 0.9, dt), "LinearGrowthCellCycle:MilestoneError", 'No Milestone error');
			testCase.verifyError(@()LinearGrowthCellCycle(5, 10, 8, 0.9, dt), "LinearGrowthCellCycle:MilestoneError", 'No Milestone error');
			testCase.verifyError(@()LinearGrowthCellCycle(5, 10, 4, 0.9, dt), "LinearGrowthCellCycle:MilestoneError", 'No Milestone error');

			% This should be fine
			ccm = LinearGrowthCellCycle(5, 10, 10, 0.9, dt);
			testCase.verifyEqual(ccm.growthPeriodEnd, 10);
			testCase.verifyEqual(ccm.minimumDivisionAge, 10);

			% Finally, test cell cycle duplication
			% First test it without stochasticity on the milestones
			ccm = LinearGrowthCellCycle(5, 10, 15, 0.9, dt);

			newCCM = ccm.Duplicate();

			% The original cell cycle returns to age 0 
			testCase.verifyEqual(ccm.age, 0);


			% And the new cycle is intiialised properly
			testCase.verifyEqual(newCCM.age, 0);

			testCase.verifyEqual(newCCM.meanGrowthPeriodStart, 5);
			testCase.verifyEqual(newCCM.meanGrowthPeriodEnd, 10);
			testCase.verifyEqual(newCCM.meanMinimumDivisionAge, 15);

			testCase.verifyEqual(newCCM.minimumDivisionFraction, 0.9);

			testCase.verifyEqual(newCCM.dt, dt);

			testCase.verifyEqual(newCCM.growthPeriodStart, 5);
			testCase.verifyEqual(newCCM.growthPeriodEnd, 10);
			testCase.verifyEqual(newCCM.minimumDivisionAge, 15);

			testCase.verifyEqual(newCCM.stochasticGrowthStart, false);
			testCase.verifyEqual(newCCM.stochasticGrowthEnd, false);
			testCase.verifyEqual(newCCM.stochasticDivisionAge, false);

			testCase.verifyEqual(newCCM.useRandomTrial, false);
			testCase.verifyEmpty(newCCM.funcRandomVariable);
			testCase.verifyEmpty(newCCM.randomThreshold);

			

			% Now turn on stochasticity and check that things vary properly after duplication
			ccm = LinearGrowthCellCycle(5, 10, 15, 0.9, dt);

			ccm.stochasticGrowthStart = true;
			ccm.stochasticGrowthEnd = true;
			ccm.stochasticDivisionAge = true;

			s = ccm.growthPeriodStart;
			e = ccm.growthPeriodEnd;
			a = ccm. minimumDivisionAge;


			newCCM = ccm.Duplicate();


			% First check that the original cell cycle has changed
			testCase.verifyEqual(ccm.age, 0);

			% This could in very rare instances fail because the process is random
			testCase.verifyNotEqual(ccm.growthPeriodStart, s);
			testCase.verifyNotEqual(ccm.growthPeriodEnd, e);
			testCase.verifyNotEqual(ccm.minimumDivisionAge, a);

			testCase.verifyTrue(ccm.stochasticGrowthStart);
			testCase.verifyTrue(ccm.stochasticGrowthEnd);
			testCase.verifyTrue(ccm.stochasticDivisionAge);

			% And check that the new cycle is correct

			testCase.verifyTrue(newCCM.stochasticGrowthStart);
			testCase.verifyTrue(newCCM.stochasticGrowthEnd);
			testCase.verifyTrue(newCCM.stochasticDivisionAge);

			% This will also fail in rare circumstances
			testCase.verifyNotEqual(newCCM.growthPeriodStart, 5);
			testCase.verifyNotEqual(newCCM.growthPeriodEnd, 10);
			testCase.verifyNotEqual(newCCM.minimumDivisionAge, 15);






		end

	end

end