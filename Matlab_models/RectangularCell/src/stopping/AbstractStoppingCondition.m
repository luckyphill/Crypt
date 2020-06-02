classdef AbstractStoppingCondition < matlab.mixin.Heterogeneous
	% This class gives the details for how stopping conditions
	% must be implemented

	properties (Abstract)

		% Give the stopping condition a name for user feedback
		name

	end

	methods

		% t is an AbstractCellSimulation
		function stopped = CheckStoppingCondition(obj, t)

			if HasStoppingConditionBeenMet(obj, t)
				fprintf('Simulation stopped by %s\n', obj.name);
			end

		end

	end

	methods  (Abstract)

		stopped = HasStoppingConditionBeenMet(obj, t)
		
	end



end