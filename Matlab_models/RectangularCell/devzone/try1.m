

t = 0;



dt = 0.01;

tEnd = 1000*dt;

eta = 1;

tissue = CellPopulation(11);
tissue.cellList(5).elementTop.SetEdgeAdhesionParameter(0.2);
tissue.cellList(5).elementBottom.SetEdgeAdhesionParameter(0.5);
tissue.cellList(6).elementTop.SetEdgeAdhesionParameter(0.2);
tissue.cellList(6).elementBottom.SetEdgeAdhesionParameter(0.5);
tissue.cellList(7).elementTop.SetEdgeAdhesionParameter(0.2);
tissue.cellList(7).elementBottom.SetEdgeAdhesionParameter(0.5);

while t < tEnd

	tissue.NextTimeStep();

	t = t + dt;
	

end

tissue.VisualiseCellPopulation();


