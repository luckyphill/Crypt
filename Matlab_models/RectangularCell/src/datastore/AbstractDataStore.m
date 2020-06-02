classdef AbstractDataStore < matlab.mixin.Heterogeneous
	% This class sets out the required functions for storing
	% data about the simulation over time

	% This could be as simple as the number of cells, or as
	% detailed as the precise position of all the elements
	% It doesn't need to go as far as saving the entire state
	% because Matlab does that with its own save function

	% This will often be closely linked to a SimulationData object

	properties (Abstract)

		% How many steps between each data point
		samplingMultiple

	end

	properties
		% A structure that holds the data
		data

		% The corresponding time point
		tPoints

	end

	methods (Abstract)

		GatherData(obj, t);
		
	end

	methods

		function StoreData(obj, t)

			if mod(t.steps, obj.samplingMultiple) == 0

				obj.GatherData(t);

			end

		end

	end

end