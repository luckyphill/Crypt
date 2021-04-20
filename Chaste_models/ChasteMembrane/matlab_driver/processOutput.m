function data = processOutput(cmdout)
	% Implements the abstract method to process the output
	% and put it in the expected location, in the expected format

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

end