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

		age = 0
		cellArea

		newCellTargetArea = 0.5
		grownCellTargetArea = 1
		currentCellTargetArea = 1

		% The natural length of the top and bottom elements
		% used to make cells trapezoidal shaped
		newCellTopLength = 0.5
		grownCellTopLength = 1
		currentCellTopLength = 1

		newCellBottomLength = 0.5
		grownCellBottomLength = 1
		currentCellBottomLength = 1

		meanCellCycleLength
		cellCycleLength
		meanGrowingPhaseLength
		growingPhaseLength

		areaGradientTopLeft
		areaGradientTopRight
		areaGradientBottomRight
		areaGradientBottomLeft

		deformationEnergyParameter = 10
		
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

			force = 2 * obj.deformationEnergyParameter * (obj.cellArea - obj.GetCellTargetArea()) * obj.areaGradientTopLeft;
			obj.nodeTopLeft.AddForceContribution(force);

			force = 2 * obj.deformationEnergyParameter * (obj.cellArea - obj.GetCellTargetArea()) * obj.areaGradientTopRight;
			obj.nodeTopRight.AddForceContribution(force);

			force = 2 * obj.deformationEnergyParameter * (obj.cellArea - obj.GetCellTargetArea()) * obj.areaGradientBottomRight;
			obj.nodeBottomRight.AddForceContribution(force);

			force = 2 * obj.deformationEnergyParameter * (obj.cellArea - obj.GetCellTargetArea()) * obj.areaGradientBottomLeft;
			obj.nodeBottomLeft.AddForceContribution(force);


		end

		function targetArea = GetCellTargetArea(obj)
			% This is so the target area can be a function of cell age

			targetArea = obj.currentCellTargetArea;

		end

		function newCell = Divide(obj)
			% To divide, split the top and bottom elements in half
			% add an element in the middle

			% After division, cell growth occurs

			tl 					= obj.nodeTopLeft.position;
			tr 					= obj.nodeTopRight.position;
			br 					= obj.nodeBottomRight.position;
			bl 					= obj.nodeBottomLeft.position;

			midTop 				= tl + (tr - tl)/2;
			midBottom 			= bl + (br - bl)/2;

			% TODO: Sort out id counting from here (maybe remove it altogether?)
			nodeMiddleTop 		= Node(midTop(1),midTop(2),1);
			nodeMiddleBottom 	= Node(midBottom(1), midBottom(2),2);
			
			elementMiddle 		= Element(nodeMiddleTop, nodeMiddleBottom, 1);

			% Existing cell is moved to the right, new cell appears to the left

			newElementTop 		= Element(obj.nodeTopLeft, nodeMiddleTop, 1);
			newElementBottom 	= Element(obj.nodeBottomLeft, nodeMiddleBottom, 1);

			% Create new cell before remodelling old cell
			newCell = Cell(newElementBottom, obj.elementLeft, newElementTop, elementMiddle, 1);
			newCell.SetCellCycleLength(obj.meanCellCycleLength);
			newCell.SetGrowingPhaseLength(obj.meanGrowingPhaseLength);

			% Preserve the existing elements to stay with the original cell
			obj.elementTop.ReplaceNode(obj.nodeTopLeft, nodeMiddleTop);
			obj.elementBottom.ReplaceNode(obj.nodeBottomLeft, nodeMiddleBottom);
			obj.elementLeft 	= elementMiddle;

			% Replace the nodes of the cell
			obj.nodeTopLeft 	= nodeMiddleTop;
			obj.nodeBottomLeft 	= nodeMiddleBottom;

			% Old cell should be completely remodelled by this point, adjust the age back to zero

			obj.age = 0;

		end

		function ready = IsReadyToDivide(obj)

			% Need to implement a cell cycle model thing here
			if obj.age > obj.cellCycleLength
				ready = true;
			else
				ready = false;
			end

		end

		function AgeCell(obj, dt)

			% This will be done at the end of the time step

			obj.age = obj.age + dt;

			% Increase the target area
			if obj.age < obj.growingPhaseLength
				obj.currentCellTargetArea = obj.newCellTargetArea + (obj.age/obj.growingPhaseLength) * (obj.grownCellTargetArea - obj.newCellTargetArea);
			else
				obj.currentCellTargetArea = obj.grownCellTargetArea;
			end

			% Manage top and bottom element lengths
			if obj.age < obj.growingPhaseLength
				obj.currentCellTopLength = obj.newCellTopLength + (obj.age/obj.growingPhaseLength) * (obj.grownCellTopLength - obj.newCellTopLength);
				obj.currentCellBottomLength = obj.newCellBottomLength + (obj.age/obj.growingPhaseLength) * (obj.grownCellBottomLength - obj.newCellBottomLength);
			else
				obj.currentCellTopLength = obj.grownCellTopLength
				obj.currentCellBottomLength = obj.grownCellBottomLength
			end

			obj.elementTop.naturaLength = obj.currentCellTopLength;
			obj.elementBottom.naturaLength = obj.currentCellBottomLength;

		end


		function SetCellCycleLength(obj, cct)

			obj.meanCellCycleLength = cct;

			obj.cellCycleLength = cct * (1 + normrnd(0,2));

			% Need to add a check to make sure it's not ridiculously short
			% This isn't done very well at the minute, may cause problems
			if obj.cellCycleLength < 2
				obj.cellCycleLength = cct;
			end

		end

		function SetGrowingPhaseLength(obj, wt)
			% Wanted to call it gt, but apparently thats a reserved keyword in matlab...
			% Make sure it's not ridiculously short

			obj.meanGrowingPhaseLength = wt;
			obj.growingPhaseLength = wt * (1 + normrnd(0,2));


		end

		function SetBirthTime(obj, birth)
			% When making new cells, we don't want them to be dividing at the same time
			obj.age = birth;

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