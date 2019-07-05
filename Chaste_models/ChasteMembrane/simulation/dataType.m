classdef (Abstract) dataType
	% This is an abstract class that defines the functions required for
	% saving and loading specific data types
	% An example of a dataType is behavioural properties, cell positions
	% these are processed and stored as raw data to be analysed in an
	% 'analysis' class

	properties (Abstract)
		name
	end

	methods (Abstract, Access = protected)
		% These methods must be implemented in sublclasses, but cannot be used
		% externally

		% An internal method that attempts to retreive the data from file
		% If this method method will only run if the file exists,
		% but it may fail if the file format doesn't match what is expected

		data = retrieveData
		processOutput
	end

	methods
		function data = loadData(obj, sp)
			% This is the way that data is loaded
			% It enforces an existance check, then loads the data
			% as required for the data type in the concrete class

			% This method can throw an error, handling must be done externally by simpoint
			% It is designed, however, to make sure the user doesn't need to handle errors
			% in their implementation of the abstract methods

			if ~(exist(sp.dataFile, 'file') == 2)
				error('File does not exist')
			end

			try
				data = obj.retrieveData(sp);
			catch
				error('Data was not found in the expected format');
			end
		end

		function status = saveData(obj, sp)
			% This saves data in the required format
			% 

		end
	end


end