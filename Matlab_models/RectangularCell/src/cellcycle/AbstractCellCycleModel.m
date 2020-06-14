classdef AbstractCellCycleModel < matlab.mixin.SetGet
	% An abstract class that gets the basics of a cell cycle model

	properties

		age

		% Colours
		PAUSE = [0.9375 0.7383 0.6562];
		GROW = [0.6562 0.8555 0.9375];
		STOPPED = [0.6680 0.5430 0.4883];
		DYING = [0.5977 0.5859 0.5820];
		STROMA = [ 0.9453, 0.9023, 0.6406]

		% An RGB triplet, default pinkish colour
		colour = [0.9375 0.7383 0.6562];

	end


	methods (Abstract)

		% Returns true if the cell meets the conditions for dividing
		ready = IsReadyToDivide(obj);
		% If a cell grows, then need to know the point in this growth
		fraction = GetGrowthPhaseFraction(obj);
		% When a cell divides, duplicate the ccm for the new cell
		newCCM = Duplicate(obj);

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

		function colour = GetColour(obj)

			colour = obj.colour;

		end


	end


end