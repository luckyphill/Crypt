function [altogether, edges1] = simple_pcf(data, dr, rmax)

    data = data(1:find(data,1,'last'));
   
    edges = 0:dr:rmax;
    edges1 = edges(2:end);
    altogether = zeros(size(edges1));
    raw_distances = [];
    for i = 1:length(data)
        temp = abs(data - data(i));
        ddd = min(data(i), rmax - data(i)); % double density distance - the max radius where both sides have present cells. Longer than this and only left or side of the cell is inside the crypt
        sdd = max(data(i), rmax - data(i));
        A = zeros(size(edges1));
        A(edges1 < sdd) = A(edges1 < sdd) + 1;
        A(edges1 < ddd) = A(edges1 < ddd) + 1;
        counts = histcounts(temp,edges);
        
        % Account for edge effects
        l_first = rem(data(i), dr)/dr;
        l_last = max(rem(rmax - data(i), dr)/dr, 0.8); % If the value is too small it causes some results to explode and dominate the counts
        if find(A>1,1,'last') < length(A)
            A(find(A>1,1,'last')+1) = 1 + l_first;
        end
        if find(A,1,'last') < length(A)
            A(find(A,1,'last')+1) = l_last;
        end
        
        weighted_counts = counts./A;
        weighted_counts(isnan(weighted_counts)) = 0;
        
        altogether = altogether + weighted_counts;
        raw_distances = [raw_distances, temp];

    end
    altogether = altogether / max(altogether);
end