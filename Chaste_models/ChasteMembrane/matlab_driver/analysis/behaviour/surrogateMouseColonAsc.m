
% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
% temp_wt is a work around to make sure cct-1 > wt > 1

objectiveFunction = @MouseColonAsc;
lb = [16, 5, 20, 20, 140, 11, 500];
ub = [22, 13, 500, 500, 240, 89, 1000];
N = 16;

[x,fval,exitflag,output] = surrogateSearch(objectiveFunction, lb, ub, N);
x
fval