function number = getCryptNumber(crypt)
	% Accepts a string or function handle, and returns
	% the designated number for the crypt
	
	if isa(crypt,'function_handle')
		crypt = func2str(crypt);
	end

    switch crypt
        case 'MouseColonDesc'
            number = 1;
        case 'MouseColonAsc'
            number = 2;
        case 'MouseColonTrans'
            number = 3;
        case 'MouseColonCaecum'
            number = 4;
        case 'RatColonDesc'
            number = 5;
        case 'RatColonAsc'
            number = 6;
        case 'RatColonTrans'
            number = 7;
        case 'RatColonCaecum'
            number = 8;
        case 'HumanColon'
            number = 9;
        otherwise
            error('Parameter type not found');
    end

end