classdef RodCellArea < AbstractCellData
	% For rod cells, the area is just the length

	properties 

		name = 'cellArea'
		data = []

	end

	methods

		function obj = RodCellArea
			% No special initialisation
			
		end

		function CalculateData(obj, c)
			% Node list must be in order around the cell

			obj.data = c.elementList.GetLength();

		end
		
	end

end