function obj = MouseColonAsc(data)

	% Objective function for the Mouse Ascending Colon
	% Values taken from Sunter et al 1979
	% Crypt height: 19.3 cells
	% Max division height: 15 cells (from figure)
	% Birth rate: 0.36 cells/column/hour
	% Cycle time: 19 hours (average from position groups)
	% G1 time: 9 hours
	
	% This order must match the order in the corresponding test
	% in this case it is TestCryptColumn
	anoikis_rate = data(1);
	average_cell_count = data(2);
	birth_rate = data(3);
	max_division_position = data(4);

	% Anoikis rate should make up about 4% of deaths

	% MINIMUM ANOIKIS HAS BEEN ADJUSTED UP TO 1. PREVIOUS WORK HAD MINIMUM OF ZERO
	
	obj =  penalty(100*anoikis_rate,0,4,1) + penalty(average_cell_count,18,21,1) + penalty(max_division_position,13,15,1) + penalty(100*birth_rate,34,38,1);


end

function pen = penalty(value, min, max, ramp)
	% If value is between min and max, penalty is 0
	% Otherwise it ramps up like a polynomial of order ramp

	pen = nan;
	
	if (value <= max && value >= min)
		pen = 0;
	end
	
	if value > max
		
		pen = abs(value - max) ^ ramp;
	end
	
	if value < min
		
		pen = abs(min - value) ^ ramp;
	end
	
	
end
