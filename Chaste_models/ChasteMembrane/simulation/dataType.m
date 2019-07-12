classdef (Abstract) dataType
	% This is an abstract class that defines the functions required for
	% saving and loading specific data types
	% An example of a dataType is behavioural properties, cell positions
	% these are processed and stored as raw data to be analysed in an
	% 'analysis' class

	properties (Abstract, Constant = true)
		% The name for the datatype, this must be implemented within a concrete class
		% For the sake of convention, this should be the same as the m file name
		name
	end

	properties
		% This is an optional property in case there is a specific flag needed to
		% trigger the specific data type in the chaste test
		typeParams containers.Map

	end

	methods (Abstract, Access = protected)
		% These methods must be implemented in sublclasses, but cannot be used
		% externally

		% These methods deal with the specific details of the data format
		% how it is extracted from the raw simulation data, and how it is
		% saved in the specified format
		data = retrieveData
		processOutput

	end

	methods
		% These methods are how the user, or the simulation point interacts with the data
		% They have error catching built in to catch and handle common file reading errors

		function data = loadData(obj, sp)
			% This is the way that data is loaded
			% It enforces an existance check, then loads the data
			% as required for the data type in the concrete class

			% This method can throw an error, handling must be done externally by simulation
			% It is designed, however, to make sure the user doesn't need to handle errors
			% in their implementation of the abstract methods

			if ~(exist(sp.dataFile, 'file') == 2)
				error('dt:FileDNE', 'File does not exist.')
			end

			try
				data = obj.retrieveData(sp);
			catch
				error('dt:RetreivalFail','Data retreival failed. Check file can be read.');
			end

			if ~obj.verifyData(data, sp)
				error('dt:VerificationFail','Data verification failed. Check that the data meets the requirements in %s.verifyData.', obj.name);
			end

		end

		function status = saveData(obj, sp)
			% This saves data in the required format by using the user created
			% implementation of processOutput
			% It expeccts the user to not implement any error handling

			try
				obj.processOutput(sp);
			catch err
				fprintf('%s\n',err.message);
				error('dt:ProcessingFail','Issue processing data. Check the processOutput method in %s', obj.name)
			end

			status = 1;

		end

		% This method can be overwritten, but it can be ignored
		function correct = verifyData(obj, data, sp)
			% An extra method that checks the data is the correct format
			% Useful if the data retrieval method can succeed even though
			% the format is incorrect.

			% It can be overwritten in subclasses, but it is not necessary,
			% hence the base class always returns true
			correct = true;

		end
	end


end