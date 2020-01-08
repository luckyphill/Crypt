
% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
% temp_wt is a work around to make sure cct-1 > wt > 1

% THIS IS NOW PREPARED FOR THE LATIN HYPER CUBE SAMPLE OF POINTS

objectiveFunction = @MouseColonDesc;
lb = [232, 96, 20, 20, 99, 20, 500];
ub = [348, 144, 500, 500, 199, 80, 1000];
N = 16;

[x,fval,exitflag,output] = surrogateSearchSingleSeed(objectiveFunction, lb, ub, 1)
x
fval