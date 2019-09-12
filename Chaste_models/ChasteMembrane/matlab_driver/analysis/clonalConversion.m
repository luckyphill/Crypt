classdef clonalConversion < matlab.mixin.SetGet

	% A class to handle plotting the data output

	properties
		outputTypes
		simParams
		mutantParams
		solverParams
		seedParams

		chastePath = [getenv('HOME'), '/'];
		chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/'];
		s % This simulation

	end


	methods
		
		function obj = clonalConversion(simParams, mutantParams, solverParams, seedParams, outputTypes)


			obj.simParams = simParams;
			obj.mutantParams = mutantParams;
			obj.solverParams = solverParams;
			obj.seedParams = seedParams;

			obj.outputTypes = outputTypes;

			obj.s = simulateCryptColumnSingleMutation(obj.simParams, obj.mutantParams, obj.solverParams, obj.seedParams, obj.outputTypes);

		end


		function runConversion(obj)

			
			obj.s.generateSimulationData();


		end

	end


end
