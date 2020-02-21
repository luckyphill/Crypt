function number = getParameterNumber(parameter)

	switch parameter
		case 'n'
			number = 1;
		case 'np'
			number = 2;
		case 'ees'
			number = 3;
		case 'ms'
			number = 4;
		case 'cct'
			number = 5;
		case 'wt'
			number = 6;
		case 'vf'
			number = 7;
		otherwise
			error('Parameter type not found');
	end

end