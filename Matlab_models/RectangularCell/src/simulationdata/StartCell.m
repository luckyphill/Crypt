classdef StartCell < AbstractSimulationData
	% Sets the start cell for a loop simulation

	% This assumes no cell death, so the cell can be
	% arbitrarily chosen and never needs updating

	properties 

		name = 'startCell'

	end

	methods

		function obj = CentreLine
			% No special initialisation
			obj.data = [];
		end

		function CalculateData(obj, t)

			% The only time to set it is at the beginning
			if isempty(obj.data)
				obj.data = t.cellList(1);
			end

		end
		
	end


end