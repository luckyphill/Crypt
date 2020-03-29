classdef AbstractCellCycleModel < matlab.mixin.SetGet
	% An abstract class that gets the basics of a cell cycle model

	properties

		age

	end


	methods (Abstract)

		% Returns true if the cell meets the conditions for dividing
		ready = IsReadyToDivide(obj);
		fraction = GetGrowthPhaseFraction(obj);

	end

	methods

		function age = GetAge(obj)
			
			age = obj.age;
		end

		function SetBirthTime(obj, birth)

			obj.age = birth;
		end

		function AgeCellCycle(obj, dt)

			obj.age = obj.age + dt;
		end


	end


end