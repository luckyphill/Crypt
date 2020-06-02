classdef WiggleRatio < AbstractSimulationData
	% Calculates the wiggle ratio

	properties 

		name = 'wiggleRatio'

	end

	methods

		function obj = WiggleRatio
			% No special initialisation
			obj.data = 1;
		end

		function CalculateData(obj, t)

			cl = t.simData{'centreLine'}.GetData();

			l = 0;

			for i = 1:length(cl)-1
				l = l + norm(cl(i,:) - cl(i+1,:));
			end

			w = cl(end,1) - cl(1,1);

			obj.data = l / w;

		end
		
	end


end