function obj = HumanColon(data)

    % Objective function for the Human Colon
    % Values taken from Potten, Kellet, Rew, Roberts 1992
    % Crypt height: 82.2 cells
    % Max division height: 65 cells (from figure)
    % Birth rate: NOT GIVEN guess of 0.75 cells/column/hour
    % Cycle time: 30 hours
    % Values taken from Potten, Kellet, Roberts, Rew, Wilson 1992
    % Birth rate:  1.1 cells/column/hour
    
    
	% This order must match the order in the corresponding test
	% in this case it is TestCryptColumn
	anoikis_rate = data(1);
	average_cell_count = data(2);
	birth_rate = data(3);
	max_division_position = data(4);

    % Anoikis rate should make up about 4% of cell production
	
    obj =  penalty(100*anoikis_rate,0,4,1) + penalty(average_cell_count,80,84,1) + penalty(max_division_position,62,66,1) + penalty(100*birth_rate,100,120,1);


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
