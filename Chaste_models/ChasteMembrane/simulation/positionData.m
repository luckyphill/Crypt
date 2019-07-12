classdef positionData < dataType
	% This is an abstract class that defines the functions required for
	% saving and loading specific data types
	% An example of a dataType is behavioural properties, cell positions
	% these are processed and stored as raw data to be analysed in an
	% 'analysis' class

	properties (Constant = true)
		name = 'position_data';
	end

	methods

		function obj = positionData(typeParams)
			% Constructor needs to be given the parameters that the particular chasteTest
			% needs in order to generate the expected output format
			obj.typeParams = typeParams;
		end

		function correct = verifyData(obj, data, sp)
			% All the check we're interested in to make sure the data is correct
			% Perhaps, check that there are sufficient time steps taken?

			finalTimeStep = data(end,1);

			t = sp.solverParams('t');
			bt = sp.solverParams('bt');

			if finalTimeStep >= t + bt
				correct = true;
			else
				correct = false;
			end
		end
	end

	methods (Access = protected)
		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			data = csvread(sp.dataFile);

		end

		function processOutput(obj, sp)
			% Implements the abstract method to process the output
			% and put it in the expected location, in the expected format

			outputFile = [sp.simOutputLocation, 'cell_positions.dat'];

			[status,cmdout] = system(['mv ', outputFile, ' ',  sp.dataFile],'-echo');

			if status
				error('pD:MoveError', 'Move failed')
			end

		end

	end

end