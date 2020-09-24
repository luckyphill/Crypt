classdef ExponentialGrowthCellCycle < AbstractCellCycleModel
	% Originally written for the rod cell but should be ok for any cell

	properties
		
		% The length of time to grow to full size
		growthRate
		% The chance a cell will divide over an hour
		% Must be between 0 and 1
		dt

		% Each cell will divide at a slightly different size
		% use this parameter to make a small difference
		volumeDelta

	end


	methods

		function obj = ExponentialGrowthCellCycle(g, dt)
			
			obj.growthRate = g;
			obj.dt = dt;
			obj.SetAge(0);

			% The volume at division will be +/- 10% of the target volume
			obj.volumeDelta = (rand - 0.5) * 0.1;

		end

		% Redefine the AgeCellCycle method to update the phase colour
		% Could probably add in a phase tracking variable that gets updated here
		function AgeCellCycle(obj, dt)

			obj.age = obj.age + dt;

		end

		function newCCM = Duplicate(obj)

			newCCM = ExponentialGrowthCellCycle(obj.growthRate, obj.dt);
			newCCM.SetAge(0);
			newCCM.colour = obj.colour;
			obj.volumeDelta = (rand - 0.5) * 0.1;

		end

		function ready = IsReadyToDivide(obj);

			c = obj.containingCell;
			ready = false;

			if c.GetCellArea() > c.grownCellTargetArea * (1 + obj.volumeDelta)
				ready = true;
			end

		end

		function fraction = GetGrowthPhaseFraction(obj)

			% At each time step, the cell exponentially gets larger
			% based on it's current size. This is supposed to represent
			% accelerated growth as the larger cell draws in more nutrients

			% The volume changes as dV/dt = gV where g is the growth rate
			% This means at any given time, the volume is V(t) = V0 exp(gt)
			% The fraction is therefore f = exp(gt)

			% In this model, the cell can get larger than its target volume,
			% but only by a small prescribed amount

			% Since the fraction needs to be between 0 and 1 to represent the
			% fraction of time between smallest and largest size, need to
			% substract 1

			fraction = exp(obj.growthRate * obj.age) - 1;

		end

	end

end