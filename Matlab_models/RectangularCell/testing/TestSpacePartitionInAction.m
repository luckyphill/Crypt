classdef TestSpacePartitionInAction < matlab.unittest.TestCase
   
   % This tests the space partition when used in a simulation
   % it is here to make sure evrything works when put into
   % practice
	methods (Test)

		function TestCaseFromTheWild1(testCase)

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

		% Doesn't work because updated to AbstractCell
		% function TestWholePartitionFromTestState(testCase)

		% 	% This tests that the continually updated partition
		% 	% is correct, by matching it to a partition calculated
		% 	% directly at a given time step. This obviously assumes
		% 	% that producing the full partition is correct

		% 	load('testState.mat');
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

		function TestSpacePartitionAfterKillingBoundaryCell(testCase)

			t = FixedDomain(1,3,3,5,10);

			t.cellList.CellCycleModel.pausePhaseLength = 1;
			t.cellList.CellCycleModel.growingPhaseLength = 1;
			t.cellList.CellCycleModel.age = 0;

			t.RunToTime(12.465);

			% At this point the cell at the left boundary has just divided and
			% been killed since it is passed the left boundary.
			% There must be no record of this cell existing

			testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{2,1}));
			testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{2,2}));
			testCase.verifyTrue(isempty(t.boxes.nodesQ{4}{2,3})); % << Fails

			testCase.verifyTrue(isempty(t.boxes.nodesQ{3}{2,1})); % << Fails


			testCase.verifyTrue(isempty(t.boxes.elementsQ{4}{2,1}));
			testCase.verifyTrue(isempty(t.boxes.elementsQ{4}{2,2}));
			testCase.verifyTrue(isempty(t.boxes.elementsQ{4}{2,3})); % << Fails

			testCase.verifyTrue(isempty(t.boxes.elementsQ{3}{2,1})); % << Fails

		end

		% This takes a long time, so keep commented until you really need to test it
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

