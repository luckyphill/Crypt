function obj = MouseColonDesc(data)

    % Objective function for the Mouse Descending Colon
    % Values taken from Tsubouchi 1981
    % Crypt height: 32.9 cells
    % Max division height: 21 cells (from figure)
    % Values taken from Sunter et al 1979
    % Birth rate: 0.93 cells/column/hour
    % Cycle time: 15 hours (average from position groups)
    % G1 time: 7 hours

	% This order must match the order in the corresponding test
	% in this case it is TestCryptColumn
	anoikis_rate = data(1);
	average_cell_count = data(2);
	birth_rate = data(3);
	max_division_position = data(4);
	
    obj =  penalty(100*anoikis_rate,0,4,1) + penalty(average_cell_count,31,35,1) + penalty(max_division_position,19,21,1) + penalty(100*birth_rate,91,95,1);


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
