classdef setBehaviour < matlab.mixin.SetGet

	% A class that runs a behaviour object function, but with set solver and seed params

	properties
		objectiveFunction
		b

	end

	methods

		function obj = setBehaviour(objectiveFunction,n,np,ees,ms,cct,wt,vf,varargin)

			outputType = behaviourData();

			simParams = containers.Map({'n', 'np', 'ees', 'ms', 'cct', 'wt', 'vf'}, {n, np, ees, ms, cct, wt, vf});
			solverParams = containers.Map({'t', 'bt', 'dt'}, {1000, 10, 0.0005});
			seedParams = containers.Map({'run'}, {1});

			obj.objectiveFunction = objectiveFunction;

			if length(varargin) > 0
				obj.b = behaviourObjective(objectiveFunction,n,np,ees,ms,cct,wt,vf,1000,0.0005,100,1,varargin);
			else
				obj.b = behaviourObjective(objectiveFunction,n,np,ees,ms,cct,wt,vf,1000,0.0005,100,1);
			end

		end

	end

end