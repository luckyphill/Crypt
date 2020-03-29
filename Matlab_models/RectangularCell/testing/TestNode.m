classdef TestNode < matlab.unittest.TestCase
   
	methods (Test)

		function TestProperties(testCase)

			n = Node(1,2,3);
			testCase.verifyEqual(n.x,1);
			testCase.verifyEqual(n.y,2);
			testCase.verifyEqual(n.id,3);
			testCase.verifyEqual(n.position,[1,2]);
			testCase.verifyEqual(n.force,[0,0]);

		end

		function TestMoveNode(testCase)

			% Test moving by specifying position
			n = Node(1,1,3);
			n.NewPosition([2,2]);
			testCase.verifyEqual(n.position,[2, 2]);
			testCase.verifyEqual(n.x,2);
			testCase.verifyEqual(n.y,2);


			% Test moving from a force
			n = Node(1,1,3);
			n.AddForceContribution([1,1]);
			testCase.verifyEqual(n.force,[1,1]);

			dt = 0.01;
			eta = 1;

			n.UpdatePosition(dt/eta);

			testCase.verifyEqual(n.position,[1.01, 1.01]);
			testCase.verifyEqual(n.x,1.01);
			testCase.verifyEqual(n.y,1.01);
			testCase.verifyEqual(n.force,[0,0]);

			% Move node using move method
			% This resets the force on the node also
			n = Node(1,1,3);
			n.MoveNode([2,2]);
			testCase.verifyEqual(n.position,[2, 2]);
			testCase.verifyEqual(n.x,2);
			testCase.verifyEqual(n.y,2);
			testCase.verifyEqual(n.force,[0,0]);

		end

		function TestPointToElement(testCase)

			n1 = Node(1,1,1);
			n2 = Node(2,1,2);

			e = Element(n1,n2,1);

			testCase.verifyEqual(n1.elementList, e);
			testCase.verifyEqual(n2.elementList, e);

			% Remove the element from both lists
			n1.RemoveElement(e);
			n2.RemoveElement(e);
			testCase.verifyEmpty(n1.elementList);
			testCase.verifyEmpty(n2.elementList);
		end



	end
end
