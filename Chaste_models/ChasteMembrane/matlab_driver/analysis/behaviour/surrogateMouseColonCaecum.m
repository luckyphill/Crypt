
% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
% temp_wt is a work around to make sure cct-1 > wt > 1

objectiveFunction = @MouseColonCaecum;
lb = [210, 50, 20, 20, 100, 11, 500];
ub = [270, 130, 500, 500, 200, 89, 1000];
N = 16;

[x,fval,exitflag,output] = surrogateSearchSingleSeed(objectiveFunction, lb, ub, 1)
x
fval