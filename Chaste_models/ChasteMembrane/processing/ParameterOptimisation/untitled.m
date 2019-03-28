prange = {[1,2,3],[4,5,6],[10,11,12],[20,21,22,23]};

n = length(prange);

n_sets = uint8(1);
counts = nan(1,n);

for i = n:-1:1
    counts(i) = n_sets;
    n_sets = n_sets * uint8(length(prange{i}));
end
params = nan(n_sets,n);

for i = 1:n_sets
   
    params(i,:) = it2indices(i, n, counts);
    
end
    
function indices = it2indices(i, n, counts)
    
    % This function takes a base 10 number 
    % and converts it to a non uniform base
    % using the number of divisions specified in lenghts
    
    % This is essentially the same process as converting
    % say, 1.5 days in to hours minutes and seconds, or
    % 1.2 km into yards feet and inches
    
    % We will assume that i is always less than
    % prod(lengths)
    
    indices = nan(1,n);
        
    for j = 1:n
       indices(j) = idivide(i, counts(j),'ceil');
       i = i - counts(j) * (indices(j)-1);
    end
    
%     indices(end) = i;
    
end
