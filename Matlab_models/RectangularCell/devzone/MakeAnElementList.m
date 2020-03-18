

for i = 1:10
	nodeList(i) = Node(i,0,i);
end

for i = 1:length(nodeList)-1
	elementList(i) = Element(nodeList(i), nodeList(i+1), i);
end