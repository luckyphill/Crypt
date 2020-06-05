classdef NagaiHondaForce < AbstractCellBasedForce
	% Applies the Nagai Honda force copied directly from Chaste


	properties

		areaEnergyParameter
		surfaceEnergyParameter
		edgeAdhesionParameter

	end

	methods

		function obj = NagaiHondaForce(areaP, surfaceP, adhesionP)

			obj.areaEnergyParameter 	= areaP;
			obj.surfaceEnergyParameter 	= surfaceP;
			obj.edgeAdhesionParameter 	= adhesionP;
			
		end

		function AddCellBasedForces(obj, cellList)

			% For each cell in the list, calculate the forces
			% and add them to the nodes

			for i = 1:length(cellList)

				c = cellList(i);
				obj.AddTargetAreaForces(c);
				obj.AddTargetPerimeterForces(c);
				obj.AddAdhesionForces(c);

			end

		end

		function AddTargetAreaForces(obj, c)
			% Add the forces to each node due to cell area properites
			[tl, tr, br, bl] 	= obj.GetAreaGradientAtNodes(c);
			currentArea 		= c.GetCellArea();
			targetArea 			= c.GetCellTargetArea();

			% deformation_contribution -= 2*GetNagaiHondaDeformationEnergyParameter()*(element_areas[elem_index] - target_areas[elem_index])*element_area_gradient;

			magnitude = 2 * obj.areaEnergyParameter * (currentArea - targetArea);

			c.nodeTopLeft.AddForceContribution(		magnitude * tl);
			c.nodeTopRight.AddForceContribution(	magnitude * tr);
			c.nodeBottomRight.AddForceContribution(	magnitude * br);
			c.nodeBottomLeft.AddForceContribution(	magnitude * bl);

		end

		function AddTargetPerimeterForces(obj, c)
			
			[currentPerimeter, tl, tr, br, bl] 	= obj.GetPerimeterAndGradientAtNodes(c);
			% currentPerimeter 	= c.GetCellPerimeter();
			targetPerimeter 	= c.GetCellTargetPerimeter();

			magnitude = 2 * obj.surfaceEnergyParameter * (currentPerimeter - targetPerimeter);

			c.nodeTopLeft.AddForceContribution(		magnitude * tl);
			c.nodeTopRight.AddForceContribution(	magnitude * tr);
			c.nodeBottomRight.AddForceContribution(	magnitude * br);
			c.nodeBottomLeft.AddForceContribution(	magnitude * bl);

		end

		function AddAdhesionForces(obj, c)

			% Each element has a gradient according to NagaiHonda force that is used for calculating the contribution from adhesion
			% The gradient is the opposite sign at each node, so need to take care to make sure the sign is correct
			% for each node when the force is actually applied. To this end, we will always have the vector pointing from Node1 to Node2
			% This force always wants to shrink the element, so pushes the nodes together along the element's vector

			et = c.elementTop;
			eb = c.elementBottom;
			el = c.elementLeft;
			er = c.elementRight;

			[egt, egb, egl, egr] = obj.GetEdgeGradientOnElements(c);

			ft = obj.edgeAdhesionParameter * egt;
			fb = obj.edgeAdhesionParameter * egb;
			fl = obj.edgeAdhesionParameter * egl;
			fr = obj.edgeAdhesionParameter * egr;

			el.Node1.AddForceContribution(fl);
			el.Node2.AddForceContribution(-fl);
			
			er.Node1.AddForceContribution(fr);
			er.Node2.AddForceContribution(-fr);
			
			et.Node1.AddForceContribution(ft);
			et.Node2.AddForceContribution(-ft);
			
			eb.Node1.AddForceContribution(fb);
			eb.Node2.AddForceContribution(-fb);

		end


		function [agtl, agtr, agbr, agbl] = GetAreaGradientAtNodes(obj, c)

			% Each node has an associated area gradient according the NagaiHondaForce, lifted directly from Chaste
			% I really have no idea what's going on here, I'm just crossing my fingers and hoping it makes sense

			% The area gradient is a direction pointing into the cell,
			% determined by the edges attached to the node of interest
			% For a given cell, each node (A) is part of two edges. These edges have other nodes (B and C)
			% We find the vector B to C, and with some cross product arithmetic find a perpendicular
			% vector that points into the cell


			tl = c.nodeTopRight.position 		- c.nodeBottomLeft.position;
			tr = c.nodeBottomRight.position 	- c.nodeTopLeft.position;
			br = c.nodeBottomLeft.position 		- c.nodeTopRight.position;
			bl = c.nodeTopLeft.position 		- c.nodeBottomRight.position;


			agtl 	= 0.5 * [tl(2), -tl(1)];
			agtr 	= 0.5 * [tr(2), -tr(1)];
			agbr 	= 0.5 * [br(2), -br(1)];
			agbl 	= 0.5 * [bl(2), -bl(1)];

		end

		function [p, pgtl, pgtr, pgbr, pgbl] = GetPerimeterAndGradientAtNodes(obj, c)

			% Each node has an associated perimeter gradient according the NagaiHondaForce, lifted directly from Chaste
			% I really have no idea what's going on here, I'm just crossing my fingers and hoping it makes sense

			% The perimeter gradient is a direction pointing into the cell,
			% determined by the edges attached to the node of interest
			% For a given cell, each node (A) is part of two edges. These edges have other nodes (B and C)
			% We find the unit vectors A to B and A to C, and add them together to get a vector
			% pointing into the cell

			% Go around in a clockwise direction

			lRight = c.elementRight.GetLength();
			lBottom = c.elementBottom.GetLength();
			lLeft = c.elementLeft.GetLength();
			lTop = c.elementTop.GetLength();

			p = lRight + lBottom + lLeft + lTop;

			right 	= (c.nodeTopRight.position 		- c.nodeBottomRight.position) 	/ lRight;
			bottom 	= (c.nodeBottomRight.position 	- c.nodeBottomLeft.position) 	/ lBottom;
			left 	= (c.nodeBottomLeft.position 	- c.nodeTopLeft.position) 		/ lLeft;
			top 	= (c.nodeTopLeft.position 		- c.nodeTopRight.position) 		/ lTop;


			pgtl 	= left 		- top;
			pgtr 	= top 		- right;
			pgbr 	= right 	- bottom;
			pgbl 	= bottom 	- left;

		end

		function [egt, egb, egl, egr] = GetEdgeGradientOnElements(obj, c)

			et = c.elementTop;
			eb = c.elementBottom;
			el = c.elementLeft;
			er = c.elementRight;


			egt = (et.Node2.position - et.Node1.position) / et.GetLength();
			egb = (eb.Node2.position - eb.Node1.position) / eb.GetLength();
			egl = (el.Node2.position - el.Node1.position) / el.GetLength();
			egr = (er.Node2.position - er.Node1.position) / er.GetLength();

		end



	end



end