classdef BottomWiggleData < dataType
	% This grabs the behaviour data for a healthy crypt simulation

	properties (Constant = true)
		name = 'bottomWiggleData';

		fileNames = 'bottomwiggleratio'
	end

	methods

		function found = exists(obj, sp)
			% Checks if the file exists
			found = exist(obj.getFullFileName(sp), 'file');

		end

		function correct = verifyData(obj, data, sp)
			
			% To be valid, the data must either run for the specified
			% time limit, or stop due to buckling

			% NOTE: The length of the data is dependent on the max run time, the step size
			% and the sampling multiple. The following calculation should work it out


			l = (sp.simObj.timeLimit/sp.simObj.dt) / sp.simObj.samplingMultiple;

			correct = false;

			if l * 0.8 > length(data) || data(end) > sp.buckledWiggleRatio * 0.8
				correct = true;
			end

		end
	end

	methods (Access = protected)

		function file = getFullFileName(obj,sp)
			
			% folder = [sp.saveLocation, sprintf('n%dp%dg%dw%db%d_seed%d/',sp.n,sp.p,sp.g,sp.w,sp.b,sp.rngSeed)];
			% Should be as below, but stuffed up and used %d instead of %g in BeamMembranePinned
			folder = sp.saveLocation;

			if exist(folder,'dir')~=7
				mkdir(folder);
			end

			file = [folder, obj.fileNames, '.csv'];
		end

		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			data = readmatrix(obj.getFullFileName(sp));

		end

		function processOutput(obj, sp)
			% Implements the abstract method to process the output
			% and put it in the expected location, in the expected format

			% Do nothing, simulation already puts it in the right spot

		end

	end

end