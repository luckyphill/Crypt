classdef SimpleRodCellCycle < AbstractCellCycleModel
	% A cell cycle for rod cells

	properties
		
		% The length of time to grow to full size
		growTime
		% The chance a cell will divide over an hour
		% Must be between 0 and 1

		divisionProbHour

		minDivisionSize = 0.8
		dt

	end


	methods

		function obj = SimpleRodCellCycle(g, d, dt, varargin)
			
			obj.growTime = g;
			obj.divisionProbHour = d;
			% The minimum fraction fo the fully grown size where division is still allowed
			% Basically the contact inhibtiion fraction, but as soon as it gets to that fraction
			% division can happen
			if ~isempty(varargin)
				obj.minDivisionSize = varargin{1};
			end
			obj.dt = dt;
			obj.SetAge(0);

		end

		% Redefine the AgeCellCycle method to update the phase colour
		% Could probably add in a phase tracking variable that gets updated here
		function AgeCellCycle(obj, dt)

			obj.age = obj.age + dt;

		end

		function newCCM = Duplicate(obj)

			newCCM = SimpleRodCellCycle(obj.growTime, obj.divisionProbHour, obj.dt, obj.minDivisionSize);
			newCCM.SetAge(0);
			newCCM.colour = obj.colour;

		end

		function ready = IsReadyToDivide(obj);

			c = obj.containingCell;
			ready = false;
			
			if (obj.age > obj.growTime) && (c.elementList.GetLength() > obj.minDivisionSize * c.grownCellTargetArea) && (obj.divisionProbHour * obj.dt > rand)
				ready = true;
			end

		end

		function fraction = GetGrowthPhaseFraction(obj)

			% Grows to a target size and stays there until random division
			if obj.age < obj.growTime
				fraction = obj.age / obj.growTime;
				obj.colour = obj.colourSet.GetNumber('PILLGROW');
			else
				fraction = 1;
				obj.colour = obj.colourSet.GetNumber('PILL');
			end

		end

	end

end