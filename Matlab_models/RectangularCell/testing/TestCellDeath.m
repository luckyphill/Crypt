classdef TestCellDeath < matlab.unittest.TestCase
   
	methods (Test)


		function TestBoundaryCellKiller(testCase)

			% Ought to check each function, but as long as the
			% whole thing works, all should be rosy

			% The cells beyond the boundary must be removed
			% and all the nodes, elements, and spacepartitions
			% cleaned up or removed as needed

			t = CellGrowing(3,5,5,20,10,1,10);

			% After death the cell, elements and nodes must be deleted
			c = t.cellList(1);

			% Using a square cell
			ntl = c.nodeTopLeft;
			ntr = c.nodeTopRight;
			nbl = c.nodeBottomLeft;
			nbr = c.nodeBottomRight;

			et = c.elementTop;
			eb = c.elementBottom;
			el = c.elementLeft;
			er = c.elementRight;

			testCase.verifyEqual(t.GetNumCells(), 3);

			t.AddTissueLevelKiller(BoundaryCellKiller(0.75,1.5));

			% Cells are killed when at least one multi-cell node
			% moves past the boundary
			
			% This will kill the left most cell only
			t.KillCells();

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

			testCase.verifyEqual(t.GetNumCells(), 3);

			t.AddTissueLevelKiller(BoundaryCellKiller(0,0.75));

			% Cells are killed when at least one multi-cell node
			% moves past the boundary
			
			% This will kill the left most cell only
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