classdef TrialCentreLine < AbstractSimulationData
	properties 
		name = 'A'
		data = []
	end
	methods
		function obj = A
			% No special initialisation
			
		end
		function CalculateData(obj, t)
			test = t.B.GetData(t)
			obj.data = rand(2,10);
		end
	end
end