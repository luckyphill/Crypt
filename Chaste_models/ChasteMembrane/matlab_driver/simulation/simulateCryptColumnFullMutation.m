classdef simulateCryptColumnFullMutation < chasteSimulation
	% A class defining the generic things a simulation needs
	% It will be handed an object of type simulation
	% The simulation runner doesn't care what happens to get the data,
	% it just activates the functions that generate it or retreive it
	% To that end, it doesn't care about variables, generating file names etc,
	% it just uses what the simulation has defined


	properties (SetAccess = immutable)
		% The name of the actual chaste test function as a string. This will
		% be used to build the simulation command and directory structure

		% Since this is a concrete implementation of a chasteSimulation the
		% name of the test will never be changed

		chasteTest = 'TestCryptColumnFullMutation'

	end

	properties (SetAccess = private)
		% These are the input variables for TestCryptColumn
		% If the c++ code is ever changed to have new input variables, this may
		% need to be updated, unnless the new input parameter relates directly to data output
		% in which case the flag should be put into the dataType instance

		% The parameters to identify the crypt type
		cryptType	uint16 {mustBeNonnegative, mustBeLessThanOrEqual(cryptType,9)}
		cryptName

		% These parameters are for the mutant cell
		Mnp 		uint16 {mustBeNonnegative}
		eesM 		double {mustBeNonnegative}
		msM 		double {mustBeNonnegative}
		cctM 		double {mustBeNonnegative}
		wtM 		double {mustBeNonnegative}
		Mvf 		double {mustBeNonnegative, mustBeLessThanOrEqual(Mvf,1)}



		% These are solver parameters
		t 			double {mustBeNonnegative}
		bt 			double {mustBeNonnegative}
		dt 			double {mustBeNonnegative}

		% This is the RNG seed parameter
		run_number 	double {mustBeNumeric}

		% The place where the Chaste test output is found
		outputLocation 

	end

	methods
		function obj = simulateCryptColumnFullMutation(simParams, mutantParams, solverParams, seedParams, outputTypes)
			% The constructor for the simulateCryptColumnFullMutation object
			% This expects the variables to be handed in as maps, which helps
			% make some of the generation functions easier and less cluttered to write
			% In addition, it needs to know where to find the 'chaste_build' and 'Research' folders
			% which should both be in the same directory. This is so the functions can
			% be used on multiple different machines without needing to manually change
			% the path each time the script moves to another computer

			obj.simParams = simParams;
			obj.mutantParams = mutantParams;
			obj.solverParams = solverParams;
			obj.seedParams = seedParams;

			obj.outputTypes = outputTypes;

			obj.assignParameters(); % A helper method to clear up the constructor from clutter

			obj.chastePath = getenv('HOME');
			if isempty(obj.chastePath)
				error('HOME environment variable not set');
			end
			if ~strcmp(obj.chastePath(end),'/')
				obj.chastePath(end+1) = '/';
			end

			outputLocation = getenv('CHASTE_TEST_OUTPUT');

			if isempty(outputLocation)
				outputLocation = ['/tmp/', getenv('USER'),'/testoutput/'];
			else
				if ~strcmp(outputLocation(end),'/')
					outputLocation(end+1) = '/';
				end
			end

			obj.outputLocation = outputLocation;

			obj.generateSimulationCommand();

			obj.generateSaveLocation();

			obj.generateSimOutputLocation();

		end

	end


	methods (Access = protected)
		% Helper methods to build the class

		function assignParameters(obj)
			% This assigns the variables to the object properties and 
			% provides some error checking/validation

			obj.cryptType	= obj.simParams('crypt');

			obj.Mnp			= obj.mutantParams('Mnp');
			obj.eesM		= obj.mutantParams('eesM');
			obj.msM			= obj.mutantParams('msM');
			obj.cctM		= obj.mutantParams('cctM');
			obj.wtM			= obj.mutantParams('wtM');
			obj.Mvf			= obj.mutantParams('Mvf');

			obj.t			= obj.solverParams('t');
			obj.bt			= obj.solverParams('bt');
			if isKey(obj.solverParams, 'dt')
				obj.dt		= obj.solverParams('dt');
			end
			
			obj.run_number	= obj.seedParams('run');

			% Validation for phase length occurs in the chaste simulation 

			% Since each crypt is given a name, now we need to extract that name given the cryptType

			switch obj.cryptType
				case 1
					obj.cryptName = 'MouseColonDesc';
				case 2
					obj.cryptName = 'MouseColonAsc';
				case 3
					obj.cryptName = 'MouseColonTrans';
				case 4
					obj.cryptName = 'MouseColonCaecum';
				case 5
					obj.cryptName = 'RatColonDesc';
				case 6
					obj.cryptName = 'RatColonAsc';
				case 7
					obj.cryptName = 'RatColonTrans';
				case 8
					obj.cryptName = 'RatColonCaecum';
				case 9
					obj.cryptName = 'HumanColon';
				otherwise
					error('Crypt type not found');
			end

		end

		function generateSimOutputLocation(obj)
			% This generates the simulation output path for the given parameters
			% in the given Chaste test. This will depend on how the
			% Chaste function 'simulator.SetOutputDirectory()' is implemented, so this method
			% will be test-specific. The default values of some parameters will need to be known here


			obj.simOutputLocation = sprintf('%s%s/%s/', obj.outputLocation, obj.chasteTest, obj.cryptName);
			obj.simOutputLocation = [obj.simOutputLocation, sprintf('Mnp_%g_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_%d/', obj.Mnp, obj.eesM, obj.msM, obj.cctM, obj.wtM, obj.Mvf, obj.run_number, obj.bt)];

		end

		function generateSaveLocation(obj)
			% This generates the full path to the specific data file for the simulation
			% If the path doesn't exist it creates the missing folder structure

			obj.saveLocation = [obj.chastePath, 'Research/Crypt/Data/Chaste/', obj.chasteTest, '/', obj.cryptName];

			% Build the folder structure with the parameter names
			% This uses the order that the map puts it in
			% and it doesn't account for the default value of parameters when they
			% aren't in the simParams keys


			obj.saveLocation = [obj.saveLocation, '/mutant'];
			
			k = obj.mutantParams.keys;
			v = obj.mutantParams.values;
			for i = 1:obj.mutantParams.Count
				if ~strcmp(k{i},'name')
					obj.saveLocation = [obj.saveLocation, sprintf('_%s_%g',k{i}, v{i})];
				end
			end

			obj.saveLocation = [obj.saveLocation, '/numerics'];

			k = obj.solverParams.keys;
			v = obj.solverParams.values;
			for i = 1:obj.solverParams.Count
				obj.saveLocation = [obj.saveLocation, sprintf('_%s_%g',k{i}, v{i})];
			end

			obj.saveLocation = [obj.saveLocation, '/'];

			if exist(obj.saveLocation,'dir')~=7
				mkdir(obj.saveLocation);
			end

		end

		function generateSimulationCommand(obj)
			% This takes the path the call the simulation
			% and adds it to the input string to create the full simulation
			% command for the specific parameter set, numerical conditions, and seed

			obj.generateInputString();
			obj.simulationCommand = [obj.chastePath, 'chaste_build/projects/ChasteMembrane/test/', obj.chasteTest, obj.inputString];

		end

		function generateInputString(obj)
			% Generates the input string needed to run the specific parameter set
			% This will be test-specific, and will be determined by the parameters
			% defined in the Chaste test used

			% This does not specify an order for the parameters, they will be written in
			% alphabetical order, as this is they are stored in the map by default

			obj.inputString = [];

			k = obj.simParams.keys;
			v = obj.simParams.values;
			for i = 1:obj.simParams.Count
				if ~strcmp(k{i}, 'name')
					obj.inputString = [obj.inputString, sprintf(' -%s %g',k{i}, v{i})];
				end
			end

			k = obj.mutantParams.keys;
			v = obj.mutantParams.values;
			for i = 1:obj.mutantParams.Count
				if ~strcmp(k{i}, 'name')
					obj.inputString = [obj.inputString, sprintf(' -%s %g',k{i}, v{i})];
				end
			end

			k = obj.solverParams.keys;
			v = obj.solverParams.values;
			for i = 1:obj.solverParams.Count
				obj.inputString = [obj.inputString, sprintf(' -%s %g',k{i}, v{i})];
			end

			k = obj.seedParams.keys;
			v = obj.seedParams.values;
			for i = 1:obj.seedParams.Count
				obj.inputString = [obj.inputString, sprintf(' -%s %g',k{i}, v{i})];
			end

			% A given dataType may need specific flags/input parameters in order
			% generate the correct data files
			for j = 1:length(obj.outputTypesToRun)
				if obj.outputTypesToRun{j}.typeParams.Count > 0
					
					k = obj.outputTypesToRun{j}.typeParams.keys;
					v = obj.outputTypesToRun{j}.typeParams.values;
					for i = 1:obj.outputTypesToRun{j}.typeParams.Count
						obj.inputString = [obj.inputString, sprintf(' -%s %g',k{i}, v{i})];
					end

				end
			end

		end

	end

end



