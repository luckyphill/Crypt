classdef SimplePhaseBasedCellCycle < AbstractCellCycleModel
	% A cell cycle with 2 phases, a growth phase and a pause phase
	% During the pause phase the cell is a constant size (or target size)
	% During the growing phase, the cell is increasing its volume (or target volume)

	% After a fresh division, the cell stays a constant size, for a time specified by
	% pausePhaseLength, after which it starts growing

	properties

		meanPausePhaseLength
		pausePhaseLength

		meanGrowingPhaseLength
		growingPhaseLength

	end


	methods

		function obj = SimplePhaseBasedCellCycle(p, g)
			obj.SetPausePhaseLength(p);
			obj.SetGrowingPhaseLength(g);

			% Cell will start off in the pause phase
			obj.SetAge(randi(p - 1));

		end

		function newCCM = Duplicate(obj)

			newCCM = SimplePhaseBasedCellCycle(obj.meanPausePhaseLength, obj.meanGrowingPhaseLength);
			newCCM.SetAge(0);

		end

		% Cell cycle mode does nothing, so it never divides
		function ready = IsReadyToDivide(obj);

			ready = false;
			if obj.pausePhaseLength + obj.growingPhaseLength < obj.GetAge()
				ready = true;
			end

		end

		function fraction = GetGrowthPhaseFraction(obj)

			if obj.age < obj.pausePhaseLength
				fraction = 0;
				obj.colour = obj.PAUSE;
			else
				fraction = (obj.age - obj.pausePhaseLength) / obj.growingPhaseLength;
				obj.colour = obj.GROW;
			end

		end

		function SetPausePhaseLength(obj, pt)

			obj.meanPausePhaseLength = pt;

			% Normally distributed, but clipped
			wobble = normrnd(0,2);

			p = pt + wobble;

			if p < 1
				p = 1;
			end

			obj.pausePhaseLength = p;

		end

		function SetGrowingPhaseLength(obj, wt)
			% Wanted to call it gt, but apparently thats a reserved keyword in matlab...

			obj.meanGrowingPhaseLength = wt;

			% Normally distributed, but clipped
			wobble = normrnd(0,2);

			g = wt + wobble;

			if g < 1
				g = 1;
			end

			obj.growingPhaseLength = g;

		end

	end

end