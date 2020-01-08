
% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
% temp_wt is a work around to make sure cct-1 > wt > 1

objectiveFunction = @RatColonDesc;
lb = [390, 250, 20, 20, 520, 5, 500];
ub = [450, 310, 500, 500, 620, 50, 1000];
N = 16;

[x,fval,exitflag,output] = surrogateSearchSingleSeed(objectiveFunction, lb, ub, 1)
x
fval