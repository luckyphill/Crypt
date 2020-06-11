classdef TestSpacePartition < matlab.unittest.TestCase
   % INCOMPLETE
   % MISSING:
   % TestInitialise
   % TestUpdateBoxesForElementsUsingNode
   % TestGettingBoxes

   % x = done
   % i = done implicitly via a funciton that uses it
   % . = probably done well enough
   %   = not done
   % r = redundant, or don't need to test

   % Methods to test:
   %   Constructor
   % i GetQuadrant > GetQuadrantAndIndices
   % i GetIndices > GetQuadrantAndIndices
   % x ConvertToQuadrant
   % x ConvertToGlobal
   % x GetGlobalIndices
   % x GetQuadrantAndIndices
   % x GetElementBox
   % r IsNodeInNewBox
   % x GetNodeBox
   %   RepairModifiedElement
   % x RemoveElementFromPartition
   % x RemoveNodeFromPartition
   % x RemoveElementFromBox
   % i InsertElement > PutElementInBoxes
   % i InsertNode > PutNodeInBox
   % r UpdateBoxesForElement - This is slow compared to using node, no testing
   % . UpdateBoxesForElementUsingNode
   % . UpdateBoxesForElementUsingNodeAdjusted
   % i MoveElementToNewBoxes > UpdateBoxesForElementUsingNode
   % x UpdateBoxForNode
   % x UpdateBoxForNodeAdjusted
   %   MakeElementBoxList
   %   GetBoxIndicesBetweenPoints
   %   GetBoxIndicesBetweenNodes
   % r GetBoxIndicesBetweenNodesPrevious
   %   GetBoxIndicesBetweenNodesPreviousCurrent
   % x PutElementInBoxes
   %   GetAdjacentElementBoxFromNode
   %   GetAdjacentNodeBoxFromNode
   % x GetElementBoxFromNode
   % x GetNodeBoxFromNode
   % x PutNodeInBox
   %   AssembleCandidateNodes
   %   AssembleCandidateElements
   %   GetNeighbouringNodesAndElements
   %   GetNeighbouringNodes
   %   GetNeighbouringElements
   % . QuickUnique

   % Test interaction between adjustposition and modified element


	methods (Test)

		function TestGetQuadrantAndIndices(testCase)

			% COMPLETE BUT CAN'T BE EXHAUSTIVE
			% This tests all possible cases of where a node can be found
			% in relation to a box and its boundaries, and makes
			% sure they end up in the expected boxes
			% In combination with TestPutNodeInBox, this gets every type
			% of placement given the boundaries
			% It can't test every possible box because there are technically
			% infinite

			t = CellGrowing(3,20,10,10,10,1,10);
			p = SpacePartition(1, 1, t);

			% Quadrant 1
			[q,i,j] = p.GetQuadrantAndIndices(1.1,2.2);

			testCase.verifyEqual([q,i,j], [1,2,3]);

			% Quadrant 2
			[q,i,j] = p.GetQuadrantAndIndices(1.1,-2.2);

			testCase.verifyEqual([q,i,j], [2,2,3]);

			% Quadrant 3
			[q,i,j] = p.GetQuadrantAndIndices(-1.1,-2.2);

			testCase.verifyEqual([q,i,j], [3,2,3]);

			% Quadrant 4
			[q,i,j] = p.GetQuadrantAndIndices(-1.1,2.2);

			testCase.verifyEqual([q,i,j], [4,2,3]);

			% Edge cases

			% Origin
			[q,i,j] = p.GetQuadrantAndIndices(0,0);

			testCase.verifyEqual([q,i,j], [1,1,1]);

			% Corners
			% Quadrant 1
			[q,i,j] = p.GetQuadrantAndIndices(1,1);

			testCase.verifyEqual([q,i,j], [1,2,2]);

			% Quadrant 2
			[q,i,j] = p.GetQuadrantAndIndices(1,-1);

			testCase.verifyEqual([q,i,j], [2,2,2]);

			% Quadrant 3
			[q,i,j] = p.GetQuadrantAndIndices(-1,-1);

			testCase.verifyEqual([q,i,j], [3,2,2]);

			% Quadrant 4
			[q,i,j] = p.GetQuadrantAndIndices(-1,1);

			testCase.verifyEqual([q,i,j], [4,2,2]);

		end

		function TestGetQuadrantAndIndicesVectorised(testCase)
			% COMPLETE
			% Does exactly the same as TestFindQuadrantsAndBoxes
			% but it does it all in one hit by vectorising
			t = CellGrowing(3,20,10,10,10,1,10);
			p = SpacePartition(1, 1, t);

			a = [1.1,2.2;1.1,-2.2;-1.1,-2.2;-1.1,2.2;0,0;1,0;0,1;-1,0;0,-1;1,1;1,-1;-1,-1;-1,1];

			x = a(:,1);
			y = a(:,2);

			out = [1,2,3;2,2,3;3,2,3;4,2,3;1,1,1;1,2,1;1,1,2;4,2,1;2,1,2;1,2,2;2,2,2;3,2,2;4,2,2];

			[q,i,j] = p.GetQuadrantAndIndices(x,y);

			testCase.verifyEqual([q,i,j], out);
		
		end

		function TestConvertToQuadrant(testCase)

			% COMPLETE
			% Goes from global indices to quadrant indices

			t.nodeList = [];
			t.elementList = [];

			p = SpacePartition(1, 1, t);

			% Test in each quadrant
			% Returns the quadrant incides, give the global indices
			[q,i,j] = p.ConvertToQuadrant(1,1);
			testCase.verifyEqual( [q,i,j], [1,1,1]);
			[q,i,j] = p.ConvertToQuadrant(-1,1);
			testCase.verifyEqual( [q,i,j], [4,1,1]);
			[q,i,j] = p.ConvertToQuadrant(1,-1);
			testCase.verifyEqual( [q,i,j], [2,1,1]);
			[q,i,j] = p.ConvertToQuadrant(-1,-1);
			testCase.verifyEqual( [q,i,j], [3,1,1]); 

		end

		function TestConvertToGlobal(testCase)

			% COMPLETE
			% Goes from quadrant to global indices

			t.nodeList = [];
			t.elementList = [];

			p = SpacePartition(1, 1, t);

			[I, J] = p.ConvertToGlobal(1,1,1);
			testCase.verifyEqual([I, J], [1,1]);
			[I, J] = p.ConvertToGlobal(2,1,1);
			testCase.verifyEqual([I, J], [1,-1]);
			[I, J] = p.ConvertToGlobal(3,1,1);
			testCase.verifyEqual([I, J], [-1,-1]);
			[I, J] = p.ConvertToGlobal(4,1,1);
			testCase.verifyEqual([I, J], [-1,1]);

		end

		function TestGetGlobalIndices(testCase)

			% COMPLETE

			% Need to test every poisition including edge cases

			t.nodeList = [];
			t.elementList = [];

			p = SpacePartition(1, 1, t);


			% Quadrant 1
			[I, J] = p.GetGlobalIndices(1.1,2.2);

			testCase.verifyEqual([I, J], [2,3]);

			% Quadrant 2
			[I, J] = p.GetGlobalIndices(1.1,-2.2);

			testCase.verifyEqual([I, J], [2,-3]);

			% Quadrant 3
			[I, J] = p.GetGlobalIndices(-1.1,-2.2);

			testCase.verifyEqual([I, J], [-2,-3]);

			% Quadrant 4
			[I, J] = p.GetGlobalIndices(-1.1,2.2);

			testCase.verifyEqual([I, J], [-2,3]);

			% Edge cases

			% Origin
			[I, J] = p.GetGlobalIndices(0,0);

			testCase.verifyEqual([I, J], [1,1]);

			% Axes
			% +ve x
			[I, J] = p.GetGlobalIndices(1.5,0);

			testCase.verifyEqual([I, J], [2,1]);

			% +ve y
			[I, J] = p.GetGlobalIndices(0,1.5);

			testCase.verifyEqual([I, J], [1,2]);

			% -ve x
			[I, J] = p.GetGlobalIndices(-1.5,0);

			testCase.verifyEqual([I, J], [-2,1]);

			% -ve y
			[I, J] = p.GetGlobalIndices(0,-1.5);

			testCase.verifyEqual([I, J], [1,-2]);

			% Corners
			% Quadrant 1
			[I, J] = p.GetGlobalIndices(1,1);

			testCase.verifyEqual([I, J], [2,2]);

			% Quadrant 2
			[I, J] = p.GetGlobalIndices(1,-1);

			testCase.verifyEqual([I, J], [2,-2]);

			% Quadrant 3
			[I, J] = p.GetGlobalIndices(-1,-1);

			testCase.verifyEqual([I, J], [-2,-2]);

			% Quadrant 4
			[I, J] = p.GetGlobalIndices(-1,1);

			testCase.verifyEqual([I, J], [-2,2]);

		end

		function TestPutNodeInBox(testCase)
			% COMPLETE
			% This tests to make sure a node is put into the
			% correct box, in the correct quadrant

			% A dummy simulation to satisfy the initialisation
			t.nodeList = [];
			t.elementList = [];
			p = SpacePartition(1, 1, t);

			% Put the node into the centre of a box
			% Quadrant 1
			n = Node(1.1,2.2,1);

			p.PutNodeInBox(n);

			testCase.verifyEqual(p.nodesQ{1}{2,3}, [n]);

			% Quadrant 2
			n = Node(1.1,-2.2,1);

			p.PutNodeInBox(n);

			testCase.verifyEqual(p.nodesQ{2}{2,3}, [n]);

			% Quadrant 3
			n = Node(-1.1,-2.2,1);

			p.PutNodeInBox(n);

			testCase.verifyEqual(p.nodesQ{3}{2,3}, [n]);

			% Quadrant 4
			n = Node(-1.1,2.2,1);

			p.PutNodeInBox(n);

			testCase.verifyEqual(p.nodesQ{4}{2,3}, [n]);

			% Put the node on the axes

			% Origin
			n = Node(0,0,1);

			p.PutNodeInBox(n);

			testCase.verifyTrue(ismember(n, p.nodesQ{1}{1,1}));

			% Positive x axis
			n = Node(1,0,1);

			p.PutNodeInBox(n);

			testCase.verifyTrue(ismember(n, p.nodesQ{1}{2,1}));

			% Positive y axis
			n = Node(0,1,1);

			p.PutNodeInBox(n);

			testCase.verifyTrue(ismember(n, p.nodesQ{1}{1,2}));

			% Negative x axis
			n = Node(-1,0,1);

			p.PutNodeInBox(n);

			testCase.verifyTrue(ismember(n, p.nodesQ{4}{2,1}));

			% Negative y axis
			n = Node(0,-1,1);

			p.PutNodeInBox(n);

			testCase.verifyTrue(ismember(n, p.nodesQ{2}{1,2}));

			% Put the node on the boundaries and corners 
			% of a non-axis box

			% Put nodes around the box with corners (1,1),(1,2),(2,1),(2,2)
			% in a given quadrant

			% A vector that matches q to the sign of x or y
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];
			for q = 1:4
				% Edges
				% Bottom
				n = Node(sx(q)*1.5,sy(q)*1,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{2,2}));

				% Right
				n = Node(sx(q)*2,sy(q)*1.5,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{3,2}));

				% Left
				n = Node(sx(q)*1,sy(q)*1.5,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{2,2}));

				% Top
				n = Node(sx(q)*1.5,sy(q)*2,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{2,3}));

				% Corners
				% BottomLeft
				n = Node(sx(q)*1,sy(q)*1,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{2,2}));

				% BottomRight
				n = Node(sx(q)*1,sy(q)*2,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{2,3}));

				% TopLeft
				n = Node(sx(q)*2,sy(q)*1,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{3,2}));

				% TopRight
				n = Node(sx(q)*2,sy(q)*2,1);

				p.PutNodeInBox(n);

				testCase.verifyTrue(ismember(n, p.nodesQ{q}{3,3}));

			end

		end

		function TestGetNodeBox(testCase)

			% COMPLETE

			% Returns the contents of the box in the node partition

			t.nodeList = [];
			t.elementList = [];

			p = SpacePartition(1, 1, t);

			n1 = Node(1,1,1);

			testCase.verifyError( @() p.GetNodeBoxFromNode(n1), 'SP:GetNodeBoxFromNode:Missing');

			p.PutNodeInBox(n1);

			b = p.GetNodeBoxFromNode(n1);
			testCase.verifyEqual(b, [n1]);

			b = p.GetNodeBox(1.1,1.1);
			testCase.verifyEqual(b, [n1]);

			b = p.GetNodeBox(0.1,0.1);
			testCase.verifyEmpty(b);

			b = p.GetNodeBox(1.1,0.1);
			testCase.verifyEmpty(b);

			b = p.GetNodeBox(0.1,1.1);
			testCase.verifyEmpty(b);

			testCase.verifyError( @() p.GetNodeBox(5,5), 'SP:GetNodeBox:NoBox');
			testCase.verifyError( @() p.GetNodeBox(-1,5), 'SP:GetNodeBox:NoBox');


			% Test the other 3 quadrants
			n2 = Node(-0.2,1,1);

			p.PutNodeInBox(n2);

			b = p.GetNodeBox(-0.2,1);
			testCase.verifyEqual(b, [n2]);

			n3 = Node(-0.2,-1,1);

			p.PutNodeInBox(n3);

			b = p.GetNodeBox(-0.2,-1);
			testCase.verifyEqual(b, [n3]);

			n4 = Node(0.2,-1,1);

			p.PutNodeInBox(n4);

			b = p.GetNodeBox(0.2,-1);
			testCase.verifyEqual(b, [n4]);



			b = p.GetNodeBoxFromNode(n2);
			testCase.verifyEqual(b, [n2]);

			b = p.GetNodeBoxFromNode(n3);
			testCase.verifyEqual(b, [n3]);

			b = p.GetNodeBoxFromNode(n4);
			testCase.verifyEqual(b, [n4]);

		end

		function TestPutElementInBoxes(testCase)

			% COMPLETE
			% We now know that nodes go in the correct box
			% in every case, and can move appropriately between boxes
			% We now want to test that elements are put in their
			% repesctive element boxes correctly		

			% There are several ways to handle putting elements
			% in the intermediate boxes
			% 1. Put the element in only the boxes it passes through
			% 2. Put the element in all the boxes it could pass through
			%    given its starting and ending boxes
			% 3. Put the element in all the boxes in the rectangle
			%    created by the starting and ending boxes

			% Method 1 is best for when the box size is small compared to
			% the max/average element length. It will likely take the most
			% computing. However, it will need to be updated at every time
			% step, because an element can pass through different boxes
			% without the node moving to a new box.
			% Method 2 will put the element in more boxes than it
			% actaully is in, however, it only needs to
			% be calculated when a node moves to a new box.
			% Method 2 and 3 produce the same result when boxes are
			% larger than the max element length, since the element is in at
			% most 4 boxes.
			% Method 3 is the dumbest, and possibly the quickest to calculate
			% It will way over estimate when the boxes are small, but when they
			% are large, then it only over estimates by 1. Like with Method 2
			% it only needs to be calculated when a node moves to a new box.

			% Clearly there is a trade-off between computational effort for
			% putting in boxes and computational effort when finding neighbours.

			% At this moment, I think method 2 is the best. However, it only
			% makes an appreciable difference when the box size is 2/3 of the
			% max/avg element length (7 boxes compared to 9). When the box
			% size is roughly 1/3 of the max/avg element length, then there
			% starts to be a significant difference (10 boxes compared to 16)
			% in the worst case.

			% As such, for now, we are sticking with Method 3

			% There are three cases to test:
			% 1. Element starts and ends in the same box
			% 2. Element starts in one box and ends in any of the 8 adjacent
			% 3. Element starts in one box and ends in another quadrant

			% A dummy simulation
			t.nodeList = [];
			t.elementList = [];

			% A vector that matches q to the sign of x or y
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];

			
			for q = 1:4

				p = SpacePartition(1, 1, t);

				x1 = sx(q) * 1.1;
				x2 = sx(q) * 1.9;
				x3 = sx(q) * 2.1;

				y1 = sy(q) * 1.1;
				y2 = sy(q) * 1.9;
				y3 = sy(q) * 2.1;

				n1 = Node(x1,y1,1);
				n2 = Node(x2,y2,2);
				n3 = Node(x3,y3,3);

				% Element starts and ends in the same box
				e = Element(n1,n2,1);

				p.PutElementInBoxes(e);

				testCase.verifyEqual(p.elementsQ{q}{2,2}, [e]);

				p = SpacePartition(1, 1, t);

				% Element starts and ends in a different box
				e = Element(n1,n3,1);
				p.PutElementInBoxes(e);

				% The element must appear in 4 boxes due to method 3
				testCase.verifyEqual(p.elementsQ{q}{2,2}, [e]);
				testCase.verifyEqual(p.elementsQ{q}{2,3}, [e]);
				testCase.verifyEqual(p.elementsQ{q}{3,2}, [e]);
				testCase.verifyEqual(p.elementsQ{q}{3,3}, [e]);

			end


			% Now test that the correct boxes are entered when
			% the element starts and ends in a different quadrant

			% Starting quadrant
			for qs = 1:4
				% Ending quadrant
				for qe = 1:4
					if qs ~= qe
						p = SpacePartition(1, 1, t);

						x1 = sx(qs) * 1.1;
						x2 = sx(qe) * 1.1;

						y1 = sy(qs) * 1.1;
						y2 = sy(qe) * 1.1;

						n1 = Node(x1,y1,1);
						n2 = Node(x2,y2,2);

						e = Element(n1,n2,1);

						p.PutElementInBoxes(e);

						testCase.verifyEqual(p.elementsQ{qs}{2,2}, [e]);
						testCase.verifyEqual(p.elementsQ{qe}{2,2}, [e]);

						% Horizontal
						if (qs == 1 && qe == 4) || (qs == 4 && qe == 1)
							testCase.verifyEqual(p.elementsQ{1}{1,2}, [e]);
							testCase.verifyEqual(p.elementsQ{4}{1,2}, [e]);
						end

						if (qs == 2 && qe == 3) || (qs == 3 && qe == 2)
							testCase.verifyEqual(p.elementsQ{2}{1,2}, [e]);
							testCase.verifyEqual(p.elementsQ{3}{1,2}, [e]);
						end

						% Vertical
						if (qs == 1 && qe == 2) || (qs == 2 && qe == 1)
							testCase.verifyEqual(p.elementsQ{1}{2,1}, [e]);
							testCase.verifyEqual(p.elementsQ{2}{2,1}, [e]);
						end

						if (qs == 3 && qe == 4) || (qs == 4 && qe == 3)
							testCase.verifyEqual(p.elementsQ{3}{2,1}, [e]);
							testCase.verifyEqual(p.elementsQ{4}{2,1}, [e]);
						end

						% Diagonal
						if (qs == 1 && qe == 3) || (qs == 3 && qe == 1) || (qs == 2 && qe == 4) || (qs == 4 && qe == 2)
							testCase.verifyEqual(p.elementsQ{1}{1,1}, [e]);
							testCase.verifyEqual(p.elementsQ{2}{1,1}, [e]);
							testCase.verifyEqual(p.elementsQ{3}{1,1}, [e]);
							testCase.verifyEqual(p.elementsQ{4}{1,1}, [e]);

							% Need horizontal and vertical in this case too
							testCase.verifyEqual(p.elementsQ{1}{2,1}, [e]);
							testCase.verifyEqual(p.elementsQ{2}{2,1}, [e]);
							testCase.verifyEqual(p.elementsQ{3}{2,1}, [e]);
							testCase.verifyEqual(p.elementsQ{4}{2,1}, [e]);

							testCase.verifyEqual(p.elementsQ{1}{1,2}, [e]);
							testCase.verifyEqual(p.elementsQ{2}{1,2}, [e]);
							testCase.verifyEqual(p.elementsQ{3}{1,2}, [e]);
							testCase.verifyEqual(p.elementsQ{4}{1,2}, [e]);
						end

					end

				end

			end

		end

		function TestGetElementBox(testCase)

			% COMPLETE

			% Returns the contents of the box in the element partition

			t.nodeList = [];
			t.elementList = [];

			p = SpacePartition(1, 1, t);

			n1 = Node(0.5,0.5,1);
			n2 = Node(-0.5,-0.5,2);
			n3 = Node(0.5,-0.5,3);
			n4 = Node(-0.5,0.5,4);

			e1 = Element(n1,n2,1);
			e2 = Element(n3,n4,2);

			p.PutElementInBoxes(e1);
			p.PutElementInBoxes(e2);

			b = p.GetElementBox(0.5,0.5);
			testCase.verifyEqual(b, [e1, e2]);

			b = p.GetElementBox(-0.5,0.5);
			testCase.verifyEqual(b, [e1, e2]);

			b = p.GetElementBox(0.5,-0.5);
			testCase.verifyEqual(b, [e1, e2]);

			b = p.GetElementBox(-0.5,-0.5);
			testCase.verifyEqual(b, [e1, e2]);

			testCase.verifyError( @() p.GetElementBox(5,5), 'SP:GetElementBox:NoBox');
			testCase.verifyError( @() p.GetElementBox(-1,5), 'SP:GetElementBox:NoBox');


			b = p.GetElementBoxFromNode(n1);
			testCase.verifyEqual(b, [e1, e2]);

			b = p.GetElementBoxFromNode(n2);
			testCase.verifyEqual(b, [e1, e2]);

			b = p.GetElementBoxFromNode(n3);
			testCase.verifyEqual(b, [e1, e2]);

			b = p.GetElementBoxFromNode(n4);
			testCase.verifyEqual(b, [e1, e2]);

			% Need to remove element to test failure getting element box from node
			p.RemoveElementFromPartition(e1);
			p.RemoveElementFromPartition(e2);

			testCase.verifyError( @() p.GetElementBoxFromNode(n1), 'SP:GetElementBoxFromNode:Missing');

		end

		function TestRemoveNodeRemoveElement(testCase)

			% COMPLETE

			% Removes the contents of the node or element boxes

			t.nodeList = [];
			t.elementList = [];

			p = SpacePartition(1, 1, t);

			n1 = Node(0.5,0.5,1);
			n2 = Node(-0.5,-0.5,2);
			n3 = Node(0.5,-0.5,3);
			n4 = Node(-0.5,0.5,4);

			e1 = Element(n1,n2,1);
			e2 = Element(n3,n4,2);

			p.PutNodeInBox(n1);
			p.PutNodeInBox(n2);
			p.PutNodeInBox(n3);
			p.PutNodeInBox(n4);

			p.PutElementInBoxes(e1);
			p.PutElementInBoxes(e2);


			p.RemoveNodeFromPartition(n1);

			testCase.verifyEmpty(p.GetNodeBox(0.5,0.5));
			testCase.verifyWarning( @() p.RemoveNodeFromPartition(n1), 'SP:RemoveNodeFromPartition:NotHere');

			p.RemoveNodeFromPartition(n2);
			p.RemoveNodeFromPartition(n3);
			p.RemoveNodeFromPartition(n4);

			testCase.verifyEmpty(p.GetNodeBox(-0.5,0.5));
			testCase.verifyEmpty(p.GetNodeBox(0.5,-0.5));
			testCase.verifyEmpty(p.GetNodeBox(-0.5,-0.5));


			p.RemoveElementFromBox(1,1,1,e1);

			testCase.verifyEqual(p.GetElementBox(0.5,0.5), [e2]);
			testCase.verifyEqual(p.GetElementBox(-0.5,0.5), [e1,e2]);
			testCase.verifyEqual(p.GetElementBox(0.5,-0.5), [e1,e2]);
			testCase.verifyEqual(p.GetElementBox(-0.5,-0.5), [e1,e2]);

			testCase.verifyWarning( @() p.RemoveElementFromBox(1,1,1,e1), 'SP:RemoveElementFromBox:NotHere');
			p.RemoveElementFromBox(2,1,1,e1);
			p.RemoveElementFromBox(3,1,1,e1);
			p.RemoveElementFromBox(4,1,1,e1);

			testCase.verifyEqual(p.GetElementBox(0.5,0.5), [e2]);
			testCase.verifyEqual(p.GetElementBox(-0.5,0.5), [e2]);
			testCase.verifyEqual(p.GetElementBox(0.5,-0.5), [e2]);
			testCase.verifyEqual(p.GetElementBox(-0.5,-0.5), [e2]);


			p.RemoveElementFromPartition(e2);
			testCase.verifyEmpty( p.GetElementBox(0.5,0.5) );
			testCase.verifyEmpty( p.GetElementBox(-0.5,0.5) );
			testCase.verifyEmpty( p.GetElementBox(0.5,-0.5) );
			testCase.verifyEmpty( p.GetElementBox(-0.5,-0.5) );

		end

		function TestInitialise(testCase)

			% INCOMPLETE
			% Missing
			% 1. Precise contents of each box including
			%    empty boxes and non-existent boxes

			% Tests that the partition intialised correctly
			% Currently just checks that the quadrants have the right
			% number of occupied boxes
			% Ought to check thoroughly that each node and element are in
			% the expected boxes
			% Also ought to use a trickier situation, rather than just
			% the simulation initial condition

			t = CellGrowing(3,20,10,10,10,1,10);
			p = SpacePartition(0.5, 0.5, t);

			testCase.verifyEqual(p.dx,0.5);
			testCase.verifyEqual(p.dy,0.5);

			testCase.verifyEqual(p.simulation, t);

			testCase.verifyEqual(size(p.nodesQ{1}), [4, 3]);
			testCase.verifyEqual(size(p.nodesQ{2}), [0, 0]);
			testCase.verifyEqual(size(p.nodesQ{3}), [0, 0]);
			testCase.verifyEqual(size(p.nodesQ{4}), [0, 0]);

			testCase.verifyEqual(size(p.elementsQ{1}), [4, 3]);
			testCase.verifyEqual(size(p.elementsQ{2}), [0, 0]);
			testCase.verifyEqual(size(p.elementsQ{3}), [0, 0]);
			testCase.verifyEqual(size(p.elementsQ{4}), [0, 0]);

			% Test each node box
			testCase.verifyEqual(size(p.nodesQ{1}{1,1}), [1, 1]);
			testCase.verifyEqual(size(p.nodesQ{1}{2,1}), [1, 1]);
			testCase.verifyEqual(size(p.nodesQ{1}{3,1}), [1, 1]);
			testCase.verifyEqual(size(p.nodesQ{1}{4,1}), [1, 1]);

			testCase.verifyEmpty(   p.nodesQ{1}{1,2}  );
			testCase.verifyEmpty(   p.nodesQ{1}{2,2}  );
			testCase.verifyEmpty(   p.nodesQ{1}{3,2}  );
			testCase.verifyEmpty(   p.nodesQ{1}{4,2}  );

			testCase.verifyEqual(size(p.nodesQ{1}{1,3}), [1, 1]);
			testCase.verifyEqual(size(p.nodesQ{1}{2,3}), [1, 1]);
			testCase.verifyEqual(size(p.nodesQ{1}{3,3}), [1, 1]);
			testCase.verifyEqual(size(p.nodesQ{1}{4,3}), [1, 1]);

			% Test each element box
			testCase.verifyEqual(size(p.elementsQ{1}{1,1}), [1, 2]);
			testCase.verifyEqual(size(p.elementsQ{1}{2,1}), [1, 2]);
			testCase.verifyEqual(size(p.elementsQ{1}{3,1}), [1, 2]);
			testCase.verifyEqual(size(p.elementsQ{1}{4,1}), [1, 2]);

			testCase.verifyEqual(size(p.elementsQ{1}{1,2}), [1, 1]);
			testCase.verifyEmpty(   p.elementsQ{1}{2,2}  );
			testCase.verifyEmpty(   p.elementsQ{1}{3,2}  );
			testCase.verifyEqual(size(p.elementsQ{1}{4,2}), [1, 1]);

			testCase.verifyEqual(size(p.elementsQ{1}{1,3}), [1, 2]);
			testCase.verifyEqual(size(p.elementsQ{1}{2,3}), [1, 2]);
			testCase.verifyEqual(size(p.elementsQ{1}{3,3}), [1, 2]);
			testCase.verifyEqual(size(p.elementsQ{1}{4,3}), [1, 2]);

		end

		function TestUpdateBoxForNode(testCase)
			% COMPLETE
			% Given that TestPutNodeInBox passes, we know
			% the node will always be in the correct box

			% Now we need to make sure that when it moves from
			% one box to the next, that move is recorded
			% properly by p.UpdateBoxForNode

			% A dummy simulation to satisfy the initialisation
			t.nodeList = [];
			t.elementList = [];

			% For each quadrant, put a node in the centre of a non axis box
			% Then move it to a position in another box of the same quadrant
			newPosition = [0.5,0.5; 0.5,1.5; 0.5,2.5; 1.5,0.5; 1.5,2.5; 2.5,0.5; 2.5,1.5; 2.5,2.5];
			I = [1,1,1,2,2,3,3,3];
			J = [1,2,3,1,3,1,2,3];

			% A vector that matches q to the sign of x or y
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];

			% For each quadrant, jump from box 2,2 to all of I(k),J(k)
			for q = 1:4

				for k=1:8
					p = SpacePartition(1, 1, t);
					nx = sx(q)*1.5;
					ny = sy(q)*1.5;
					n = Node(nx,ny,1);
					p.PutNodeInBox(n);

					x = sx(q) * newPosition(k,1);
					y = sy(q) * newPosition(k,2);
					n.MoveNode([x,y]);
					p.UpdateBoxForNode(n);

					testCase.verifyEqual( [n], p.nodesQ{q}{I(k),J(k)} );
					testCase.verifyEmpty(p.nodesQ{q}{2,2});
				end

			end

			% For each quadrant, put a node in an axis box, and move it to another quadrant

			% Starting quadrant
			for qs = 1:4
				% Ending quadrant
				for qe = 1:4
					if qs ~= qe
						p = SpacePartition(1, 1, t);
						nx = sx(qs)*0.5;
						ny = sy(qs)*0.5;
						n = Node(nx,ny,1);
						p.PutNodeInBox(n);

						x = sx(qe)*0.5;
						y = sy(qe)*0.5;
						n.MoveNode([x,y]);
						p.UpdateBoxForNode(n);

						testCase.verifyEqual( [n], p.nodesQ{qe}{1,1} );
						testCase.verifyEmpty(p.nodesQ{qs}{1,1});
					end

				end

			end

		end

		function TestUpdateBoxForNodeAdjusted(testCase)
			% COMPLETE
			% Identical to TestUpdateBoxForNode except for
			% using Adjust

			% A dummy simulation to satisfy the initialisation
			t.nodeList = [];
			t.elementList = [];

			% For each quadrant, put a node in the centre of a non axis box
			% Then move it to a position in another box of the same quadrant
			newPosition = [0.5,0.5; 0.5,1.5; 0.5,2.5; 1.5,0.5; 1.5,2.5; 2.5,0.5; 2.5,1.5; 2.5,2.5];
			I = [1,1,1,2,2,3,3,3];
			J = [1,2,3,1,3,1,2,3];

			% A vector that matches q to the sign of x or y
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];

			% For each quadrant, jump from box 2,2 to all of I(k),J(k)
			for q = 1:4

				for k=1:8
					p = SpacePartition(1, 1, t);
					nx = sx(q)*1.5;
					ny = sy(q)*1.5;
					n = Node(nx,ny,1);
					p.PutNodeInBox(n);

					x = sx(q) * newPosition(k,1);
					y = sy(q) * newPosition(k,2);
					n.AdjustPosition([x,y]);
					p.UpdateBoxForNodeAdjusted(n);

					testCase.verifyEqual( [n], p.nodesQ{q}{I(k),J(k)} );
					testCase.verifyEmpty(p.nodesQ{q}{2,2});
				end

			end

			% For each quadrant, put a node in an axis box, and move it to another quadrant

			% Starting quadrant
			for qs = 1:4
				% Ending quadrant
				for qe = 1:4
					if qs ~= qe
						p = SpacePartition(1, 1, t);
						nx = sx(qs)*0.5;
						ny = sy(qs)*0.5;
						n = Node(nx,ny,1);
						p.PutNodeInBox(n);

						x = sx(qe)*0.5;
						y = sy(qe)*0.5;
						n.AdjustPosition([x,y]);
						p.UpdateBoxForNodeAdjusted(n);

						testCase.verifyEqual( [n], p.nodesQ{qe}{1,1} );
						testCase.verifyEmpty(p.nodesQ{qs}{1,1});
					end

				end

			end

		end

		function TestUpdateBoxesForElementsUsingNode(testCase)

			% INCOMPLETE
			% Some of the scenarios are not implemented
			% The tests around lines 650 - 750 (as of 6/6/2020)
			% don't behave precisely as intended, but the behaviour
			% is consistent. Read comments around that area for details

			% This is arguably the most important test because
			% without this functioning properly, the whole point
			% of the space partitioning falls down (or at least
			% the part where we save orders of magnitude of time)

			% Should also test UpdateBoxesForElements, but since we are
			% updating the element only when a node shifts box
			% there is no need at this stage

			% Need to test:
			% 1. Element in 1 box, nodes don't leave box
			% 2. Element in 1 box, one or both nodes leave box
			% 3. Element in multiple boxes in one quadrant, nodes don't leave box
			% 4. Element in multiple boxes in one quadrant, 
			%    one or both leave, but stay in same quadrant
			% 5. Element in multiple boxes in one quadrant, 
			%    one or both leave, but move to different quadrant
			% 6. Element in multiple boxes in different quadrants
			%    nodes don't leave box
			% 7. Element in multiple boxes in different quadrants
			%    one or both leave, but stay in same quadrant
			% 8. Element in multiple boxes in different quadrants
			%    one or both leave, but move to different quadrant

			% This will be a long one...

			% A dummy simulation
			t.nodeList = [];
			t.elementList = [];

			% A vector that matches q to the sign of x or y
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];


			% Otherwise we are flooded with warnings
			warning('off','all')

			for q = 1:4

				p = SpacePartition(1, 1, t);

				x1 = sx(q) * 1.1;
				x2 = sx(q) * 1.9;
				x3 = sx(q) * 2.1;
				x4 = sx(q) * 2.1;

				y1 = sy(q) * 1.1;
				y2 = sy(q) * 1.9;
				y3 = sy(q) * 0.1;
				y4 = sy(q) * 0.9;

				n1 = Node(x1,y1,1);
				n2 = Node(x2,y2,2);
				n3 = Node(x3,y3,3);
				n4 = Node(x4,y4,4);

				p.PutNodeInBox(n1);
				p.PutNodeInBox(n2);
				p.PutNodeInBox(n3);
				p.PutNodeInBox(n4);
			
				% These will be in the partition and moving
				et = Element(n1,n2,1);
				eb = Element(n3,n4,2);

				% These are just around to make the cell
				el = Element(n4,n1,3);
				er = Element(n2,n3,4);

				c = Cell(NoCellCycle, [et,eb,el,er], 1);

				%-------------------------------------------------
				% 1. Element in 1 box, nodes don't leave box
				%-------------------------------------------------

				p.PutElementInBoxes(et);

				xn1 = sx(q) * 1.3;
				xn2 = sx(q) * 1.7;

				yn1 = sy(q) * 1.3;
				yn2 = sy(q) * 1.7;

				n1.MoveNode([xn1, yn1]);
				p.UpdateBoxForNode(n1);

				n2.MoveNode([xn2, yn2]);
				p.UpdateBoxForNode(n2);

				testCase.verifyEqual(p.elementsQ{q}{2,2}, [et]);

				% A bit over the top, but this needs to be the case
				% Can't test every possible index, so test the adjacent
				% boxes

				% These will exist, but are empty
				testCase.verifyEmpty(p.elementsQ{q}{1,1});
				testCase.verifyEmpty(p.elementsQ{q}{1,2});
				testCase.verifyEmpty(p.elementsQ{q}{2,1});

				% These won't exist
				testCase.verifyError(@() p.elementsQ{q}{2,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,2}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,1}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{1,3}, 'MATLAB:badsubscript');

				%-------------------------------------------------
				% 2. Element in 1 box, one or both nodes leave box
				%-------------------------------------------------

				% One node leaves
				%-----------------
				xn1 = sx(q) * 0.9;
				yn1 = sy(q) * 1.3;

				n1.MoveNode([xn1, yn1]);
				p.UpdateBoxForNode(n1);

				% When the node moves to a new box, it implicitly adds any
				% of its elements that may be missing from the partition
				% I'm not sure if this is a good idea or not, but I can't
				% think of a better way to handle it right now. Better make
				% it integral to the test incase it impacts anything in the future
				% This happens as a consequence of IsElementInternal. A better
				% way might be to put a flag in stating if the element is considered
				% part of the space partition.

				testCase.verifyEqual(p.elementsQ{q}{2,2}, [et]);
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{1,2}));
				testCase.verifyTrue(ismember(el, p.elementsQ{q}{1,2})); 	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{1,2}), [1 2]);	% << This will change
				testCase.verifyEqual(p.elementsQ{q}{1,1}, [el]);			% << This will change
				
				testCase.verifyEmpty(p.elementsQ{q}{2,1});

				testCase.verifyError(@() p.elementsQ{q}{2,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,2}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,1}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{1,3}, 'MATLAB:badsubscript');

				
				% Both nodes leave
				%-----------------
				p.PutElementInBoxes(eb);

				xn3 = sx(q) * 1.9;
				yn3 = sy(q) * 0.1;

				xn4 = sx(q) * 2.1;
				yn4 = sy(q) * 1.1;

				n3.MoveNode([xn3, yn3]);
				n4.MoveNode([xn4, yn4]);

				% Will throw warnings because of inmplicit adding of elements
				% This test doesn't catch any warnings for some reason...
				% testCase.verifyWarning( @() p.UpdateBoxForNode(), 'SP:RemoveElementFromBox:DeleteFail');
				% testCase.verifyWarning( @() p.UpdateBoxForNode(n4), 'SP:RemoveElementFromBox:DeleteFail');
					
				p.UpdateBoxForNode(n3);
				p.UpdateBoxForNode(n4);
				
				testCase.verifyEqual(p.elementsQ{q}{2,1}, [eb]);
				testCase.verifyTrue(ismember(eb, p.elementsQ{q}{2,2}));
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,2}));
				testCase.verifyEqual(size(p.elementsQ{q}{2,2}), [1,2]);
				testCase.verifyEqual(p.elementsQ{q}{3,1}, [eb]);
				testCase.verifyEqual(p.elementsQ{q}{3,2}, [eb]);
				
				%--------------------------------------------------------------------
				% 3. Element in multiple boxes in one quadrant, nodes don't leave box
				%--------------------------------------------------------------------


				% I think this is proven from above


				%--------------------------------------------------
				% 4. Element in multiple boxes in one quadrant, 
				%    one or both leave, but stay in same quadrant
				%--------------------------------------------------

				% One leaves
				%-----------
				xn4 = sx(q) * 1.9;
				yn4 = sy(q) * 1.1;

				n4.MoveNode([xn4, yn4]);

				p.UpdateBoxForNode(n4);

				testCase.verifyEqual(p.elementsQ{q}{2,1}, [eb]);
				testCase.verifyTrue(ismember(eb, p.elementsQ{q}{2,2}));

				testCase.verifyEmpty(p.elementsQ{q}{1,1});
				testCase.verifyEmpty(p.elementsQ{q}{3,1});
				testCase.verifyEmpty(p.elementsQ{q}{3,2});

				% Both leave
				%-----------
				xn1 = sx(q) * 0.9;
				yn1 = sy(q) * 0.9;

				xn2 = sx(q) * 1.7;
				yn2 = sy(q) * 2.3;

				n1.MoveNode([xn1, yn1]);
				p.UpdateBoxForNode(n1);

				n2.MoveNode([xn2, yn2]);
				p.UpdateBoxForNode(n2);

				% When the node moves to a new box, it implicitly adds any
				% of its elements that may be missing from the partition.
				% This is a consequence of IsElementInternal, and is only an
				% issue for the test (at this point)

				testCase.verifyTrue(ismember(et, p.elementsQ{q}{1,1}));
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{1,2}));
				testCase.verifyTrue(ismember(el, p.elementsQ{q}{1,1})); 	% << This will change
				testCase.verifyTrue(ismember(el, p.elementsQ{q}{1,2})); 	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{1,1}), [1 2]);	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{1,2}), [1 2]);	% << This will change
				testCase.verifyEqual(p.elementsQ{q}{1,3}, [et]);

				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,1}));
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,2}));

				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,3}));
				testCase.verifyTrue(ismember(er, p.elementsQ{q}{2,3})); 	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{2,3}), [1 2]);	% << This will change

				testCase.verifyEmpty(p.elementsQ{q}{3,1});
				testCase.verifyEmpty(p.elementsQ{q}{3,2});
				testCase.verifyEmpty(p.elementsQ{q}{3,3});

			end

			
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];
			% Now looking at multiple quadrants
			% Starting quadrant
			for qs = 1:4
				% Ending quadrant
				for qe = 1:4
					if qs ~= qe

						p = SpacePartition(1, 1, t);

						x1 = sx(qs) * 0.1;
						y1 = sy(qs) * 0.9;

						x2 = sx(qs) * 0.9;
						y2 = sy(qs) * 0.9;

						x3 = sx(qs) * 0.1;
						y3 = sy(qs) * 0.1;

						x4 = sx(qs) * 1.1;
						y4 = sy(qs) * 0.1;

						n1 = Node(x1,y1,1);
						n2 = Node(x2,y2,2);
						n3 = Node(x3,y3,3);
						n4 = Node(x4,y4,4);

						p.PutNodeInBox(n1);
						p.PutNodeInBox(n2);
						p.PutNodeInBox(n3);
						p.PutNodeInBox(n4);
					
						% These will be in the partition and moving
						et = Element(n1,n2,1);
						eb = Element(n3,n4,2);

						% These are just around to make the cell
						el = Element(n4,n1,3);
						er = Element(n2,n3,4);

						c = Cell(NoCellCycle, [et,eb,el,er], 1);


						%--------------------------------------------------
						% 5. Element in multiple boxes in one quadrant, 
						%    one or both leave, but move to different quadrant
						%--------------------------------------------------

						p.PutElementInBoxes(et);
						p.PutElementInBoxes(eb);

						xn1 = sx(qe) * 0.1;
						yn1 = sy(qe) * 0.9;

						xn2 = sx(qs) * 0.8;
						yn2 = sy(qs) * 0.8;

						xn3 = sx(qe) * 0.1;
						yn3 = sy(qe) * 0.1;

						xn4 = sx(qe) * 1.1;
						yn4 = sy(qe) * 0.1;


						n1.MoveNode([xn1, yn1]);
						p.UpdateBoxForNode(n1);

						n2.MoveNode([xn2, yn2]);
						p.UpdateBoxForNode(n2);

						n3.MoveNode([xn3, yn3]);
						p.UpdateBoxForNode(n3);

						n4.MoveNode([xn4, yn4]);
						p.UpdateBoxForNode(n4);

						% Check top element
						testCase.verifyTrue(ismember(et, p.elementsQ{qs}{1,1}) );
						testCase.verifyTrue(ismember(et, p.elementsQ{qe}{1,1}) );

						% Check bottom element
						testCase.verifyTrue(~ismember(eb, p.elementsQ{qs}{1,1}) );
						testCase.verifyEmpty(p.elementsQ{qs}{2,1});

						testCase.verifyTrue(ismember(eb, p.elementsQ{qe}{1,1}) );
						testCase.verifyTrue(ismember(eb, p.elementsQ{qe}{2,1}) );
						


						%--------------------------------------------------
						% 6. Element in multiple boxes in different quadrants
						%    nodes don't leave box
						%--------------------------------------------------


						%--------------------------------------------------
						% 7. Element in multiple boxes in different quadrants
						%    one or both leave, but stay in same quadrant
						%--------------------------------------------------


						%--------------------------------------------------
						% 8. Element in multiple boxes in different quadrants
						%    one or both leave, but move to different quadrant
						%--------------------------------------------------
					end

				end

			end

			warning('on','all')

		end

		function TestUpdateBoxesForElementsUsingNodeAdjusted(testCase)

			% This is identical to TestUpdateBoxesForElementsUsingNode
			% except it uses adjust node rather than move node
			t.nodeList = [];
			t.elementList = [];

			% A vector that matches q to the sign of x or y
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];


			% Otherwise we are flooded with warnings
			warning('off','all')

			for q = 1:4

				p = SpacePartition(1, 1, t);

				x1 = sx(q) * 1.1;
				x2 = sx(q) * 1.9;
				x3 = sx(q) * 2.1;
				x4 = sx(q) * 2.1;

				y1 = sy(q) * 1.1;
				y2 = sy(q) * 1.9;
				y3 = sy(q) * 0.1;
				y4 = sy(q) * 0.9;

				n1 = Node(x1,y1,1);
				n2 = Node(x2,y2,2);
				n3 = Node(x3,y3,3);
				n4 = Node(x4,y4,4);

				p.PutNodeInBox(n1);
				p.PutNodeInBox(n2);
				p.PutNodeInBox(n3);
				p.PutNodeInBox(n4);
			
				% These will be in the partition and moving
				et = Element(n1,n2,1);
				eb = Element(n3,n4,2);

				% These are just around to make the cell
				el = Element(n4,n1,3);
				er = Element(n2,n3,4);

				c = Cell(NoCellCycle, [et,eb,el,er], 1);

				%-------------------------------------------------
				% 1. Element in 1 box, nodes don't leave box
				%-------------------------------------------------

				p.PutElementInBoxes(et);

				xn1 = sx(q) * 1.3;
				xn2 = sx(q) * 1.7;

				yn1 = sy(q) * 1.3;
				yn2 = sy(q) * 1.7;

				n1.AdjustPosition([xn1, yn1]);
				p.UpdateBoxForNodeAdjusted(n1);

				n2.AdjustPosition([xn2, yn2]);
				p.UpdateBoxForNodeAdjusted(n2);

				testCase.verifyEqual(p.elementsQ{q}{2,2}, [et]);

				% A bit over the top, but this needs to be the case
				% Can't test every possible index, so test the adjacent
				% boxes

				% These will exist, but are empty
				testCase.verifyEmpty(p.elementsQ{q}{1,1});
				testCase.verifyEmpty(p.elementsQ{q}{1,2});
				testCase.verifyEmpty(p.elementsQ{q}{2,1});

				% These won't exist
				testCase.verifyError(@() p.elementsQ{q}{2,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,2}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,1}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{1,3}, 'MATLAB:badsubscript');

				%-------------------------------------------------
				% 2. Element in 1 box, one or both nodes leave box
				%-------------------------------------------------

				% One node leaves
				%-----------------
				xn1 = sx(q) * 0.9;
				yn1 = sy(q) * 1.3;

				n1.AdjustPosition([xn1, yn1]);
				p.UpdateBoxForNodeAdjusted(n1);

				% When the node moves to a new box, it implicitly adds any
				% of its elements that may be missing from the partition
				% I'm not sure if this is a good idea or not, but I can't
				% think of a better way to handle it right now. Better make
				% it integral to the test incase it impacts anything in the future
				% This happens as a consequence of IsElementInternal. A better
				% way might be to put a flag in stating if the element is considered
				% part of the space partition.

				testCase.verifyEqual(p.elementsQ{q}{2,2}, [et]);
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{1,2}));
				testCase.verifyTrue(ismember(el, p.elementsQ{q}{1,2})); 	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{1,2}), [1 2]);	% << This will change
				testCase.verifyEqual(p.elementsQ{q}{1,1}, [el]);			% << This will change
				
				testCase.verifyEmpty(p.elementsQ{q}{2,1});

				testCase.verifyError(@() p.elementsQ{q}{2,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,3}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,2}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{3,1}, 'MATLAB:badsubscript');
				testCase.verifyError(@() p.elementsQ{q}{1,3}, 'MATLAB:badsubscript');

				
				% Both nodes leave
				%-----------------
				p.PutElementInBoxes(eb);

				xn3 = sx(q) * 1.9;
				yn3 = sy(q) * 0.1;

				xn4 = sx(q) * 2.1;
				yn4 = sy(q) * 1.1;

				n3.AdjustPosition([xn3, yn3]);
				n4.AdjustPosition([xn4, yn4]);

				% Will throw warnings because of inmplicit adding of elements
				% This test doesn't catch any warnings for some reason...
				% testCase.verifyWarning( @() p.UpdateBoxForNodeAdjusted(), 'SP:RemoveElementFromBox:DeleteFail');
				% testCase.verifyWarning( @() p.UpdateBoxForNodeAdjusted(n4), 'SP:RemoveElementFromBox:DeleteFail');
					
				p.UpdateBoxForNodeAdjusted(n3);
				p.UpdateBoxForNodeAdjusted(n4);
				
				testCase.verifyEqual(p.elementsQ{q}{2,1}, [eb]);
				testCase.verifyTrue(ismember(eb, p.elementsQ{q}{2,2}));
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,2}));
				testCase.verifyEqual(size(p.elementsQ{q}{2,2}), [1,2]);
				testCase.verifyEqual(p.elementsQ{q}{3,1}, [eb]);
				testCase.verifyEqual(p.elementsQ{q}{3,2}, [eb]);
				
				%--------------------------------------------------------------------
				% 3. Element in multiple boxes in one quadrant, nodes don't leave box
				%--------------------------------------------------------------------


				% I think this is proven from above


				%--------------------------------------------------
				% 4. Element in multiple boxes in one quadrant, 
				%    one or both leave, but stay in same quadrant
				%--------------------------------------------------

				% One leaves
				%-----------
				xn4 = sx(q) * 1.9;
				yn4 = sy(q) * 1.1;

				n4.AdjustPosition([xn4, yn4]);

				p.UpdateBoxForNodeAdjusted(n4);

				testCase.verifyEqual(p.elementsQ{q}{2,1}, [eb]);
				testCase.verifyTrue(ismember(eb, p.elementsQ{q}{2,2}));

				testCase.verifyEmpty(p.elementsQ{q}{1,1});
				testCase.verifyEmpty(p.elementsQ{q}{3,1});
				testCase.verifyEmpty(p.elementsQ{q}{3,2}); % << FAILS

				% Both leave
				%-----------
				xn1 = sx(q) * 0.9;
				yn1 = sy(q) * 0.9;

				xn2 = sx(q) * 1.7;
				yn2 = sy(q) * 2.3;

				n1.AdjustPosition([xn1, yn1]);
				p.UpdateBoxForNodeAdjusted(n1);

				n2.AdjustPosition([xn2, yn2]);
				p.UpdateBoxForNodeAdjusted(n2);

				% When the node moves to a new box, it implicitly adds any
				% of its elements that may be missing from the partition.
				% This is a consequence of IsElementInternal, and is only an
				% issue for the test (at this point)

				testCase.verifyTrue(ismember(et, p.elementsQ{q}{1,1}));
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{1,2}));
				testCase.verifyTrue(ismember(el, p.elementsQ{q}{1,1})); 	% << This will change
				testCase.verifyTrue(ismember(el, p.elementsQ{q}{1,2})); 	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{1,1}), [1 2]);	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{1,2}), [1 2]);	% << This will change
				testCase.verifyEqual(p.elementsQ{q}{1,3}, [et]);

				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,1}));
				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,2}));

				testCase.verifyTrue(ismember(et, p.elementsQ{q}{2,3}));
				testCase.verifyTrue(ismember(er, p.elementsQ{q}{2,3})); 	% << This will change
				testCase.verifyEqual( size(p.elementsQ{q}{2,3}), [1 2]);	% << This will change

				testCase.verifyEmpty(p.elementsQ{q}{3,1});
				testCase.verifyEmpty(p.elementsQ{q}{3,2}); % << FAILS
				testCase.verifyEmpty(p.elementsQ{q}{3,3});

			end

			
			sx = [1, 1, -1, -1];
			sy = [1, -1, -1, 1];
			% Now looking at multiple quadrants
			% Starting quadrant
			for qs = 1:4
				% Ending quadrant
				for qe = 1:4
					if qs ~= qe

						p = SpacePartition(1, 1, t);

						x1 = sx(qs) * 0.1;
						y1 = sy(qs) * 0.9;

						x2 = sx(qs) * 0.9;
						y2 = sy(qs) * 0.9;

						x3 = sx(qs) * 0.1;
						y3 = sy(qs) * 0.1;

						x4 = sx(qs) * 1.1;
						y4 = sy(qs) * 0.1;

						n1 = Node(x1,y1,1);
						n2 = Node(x2,y2,2);
						n3 = Node(x3,y3,3);
						n4 = Node(x4,y4,4);

						p.PutNodeInBox(n1);
						p.PutNodeInBox(n2);
						p.PutNodeInBox(n3);
						p.PutNodeInBox(n4);
					
						% These will be in the partition and moving
						et = Element(n1,n2,1);
						eb = Element(n3,n4,2);

						% These are just around to make the cell
						el = Element(n4,n1,3);
						er = Element(n2,n3,4);

						c = Cell(NoCellCycle, [et,eb,el,er], 1);


						%--------------------------------------------------
						% 5. Element in multiple boxes in one quadrant, 
						%    one or both leave, but move to different quadrant
						%--------------------------------------------------

						p.PutElementInBoxes(et);
						p.PutElementInBoxes(eb);

						xn1 = sx(qe) * 0.1;
						yn1 = sy(qe) * 0.9;

						xn2 = sx(qs) * 0.8;
						yn2 = sy(qs) * 0.8;

						xn3 = sx(qe) * 0.1;
						yn3 = sy(qe) * 0.1;

						xn4 = sx(qe) * 1.1;
						yn4 = sy(qe) * 0.1;


						n1.AdjustPosition([xn1, yn1]);
						p.UpdateBoxForNodeAdjusted(n1);

						n2.AdjustPosition([xn2, yn2]);
						p.UpdateBoxForNodeAdjusted(n2);

						n3.AdjustPosition([xn3, yn3]);
						p.UpdateBoxForNodeAdjusted(n3);

						n4.AdjustPosition([xn4, yn4]);
						p.UpdateBoxForNodeAdjusted(n4);

						% Check top element
						testCase.verifyTrue(ismember(et, p.elementsQ{qs}{1,1}) );
						testCase.verifyTrue(ismember(et, p.elementsQ{qe}{1,1}) );

						% Check bottom element
						testCase.verifyTrue(~ismember(eb, p.elementsQ{qs}{1,1}) );
						testCase.verifyEmpty(p.elementsQ{qs}{2,1});

						testCase.verifyTrue(ismember(eb, p.elementsQ{qe}{1,1}) );
						testCase.verifyTrue(ismember(eb, p.elementsQ{qe}{2,1}) );
						


						%--------------------------------------------------
						% 6. Element in multiple boxes in different quadrants
						%    nodes don't leave box
						%--------------------------------------------------


						%--------------------------------------------------
						% 7. Element in multiple boxes in different quadrants
						%    one or both leave, but stay in same quadrant
						%--------------------------------------------------


						%--------------------------------------------------
						% 8. Element in multiple boxes in different quadrants
						%    one or both leave, but move to different quadrant
						%--------------------------------------------------
					end

				end

			end

			warning('on','all')

		end

		function TestGettingBoxes(testCase)

			% INCOMPLETE
			% Missing:
			% 1. Nearly everything...

			% Sometimes you need to get adjacent boxes

			t = CellGrowing(20,20,10,10,10,1,10);
			p = SpacePartition(1, 1, t);

			n = t.nodeList(10);

			bn = p.GetNodeBoxFromNode(n);

			% The node should be in the box
			testCase.verifyTrue(ismember(n, bn));

			%... and the box should have the correct indices
			testCase.verifyEqual(bn, p.nodesQ{1}{3,2});

			% A size check to make sure it's all in order
			testCase.verifyEqual(size(bn),[1, 2]);

			be = p.GetElementBoxFromNode(n);

			testCase.verifyEqual(be, p.elementsQ{1}{3,2});
			testCase.verifyEqual(size(be),[1, 3]);

			bnu = p.GetAdjacentNodeBoxFromNode(n, [0, 1]);
			testCase.verifyTrue(isempty(bnu));

		end

		function TestGettingNeighbours(testCase)

			load('testState.mat');

			% Need to put the nodes in order so we can find the one we want
			[~,idx] = sort([t.nodeList.x]);

			t.nodeList = t.nodeList(idx);

			p = SpacePartition(1,1,t);

			% If the partition is correct, the following nodes
			% are close to a collision with an element

			n1 = t.nodeList(55);
			testCase.verifyEqual(n1.position, [2.6628 1.1181], 'AbsTol', 1e-4);

			n2 = t.nodeList(56);
			testCase.verifyEqual(n2.position, [2.6850 1.0843], 'AbsTol', 1e-4);

			n3 = t.nodeList(72);
			testCase.verifyEqual(n3.position, [4.2624 -0.3782], 'AbsTol', 1e-4);

			n4 = t.nodeList(73);
			testCase.verifyEqual(n4.position, [4.3251 -0.5368], 'AbsTol', 1e-4);

			% n2 is close to the bottom boundary,
			% the rest are at least 0.1 from a boundary

			% Paranoia testing
			b = p.GetNodeBoxFromNode(n1);
			testCase.verifyEqual(size(b), [1, 4]);
			testCase.verifyTrue(ismember(n1, b));
			testCase.verifyTrue(ismember(n2, b));

			b = p.GetNodeBoxFromNode(n2);
			testCase.verifyEqual(size(b), [1, 4]);
			testCase.verifyTrue(ismember(n1, b));
			testCase.verifyTrue(ismember(n2, b));

			b = p.GetNodeBoxFromNode(n3);
			testCase.verifyEqual(size(b), [1, 2]);
			testCase.verifyTrue(ismember(n3, b));
			testCase.verifyTrue(ismember(n4, b));

			b = p.GetNodeBoxFromNode(n4);
			testCase.verifyEqual(size(b), [1, 2]);
			testCase.verifyTrue(ismember(n3, b));
			testCase.verifyTrue(ismember(n4, b));

			

			% We now want to check and see that the adjacent detection gets
			% the correct elements
			neighbours = p.GetNeighbouringElements(n1, 0.1);

			% The only neighbouring element should be the one from n2 to
			n11 = n2;
			n12 = t.nodeList(57); % Node neighbour 2
			% It's a little tricky to get it
			e = Element.empty();
			for i=1:3
				if n2.elementList(i).GetOtherNode(n2) == n12
					e = n2.elementList(i);
				end
			end
			% Should make sure it gets something, but oh well

			testCase.verifyEqual([e], neighbours);

			% Do the above again for n2
			neighbours = p.GetNeighbouringElements(n2, 0.1);

			n21 = n1;
			n22 = t.nodeList(54);
			% It's a little tricky to get it
			e = Element.empty();
			for i=1:3
				if n1.elementList(i).GetOtherNode(n1) == n22
					e = n1.elementList(i);
				end
			end
			
			testCase.verifyEqual([e], neighbours);

			% And we want to do the same for n3 and n4

			% Do it for n3
			neighbours = p.GetNeighbouringElements(n3, 0.1);

			% The only neighbouring element should be the one from n2 to
			n31 = n4;
			n32 = t.nodeList(74); % Node neighbour 2
			% It's a little tricky to get it
			e = Element.empty();
			for i=1:3
				if n4.elementList(i).GetOtherNode(n4) == n32
					e = n4.elementList(i);
				end
			end

			testCase.verifyEqual([e], neighbours);
			
			% Do it for n4
			neighbours = p.GetNeighbouringElements(n4, 0.1);

			% The only neighbouring element should be the one from n2 to
			n41 = n3;
			n42 = t.nodeList(69); % Node neighbour 2
			% It's a little tricky to get it
			e = Element.empty();
			for i=1:3
				if n3.elementList(i).GetOtherNode(n3) == n42
					e = n3.elementList(i);
				end
			end

			testCase.verifyEqual([e], neighbours);

			% If we get here, then the specific nodes find their correct
			% adjacent elements. We also should check that it _doesnt_ find
			% elements when there should be none. This will be the case for
			% all nodes, except the 4 from above

			for i = 1:length(t.nodeList)
				n = t.nodeList(i);
				if n ~= n1 && n ~= n2 && n ~= n3 && n ~= n4
					neighbours = p.GetNeighbouringElements(n, 0.1);
					testCase.verifyTrue(isempty(neighbours));
				end
			end

		end

		function TestAssembleNeighbours(testCase)

			% INCOMPLETE
			% Need to test that it picks up elements when the node is
			% close to a boundary

			load('testState.mat');

			% Need to put the nodes in order so we can find the one we want
			[~,idx] = sort([t.nodeList.x]);

			t.nodeList = t.nodeList(idx);

			p = SpacePartition(1,1,t);

			% This node should have some elements close by, and it is
			% also close to the edge of a box

			n = t.nodeList(56);

			b = p.AssembleCandidateElements(n, 0.1);

			% Don't want the node's own elements in the mix
			testCase.verifyEqual(sum(ismember(b, n.elementList)), 0);

		end

		function TestQuickUnique(testCase)

			% COMPLETE (probably)
			% Need to make sure it gets all duplicates

			% Dummy simulation for the partition
			t.nodeList = [];
			t.elementList = [];

			p = SpacePartition(1, 1, t);

			a = [1,1,1,1,1,1,1,1,1];

			a = p.QuickUnique(a);

			testCase.verifyEqual(a, [1]);

			a = [-1,1,1,1,1,1,1,1,1];

			a = p.QuickUnique(a);

			testCase.verifyEqual(a, [-1, 1]);

			a = [1,2,3,4,5,6,7,8,9];

			a = p.QuickUnique(a);

			testCase.verifyEqual(a, [1,2,3,4,5,6,7,8,9]);

			a = [1,1,2,3,4,5,6,7,8,9,2,3,4,5,6,7,8,9];

			a = p.QuickUnique(a);

			testCase.verifyEqual(a, [1,2,3,4,5,6,7,8,9]);

			a = [1];

			a = p.QuickUnique(a);

			testCase.verifyEqual(a, [1]);

			a = [];

			a = p.QuickUniqueEmpty(a);

			testCase.verifyEqual(a, []);

		end

		function TestSpacePartitionAfterDivision(testCase)

			t = CellGrowing(1,3,3,20,10,1,10);

			% Set the only stochastic parts so it is completely
			% reproducible
			t.cellList.CellCycleModel.pausePhaseLength = 1.00001;
			t.cellList.CellCycleModel.growingPhaseLength = 1;
			t.cellList.CellCycleModel.age = 0;

			t.RunToTime(2)
			t.NTimeSteps(2);

			% At this point the cell has just divided.

			% Under the controlled conditions, the partition must
			% be in this precise state:

			testCase.verifyEqual(size(t.boxes.nodesQ{1}), [2, 3]);
			testCase.verifyEqual(size(t.boxes.nodesQ{2}), [2, 1]);
			testCase.verifyEqual(size(t.boxes.nodesQ{3}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.nodesQ{4}), [1, 3]);

			testCase.verifyEqual(size(t.boxes.elementsQ{1}), [2, 3]);
			testCase.verifyEqual(size(t.boxes.elementsQ{2}), [2, 1]);
			testCase.verifyEqual(size(t.boxes.elementsQ{3}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.elementsQ{4}), [1, 3]);


			% Check the sizes of the boxes
			% Check node quadrants
			testCase.verifyTrue(isempty(t.boxes.nodesQ{1}{1,1}));
			testCase.verifyTrue(isempty(t.boxes.nodesQ{1}{1,2}));
			testCase.verifyTrue(isempty(t.boxes.nodesQ{1}{2,1}));
			testCase.verifyTrue(isempty(t.boxes.nodesQ{1}{2,2}));

			testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{1,1}));
			testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{1,2}));


			% Check the sizes are correct
			testCase.verifyEqual(size(t.boxes.nodesQ{1}{1,3}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.nodesQ{1}{2,3}), [1, 1]);

			testCase.verifyEqual(size(t.boxes.nodesQ{2}{1,1}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.nodesQ{2}{2,1}), [1, 1]);

			testCase.verifyEqual(size(t.boxes.nodesQ{3}{1,1}), [1, 1]);

			testCase.verifyEqual(size(t.boxes.nodesQ{4}{1,3}), [1, 1]);

			
			% Need to update this test to reflect the left and right elements
			% now are permitted to be external in a CellJoined simulation

			% Check element quadrants
			% Note that only external elements are placed in boxes
			testCase.verifyEmpty( t.boxes.elementsQ{1}{1,1} ); % Empty
			testCase.verifyEmpty( t.boxes.elementsQ{1}{1,2} ); % Empty

			% Check the sizes are correct
			testCase.verifyEqual(size(t.boxes.elementsQ{1}{1,3}), [1, 2]);
			testCase.verifyEqual(size(t.boxes.elementsQ{1}{2,1}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.elementsQ{1}{2,2}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.elementsQ{1}{2,3}), [1, 2]);

			testCase.verifyEqual(size(t.boxes.elementsQ{2}{1,1}), [1, 2]);
			testCase.verifyEqual(size(t.boxes.elementsQ{2}{2,1}), [1, 2]);

			testCase.verifyEqual(size(t.boxes.elementsQ{3}{1,1}), [1, 2]);

			testCase.verifyEqual(size(t.boxes.elementsQ{4}{1,1}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.elementsQ{4}{1,2}), [1, 1]);
			testCase.verifyEqual(size(t.boxes.elementsQ{4}{1,3}), [1, 2]);


			% Check the contents of the node boxes

			testCase.verifyEqual( t.boxes.nodesQ{1}{1,3}, [  t.cellList(1).nodeTopLeft ]);
			testCase.verifyEqual( t.boxes.nodesQ{1}{1,3}, [  t.cellList(2).nodeTopRight ]);
			testCase.verifyEqual( t.boxes.nodesQ{1}{2,3}, [  t.cellList(1).nodeTopRight ]);
			testCase.verifyEqual( t.boxes.nodesQ{2}{1,1}, [  t.cellList(1).nodeBottomLeft ]);
			testCase.verifyEqual( t.boxes.nodesQ{2}{1,1}, [  t.cellList(2).nodeBottomRight ]);
			testCase.verifyEqual( t.boxes.nodesQ{2}{2,1}, [  t.cellList(1).nodeBottomRight ]);
			testCase.verifyEqual( t.boxes.nodesQ{3}{1,1}, [  t.cellList(2).nodeBottomLeft ]);
			testCase.verifyEqual( t.boxes.nodesQ{4}{1,3}, [  t.cellList(2).nodeTopLeft ]);

			% Check the contents of the element boxes

			testCase.verifyTrue(   ismember( t.cellList(1).elementTop, 		t.boxes.elementsQ{1}{1,3} )   )
			testCase.verifyTrue(   ismember( t.cellList(2).elementTop, 		t.boxes.elementsQ{1}{1,3} )   )

			testCase.verifyTrue(   ismember( t.cellList(1).elementRight, 	t.boxes.elementsQ{1}{2,3} )   )
			testCase.verifyTrue(   ismember( t.cellList(1).elementTop,		t.boxes.elementsQ{1}{2,3} )   )

			testCase.verifyTrue(   ismember( t.cellList(1).elementBottom, 	t.boxes.elementsQ{2}{1,1} )   )
			testCase.verifyTrue(   ismember( t.cellList(2).elementBottom,	t.boxes.elementsQ{2}{1,1} )   )

			testCase.verifyTrue(   ismember( t.cellList(1).elementRight,	t.boxes.elementsQ{2}{2,1} )   )
			testCase.verifyTrue(   ismember( t.cellList(1).elementBottom,	t.boxes.elementsQ{2}{2,1} )   )

			testCase.verifyTrue(   ismember( t.cellList(2).elementLeft,		t.boxes.elementsQ{3}{1,1} )   )
			testCase.verifyTrue(   ismember( t.cellList(2).elementBottom,	t.boxes.elementsQ{3}{1,1} )   )

			testCase.verifyTrue(   ismember( t.cellList(2).elementLeft,		t.boxes.elementsQ{4}{1,3} )   )
			testCase.verifyTrue(   ismember( t.cellList(2).elementTop,		t.boxes.elementsQ{4}{1,3} )   )

		end

		function TestCaseFromTheWild1(testCase)

			% When running this test, the node does not detect
			% a neighbouring element when it is in a box to the left

			t = IsolatedCellTest(10,10,1);

			t.RunToTime(6.5);

			e = t.boxes.elementsQ{1}{1,3}(1);
			n = t.boxes.elementsQ{1}{2,3}(4).Node2;

			ec = AssembleCandidateElements(n, 0.1);

			testCase.verifyTrue(ismember(e,ec));

			en = t.boxes.GetNeighbouringElements(n, 0.1);

			testCase.verifyEqual(en, e);

		end

		% function TestWholePartitionFromTestState(testCase)

		% 	% This tests that the continually updated partition
		% 	% is correct, by matching it to a partition calculated
		% 	% directly at a given time step. This obviously assumes
		% 	% that producing the full partition is correct

		% 	load('testState.mat');
		% 	t.collisionDetectionOn = false;
		% 	t.collisionDetectionRequested = false;
		% 	% Just to be sure that the save state is correct, we
		% 	% recreate the partition
		% 	t.boxes = SpacePartition(1,1,t);

		% 	% In this time interval there should be 35 times where the
		% 	% elements need updating, equivalent to 35 time a node has
		% 	% moved to a new box - hopefully enough to catch problems
		% 	t.NTimeSteps(1000);

		% 	p = SpacePartition(1,1,t);

		% 	% Need to now check that p is identical to t.boxes
			
		% 	testCase.verifyEqual(size(p.nodesQ), size(t.boxes.nodesQ));
		% 	testCase.verifyEqual(size(p.nodesQ), size(t.boxes.nodesQ));
		% 	for q=1:4
		% 		testCase.verifyEqual(size(p.nodesQ{q}), size(t.boxes.nodesQ{q}));
		% 		testCase.verifyEqual(size(p.elementsQ{q}), size(t.boxes.elementsQ{q}));

		% 		[il, jl] = size(p.nodesQ{q});

		% 		% For every box, check they are identical
		% 		for i = 1:il
		% 			for j = 1:jl
		% 				testCase.verifyEqual(size(p.nodesQ{q}{i,j}), size(t.boxes.nodesQ{q}{i,j}));
		% 				testCase.verifyEqual(size(p.elementsQ{q}{i,j}), size(t.boxes.elementsQ{q}{i,j}));
		% 			end
		% 		end

		% 	end

		% end


		% function TestSpacePartitionAfterKillingBoundaryCell(testCase)

		% 	t = FixedDomain(1,3,3,5,10);

		% 	t.cellList.CellCycleModel.pausePhaseLength = 1;
		% 	t.cellList.CellCycleModel.growingPhaseLength = 1;
		% 	t.cellList.CellCycleModel.age = 0;

		% 	t.RunToTime(12.465);

		% 	% At this point the cell at the left boundary has just divided and
		% 	% been killed since it is passed the left boundary.
		% 	% There must be no record of this cell existing

		% 	testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{2,1}));
		% 	testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{2,2}));
		% 	testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{2,3})); % << Fails

		% 	testCase.verifyTrue(isempty(t.boxes.nodesQ{3}{2,1})); % << Fails


		% 	testCase.verifyTrue(isempty(t.boxes.elementsQ{4}{2,1}));
		% 	testCase.verifyTrue(isempty(t.boxes.elementsQ{4}{2,2}));
		% 	testCase.verifyTrue(isempty(t.boxes.elementsQ{4}{2,3})); % << Fails

		% 	testCase.verifyTrue(isempty(t.boxes.elementsQ{3}{2,1})); % << Fails



		% end

		

		% function TestWholePartitionFromT0(testCase)

		% 	% This tests that the continually updated partition
		% 	% is correct, by matching it to a partition calculated
		% 	% directly at a given time step. This obviously assumes
		% 	% that producing the full partition is correct

		% 	t = CellGrowing(20,3,3,20,10,1,10);

		% 	t.NTimeSteps(3000);

		% 	p = SpacePartition(1,1,t);

		% 	% Need to now check that p is identical to t.boxes
			
		% 	testCase.verifyEqual(size(t.boxes.nodesQ), size(p.nodesQ));
		% 	testCase.verifyEqual(size(t.boxes.nodesQ), size(p.nodesQ));
		% 	for q=1:4
		% 		testCase.verifyEqual(size(t.boxes.nodesQ{q}), size(p.nodesQ{q}));
		% 		testCase.verifyEqual(size(t.boxes.elementsQ{q}), size(p.elementsQ{q}) );

		% 		[il, jl] = size(p.nodesQ{q});

		% 		% For every box, check they are identical
		% 		for i = 1:il
					
		% 			for j = 1:jl
		% 				testCase.verifyEqual(size(t.boxes.nodesQ{q}{i,j}), size(p.nodesQ{q}{i,j}));
		% 				testCase.verifyEqual(size(t.boxes.elementsQ{q}{i,j}), size(p.elementsQ{q}{i,j}));
		% 			end

		% 		end

		% 	end

		% end

	end

end

