classdef TestElement < matlab.unittest.TestCase
   % COMPLETE
	methods (Test)

		function TestPropertiesAndInitialise(testCase)
			
			% COMPLETE

			n1 = Node(1,1,1);
			n2 = Node(2,1,2);

			e = Element(n1,n2,1);

			testCase.verifyEqual(e.id,1);
			testCase.verifyEqual(e.naturalLength,1);
			testCase.verifyEqual(e.GetLength(),1);

			testCase.verifyEqual(e.Node1, n1);
			testCase.verifyEqual(e.Node2, n2);

			testCase.verifyEmpty(e.oldNode1);
			testCase.verifyEmpty(e.oldNode2);

			testCase.verifyFalse(e.modifiedInDivision);

			testCase.verifyEqual(e.minimumLength, 0.2);

			testCase.verifyEqual(e.nodeList, [n1, n2]);
			testCase.verifyEmpty(e.cellList);

			testCase.verifyFalse(e.internal);


			testCase.verifyEqual(n1.elementList, e);
			testCase.verifyEqual(n2.elementList, e);

			testCase.verifyEqual(e.etaD, 2);

		end

		function TestFunctions(testCase)

			% COMPLETE
			% Test the major functions of an element
			n1 = Node(1,0,1);
			n2 = Node(0,0,2);

			e = Element(n1,n2,1);

			n1.SetDragCoefficient(5);
			n2.SetDragCoefficient(5);

			e.UpdateTotalDrag();
			testCase.verifyEqual(e.etaD, 10);

			testCase.verifyEqual( e.GetMomentOfDrag, 2.5);

			e.SetNaturalLength(23.4);
			testCase.verifyEqual(e.naturalLength,23.4);
			testCase.verifyEqual(e.GetNaturalLength(),23.4);

			% The all important length, vector and mif point functions
			testCase.verifyEqual(e.GetLength(), 1);
			testCase.verifyEqual(e.GetVector1to2(), [-1, 0]);
			testCase.verifyEqual(e.GetOutwardNormal(), [0, 1]);
			testCase.verifyEqual(e.GetMidPoint(), [0.5,0]);

			e.SwapNodes();

			testCase.verifyEqual(e.Node1, n2);
			testCase.verifyEqual(e.Node2, n1);

			testCase.verifyEqual(e.GetVector1to2(), [1, 0]);
			testCase.verifyEqual(e.GetOutwardNormal(), [0, -1]);
			testCase.verifyEqual(e.GetMidPoint(), [0.5,0]);


			na = Node(0,0,1);
			nb = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(na,nb,1);
			eb = Element(na,n3,2);
			et = Element(nb,n4,3);
			er = Element(n3,n4,4);

			ccm = NoCellCycle();

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);

			% This should never really happen in the wild, only inside
			% a cell initialisation and division, but test it we must
			e.AddCell(c);
			testCase.verifyEqual(e.cellList, c);

			e.RemoveCell(c);
			testCase.verifyEmpty(e.cellList);

			testCase.verifyWarning( @() e.RemoveCell(c), 'E:RemoveCell:CellNotHere');

			testCase.verifyEqual(e.GetOtherNode(n2), n1);
			testCase.verifyEqual(e.GetOtherNode(n1), n2);
			testCase.verifyError( @() e.GetOtherNode(n4), 'E:GetOtherNode:NodeNotHere');

		end

		function TestCellStuff(testCase)

			% COMPLETE
			% Tests that cells can be added and removed
			% and the other cell can be found


			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = NoCellCycle();

			c1 = SquareCellJoined(ccm, [et,eb,el,er], 1);

			n6 = Node(2,1,6);
			n7 = Node(2,0,7);

			eb2 = Element(n3,n7,5);
			et2 = Element(n6,n4,6);
			er2 = Element(n7,n6,7);

			ccm = NoCellCycle();

			c2 = SquareCellJoined(ccm, [et2,eb2,er,er2], 1);

			testCase.verifyEqual(er.cellList, [c1, c2]);

			testCase.verifyEqual(er.GetOtherCell(c1), c2);
			testCase.verifyEqual(er.GetOtherCell(c2), c1);
			testCase.verifyEmpty(et.GetOtherCell(c1));

			testCase.verifyError( @() et.GetOtherCell(c2), 'E:GetOtherCell:CellNotHere');


			% Replace cell
			el.ReplaceCell(c1,c2);
			testCase.verifyEqual(el.cellList, c2);

			testCase.verifyWarning( @() eb.ReplaceCell(c2,c2), 'E:ReplaceCell:SameCell');
			
			% Two warnings here, c1 is already tehre, c2 is not in the element 
			testCase.verifyWarning( @() eb.ReplaceCell(c2,c1), 'E:AddCell:CellAlreadyHere');
			testCase.verifyWarning( @() eb.ReplaceCell(c2,c1), 'E:RemoveCell:CellNotHere');

			% Apparently not needed, if the cell isn't there, then it silently does nothing
			testCase.verifyWarning( @() eb.RemoveCell(c2), 'E:RemoveCell:CellNotHere');


			er2.ReplaceCellList([c1,c2,c1,c2]);

			testCase.verifyEqual(er2.cellList, [c1,c2,c1,c2]);

			testCase.verifyError( @() er2.GetOtherCell(c2), 'E:GetOtherCell:MoreThanTwo');

		end

		function TestReplaceNode(testCase)

			% COMPLETE (I believe...)

			% Test the function of replace node

			n1 = Node(1,1,1);
			n2 = Node(2,1,2);

			e = Element(n1,n2,1);

			testCase.verifyEqual(e.Node1, n1);
			testCase.verifyEqual(e.Node2, n2);

			n3 = Node(1.5,1,3);

			e.ReplaceNode(n2, n3);

			testCase.verifyEqual(e.Node1, n1);
			testCase.verifyEqual(e.Node2, n3);
			testCase.verifyEmpty(e.oldNode1);
			testCase.verifyEqual(e.oldNode2, n2);
			testCase.verifyTrue(ismember(e, n3.elementList));
			testCase.verifyFalse(ismember(e, n2.elementList));
			testCase.verifyEqual(e.nodeList, [n1, n3]);
			testCase.verifyTrue(e.modifiedInDivision);

			e.ReplaceNode(n1, n2);
			testCase.verifyEqual(e.Node1, n2);
			testCase.verifyEqual(e.Node2, n3);
			testCase.verifyEqual(e.oldNode1, n1);
			testCase.verifyEqual(e.oldNode2, n2);
			testCase.verifyTrue(ismember(e, n2.elementList));
			testCase.verifyFalse(ismember(e, n1.elementList));
			testCase.verifyEqual(e.nodeList, [n2, n3]);
			testCase.verifyTrue(e.modifiedInDivision);

			testCase.verifyWarning(@()e.ReplaceNode(n2,n2), 'e:sameNode', 'no warning from replace node');

			testCase.verifyError(@()e.ReplaceNode(n1,n2), 'e:nodeNotFound', 'no error from replace node');

		end


	end

end
