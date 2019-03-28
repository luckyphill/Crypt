function obj = MouseColonDesc(data)

	% This order must match the order in the corresponding test
	% in this case it is TestCryptNewPhaseModel
	slough = data(1);
	anoikis = data(2);
	dcells = data(3);
	wcells = data(4);
	pcells = data(5);
	max_division_position = data(6);
	
	total_end = dcells + pcells + wcells/2;

	
    obj =  penalty(anoikis,0,4,1) + penalty(total_end,31,35,1) + penalty(max_division_position,18,21,1) + penalty(anoikis + slough,85,95,1);


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
