
nCells = 11;
p = 10;
g = 10;
areaEnergy = 10;
perimeterEnergy = 1;
adhesionEnergy = 1; 


minLen = 1000000;
for i = 1:10
	tissue(i) = CellGrowing(nCells, p, g, areaEnergy, perimeterEnergy, adhesionEnergy, i);
	tissue(i).NTimeSteps(9000);
	if length(tissue(i).storeTopWiggleRatio) < minLen
		minLen = length(tissue(i).storeTopWiggleRatio);
	end
end


allWiggle = [];
allDeviation = [];
allNumCells = [];

for i = 1:10
	allWiggle(end + 1, :) = tissue(i).storeTopWiggleRatio(1:minLen);
	allDeviation(end + 1, :) = tissue(i).storeAvgYDeviation(1:minLen);
	allNumCells(end + 1, :) = tissue(i).storeNumCells(1:minLen);
end

figure()
plot(mean(allWiggle))
figure()
plot(mean(allDeviation))
figure()
plot(mean(allNumCells))

