classdef Cell < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% Essential porperties of a node
		id

		% This will be circular - each element will have two nodes
		% each node can be part of multiple elements
		elementTop
		elementBottom
		elementLeft
		elementRight

		% Can't know for certain which order the nodes will be placed into the element
		% so need to determine these carefully when initialising
		nodeTopLeft
		nodeTopRight
		nodeBottomLeft
		nodeBottomRight

		age
		cellArea
		targetCellArea = 1

		areaGradientTopLeft
		areaGradientTopRight
		areaGradientBottomRight
		areaGradientBottomLeft

		deformationEnergyParameter = 1
		
	end

	methods
		function obj = Cell(ElementBottom, ElementLeft, ElementTop, ElementRight, id)
			% All the initilising
			% A cell will always have 4 elements

			obj.elementTop = ElementTop;
			obj.elementBottom = ElementBottom;
			obj.elementLeft = ElementLeft;
			obj.elementRight = ElementRight;

			obj.elementTop.AddCell(obj);
			obj.elementBottom.AddCell(obj);
			obj.elementLeft.AddCell(obj);
			obj.elementRight.AddCell(obj);


			obj.AddNodesInOrder();

			obj.id = id;

		end

		function UpdateCellArea(obj)
			% Use the shoelace formula to calculate the cellArea of the cell
			% See: https://en.wikipedia.org/wiki/Shoelace_formula

			tl = obj.nodeTopLeft.position;
			tr = obj.nodeTopRight.position;
			br = obj.nodeBottomRight.position;
			bl = obj.nodeBottomLeft.position;
			

			obj.cellArea = 0.5 * abs( tl(1) * tr(2) + tr(1) * br(2) + br(1) * bl(2) + bl(1) * tl(2)...
								-  tl(2) * tr(1) - tr(2) * br(1) - br(2) * bl(1) - bl(2) * tl(1));

		end

		function UpdateAreaGradientAtNode(obj)

			% Each node has an associated area gradient according the NagaiHondaForce, lifted directly from Chaste
			% I really have no idea what's going on here, I'm just crossing my fingers and hoping it makes sense

			tl = obj.nodeTopRight.position - obj.nodeBottomLeft.position;
			tr = obj.nodeBottomRight.position - obj.nodeTopLeft.position;
			br = obj.nodeBottomLeft.position - obj.nodeTopRight.position;
			bl = obj.nodeTopLeft.position - obj.nodeBottomRight.position;


			obj.areaGradientTopLeft = 0.5 * [tl(2), -tl(1)];
			obj.areaGradientTopRight = 0.5 * [tr(2), -tr(1)];
			obj.areaGradientBottomRight = 0.5 * [br(2), -br(1)];
			obj.areaGradientBottomLeft = 0.5 * [bl(2), -bl(1)];
		end

		function UpdateForce(obj)
			% Add the forces to each node due to cell area properites
			obj.UpdateAreaGradientAtNode();
			obj.UpdateCellArea();

			% deformation_contribution -= 2*GetNagaiHondaDeformationEnergyParameter()*(element_areas[elem_index] - target_areas[elem_index])*element_area_gradient;

			force = -2 * obj.deformationEnergyParameter * (obj.cellArea - obj.targetCellArea) * obj.areaGradientTopLeft;
			obj.nodeTopLeft.AddForceContribution(force);

			force = -2 * obj.deformationEnergyParameter * (obj.cellArea - obj.targetCellArea) * obj.areaGradientTopRight;
			obj.nodeTopRight.AddForceContribution(force);

			force = -2 * obj.deformationEnergyParameter * (obj.cellArea - obj.targetCellArea) * obj.areaGradientBottomRight;
			obj.nodeBottomRight.AddForceContribution(force);

			force = -2 * obj.deformationEnergyParameter * (obj.cellArea - obj.targetCellArea) * obj.areaGradientBottomLeft;
			obj.nodeBottomLeft.AddForceContribution(force);
			


		end


	end

	methods (Access = private)
		function AddNodesInOrder(obj)
			% Adds the nodes properly so we always know which node is where

			% One of the nodes in elementTop must be nodeTopLeft
			% pick the leftmost of the two. If the cell gets rotated, this will need to change
			% but for now it will do

			if obj.elementTop.Node1.x < obj.elementTop.Node2.x
				obj.nodeTopLeft = obj.elementTop.Node1;
				obj.nodeTopRight = obj.elementTop.Node2;
			else
				obj.nodeTopLeft = obj.elementTop.Node2;
				obj.nodeTopRight = obj.elementTop.Node1;
			end

			if obj.elementBottom.Node1.x < obj.elementBottom.Node2.x
				obj.nodeBottomLeft = obj.elementBottom.Node1;
				obj.nodeBottomRight = obj.elementBottom.Node2;
			else
				obj.nodeBottomLeft = obj.elementBottom.Node2;
				obj.nodeBottomRight = obj.elementBottom.Node1;
			end


		end

	end


end