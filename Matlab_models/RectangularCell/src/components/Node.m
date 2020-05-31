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

		% Each node stores it's local drag coefficient, so we can distinguish
		% between different regions in a tissue more easily
		eta = 1

	end

	methods

		function obj = Node(x,y,id)
			% Initialise the node

			obj.x 	= x;
			obj.y 	= y;

			obj.position = [x,y];
			% Need to give the node a previous position so elements
			% can move to a new nox on the very first time step
			obj.previousPosition = [x,y];  
			
			obj.id 	= id;

		end

		function delete(obj)

			clear obj;

		end

		function AddForceContribution(obj, force)
			
			if sum(isnan(force)) || sum(isinf(force))
				error('Force is inf')
			end
			obj.force = obj.force + force;

		end

		function UpdatePosition(obj, dt)

			% NOT USED IN SIMULATIONS, ONLY USED IN TESTING
			% Used primarily for testing to avoid making a cell population
			newPosition = obj.position + dt/obj.eta * obj.force;

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

		function SetDragCoefficient(obj, eta)

			% Use this to change the drag coefficient
			% so that the associated elements have their
			% properties updated
			obj.eta = eta;

			for i = 1:length(obj.elementList)

				obj.elementList(i).UpdateTotalDrag();

			end

		end

	end

	methods (Access = private)
		

	end


end
