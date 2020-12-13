classdef LinearGrowthCellCycle < AbstractCellCycleModel
	% A cell cycle based on the growth of a cell.
	% It is broken up into three different periods (as opposed to phases or
	% stages that describe an actual cell cycle), and each period represents
	% a different target size. These are defined by milestones in the cycle
	% The first period is where the cell stays at a constant target size
	% which finishes at t0 (growthPeriodStart). From here the cell grows
	% at a constant rate until it reaches t_grown (growthPeriodEnd), at which
	% point its target length is at its full size.
	% After this it stays at its fully grown target size until certain conditions
	% are met for division.
	%  - The cell reaches a minimum age (minimumDivisionAge)
	%  - The measured cell size is above a certain fraction (minimumDivisionFraction)
	%    of its fully grown target size
	%  - If so desired, a randomly chosen variable (funcRandomVariable) is below a
	%    certain threshold (randomThreshold)

	properties


		meanGrowthPeriodStart
		meanGrowthPeriodEnd
		meanMinimumDivisionAge

		minimumDivisionFraction

		dt

		% These are set by the object, but we let them be user-modifiable
		% just in case
		growthPeriodStart
		growthPeriodEnd
		minimumDivisionAge
		

		% These must be modified after creating the object
		stochasticGrowthStart = false;
		stochasticGrowthEnd = false;
		stochasticDivisionAge = false;

		% These can, but shouldn't be modified directly
		% Use the setter function
		useRandomTrial = false;
		funcRandomVariable
		randomThreshold

		% These are to customise the colouring for the visualisation
		% They can be left as default with no issues

		% This is mainly here to make it easier to distinguish
		% rod cell colouring from polygon cell colouring

		preGrowthColour
		growthColour
		postGrowthColour
		inhibitedColour

	end


	methods

		function obj = LinearGrowthCellCycle(s, e, a, f, dt)

			if e <= s || a < s || a < e
				error("LinearGrowthCellCycle:MilestoneError",'One or more of the cycle milestones are invalid. Make sure start<end<=divisionage\n');
			end

			if e - s < 2
				msg = sprintf("The mean growth period is only %f time units. ", e-s);
				msg = sprintf("%s This may cause numerical issues due to rapid growth",msg);
				warning("LinearGrowthCellCycle:ShortGrowthWarning",msg);
			end

			% Separate out the mean milestones from the stochastic noise values
			obj.meanGrowthPeriodStart = s;
			obj.meanGrowthPeriodEnd = e;
			obj.meanMinimumDivisionAge = a;

			obj.growthPeriodStart = s;
			obj.growthPeriodEnd = e;
			obj.minimumDivisionAge = a;

			obj.minimumDivisionFraction = f;

			obj.dt = dt;

			% Randomly set the cell age
			age = floor( unifrnd(0,s) / dt ) * dt;
			obj.SetAge(age);


			% Need to specifiy these here because it won't let properties
			% be given a default called in this way
			obj.preGrowthColour = obj.colourSet.GetNumber('PAUSE');
			obj.growthColour = obj.colourSet.GetNumber('GROW');
			obj.postGrowthColour = obj.colourSet.GetNumber('PAUSE');
			obj.inhibitedColour = obj.colourSet.GetNumber('STOPPED');

		end

		% Co-opt the AgeCellCycle method to update the growth period colour
		% Could probably add in a phase tracking variable that gets updated here
		function AgeCellCycle(obj, dt)

			obj.age = obj.age + dt;

			if obj.age < obj.growthPeriodStart
				obj.colour = obj.preGrowthColour;
			else
				if obj.age < obj.growthPeriodEnd
					obj.colour = obj.growthColour;
				else
					obj.colour = obj.postGrowthColour;
					c = obj.containingCell;
					if c.GetCellArea() < obj.minimumDivisionFraction * c.GetCellTargetArea()
						obj.colour = obj.inhibitedColour;
					end
				end
			end

		end

		function newCCM = Duplicate(obj)

			% Make a new cell cycle model for the newly divided cell
			newCCM = LinearGrowthCellCycle(obj.meanGrowthPeriodStart, obj.meanGrowthPeriodEnd, obj.meanMinimumDivisionAge, obj.minimumDivisionFraction, obj.dt);
			newCCM.SetAge(0);
			obj.SetAge(0);

			newCCM.stochasticGrowthStart = obj.stochasticGrowthStart;
			newCCM.stochasticGrowthEnd = obj.stochasticGrowthEnd;
			newCCM.stochasticDivisionAge = obj.stochasticDivisionAge;

			newCCM.useRandomTrial = obj.useRandomTrial;
			newCCM.funcRandomVariable = obj.funcRandomVariable;
			newCCM.randomThreshold = obj.randomThreshold;

			% Retrigger a new stochasticly chosen variable
			% This looks a bit weird, but it should trigger the setter methods below
			obj.stochasticGrowthStart = obj.stochasticGrowthStart;
			obj.stochasticGrowthEnd = obj.stochasticGrowthEnd;
			obj.stochasticDivisionAge = obj.stochasticDivisionAge;

			% Pass on the colours
			newCCM.preGrowthColour = obj.preGrowthColour;
			newCCM.growthColour = obj.growthColour;
			newCCM.postGrowthColour = obj.postGrowthColour;
			newCCM.inhibitedColour = obj.inhibitedColour;


			% Reset the colours
			obj.colour = obj.preGrowthColour;
			newCCM.colour = obj.preGrowthColour;

		end

		function ready = IsReadyToDivide(obj)

			ready = false;

			c = obj.containingCell;

			if obj.minimumDivisionAge < obj.GetAge() && c.GetCellArea() > obj.minimumDivisionFraction * c.GetCellTargetArea()
				
				if obj.useRandomTrial

					if obj.randomThreshold * obj.dt > obj.funcRandomVariable()
						ready = true;
					end

				else
					ready = true;
				end

			end

		end

		function fraction = GetGrowthPhaseFraction(obj)

			if obj.age < obj.growthPeriodStart
				fraction = 0;
			else
				if obj.age < obj.growthPeriodEnd
					fraction = (obj.age - obj.growthPeriodStart) / (obj.growthPeriodEnd - obj.growthPeriodStart);
				else
					fraction = 1;
				end
			end

		end

		function SetRandomTrialDivisionCondition(obj, func, threshold)

			% func must be a random number generator function that produces numbers
			% strictly between 0 and 1
			% The threshold is the number of successful events in one time unit
			% so if the value is 0.1, then there should on average be 1 success
			% in 10 time units. If threshold is 1/dt then it will be successful at every time step

			obj.useRandomTrial = true;
			obj.funcRandomVariable = func;
			obj.randomThreshold = threshold;

		end

		function set.stochasticGrowthStart(obj, yn)

			% In order for this to run, the growthStart variable must be set
			obj.stochasticGrowthStart = yn;

			if yn

				s = obj.meanGrowthPeriodStart;

				wobble = unifrnd(-2,2);

				s = s + wobble;

				if s < 0
					s = 0;
				end

				obj.growthPeriodStart = s;

			else
				obj.growthPeriodStart = obj.meanGrowthPeriodStart;
			end

		end

		function set.stochasticGrowthEnd(obj, yn)

			% In order for this to run, the growthEnd variable must be set
			obj.stochasticGrowthEnd = yn;

			if yn

				e = obj.meanGrowthPeriodEnd;

				wobble = unifrnd(-2,2);

				e = e + wobble;

				if e < obj.growthPeriodStart
					e = obj.growthPeriodStart + 2;
				end

				obj.growthPeriodEnd = e;

			else
				obj.growthPeriodEnd = obj.meanGrowthPeriodEnd;

			end

		end

		function set.stochasticDivisionAge(obj, yn)

			% In order for this to run, the DivisionAge variable must be set
			obj.stochasticDivisionAge = yn;

			if yn

				a = obj.meanMinimumDivisionAge;

				wobble = unifrnd(-2,2);

				a = a + wobble;

				if a < obj.growthPeriodEnd
					a = obj.growthPeriodEnd;
				end

				obj.minimumDivisionAge = a;

			else
				obj.minimumDivisionAge = obj.meanMinimumDivisionAge;

			end

		end

	end

end