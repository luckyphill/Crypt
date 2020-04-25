classdef TestNode < matlab.unittest.TestCase
   
	methods (Test)

		function TestProperties(testCase)

			n = Node(1,2,3);
			testCase.verifyEqual(n.x,1);
			testCase.verifyEqual(n.y,2);
			testCase.verifyEqual(n.id,3);
			testCase.verifyEqual(n.position,[1,2]);
			testCase.verifyEqual(n.force,[0,0]);
			testCase.verifyEqual(n.previousForce,[0,0]);

			testCase.verifyEmpty(n.isTopNode);
			testCase.verifyEmpty(n.elementList);
			testCase.verifyEmpty(n.cellList);

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

		function TestPointToElementAndCell(testCase)


			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);


			testCase.verifyTrue(ismember(el,n1.elementList));
			testCase.verifyTrue(ismember(el,n2.elementList));

			testCase.verifyTrue(ismember(eb,n1.elementList));
			testCase.verifyTrue(ismember(eb,n3.elementList));

			testCase.verifyTrue(ismember(et,n4.elementList));
			testCase.verifyTrue(ismember(et,n2.elementList));

			testCase.verifyTrue(ismember(er,n3.elementList));
			testCase.verifyTrue(ismember(er,n4.elementList));

			testCase.verifyTrue(ismember(c,n1.cellList));
			testCase.verifyTrue(ismember(c,n2.cellList));

			testCase.verifyTrue(n2.isTopNode);
			testCase.verifyTrue(n4.isTopNode);

			testCase.verifyFalse(n1.isTopNode);
			testCase.verifyFalse(n3.isTopNode);

			% Remove the element from both lists
			n1.RemoveElement(el);
			n2.RemoveElement(el);

			testCase.verifyFalse(ismember(el,n1.elementList));
			testCase.verifyFalse(ismember(el,n2.elementList));

			testCase.verifyTrue(ismember(c,n1.cellList));
			testCase.verifyTrue(ismember(c,n2.cellList));

			n1.RemoveElement(er);
			n2.RemoveElement(er);
			n1.RemoveElement(eb);
			n2.RemoveElement(eb);
			n1.RemoveElement(et);
			n2.RemoveElement(et);

			testCase.verifyEmpty(n1.elementList);
			testCase.verifyEmpty(n2.elementList);

			testCase.verifyEmpty(n1.cellList);
			testCase.verifyEmpty(n2.cellList);
		end



	end
end
