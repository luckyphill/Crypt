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

			[pgtl, pgtr, pgbr, pgbl] = f.GetPerimeterGradientAtNodes(c);

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



	end

end