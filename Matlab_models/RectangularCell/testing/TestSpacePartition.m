classdef TestSpacePartition < matlab.unittest.TestCase
   
	methods (Test)

		function TestFindQuadrantsAndBoxes(testCase)

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

			% Positive x axis
			[q,i,j] = p.GetQuadrantAndIndices(1,0);

			testCase.verifyEqual([q,i,j], [1,2,1]);

			% Positive y axis
			[q,i,j] = p.GetQuadrantAndIndices(0,1);

			testCase.verifyEqual([q,i,j], [1,1,2]);

			% Negative x axis
			[q,i,j] = p.GetQuadrantAndIndices(-1,0);

			testCase.verifyEqual([q,i,j], [4,2,1]);

			% Negative y axis
			[q,i,j] = p.GetQuadrantAndIndices(0,-1);

			testCase.verifyEqual([q,i,j], [2,1,2]);

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

			% Quadrant 1
			[q,i,j] = p.GetQuadrantAndIndices(-1,1);

			testCase.verifyEqual([q,i,j], [4,2,2]);


			% Test to see if box switching can be detected
			% MoveNode should handle the actual moving in
			% stored lists
			n = Node(1.1,2.2,1);

			n.MoveNode([1.2,2.2]);

			new = p.IsNodeInNewBox(n);

			testCase.verifyFalse(new);

			n.MoveNode([0.9,2.2]);

			new = p.IsNodeInNewBox(n);

			testCase.verifyTrue(new);

			% The function IsNodeInNewBox is redundant now, but left here
			% for testing purposes


			% Test putting a node in a box
			p.PutNodeInBox(n);
			testCase.verifyEqual(p.nodesQ{1}{1,3}, [n]);

			n.MoveNode([1.1,2.2]);

			p.UpdateBoxForNode(n);
			testCase.verifyEqual(p.nodesQ{1}{2,3}, [n]);
			testCase.verifyTrue(isempty(p.nodesQ{1}{1,3}));

		end

		function TestFindQuadrantsAndBoxesVectorised(testCase)

			t = CellGrowing(3,20,10,10,10,1,10);
			p = SpacePartition(1, 1, t);

			a = [1.1,2.2;1.1,-2.2;-1.1,-2.2;-1.1,2.2;0,0;1,0;0,1;-1,0;0,-1;1,1;1,-1;-1,-1;-1,1];

			x = a(:,1);
			y = a(:,2);

			out = [1,2,3;2,2,3;3,2,3;4,2,3;1,1,1;1,2,1;1,1,2;4,2,1;2,1,2;1,2,2;2,2,2;3,2,2;4,2,2];

			[q,i,j] = p.GetQuadrantAndIndices(x,y);

			testCase.verifyEqual([q,i,j], out);
		end

		function TestElementBoxes(testCase)
			t = CellGrowing(3,20,10,10,10,1,10);
			p = SpacePartition(1, 1, t);

			n1 = Node(0.1,0.1,1);
			n2 = Node(4.1,4.1,2);

			[ql,il,jl] = p.GetBoxIndicesBetweenNodes(n1, n2);

			% This test assumes we get a rectangular grid
			% If this method is optimised, it will be smaller
			% so these tests will fail
			testCase.verifyEqual(ql, ones(25,1));
			testCase.verifyEqual(il, [ones(5,1);2*ones(5,1);3*ones(5,1);4*ones(5,1);5*ones(5,1)]);
			testCase.verifyEqual(jl, repmat([1,2,3,4,5]',5,1));

			e = Element(n1,n2,1);

			p.PutElementInBoxes(e);

			testCase.verifyEqual(size(p.elementsQ{1}), [5 5]);
			
			for i=1:5
				for j=1:5
					b = p.elementsQ{1}{i,j};
					testCase.verifyEqual(b, [e]);
				end
			end

			n1.MoveNode([1.1,0.1]);
			n2.MoveNode([4.1,4.2]);

			[ql,il,jl] = p.GetBoxIndicesBetweenNodes(n1, n2);
			[qp,ip,jp] = p.GetPreviousBoxIndicesBetweenNodes(n1, n2);

			testCase.verifyNotEqual([ql,il,jl], [qp,ip,jp]);

			p = SpacePartition(1, 1, t);
			% Need element to be in a cell for the final bit to work
			n1 = Node(0.1,0.1,1);
			n2 = Node(4.1,4.1,2);
			n3 = Node(4.1,0.1,3);
			n4 = Node(0.1,-3,4);

			el = Element(n4,n1,1);
			eb = Element(n3,n4,2);
			et = Element(n1,n2,3);
			er = Element(n2,n3,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			p.PutElementInBoxes(et);

			n1.MoveNode([1.1,0.1]);
			n2.MoveNode([4.1,4.2]);

			p.UpdateBoxForNode(n1);
			p.UpdateBoxForNode(n2);

			testCase.verifyFalse(et.IsElementInternal);

			% This should leave no elements in the first column of
			% quadrant 1, with the remaining being identical to before

			% The element box quadrant will still be the same size...
			testCase.verifyEqual(size(p.elementsQ{1}), [5 5]);

			% ... but the first column will have no entries...
			for j=1:5
				b = p.elementsQ{1}{1,j};
				testCase.verifyTrue(isempty(b));
			end

			% ... while the rest will not have changed
			for i=2:5
				for j=1:5
					b = p.elementsQ{1}{i,j};
					testCase.verifyEqual(b, [et]);
				end
			end

			% We also need to test between quadrants
			% Tecchnically, this should test every combination,
			% but I have enough faith in the previous testing
			% that it should hold true for any quadrant (fingers crossed!)

			p = SpacePartition(1, 1, t);
			p.PutElementInBoxes(eb);

			% Test that quadrant 1 and 2 have boxes with eb
			% Test goes here

			% Move the nodes to another quadrant and it should hold up
			n3.MoveNode(4.1,-0.1,3);
			n4.MoveNode(-0.1,-3,4);



		end

		function TestInitialise(testCase)

			t = CellGrowing(3,20,10,10,10,1,10);
			p = SpacePartition(1, 1, t);

			testCase.verifyEqual(p.dx,1);
			testCase.verifyEqual(p.dy,1);

			testCase.verifyEqual(p.simulation, t);

			testCase.verifyEqual(size(p.nodesQ{1}), [2, 2]);
			testCase.verifyEqual(size(p.nodesQ{2}), [0, 0]);
			testCase.verifyEqual(size(p.nodesQ{3}), [0, 0]);
			testCase.verifyEqual(size(p.nodesQ{4}), [0, 0]);

		end

	end

end

