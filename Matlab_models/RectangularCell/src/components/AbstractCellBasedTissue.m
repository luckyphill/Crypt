classdef (Abstract) AbstractCellBasedTissue < AbstractTissue
	% A parent class for a cell based tissue. This is used for things
	% like epithelia or anythign rally that is made up of cells

	properties

		cellList
		nextCellId = 1

		cellBasedForces AbstractCellBasedForce

		tissueBasedForces AbstractCellBasedTissueForce
		
		neighbourhoodBasedForces AbstractNeighbourhoodBasedForce

		tissueLevelKillers AbstractTissueLevelCellKiller
		cellKillers AbstractCellKiller

	end

	methods

		function MakeTissueGrow(obj)

			% Call the divide process, and update the lists
			newCells 	= AbstractCell.empty();
			newElements = Element.empty();
			newNodes 	= Node.empty();
			for i = 1:length(obj.cellList)
				c = obj.cellList(i);
				if c.IsReadyToDivide()
					[newCellList, newNodeList, newElementList] = c.Divide();
					newCells = [newCells, newCellList];
					newElements = [newElements, newElementList];
					newNodes = [newNodes, newNodeList];
				end
			end

			obj.AddNewCells(newCells, newElements, newNodes);

		end

		function AddNewCells(obj, newCells, newElements, newNodes)
			% When a cell divides, need to make sure the new cell object
			% as well as the new elements and nodes are correctly added to
			% their respective lists and boxes if relevant

			for i = 1:length(newNodes)

				n = newNodes(i);
				n.id = obj.GetNextNodeId();
				if obj.usingBoxes
					obj.partition.PutNodeInBox(n);
				end

			end

			for i = 1:length(newElements)

				e = newElements(i);
				e.id = obj.GetNextElementId();
				if obj.usingBoxes && ~e.internal
					obj.partition.PutElementInBoxes(e);
				end

			end

			for i = 1:length(newCells)
				
				nc = newCells(i);
				nc.id = obj.GetNextCellId();

				if obj.usingBoxes

					% Not necessary, as external elements never become internal elements
					% even considering cell death. As long as the internal flag is set
					% correctly during division, there is no issue
					% % If the cell type is joined, then we need to make sure the
					% % internal element is labelled as such, and that the element
					% % is removed from the partition.

					% if strcmp(class(nc), 'SquareCellJoined')

					% 	if ~nc.elementRight.internal
					% 		nc.elementRight.internal = true;
					% 		obj.partition.RemoveElementFromPartition(nc.elementRight);
					% 	end

					% end

					% When a division occurs, the nodes and elements of the sister cell
					% (which was also the parent cell before division), may
					% have been modified to have a different node. This screws
					% with the space partition, so we have to fix it
					oc = nc.sisterCell;

					% Repair modified elements goes first because that adjusts nodes
					% in the function
					for j = 1:length(oc.elementList)
						e = oc.elementList(j);
						
						if e.modifiedInDivision
							obj.partition.RepairModifiedElement(e);
						end

					end

					for j = 1:length(oc.nodeList)
						n = oc.nodeList(j);

						if n.nodeAdjusted
							obj.partition.UpdateBoxForNodeAdjusted(n);
						end

					end

				end

			end


			obj.cellList = [obj.cellList, newCells];

			obj.elementList = [obj.elementList, newElements];

			obj.nodeList = [obj.nodeList, newNodes];

		end

		function AddCellBasedForce(obj, f)

			if isempty(obj.cellBasedForces)
				obj.cellBasedForces = f;
			else
				obj.cellBasedForces(end + 1) = f;
			end

		end

		function AddTissueLevelKiller(obj, k)

			if isempty(obj.tissueLevelKillers)
				obj.tissueLevelKillers = k;
			else
				obj.tissueLevelKillers(end + 1) = k;
			end

		end

		function AddCellKiller(obj, k)

			if isempty(obj.cellKillers)
				obj.cellKillers = k;
			else
				obj.cellKillers(end + 1) = k;
			end

		end

		function KillCells(obj)

			% Loop through the cell killers

			for i = 1:length(obj.tissueLevelKillers)
				obj.tissueLevelKillers(i).KillCells(obj);
			end

			for i = 1:length(obj.cellKillers)
				obj.cellKillers(i).KillCells(obj.cellList);
			end

		end

		function numCells = GetNumCells(obj)

			numCells = length(obj.cellList);

		end

	end

	methods (Access = protected)

		function id = GetNextCellId(obj)
			
			id = obj.nextCellId;
			obj.nextCellId = obj.nextCellId + 1;

		end

	end

end