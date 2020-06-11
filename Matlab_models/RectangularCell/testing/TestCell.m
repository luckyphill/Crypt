classdef TestCell < matlab.unittest.TestCase
   	% Tests AbstractCell and the SquareCells
   	% that inherit from it
	methods (Test)

		function TestProperties(testCase)

			% COMPLETE (probably)
			% Missing:
			% 1. Testing for IsReadyToDivide. This shouldn't need to be tested
			%    here since it just reports back the result from CellCycleModel

			% Use a concrete class to test functionality in Abstract
			% As long as it works here, no need to recheck in the following tests

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = NoCellCycle();

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);

			% Check value parameters
			testCase.verifyEqual(c.id, 1);
			testCase.verifyEqual(c.age, 0);
			testCase.verifyEqual(c.newCellTargetArea, 0.5);
			testCase.verifyEqual(c.grownCellTargetArea, 1);
			testCase.verifyEqual(ccm, c.CellCycleModel);
			testCase.verifyEqual(c.newFreeCellSeparation, 0.1);
			testCase.verifyEqual(c.ancestorId, 1);
			testCase.verifyFalse(c.freeCell); % May be redundant

			% No divisions have happened yet
			testCase.verifyEmpty(c.sisterCell);

			% Check array parameters
			testCase.verifyTrue( ismember(n1, c.nodeList)  );
			testCase.verifyTrue( ismember(n2, c.nodeList)  );
			testCase.verifyTrue( ismember(n3, c.nodeList)  );
			testCase.verifyTrue( ismember(n4, c.nodeList)  );

			testCase.verifyEqual( size(c.nodeList), [1 4]);

			testCase.verifyTrue( ismember(el, c.elementList)  );
			testCase.verifyTrue( ismember(eb, c.elementList)  );
			testCase.verifyTrue( ismember(et, c.elementList)  );
			testCase.verifyTrue( ismember(er, c.elementList)  );

			testCase.verifyEqual( size(c.elementList), [1 4]);

			% Check setting wrong ccm errors
			testCase.verifyError( @() SquareCellJoined(1, [et,eb,el,er], 1), 'C:NotValidCCM');

			% Check cell data is set. This will be different for different cell types
			testCase.verifyEqual( c.cellData.Count, uint64(4));
			% Seriously, wtf matlab? You really are going to pull me up on type casting here of all places?


			% Check the getters
			% Area and perimeter accessed through cellData
			testCase.verifyEqual( c.GetCellArea, 1);
			testCase.verifyEqual( c.GetCellTargetArea, 1);

			testCase.verifyEqual( c.GetCellPerimeter, 4);
			testCase.verifyEqual( c.GetCellTargetPerimeter, 4);

			% Age
			c.CellCycleModel.age = 11;
			testCase.verifyEqual( c.GetAge(), 11);

			c.AgeCell(1);
			testCase.verifyEqual( c.GetAge(), 12);

			testCase.verifyEqual( c.GetColour(), ccm.PAUSE);

			% Last tricky one, the round about way to set cellData
			cellDataArray = [CellAreaSquare(), CellPerimeter()];

			c.AddCellData(cellDataArray);
			testCase.verifyEqual(c.cellData('cellArea'), cellDataArray(1));
			testCase.verifyEqual(c.cellData('cellPerimeter'), cellDataArray(2));

			% And another for good measure
			cD = CellArea();
			c.AddCellData(cD);
			testCase.verifyEqual(c.cellData('cellArea'), cD);


			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			ccm = NoCellCycle();

			c2 = SquareCellJoined(ccm, [et,eb,el,er], 1);

			% Need to do this check to make sure there is a unique
			% map object for every cell. This has gone wrong in the past...
			testCase.verifyNotEqual(c.cellData, c2.cellData);


			% Check element crossing

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			eb = Element(n3,n2,2);
			et = Element(n1,n4,3);

			testCase.verifyTrue( c2.DoElementsCross(eb, et) );

			% Self intersection has to be tested in each case
			% because it is part of the cell constructor


			% Test if cell is ready for division is really part of CellCycleModel
			% so as long as the function IsReadyToDivide just returns the 
			% behaviour from CellCycleModel, all should be rosy

		end

		function TestSquareCellJoined(testCase)

			% COMPLETE
			% Test the things specific to SquareCellJoined except for dividing

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			% All elements assembled clockwise
			el = Element(n1,n2,1);
			eb = Element(n3,n1,2);
			et = Element(n2,n4,3);
			er = Element(n4,n3,4);

			ccm = NoCellCycle();

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);

			testCase.verifyEqual(c.nodeBottomLeft, n1);
			testCase.verifyEqual(c.nodeBottomRight, n3);
			testCase.verifyEqual(c.nodeTopRight, n4);
			testCase.verifyEqual(c.nodeTopLeft, n2);

			testCase.verifyEqual(c.elementTop, et);
			testCase.verifyEqual(c.elementBottom, eb);
			testCase.verifyEqual(c.elementLeft, el);
			testCase.verifyEqual(c.elementRight, er);

			% Most initialising tested in TestProperties
			% Here we will test making sure nodes and elements are
			% listed correctly so they are in anticlockwise order

			%------------------------------------------------------
			% Elements are all correct, but nodes are ordered wrong
			%------------------------------------------------------

			% The lists are made anticlockwise
			nl = [n1, n3, n4, n2];
			elist = [eb, er, et, el];
			testCase.verifyEqual( c.nodeList, nl);
			testCase.verifyEqual( c.elementList, elist);

			% The elements have their nodes flipped so that
			% Node1 -> Node2 is anticlockwise
			testCase.verifyEqual( c.elementTop.Node1, n4 );
			testCase.verifyEqual( c.elementTop.Node2, n2 );

			testCase.verifyEqual( c.elementBottom.Node1, n1 );
			testCase.verifyEqual( c.elementBottom.Node2, n3 );

			testCase.verifyEqual( c.elementLeft.Node1, n2 );
			testCase.verifyEqual( c.elementLeft.Node2, n1 );

			testCase.verifyEqual( c.elementRight.Node1, n3 );
			testCase.verifyEqual( c.elementRight.Node2, n4 );

			testCase.verifyEqual( c.elementTop.nodeList, [n4, n2] );
			testCase.verifyEqual( c.elementBottom.nodeList, [n1, n3] );
			testCase.verifyEqual( c.elementLeft.nodeList, [n2, n1] );
			testCase.verifyEqual( c.elementRight.nodeList, [n3, n4] );


			%------------------------------------------------------
			% Two elements don't join at a corner
			%------------------------------------------------------

			% Elements aren't joined to eachother properly -> error
			% 4 cases for the 4 different corners where things can break

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);
			n5 = Node(0.1,0.1,5);

			% All elements assembled clockwise
			el = Element(n1,n2,1);
			eb = Element(n3,n5,2); % n1 split
			et = Element(n2,n4,3);
			er = Element(n4,n3,4);

			ccm = NoCellCycle();

			testCase.verifyError( @() SquareCellJoined(ccm, [et,eb,el,er], 1), 'SCJ:MakeEverythingAntiClockwise:ElementsWrong');
			

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);
			n5 = Node(0.1,0.1,5);

			% All elements assembled clockwise
			el = Element(n1,n5,1); % n2 split
			eb = Element(n3,n1,2);
			et = Element(n2,n4,3);
			er = Element(n4,n3,4);

			ccm = NoCellCycle();

			testCase.verifyError( @() SquareCellJoined(ccm, [et,eb,el,er], 1), 'SCJ:MakeEverythingAntiClockwise:ElementsWrong');


			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);
			n5 = Node(0.1,0.1,5);

			% All elements assembled clockwise
			el = Element(n1,n2,1); 
			eb = Element(n5,n1,2); % n3 split
			et = Element(n2,n4,3);
			er = Element(n4,n3,4);

			ccm = NoCellCycle();

			testCase.verifyError( @() SquareCellJoined(ccm, [et,eb,el,er], 1), 'SCJ:MakeEverythingAntiClockwise:ElementsWrong');


			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);
			n5 = Node(0.1,0.1,5);

			% All elements assembled clockwise
			el = Element(n1,n2,1); 
			eb = Element(n3,n1,2);
			et = Element(n2,n5,3); % n4 split
			er = Element(n4,n3,4);

			ccm = NoCellCycle();

			testCase.verifyError( @() SquareCellJoined(ccm, [et,eb,el,er], 1), 'SCJ:MakeEverythingAntiClockwise:ElementsWrong');


			%------------------------------------------------------
			% Elements form a loop, but cross over
			%------------------------------------------------------

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			% All elements assembled clockwise
			el = Element(n2,n1,1);
			eb = Element(n3,n2,2);
			et = Element(n1,n4,3);
			er = Element(n4,n3,4);

			ccm = NoCellCycle();

			testCase.verifyError( @() SquareCellJoined(ccm, [et,eb,el,er], 1), 'SCJ:MakeEverythingAntiClockwise:ElementsCross');

		end

		function TestSquareCellJoinedDivision(testCase)

			% COMPLETE
			% Test that division occurs correctly

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			% All elements assembled clockwise
			el = Element(n1,n2,1);
			eb = Element(n3,n1,2);
			et = Element(n2,n4,3);
			er = Element(n4,n3,4);

			ccm = SimplePhaseBasedCellCycle(10,10);
			% Fix these values for the sake of testing
			ccm.pausePhaseLength = 10;
			ccm.growingPhaseLength = 10;
			ccm.SetAge(5);

			c = SquareCellJoined(ccm, [et,eb,el,er], 1);


			% Not strictly necessary, as this is tested in other places
			% but a useful paranoia check
			testCase.verifyFalse( c.IsReadyToDivide() );

			ccm.SetAge(15);

			testCase.verifyFalse( c.IsReadyToDivide() );

			ccm.SetAge(25);

			testCase.verifyTrue( c.IsReadyToDivide() );

			[newCell, newNodeList, newElementList] = c.Divide();

			% Each new component is unique
			testCase.verifyEqual( size(newNodeList), [1 2]);
			testCase.verifyNotEqual(newNodeList(1), newNodeList(2));

			testCase.verifyEqual( size(newElementList), [1 3]);
			testCase.verifyNotEqual(newElementList(1), newElementList(2));
			testCase.verifyNotEqual(newElementList(3), newElementList(2));
			testCase.verifyNotEqual(newElementList(1), newElementList(3));

			testCase.verifyEqual(newNodeList, [c.nodeTopLeft, c.nodeBottomLeft] );
			testCase.verifyEqual(newNodeList, [newCell.nodeTopRight, newCell.nodeBottomRight] );

			testCase.verifyEqual(newElementList, [newCell.elementRight, newCell.elementTop, newCell.elementBottom]);
			testCase.verifyEqual(newElementList, [c.elementLeft, newCell.elementTop, newCell.elementBottom]);


			% Shared are correct

			% Shared nodes are correct
			testCase.verifyEqual(c.nodeTopLeft, newCell.nodeTopRight);
			testCase.verifyEqual(c.nodeBottomLeft, newCell.nodeBottomRight);

			testCase.verifyNotEqual(newCell.nodeTopRight, newCell.nodeBottomRight);

			% Shared elements are correct
			testCase.verifyEqual(c.elementLeft, newCell.elementRight);

			% Links are correct

			% Links Cell to Node (anticlockwise order)
			newNL = [n1, newCell.nodeBottomRight, newCell.nodeTopRight, n2];
			testCase.verifyEqual(newCell.nodeList, newNL);
			oldNL = [c.nodeBottomLeft, n3, n4, c.nodeTopLeft];
			testCase.verifyEqual(c.nodeList, oldNL);
			
			% Links Node to cell
			testCase.verifyEqual(newCell.nodeTopLeft.cellList, newCell);
			testCase.verifyEqual(newCell.nodeBottomLeft.cellList, newCell);

			testCase.verifyEqual(c.nodeTopRight.cellList, c);
			testCase.verifyEqual(c.nodeBottomRight.cellList, c);

			testCase.verifyEqual(c.nodeTopLeft.cellList, [newCell, c]);
			testCase.verifyEqual(c.nodeBottomLeft.cellList, [newCell, c]);

			% Links Node to element (only new and changed)
			testCase.verifyTrue(  ismember(newCell.elementRight, newCell.nodeTopRight.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementRight, newCell.nodeBottomRight.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementTop, newCell.nodeTopRight.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementTop, n2.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementBottom, n1.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementBottom, newCell.nodeBottomRight.elementList)  );

			testCase.verifyTrue(  ismember(el, n2.elementList)  );
			testCase.verifyTrue(  ismember(el, n1.elementList)  );

			testCase.verifyEqual( size(newCell.nodeTopRight.elementList), [1 3]);
			testCase.verifyEqual( size(newCell.nodeBottomRight.elementList), [1 3]);
			testCase.verifyEqual( size(n2.elementList), [1 2]);
			testCase.verifyEqual( size(n1.elementList), [1 2]);


			testCase.verifyTrue(  ismember(er, n4.elementList)  );
			testCase.verifyTrue(  ismember(er, n3.elementList)  );
			testCase.verifyTrue(  ismember(et, n4.elementList)  );
			testCase.verifyTrue(  ismember(et, c.nodeTopLeft.elementList)  );
			testCase.verifyTrue(  ismember(eb, c.nodeBottomLeft.elementList)  );
			testCase.verifyTrue(  ismember(eb, n3.elementList)  );

			testCase.verifyTrue(  ismember(c.elementLeft, c.nodeTopLeft.elementList)  );
			testCase.verifyTrue(  ismember(c.elementLeft, c.nodeBottomLeft.elementList)  );

			testCase.verifyEqual( size(n4.elementList), [1 2]);
			testCase.verifyEqual( size(n3.elementList), [1 2]);
			testCase.verifyEqual( size(c.nodeTopLeft.elementList), [1 3]);
			testCase.verifyEqual( size(c.nodeBottomLeft.elementList), [1 3]);


			% Links Cell to element are correct
			newEL = [newCell.elementBottom, newCell.elementRight, newCell.elementTop, el];
			testCase.verifyEqual(newCell.elementList, newEL);
			oldEL = [eb, er, et, c.elementLeft];
			testCase.verifyEqual(c.elementList, oldEL);

			% Links element to node are correct
			testCase.verifyEqual(el.Node1, n2);
			testCase.verifyEqual(el.Node2, n1);
			testCase.verifyEqual(er.Node1, n3);
			testCase.verifyEqual(er.Node2, n4);

			testCase.verifyEqual(et.Node1, n4);
			testCase.verifyEqual(et.Node2, newCell.nodeTopRight);
			testCase.verifyEqual(eb.Node1, newCell.nodeBottomRight);
			testCase.verifyEqual(eb.Node2, n3);

			testCase.verifyEqual(newCell.elementTop.Node1, c.nodeTopLeft);
			testCase.verifyEqual(newCell.elementTop.Node2, n2);
			testCase.verifyEqual(newCell.elementBottom.Node1, n1);
			testCase.verifyEqual(newCell.elementBottom.Node2, c.nodeBottomLeft);

			testCase.verifyEqual(newCell.elementRight.Node1, c.nodeBottomLeft);
			testCase.verifyEqual(newCell.elementRight.Node2, c.nodeTopLeft);

			testCase.verifyEqual( el.nodeList, [n2, n1]  );
			testCase.verifyEqual( er.nodeList, [n3, n4]  );
			testCase.verifyEqual( et.nodeList, [n4, newCell.nodeTopRight]  );
			testCase.verifyEqual( eb.nodeList, [newCell.nodeBottomRight,  n3]  );
			testCase.verifyEqual( newCell.elementTop.nodeList, [c.nodeTopLeft, n2]  );
			testCase.verifyEqual( newCell.elementBottom.nodeList, [n1, c.nodeBottomLeft]  );
			testCase.verifyEqual( newCell.elementRight.nodeList, [c.nodeBottomLeft,  c.nodeTopLeft]  );

		end

		function TestSquareCellFreeDivision(testCase)

			% INCOMPLETE
			% At this stage, the only difference between Joined and Free
			% is the division and the freeCell flag

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			% All elements assembled clockwise
			el = Element(n1,n2,1);
			eb = Element(n3,n1,2);
			et = Element(n2,n4,3);
			er = Element(n4,n3,4);

			ccm = SimplePhaseBasedCellCycle(10,10);
			% Fix these values for the sake of testing
			ccm.pausePhaseLength = 10;
			ccm.growingPhaseLength = 10;
			ccm.SetAge(10);

			c = SquareCellFree(ccm, [et,eb,el,er], 1);


			% Not strictly necessary, as this is tested in other places
			% but a useful paranoia check
			testCase.verifyFalse( c.IsReadyToDivide() );

			ccm.SetAge(15);

			testCase.verifyFalse( c.IsReadyToDivide() );

			ccm.SetAge(25);

			testCase.verifyTrue( c.IsReadyToDivide() );

			[newCell, newNodeList, newElementList] = c.Divide();


			% Uncomment as repaired

			% Each new component is unique
			testCase.verifyEqual( size(newNodeList), [1 4]);
			testCase.verifyNotEqual(newNodeList(1), newNodeList(2));
			testCase.verifyNotEqual(newNodeList(1), newNodeList(3));
			testCase.verifyNotEqual(newNodeList(1), newNodeList(4));
			testCase.verifyNotEqual(newNodeList(2), newNodeList(3));
			testCase.verifyNotEqual(newNodeList(2), newNodeList(4));
			testCase.verifyNotEqual(newNodeList(3), newNodeList(4));

			testCase.verifyEqual( size(newElementList), [1 4]);
			testCase.verifyNotEqual(newElementList(1), newElementList(2));
			testCase.verifyNotEqual(newElementList(1), newElementList(3));
			testCase.verifyNotEqual(newElementList(1), newElementList(4));
			testCase.verifyNotEqual(newElementList(2), newElementList(3));
			testCase.verifyNotEqual(newElementList(2), newElementList(4));
			testCase.verifyNotEqual(newElementList(3), newElementList(4));
			
			% The new components match exactly these lists
			testCase.verifyEqual(newNodeList, [c.nodeTopLeft, newCell.nodeTopRight, c.nodeBottomLeft, newCell.nodeBottomRight])
			testCase.verifyEqual(newElementList, [c.elementLeft, newCell.elementRight, newCell.elementTop, newCell.elementBottom]);

			% Links are correct

			% Links Cell to Node (anticlockwise order)
			newNL = [n1, newCell.nodeBottomRight, newCell.nodeTopRight, n2];
			testCase.verifyEqual(newCell.nodeList, newNL);
			oldNL = [c.nodeBottomLeft, n3, n4, c.nodeTopLeft];
			testCase.verifyEqual(c.nodeList, oldNL);
			
			% Links Node to cell
			testCase.verifyEqual(newCell.nodeTopLeft.cellList, newCell);
			testCase.verifyEqual(newCell.nodeBottomLeft.cellList, newCell);

			testCase.verifyEqual(c.nodeTopRight.cellList, c);
			testCase.verifyEqual(c.nodeBottomRight.cellList, c);

			% Links Node to element
			testCase.verifyTrue(  ismember(newCell.elementRight, newCell.nodeTopRight.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementRight, newCell.nodeBottomRight.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementTop, newCell.nodeTopRight.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementTop, n2.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementBottom, n1.elementList)  );
			testCase.verifyTrue(  ismember(newCell.elementBottom, newCell.nodeBottomRight.elementList)  );
			testCase.verifyTrue(  ismember(el, n2.elementList)  );
			testCase.verifyTrue(  ismember(el, n1.elementList)  );

			testCase.verifyEqual( size(newCell.nodeTopRight.elementList), [1 2]);
			testCase.verifyEqual( size(newCell.nodeBottomRight.elementList), [1 2]);
			testCase.verifyEqual( size(n2.elementList), [1 2]);
			testCase.verifyEqual( size(n1.elementList), [1 2]);
			

			testCase.verifyTrue(  ismember(er, n3.elementList)  );
			testCase.verifyTrue(  ismember(er, n4.elementList)  );
			testCase.verifyTrue(  ismember(et, c.nodeTopLeft.elementList)  );
			testCase.verifyTrue(  ismember(et, n4.elementList)  );
			testCase.verifyTrue(  ismember(eb, n3.elementList)  );
			testCase.verifyTrue(  ismember(eb, c.nodeBottomLeft.elementList)  );
			testCase.verifyTrue(  ismember(c.elementLeft, c.nodeTopLeft.elementList)  );
			testCase.verifyTrue(  ismember(c.elementLeft, c.nodeBottomLeft.elementList)  );

			testCase.verifyEqual( size(c.nodeTopLeft.elementList), [1 2]);
			testCase.verifyEqual( size(c.nodeBottomLeft.elementList), [1 2]);
			testCase.verifyEqual( size(n3.elementList), [1 2]);
			testCase.verifyEqual( size(n4.elementList), [1 2]);


			% Links Cell to element are correct
			newEL = [newCell.elementBottom, newCell.elementRight, newCell.elementTop, el];
			testCase.verifyEqual(newCell.elementList, newEL);
			oldEL = [eb, er, et, c.elementLeft];
			testCase.verifyEqual(c.elementList, oldEL);

			% Links element to node are correct
			testCase.verifyEqual(el.Node1, n2);
			testCase.verifyEqual(el.Node2, n1);
			testCase.verifyEqual(er.Node1, n3);
			testCase.verifyEqual(er.Node2, n4);

			testCase.verifyEqual(et.Node1, n4);
			testCase.verifyEqual(et.Node2, c.nodeTopLeft);
			testCase.verifyEqual(eb.Node1, c.nodeBottomLeft);
			testCase.verifyEqual(eb.Node2, n3);


			testCase.verifyEqual(newCell.elementLeft.Node1, n2);
			testCase.verifyEqual(newCell.elementLeft.Node2, n1);
			testCase.verifyEqual(newCell.elementRight.Node1, newCell.nodeBottomRight);
			testCase.verifyEqual(newCell.elementRight.Node2, newCell.nodeTopRight);

			testCase.verifyEqual(newCell.elementTop.Node1, newCell.nodeTopRight);
			testCase.verifyEqual(newCell.elementTop.Node2, n2);
			testCase.verifyEqual(newCell.elementBottom.Node1, n1);
			testCase.verifyEqual(newCell.elementBottom.Node2, newCell.nodeBottomRight);


			testCase.verifyEqual( el.nodeList, [n2, n1]  );
			testCase.verifyEqual( er.nodeList, [n3, n4]  );
			testCase.verifyEqual( et.nodeList, [n4, c.nodeTopLeft]  );
			testCase.verifyEqual( eb.nodeList, [c.nodeBottomLeft,  n3]  );

			testCase.verifyEqual( newCell.elementTop.nodeList, [newCell.nodeTopRight, n2]  );
			testCase.verifyEqual( newCell.elementBottom.nodeList, [n1, newCell.nodeBottomRight]  );
			testCase.verifyEqual( newCell.elementRight.nodeList, [newCell.nodeBottomRight,  newCell.nodeTopRight]  );
			testCase.verifyEqual( c.elementLeft.nodeList, [c.nodeTopLeft,  c.nodeBottomLeft]  );

		end

	end

end