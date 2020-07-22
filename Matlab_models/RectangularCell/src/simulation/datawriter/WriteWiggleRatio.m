classdef WriteWiggleRatio < AbstractDataWriter
	% Stores the wiggle ratio

	properties

		% No special properties
		fileNames = {'wiggleratio'};

		subdirectoryStructure = ''
		
	end

	methods

		function obj = WriteWiggleRatio(sm, simName)

			obj.subdirectoryStructure = simName;
			obj.samplingMultiple = sm;
			obj.multipleFiles = false;
			obj.timeStampNeeded = false;
			obj.data = {};

		end

		function GatherData(obj, t)

			% The simulation t must have a simulation data object
			% collating the complete spatial state

			obj.data = {t.simData('wiggleRatio').GetData(t)};

		end
		
	end

end