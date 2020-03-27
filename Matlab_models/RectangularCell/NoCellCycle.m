classdef NoCellCycle < AbstractCellCycleModel
	% A cell cycle that does nothing except count the age of the cell

	methods

		% Cell cycle mode does nothing, so it never divides
		function ready = IsReadyToDivide(obj);

			ready = false;

		end

	end


end