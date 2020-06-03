classdef TestForce < matlab.unittest.TestCase
   
	methods (Test)


		function TestNagaiHondaForce(testCase)
			% Sice this force applies to cells, set up a cell to test on
			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1.1,1.1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			f = NagaiHondaForce(1,1,1);

			testCase.verifyEqual(f.areaEnergyParameter, 1);
			testCase.verifyEqual(f.surfaceEnergyParameter, 1);
			testCase.verifyEqual(f.edgeAdhesionParameter, 1);

			% Test the area forces

			[agtl, agtr, agbr, agbl] = f.GetAreaGradientAtNodes(c);

			testCase.verifyEqual(agtl, [0.55, -0.55]);
			testCase.verifyEqual(agtr, [-0.5, -0.5]);
			testCase.verifyEqual(agbl, [0.5, 0.5]);
			testCase.verifyEqual(agbr, [-0.55, 0.55]);

			f.AddTargetAreaForces(c);

			testCase.verifyEqual(c.nodeTopLeft.force, [0.11, -0.11], 'RelTol', 1e-8);
			testCase.verifyEqual(c.nodeTopRight.force, [-0.1, -0.1], 'RelTol', 1e-8);
			testCase.verifyEqual(c.nodeBottomLeft.force, [0.1, 0.1], 'RelTol', 1e-8);
			testCase.verifyEqual(c.nodeBottomRight.force, [-0.11, 0.11], 'RelTol', 1e-8);

			% Reset the forces so we can test the perimeter forces

			c.nodeTopLeft.force = [0, 0];
			c.nodeTopRight.force = [0, 0];
			c.nodeBottomLeft.force = [0, 0];
			c.nodeBottomRight.force = [0, 0];

			[p, pgtl, pgtr, pgbr, pgbl] = f.GetPerimeterAndGradientAtNodes(c);

			testCase.verifyEqual(pgtl, [0.9959, -0.9095], 'AbsTol', 1e-4);
			testCase.verifyEqual(pgtr, [-1.0864, -1.0864], 'AbsTol', 1e-4);
			testCase.verifyEqual(pgbl, [1, 1], 'AbsTol', 1e-4);
			testCase.verifyEqual(pgbr, [-0.9095, 0.9959], 'AbsTol', 1e-4);

			f.AddTargetPerimeterForces(c);

			testCase.verifyEqual(c.GetCellTargetPerimeter(), 4);
			testCase.verifyEqual(c.GetCellPerimeter(), 4.2090,'AbsTol', 1e-4);

			testCase.verifyEqual(c.nodeTopLeft.force, [0.4163, -0.3802], 'AbsTol', 1e-3);
			testCase.verifyEqual(c.nodeTopRight.force, [-0.4541, -.4541], 'AbsTol', 1e-3);
			testCase.verifyEqual(c.nodeBottomLeft.force, [0.418, 0.418], 'AbsTol', 1e-3);
			testCase.verifyEqual(c.nodeBottomRight.force, [-0.3802, 0.4163], 'AbsTol', 1e-3);

			% Reset again so we can test the adhesion forces

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1,1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			[egt, egb, egl, egr] = f.GetEdgeGradientOnElements(c);

			testCase.verifyEqual(egt, [1, 0]);
			testCase.verifyEqual(egb, [1 ,0]);
			testCase.verifyEqual(egl, [0, 1]);
			testCase.verifyEqual(egr, [0, 1]);

			f.AddAdhesionForces(c);

			testCase.verifyEqual(c.nodeTopLeft.force, [1, -1]);
			testCase.verifyEqual(c.nodeTopRight.force, [-1, -1]);
			testCase.verifyEqual(c.nodeBottomLeft.force, [1, 1]);
			testCase.verifyEqual(c.nodeBottomRight.force, [-1 ,1]);

		end

		function TestRigidBodyEdgeModifierForce(testCase)
			
			% Make an element that is shorter than the min length
			n1 = Node(0,0,1);
			n2 = Node(0.15,0,2);

			e = Element(n1,n2,1);

			% Test compression
			n1.AddForceContribution([1,0]);
			n2.AddForceContribution([-1,0]);

			f = RigidBodyEdgeModifierForce(0.2);

			f.AddElementBasedForces(e);

			testCase.verifyEqual(n1.force,[0,0]);
			testCase.verifyEqual(n2.force,[0,0]);

			% Test pushing r to l
			n1 = Node(0,0,1);
			n2 = Node(0.15,0,2);

			e = Element(n1,n2,1);

			n1.AddForceContribution([-0.1,0]);
			n2.AddForceContribution([-1,0]);

			f.AddElementBasedForces(e);

			testCase.verifyEqual(n1.force,[-1.1,0]);
			testCase.verifyEqual(n2.force,[-1,0]);

			% Test pushing l to r
			n1 = Node(0,0,1);
			n2 = Node(0.15,0,2);

			e = Element(n1,n2,1);
			
			n1.AddForceContribution([1,0]);
			n2.AddForceContribution([0.1,0]);

			f.AddElementBasedForces(e);

			testCase.verifyEqual(n1.force,[1,0]);
			testCase.verifyEqual(n2.force,[1.1,0]);

		end

		function TestCornerForceFletcher(testCase)
			% Tests for the corner force to push angles to their prefered size

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1.1,1.1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			f = CornerForceFletcher(1, pi/2);

			[atl, abr, abl, atr] = f.GetCornerAngles(c);

			testCase.verifyEqual(atl, 1.6615, 'AbsTol', 1e-4);
			testCase.verifyEqual(abr, 1.6615, 'AbsTol', 1e-4);
			testCase.verifyEqual(abl, pi/2  , 'AbsTol', 1e-4);
			testCase.verifyEqual(atr, 1.3895, 'AbsTol', 1e-4);

			[vtl, vbr, vbl, vtr] = f.GetCornerVectors(c);

			testCase.verifyEqual(vtl, [0.7384, -0.6743]		  , 'AbsTol', 1e-4);
			testCase.verifyEqual(vbl, [1/sqrt(2) ,1/sqrt(2)]  , 'AbsTol', 1e-4);
			testCase.verifyEqual(vtr, [-1/sqrt(2), -1/sqrt(2)], 'AbsTol', 1e-4);
			testCase.verifyEqual(vbr, [-0.6743, 0.7384]		  , 'AbsTol', 1e-4);

			f.AddCornerForces(c);

			% Needs fixing
			testCase.verifyEqual(c.nodeTopLeft.force, -0.090659^3 * [0.7384, -0.6743], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.nodeTopRight.force, 0.1812^3 * [-1/sqrt(2), -1/sqrt(2)], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.nodeBottomLeft.force, [0, 0], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.nodeBottomRight.force, -0.090659^3 * [-0.6743, 0.7384], 'AbsTol', 1e-4);

		end

		function TestCornerForceCouple(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);
			n3 = Node(1,0,3);
			n4 = Node(1.1,1.1,4);

			el = Element(n1,n2,1);
			eb = Element(n1,n3,2);
			et = Element(n2,n4,3);
			er = Element(n3,n4,4);

			c = Cell(NoCellCycle, [et,eb,el,er], 1);

			f = CornerForceCouple(1, pi/2);

			[atl, abr, abl, atr] = f.GetCornerAngles(c);

			testCase.verifyEqual(atl, 1.6615, 'AbsTol', 1e-4);
			testCase.verifyEqual(abr, 1.6615, 'AbsTol', 1e-4);
			testCase.verifyEqual(abl, pi/2  , 'AbsTol', 1e-4);
			testCase.verifyEqual(atr, 1.3895, 'AbsTol', 1e-4);

			[nvt, nvb, nvl, nvr] = f.GetElementNormalVectors(c);

			testCase.verifyEqual(nvt, -[0.1, -1.1] / sqrt(1.1^2 + 0.1^2), 'AbsTol', 1e-4);
			testCase.verifyEqual(nvb, -[0, 1]  , 'AbsTol', 1e-4);
			testCase.verifyEqual(nvl, -[1, 0], 'AbsTol', 1e-4);
			testCase.verifyEqual(nvr, -[-1.1, 0.1] / sqrt(1.1^2 + 0.1^2), 'AbsTol', 1e-4);

			% These values weren't calculated independently, they are what the test expected, so they are put here
			% This test is only useful to see if the values change, not if they are correct (although I'm pretty sure they are)
			f.AddCouples(c);
			testCase.verifyEqual(c.nodeTopLeft.force, [-0.112953302086175   0.245227563739721], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.nodeTopRight.force, [-0.222934148854292  -0.222934148854292], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.nodeBottomLeft.force, [0.090659887200745   0.090659887200745], 'AbsTol', 1e-4);
			testCase.verifyEqual(c.nodeBottomRight.force, [0.245227563739721  -0.112953302086175], 'AbsTol', 1e-4);

		end

		function TestEdgeSpringForce(testCase)

			n1 = Node(0,0,1);
			n2 = Node(0,0.9,2);

			e = Element(n1,n2,1);

			f = EdgeSpringForce(@(n, l) n - l);
			f.ApplySpringForce(e);


			testCase.verifyEqual(n1.force, -[0, 0.1], 'AbsTol', 1e-4);
			testCase.verifyEqual(n2.force, [0, 0.1], 'AbsTol', 1e-4);

		end

		function TestNodeElementRepulsionForce(testCase)

			% This force is special in that it acts at a distance
			% since the nodes aren't all connected thorugh edges and cells
			% we have to use the space partition to find the interactions

			r = 0.1;
			dt = 0.005;

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);

			e = Element(n1,n2,1);

			n = Node(0.06,0.5,3);

			f = NodeElementRepulsionForce(r, dt);

			dr = r - n.x;
			Fa = [-atanh(dr/r),0];
			n1toA = [0, 0.5];

			f.ApplyForcesToNodeAndElement(n,e,Fa,n1toA);

			testCase.verifyEqual(n.force, -Fa, 'RelTol', 1e-8);
			testCase.verifyEqual(n1.force, 0.5*Fa, 'RelTol', 1e-8);
			testCase.verifyEqual(n2.force, 0.5*Fa, 'RelTol', 1e-8);



			% Redo the test above, but this time using AddNeighbourhoodBasedForces
			% need to make a partition and put the bits in it
			clear e n n1 n2 f
			t.nodeList = [];
			t.elementList = [];
			p = SpacePartition(1, 1, t);

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);

			e = Element(n1,n2,1);

			n = Node(0.06,0.5,3);

			f = NodeElementRepulsionForce(r, dt);

			p.PutNodeInBox(n);
			p.PutNodeInBox(n1);
			p.PutNodeInBox(n2);

			p.PutElementInBoxes(e);

			f.AddNeighbourhoodBasedForces(n, p);

			testCase.verifyEqual(n.force, -Fa, 'RelTol', 1e-8);
			testCase.verifyEqual(n1.force, 0.5*Fa, 'RelTol', 1e-8);
			testCase.verifyEqual(n2.force, 0.5*Fa, 'RelTol', 1e-8);


			testCase.verifyTrue( n.force(1) > 0);
			testCase.verifyTrue( e.Node1.force(1) < 0);
			testCase.verifyTrue( e.Node2.force(1) < 0);


			% This time the node is near the end of the edge
			clear e n n1 n2 f
			t.nodeList = [];
			t.elementList = [];
			p = SpacePartition(1, 1, t);

			n1 = Node(0,0,1);
			n2 = Node(0,1,2);

			e = Element(n1,n2,1);

			n = Node(0.06,0.1,3);

			f = NodeElementRepulsionForce(r, dt);

			p.PutNodeInBox(n);
			p.PutNodeInBox(n1);
			p.PutNodeInBox(n2);

			p.PutElementInBoxes(e);

			f.AddNeighbourhoodBasedForces(n, p);

			testCase.verifyTrue( n.force(1) > 0);
			testCase.verifyTrue( e.Node1.force(1) < 0);
			% testCase.verifyTrue( e.Node2.force(1) > 0);


			% % Test a specific case observed in the wild
			clear e n n1 n2 f
			load('nodePopThrough')

			n = t.boxes.nodesQ{1}{16,6}(1);
			e = t.boxes.elementsQ{1}{16,6}(3);

			clear t
			t.nodeList = [];
			t.elementList = [];
			p = SpacePartition(0.5, 0.5, t);

			p.PutNodeInBox(n);
			p.PutNodeInBox(e.Node1);
			p.PutNodeInBox(e.Node2);

			p.PutElementInBoxes(e);

			% These two should push eachother apart
			f = NodeElementRepulsionForce(r, dt);

			f.AddNeighbourhoodBasedForces(n, p);

			testCase.verifyTrue( n.force(1) < 0);
			testCase.verifyTrue( e.Node1.force(1) > 0);

			% Apply the wild case, but specify the nodes and elements directly
			clear e n n1 n2 f
			t.nodeList = [];
			t.elementList = [];
			p = SpacePartition(1, 1, t);

			n1 = Node(7.522,2.397,1);
			n2 = Node(7.737,2.894,2);

			e = Element(n1,n2,1);

			n = Node(7.704,2.86,3);

			u = e.GetVector1to2();
			v = [u(2), -u(1)];

			n1ton = n.position - e.Node1.position;
			d = dot(n1ton, v)

			f = NodeElementRepulsionForce(r, dt);

			p.PutNodeInBox(n);
			p.PutNodeInBox(n1);
			p.PutNodeInBox(n2);

			p.PutElementInBoxes(e);

			f.AddNeighbourhoodBasedForces(n, p);

			testCase.verifyTrue( n.force(1) < 0);
			testCase.verifyTrue( n2.force(1) > 0);


		end


	end

end