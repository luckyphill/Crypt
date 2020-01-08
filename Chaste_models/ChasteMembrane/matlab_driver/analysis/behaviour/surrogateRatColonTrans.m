
% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
% temp_wt is a work around to make sure cct-1 > wt > 1

objectiveFunction = @RatColonTrans;
lb = [330, 170, 20, 20, 370, 11, 500];
ub = [390, 230, 500, 500, 470, 89, 1000];
N = 16;

[x,fval,exitflag,output] = surrogateSearchSingleSeed(objectiveFunction, lb, ub, 1)
x
fval