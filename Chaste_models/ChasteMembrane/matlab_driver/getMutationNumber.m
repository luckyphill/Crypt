function number = getMutationNumber(mutation)

	switch mutation
		case 'nM'
			number = 1;
		case 'npM'
			number = 2;
		case 'eesM'
			number = 3;
		case 'msM'
			number = 4;
		case 'cctM'
			number = 5;
		case 'wtM'
			number = 6;
		case 'vfM'
			number = 7;
		otherwise
			error('Parameter type not found');
	end

end