classdef simulateCryptColumnMutation < chasteSimulation
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

		chasteTest = 'TestCryptColumnMutation'

	end

	properties (SetAccess = private)
		% These are the input variables for TestCryptColumn
		% If the c++ code is ever changed to have new input variables, this may
		% need to be updated, unnless the new input parameter relates directly to data output
		% in which case the flag should be put into the dataType instance

		% These parameters are for the healthy crypt
		n 			uint16 {mustBeNonnegative}
		np 			uint16 {mustBeNonnegative}
		ees 		double {mustBeNonnegative}
		ms 			double {mustBeNonnegative}
		cct 		double {mustBeNonnegative}
		wt 			double {mustBeNonnegative}
		vf 			double {mustBeNonnegative, mustBeLessThanOrEqual(vf,1)}

		% These parameters are for the mutant cell
		mpos		uint16 {mustBeNonnegative}
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

	end

	methods
		function obj = simulateCryptColumnMutation(simParams, mutantParams, solverParams, seedParams, outputTypes, chastePath, chasteTestOutputLocation)
			% The constructor for the simulateCryptColumn object
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

			obj.chastePath = chastePath;


			obj.assignParameters(); % A helper method to clear up the constructor from clutter


			if ~strcmp(chastePath(end),'/')
				chastePath(end+1) = '/';
			end

			obj.generateSimulationCommand();

			obj.generateSaveLocation();

			if ~strcmp(chasteTestOutputLocation(end),'/')
				chasteTestOutputLocation(end+1) = '/';
			end			

			obj.generateSimOutputLocation(chasteTestOutputLocation);

		end

	end


	methods (Access = protected)
		% Helper methods to build the class

		function assignParameters(obj)
			% This assigns the variables to the object properties and 
			% provides some error checking/validation

			obj.n 			= obj.simParams('n');
			obj.np			= obj.simParams('np');
			obj.ees			= obj.simParams('ees');
			obj.ms			= obj.simParams('ms');
			obj.cct			= obj.simParams('cct');
			obj.wt			= obj.simParams('wt');
			obj.vf			= obj.simParams('vf');

			obj.mpos 		= obj.mutantParams('mpos');
			obj.Mnp			= obj.mutantParams('Mnp');
			obj.eesM		= obj.mutantParams('eesM');
			obj.msM			= obj.mutantParams('msM');
			obj.cctM		= obj.mutantParams('cctM');
			obj.wtM			= obj.mutantParams('wtM');
			obj.Mvf			= obj.mutantParams('Mvf');

			obj.t			= obj.solverParams('t');
			obj.bt			= obj.solverParams('bt');
			obj.dt			= obj.solverParams('dt');
			
			obj.run_number	= obj.seedParams('run');

			if obj.wt > (obj.cct - 1)
				error('Growing time (wt) is longer than the cell cycle time (cct)');
			end

			if obj.wt > (obj.cct * obj.cctM - 1)
				error('Growing time (wt) is longer than the mutated cell cycle time (cct * cctM)');
			end

		end

		function generateSimOutputLocation(obj, chasteTestOutputLocation)
			% This generates the simulation output path for the given parameters
			% in the given Chaste test. This will depend on how the
			% Chaste function 'simulator.SetOutputDirectory()' is implemented, so this method
			% will be test-specific. The default values of some parameters will need to be known here

			% This uses the properties rather than the maps because the order needs to be identical
			% to that used in the Chaste Test, and doing that using maps takes a lot of effort


			obj.simOutputLocation = sprintf('%s%s/n_%d_np_%d_EES_%g_MS_%g_CCT_%g_WT_%g_VF_%g/', chasteTestOutputLocation,obj.chasteTest, obj.n, obj.np, obj.ees, obj.ms, obj.cct, obj.wt, obj.vf);
			obj.simOutputLocation = [obj.simOutputLocation, sprintf('mpos_%g_Mnp_%g_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/run_%d/results_from_time_%d/', obj.mpos, obj.Mnp, obj.eesM, obj.msM, obj.cctM, obj.wtM, obj.Mvf, obj.run_number, obj.bt)];

		end

		function generateSaveLocation(obj)
			% This generates the full path to the specific data file for the simulation
			% If the path doesn't exist it creates the missing folder structure

			obj.saveLocation = [obj.chastePath, 'Research/Crypt/Data/Chaste/', obj.chasteTest, '/'];

			% Build the folder structure with the parameter names
			% This uses the order that the map puts it in
			% and it doesn't account for the default value of parameters when they
			% aren't in the simParams keys

			if isKey(obj.simParams,'name');
				% Allows for the possibility of naming a particular parameter set
				% useful if they need to be distinguished easily, but could lead to 
				% duplication of data and simulation time
				obj.saveLocation = [obj.saveLocation, obj.simParams('name')];
			else
				k = obj.simParams.keys;
				v = obj.simParams.values;

				obj.saveLocation = [obj.saveLocation, 'params'];
				for i = 1:obj.simParams.Count
					obj.saveLocation = [obj.saveLocation, sprintf('_%s_%g',k{i}, v{i})];
				end
			end

			obj.saveLocation = [obj.saveLocation, '/mutant'];
			
			k = obj.mutantParams.keys;
			v = obj.mutantParams.values;
			for i = 1:obj.mutantParams.Count
				obj.saveLocation = [obj.saveLocation, sprintf('_%s_%g',k{i}, v{i})];
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
				obj.inputString = [obj.inputString, sprintf(' -%s %g',k{i}, v{i})];
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



