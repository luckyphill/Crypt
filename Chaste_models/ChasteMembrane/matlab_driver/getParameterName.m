function name = getParameterName(parameter)

	switch parameter
		case 'n'
			name = 'Height';
		case 'np'
			name = 'Compartment';
		case 'ees'
			name = 'Stiffness';
		case 'ms'
			name = 'Adhesion';
		case 'cct'
			name = 'Cycle';
		case 'wt'
			name = 'Growth';
		case 'vf'
			name = 'Inhibition';
		otherwise
			error('Parameter type not found');
	end
end