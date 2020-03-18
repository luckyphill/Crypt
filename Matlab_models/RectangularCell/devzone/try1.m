

t = 0;



dt = 0.005;

tEnd = 1000*dt;

eta = 1;

tissue = CellPopulation(11);

tissue.cellList(6).elementTop.naturalLength = 0.7;
tissue.cellList(6).elementBottom.naturalLength = 1.3;

while t < tEnd
	for i = 1:length(tissue.elementList)
		tissue.elementList(i).UpdateForce();
	end
	for i = 1:length(tissue.cellList)
		tissue.cellList(i).UpdateForce();
	end

	for i = 1:length(tissue.nodeList)
		tissue.nodeList(i).UpdatePosition(dt/eta);
	end

	t = t + dt;

end


