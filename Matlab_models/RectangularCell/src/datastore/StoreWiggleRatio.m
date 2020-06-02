classdef StoreWiggleRatio < AbstractDataStore
	% Stores the wiggle ratio

	properties

		% No special properties
		
	end

	methods

		function obj = StoreWiggleRatio(sm)

			obj.samplingMultiple = sm;

		end

		function GatherData(obj, t)

			% The simulation t must have a simulation data object
			% calculating the wiggle ratio

			% Update the wiggle ratio data object

			if isempty(obj.data)
				obj.data = t.simData{'wiggleRatio'}.GetData();
			else
				obj.data(end + 1) = t.simData{'wiggleRatio'}.GetData();
			end

		end
		
	end

end