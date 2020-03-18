classdef TestElement < matlab.unittest.TestCase
   
	methods (Test)

		function TestProperties(testCase)
			n1 = Node(1,1,1);
			n2 = Node(2,1,2);

			e = Element(n1,n2,1);

			testCase.verifyEqual(e.id,1);
			testCase.verifyEqual(e.naturalLength,1);
			testCase.verifyEqual(e.stiffness,10);

			testCase.verifyEqual(e.Node1, n1);
			testCase.verifyEqual(e.Node2, n2);

			e.SetNaturalLength(23.4);
			testCase.verifyEqual(e.naturalLength,23.4);
			e.SetStiffness(23.4);
			testCase.verifyEqual(e.stiffness,23.4);

			testCase.verifyEqual(e.GetLength(), 1);

		end

		function TestApplyForce(testCase)
			n1 = Node(1,1,1);
			n2 = Node(2,1,2);

			e = Element(n1,n2,1);

			e.SetNaturalLength(2);
			e.SetStiffness(2);

			e.UpdateForce();

			testCase.verifyEqual(e.dx, 1);
			testCase.verifyEqual(e.force, 2);

			testCase.verifyEqual(e.direction1to2, [1,0]);
			testCase.verifyEqual(e.force1to2, [2,0]);

		end

	end

end
