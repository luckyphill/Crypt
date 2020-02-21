function flag = getParameterFlag(parameter)

	switch parameter
		case 1
			flag = 'n';
		case 2
			flag = 'np';
		case 3
			flag = 'ees';
		case 4
			flag = 'ms';
		case 5
			flag = 'cct';
		case 6
			flag = 'wt';
		case 7
			flag = 'vf';
		otherwise
			error('Parameter type not found, check that input is between 1 and 7');
	end

end