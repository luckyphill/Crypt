

t = 0;



dt = 0.01;

tEnd = 300*dt;

eta = 1;

tissue = CellPopulation(11);

tissue.cellList(4).elementTop.naturalLength = 0.7;
tissue.cellList(4).elementBottom.naturalLength = 1.3;
tissue.cellList(4).elementLeft.naturalLength = 1.044;
tissue.cellList(4).elementRight.naturalLength = 1.044;

tissue.cellList(5).elementTop.naturalLength = 0.7;
tissue.cellList(5).elementBottom.naturalLength = 1.3;
tissue.cellList(5).elementLeft.naturalLength = 1.044;
tissue.cellList(5).elementRight.naturalLength = 1.044;

tissue.cellList(6).elementTop.naturalLength = 0.5;
tissue.cellList(6).elementBottom.naturalLength = 1.5;
tissue.cellList(6).elementLeft.naturalLength = 1.044;
tissue.cellList(6).elementRight.naturalLength = 1.044;

tissue.cellList(7).elementTop.naturalLength = 0.7;
tissue.cellList(7).elementBottom.naturalLength = 1.3;
tissue.cellList(7).elementLeft.naturalLength = 1.044;
tissue.cellList(7).elementRight.naturalLength = 1.044;

tissue.cellList(8).elementTop.naturalLength = 0.8;
tissue.cellList(8).elementBottom.naturalLength = 1.3;
tissue.cellList(8).elementLeft.naturalLength = 1.044;
tissue.cellList(8).elementRight.naturalLength = 1.044;

while t < tEnd

	tissue.NextTimeStep();

	t = t + dt;

end


