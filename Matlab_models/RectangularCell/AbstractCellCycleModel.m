classdef AbstractCellCycleModel < matlab.mixin.SetGet
	% An abstract class that gets the basics of a cell cycle model

	properties

		age

	end


	methods (Abstract)

		% Returns true if the cell meets the conditions for dividing
		ready = IsReadyToDivide(obj);
		% If a cell grows, then need to know the point in this growth
		fraction = GetGrowthPhaseFraction(obj);
		% When a cell divides, duplicate the ccm for the new cell
		newCCM = Duplicate();

	end

	methods

		function age = GetAge(obj)
			
			age = obj.age;
		end

		function SetAge(obj, age)

			obj.age = age;
		end

		function AgeCellCycle(obj, dt)

			obj.age = obj.age + dt;
		end


	end


end