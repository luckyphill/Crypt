function name = getMutationName(mutation)

	if isnumeric(mutation)
		mutation = getMutationFlag(mutation);
	end

	switch mutation
		case 'nM'
			name = 'Height';
		case 'npM'
			name = 'Compartment';
		case 'eesM'
			name = 'Stiffness';
		case 'msM'
			name = 'Adhesion';
		case 'cctM'
			name = 'Cycle';
		case 'wtM'
			name = 'Growth';
		case 'vfM'
			name = 'Inhibition';
		otherwise
			error('Parameter type not found');
	end
end