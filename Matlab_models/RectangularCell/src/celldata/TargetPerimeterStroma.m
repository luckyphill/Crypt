classdef TargetPerimeterStroma < AbstractCellData
	% Target perimeter for the general case with CellFree etc.

	properties 

		name = 'targetPerimeter'
		data = []

	end

	methods

		function obj = TargetPerimeterStroma
			% No special initialisation
			
		end

		function CalculateData(obj, c)
			% For a stromal 'cell' we are going to fix the width as 0.9
			% so use that to work out the perimeter

			targetArea = c.cellData('targetArea').GetData(c);

			obj.data = 2 * (0.9 + targetArea/0.9);

		end
		
	end

end