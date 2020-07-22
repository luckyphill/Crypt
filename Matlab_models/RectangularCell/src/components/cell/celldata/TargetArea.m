classdef TargetArea < AbstractCellData
	% Calculates the wiggle ratio

	properties 

		name = 'targetArea'
		data = []

	end

	methods

		function obj = TargetArea
			% No special initialisation
			
		end

		function CalculateData(obj, c)
			% Node list must be in order around the cell

			fraction = c.CellCycleModel.GetGrowthPhaseFraction();

			obj.data = c.newCellTargetArea + fraction * (c.grownCellTargetArea - c.newCellTargetArea);

		end
		
	end

end