classdef clonalData < dataType
	% This grabs the behaviour data for a healthy crypt simulation

	properties (Constant = true)
		name = 'clonal_data';

		fileNames = 'conversion'
	end

	methods

		function obj = clonalData()
			% Constructor needs to be given the parameters that the particular chasteTest
			% needs in order to generate the expected output format
			obj.typeParams = containers.Map({'Sml', 'Scc'}, {1,1});
		end

		function correct = verifyData(obj, data, sp)
			% All the check we're interested in to make sure the data is correct
			% Perhaps, check that there are sufficient time steps taken?

			if length(data) == 1
				correct = true;
			else
				correct = false;
			end

		end

		function found = exists(obj, sp)
			% Checks if the file exists
			found = exist(obj.getFullFileName(sp), 'file');

		end

		function file = getFullFileName(obj,sp)

			file = [obj.getFullFilePath(sp), obj.fileNames, '_', num2str(sp.run_number), '.txt'];
		end


		function folder = getFullFilePath(obj,sp)
			folder = [sp.saveLocation, obj.name];


			folder = [folder, '/numerics'];

			k = sp.solverParams.keys;
			v = sp.solverParams.values;
			for i = 1:sp.solverParams.Count
				folder = [folder, sprintf('_%s_%g',k{i}, v{i})];
			end
			
			folder = [folder, '/mutant'];
			
			k = sp.mutantParams.keys;
			v = sp.mutantParams.values;
			for i = 1:sp.mutantParams.Count
				if ~strcmp(k{i},'name')
					folder = [folder, sprintf('_%s_%g',k{i}, v{i})];
				end
			end

			folder = [folder, '/'];

			if exist(folder,'dir')~=7
				mkdir(folder);
			end

		end		

	end

	methods (Access = protected)

		function data = retrieveData(obj, sp)
			% Loads the data from the file and puts it in the expected format

			data = csvread(obj.getFullFileName(sp));

		end

		function processOutput(obj, sp)
			% Implements the abstract method to process the output
			% and put it in the expected location, in the expected format

			cmdout = sp.cmdout;

			try
				temp1 = strsplit(cmdout, 'START');
				temp1 = strsplit(temp1{2}, 'END');
				temp2 = strsplit(temp1{1}, 'DEBUG: ');
			catch
				error('bD:MissingBracketingFlags','Couldnt find START, END or DEBUG. Ensure the Chaste test console output is formatted correctly.');
			end

			out = temp2{2}(1:end-1);

			data = nan;

			if strcmp(out, 'Monolayer clear') || strcmp(out, 'Crypt clear')
				data = 0;
			end

			if strcmp(out, 'Clonal conversion')
				data = 1;
			end

			if strcmp(out, 'Timeout')
				data = -1;
			end
			

			if ~strcmp(out, 'Monolayer clear') && ~strcmp(out, 'Clonal conversion') && ~strcmp(out, 'Crypt clear') &&~strcmp(out, 'Timeout')
				error('bD:MissingData','Console output format doesnt match expected format.');
			end

			try
				csvwrite(obj.getFullFileName(sp), data);
			catch
				error('bD:WriteError','Error writing to file');
			end

		end

	end

end