classdef WiggleData < dataType
	% This grabs the behaviour data for a healthy crypt simulation

	properties (Constant = true)
		name = 'wiggleData';

		fileNames = 'wiggleratio'
	end

	methods

		function found = exists(obj, sp)
			% Checks if the file exists
			found = exist(obj.getFullFileName(sp), 'file');

		end
	end

	methods (Access = protected)

		function file = getFullFileName(obj,sp)
			
			folder = [sp.saveLocation, sprintf('p%dg%dw%db%d_seed%d/',sp.p,sp.g,sp.w,sp.b,sp.rngSeed)];

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