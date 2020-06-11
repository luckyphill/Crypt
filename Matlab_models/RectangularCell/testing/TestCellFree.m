classdef TestCellFree < matlab.unittest.TestCase
   % INCOMPLETE
   % Not entirely sure if it's all done, but I think it is
	methods (Test)

		function TestInitialisingAndOpposite(testCase)

			pgon = nsidedpoly(6,'Center',[5 0],'SideLength',3);
			v = flipud(pgon.Vertices);

			n1 = Node(v(1,1),v(1,2),1);
			n2 = Node(v(2,1),v(2,2),2);
			n3 = Node(v(3,1),v(3,2),3);
			n4 = Node(v(4,1),v(4,2),4);
			n5 = Node(v(5,1),v(5,2),5);
			n6 = Node(v(6,1),v(6,2),6);

			c = CellFree(NoCellCycle, [n1, n2, n3, n4, n5, n6], 1);

			% Check initialising is good, pay especial attention to the elemnts
			testCase.verifyEqual(c.numNodes, 6);
			testCase.verifyEqual(length(c.nodeList), 6);
			testCase.verifyEqual(length(c.elementList), 6);

			% Check that the order is correct going around
			% anticlockwise. Also checking the GetNextNode function
			% works properly

			% Node 1
			next = c.GetNextNode(n1, 1);
			testCase.verifyEqual(next,n2);
			next = c.GetNextNode(n1, -1);
			testCase.verifyEqual(next,n6);

			% Node 2
			next = c.GetNextNode(n2, 1);
			testCase.verifyEqual(next,n3);
			next = c.GetNextNode(n2, -1);
			testCase.verifyEqual(next,n1);

			% Node 3
			next = c.GetNextNode(n3, 1);
			testCase.verifyEqual(next,n4);
			next = c.GetNextNode(n3, -1);
			testCase.verifyEqual(next,n2);

			% Node 4
			next = c.GetNextNode(n4, 1);
			testCase.verifyEqual(next,n5);
			next = c.GetNextNode(n4, -1);
			testCase.verifyEqual(next,n3);

			% Node 5
			next = c.GetNextNode(n5, 1);
			testCase.verifyEqual(next,n6);
			next = c.GetNextNode(n5, -1);
			testCase.verifyEqual(next,n4);

			% Node 6
			next = c.GetNextNode(n6, 1);
			testCase.verifyEqual(next,n1);
			next = c.GetNextNode(n6, -1);
			testCase.verifyEqual(next,n5);



			% Test getting the opposite node using the nodeList index
			% Node 1
			o = c.GetOppositeNode(1);
			testCase.verifyEqual(o,n4);

			% Node 2
			o = c.GetOppositeNode(2);
			testCase.verifyEqual(o,n5);

			% Node 3
			o = c.GetOppositeNode(3);
			testCase.verifyEqual(o,n6);

			% Node 4
			o = c.GetOppositeNode(4);
			testCase.verifyEqual(o,n1);

			% Node 5
			o = c.GetOppositeNode(5);
			testCase.verifyEqual(o,n2);

			% Node 6
			o = c.GetOppositeNode(6);
			testCase.verifyEqual(o,n3);

			% Even sided cell should error if we look for the
			% opposite element
			testCase.verifyError(@() c.GetOppositeElement(1), 'CF:GetOppositeElement');

			% Make an odd sided polygon to test get opposite element
			pgon = nsidedpoly(5,'Center',[5 0],'SideLength',3);
			v = flipud(pgon.Vertices);

			n1 = Node(v(1,1),v(1,2),1);
			n2 = Node(v(2,1),v(2,2),2);
			n3 = Node(v(3,1),v(3,2),3);
			n4 = Node(v(4,1),v(4,2),4);
			n5 = Node(v(5,1),v(5,2),5);

			c = CellFree(NoCellCycle, [n1, n2, n3, n4, n5], 1);

			% Test getting the opposite node using the nodeList index
			% Node 1
			o = c.GetOppositeElement(1);
			testCase.verifyEqual(o,c.elementList(3));

			% Node 2
			o = c.GetOppositeElement(2);
			testCase.verifyEqual(o,c.elementList(4));

			% Node 3
			o = c.GetOppositeElement(3);
			testCase.verifyEqual(o,c.elementList(5));

			% Node 4
			o = c.GetOppositeElement(4);
			testCase.verifyEqual(o,c.elementList(1));

			% Node 5
			o = c.GetOppositeElement(5);
			testCase.verifyEqual(o,c.elementList(2));

			% And test that an odd sided cell errors get opposite node
			testCase.verifyError(@() c.GetOppositeNode(1), 'CF:GetOppositeNode');

		end

		function TestListSplitting(testCase)

			% Tests that we get the correct nodes and elements when
			% using getbetween methods

			pgon = nsidedpoly(6,'Center',[5 0],'SideLength',3);
			v = flipud(pgon.Vertices);

			n1 = Node(v(1,1),v(1,2),1);
			n2 = Node(v(2,1),v(2,2),2);
			n3 = Node(v(3,1),v(3,2),3);
			n4 = Node(v(4,1),v(4,2),4);
			n5 = Node(v(5,1),v(5,2),5);
			n6 = Node(v(6,1),v(6,2),6);

			c = CellFree(NoCellCycle, [n1, n2, n3, n4, n5, n6], 1);

			% Need to test different lengths, different directins
			% and crossing over the end of nodeList back to the start

			%-----------------------------------
			% Nodes
			%-----------------------------------

			% Anticlockwise
			% Get a list
			nodesBetween = c.GetNodesBetween(n1, n6, 1);
			testCase.verifyEqual(nodesBetween, [n2, n3, n4, n5]);

			% List is single cell
			nodesBetween = c.GetNodesBetween(n4, n6, 1);
			testCase.verifyEqual(nodesBetween, [n5]);

			% List is empty
			nodesBetween = c.GetNodesBetween(n5, n6, 1);
			testCase.verifyEmpty(nodesBetween);
			nodesBetween = c.GetNodesBetween(n6, n1, 1);
			testCase.verifyEmpty(nodesBetween);

			% Wrap around
			nodesBetween = c.GetNodesBetween(n4, n3, 1);
			testCase.verifyEqual(nodesBetween, [n5, n6, n1, n2]);


			% Clockwise
			% Get a list
			nodesBetween = c.GetNodesBetween(n6, n1, -1);
			testCase.verifyEqual(nodesBetween, [n5, n4, n3, n2]);

			% List is single cell
			nodesBetween = c.GetNodesBetween(n4, n2, -1);
			testCase.verifyEqual(nodesBetween, [n3]);

			% List is empty
			nodesBetween = c.GetNodesBetween(n3, n2, -1);
			testCase.verifyEmpty(nodesBetween);
			nodesBetween = c.GetNodesBetween(n1, n6, -1);
			testCase.verifyEmpty(nodesBetween);

			% Wrap around
			nodesBetween = c.GetNodesBetween(n3, n4, -1);
			testCase.verifyEqual(nodesBetween, [n2, n1, n6, n5]);


			% Anticlockwise inclusive
			% Get a list
			nodesBetween = c.GetNodesBetweenInclusive(n1, n6, 1);
			testCase.verifyEqual(nodesBetween, [n1, n2, n3, n4, n5, n6]);

			% List gets one extra cell
			nodesBetween = c.GetNodesBetweenInclusive(n4, n6, 1);
			testCase.verifyEqual(nodesBetween, [n4, n5, n6]);

			% Just end points
			nodesBetween = c.GetNodesBetweenInclusive(n1, n2, 1);
			testCase.verifyEqual(nodesBetween, [n1, n2]);
			nodesBetween = c.GetNodesBetweenInclusive(n6, n1, 1);
			testCase.verifyEqual(nodesBetween, [n6, n1]);

			% Wrap around
			nodesBetween = c.GetNodesBetweenInclusive(n4, n3, 1);
			testCase.verifyEqual(nodesBetween, [n4, n5, n6, n1, n2, n3]);


			% Clockwise inclusive
			% Get a list
			nodesBetween = c.GetNodesBetweenInclusive(n6, n1, -1);
			testCase.verifyEqual(nodesBetween, [n6, n5, n4, n3, n2, n1]);
			

			% List gets one extra cell
			nodesBetween = c.GetNodesBetweenInclusive(n4, n2, -1);
			testCase.verifyEqual(nodesBetween, [n4, n3, n2]);

			% Just end points
			nodesBetween = c.GetNodesBetweenInclusive(n4, n3, -1);
			testCase.verifyEqual(nodesBetween, [n4, n3]);
			nodesBetween = c.GetNodesBetweenInclusive(n1, n6, -1);
			testCase.verifyEqual(nodesBetween, [n1, n6]);
			
			% Wrap around
			nodesBetween = c.GetNodesBetweenInclusive(n1, n2, -1);
			testCase.verifyEqual(nodesBetween, [n1, n6, n5, n4, n3, n2]);



			%-----------------------------------
			% Elements
			%-----------------------------------


			e1 = c.elementList(1);
			e2 = c.elementList(2);
			e3 = c.elementList(3);
			e4 = c.elementList(4);
			e5 = c.elementList(5);
			e6 = c.elementList(6);

			% Anticlockwise
			% Get a list
			elementsBetween = c.GetElementsBetween(e1, e6, 1);
			testCase.verifyEqual(elementsBetween, [e2, e3, e4, e5]);

			% List is single cell
			elementsBetween = c.GetElementsBetween(e4, e6, 1);
			testCase.verifyEqual(elementsBetween, [e5]);

			% List is empty
			elementsBetween = c.GetElementsBetween(e5, e6, 1);
			testCase.verifyEmpty(elementsBetween);
			elementsBetween = c.GetElementsBetween(e6, e1, 1);
			testCase.verifyEmpty(elementsBetween);

			% Wrap around
			elementsBetween = c.GetElementsBetween(e4, e3, 1);
			testCase.verifyEqual(elementsBetween, [e5, e6, e1, e2]);


			% Clockwise
			% Get a list
			elementsBetween = c.GetElementsBetween(e6, e1, -1);
			testCase.verifyEqual(elementsBetween, [e5, e4, e3, e2]);

			% List is single cell
			elementsBetween = c.GetElementsBetween(e4, e2, -1);
			testCase.verifyEqual(elementsBetween, [e3]);

			% List is empty
			elementsBetween = c.GetElementsBetween(e3, e2, -1);
			testCase.verifyEmpty(elementsBetween);
			elementsBetween = c.GetElementsBetween(e1, e6, -1);
			testCase.verifyEmpty(elementsBetween);

			% Wrap around
			elementsBetween = c.GetElementsBetween(e3, e4, -1);
			testCase.verifyEqual(elementsBetween, [e2, e1, e6, e5]);


			% Anticlockwise inclusive
			% Get a list
			elementsBetween = c.GetElementsBetweenInclusive(e1, e6, 1);
			testCase.verifyEqual(elementsBetween, [e1, e2, e3, e4, e5, e6]);

			% List gets one extra cell
			elementsBetween = c.GetElementsBetweenInclusive(e4, e6, 1);
			testCase.verifyEqual(elementsBetween, [e4, e5, e6]);

			% Just end points
			elementsBetween = c.GetElementsBetweenInclusive(e1, e2, 1);
			testCase.verifyEqual(elementsBetween, [e1, e2]);
			elementsBetween = c.GetElementsBetweenInclusive(e6, e1, 1);
			testCase.verifyEqual(elementsBetween, [e6, e1]);

			% Wrap around
			elementsBetween = c.GetElementsBetweenInclusive(e4, e3, 1);
			testCase.verifyEqual(elementsBetween, [e4, e5, e6, e1, e2, e3]);


			% Clockwise inclusive
			% Get a list
			elementsBetween = c.GetElementsBetweenInclusive(e6, e1, -1);
			testCase.verifyEqual(elementsBetween, [e6, e5, e4, e3, e2, e1]);
			

			% List gets one extra cell
			elementsBetween = c.GetElementsBetweenInclusive(e4, e2, -1);
			testCase.verifyEqual(elementsBetween, [e4, e3, e2]);

			% Just end points
			elementsBetween = c.GetElementsBetweenInclusive(e4, e3, -1);
			testCase.verifyEqual(elementsBetween, [e4, e3]);
			elementsBetween = c.GetElementsBetweenInclusive(e1, e6, -1);
			testCase.verifyEqual(elementsBetween, [e1, e6]);
			
			% Wrap around
			elementsBetween = c.GetElementsBetweenInclusive(e1, e2, -1);
			testCase.verifyEqual(elementsBetween, [e1, e6, e5, e4, e3, e2]);

		end

		function TestDividingEven(testCase)

			% Test that dividing works properly when the polygon has
			% an even number of sides

			pgon = nsidedpoly(6,'Center',[5 0],'SideLength',3);
			v = flipud(pgon.Vertices);

			n1 = Node(v(1,1),v(1,2),1);
			n2 = Node(v(2,1),v(2,2),2);
			n3 = Node(v(3,1),v(3,2),3);
			n4 = Node(v(4,1),v(4,2),4);
			n5 = Node(v(5,1),v(5,2),5);
			n6 = Node(v(6,1),v(6,2),6);

			c = CellFree(NoCellCycle, [n1, n2, n3, n4, n5, n6], 1);
			c.newFreeCellSeparation = 0.1;

			% Split from node 1

			sTOo = c.GetSplitVector(n1, 1);

			testCase.verifyEqual(sTOo, n4.position - n1.position);

			[nodesLeft, nodesRight, sTOo] = c.MakeIntermediateNodes(n1, 1);

			testCase.verifyEqual(sTOo, n4.position - n1.position);

			% These were determined by looking at a plot and judging by eye they looked right
			% Only valid given newFreeCellSeparation = 0.1
			testCase.verifyEqual(nodesLeft(1).position, [5.4567   -0.8910], 'RelTol', 1e-4);
			testCase.verifyEqual(nodesLeft(2).position, [4.4567    0.8410], 'RelTol', 1e-4);
			testCase.verifyEqual(nodesRight(1).position, [5.5433   -0.8410], 'RelTol', 1e-4);
			testCase.verifyEqual(nodesRight(2).position, [4.5433    0.8910], 'RelTol', 1e-4);

			[newCell, newNodeList, newElementList] = c.Divide();

			% Need to verify all of the positions, but the splitNode is chosen at random just now


			testCase.verifyEqual(c.GetAge(), 0);
			testCase.verifyEqual(newCell.GetAge(), 0);

			testCase.verifyEqual(c.sisterCell, newCell);
			testCase.verifyEqual(c, newCell.sisterCell);

			testCase.verifyEqual(c.ancestorId,newCell.ancestorId);

			% The nodes in each cell should be unique
			testCase.verifyEqual(  sum(  c.nodeList == newCell.nodeList  ), 0  );

			% Test the two cells to make sure everything is in order

			% Check the cells have the right number of nodes and elements
			testCase.verifyEqual(length(c.nodeList), 6);
			testCase.verifyEqual(length(c.elementList), 6);

			testCase.verifyEqual(length(newCell.nodeList), 6);
			testCase.verifyEqual(length(newCell.elementList), 6);


			% Check that the loop is continuous anticlockwise
			
			% Old cell nodes
			next = c.GetNextNode(c.nodeList(1), 1);
			for i = 1:5
				next = c.GetNextNode(next, 1);
			end
			testCase.verifyEqual(c.nodeList(1), next);
			% New cell nodes
			next = newCell.GetNextNode(newCell.nodeList(1), 1);
			for i = 1:5
				next = newCell.GetNextNode(next, 1);
			end
			testCase.verifyEqual(newCell.nodeList(1), next);


			% Old cell elements
			next = c.GetNextElement(c.elementList(1), 1);
			for i = 1:5
				next = c.GetNextElement(next, 1);
			end
			testCase.verifyEqual(c.elementList(1), next);
			% New cell elements
			next = newCell.GetNextElement(newCell.elementList(1), 1);
			for i = 1:5
				next = newCell.GetNextElement(next, 1);
			end
			testCase.verifyEqual(newCell.elementList(1), next);


			% Check that the loop is continuous iclockwise
			
			% Old cell nodes
			next = c.GetNextNode(c.nodeList(1), -1);
			for i = 1:5
				next = c.GetNextNode(next, -1);
			end
			testCase.verifyEqual(c.nodeList(1), next);
			% New cell nodes
			next = newCell.GetNextNode(newCell.nodeList(1), -1);
			for i = 1:5
				next = newCell.GetNextNode(next, -1);
			end
			testCase.verifyEqual(newCell.nodeList(1), next);


			% Old cell elements
			next = c.GetNextElement(c.elementList(1), -1);
			for i = 1:5
				next = c.GetNextElement(next, -1);
			end
			testCase.verifyEqual(c.elementList(1), next);
			% New cell elements
			next = newCell.GetNextElement(newCell.elementList(1), -1);
			for i = 1:5
				next = newCell.GetNextElement(next, -1);
			end
			testCase.verifyEqual(newCell.elementList(1), next);

			
			% Old cell

			% Check that the nodeLists match the element lists
			% nodeList(i) must be Node1 of elementList(i)
			% and Node2 of elementList(i-1)
			% Check all the nodes only have two elements, and point to the
			% correct cell.

			for i = 1:length(c.nodeList)
				testCase.verifyEqual(c.nodeList(i), c.elementList(i).Node1);
				testCase.verifyEqual(length(c.nodeList(i).elementList), 2);

				testCase.verifyEqual(length(c.nodeList(i).cellList), 1);
				testCase.verifyEqual(c.nodeList(i).cellList,c);
			end

			% Node2 check needs a separate loop
			testCase.verifyEqual(c.nodeList(1), c.elementList(end).Node2);
			for i = 2:length(c.nodeList)
				testCase.verifyEqual(c.nodeList(i), c.elementList(i-1).Node2);
			end


			% New Cell

			% Check that the nodeLists match the element lists
			% nodeList(i) must be Node1 of elementList(i)
			% and Node2 of elementList(i-1)
			% Check all the nodes only have two elements, and point to the
			% correct cell.
			for i = 1:length(newCell.nodeList)
				testCase.verifyEqual(newCell.nodeList(i), newCell.elementList(i).Node1);

				testCase.verifyEqual(length(newCell.nodeList(i).elementList), 2);

				testCase.verifyEqual(length(newCell.nodeList(i).cellList), 1);
				testCase.verifyEqual(newCell.nodeList(i).cellList,newCell);
			end

			% Node2 check needs a separate loop
			testCase.verifyEqual(newCell.nodeList(1), newCell.elementList(end).Node2);
			for i = 2:length(newCell.nodeList)
				testCase.verifyEqual(newCell.nodeList(i), newCell.elementList(i-1).Node2);
			end

		end

		function TestDividingOdd(testCase)

			% Test that dividing works properly when the polygon has
			% an odd number of sides

			pgon = nsidedpoly(5,'Center',[5 0],'SideLength',3);
			v = flipud(pgon.Vertices);

			n1 = Node(v(1,1),v(1,2),1);
			n2 = Node(v(2,1),v(2,2),2);
			n3 = Node(v(3,1),v(3,2),3);
			n4 = Node(v(4,1),v(4,2),4);
			n5 = Node(v(5,1),v(5,2),5);

			c = CellFree(NoCellCycle, [n1, n2, n3, n4, n5], 1);
			c.newFreeCellSeparation = 0.1;

			% Split from node 1

			sTOo = c.GetSplitVector(n1, 1);

			mp = c.elementList(3).GetMidPoint();

			testCase.verifyEqual(sTOo, mp - n1.position);

			[nodesLeft, nodesRight, sTOo] = c.MakeIntermediateNodes(n1, 1);

			testCase.verifyEqual(sTOo, mp - n1.position);

			% These were determine by looking at a plot and judging by eye they looked right
			% Only valid given newFreeCellSeparation = 0.1
			testCase.verifyEqual(nodesLeft(1).position, [5.1028   -0.2265], 'RelTol', 1e-3);
			testCase.verifyEqual(nodesRight(1).position, [5.1837   -0.1678], 'RelTol', 1e-3);
			


			%----------------------------------------------------------------
			% THe following is copied from even, so need to be careful to
			% update everything properly
			%----------------------------------------------------------------

			[newCell, newNodeList, newElementList] = c.Divide();

			testCase.verifyEqual(c.GetAge(), 0);
			testCase.verifyEqual(newCell.GetAge(), 0);

			testCase.verifyEqual(c.sisterCell, newCell);
			testCase.verifyEqual(c, newCell.sisterCell);

			testCase.verifyEqual(c.ancestorId,newCell.ancestorId);

			% Test the two cells to make sure everything is in order

			% Check the cells have the right number of nodes and elements
			testCase.verifyEqual(length(c.nodeList), 5);
			testCase.verifyEqual(length(c.elementList), 5);

			testCase.verifyEqual(length(newCell.nodeList), 5);
			testCase.verifyEqual(length(newCell.elementList), 5);


			% Check that the loop is continuous anticlockwise
			
			% Old cell nodes
			next = c.GetNextNode(c.nodeList(1), 1);
			for i = 1:4
				next = c.GetNextNode(next, 1);
			end
			testCase.verifyEqual(c.nodeList(1), next);
			% New cell nodes
			next = newCell.GetNextNode(newCell.nodeList(1), 1);
			for i = 1:4
				next = newCell.GetNextNode(next, 1);
			end
			testCase.verifyEqual(newCell.nodeList(1), next);


			% Old cell elements
			next = c.GetNextElement(c.elementList(1), 1);
			for i = 1:4
				next = c.GetNextElement(next, 1);
			end
			testCase.verifyEqual(c.elementList(1), next);
			% New cell elements
			next = newCell.GetNextElement(newCell.elementList(1), 1);
			for i = 1:4
				next = newCell.GetNextElement(next, 1);
			end
			testCase.verifyEqual(newCell.elementList(1), next);


			% Check that the loop is continuous iclockwise
			
			% Old cell nodes
			next = c.GetNextNode(c.nodeList(1), -1);
			for i = 1:4
				next = c.GetNextNode(next, -1);
			end
			testCase.verifyEqual(c.nodeList(1), next);
			% New cell nodes
			next = newCell.GetNextNode(newCell.nodeList(1), -1);
			for i = 1:4
				next = newCell.GetNextNode(next, -1);
			end
			testCase.verifyEqual(newCell.nodeList(1), next);


			% Old cell elements
			next = c.GetNextElement(c.elementList(1), -1);
			for i = 1:4
				next = c.GetNextElement(next, -1);
			end
			testCase.verifyEqual(c.elementList(1), next);
			% New cell elements
			next = newCell.GetNextElement(newCell.elementList(1), -1);
			for i = 1:4
				next = newCell.GetNextElement(next, -1);
			end
			testCase.verifyEqual(newCell.elementList(1), next);

			
			% Old cell

			% Check that the nodeLists match the element lists
			% nodeList(i) must be Node1 of elementList(i)
			% and Node2 of elementList(i-1)
			% Check all the nodes only have two elements, and point to the
			% correct cell.

			for i = 1:length(c.nodeList)
				testCase.verifyEqual(c.nodeList(i), c.elementList(i).Node1);
				testCase.verifyEqual(length(c.nodeList(i).elementList), 2);

				testCase.verifyEqual(length(c.nodeList(i).cellList), 1);
				testCase.verifyEqual(c.nodeList(i).cellList,c);
			end

			% Node2 check needs a separate loop
			testCase.verifyEqual(c.nodeList(1), c.elementList(end).Node2);
			for i = 2:length(c.nodeList)
				testCase.verifyEqual(c.nodeList(i), c.elementList(i-1).Node2);
			end


			% New Cell

			% Check that the nodeLists match the element lists
			% nodeList(i) must be Node1 of elementList(i)
			% and Node2 of elementList(i-1)
			% Check all the nodes only have two elements, and point to the
			% correct cell.
			for i = 1:length(newCell.nodeList)
				testCase.verifyEqual(newCell.nodeList(i), newCell.elementList(i).Node1);

				testCase.verifyEqual(length(newCell.nodeList(i).elementList), 2);

				testCase.verifyEqual(length(newCell.nodeList(i).cellList), 1);
				testCase.verifyEqual(newCell.nodeList(i).cellList,newCell);
			end

			% Node2 check needs a separate loop
			testCase.verifyEqual(newCell.nodeList(1), newCell.elementList(end).Node2);
			for i = 2:length(newCell.nodeList)
				testCase.verifyEqual(newCell.nodeList(i), newCell.elementList(i-1).Node2);
			end

		end

	end

end