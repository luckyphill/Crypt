classdef dummySimulation < simulation
	% A dummy class to test the simulation class at the highest level


	properties

		saveLocation = getenv('HOME');
	end
	methods

		function obj = dummySimulation(outputTypes)

			obj.outputTypes = outputTypes;

		end


		function status = runSimulation(obj)
			file = [getenv('HOME'),'/Research/Crypt/Chaste_models/ChasteMembrane/matlab_driver/testing/dummy.txt'];

			csvwrite(file, [1,2;3,4]);
			status = true;
		end

	end

end






