for q = 1:4
[m,n] = size(t.boxes.elementsQ{q});
for i = 1:m
for j = 1:n
for k = 1:length(t.boxes.elementsQ{q}{i,j})
if ismember(t.boxes.elementsQ{q}{i,j}(k).id, [74,76,7,75])
fprintf('Element %d is in (%d,%d,%d)\n',t.boxes.elementsQ{q}{i,j}(k).id,q,i,j);
end
end
end
end
end