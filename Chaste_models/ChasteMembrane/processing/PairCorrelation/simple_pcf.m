function [altogether, edges1] = simple_pcf(data, dr, rmax)
    data = data(1:find(data,1,'last'));
    edges = 0:dr:rmax;
    edges1 = edges(2:end);
    altogether = zeros(size(edges1));
    for i = 1:length(data)
        temp = abs(data - data(i));
        ddd = min(data(i), rmax - data(i)); % double density distance - the max radius where both sides have present cells. Longer than this and only left or side of the cell is inside the crypt
        A = ones(size(edges1));
        A(edges1 < ddd) = A(edges1 < ddd) + 1;
        counts = hist(temp,length(edges1));
        
        altogether = altogether + counts./A;

    end
end