classdef clonalData < dataType
	% This grabs the behaviour data for a healthy crypt simulation

	properties (Constant = true)
		name = 'clonal_data';

		fileNames = 'conversion'
	end

	methods

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
			folder = [sp.saveLocation, obj.name, '/'];

			if exist(folder,'dir')~=7
				mkdir(folder);
			end

			file = [folder, obj.fileNames, '_', num2str(sp.run_number), '.txt'];
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


			data = [];
			for i = 2:length(temp2)-1
				temp3 = strsplit(temp2{i}, ' = ');
				try
					data = [data; str2num(temp3{2})];
				catch
					error('bD:MissingData','Console output format doesnt match expected format.');
				end
			end

			try
				csvwrite(obj.getFullFileName(sp), data);
			catch
				error('bD:WriteError','Error writing to file');
			end

		end

	end

end