classdef visPositionData < dataType
	% This handles only the position data from the visualiser.
	% This hence should only be used when redaing data, not generating data

	properties (Constant = true)
		name = 'visualiser_data';

		fileNames = 'results.viznodes';
	end

	methods

		function obj = visPositionData(typeParams)
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

		function file = getFullFileName(obj,sp)
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

			outputFile = [sp.simOutputLocation, 'results.viznodes'];
			[status,cmdout] = system(['mv ', outputFile, ' ', obj.getFullFileName(sp)],'-echo');

			if status
				error('vPD:MoveError', 'Move failed')
			end

		end

	end

end