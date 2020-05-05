classdef TestSimulation < matlab.unittest.TestCase

	% All of these tests will be for AbstractCellSimulation,
	% but they will be done using CellGrowing
   
	methods (Test)

		function TestProperties(testCase)

			t = CellGrowing(20,20,10,10,10,1,10);



		end

		function TestLinksDivision(testCase)
			% This tests that links are maintained after division

			% Simulation with 3 cells
			t = CellGrowing(3,20,10,10,10,1,10);

			% This assumes boundary cell finding works correctly
			bcl = t.leftBoundaryCell;
			bcr = t.rightBoundaryCell;
			
			% These specific node must be part of one cell only
			oneCellNodes = [bcl.nodeTopLeft, bcl.nodeBottomLeft, bcr.nodeTopRight, bcr.nodeBottomRight];
			for i=1:4
				testCase.verifyEqual(length(oneCellNodes(i).cellList), 1);
			end

			% The remaining nodes must be part of two cells
			Lidx = ~ismember(t.nodeList, oneCellNodes);
			twoCellNodes = t.nodeList(Lidx);
			for i=1:length(twoCellNodes)
				testCase.verifyEqual(length(twoCellNodes(i).cellList), 2);
			end

			% Make the middle cell divide
			t.cellList(2).CellCycleModel.SetAge(50);
			t.MakeCellsDivide();

			testCase.verifyEqual(length(t.cellList),4);


			% This assumes boundary cell finding works correctly
			bcl = t.leftBoundaryCell;
			bcr = t.rightBoundaryCell;
			
			% These specific node must be part of one cell only
			oneCellNodes = [bcl.nodeTopLeft, bcl.nodeBottomLeft, bcr.nodeTopRight, bcr.nodeBottomRight];
			for i=1:4
				testCase.verifyEqual(length(oneCellNodes(i).cellList), 1);
			end

			% The remaining nodes must be part of two cells
			Lidx = ~ismember(t.nodeList, oneCellNodes);
			twoCellNodes = t.nodeList(Lidx);
			for i=1:length(twoCellNodes)
				testCase.verifyEqual(length(twoCellNodes(i).cellList), 2);
			end


		end

		function TestProcessCollision(testCase)

			% This tests that the elements and nodes move properly
			% after a collision is detected and processed

			% Need a concrete class instance to access the method
			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.01;
			t.eta = 1;

			n = Node(0.1,0.6,1);

			n1 = Node(0,0,2);
			n2 = Node(0,1,3);
			e = Element(n1,n2,1);

			for i = 1:5
				n.AddForceContribution([-1.3,0]);
				n1.AddForceContribution([1,0]);
				n2.AddForceContribution([1,0]);

				n.UpdatePosition(t.dt/t.eta);
				n1.UpdatePosition(t.dt/t.eta);
				n2.UpdatePosition(t.dt/t.eta);
			end

			n.previousPosition
			n1.previousPosition
			n2.previousPosition

			n.previousForce
			n1.previousForce
			n2.previousForce

			t.MoveNodeAndElement(n, e);



		end


	end

end