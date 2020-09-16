classdef WntCellCycle < AbstractCellCycleModel
	% A cell cycle with 2 phases, a growth phase and a pause phase
	% During the pause phase the cell is a constant size (or target size)
	% During the growing phase, the cell is increasing its volume (or target volume)

	% After a fresh division, the cell stays a constant size, for a time specified by
	% pausePhaseLength, after which it starts growing

	% This offers a way to make cells stop growing after they reach a certain position
	% It is intended at this moment to be a quick hack to make cells stop growing in a crypt

	properties

		meanPausePhaseLength
		pausePhaseLength

		meanGrowingPhaseLength
		growingPhaseLength

		differentiated = false;

	end


	methods

		function obj = WntCellCycle(p, g)
			obj.SetPausePhaseLength(p);
			obj.SetGrowingPhaseLength(g);

			% By default cell will start off in the pause phase
			% (actually, this will depend somewhat on the randomly
			% chosen pausePhaselength)
			obj.SetAge(randi(p - 1));

		end

		% Redefine the AgeCellCycle method to update the phase colour
		% Could probably add in a phase tracking variable that gets updated here
		function AgeCellCycle(obj, dt)

			% Using the AgeCellCycle method, determine whether the cell is differentiated
			% by checking it's height. This is a quick hack to get it working.
			% The height is a proxy for Wnt concentration
			% The cell can only become differentiated if the cell is in the PAUSE phase
			obj.age = obj.age + dt;
			if ~obj.differentiated
				if obj.age > obj.pausePhaseLength
					obj.colour = obj.colourSet.GetNumber('GROW');
				else
					centre = obj.containingCell.GetCellCentre();
					if centre(2) > 2.5
						obj.differentiated = true;
						obj.colour = obj.colourSet.GetNumber('STOPPED');
					end
				end
			end

		end

		function newCCM = Duplicate(obj)

			newCCM = WntCellCycle(obj.meanPausePhaseLength, obj.meanGrowingPhaseLength);
			newCCM.SetAge(0);
			newCCM.colour = obj.colourSet.GetNumber('PAUSE');

		end

		function ready = IsReadyToDivide(obj);

			ready = false;
			if ~obj.differentiated && obj.pausePhaseLength + obj.growingPhaseLength < obj.GetAge()
				ready = true;
			end

		end

		function fraction = GetGrowthPhaseFraction(obj)

			if obj.age < obj.pausePhaseLength || obj.differentiated
				fraction = 0;
				% obj.colour = obj.colourSet.GetNumber('PAUSE');
			else
				fraction = (obj.age - obj.pausePhaseLength) / obj.growingPhaseLength;
				obj.colour = obj.colourSet.GetNumber('GROW');
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