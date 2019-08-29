classdef popUpData < dataType
	% This is an abstract class that defines the functions required for
	% saving and loading specific data types
	% An example of a dataType is behavioural properties, cell positions
	% these are processed and stored as raw data to be analysed in an
	% 'analysis' class

	properties (Constant = true)
		name = 'popup_data';

		fileNames = 'popup_location.txt';
	end

	methods

		function obj = popUpData()
			% Constructor needs to be given the parameters that the particular chasteTest
			% needs in order to generate the expected output format
			obj.typeParams = containers.Map({'Pul'},{1});
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

		function found = exists(obj, sp)
			% Checks if the file exists
			found = exist(obj.getFullFileName(sp), 'file');

		end

	end

	methods (Access = protected)

		function file = getFullFileName(obj,sp)
			% This should be num2str(sp.run_number), but it wasn't when the simulations ran 23-26 Aug
			% somehow this didn't cause an error, it just made a file name like run_\#001/
			% The numeral 'character' must be interpreted as some ASCII code. I don't know how to programmatically
			% access these folders, so I can't move the files right now, so I hope they can be accessed
			% Otherwise I'll have to run the simulations again...
			folder = [sp.saveLocation, 'run_', sp.run_number, '/'];

			if exist(folder,'dir')~=7
				mkdir(folder);
			end

			file = [folder, obj.fileNames];
		end

		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			data = csvread(obj.getFullFileName(sp));

		end

		function processOutput(obj, sp)
			% Implements the abstract method to process the output
			% and put it in the expected location, in the expected format

			outputFile = [sp.simOutputLocation, 'popup_location.txt'];

			[status,cmdout] = system(['mv ', outputFile, ' ',  obj.getFullFileName(sp)],'-echo');

			if status
				error('puD:MoveError', 'Move failed')
			end

		end

	end

end