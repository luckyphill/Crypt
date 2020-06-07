classdef AbstractCell < handle & matlab.mixin.Heterogeneous
	% A class specifying the details about nodes

	properties
		% Essential properties of a node
		id

		age = 0

		nodeList 	= Node.empty()
		elementList = Element.empty()

		cellArea
		cellPerimeter

		newCellTargetArea = 0.5
		grownCellTargetArea = 1
		currentCellTargetArea = 1

		newCellTargetPerimeter
		grownCellTargetPerimeter
		currentCellTargetPerimeter

		CellCycleModel

		deformationEnergyParameter = 10
		surfaceEnergyParameter = 1

		% Determines if we are using a free or joined cell model
		freeCell = false
		newFreeCellSeparation = 0.1

		% A cell divides in 2, this will store the sister
		% cell after division
		sisterCell = AbstractCell.empty();

		% Stores the id of the cell that was in the 
		% initial configuration. Only can store the id
		% because the cell can be deleted from the simulation
		ancestorId


		% A collection objects for calculating data about the cell
		% stored in a map container so each type of data can be given a
		% meaingful name
		cellData
		
	end

	methods (Abstract)

		[newCell, newNodeList, newElementList] = Divide(obj)
		inside = IsPointInsideCell(obj, point)
		flipped = HasEdgeFlipped(obj)
	end

	methods

		function delete(obj)

			clear obj;

		end

		function set.CellCycleModel( obj, v )
			% This is to validate the object given to outputType in the constructor
			if isa(v, 'AbstractCellCycleModel')
            	validateattributes(v, {'AbstractCellCycleModel'}, {});
            	obj.CellCycleModel = v;
            else
            	error('C:NotValidCCM','Not a valid cell cycle');
            end

        end

        function currentArea = GetCellArea(obj)
			% This and the following 3 functions could be replaced by accessing the cellData
			% but they're kept here for backwards compatibility, and because
			% these types of data are fundamental enough to designate a function

			currentArea = obj.cellData('cellArea').GetData(obj);

		end

		function targetArea = GetCellTargetArea(obj)
			% This is so the target area can be a function of cell age

			targetArea = obj.cellData('targetArea').GetData(obj);

		end

		function currentPerimeter = GetCellPerimeter(obj)

			currentPerimeter = obj.cellData('cellPerimeter').GetData(obj);

		end

		function targetPerimeter = GetCellTargetPerimeter(obj)
			% This is so the target Perimeter can be a function of cell age
			targetPerimeter = obj.cellData('targetPerimeter').GetData(obj);

		end

		function ready = IsReadyToDivide(obj)

			ready = obj.CellCycleModel.IsReadyToDivide();

		end

		function AddCellDataArray(obj, cellDataArray)

			% Need to explicitly create a map object or matlab
			% will only point to one map object for the
			% entire list of Cells...
			cD = containers.Map;
			for i = 1:length(cellDataArray)
				cD(cellDataArray(i).name) = cellDataArray(i);
			end

			obj.cellData = cD;

		end

		function AgeCell(obj, dt)

			% This will be done at the end of the time step
			obj.age = obj.age + dt;
			obj.CellCycleModel.AgeCellCycle(dt);

		end

		function age = GetAge(obj)

			age = obj.CellCycleModel.GetAge();
			
		end

		function colour = GetColour(obj)
			% Used for animating/plotting only

			colour = obj.CellCycleModel.GetColour();
		
		end

	end

end