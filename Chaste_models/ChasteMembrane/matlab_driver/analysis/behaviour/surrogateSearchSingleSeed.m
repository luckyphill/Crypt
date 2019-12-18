function [x,fval,exitflag,output] = surrogateSearchSingleSeed(objectiveFunction, lb, ub, j)
	% sets up the surrogate funciton optimisation approach
	% lb and ub specifies the upper and lower bounds of the parameters
	% parameters are given in the order:
	% n, np, ees, ms, 10*cct, 100*temp_wt, 1000*vf
	% Multipliction by 10^a indicates the parameter is tuned only to a decimal places
	% temp_wt is a work around to make sure cct-1 > wt > 1


	fun = @(params)objectiveFunctionSingleSeed(params, objectiveFunction, j);

	intcon = [1,2,3,4,5,6,7]; % The parameters that must be integers
	options = optimoptions('surrogateopt','InitialPoints', assembleInitialPointsSingleSeed(objectiveFunction, j));

	problem.objective = fun;
	problem.lb = lb;
	problem.ub = ub;
	problem.solver = 'surrogateopt';
	problem.options = options;
	problem.intcon = intcon;

	% make the optimisation approach reproducible
	rng default;
	% [x,fval,exitflag,output] = surrogateopt(fun,lb,ub,intcon,options);
	[x,fval,exitflag,output] = surrogateopt(problem);


end