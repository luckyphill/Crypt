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

	end

end