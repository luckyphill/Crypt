function flag = getMutationFlag(mutation)
	
	switch mutation
		case 1
			flag = 'nM';
		case 2
			flag = 'npM';
		case 3
			flag = 'eesM';
		case 4
			flag = 'msM';
		case 5
			flag = 'cctM';
		case 6
			flag = 'wtM';
		case 7
			flag = 'vfM';
		otherwise
			error('Parameter type not found, check that input is between 1 and 7');
	end

end