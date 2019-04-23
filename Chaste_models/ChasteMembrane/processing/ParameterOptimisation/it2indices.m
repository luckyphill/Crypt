function indices = it2indices(i, counts)
    
    % This function takes a base 10 number 
    % and converts it to a non uniform base
    % using the conversion rates specified in counts
    
    % This is essentially the same process as converting
    % say, 100,000s in to days, hours, minutes and seconds, or
    % 200p into pounds, schillings pence
    % counts is the conversion rate for each level
    % i.e. if we are talking time conversion then
    % counts = (86400, 3600, 60, 1)

    indices = nan(size(counts));
    n = length(counts);
        
    for j = 1:n
       indices(j) = idivide(uint16(i), uint16(counts(j)),'ceil');
       i = i - counts(j) * (indices(j)-1);  % -1 necessary because matlab indexes from 1 -\(o-o)/-
    end
    
end