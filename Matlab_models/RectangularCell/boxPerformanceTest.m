runs = 10;

dx = [0.2,0.5,1,1.5,2,3];
dy = [0.2,0.5,1,1.5,2,3];

simTime = [1000, 2000, 5000, 10000, 20000];
runTime = nan(1,runs);
for k = 1:length(simTime)
    fprintf('Starting %5dhr simulations\n',simTime(k));
    for i = 1:length(dx)
        fprintf('Starting simulations with dx =  %1.1f and dy = %1.1f\n',dx(i), dy(i));
        for n = 1:runs
            tic;
            t = CellGrowing(20,20,10,10,10,1,10,dx(i), dy(i));
            t.NTimeSteps(simTime(k));
            runTime(n) = toc;
            fprintf('Trial %2d took %7.1fs\n', n, runTime(n));
        end

        fprintf('Case time = %5dhr, dx =  %1.1f, dy = %1.1f: Average time = %7.1f\n', simTime(k), dx(i), dy(i), nanmean(runTime));
        storeMean(k,i) = nanmean(runTime);
    end
end

runs = 5;

dx = [0.2,0.5,1,1.5,2,3];
dy = [0.2,0.5,1,1.5,2,3];

simTime = [1000, 1000, 3000, 5000, 10000];

for i = 1:length(dx)
    fprintf('Starting simulations with dx = %1.1f and dy = %1.1f\n',dx(i), dy(i));
    for n = 1:runs
        tic;
        t = CellGrowing(20,20,10,10,10,1,10,dx(i), dy(i));
        for k = 1:length(simTime)
            t.NTimeSteps(simTime(k));
            runTime(n,k,i) = toc;
            fprintf('Trial %2d, %5dhr took %7.1fs\n', n,sum(simTime(1:k)), runTime(n,k,i));
        end
    end
end