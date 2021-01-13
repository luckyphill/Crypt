classdef AlphaWrinkle < AbstractSimulationData
	% Calculates the wiggle ratio

	properties 

		name = 'alphaWrinkle'
		data = 1;

	end

	methods

		function obj = AlphaWrinkle
			% No special initialisation
			
		end

		function CalculateData(obj, t)

			% Calculates the alpha wrinkliness parameter from Dunn 2011 eqn 10
			cL = t.simData('centreLine').GetData(t);

			r = 0;

			for i = 1:length(cL) - 1

				c = obj.cellList(i);

				dx = cL(i,1) - cL(i+1,1);
				dy = cL(i,2) - cL(i+1,2);
				

				r = r + abs(dy/dx);

			end

			obj.data = r / obj.GetNumCells();

		end
		
	end

end