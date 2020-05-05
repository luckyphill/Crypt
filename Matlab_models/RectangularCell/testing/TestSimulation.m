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

		% function TestLinksLong(testCase)

		% 	% This tests to make sure all the links between nodes, elements
		% 	% and cells are maintained correctly as the simulation progresses
		% 	t = CellGrowing(20,20,10,10,10,1,10);
		% 	t.NTimeSteps(3000);
		% 	% In testing at one point, the node->cell linking was incorrect here

		% 	% This assumes boundary cell finding works correctly
		% 	bcl = t.leftBoundaryCell;
		% 	bcr = t.rightBoundaryCell;
			
		% 	% These specific node must be part of one cell only
		% 	oneCellNodes = [bcl.nodeTopLeft, bcl.nodeBottomLeft, bcr.nodeTopRight, bcr.nodeBottomRight];
		% 	for i=1:4
		% 		testCase.verifyEqual(length(oneCellNodes(i).cellList), 1);
		% 	end

		% 	% The remaining nodes must be part of two cells
		% 	Lidx = ~ismember(t.nodeList, oneCellNodes);
		% 	twoCellNodes = t.nodeList(Lidx);
		% 	for i=1:length(twoCellNodes)
		% 		testCase.verifyEqual(length(twoCellNodes(i).cellList), 2);
		% 	end

		% end


	end

end