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

		% Cell cycle mode does nothing, so it never divides
		function ready = IsReadyToDivide(obj);

			ready = false;
			if obj.pausePhaseLength + obj.growingPhaseLength < obj.GetAge()
				ready = true;
			end

		end

		function fraction = GetGrowthPhaseFraction(obj)

			fraction = (obj.age - obj.pausePhaseLength) / obj.growingPhaseLength;
		end

		function SetPausePhaseLength(obj, pt)

			obj.meanPausePhaseLength = pt;

			obj.pausePhaseLength = pt + normrnd(0,2);

		end

		function SetGrowingPhaseLength(obj, wt)
			% Wanted to call it gt, but apparently thats a reserved keyword in matlab...

			obj.meanGrowingPhaseLength = wt;
			obj.growingPhaseLength = wt + normrnd(0,2);

		end

	end


end