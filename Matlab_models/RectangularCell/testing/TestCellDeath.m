classdef TestCellDeath < matlab.unittest.TestCase
   
	methods (Test)

		function TestBoundaryCellKillerFunctions(testCase)

			% COMPLETE
			% Test each function in BoundaryCellKiller
			% Only valid for SquareCellJoined

			k = BoundaryCellKiller(0.75,1.5);

			testCase.verifyEqual(k.leftBoundary, 0.75);
			testCase.verifyEqual(k.rightBoundary, 1.5);

			testCase.verifyError( @() BoundaryCellKiller(0.75,0), 'BCK:WrongOrder');


			% Test moving past the boundaries is detected
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = SquareCellJoined(NoCellCycle, [et,eb,el,er], 1);

			% Left
			k = BoundaryCellKiller(0.9,1.5);

			testCase.verifyFalse( k.IsPastLeftBoundary(c) )

			k = BoundaryCellKiller(1.1,1.5);

			testCase.verifyTrue( k.IsPastLeftBoundary(c) );

			% Right
			k = BoundaryCellKiller(-1,0.1);

			testCase.verifyFalse( k.IsPastRightBoundary(c) )

			k = BoundaryCellKiller(-1,-0.1);

			testCase.verifyTrue( k.IsPastRightBoundary(c) );

		end

		function TestBoundaryCellKillerInSimulation(testCase)

			% INCOMPLETE
			% Missing:
			% 1. Left  boundary doesn't check exact contents of boxes
			% 2. Right boundary doesn't check exact contents of boxes
			% Test that the cells are removed properly from a simulation
			% Only valid for SquareCellJoined

			% The cells beyond the boundary must be removed
			% and all the nodes, elements, and spacepartitions
			% cleaned up or removed as needed


			%--------------------------------
			% Left boundary
			%--------------------------------

			t = CellGrowing(3,5,5,20,10,1,10);

			% The following cell, elements and nodes are impacted
			%--------------------------------
			c = t.cellList(1);
			c2 = t.cellList(2);

			ntl = c.nodeTopLeft;
			ntr = c.nodeTopRight;
			nbl = c.nodeBottomLeft;
			nbr = c.nodeBottomRight;

			et = c.elementTop;
			eb = c.elementBottom;
			el = c.elementLeft;
			er = c.elementRight;

			% Boundary so that the left cell will die
			t.AddTissueLevelKiller(BoundaryCellKiller(0.75,1.5));
			t.KillCells();

			% Simulation count is updated - technically this 
			% is a feature of AbstractCellSimulation but it's
			% a quick check to make sure no additional parts
			% are deleted
			testCase.verifyEqual(t.GetNumCells(), 2);
			testCase.verifyEqual(t.GetNumElements(), 7);
			testCase.verifyEqual(t.GetNumNodes(), 6);

			% These must be gone
			testCase.verifyEqual(whos('c').bytes, 0);
			testCase.verifyEqual(whos('ntl').bytes, 0);
			testCase.verifyEqual(whos('nbl').bytes, 0);
			testCase.verifyEqual(whos('et').bytes, 0);
			testCase.verifyEqual(whos('eb').bytes, 0);
			testCase.verifyEqual(whos('el').bytes, 0);

			% These must remain
			testCase.verifyEqual(ntr, c2.nodeTopLeft);
			testCase.verifyEqual(nbr, c2.nodeBottomLeft);
			testCase.verifyEqual(er, c2.elementLeft);
			testCase.verifyFalse(er.internal);

			% This simulation uses boxes, so need to verify everythign is gone

			% Empty from deletion
			testCase.verifyEmpty(t.boxes.nodesQ{1}{1,1});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{1,2});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{1,3});

			% Initially empty
			testCase.verifyEmpty(t.boxes.nodesQ{1}{2,2});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{3,2});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{4,2});

			% Initially full
			% Really should check the size and contents
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{2,1});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{3,1});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{4,1});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{2,3});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{3,3});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{4,3});

			% Box that is no longer empty because the left element
			% is now external
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{2,2});
			
			% Initially empty (internal element)
			testCase.verifyEmpty(t.boxes.elementsQ{1}{3,2});

			% Empty from deletion
			testCase.verifyEmpty(t.boxes.elementsQ{1}{1,1});
			testCase.verifyEmpty(t.boxes.elementsQ{1}{1,2});
			testCase.verifyEmpty(t.boxes.elementsQ{1}{1,3});

			% Initially full
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{2,1});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{2,3});

			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{3,1});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{3,3});

			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{4,1});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{4,2});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{4,3});


			% Repeat the test for the right boundary
			% The cells beyond the boundary must be removed
			% and all the nodes, elements, and spacepartitions
			% cleaned up or removed as needed

			t = CellGrowing(3,5,5,20,10,1,10);

			% After death the cell, elements and nodes must be deleted
			c2 = t.cellList(2);
			c = t.cellList(3);

			% Using a square cell
			ntl = c.nodeTopLeft;
			ntr = c.nodeTopRight;
			nbl = c.nodeBottomLeft;
			nbr = c.nodeBottomRight;

			et = c.elementTop;
			eb = c.elementBottom;
			el = c.elementLeft;
			er = c.elementRight;

			t.AddTissueLevelKiller(BoundaryCellKiller(0,0.75));
			t.KillCells();

			testCase.verifyEqual(t.GetNumCells(), 2);
			testCase.verifyEqual(t.GetNumElements(), 7);
			testCase.verifyEqual(t.GetNumNodes(), 6);

			% These must be gone
			testCase.verifyEqual(whos('c').bytes, 0);
			testCase.verifyEqual(whos('ntr').bytes, 0);
			testCase.verifyEqual(whos('nbr').bytes, 0);
			testCase.verifyEqual(whos('et').bytes, 0);
			testCase.verifyEqual(whos('eb').bytes, 0);
			testCase.verifyEqual(whos('er').bytes, 0);

			% These must remain
			testCase.verifyEqual(ntl, c2.nodeTopRight);
			testCase.verifyEqual(nbl, c2.nodeBottomRight);
			testCase.verifyEqual(el, c2.elementRight);
			testCase.verifyFalse(el.internal);

			% This simulation uses boxes, so need to verify everythign is gone

			% Empty from deletion
			testCase.verifyEmpty(t.boxes.nodesQ{1}{4,1});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{4,2});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{4,3});

			% Initially empty
			testCase.verifyEmpty(t.boxes.nodesQ{1}{1,2});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{2,2});
			testCase.verifyEmpty(t.boxes.nodesQ{1}{3,2});

			% Initially full
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{1,1});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{2,1});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{3,1});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{1,3});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{2,3});
			testCase.verifyNotEmpty(t.boxes.nodesQ{1}{3,3});

			% Empty from deletion
			testCase.verifyEmpty(t.boxes.elementsQ{1}{4,1});
			testCase.verifyEmpty(t.boxes.elementsQ{1}{4,2});
			testCase.verifyEmpty(t.boxes.elementsQ{1}{4,3});

			% Reduced size from deletion
			testCase.verifyEqual(size(t.boxes.elementsQ{1}{3,1}), [1,2]);
			testCase.verifyEqual(size(t.boxes.elementsQ{1}{3,3}), [1,2]);

			% No longer empty because right element is now external
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{3,2});
			
			% Initially empty (internal elements)
			testCase.verifyEmpty(t.boxes.elementsQ{1}{2,2});

			% Initially full
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{1,1});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{1,2});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{1,3});

			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{2,1});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{2,3});

			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{3,1});
			testCase.verifyNotEmpty(t.boxes.elementsQ{1}{3,3});

		end

	end

end