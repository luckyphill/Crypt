function [avgTime, nStoppedFromCollision] = avgStopTime(nCells, p, g, areaEnergy, perimeterEnergy, adhesionEnergy, N)

	nStoppedFromCollision = 0;
	tStopped = [];
	edgeStopped = [];
	edgeFlipped = [];
	timeSteps = 0;

	for i = 1:N
		t = CellGrowing(nCells, p, g, areaEnergy, perimeterEnergy, adhesionEnergy, i);
		fprintf('Running trial %d with: N0 = %d, pause = %g, grow = %g, areaP = %g, periP = %g, adhP = %g\n', i ,nCells, p, g, areaEnergy, perimeterEnergy, adhesionEnergy);
		while ~t.collisionDetected && ~t.edgeFlipDetected && timeSteps < 200000
			t.NTimeSteps(10000);
			timeSteps = timeSteps + 10000;
		end
		if t.collisionDetected
			nStoppedFromCollision = nStoppedFromCollision + 1;
			tStopped(end+1) = t.t;
		end
		if t.edgeFlipDetected
			edgeFlipped(end+1) = i;
			edgeStopped(end+1) = t.t;

		end

	end

	avgTime = mean(tStopped);

end
