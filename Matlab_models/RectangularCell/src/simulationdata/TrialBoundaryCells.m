classdef TrialBoundaryCells < AbstractSimulationData
	properties 
		name = 'B'
		data = containers.Map
	end
	methods
		function obj = B
			% No special initialisation
			
		end
		function CalculateData(obj, t)
			if isempty(obj.data)
				obj.data('left') 	= 1;
				obj.data('right') 	= 2;
			end
			% Other operations
		end
	end
end