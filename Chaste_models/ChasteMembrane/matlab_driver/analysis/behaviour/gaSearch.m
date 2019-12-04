function [x,fval,exitflag,output,population,scores] = gaSearch(objectiveFunction, lb, ub, N)
	% sets up the ga funciton optimisation approach
	% lb and ub specifies the upper and lower bounds of the parameters
	% parameters are given in the order:
	% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
	% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
	% temp_wt is a work around to make sure cct-1 > wt > 1

	fun = @(params)parObjectiveFunction(params, objectiveFunction, N);

	intcon = 1:7; % All parameters must be integers. Inside the parObjectiveFunction the true input parameters are calculated

	A = [];
	b = [];
	Aeq = [];
	beq = [];
	nonlcon = [];

	[x,fval,exitflag,output,population,scores] = ga(fun,7,A,b,Aeq,beq,lb,ub,nonlcon,intcon);


end