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

	end


	methods
		
		function obj = clonalConversion(simParams, mutantParams, solverParams, seedParams, outputTypes, chastePath, chasteTestOutputLocation)


			obj.simParams = simParams;
			obj.mutantParams = mutantParams;
			obj.solverParams = solverParams;
			obj.seedParams = seedParams;

			obj.outputTypes = outputTypes;

			obj.chastePath = [getenv('HOME'), '/'];

			outputLocation = getenv('CHASTE_TEST_OUTPUT');

			if isempty(outputLocation)
				obj.chasteTestOutputLocation = ['/tmp/', getenv('USER'),'/testoutput/'];
			else
				if ~strcmp(outputLocation(end),'/')
					outputLocation(end+1) = '/';
				end
				obj.chasteTestOutputLocation = outputLocation;
			end

		end


		function runConversion(obj, mutations, mvalues, reps)

			for i = 1:length(mutations)
				obj.mutantParams(mutations{i}) = mvalues(i);
			end
			for j=1:reps
				obj.seedParams = containers.Map({'run'}, {j});
				s = simulateCryptColumnMutation(obj.simParams, obj.mutantParams, obj.solverParams, obj.seedParams, obj.outputTypes, obj.chastePath, obj.chasteTestOutputLocation);
				s.generateSimulationData();
			end

		end

	end


end
