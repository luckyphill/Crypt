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
		cellPerimeter

		newCellTargetArea = 0.5
		grownCellTargetArea = 1
		currentCellTargetArea = 1

		newCellTargetPerimeter = 3
		grownCellTargetPerimeter = 4
		currentCellTargetPerimeter = 4

		% The natural length of the top and bottom elements
		% used to make cells trapezoidal shaped
		newCellTopLength = 0.5
		grownCellTopLength = 1
		currentCellTopLength = 1

		newCellBottomLength = 0.5
		grownCellBottomLength = 1
		currentCellBottomLength = 1

		CellCycleModel

		areaGradientTopLeft
		areaGradientTopRight
		areaGradientBottomRight
		areaGradientBottomLeft

		perimeterGradientTopLeft
		perimeterGradientTopRight
		perimeterGradientBottomRight
		perimeterGradientBottomLeft

		deformationEnergyParameter = 10
		surfaceEnergyParameter = 1
		
	end

	methods
		function obj = Cell(Cycle, ElementBottom, ElementLeft, ElementTop, ElementRight, id)
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

			obj.CellCycleModel = Cycle;

			obj.AddNodesInOrder();

			obj.id = id;

		end

		function set.CellCycleModel( obj, v )
			% This is to validate the object given to outputType in the constructor
			if isa(v, 'AbstractCellCycleModel')
            	validateattributes(v, {'AbstractCellCycleModel'}, {});
            	obj.CellCycleModel = v;
            else
            	error('c:NotValidCCM','Not a valid cell cycle');
            end

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

		function UpdateCellPerimeter(obj)

			obj.cellPerimeter = obj.elementTop.GetLength() + obj.elementRight.GetLength() + obj.elementBottom.GetLength() + obj.elementLeft.GetLength();

		end

		function UpdateAreaGradientAtNode(obj)

			% Each node has an associated area gradient according the NagaiHondaForce, lifted directly from Chaste
			% I really have no idea what's going on here, I'm just crossing my fingers and hoping it makes sense

			% The area gradient is a direction pointing into the cell,
			% determined by the edges attached to the node of interest
			% For a given cell, each node (A) is part of two edges. These edges have other nodes (B and C)
			% We find the vector B to C, and with some cross product arithmetic find a perpendicular
			% vector that points into the cell


			tl = obj.nodeTopRight.position 		- obj.nodeBottomLeft.position;
			tr = obj.nodeBottomRight.position 	- obj.nodeTopLeft.position;
			br = obj.nodeBottomLeft.position 	- obj.nodeTopRight.position;
			bl = obj.nodeTopLeft.position 		- obj.nodeBottomRight.position;


			obj.areaGradientTopLeft 	= 0.5 * [tl(2), -tl(1)];
			obj.areaGradientTopRight 	= 0.5 * [tr(2), -tr(1)];
			obj.areaGradientBottomRight = 0.5 * [br(2), -br(1)];
			obj.areaGradientBottomLeft 	= 0.5 * [bl(2), -bl(1)];

		end

		function UpdatePerimeterGradientAtNode(obj)

			% Each node has an associated perimeter gradient according the NagaiHondaForce, lifted directly from Chaste
			% I really have no idea what's going on here, I'm just crossing my fingers and hoping it makes sense

			% The perimeter gradient is a direction pointing into the cell,
			% determined by the edges attached to the node of interest
			% For a given cell, each node (A) is part of two edges. These edges have other nodes (B and C)
			% We find the unit vectors A to B and A to C, and add them together to get a vector
			% pointing into the cell

			% Go around in a clockwise direction

			right 	= (obj.nodeTopRight.position 	- obj.nodeBottomRight.position) / obj.elementRight.GetLength();
			bottom 	= (obj.nodeBottomRight.position - obj.nodeBottomLeft.position) 	/ obj.elementBottom.GetLength();
			left 	= (obj.nodeBottomLeft.position 	- obj.nodeTopLeft.position) 	/ obj.elementLeft.GetLength();
			top 	= (obj.nodeTopLeft.position 	- obj.nodeTopRight.position) 	/ obj.elementTop.GetLength();


			obj.perimeterGradientTopLeft 		= left 		- top;
			obj.perimeterGradientTopRight 		= top 		- right;
			obj.perimeterGradientBottomRight 	= right 	- bottom;
			obj.perimeterGradientBottomLeft 	= bottom 	- left;

		end

		function UpdateTargetAreaForce(obj)
			% Add the forces to each node due to cell area properites
			obj.UpdateAreaGradientAtNode();
			obj.UpdateCellArea();

			% deformation_contribution -= 2*GetNagaiHondaDeformationEnergyParameter()*(element_areas[elem_index] - target_areas[elem_index])*element_area_gradient;

			magnitude = 2 * obj.deformationEnergyParameter * (obj.cellArea - obj.GetCellTargetArea());

			obj.nodeTopLeft.AddForceContribution(		magnitude * obj.areaGradientTopLeft);
			obj.nodeTopRight.AddForceContribution(		magnitude * obj.areaGradientTopRight);
			obj.nodeBottomRight.AddForceContribution(	magnitude * obj.areaGradientBottomRight);
			obj.nodeBottomLeft.AddForceContribution(	magnitude * obj.areaGradientBottomLeft);

		end

		function UpdateTargetPerimeterForce(obj)
			obj.UpdatePerimeterGradientAtNode();
			obj.UpdateCellPerimeter();

			magnitude = 2 * obj.surfaceEnergyParameter * (obj.cellPerimeter - obj.GetCellTargetPerimeter());
			obj.nodeTopLeft.AddForceContribution(		magnitude * obj.perimeterGradientTopLeft);
			obj.nodeTopRight.AddForceContribution(		magnitude * obj.perimeterGradientTopRight);
			obj.nodeBottomRight.AddForceContribution(	magnitude * obj.perimeterGradientBottomRight);
			obj.nodeBottomLeft.AddForceContribution(	magnitude * obj.perimeterGradientBottomLeft);

		end

		function UpdateForce(obj)
			obj.UpdateTargetAreaForce();
			obj.UpdateTargetPerimeterForce();

		end

		function targetArea = GetCellTargetArea(obj)
			% This is so the target area can be a function of cell age

			fraction = obj.CellCycleModel.GetGrowthPhaseFraction();

			targetArea = obj.newCellTargetArea + fraction * (obj.grownCellTargetArea - obj.newCellTargetArea);

		end

		function currentArea = GetCellArea(obj)

			obj.UpdateCellArea();

			currentArea = obj.cellArea;

		end

		function targetPerimeter = GetCellTargetPerimeter(obj)
			% This is so the target Perimeter can be a function of cell age
			targetArea = obj.GetCellTargetArea();	
			targetPerimeter = 2 * (1 + targetArea);

		end

		function currentPerimeter = GetCellPerimeter(obj)

			obj.UpdateCellPerimeter();
			currentPerimeter = obj.cellPerimeter;

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

			ready = obj.CellCycleModel.IsReadyToDivide();

		end

		function AgeCell(obj, dt)

			% This will be done at the end of the time step
			obj.age = obj.age + dt;
			obj.CellCycleModel.AgeCellCycle(dt);

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