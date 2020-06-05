classdef TargetPerimeterSquare < AbstractCellData
	% Calculates the wiggle ratio

	properties 

		name = 'targetPerimeter'
		data = []

	end

	methods

		function obj = TargetPerimeterSquare
			% No special initialisation
			
		end

		function CalculateData(obj, c)
			% Node list must be in order around the cell

			targetArea = c.cellData('targetArea').GetData(c);

			obj.data = 2 * (1 + targetArea);

		end
		
	end

end