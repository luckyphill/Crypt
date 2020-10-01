classdef RandomDivisionCellCycle < AbstractCellCycleModel
	% This cell cycle model randomly decides when a cell should start growing
	% When the cell starts growing, it keeps adding area until it's 
	% actual area is above a given threshold, at which point it divides

	properties
		
		% The length of time to grow to full size
		growthAmountHour
		% The chance a cell will divide over an hour
		% Must be between 0 and 1

		divisionProbHour
		dt

		growing = false

		currentFraction = 0

	end


	methods

		function obj = RandomDivisionCellCycle(p, g, dt)
			
			% g is the amount of area added per hour
			obj.growthAmountHour = g;
			obj.divisionProbHour = p;
			obj.dt = dt;
			obj.SetAge(0);
			obj.growing = false;
			obj.currentFraction = 0;
			obj.colour = obj.colourSet.GetNumber('PAUSE');

		end

		% Redefine the AgeCellCycle method to update the phase colour
		% Could probably add in a phase tracking variable that gets updated here
		function AgeCellCycle(obj, dt)

			obj.age = obj.age + dt;

		end

		function newCCM = Duplicate(obj)

			newCCM = RandomDivisionCellCycle(obj.growthAmountHour, obj.divisionProbHour, obj.dt);
			newCCM.SetAge(0);
			obj.growing = false;
			obj.colour = obj.colourSet.GetNumber('PAUSE');
			obj.currentFraction = 0;

		end

		function ready = IsReadyToDivide(obj);

			c = obj.containingCell;
			ready = false;

			if c.GetCellArea() >= c.grownCellTargetArea
				ready = true;
			end

		end

		function fraction = GetGrowthPhaseFraction(obj)

			% Grows to a target size and stays there until random division

			if obj.growing
				% control the growth
				obj.colour = obj.colourSet.GetNumber('GROW');
				obj.currentFraction = obj.currentFraction + obj.dt * obj.growthAmountHour;
			else
				obj.colour = obj.colourSet.GetNumber('PAUSE');
				if rand < obj.dt * obj.divisionProbHour
					obj.growing = true;
				end

			end  

			fraction = obj.currentFraction;

		end

	end

end