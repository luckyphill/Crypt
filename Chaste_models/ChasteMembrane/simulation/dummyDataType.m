classdef dummyDataType < dataType
	% This is an abstract class that defines the functions required for
	% saving and loading specific data types
	% An example of a dataType is behavioural properties, cell positions
	% these are processed and stored as raw data to be analysed in an
	% 'analysis' class

	properties (Constant = true)
		name = 'dummy';
	end


	methods (Access = protected)
		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			data = csvread(sp.dataFile);

		end

		function processOutput(obj, sp)
			% Implements the abstract method to process the simpoint output
			% and put it in the expected location, in the expected format

			
			csvwrite(sp.saveFile, sp.data);

		end

	end
	methods

		function correct = verifyData(obj, data)
			
			if length(data) > 2
				correct = false;
			else
				correct = true;
			end
		end



	end


end