classdef SimplePhaseBasedCellCycle < AbstractCellCycleModel
	% A cell cycle that does nothing except count the age of the cell

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