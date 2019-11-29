function [x,fval,exitflag,output] = surrogateSearch(objectiveFunction, lb, ub)
	% sets up the surrogate funciton optimisation approach
	% lb and ub specifies the upper and lower bounds of the parameters
	% parameters are given in the order:
	% n, np, ees, ms, cct, wt, vf

	N = 4;

	fun = @(params)parObjectiveFunction(params, objectiveFunction, N);

	intcon = [1,2,3,4,5]; % The parameters that must be integers
	% options = optimoptions('surrogateopt','CheckpointFile','test.mat');

	% problem.objective = fun;
	% problem.lb = lb;
	% problem.ub = ub;
	% problem.solver = 'surrogateopt';
	% problem.options = options;
	% problem.intcon = intcon;
	% [x,fval,exitflag,output] = surrogateopt(fun,lb,ub,intcon,options);
	% % [x,fval,exitflag,output] = surrogateopt(problem);

	A = [];
	b = [];
	Aeq = [];
	beq = [];
	nonlcon = [];

	[x,fval] = ga(fun,7,A,b,Aeq,beq,lb,ub,nonlcon,intcon);


end