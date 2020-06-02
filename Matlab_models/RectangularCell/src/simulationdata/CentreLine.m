classdef CentreLine < AbstractSimulationData
	% Calculates the wiggle ratio

	properties 

		name = 'centreLine'

	end

	methods

		function obj = CentreLine
			% No special initialisation
			obj.data = [];
		end

		function CalculateData(obj, t)

			% Makes a sequence of points that defines the centre line of the cells
			cL = [];

			c = t.simData{'boundaryCells'}.GetData(){'left'};

			cL(end + 1, :) = c.elementLeft.GetMidPoint();
			e = c.elementRight;

			cL(end + 1, :) = e.GetMidPoint();

			% Jump through the cells until we hit the right most cell
			c = e.GetOtherCell(c);

			while ~isempty(c) 

				e = c.elementRight;
				cL(end + 1, :) = e.GetMidPoint();
				c = e.GetOtherCell(c);
			end

			obj.data = cL;

		end
		
	end


end