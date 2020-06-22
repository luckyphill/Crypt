classdef TopWiggleRatio < AbstractSimulationData
	% Calculates the wiggle ratio of the top of the cells

	properties 

		name = 'topWiggleRatio'
		data = 1;

	end

	methods

		function obj = TopWiggleRatio
			% No special initialisation
			
		end

		function CalculateData(obj, t)

			l = 0;
			for i = 1:t.GetNumCells()
				l = l + t.cellList(i).elementTop.GetLength();
			end

			sd = t.simData('boundaryCells');
			bcs = sd.GetData(t);
			cl = bcs('left');
			cr = bcs('right');

			w = cr.nodeTopRight.x - cl.nodeTopLeft.x;

			obj.data = l/w;

		end
		
	end


end