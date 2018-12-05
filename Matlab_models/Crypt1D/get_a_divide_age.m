function divide_age = get_a_divide_age(varargin)
    % returns a random age to divide at
    % samples from U(10,14)
    
    if length(varargin)
        n = varargin{1};
        divide_age = 10 + 4 * rand(1,n);
    else
        divide_age = 10 + 4 * rand;
    end


end