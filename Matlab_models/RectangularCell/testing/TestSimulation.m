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

			% Just loop through a few iterations until we get a collision
			% this is easier than manually determining the previous positions
			% and forces
			for i = 1:5
				n.AddForceContribution([-1.3,0]);
				n1.AddForceContribution([1,0]);
				n2.AddForceContribution([1,0]);

				n.UpdatePosition(t.dt/t.eta);
				n1.UpdatePosition(t.dt/t.eta);
				n2.UpdatePosition(t.dt/t.eta);
			end

			t.MoveNodeAndElement(n, e);

			testCase.verifyEqual(n.position, [0.043478260869565, 0.6], 'RelTol', 1e-8);
			testCase.verifyEqual(n1.position, [0.043478260869565, 0], 'RelTol', 1e-8);
			testCase.verifyEqual(n2.position, [0.043478260869565, 1], 'RelTol', 1e-8);


		end

		function TestProcessCollisionFromTestState1(testCase)
			% In development of collision processing, the simulation saved in
			% testState.mat failed to calculate the collision point properly
			% so that will be used as a test. All values are taken directly
			% from this simulation at the point of collision

			% This is the first point to fail. It was due to an error
			% in writing out the equations to find the intersection.
			% That means this ends up being a practical test for a standard
			% collision - a bit better than the one conjured up above


			t = CellGrowing(1,20,10,10,10,1,10);

			n = Node(2.679089843793793, 1.111279426020461, 1);
			n.previousPosition = [2.678993071095805,   1.111322535559900];
			n.previousForce = [0.019356072843268,  -0.008623370542502];

			n1 = Node(2.678125774934509, 1.099393998875818, 2);
			n1.previousPosition = [2.678224841525261,   1.099196272975437];
			n1.previousForce = [-0.019815031993694,   0.039549258131540];

			n2 = Node(2.737339808220937,   1.977995499569748, 3);
			n2.previousPosition = [2.737408966487447,   1.977577366126344];
			n2.previousForce = [-0.013839246351063,   0.083630457153625];

			e = Element(n1,n2,1);
			% figure
			% hold on

			% plot(n.x, n.y, 'ko');
			% plot(e.Node1.x, e.Node1.y, 'bo');
			% plot(e.Node2.x, e.Node2.y, 'bo');

			% plot([e.nodeList.x], [e.nodeList.y], 'k--');

			% plot(n.previousPosition(1), n.previousPosition(2), 'go');
			% plot(e.Node1.previousPosition(1), e.Node1.previousPosition(2), 'ro');
			% plot(e.Node2.previousPosition(1), e.Node2.previousPosition(2), 'ro');

			% plot([e.Node1.previousPosition(1),e.Node2.previousPosition(1)], [e.Node1.previousPosition(2),e.Node2.previousPosition(2)], 'r--');

			% No verifications have been explicitly written, but there are error trigger points
			% in the following function, so if all is not well, then we can catch the failure
			t.MoveNodeAndElement(n, e);

		end

		function TestProcessCollisionFromTestState2(testCase)
			% In development of collision processing, the simulation saved in
			% testState.mat failed to calculate the collision point properly
			% so that will be used as a test. All values are taken directly
			% from this simulation at the point of collision

			% This is the second time failure has occurred.
			% This failure is apparently due to subtraction of
			% almost equal numbers resulting in a number that
			% is highly susceptible to round-off/binary-to-decimal approximation errors

			% To remedy this, when numbers are very close to 0
			% we will simply set them to zero

			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.01;
			t.eta = 1;

			n = Node(4.289163775967404,  -0.430126629734065, 1);
			n.previousPosition = [4.288768222511362  -0.429082966112824];
			n.previousForce = [0.079097065192904  -0.208715046158330];

			n1 = Node(4.342369240828197,   0.237019662505578, 2);
			n1.previousPosition = [4.342609917545624   0.236289903275623];
			n1.previousForce = [-0.048124097742078   0.145941373102790];

			n2 = Node(4.279943205181989,  -0.527406852252034, 3);
			n2.previousPosition = [4.280809107292654  -0.527441298395918];
			n2.previousForce = [-0.173173181470151   0.006873482832686];

			e = Element(n1,n2,1);
			% figure
			% hold on

			% plot(n.x, n.y, 'ko');
			% plot(e.Node1.x, e.Node1.y, 'ko');
			% plot(e.Node2.x, e.Node2.y, 'ko');

			% plot([e.nodeList.x], [e.nodeList.y], 'k');

			% plot(n.previousPosition(1), n.previousPosition(2), 'r*');
			% plot(e.Node1.previousPosition(1), e.Node1.previousPosition(2), 'r*');
			% plot(e.Node2.previousPosition(1), e.Node2.previousPosition(2), 'r*');

			% plot([e.Node1.previousPosition(1),e.Node2.previousPosition(1)], [e.Node1.previousPosition(2),e.Node2.previousPosition(2)], 'r--');

			t.MoveNodeAndElement(n, e);

		end


		function TestProcessCollisionFromTestState3(testCase)
			% In development of collision processing, the simulation saved in
			% testState.mat failed to calculate the collision point properly
			% so that will be used as a test. All values are taken directly
			% from this simulation at the point of collision

			% This is the third failure. This time I believe it is due to
			% two collisions occurring involving the same edges
			% Briefly, the initial algorithm made no attempt to work out which
			% collision occurred first and handle the double collision properly
			% This resulted in on collision being resolved correctly by the node
			% ending up on the edge, while the second collision was resolved
			% based on an earlier, no longer relevant, set of positions
			% This left the second collision resolving to a position where the
			% node did not attached to the edge.

			% Concrete class to access the methods
			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.005;
			t.eta = 1;

			% Nodes involved

			nc1 = Node(7.516323235982217,  -0.510562827716617, 1);
			nc1.previousPosition = [7.515395256320858  -0.511046011542917];
			nc1.previousForce = [0.190044400221934   0.098953009736972];
			nc1.AdjustPosition(nc1.previousPosition + t.dt * nc1.previousForce/t.eta);

			nc2 = Node(7.522497481658915,  -0.663125885289055, 2);
			nc2.previousPosition = [7.523905969216058  -0.663230458083442];
			nc2.previousForce = [-0.288449396213211   0.021415850816997];
			nc2.AdjustPosition( nc2.previousPosition + t.dt * nc2.previousForce/t.eta );

			e1n1 = Node(7.477964004765953,   0.158281502068270, 3);
			e1n1.previousPosition = [7.477964004765953   0.158281502068270];
			e1n1.previousForce = [-0.088564005942511   0.028871917552375];
			e1n1.AdjustPosition(e1n1.previousPosition + t.dt * e1n1.previousForce/t.eta);

			e1n2 = nc2;

			e2n1 = Node(7.540171238449982,  -1.099837107359943, 4);
			e2n1.previousPosition = [7.539854029048046  -1.099702316192680];
			e2n1.previousForce = [0.064962491147076  -0.027604383592040];
			e2n1.AdjustPosition(e2n1.previousPosition + t.dt * e2n1.previousForce/t.eta);

			e2n2 = nc1;


			% Elements involved
			e1 = Element(e1n1,e1n2,1);
			e2 = Element(e2n1,e2n2,2);

			% t.MoveNodeAndElement(nc2, e2);
			% t.MoveNodeAndElement(nc1, e1);
			
			

			% Node and element for second collision
			% figure
			% hold on

			% plot(nc1.x, nc1.y, 'ko');
			% plot(e1.Node1.x, e1.Node1.y, 'ko');
			% plot(e1.Node2.x, e1.Node2.y, 'ko');

			% plot([e1.nodeList.x], [e1.nodeList.y], 'k');

			% plot(nc1.previousPosition(1), nc1.previousPosition(2), 'r*');
			% plot(e1.Node1.previousPosition(1), e1.Node1.previousPosition(2), 'r*');
			% plot(e1.Node2.previousPosition(1), e1.Node2.previousPosition(2), 'r*');

			% plot([e1.Node1.previousPosition(1),e1.Node2.previousPosition(1)], [e1.Node1.previousPosition(2),e1.Node2.previousPosition(2)], 'r--');

			% plot(nc2.x, nc2.y, 'bo');
			% plot(e2.Node1.x, e2.Node1.y, 'bo');
			% plot(e2.Node2.x, e2.Node2.y, 'bo');

			% plot([e2.nodeList.x], [e2.nodeList.y], 'b');

			% plot(nc2.previousPosition(1), nc2.previousPosition(2), 'c*');
			% plot(e2.Node1.previousPosition(1), e2.Node1.previousPosition(2), 'c*');
			% plot(e2.Node2.previousPosition(1), e2.Node2.previousPosition(2), 'c*');

			% plot([e2.Node1.previousPosition(1),e2.Node2.previousPosition(1)], [e2.Node1.previousPosition(2),e2.Node2.previousPosition(2)], 'c--');




		end

		function TestMoveNodeElementPair(testCase)

			% Tests that a node element pair that are in contact
			% move as expected

			% Need a concrete class instance to access the method
			t = CellGrowing(1,20,10,10,10,1,10);
			t.dt = 0.01;
			t.eta = 1;

			n = Node(0,0.75,1);

			n1 = Node(0,0,2);
			n2 = Node(0,1,3);
			e = Element(n1,n2,1);
			e.GetLength()

			n.AddForceContribution([-100,0]);

			% n1.AddForceContribution([0.5,0]);
			% n2.AddForceContribution([0.5,0]);

			t.TransmitForcesPair(n,e);

			e.GetLength()

			% figure
			% hold on

			% plot(n.x, n.y, 'ko');
			% plot(e.Node1.x, e.Node1.y, 'ko');
			% plot(e.Node2.x, e.Node2.y, 'ko');

			% plot([e.nodeList.x], [e.nodeList.y], 'k');

			% plot(n.previousPosition(1), n.previousPosition(2), 'r*');
			% plot(e.Node1.previousPosition(1), e.Node1.previousPosition(2), 'r*');
			% plot(e.Node2.previousPosition(1), e.Node2.previousPosition(2), 'r*');

			% plot([e.Node1.previousPosition(1),e.Node2.previousPosition(1)], [e.Node1.previousPosition(2),e.Node2.previousPosition(2)], 'r--');



		end


	end

end