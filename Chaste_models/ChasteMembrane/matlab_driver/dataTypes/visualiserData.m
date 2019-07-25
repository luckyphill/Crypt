classdef visualiserData < dataType
	% This class moves the visualiser data to a fixed location

	properties (Constant = true)
		% The spot where the data is expected to be
		name = 'visualiser_data';

		fileNames = {'results.vizboundarynodes','results.vizcelltypes', 'results.viznodes', 'results.vizsetup'};
	end

	methods

		function obj = visualiserData(typeParams)
			% Constructor needs to be given the parameters that the particular chasteTest
			% needs in order to generate the expected output format
			obj.typeParams = typeParams;
		end

	end

	methods (Access = protected)

		function folder = getFullFilePath(obj,sp)
			folder = [sp.saveLocation, 'run_', num2str(sp.run_number), '/'];

			if exist(folder,'dir')~=7
				mkdir(folder);
			end

		end

		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			existCount = 0;

			for i = 1:length(obj.fileNames)
				outputFile = [sp.simOutputLocation, obj.fileNames{i}];
				saveFile = [getFullFilePath(sp), obj.fileNames{i}];

				% Check if the file exists, if it doesn't attempt to move it from outputlocation
				% if that fails, then the file doesn't exist in a known location
				if exist(saveFile)
					existCount = existCount + 1;
				else
					[status,cmdout] = system(['mv ', outputFile, ' ',  saveFile],'-echo');
					if exist(saveFile)
						existCount = existCount + 1;
					else
						fprintf('%s missing', obj.fileNames{i});
					end
				end
			end

			if existCount < 4
				error('vD:FileMissing', 'One of the visualiser files is missing');
			end

			data = 'All data exists, but not loaded. To load data use a specialised dataType, like visPositionData';

		end

		function processOutput(obj, sp)
			
			% Moves the files from the generic Chaste output directory, to the database


			for i = 1:length(obj.fileNames)
				outputFile = [sp.simOutputLocation, obj.fileNames{i}];
				saveFile = [getFullFilePath(sp), obj.fileNames{i}];

				[status,cmdout] = system(['mv ', outputFile, ' ',  saveFile],'-echo');

				if status
					error('vD:MoveError', 'Move failed: %s', obj.fileNames{i});
				end
			end

		end

	end

end