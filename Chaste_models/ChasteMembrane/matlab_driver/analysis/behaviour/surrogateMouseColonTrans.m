
% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
% temp_wt is a work around to make sure cct-1 > wt > 1

objectiveFunction = @MouseColonTrans;
lb = [34, 9, 20, 20, 160, 11, 500];
ub = [40, 15, 500, 500, 260, 89, 1000];
N = 16;

[x,fval,exitflag,output] = surrogateSearch(objectiveFunction, lb, ub, N);
x
fval