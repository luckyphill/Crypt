classdef Node < matlab.mixin.SetGet
	% A class specifying the details about nodes

	properties
		% Essential porperties of a node
		x
		y

		position

		previousPosition

		id

		force = [0, 0]

		previousForce = [0, 0]

		% This will be circular - each element will have two nodes
		% each node can be part of multiple elements, similarly for cells
		elementList = []

		cellList = []

		isTopNode

	end

	methods

		function obj = Node(x,y,id)
			% Initialise the node

			obj.x 	= x;
			obj.y 	= y;

			obj.position = [x,y];
			
			obj.id 	= id;

		end

		function AddForceContribution(obj, force)
			obj.force = obj.force + force;

		end

		function UpdatePosition(obj, dtEta)

			% NOT USED IN SIMULATIONS, ONLY USED IN TESTING
			% Used primarily for testing to avoid making a cell population
			newPosition = obj.position + dtEta * obj.force;

			obj.NewPosition(newPosition);

			% Reset the force for next time step
			obj.previousForce = obj.force;
			obj.force = [0,0];

		end

		function AddElement(obj, ele)
			obj.elementList = [obj.elementList , ele];
			% Technically should add each cell at a time
			% but the cellLists work the same way, so we can get away with it
			% obj.AddCell(ele.cellList);
			
		end

		function RemoveElement(obj, ele)
			
			% Remove the element from the list
			obj.elementList(obj.elementList == ele) = [];

			% If removing this element means a node is no longer associated with
			% a specific cell, then the cell must also be removed. It's easier just to regenerate the cellList

			% Make a list of the cells that the node must be part of
			obj.cellList = unique([obj.elementList.cellList]);

		end

		function RemoveCell(obj, c)

			% Not likely to need this now, but leaving it anyway
			obj.cellList(obj.cellList == c) = [];

		end

		function NewPosition(obj, pos)

			obj.previousPosition = obj.position;
			obj.position = pos;

			obj.x = pos(1);
			obj.y = pos(2);

		end

		function AdjustPosition(obj, pos)
			% Used when modifying the position manually
			obj.position = pos;

			obj.x = pos(1);
			obj.y = pos(2);

		end

		function MoveNode(obj, pos)
			% This function is used to move the position due to time stepping
			% so the force must be reset here
			% This is only to be used by the numerical integration

			obj.NewPosition(pos);
			% Reset the force for next time step
			obj.previousForce = obj.force;
			obj.force = [0,0];

		end

		function AddCell(obj, c)

			% Need to add the cell, but also make sure that
			% we only have the correct cells in the list
			% This should be the best place to do it, but I haven't verified

			Lidx = ~ismember(c,obj.cellList);
			obj.cellList = [obj.cellList , c(Lidx)];

			% delCell = Cell.empty;
			% for i = 1:length(obj.cellList)
			% 	if ~ismember(obj,obj.cellList(i).nodeList)
			% 		delCell(end+1) = obj.cellList(i);
			% 	end
			% end
			% Lidx = ismember(obj.cellList, delCell);
			% obj.cellList(Lidx) = [];


		end

	end

	methods (Access = private)
		

	end


end
