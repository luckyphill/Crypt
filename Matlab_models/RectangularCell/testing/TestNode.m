classdef TestNode < matlab.unittest.TestCase
   
	methods (Test)

		function TestPropertiesAndInitialise(testCase)

			% COMPLETE

			n = Node(1,2,3);

			testCase.verifyEqual(n.x,1);
			testCase.verifyEqual(n.y,2);
			testCase.verifyEqual(n.id,3);
			testCase.verifyEqual(n.position,[1,2]);
			testCase.verifyEqual(n.previousPosition,[1,2]);
			testCase.verifyEqual(n.force,[0,0]);
			testCase.verifyEqual(n.previousForce,[0,0]);

			testCase.verifyEmpty(n.isTopNode);
			testCase.verifyEmpty(n.elementList);
			testCase.verifyEmpty(n.cellList);

			testCase.verifyFalse(n.nodeAdjusted);
			testCase.verifyEmpty(n.preAdjustedPosition);

			testCase.verifyEqual(n.eta, 1);

			% Move to function testing
			n.SetDragCoefficient(2);
			testCase.verifyEqual(n.eta, 2);

		end

		function TestAddForceContribution(testCase)

			% COMPLETE

			n = Node(1,1,3);

			testCase.verifyEqual(n.force,[0,0]);
			n.AddForceContribution([1,1]);
			testCase.verifyEqual(n.force,[1,1]);
			n.AddForceContribution([1,1]);
			testCase.verifyEqual(n.force,[2,2]);

			testCase.verifyError( @() n.AddForceContribution([Inf,Inf]), 'N:AddForceContribution:InfNaN');
			testCase.verifyError( @() n.AddForceContribution([nan,nan]), 'N:AddForceContribution:InfNaN');
			
		end

		function TestMoving(testCase)

 			% COMPLETE

			n = Node(1,1,3);
			n.MoveNode([2,2]);
			testCase.verifyEqual(n.position,[2, 2]);
			testCase.verifyEqual(n.previousPosition,[1,1]);
			testCase.verifyEqual(n.x,2);
			testCase.verifyEqual(n.y,2);
			testCase.verifyEqual(n.force,[0,0]);
			testCase.verifyEqual(n.previousForce,[0,0]);

			% Test moving from a force
			n = Node(1,1,3);
			n.AddForceContribution([1,1]);
			testCase.verifyEqual(n.force,[1,1]);

			dt = 0.01;
			pos = n.position + dt * n.force/n.eta;
			n.MoveNode(pos);

			testCase.verifyEqual(n.position,[1.01, 1.01]);
			testCase.verifyEqual(n.previousPosition,[1,1]);
			testCase.verifyEqual(n.x,1.01);
			testCase.verifyEqual(n.y,1.01);
			testCase.verifyEqual(n.force,[0,0]);
			testCase.verifyEqual(n.previousForce,[1,1]);


			% Test adjusting
			% Use same node as above
			n.AddForceContribution([2,2]);

			% Adjust position doesn't trigger force clearing
			n.AdjustPosition([4,4]);

			testCase.verifyEqual(n.position,[4, 4]);
			testCase.verifyEqual(n.previousPosition,[1,1]);
			testCase.verifyEqual(n.x,4);
			testCase.verifyEqual(n.y,4);
			testCase.verifyEqual(n.force,[2,2]);
			testCase.verifyEqual(n.previousForce,[1,1]);
			testCase.verifyEqual(n.preAdjustedPosition,[1.01, 1.01]);
			testCase.verifyTrue(n.nodeAdjusted);

		end

		function TestPointToElementAndCell(testCase)


			% COMPLETE
			% Node only handles it's own values, it shouldn't update
			% anything held in an element or cell, as they should be only handled
			% by the element or cell themselves. This is to fix the line of command
			% so to speak

			% Here we are only testing the function of the adding to list
			% functionality using functions in Node, not if the functions
			% from Element or Cell work properly

			% Make a cell to test with 
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c1 = Cell(NoCellCycle, [et,eb,el,er], 1);

			% Make another cell to test with

			n5 = Node(0,0,1);
			n6 = Node(0,1,2);
			n7 = Node(1,0,3);
			n8 = Node(1,1,4);

			el2 = Element(n1,n2,1);
			eb2 = Element(n1,n3,2);
			et2 = Element(n2,n4,3);
			er2 = Element(n3,n4,4);

			c2 = Cell(NoCellCycle, [et2,eb2,el2,er2], 2);


			% The node that will allow us to access the functions
			n = Node(-1,-1,5);

			% Adding elements
			n.AddElement([el,eb,et,er]);
			testCase.verifyEqual(n.elementList, [el,eb,et,er]);

			testCase.verifyWarning(@() n.AddElement(eb), 'N:AddElement:ElementAlreadyHere')

			testCase.verifyWarning(@() n.AddElement([el,el2]), 'N:AddElement:ElementAlreadyHere')
			testCase.verifyEqual(n.elementList, [el,eb,et,er,el2]);

			% Removing elements
			n.RemoveElement(et);
			testCase.verifyEqual(n.elementList, [el,eb,er,el2]);
			testCase.verifyWarning(@() n.RemoveElement(et), 'N:RemoveElement:ElementNotHere');

			% Replacing elementList
			n.ReplaceElementList([et2,eb2,el]);
			testCase.verifyEqual(n.elementList, [et2,eb2,el]);


			% Adding cells
			n.AddCell([c1]);
			testCase.verifyEqual(n.cellList, [c1]);

			testCase.verifyWarning(@() n.AddCell(c1), 'N:AddCell:CellAlreadyHere');
			testCase.verifyWarning(@() n.AddCell([c1, c2]), 'N:AddCell:CellAlreadyHere');
			testCase.verifyEqual(n.cellList, [c1,c2]);

			% Removing cells
			n.RemoveCell(c1);
			testCase.verifyEqual(n.cellList, [c2]);
			testCase.verifyWarning( @() n.RemoveCell(c1), 'N:RemoveCell:CellNotHere');

			% Replacing cellList
			n.ReplaceCellList([c1,c2,c1,c2]);
			testCase.verifyEqual(n.cellList, [c1,c2,c1,c2]);

		end

	end

end
