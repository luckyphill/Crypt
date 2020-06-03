classdef AbstractModifiableSimulationData < AbstractSimulationData
	% The same as AbstractSimulationData, but it allows the data
	% to be modified, throwing in a validation check

	methods (Abstract)

		% This method must return data
		correct = VerifyData(obj, d)
		
	end

	methods

		function SetData(obj, d)
			% If the data needs to be directly modified
			if obj.VerifyData(d)
				obj.data = d;
			else
				error('AMSD:WrongData', 'Data in unexpected format');
			end
			
		end

	end

end