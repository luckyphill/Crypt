classdef positionData < dataType
	% This is an abstract class that defines the functions required for
	% saving and loading specific data types
	% An example of a dataType is behavioural properties, cell positions
	% these are processed and stored as raw data to be analysed in an
	% 'analysis' class

	properties
		name = 'position_data';
	end

	methods
		function processOutput(pd, sp)
			% Implements the abstract method to process the simpoint output
			% and put it in the expected location, in the expeccted format

			outputFile = [sp.simOutputLocation, 'cell_positions.dat'];

			[status,cmdout] = system(['mv ', outputFile,  sp.dataFile],'-echo');

		end

	end

	methods (Access = protected)
		function data = retrieveData(pd, sp)
			% Loads the data from the file and puts it in the expected format

			data = csvread(sp.dataFile);

		end

	end


end