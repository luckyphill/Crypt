classdef StoreWiggleRatio < AbstractDataStore
	% Stores the wiggle ratio

	properties

		% No special properties
		
	end

	methods

		function obj = StoreWiggleRatio(sm)

			obj.samplingMultiple = sm;
			obj.data = [];

		end

		function GatherData(obj, t)

			% The simulation t must have a simulation data object
			% calculating the wiggle ratio

			% Update the wiggle ratio data object

			obj.data(end + 1) = t.simData('wiggleRatio').GetData(t);

		end
		
	end

end