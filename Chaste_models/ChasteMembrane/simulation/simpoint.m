classdef simpoint
	% A class defining a simulation point for a given Chaste test
	% It will be the primary way of controlling the data from a simulation
	% In the class will be held:
	% - Input paramters
	% - The simulation command
	% - Output file writer, specific to the type of data required
	% - Output file location
	% - A method controlling the simulation running and data checking
	% Essentially the purpose of this class is to put the data in a standard location
	% and make sure that simulations only run when the data does not exist
	% OR the data is specifically requested to be regenerated

	properties
		% The various parameters are grouped by:
		% simParams: These define the crypt shape and behaviour
		% solverParams: These define numerical conditions, like run time, time step
		% seedParams: These define the intial conditions of the crypt (in this case, a random number seed)
		% They are stored in maps where key = the flag/variable name, value = numerical value of the variable
		% These are set when the simulation is initialised and won't change
		simParams containers.Map

		solverParams containers.Map

		seedParams containers.Map

		% The name of the test.
		% This is used when building the simulation command
		chasteTest

		% The path to the function that runs the simulation
		% May not be needed for the most general form of this class,
		% but is definitely needed for using Chaste
		pathToFunction

		% Where the simulation output is stored in general
		% This will have a deeper folder structure, and is used as the base
		pathToSimOutput

		% This is where the data is saved to.
		% There will be a deeper folder structure for the 
		pathToDatabase

		% This is an object that manages reading and writing of output
		outputType

		% A flag to tell the data generating method if existing data is to be overwritten
		overWrite = false;
	end

	properties (SetAccess = protected)
		% These properties are determined from the input values, and are set 
		% in the constructor only (hence immutable)
		% The input values never change for a given simulation, so these will never change

		simOutputLocation % Where Chaste stores its own output
		dataSaveLocation % Where the data for the given analysis will be stored

		dataFile
		errorFile

		fileName

		simulationCommand

		inputString

	end

	properties (SetAccess = protected, GetAccess = public)
		% These properties are determined from simulations and can be modified
		% within the class at any time, but cannot be modified from outside

		% The console output from the simulation
		cmdout

		% The loaded simulation data in the format defined in 'outputType'
		data
	end




	methods
		
		function obj = set.outputType( obj, v )
			% This is to validate the object given to outputType in the constructor
            validateattributes(v, {'dataType'}, {});
            obj.outputType = v;
        end


		% These methods are available externally and are how the data gathering is handled

		function sp = simulation(p)
			% Initialise the simulation and generate all the fixed file names
			% p is an input structure, containing all the details needed for a simulation
			% they are then dispersed appropriately

			sp.simParams = p.simParams;

			sp.solverParams = p.solverParams;

			sp.seedParams = p.seedParams;

			% This controls the data saving
			sp.outputType = p.outputType;

			% The name of the specific Chaste test used
			sp.chasteTest = p.chasteTest;

			% An optional argument to trigger overwriting of existing data
			% Useful when a dataType is changed, or the Chaste test is modified
			if isfield(p, 'overWrite')
				sp.overWrite = p.overWrite;
			end

			% Fixed paths to different input/output/command locations
			sp.pathToFunction = p.pathToFunction;

			sp.pathToSimOutput = p.pathToSimOutput;

			sp.pathToDatabase = p.pathToDatabase;

			% Full path to locations with parameter dependent paths
			sp.simOutputLocation = sp.generateSimOutputLocation();
			
			sp.dataSaveLocation = sp.generateDataSaveLocation();

			% The filename of the actual file
			sp.fileName = sp.generateFileName();

			% Data and error output files
			sp.dataFile = [sp.dataSaveLocation, sp.fileName, '.txt'];
			sp.errorFile = [sp.dataSaveLocation, sp.fileName, '.err'];

			% The string that provides the parameter input
			sp.inputString = sp.generateInputString();

			% The actual command that runs the whole shebang
			sp.simulationCommand = sp.generateSimulationCommand();

		end


		function [data, successCode] = generateSimulationData(sp)
			% Runs the simulation, and makes sure all the data is in the correct place
			% First it checks for existing data
			% successCode is a flag to say what happened:
			% 0 - something went wrong
			% 1 - simulation ran, data processed and saved
			% 2 - existing data loaded

			%% TODO: This implicitly assumes the data is contained in a single file.
			%% It could easily be in multiple, and dataType can handle this
			%% To make this more general, implement a way of having multiple files
			data = nan;
			successCode = 0;

			if ~sp.overWrite
				% We are going to take whatever data exists and if it doesn't exist
				% we will generate it
				try
					data = sp.outputType.loadData(sp);
					successCode = 2;
				catch err
					fprintf('%s\n',err.message);
					fprintf('Problem retrieving data, attempting to regenerate\n');
					
					% The data couldn't be read in for some reason, so attempt to regenerate
					if sp.runSimulation();
						try
							data = sp.outputType.loadData(sp);
							successCode = 1;
						catch err
							fprintf('%s\n',err.message);
							fprintf('Regeneration failed\n');
							successCode = 0;
						end
					end
				end

			else
				% We are going to run the simulation and make new data, regardless
				% of what already exists
				if sp.runSimulation();
					try
						data = sp.outputType.loadData(sp);
						successCode = 1;
					catch err
						fprintf('%s\n',err.message);
						fprintf('Data generation failed\n');
						successCode = 0;
					end
				end

			end

		end

		function status = runSimulation(sp)
			% Runs the simulation command
			% This will never throw an error

			% The 'system' command will always work in Matlab. It doesn't care what you type
			% it just reports back what the console said

			% Delete the previous error file
			[~,~] = system(['rm ', sp.errorFile]);
			[status, sp.cmdout] = system([sp.simulationCommand, sp.inputString],'-echo');

			if status
				% The simulation ended in an unexpected way, save console output to the error file
				fid = fopen(sp.errorFile,'w');
				fprintf(fid, cmdout);
				fclose(fid);
				fprintf('Problem running simulation. Console output saved in:\n%s', sp.errorFile);
			else
				% If status returns 0, then the command completed without failing
				% However, this does not mean the data will necessarily be in the correct
				% format. Error checking needs to happen in the data processing
				% Data should be able to be processed correctly
				sp.outputType.saveData(sp);
			end

		end

		function data = loadSimulationData(sp)
			% Uses the loader to get the data from the file when it knows a file exists
			% There might be a situation when the file exists, but it wasn't written correctly
			% In this case, loader should throw an error, which will be handled here

			data = nan;
			try
				data = sp.dataType.loadData(sp);
			catch err
				fprintf('%s\n',err.message);
			end

		end

	end

	methods (Access = protected)
		% These methods are purely for managing the class 

		function fileName = generateFileName(sp)
			% This function generates the filename based on the input variables
			% sometime the input variables might be held in the folder structure
			% so this might just be a seed number

			fileName = [sp.outputType.name];

			k = sp.seedParams.keys;
			v = sp.seedParams.values;
			for i = 1:sp.seedParams.Count
				fileName = [fileName, sprintf('_%s_%g',k{i}, v{i})];
			end

		end
		

		function simOutputLocation =  generateSimOutputLocation(sp)
			% This generates the simulation output path for the given parameters
			% in the given Chaste test. This will depend on how the
			% Chaste function 'simulator.SetOutputDirectory()' is implemented, so this method
			% will be test-specific. The default values of some parameters will need to be know here

			n = 20;
			np = 10;
			ees = 20;
			ms = 50;
			cct = 15;
			wt = 10;
			vf = 0.75;

			bt = 40;
			t = 100;
			dt = 0.001;
			sm = 10;

			mpos = 1;
			
			rdiv = 0;
			rple = 'MAX';
			rcct = 15;
			use_resist = false;

			Mnp = 10;
			eesM = 1;
			msM = 1;
			cctM = 1;
			wtM = 1;
			Mvf = 0.75;

			k = sp.simParams.keys;
			v = sp.simParams.values;

			for i = 1:sp.simParams.Count

				flag = k{i};

				switch flag
				 	case 'n'
				 		n = v{i};
				 	case 'np'
				 		np = v{i};
				 		Mnp = np;
				 	case 'ees'
				 		ees = v{i};
				 	case 'ms'
				 		ms = v{i};
				 	case 'cct'
				 		cct = v{i};
				 		rcct = cct;
				 	case 'wt'
				 		wt = v{i};
				 	case 'vf'
				 		vf = v{i};
				 		Mvf = vf;
					case 'Mnp'
				 		Mnp = v{i};
				 	case 'eesM'
				 		eesM = v{i};
				 	case 'msM'
				 		msM = v{i};
				 	case 'cctM'
				 		cctM = v{i};
				 	case 'wtM'
				 		wtM = v{i};
				 	case 'Mvf'
				 		Mvf = v{i};
				 	case 'rdiv'
				 		rdiv = v{i};
				 		use_resist = true;
				 	case 'rple'
				 		rple = v{i};
				 	case 'rcct'
				 		rcct = v{i};
				 	otherwise
				 		error('Unknown flag %s', flag)  		
				end
			end

			k = sp.solverParams.keys;
			v = sp.solverParams.values;

			for i = 1:sp.solverParams.Count

				flag = k{i};

				switch flag
					case 'bt'
				 		bt = v{i};
				 	case 't'
				 		t = v{i};
				 	case 'dt'
				 		dt = v{i};
				 	case 'sm'
				 		sm = v{i};
				 	otherwise
				 		error('Unknown flag %s', flag) 		
				end
			end

			run_number = sp.seedParams('run');

			simOutputLocation = sp.pathToSimOutput;

			path_normal = sprintf('n_%d_np_%d_EES_%g_MS_%g_CCT_%g_WT_%g_VF_%g_run_%d/', n, np, ees, ms, cct, wt, vf, run_number);

			simOutputLocation = [simOutputLocation, sp.chasteTest, '/', path_normal];

			% path_mpos = sprintf('mpos_%d_', mpos);

			% simOutputLocation = [simOutputLocation, path_mpos];

			% if use_resist
			% 	path_resist = sprintf('rdiv_%d_rple_%g_rcct_%g_', rdiv, rple, rcct);
			% 	simOutputLocation  = [simOutputLocation, path_resist];
			% end

			% path_mutant = sprintf('Mnp_%d_eesM_%g_msM_%g_cctM_%g_wtM_%g_Mvf_%g/', Mnp, eesM, msM, cctM, wtM, Mvf);

			% simOutputLocation =  [simOutputLocation, path_mutant];

			path_results = sprintf('results_from_time_%d/',bt);

			simOutputLocation =  [simOutputLocation, path_results];

		end


		function saveDataLocation =generateDataSaveLocation(sp)
			% This generates the full path to the specific data file for the simulation
			% If the path doesn't exist it creates the missing folder structure

			saveDataLocation = [sp.pathToDatabase, sp.chasteTest, '/',  sp.outputType.name, '/'];

			% Build the folder structure with the parameter names
			% This uses the order that the map puts it in
			% and it doesn't account for the default value of parameters when they
			% aren't in the simParams keys

			k = sp.simParams.keys;
			v = sp.simParams.values;
			saveDataLocation = [saveDataLocation, 'params'];
			for i = 1:sp.simParams.Count
				saveDataLocation = [saveDataLocation, sprintf('_%s_%g',k{i}, v{i})];
			end

			saveDataLocation = [saveDataLocation, '/numerics'];

			k = sp.solverParams.keys;
			v = sp.solverParams.values;
			for i = 1:sp.solverParams.Count
				saveDataLocation = [saveDataLocation, sprintf('_%s_%g',k{i}, v{i})];
			end

			saveDataLocation = [saveDataLocation, '/'];

			if exist(saveDataLocation,'dir')~=7
				mkdir(saveDataLocation);
			end

		end

		function simulationCommand = generateSimulationCommand(sp)
			% This takes the path the call the simulation
			% and adds it to the input string to create the full simulation
			% command for the specific parameter set, numerical conditions, and seed


			simulationCommand = [sp.pathToFunction, sp.chasteTest, sp.inputString];

		end

		function inputString = generateInputString(sp)
			% Generates the input string needed to run the specific parameter set
			% This will be test-specific, and will be determined by the parameters
			% defined in the Chaste test used

			% This does not specify an order for the parameters, they will be written in
			% alphabetical order, as this is they are stored in the map by default

			inputString = [];

			k = sp.simParams.keys;
			v = sp.simParams.values;
			for i = 1:sp.simParams.Count
				inputString = [inputString, sprintf(' -%s %g',k{i}, v{i})];
			end

			k = sp.solverParams.keys;
			v = sp.solverParams.values;
			for i = 1:sp.solverParams.Count
				inputString = [inputString, sprintf(' -%s %g',k{i}, v{i})];
			end

			k = sp.seedParams.keys;
			v = sp.seedParams.values;
			for i = 1:sp.seedParams.Count
				inputString = [inputString, sprintf(' -%s %g',k{i}, v{i})];
			end

			% A given dataType may need specific flags/imput parameters in order
			% generate the correct data files

			if sp.outputType.typeParams.Count > 0
				k = sp.outputType.typeParams.keys;
				v = sp.outputType.typeParams.values;
				for i = 1:sp.outputType.typeParams.Count
					inputString = [inputString, sprintf(' -%s %g',k{i}, v{i})];
				end
			end

		end

	end
end






