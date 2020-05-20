classdef TestElement < matlab.unittest.TestCase
   
	methods (Test)

		function TestProperties(testCase)
			n1 = Node(1,1,1);
			n2 = Node(2,1,2);

			n1.SetDragCoefficient(1);
			n2.SetDragCoefficient(1);

			e = Element(n1,n2,1);

			testCase.verifyEqual(e.id,1);
			testCase.verifyEqual(e.naturalLength,1);
			testCase.verifyEqual(e.GetLength(),1);

			testCase.verifyEqual(e.Node1, n1);
			testCase.verifyEqual(e.Node2, n2);

			testCase.verifyEqual(e.GetOtherNode(n2), n1);
			testCase.verifyEqual(e.GetOtherNode(n1), n2);

			e.SetNaturalLength(23.4);
			testCase.verifyEqual(e.naturalLength,23.4);
			testCase.verifyEqual(e.GetNaturalLength(),23.4);

			testCase.verifyEqual(e.GetLength(), 1);

			testCase.verifyEqual(e.GetVector1to2(), [1, 0]);
			testCase.verifyEqual(e.GetMidPoint(), [1.5,1]);

		end

		function TestReplaceNode(testCase)
			n1 = Node(1,1,1);
			n2 = Node(2,1,2);

			e = Element(n1,n2,1);

			testCase.verifyEqual(e.Node1, n1);
			testCase.verifyEqual(e.Node2, n2);

			n3 = Node(1.5,1,3);

			e.ReplaceNode(n2, n3);

			testCase.verifyEqual(e.Node1, n1);
			testCase.verifyEqual(e.Node2, n3);

			e.ReplaceNode(n1, n2);
			testCase.verifyEqual(e.Node1, n2);

			testCase.verifyWarning(@()e.ReplaceNode(n2,n2), 'e:sameNode', 'no warning from replace node');

			testCase.verifyError(@()e.ReplaceNode(n1,n2), 'e:nodeNotFound', 'no error from replace node');

		end


	end

end
