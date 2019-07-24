classdef dummyDataType < dataType
	% A dummy dataType that has the bare minimum functionality for testing purposes

	properties (Constant = true)
		name = 'dummy';

		fileNames = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummy.txt'];
	end


	methods (Access = protected)
		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			data = csvread(obj.fileNames);

		end

		function processOutput(obj, sp)
			% Implements the abstract method to process the simulation output
			% and put it in the expected location, in the expected format
			csvwrite(sp.saveFile, sp.data);

		end

	end
	methods

		function correct = verifyData(obj, data, sp)
			
			if length(data) > 2
				correct = false;
			else
				correct = true;
			end
		end

		function found = exists(obj, sp)
			% Checks if the file exists
			result = exist(obj.fileNames, 'file');
			found = false;
			if result ~= 0
				found = true;
			end
		end



	end


end