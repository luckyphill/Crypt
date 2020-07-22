classdef YDeviation < AbstractSimulationData
	% Calculates the wiggle ratio

	properties 

		name = 'yDeviation'
		data = 1;

	end

	methods

		function obj = YDeviation
			% No special initialisation
			
		end

		function CalculateData(obj, t)

			% Calculates the average y deviation from the starting position
			cL = t.simData('centreLine').GetData(t);

			obj.data = mean(cl(:,2) - 0.5);

		end
		
	end

end